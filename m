From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 5/6] enic: feature add: add ethtool -c/C support
Date: Mon, 21 Dec 2009 18:21:47 -0800
Message-ID: <20091222022147.30220.42433.stgit@savbu-pc100.cisco.com>
References: <20091222021857.30220.51795.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:22679 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742AbZLVCVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 21:21:47 -0500
In-Reply-To: <20091222021857.30220.51795.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Only rx_usec and tx_usec options for ethtool -C are settable as those
are the only settings that make sense to HW.  Adds driver reporting of 
intr coalescing timer value in usec units rather than HW units.

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +
 drivers/net/enic/enic_main.c |   65 +++++++++++++++++++++++++++++++++++++++++-
 drivers/net/enic/enic_res.c  |   12 +++++---
 drivers/net/enic/vnic_enet.h |    5 +++
 drivers/net/enic/vnic_intr.c |    8 +++++
 drivers/net/enic/vnic_intr.h |    2 +
 6 files changed, 86 insertions(+), 8 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index b090d65..ee01f5a 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -93,6 +93,8 @@ struct enic {
 	unsigned int mc_count;
 	int csum_rx_enabled;
 	u32 port_mtu;
+	u32 rx_coalesce_usecs;
+	u32 tx_coalesce_usecs;
 
 	/* work queue cache line section */
 	____cacheline_aligned struct vnic_wq wq[ENIC_WQ_MAX];
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 019b148..81cc68d 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -261,7 +261,63 @@ static void enic_set_msglevel(struct net_device *netdev, u32 value)
 	enic->msg_enable = value;
 }
 
-static const struct ethtool_ops enic_ethtool_ops = {
+static int enic_get_coalesce(struct net_device *netdev,
+	struct ethtool_coalesce *ecmd)
+{
+	struct enic *enic = netdev_priv(netdev);
+
+	ecmd->tx_coalesce_usecs = enic->tx_coalesce_usecs;
+	ecmd->rx_coalesce_usecs = enic->rx_coalesce_usecs;
+
+	return 0;
+}
+
+static int enic_set_coalesce(struct net_device *netdev,
+	struct ethtool_coalesce *ecmd)
+{
+	struct enic *enic = netdev_priv(netdev);
+	u32 tx_coalesce_usecs;
+	u32 rx_coalesce_usecs;
+
+	tx_coalesce_usecs = min_t(u32,
+		INTR_COALESCE_HW_TO_USEC(VNIC_INTR_TIMER_MAX),
+		ecmd->tx_coalesce_usecs);
+	rx_coalesce_usecs = min_t(u32,
+		INTR_COALESCE_HW_TO_USEC(VNIC_INTR_TIMER_MAX),
+		ecmd->rx_coalesce_usecs);
+
+	switch (vnic_dev_get_intr_mode(enic->vdev)) {
+	case VNIC_DEV_INTR_MODE_INTX:
+		if (tx_coalesce_usecs != rx_coalesce_usecs)
+			return -EINVAL;
+
+		vnic_intr_coalescing_timer_set(&enic->intr[ENIC_INTX_WQ_RQ],
+			INTR_COALESCE_USEC_TO_HW(tx_coalesce_usecs));
+		break;
+	case VNIC_DEV_INTR_MODE_MSI:
+		if (tx_coalesce_usecs != rx_coalesce_usecs)
+			return -EINVAL;
+
+		vnic_intr_coalescing_timer_set(&enic->intr[0],
+			INTR_COALESCE_USEC_TO_HW(tx_coalesce_usecs));
+		break;
+	case VNIC_DEV_INTR_MODE_MSIX:
+		vnic_intr_coalescing_timer_set(&enic->intr[ENIC_MSIX_WQ],
+			INTR_COALESCE_USEC_TO_HW(tx_coalesce_usecs));
+		vnic_intr_coalescing_timer_set(&enic->intr[ENIC_MSIX_RQ],
+			INTR_COALESCE_USEC_TO_HW(rx_coalesce_usecs));
+		break;
+	default:
+		break;
+	}
+
+	enic->tx_coalesce_usecs = tx_coalesce_usecs;
+	enic->rx_coalesce_usecs = rx_coalesce_usecs;
+
+	return 0;
+}
+
+static struct ethtool_ops enic_ethtool_ops = {
 	.get_settings = enic_get_settings,
 	.get_drvinfo = enic_get_drvinfo,
 	.get_msglevel = enic_get_msglevel,
@@ -278,6 +334,8 @@ static const struct ethtool_ops enic_ethtool_ops = {
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = enic_set_tso,
+	.get_coalesce = enic_get_coalesce,
+	.set_coalesce = enic_set_coalesce,
 	.get_flags = ethtool_op_get_flags,
 	.set_flags = ethtool_op_set_flags,
 };
@@ -363,12 +421,12 @@ static void enic_mtu_check(struct enic *enic)
 	u32 mtu = vnic_dev_mtu(enic->vdev);
 
 	if (mtu && mtu != enic->port_mtu) {
+		enic->port_mtu = mtu;
 		if (mtu < enic->netdev->mtu)
 			printk(KERN_WARNING PFX
 				"%s: interface MTU (%d) set higher "
 				"than switch port MTU (%d)\n",
 				enic->netdev->name, enic->netdev->mtu, mtu);
-		enic->port_mtu = mtu;
 	}
 }
 
@@ -1990,6 +2048,9 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		goto err_out_dev_deinit;
 	}
 
+	enic->tx_coalesce_usecs = enic->config.intr_timer_usec;
+	enic->rx_coalesce_usecs = enic->tx_coalesce_usecs;
+
 	netdev->netdev_ops = &enic_netdev_ops;
 	netdev->watchdog_timeo = 2 * HZ;
 	netdev->ethtool_ops = &enic_ethtool_ops;
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index a605da1..02839bf 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -66,9 +66,9 @@ int enic_get_vnic_config(struct enic *enic)
 	GET_CONFIG(wq_desc_count);
 	GET_CONFIG(rq_desc_count);
 	GET_CONFIG(mtu);
-	GET_CONFIG(intr_timer);
 	GET_CONFIG(intr_timer_type);
 	GET_CONFIG(intr_mode);
+	GET_CONFIG(intr_timer_usec);
 
 	c->wq_desc_count =
 		min_t(u32, ENIC_MAX_WQ_DESCS,
@@ -88,15 +88,17 @@ int enic_get_vnic_config(struct enic *enic)
 		max_t(u16, ENIC_MIN_MTU,
 		c->mtu));
 
-	c->intr_timer = min_t(u16, VNIC_INTR_TIMER_MAX, c->intr_timer);
+	c->intr_timer_usec = min_t(u32,
+		INTR_COALESCE_HW_TO_USEC(VNIC_INTR_TIMER_MAX),
+		c->intr_timer_usec);
 
 	printk(KERN_INFO PFX "vNIC MAC addr %pM wq/rq %d/%d\n",
 		enic->mac_addr, c->wq_desc_count, c->rq_desc_count);
 	printk(KERN_INFO PFX "vNIC mtu %d csum tx/rx %d/%d tso/lro %d/%d "
-		"intr timer %d\n",
+		"intr timer %d usec\n",
 		c->mtu, ENIC_SETTING(enic, TXCSUM),
 		ENIC_SETTING(enic, RXCSUM), ENIC_SETTING(enic, TSO),
-		ENIC_SETTING(enic, LRO), c->intr_timer);
+		ENIC_SETTING(enic, LRO), c->intr_timer_usec);
 
 	return 0;
 }
@@ -303,7 +305,7 @@ void enic_init_vnic_resources(struct enic *enic)
 
 	for (i = 0; i < enic->intr_count; i++) {
 		vnic_intr_init(&enic->intr[i],
-			enic->config.intr_timer,
+			INTR_COALESCE_USEC_TO_HW(enic->config.intr_timer_usec),
 			enic->config.intr_timer_type,
 			mask_on_assertion);
 	}
diff --git a/drivers/net/enic/vnic_enet.h b/drivers/net/enic/vnic_enet.h
index 6332ac9..8eeb675 100644
--- a/drivers/net/enic/vnic_enet.h
+++ b/drivers/net/enic/vnic_enet.h
@@ -20,6 +20,10 @@
 #ifndef _VNIC_ENIC_H_
 #define _VNIC_ENIC_H_
 
+/* Hardware intr coalesce timer is in units of 1.5us */
+#define INTR_COALESCE_USEC_TO_HW(usec) ((usec) * 2/3)
+#define INTR_COALESCE_HW_TO_USEC(usec) ((usec) * 3/2)
+
 /* Device-specific region: enet configuration */
 struct vnic_enet_config {
 	u32 flags;
@@ -30,6 +34,7 @@ struct vnic_enet_config {
 	u8 intr_timer_type;
 	u8 intr_mode;
 	char devname[16];
+	u32 intr_timer_usec;
 };
 
 #define VENETF_TSO		0x1	/* TSO enabled */
diff --git a/drivers/net/enic/vnic_intr.c b/drivers/net/enic/vnic_intr.c
index 1f8786d..3934309 100644
--- a/drivers/net/enic/vnic_intr.c
+++ b/drivers/net/enic/vnic_intr.c
@@ -50,12 +50,18 @@ int vnic_intr_alloc(struct vnic_dev *vdev, struct vnic_intr *intr,
 void vnic_intr_init(struct vnic_intr *intr, unsigned int coalescing_timer,
 	unsigned int coalescing_type, unsigned int mask_on_assertion)
 {
-	iowrite32(coalescing_timer, &intr->ctrl->coalescing_timer);
+	vnic_intr_coalescing_timer_set(intr, coalescing_timer);
 	iowrite32(coalescing_type, &intr->ctrl->coalescing_type);
 	iowrite32(mask_on_assertion, &intr->ctrl->mask_on_assertion);
 	iowrite32(0, &intr->ctrl->int_credits);
 }
 
+void vnic_intr_coalescing_timer_set(struct vnic_intr *intr,
+	unsigned int coalescing_timer)
+{
+	iowrite32(coalescing_timer, &intr->ctrl->coalescing_timer);
+}
+
 void vnic_intr_clean(struct vnic_intr *intr)
 {
 	iowrite32(0, &intr->ctrl->int_credits);
diff --git a/drivers/net/enic/vnic_intr.h b/drivers/net/enic/vnic_intr.h
index f79a722..2fe6c63 100644
--- a/drivers/net/enic/vnic_intr.h
+++ b/drivers/net/enic/vnic_intr.h
@@ -102,6 +102,8 @@ int vnic_intr_alloc(struct vnic_dev *vdev, struct vnic_intr *intr,
 	unsigned int index);
 void vnic_intr_init(struct vnic_intr *intr, unsigned int coalescing_timer,
 	unsigned int coalescing_type, unsigned int mask_on_assertion);
+void vnic_intr_coalescing_timer_set(struct vnic_intr *intr,
+	unsigned int coalescing_timer);
 void vnic_intr_clean(struct vnic_intr *intr);
 
 #endif /* _VNIC_INTR_H_ */

