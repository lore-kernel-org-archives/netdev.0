From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: synchronize VF representor names with NIC
 firmware
Date: Wed, 1 Nov 2017 16:19:49 -0700
Message-ID: <20171101231949.GA21755@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        vijaya.guvva@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0070.outbound.protection.outlook.com ([104.47.42.70]:42050
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933449AbdKAXTy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 19:19:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>

LiquidIO firmware supports a vswitch that needs to know the names of the
VF representors in the host to maintain compatibility for direct
programming using external Openflow agents.  So, for each VF representor,
send its name to the firmware when it gets registered and when its name
changes.

Signed-off-by: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 15 +++++
 drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c  | 68 ++++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_vf_rep.h  |  2 +
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  8 ++-
 4 files changed, 92 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index f27f0af..f05045a 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1639,6 +1639,10 @@ static void liquidio_remove(struct pci_dev *pdev)
 	if (oct_dev->watchdog_task)
 		kthread_stop(oct_dev->watchdog_task);
 
+	if (!oct_dev->octeon_id &&
+	    oct_dev->fw_info.app_cap_flags & LIQUIDIO_SWITCHDEV_CAP)
+		lio_vf_rep_modexit();
+
 	if (oct_dev->app_mode && (oct_dev->app_mode == CVM_DRV_NIC_APP))
 		liquidio_stop_nic_module(oct_dev);
 
@@ -4029,6 +4033,17 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 		goto octnet_init_failure;
 	}
 
+	/* Call vf_rep_modinit if the firmware is switchdev capable
+	 * and do it from the first liquidio function probed.
+	 */
+	if (!oct->octeon_id &&
+	    oct->fw_info.app_cap_flags & LIQUIDIO_SWITCHDEV_CAP) {
+		if (lio_vf_rep_modinit()) {
+			liquidio_stop_nic_module(oct);
+			goto octnet_init_failure;
+		}
+	}
+
 	liquidio_ptp_init(oct);
 
 	dev_dbg(&oct->pci_dev->dev, "Network interfaces ready\n");
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c
index de0c80d..2adafa3 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c
@@ -625,3 +625,71 @@ static void lio_vf_rep_get_stats64(struct net_device *dev,
 
 	oct->vf_rep_list.num_vfs = 0;
 }
+
+static int
+lio_vf_rep_netdev_event(struct notifier_block *nb,
+			unsigned long event, void *ptr)
+{
+	struct net_device *ndev = netdev_notifier_info_to_dev(ptr);
+	struct lio_vf_rep_desc *vf_rep;
+	struct lio_vf_rep_req rep_cfg;
+	struct octeon_device *oct;
+	int ret;
+
+	switch (event) {
+	case NETDEV_REGISTER:
+	case NETDEV_CHANGENAME:
+		break;
+
+	default:
+		return NOTIFY_DONE;
+	}
+
+	if (ndev->netdev_ops != &lio_vf_rep_ndev_ops)
+		return NOTIFY_DONE;
+
+	vf_rep = netdev_priv(ndev);
+	oct = vf_rep->oct;
+
+	if (strlen(ndev->name) > LIO_IF_NAME_SIZE) {
+		dev_err(&oct->pci_dev->dev,
+			"Device name change sync failed as the size is > %d\n",
+			LIO_IF_NAME_SIZE);
+		return NOTIFY_DONE;
+	}
+
+	memset(&rep_cfg, 0, sizeof(rep_cfg));
+	rep_cfg.req_type = LIO_VF_REP_REQ_DEVNAME;
+	rep_cfg.ifidx = vf_rep->ifidx;
+	strncpy(rep_cfg.rep_name.name, ndev->name, LIO_IF_NAME_SIZE);
+
+	ret = lio_vf_rep_send_soft_command(oct, &rep_cfg,
+					   sizeof(rep_cfg), NULL, 0);
+	if (ret)
+		dev_err(&oct->pci_dev->dev,
+			"vf_rep netdev name change failed with err %d\n", ret);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block lio_vf_rep_netdev_notifier = {
+	.notifier_call = lio_vf_rep_netdev_event,
+};
+
+int
+lio_vf_rep_modinit(void)
+{
+	if (register_netdevice_notifier(&lio_vf_rep_netdev_notifier)) {
+		pr_err("netdev notifier registration failed\n");
+		return -EFAULT;
+	}
+
+	return 0;
+}
+
+void
+lio_vf_rep_modexit(void)
+{
+	if (unregister_netdevice_notifier(&lio_vf_rep_netdev_notifier))
+		pr_err("netdev notifier unregister failed\n");
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.h b/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.h
index 5a9ec98..bb3cedc 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.h
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.h
@@ -44,4 +44,6 @@ struct lio_vf_rep_sc_ctx {
 
 int lio_vf_rep_create(struct octeon_device *oct);
 void lio_vf_rep_destroy(struct octeon_device *oct);
+int lio_vf_rep_modinit(void);
+void lio_vf_rep_modexit(void);
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 441cc78..3bcdda8 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -928,7 +928,8 @@ enum lio_vf_rep_req_type {
 	LIO_VF_REP_REQ_NONE,
 	LIO_VF_REP_REQ_STATE,
 	LIO_VF_REP_REQ_MTU,
-	LIO_VF_REP_REQ_STATS
+	LIO_VF_REP_REQ_STATS,
+	LIO_VF_REP_REQ_DEVNAME
 };
 
 enum {
@@ -936,12 +937,17 @@ enum {
 	LIO_VF_REP_STATE_UP
 };
 
+#define LIO_IF_NAME_SIZE 16
 struct lio_vf_rep_req {
 	u8 req_type;
 	u8 ifidx;
 	u8 rsvd[6];
 
 	union {
+		struct lio_vf_rep_name {
+			char name[LIO_IF_NAME_SIZE];
+		} rep_name;
+
 		struct lio_vf_rep_mtu {
 			u32 mtu;
 			u32 rsvd;
-- 
1.8.3.1
