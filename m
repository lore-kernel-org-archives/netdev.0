From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH 3/4] igb: Add support to igb for setting MAC and VLAN
	filters to hardware queues
Date: Tue, 17 Nov 2009 13:50:44 -0800
Message-ID: <20091117215043.15119.19684.stgit@localhost.localdomain>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:52722 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753989AbZKQVvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 16:51:17 -0500
In-Reply-To: <20091117214923.15119.98918.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

This is currently only supported in SR-IOV mode.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.h |    3 +
 drivers/net/igb/e1000_regs.h  |    1 
 drivers/net/igb/igb.h         |    2 +
 drivers/net/igb/igb_main.c    |   90 ++++++++++++++++++++++++++++++++++++-----
 4 files changed, 86 insertions(+), 10 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index b3808ca..c2d2b33 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -214,6 +214,9 @@ struct e1000_adv_tx_context_desc {
 #define E1000_VLVF_LVLAN          0x00100000
 #define E1000_VLVF_VLANID_ENABLE  0x80000000
 
+#define E1000_VMVIR_VLANA_DEFAULT	0x40000000 /* Always use default VLAN */
+#define E1000_VMVIR_VLANA_NEVER		0x80000000 /* Never insert VLAN tag */
+
 #define E1000_IOVCTL 0x05BBC
 #define E1000_IOVCTL_REUSE_VFQ 0x00000001
 
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 934e03b..42e8528 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -307,6 +307,7 @@
 #define E1000_VMOLR(_n)        (0x05AD0 + (4 * (_n)))
 #define E1000_VLVF(_n)         (0x05D00 + (4 * (_n))) /* VLAN Virtual Machine
                                                        * Filter - RW */
+#define E1000_VMVIR(_n)        (0x03700 + (4 * (_n)))
 
 #define wr32(reg, value) (writel(value, hw->hw_addr + reg))
 #define rd32(reg) (readl(hw->hw_addr + reg))
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 63abd1c..0a55cd2 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -75,11 +75,13 @@ struct vf_data_storage {
 	u16 vlans_enabled;
 	u32 flags;
 	unsigned long last_nack;
+	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
 };
 
 #define IGB_VF_FLAG_CTS            0x00000001 /* VF is clear to send data */
 #define IGB_VF_FLAG_UNI_PROMISC    0x00000002 /* VF has unicast promisc */
 #define IGB_VF_FLAG_MULTI_PROMISC  0x00000004 /* VF has multicast promisc */
+#define IGB_VF_FLAG_PF_SET_MAC     0x00000008 /* PF has set MAC address */
 
 /* RX descriptor control thresholds.
  * PTHRESH - MAC will consider prefetch if it has fewer than this number of
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 0cab5e2..67773e3 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -128,6 +128,9 @@ static void igb_msg_task(struct igb_adapter *);
 static void igb_vmm_control(struct igb_adapter *);
 static int igb_set_vf_mac(struct igb_adapter *, int, unsigned char *);
 static void igb_restore_vf_multicasts(struct igb_adapter *adapter);
+static int igb_set_queue_mac(struct net_device *netdev, int queue, u8 *mac);
+static int igb_set_queue_vlan(struct net_device *netdev, int queue, u16 vlan);
+
 
 #ifdef CONFIG_PM
 static int igb_suspend(struct pci_dev *, pm_message_t);
@@ -1302,6 +1305,8 @@ static const struct net_device_ops igb_netdev_ops = {
 	.ndo_vlan_rx_register	= igb_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= igb_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= igb_vlan_rx_kill_vid,
+	.ndo_set_queue_mac	= igb_set_queue_mac,
+	.ndo_set_queue_vlan	= igb_set_queue_vlan,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= igb_netpoll,
 #endif
@@ -2379,7 +2384,8 @@ static void igb_rlpml_set(struct igb_adapter *adapter)
 	wr32(E1000_RLPML, max_frame_size);
 }
 
-static inline void igb_set_vmolr(struct igb_adapter *adapter, int vfn)
+static inline void igb_set_vmolr(struct igb_adapter *adapter,
+				 int vfn, bool aupe)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 vmolr;
@@ -2392,8 +2398,11 @@ static inline void igb_set_vmolr(struct igb_adapter *adapter, int vfn)
 		return;
 
 	vmolr = rd32(E1000_VMOLR(vfn));
-	vmolr |= E1000_VMOLR_AUPE |        /* Accept untagged packets */
-	         E1000_VMOLR_STRVLAN;      /* Strip vlan tags */
+	vmolr |= E1000_VMOLR_STRVLAN;      /* Strip vlan tags */
+	if (aupe)
+		vmolr |= E1000_VMOLR_AUPE;   /* Accept untagged packets */
+	else
+		vmolr &= ~(E1000_VMOLR_AUPE); /* Tagged packets ONLY */
 
 	/* clear all bits that might not be set */
 	vmolr &= ~(E1000_VMOLR_BAM | E1000_VMOLR_RSSE);
@@ -2464,7 +2473,7 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	wr32(E1000_SRRCTL(reg_idx), srrctl);
 
 	/* set filtering for VMDQ pools */
-	igb_set_vmolr(adapter, reg_idx & 0x7);
+	igb_set_vmolr(adapter, reg_idx & 0x7, true);
 
 	/* enable receive descriptor fetching */
 	rxdctl = rd32(E1000_RXDCTL(reg_idx));
@@ -4352,6 +4361,49 @@ static s32 igb_vlvf_set(struct igb_adapter *adapter, u32 vid, bool add, u32 vf)
 	return -1;
 }
 
+static void igb_set_vmvir(struct igb_adapter *adapter, u32 vid, u32 vf)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	if (vid)
+		wr32(E1000_VMVIR(vf), (vid | E1000_VMVIR_VLANA_DEFAULT));
+	else
+		wr32(E1000_VMVIR(vf), 0);
+}
+
+static int igb_pf_set_vf_vlan(struct igb_adapter *adapter, int vf, u16 vlan)
+{
+	int err = 0;
+
+	if (vlan) {
+		err = igb_vlvf_set(adapter, vlan, true, vf);
+		if (err)
+			goto out;
+		igb_set_vmvir(adapter, vlan, vf);
+		igb_set_vmolr(adapter, vf, false);
+		adapter->vf_data[vf].pf_vlan = vlan;
+	} else if (adapter->vf_data[vf].pf_vlan) {
+		err = igb_vlvf_set(adapter, adapter->vf_data[vf].pf_vlan,
+				   false, vf);
+		if (err)
+			goto out;
+		igb_set_vmvir(adapter, vlan, vf);
+		igb_set_vmolr(adapter, vf, true);
+		adapter->vf_data[vf].pf_vlan = 0;
+	}
+out:
+	return err;
+}
+
+static int igb_set_queue_vlan(struct net_device *netdev, int queue, u16 vlan)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	if ((queue > adapter->vfs_allocated_count) ||
+	    (queue == 0) || (vlan > 4095))
+		return -EINVAL;
+	return igb_pf_set_vf_vlan(adapter, queue - 1, vlan);
+}
+
 static int igb_set_vf_vlan(struct igb_adapter *adapter, u32 *msgbuf, u32 vf)
 {
 	int add = (msgbuf[0] & E1000_VT_MSGINFO_MASK) >> E1000_VT_MSGINFO_SHIFT;
@@ -4362,15 +4414,18 @@ static int igb_set_vf_vlan(struct igb_adapter *adapter, u32 *msgbuf, u32 vf)
 
 static inline void igb_vf_reset(struct igb_adapter *adapter, u32 vf)
 {
-	/* clear all flags */
-	adapter->vf_data[vf].flags = 0;
+	/* clear flags */
+	adapter->vf_data[vf].flags &= ~(IGB_VF_FLAG_PF_SET_MAC);
 	adapter->vf_data[vf].last_nack = jiffies;
 
 	/* reset offloads to defaults */
-	igb_set_vmolr(adapter, vf);
+	igb_set_vmolr(adapter, vf, true);
 
 	/* reset vlans for device */
-	igb_clear_vf_vfta(adapter, vf);
+	if (adapter->vf_data[vf].pf_vlan)
+		igb_pf_set_vf_vlan(adapter, adapter->vf_data[vf].pf_vlan, vf);
+	else
+		igb_clear_vf_vfta(adapter, vf);
 
 	/* reset multicast table array for vf */
 	adapter->vf_data[vf].num_vf_mc_hashes = 0;
@@ -4384,7 +4439,8 @@ static void igb_vf_reset_event(struct igb_adapter *adapter, u32 vf)
 	unsigned char *vf_mac = adapter->vf_data[vf].vf_mac_addresses;
 
 	/* generate a new mac address as we were hotplug removed/added */
-	random_ether_addr(vf_mac);
+	if (!(adapter->vf_data[vf].flags & IGB_VF_FLAG_PF_SET_MAC))
+		random_ether_addr(vf_mac);
 
 	/* process remaining reset events */
 	igb_vf_reset(adapter, vf);
@@ -4493,7 +4549,10 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 		retval = igb_set_vf_rlpml(adapter, msgbuf[1], vf);
 		break;
 	case E1000_VF_SET_VLAN:
-		retval = igb_set_vf_vlan(adapter, msgbuf, vf);
+		if (adapter->vf_data[vf].pf_vlan)
+			retval = -1;
+		else
+			retval = igb_set_vf_vlan(adapter, msgbuf, vf);
 		break;
 	default:
 		dev_err(&pdev->dev, "Unhandled Msg %08x\n", msgbuf[0]);
@@ -5843,6 +5902,17 @@ static int igb_set_vf_mac(struct igb_adapter *adapter,
 	return 0;
 }
 
+static int igb_set_queue_mac(struct net_device *netdev, int queue, u8 *mac)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	if (!is_valid_ether_addr(mac) ||
+	    (queue > adapter->vfs_allocated_count) ||
+	    (queue == 0))
+		return -EINVAL;
+	adapter->vf_data[queue - 1].flags |= IGB_VF_FLAG_PF_SET_MAC;
+	return igb_set_vf_mac(adapter, queue - 1, mac);
+}
+
 static void igb_vmm_control(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;

