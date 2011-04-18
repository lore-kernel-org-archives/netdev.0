From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: vxge: convert to hw_features
Date: Tue, 19 Apr 2011 01:31:21 +0200 (CEST)
Message-ID: <20110418233121.5D8BB13A66@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Mason <jdmason@kudzu.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46020 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753503Ab1DRXbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 19:31:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Side effect: ->gro_enable is removed as napi_gro_receive() does the
fallback itself.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/vxge/vxge-ethtool.c |   72 ----------------------------
 drivers/net/vxge/vxge-main.c    |  100 +++++++++++++++++++++----------=
-------
 drivers/net/vxge/vxge-main.h    |   14 ++----
 3 files changed, 59 insertions(+), 127 deletions(-)

diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-et=
htool.c
index 43c4583..5aef6c8 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -1071,35 +1071,6 @@ static int vxge_ethtool_get_regs_len(struct net_=
device *dev)
 	return sizeof(struct vxge_hw_vpath_reg) * vdev->no_of_vpath;
 }
=20
-static u32 vxge_get_rx_csum(struct net_device *dev)
-{
-	struct vxgedev *vdev =3D netdev_priv(dev);
-
-	return vdev->rx_csum;
-}
-
-static int vxge_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct vxgedev *vdev =3D netdev_priv(dev);
-
-	if (data)
-		vdev->rx_csum =3D 1;
-	else
-		vdev->rx_csum =3D 0;
-
-	return 0;
-}
-
-static int vxge_ethtool_op_set_tso(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
-	else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-
-	return 0;
-}
-
 static int vxge_ethtool_get_sset_count(struct net_device *dev, int sse=
t)
 {
 	struct vxgedev *vdev =3D netdev_priv(dev);
@@ -1119,40 +1090,6 @@ static int vxge_ethtool_get_sset_count(struct ne=
t_device *dev, int sset)
 	}
 }
=20
-static int vxge_set_flags(struct net_device *dev, u32 data)
-{
-	struct vxgedev *vdev =3D netdev_priv(dev);
-	enum vxge_hw_status status;
-
-	if (ethtool_invalid_flags(dev, data, ETH_FLAG_RXHASH))
-		return -EINVAL;
-
-	if (!!(data & ETH_FLAG_RXHASH) =3D=3D vdev->devh->config.rth_en)
-		return 0;
-
-	if (netif_running(dev) || (vdev->config.rth_steering =3D=3D NO_STEERI=
NG))
-		return -EINVAL;
-
-	vdev->devh->config.rth_en =3D !!(data & ETH_FLAG_RXHASH);
-
-	/* Enabling RTH requires some of the logic in vxge_device_register an=
d a
-	 * vpath reset.  Due to these restrictions, only allow modification
-	 * while the interface is down.
-	 */
-	status =3D vxge_reset_all_vpaths(vdev);
-	if (status !=3D VXGE_HW_OK) {
-		vdev->devh->config.rth_en =3D !vdev->devh->config.rth_en;
-		return -EFAULT;
-	}
-
-	if (vdev->devh->config.rth_en)
-		dev->features |=3D NETIF_F_RXHASH;
-	else
-		dev->features &=3D ~NETIF_F_RXHASH;
-
-	return 0;
-}
-
 static int vxge_fw_flash(struct net_device *dev, struct ethtool_flash =
*parms)
 {
 	struct vxgedev *vdev =3D netdev_priv(dev);
@@ -1181,19 +1118,10 @@ static const struct ethtool_ops vxge_ethtool_op=
s =3D {
 	.get_link		=3D ethtool_op_get_link,
 	.get_pauseparam		=3D vxge_ethtool_getpause_data,
 	.set_pauseparam		=3D vxge_ethtool_setpause_data,
-	.get_rx_csum		=3D vxge_get_rx_csum,
-	.set_rx_csum		=3D vxge_set_rx_csum,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_ipv6_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
-	.get_tso		=3D ethtool_op_get_tso,
-	.set_tso		=3D vxge_ethtool_op_set_tso,
 	.get_strings		=3D vxge_ethtool_get_strings,
 	.set_phys_id		=3D vxge_ethtool_idnic,
 	.get_sset_count		=3D vxge_ethtool_get_sset_count,
 	.get_ethtool_stats	=3D vxge_get_ethtool_stats,
-	.set_flags		=3D vxge_set_flags,
 	.flash_device		=3D vxge_fw_flash,
 };
=20
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.=
c
index d192dad..fc837cf 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -304,22 +304,14 @@ vxge_rx_complete(struct vxge_ring *ring, struct s=
k_buff *skb, u16 vlan,
 		"%s: %s:%d  skb protocol =3D %d",
 		ring->ndev->name, __func__, __LINE__, skb->protocol);
=20
-	if (ring->gro_enable) {
-		if (ring->vlgrp && ext_info->vlan &&
-			(ring->vlan_tag_strip =3D=3D
-				VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE))
-			vlan_gro_receive(ring->napi_p, ring->vlgrp,
-					ext_info->vlan, skb);
-		else
-			napi_gro_receive(ring->napi_p, skb);
-	} else {
-		if (ring->vlgrp && vlan &&
-			(ring->vlan_tag_strip =3D=3D
-				VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE))
-			vlan_hwaccel_receive_skb(skb, ring->vlgrp, vlan);
-		else
-			netif_receive_skb(skb);
-	}
+	if (ring->vlgrp && ext_info->vlan &&
+		(ring->vlan_tag_strip =3D=3D
+			VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE))
+		vlan_gro_receive(ring->napi_p, ring->vlgrp,
+				ext_info->vlan, skb);
+	else
+		napi_gro_receive(ring->napi_p, skb);
+
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s: %s:%d Exiting...", ring->ndev->name, __func__, __LINE__);
 }
@@ -490,7 +482,7 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void=
 *dtr,
=20
 		if ((ext_info.proto & VXGE_HW_FRAME_PROTO_TCP_OR_UDP) &&
 		    !(ext_info.proto & VXGE_HW_FRAME_PROTO_IP_FRAG) &&
-		    ring->rx_csum && /* Offload Rx side CSUM */
+		    (dev->features & NETIF_F_RXCSUM) && /* Offload Rx side CSUM */
 		    ext_info.l3_cksum =3D=3D VXGE_HW_L3_CKSUM_OK &&
 		    ext_info.l4_cksum =3D=3D VXGE_HW_L4_CKSUM_OK)
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
@@ -2094,11 +2086,9 @@ static int vxge_open_vpaths(struct vxgedev *vdev=
)
 				vdev->config.fifo_indicate_max_pkts;
 			vpath->fifo.tx_vector_no =3D 0;
 			vpath->ring.rx_vector_no =3D 0;
-			vpath->ring.rx_csum =3D vdev->rx_csum;
 			vpath->ring.rx_hwts =3D vdev->rx_hwts;
 			vpath->is_open =3D 1;
 			vdev->vp_handles[i] =3D vpath->handle;
-			vpath->ring.gro_enable =3D vdev->config.gro_enable;
 			vpath->ring.vlan_tag_strip =3D vdev->vlan_tag_strip;
 			vdev->stats.vpaths_open++;
 		} else {
@@ -2670,6 +2660,40 @@ static void vxge_poll_vp_lockup(unsigned long da=
ta)
 	mod_timer(&vdev->vp_lockup_timer, jiffies + HZ / 1000);
 }
=20
+static u32 vxge_fix_features(struct net_device *dev, u32 features)
+{
+	u32 changed =3D dev->features ^ features;
+
+	/* Enabling RTH requires some of the logic in vxge_device_register an=
d a
+	 * vpath reset.  Due to these restrictions, only allow modification
+	 * while the interface is down.
+	 */
+	if ((changed & NETIF_F_RXHASH) && netif_running(dev))
+		features ^=3D NETIF_F_RXHASH;
+
+	return features;
+}
+
+static int vxge_set_features(struct net_device *dev, u32 features)
+{
+	struct vxgedev *vdev =3D netdev_priv(dev);
+	u32 changed =3D dev->features ^ features;
+
+	if (!(changed & NETIF_F_RXHASH))
+		return 0;
+
+	/* !netif_running() ensured by vxge_fix_features() */
+
+	vdev->devh->config.rth_en =3D !!(features & NETIF_F_RXHASH);
+	if (vxge_reset_all_vpaths(vdev) !=3D VXGE_HW_OK) {
+		dev->features =3D features ^ NETIF_F_RXHASH;
+		vdev->devh->config.rth_en =3D !!(dev->features & NETIF_F_RXHASH);
+		return -EIO;
+	}
+
+	return 0;
+}
+
 /**
  * vxge_open
  * @dev: pointer to the device structure.
@@ -3369,6 +3393,8 @@ static const struct net_device_ops vxge_netdev_op=
s =3D {
 	.ndo_do_ioctl           =3D vxge_ioctl,
 	.ndo_set_mac_address    =3D vxge_set_mac_addr,
 	.ndo_change_mtu         =3D vxge_change_mtu,
+	.ndo_fix_features	=3D vxge_fix_features,
+	.ndo_set_features	=3D vxge_set_features,
 	.ndo_vlan_rx_register   =3D vxge_vlan_rx_register,
 	.ndo_vlan_rx_kill_vid   =3D vxge_vlan_rx_kill_vid,
 	.ndo_vlan_rx_add_vid	=3D vxge_vlan_rx_add_vid,
@@ -3415,14 +3441,21 @@ static int __devinit vxge_device_register(struc=
t __vxge_hw_device *hldev,
 	vdev->devh =3D hldev;
 	vdev->pdev =3D hldev->pdev;
 	memcpy(&vdev->config, config, sizeof(struct vxge_config));
-	vdev->rx_csum =3D 1;	/* Enable Rx CSUM by default. */
 	vdev->rx_hwts =3D 0;
 	vdev->titan1 =3D (vdev->pdev->revision =3D=3D VXGE_HW_TITAN1_PCI_REVI=
SION);
=20
 	SET_NETDEV_DEV(ndev, &vdev->pdev->dev);
=20
-	ndev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
-				NETIF_F_HW_VLAN_FILTER;
+	ndev->hw_features =3D NETIF_F_RXCSUM | NETIF_F_SG |
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+		NETIF_F_TSO | NETIF_F_TSO6 |
+		NETIF_F_HW_VLAN_TX;
+	if (vdev->config.rth_steering !=3D NO_STEERING)
+		ndev->hw_features |=3D NETIF_F_RXHASH;
+
+	ndev->features |=3D ndev->hw_features |
+		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+
 	/*  Driver entry points */
 	ndev->irq =3D vdev->pdev->irq;
 	ndev->base_addr =3D (unsigned long) hldev->bar0;
@@ -3434,11 +3467,6 @@ static int __devinit vxge_device_register(struct=
 __vxge_hw_device *hldev,
=20
 	vxge_initialize_ethtool_ops(ndev);
=20
-	if (vdev->config.rth_steering !=3D NO_STEERING) {
-		ndev->features |=3D NETIF_F_RXHASH;
-		hldev->config.rth_en =3D VXGE_HW_RTH_ENABLE;
-	}
-
 	/* Allocate memory for vpath */
 	vdev->vpaths =3D kzalloc((sizeof(struct vxge_vpath)) *
 				no_of_vpath, GFP_KERNEL);
@@ -3450,9 +3478,6 @@ static int __devinit vxge_device_register(struct =
__vxge_hw_device *hldev,
 		goto _out1;
 	}
=20
-	ndev->features |=3D NETIF_F_SG;
-
-	ndev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
 		"%s : checksuming enabled", __func__);
=20
@@ -3462,11 +3487,6 @@ static int __devinit vxge_device_register(struct=
 __vxge_hw_device *hldev,
 			"%s : using High DMA", __func__);
 	}
=20
-	ndev->features |=3D NETIF_F_TSO | NETIF_F_TSO6;
-
-	if (vdev->config.gro_enable)
-		ndev->features |=3D NETIF_F_GRO;
-
 	ret =3D register_netdev(ndev);
 	if (ret) {
 		vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
@@ -3996,15 +4016,6 @@ static void __devinit vxge_print_parm(struct vxg=
edev *vdev, u64 vpath_mask)
 		vdev->config.tx_steering_type =3D 0;
 	}
=20
-	if (vdev->config.gro_enable) {
-		vxge_debug_init(VXGE_ERR,
-			"%s: Generic receive offload enabled",
-			vdev->ndev->name);
-	} else
-		vxge_debug_init(VXGE_TRACE,
-			"%s: Generic receive offload disabled",
-			vdev->ndev->name);
-
 	if (vdev->config.addr_learn_en)
 		vxge_debug_init(VXGE_TRACE,
 			"%s: MAC Address learning enabled", vdev->ndev->name);
@@ -4589,7 +4600,6 @@ vxge_probe(struct pci_dev *pdev, const struct pci=
_device_id *pre)
 	/* set private device info */
 	pci_set_drvdata(pdev, hldev);
=20
-	ll_config->gro_enable =3D VXGE_GRO_ALWAYS_AGGREGATE;
 	ll_config->fifo_indicate_max_pkts =3D VXGE_FIFO_INDICATE_MAX_PKTS;
 	ll_config->addr_learn_en =3D addr_learn_en;
 	ll_config->rth_algorithm =3D RTH_ALG_JENKINS;
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.=
h
index 40474f0..ed120ab 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -168,9 +168,6 @@ struct vxge_config {
=20
 #define	NEW_NAPI_WEIGHT	64
 	int		napi_weight;
-#define VXGE_GRO_DONOT_AGGREGATE		0
-#define VXGE_GRO_ALWAYS_AGGREGATE		1
-	int		gro_enable;
 	int		intr_type;
 #define INTA	0
 #define MSI	1
@@ -290,13 +287,11 @@ struct vxge_ring {
 	unsigned long interrupt_count;
 	unsigned long jiffies;
=20
-	/* copy of the flag indicating whether rx_csum is to be used */
-	u32 rx_csum:1,
-	    rx_hwts:1;
+	/* copy of the flag indicating whether rx_hwts is to be used */
+	u32 rx_hwts:1;
=20
 	int pkts_processed;
 	int budget;
-	int gro_enable;
=20
 	struct napi_struct napi;
 	struct napi_struct *napi_p;
@@ -369,9 +364,8 @@ struct vxgedev {
 	 */
 	u16		all_multi_flg;
=20
-	 /* A flag indicating whether rx_csum is to be used or not. */
-	u32	rx_csum:1,
-		rx_hwts:1,
+	/* A flag indicating whether rx_hwts is to be used or not. */
+	u32	rx_hwts:1,
 		titan1:1;
=20
 	struct vxge_msix_entry *vxge_entries;
--=20
1.7.2.5

