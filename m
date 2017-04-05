From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix Octeon core watchdog timeout false
 alarm
Date: Tue, 4 Apr 2017 19:26:57 -0700
Message-ID: <20170405022657.GA1064@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0045.outbound.protection.outlook.com ([104.47.42.45]:51328
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751692AbdDEC0P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 22:26:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detection of watchdog timeout of Octeon cores is flawed and susceptible to
false alarms.  Refactor by removing the detection code, and in its place,
leverage existing code that monitors for an indication from the NIC
firmware that an Octeon core crashed; expand the meaning of the indication
to "an Octeon core crashed or its watchdog timer expired".  Detection of
watchdog timeout is now delegated to an exception handler in the NIC
firmware; this is free of false alarms.

Also if there's an Octeon core crash or watchdog timeout:
(1) Disable VF Ethernet links.
(2) Decrement the module refcount by an amount equal to the number of
    active VFs of the NIC whose Octeon core crashed or had a watchdog
    timeout.  The refcount will continue to reflect the active VFs of
    other liquidio NIC(s) (if present) whose Octeon cores are faultless.

Item (2) is needed to avoid the case of not being able to unload the driver
because the module refcount is stuck at some non-zero number.  There is
code that, in normal cases, decrements the refcount upon receiving a
message from the firmware that a VF driver was unloaded.  But in
exceptional cases like an Octeon core crash or watchdog timeout, arrival of
that particular message from the firmware might be unreliable.  That normal
case code is changed to not touch the refcount in the exceptional case to
avoid contention (over the refcount) with the liquidio_watchdog kernel
thread who will carry out item (2).

Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 178 ++++++++++++---------
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   2 +
 .../net/ethernet/cavium/liquidio/octeon_network.h  |   4 -
 3 files changed, 107 insertions(+), 77 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index a8426d3..fa673a1 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -173,6 +173,8 @@ static int liquidio_stop(struct net_device *netdev);
 static void liquidio_remove(struct pci_dev *pdev);
 static int liquidio_probe(struct pci_dev *pdev,
 			  const struct pci_device_id *ent);
+static int liquidio_set_vf_link_state(struct net_device *netdev, int vfidx,
+				      int linkstate);
 
 static struct handshake handshake[MAX_OCTEON_DEVICES];
 static struct completion first_stage;
@@ -1199,97 +1201,122 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 	return 0;
 }
 
+static struct octeon_device *get_other_octeon_device(struct octeon_device *oct)
+{
+	struct octeon_device *other_oct;
+
+	other_oct = lio_get_device(oct->octeon_id + 1);
+
+	if (other_oct && other_oct->pci_dev) {
+		int oct_busnum, other_oct_busnum;
+
+		oct_busnum = oct->pci_dev->bus->number;
+		other_oct_busnum = other_oct->pci_dev->bus->number;
+
+		if (oct_busnum == other_oct_busnum) {
+			int oct_slot, other_oct_slot;
+
+			oct_slot = PCI_SLOT(oct->pci_dev->devfn);
+			other_oct_slot = PCI_SLOT(other_oct->pci_dev->devfn);
+
+			if (oct_slot == other_oct_slot)
+				return other_oct;
+		}
+	}
+
+	return NULL;
+}
+
+static void disable_all_vf_links(struct octeon_device *oct)
+{
+	struct net_device *netdev;
+	int max_vfs, vf, i;
+
+	if (!oct)
+		return;
+
+	max_vfs = oct->sriov_info.max_vfs;
+
+	for (i = 0; i < oct->ifcount; i++) {
+		netdev = oct->props[i].netdev;
+		if (!netdev)
+			continue;
+
+		for (vf = 0; vf < max_vfs; vf++)
+			liquidio_set_vf_link_state(netdev, vf,
+						   IFLA_VF_LINK_STATE_DISABLE);
+	}
+}
+
 static int liquidio_watchdog(void *param)
 {
-	u64 wdog;
-	u16 mask_of_stuck_cores = 0;
-	u16 mask_of_crashed_cores = 0;
-	int core_num;
-	u8 core_is_stuck[LIO_MAX_CORES];
-	u8 core_crashed[LIO_MAX_CORES];
+	bool err_msg_was_printed[LIO_MAX_CORES];
+	u16 mask_of_crashed_or_stuck_cores = 0;
+	bool all_vf_links_are_disabled = false;
 	struct octeon_device *oct = param;
+	struct octeon_device *other_oct;
+#ifdef CONFIG_MODULE_UNLOAD
+	long refcount, vfs_referencing_pf;
+	u64 vfs_mask1, vfs_mask2;
+#endif
+	int core;
 
-	memset(core_is_stuck, 0, sizeof(core_is_stuck));
-	memset(core_crashed, 0, sizeof(core_crashed));
+	memset(err_msg_was_printed, 0, sizeof(err_msg_was_printed));
 
 	while (!kthread_should_stop()) {
-		mask_of_crashed_cores =
+		/* sleep for a couple of seconds so that we don't hog the CPU */
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(msecs_to_jiffies(2000));
+
+		mask_of_crashed_or_stuck_cores =
 		    (u16)octeon_read_csr64(oct, CN23XX_SLI_SCRATCH2);
 
-		for (core_num = 0; core_num < LIO_MAX_CORES; core_num++) {
-			if (!core_is_stuck[core_num]) {
-				wdog = lio_pci_readq(oct, CIU3_WDOG(core_num));
-
-				/* look at watchdog state field */
-				wdog &= CIU3_WDOG_MASK;
-				if (wdog) {
-					/* this watchdog timer has expired */
-					core_is_stuck[core_num] =
-						LIO_MONITOR_WDOG_EXPIRE;
-					mask_of_stuck_cores |= (1 << core_num);
-				}
-			}
+		if (!mask_of_crashed_or_stuck_cores)
+			continue;
 
-			if (!core_crashed[core_num])
-				core_crashed[core_num] =
-				    (mask_of_crashed_cores >> core_num) & 1;
-		}
+		WRITE_ONCE(oct->cores_crashed, true);
+		other_oct = get_other_octeon_device(oct);
+		if (other_oct)
+			WRITE_ONCE(other_oct->cores_crashed, true);
 
-		if (mask_of_stuck_cores) {
-			for (core_num = 0; core_num < LIO_MAX_CORES;
-			     core_num++) {
-				if (core_is_stuck[core_num] == 1) {
-					dev_err(&oct->pci_dev->dev,
-						"ERROR: Octeon core %d is stuck!\n",
-						core_num);
-					/* 2 means we have printk'd  an error
-					 * so no need to repeat the same printk
-					 */
-					core_is_stuck[core_num] =
-						LIO_MONITOR_CORE_STUCK_MSGD;
-				}
-			}
-		}
+		for (core = 0; core < LIO_MAX_CORES; core++) {
+			bool core_crashed_or_got_stuck;
 
-		if (mask_of_crashed_cores) {
-			for (core_num = 0; core_num < LIO_MAX_CORES;
-			     core_num++) {
-				if (core_crashed[core_num] == 1) {
-					dev_err(&oct->pci_dev->dev,
-						"ERROR: Octeon core %d crashed!  See oct-fwdump for details.\n",
-						core_num);
-					/* 2 means we have printk'd  an error
-					 * so no need to repeat the same printk
-					 */
-					core_crashed[core_num] =
-						LIO_MONITOR_CORE_STUCK_MSGD;
-				}
+			core_crashed_or_got_stuck =
+						(mask_of_crashed_or_stuck_cores
+						 >> core) & 1;
+
+			if (core_crashed_or_got_stuck &&
+			    !err_msg_was_printed[core]) {
+				dev_err(&oct->pci_dev->dev,
+					"ERROR: Octeon core %d crashed or got stuck!  See oct-fwdump for details.\n",
+					core);
+					err_msg_was_printed[core] = true;
 			}
 		}
+
+		if (all_vf_links_are_disabled)
+			continue;
+
+		disable_all_vf_links(oct);
+		disable_all_vf_links(other_oct);
+		all_vf_links_are_disabled = true;
+
 #ifdef CONFIG_MODULE_UNLOAD
-		if (mask_of_stuck_cores || mask_of_crashed_cores) {
-			/* make module refcount=0 so that rmmod will work */
-			long refcount;
+		vfs_mask1 = READ_ONCE(oct->sriov_info.vf_drv_loaded_mask);
+		vfs_mask2 = READ_ONCE(other_oct->sriov_info.vf_drv_loaded_mask);
 
-			refcount = module_refcount(THIS_MODULE);
+		vfs_referencing_pf  = hweight64(vfs_mask1);
+		vfs_referencing_pf += hweight64(vfs_mask2);
 
-			while (refcount > 0) {
+		refcount = module_refcount(THIS_MODULE);
+		if (refcount >= vfs_referencing_pf) {
+			while (vfs_referencing_pf) {
 				module_put(THIS_MODULE);
-				refcount = module_refcount(THIS_MODULE);
-			}
-
-			/* compensate for and withstand an unlikely (but still
-			 * possible) race condition
-			 */
-			while (refcount < 0) {
-				try_module_get(THIS_MODULE);
-				refcount = module_refcount(THIS_MODULE);
+				vfs_referencing_pf--;
 			}
 		}
 #endif
-		/* sleep for two seconds */
-		set_current_state(TASK_INTERRUPTIBLE);
-		schedule_timeout(2 * HZ);
 	}
 
 	return 0;
@@ -4406,6 +4433,7 @@ octeon_recv_vf_drv_notice(struct octeon_recv_info *recv_info, void *buf)
 	struct octeon_device *oct = (struct octeon_device *)buf;
 	struct octeon_recv_pkt *recv_pkt = recv_info->recv_pkt;
 	int i, notice, vf_idx;
+	bool cores_crashed;
 	u64 *data, vf_num;
 
 	notice = recv_pkt->rh.r.ossp;
@@ -4416,19 +4444,23 @@ octeon_recv_vf_drv_notice(struct octeon_recv_info *recv_info, void *buf)
 	octeon_swap_8B_data(&vf_num, 1);
 	vf_idx = (int)vf_num - 1;
 
+	cores_crashed = READ_ONCE(oct->cores_crashed);
+
 	if (notice == VF_DRV_LOADED) {
 		if (!(oct->sriov_info.vf_drv_loaded_mask & BIT_ULL(vf_idx))) {
 			oct->sriov_info.vf_drv_loaded_mask |= BIT_ULL(vf_idx);
 			dev_info(&oct->pci_dev->dev,
 				 "driver for VF%d was loaded\n", vf_idx);
-			try_module_get(THIS_MODULE);
+			if (!cores_crashed)
+				try_module_get(THIS_MODULE);
 		}
 	} else if (notice == VF_DRV_REMOVED) {
 		if (oct->sriov_info.vf_drv_loaded_mask & BIT_ULL(vf_idx)) {
 			oct->sriov_info.vf_drv_loaded_mask &= ~BIT_ULL(vf_idx);
 			dev_info(&oct->pci_dev->dev,
 				 "driver for VF%d was removed\n", vf_idx);
-			module_put(THIS_MODULE);
+			if (!cores_crashed)
+				module_put(THIS_MODULE);
 		}
 	} else if (notice == VF_DRV_MACADDR_CHANGED) {
 		u8 *b = (u8 *)&data[1];
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index dab35bf..92f67de 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -542,6 +542,8 @@ struct octeon_device {
 	u32 rx_coalesce_usecs;
 	u32 rx_max_coalesced_frames;
 	u32 tx_max_coalesced_frames;
+
+	bool cores_crashed;
 };
 
 #define  OCT_DRV_ONLINE 1
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 454ec0c..bf48393 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -141,10 +141,6 @@ struct lio {
 #define LIO_SIZE         (sizeof(struct lio))
 #define GET_LIO(netdev)  ((struct lio *)netdev_priv(netdev))
 
-#define CIU3_WDOG(c)                 (0x1010000020000ULL + ((c) << 3))
-#define CIU3_WDOG_MASK               12ULL
-#define LIO_MONITOR_WDOG_EXPIRE      1
-#define LIO_MONITOR_CORE_STUCK_MSGD  2
 #define LIO_MAX_CORES                12
 
 /**
