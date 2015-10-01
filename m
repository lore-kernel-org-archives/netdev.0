From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 2/2] enic: do hang reset only in case of tx timeout
Date: Thu,  1 Oct 2015 14:18:47 +0530
Message-ID: <1443689327-15776-2-git-send-email-_govind@gmx.com>
References: <1443689327-15776-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:52381 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954AbbJAItS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 04:49:18 -0400
In-Reply-To: <1443689327-15776-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code invokes hang reset in case of error interrupt. We should
hang reset only in case of tx timeout. This because of the way hang reset
is implemented in firmware. Hang reset takes more firmware resources than
soft reset. Adaptor does not generate error interrupt in case of tx
timeout.

Hang reset only in case of tx timeout, in .ndo_tx_timeout. Do soft reset
otherwise. Introduce deferred work, enic_tx_hang_reset, to do hang reset.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |  1 +
 drivers/net/ethernet/cisco/enic/enic_main.c | 36 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/cisco/enic/vnic_dev.c  |  4 ++--
 drivers/net/ethernet/cisco/enic/vnic_dev.h  |  2 ++
 4 files changed, 40 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 8b53f7d..6401ba99 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -143,6 +143,7 @@ struct enic {
 	struct vnic_dev *vdev;
 	struct timer_list notify_timer;
 	struct work_struct reset;
+	struct work_struct tx_hang_reset;
 	struct work_struct change_mtu_work;
 	struct msix_entry msix_entry[ENIC_INTR_MAX];
 	struct enic_msix_entry msix[ENIC_INTR_MAX];
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 0b54429..0c22fd0 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -808,7 +808,7 @@ static void enic_set_rx_mode(struct net_device *netdev)
 static void enic_tx_timeout(struct net_device *netdev)
 {
 	struct enic *enic = netdev_priv(netdev);
-	schedule_work(&enic->reset);
+	schedule_work(&enic->tx_hang_reset);
 }
 
 static int enic_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
@@ -1928,6 +1928,19 @@ static int enic_dev_open(struct enic *enic)
 	return err;
 }
 
+static int enic_dev_soft_reset(struct enic *enic)
+{
+	int err;
+
+	err = enic_dev_wait(enic->vdev, vnic_dev_soft_reset,
+			    vnic_dev_soft_reset_done, 0);
+	if (err)
+		netdev_err(enic->netdev, "vNIC soft reset failed, err %d\n",
+			   err);
+
+	return err;
+}
+
 static int enic_dev_hang_reset(struct enic *enic)
 {
 	int err;
@@ -2064,6 +2077,26 @@ static void enic_reset(struct work_struct *work)
 	rtnl_lock();
 
 	spin_lock(&enic->enic_api_lock);
+	enic_stop(enic->netdev);
+	enic_dev_soft_reset(enic);
+	enic_reset_addr_lists(enic);
+	enic_init_vnic_resources(enic);
+	enic_set_rss_nic_cfg(enic);
+	enic_dev_set_ig_vlan_rewrite_mode(enic);
+	enic_open(enic->netdev);
+	spin_unlock(&enic->enic_api_lock);
+	call_netdevice_notifiers(NETDEV_REBOOT, enic->netdev);
+
+	rtnl_unlock();
+}
+
+static void enic_tx_hang_reset(struct work_struct *work)
+{
+	struct enic *enic = container_of(work, struct enic, tx_hang_reset);
+
+	rtnl_lock();
+
+	spin_lock(&enic->enic_api_lock);
 	enic_dev_hang_notify(enic);
 	enic_stop(enic->netdev);
 	enic_dev_hang_reset(enic);
@@ -2587,6 +2620,7 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	enic_set_rx_coal_setting(enic);
 	INIT_WORK(&enic->reset, enic_reset);
+	INIT_WORK(&enic->tx_hang_reset, enic_tx_hang_reset);
 	INIT_WORK(&enic->change_mtu_work, enic_change_mtu_work);
 
 	for (i = 0; i < enic->wq_count; i++)
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index a3badef..1ffd105 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -659,14 +659,14 @@ int vnic_dev_open_done(struct vnic_dev *vdev, int *done)
 	return 0;
 }
 
-static int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg)
+int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg)
 {
 	u64 a0 = (u32)arg, a1 = 0;
 	int wait = 1000;
 	return vnic_dev_cmd(vdev, CMD_SOFT_RESET, &a0, &a1, wait);
 }
 
-static int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done)
+int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done)
 {
 	u64 a0 = 0, a1 = 0;
 	int wait = 1000;
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.h b/drivers/net/ethernet/cisco/enic/vnic_dev.h
index b013b6a..54156c4 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.h
@@ -155,7 +155,9 @@ int vnic_dev_deinit(struct vnic_dev *vdev);
 void vnic_dev_intr_coal_timer_info_default(struct vnic_dev *vdev);
 int vnic_dev_intr_coal_timer_info(struct vnic_dev *vdev);
 int vnic_dev_hang_reset(struct vnic_dev *vdev, int arg);
+int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg);
 int vnic_dev_hang_reset_done(struct vnic_dev *vdev, int *done);
+int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done);
 void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
 	enum vnic_dev_intr_mode intr_mode);
 enum vnic_dev_intr_mode vnic_dev_get_intr_mode(struct vnic_dev *vdev);
-- 
2.6.0
