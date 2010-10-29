From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 01/11] vxge: enable rxhash
Date: Thu, 28 Oct 2010 21:19:36 -0500
Message-ID: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:37304 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756106Ab0J2CTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 22:19:51 -0400
Received: by gyg4 with SMTP id 4so1700548gyg.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 19:19:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable RSS hashing and add ability to pass up the adapter calculated rx
hash up the network stack (if feature is available).  Add the ability to
enable/disable feature via ethtool, which requires that the adapter is
not running at the time.  Other miscellaneous cleanups and fixes
required to get RSS working.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-config.c  |    2 +
 drivers/net/vxge/vxge-config.h  |   12 ++++----
 drivers/net/vxge/vxge-ethtool.c |   35 +++++++++++++++++++++++++
 drivers/net/vxge/vxge-main.c    |   54 ++++++++++++++++++++++++--------------
 drivers/net/vxge/vxge-main.h    |   18 ++++++------
 drivers/net/vxge/vxge-traffic.h |   28 --------------------
 6 files changed, 86 insertions(+), 63 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 0e6db59..25f0938 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -3067,6 +3067,8 @@ enum vxge_hw_status vxge_hw_vpath_rts_rth_set(
 		     VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_READ_ENTRY,
 		     VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_GEN_CFG,
 			0, &data0, &data1);
+	if (status != VXGE_HW_OK)
+		goto exit;
 
 	data0 &= ~(VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_BUCKET_SIZE(0xf) |
 			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_ALG_SEL(0x3));
diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index 1a94343..66c6773 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -1418,12 +1418,12 @@ enum vxge_hw_rth_algoritms {
  * See also: vxge_hw_vpath_rts_rth_set(), vxge_hw_vpath_rts_rth_get().
  */
 struct vxge_hw_rth_hash_types {
-	u8 hash_type_tcpipv4_en;
-	u8 hash_type_ipv4_en;
-	u8 hash_type_tcpipv6_en;
-	u8 hash_type_ipv6_en;
-	u8 hash_type_tcpipv6ex_en;
-	u8 hash_type_ipv6ex_en;
+	u8 hash_type_tcpipv4_en:1,
+	   hash_type_ipv4_en:1,
+	   hash_type_tcpipv6_en:1,
+	   hash_type_ipv6_en:1,
+	   hash_type_tcpipv6ex_en:1,
+	   hash_type_ipv6ex_en:1;
 };
 
 u32
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-ethtool.c
index 05679e3..6194fd9 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -1119,6 +1119,40 @@ static int vxge_ethtool_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
+static int vxge_set_flags(struct net_device *dev, u32 data)
+{
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+	enum vxge_hw_status status;
+
+	if (data & ~ETH_FLAG_RXHASH)
+		return -EOPNOTSUPP;
+
+	if (!!(data & ETH_FLAG_RXHASH) == vdev->devh->config.rth_en)
+		return 0;
+
+	if (netif_running(dev) || (vdev->config.rth_steering == NO_STEERING))
+		return -EINVAL;
+
+	vdev->devh->config.rth_en = !!(data & ETH_FLAG_RXHASH);
+
+	/* Enabling RTH requires some of the logic in vxge_device_register and a
+	 * vpath reset.  Due to these restrictions, only allow modification
+	 * while the interface is down.
+	 */
+	status = vxge_reset_all_vpaths(vdev);
+	if (status != VXGE_HW_OK) {
+		vdev->devh->config.rth_en = !vdev->devh->config.rth_en;
+		return -EFAULT;
+	}
+
+	if (vdev->devh->config.rth_en)
+		dev->features |= NETIF_F_RXHASH;
+	else
+		dev->features &= ~NETIF_F_RXHASH;
+
+	return 0;
+}
+
 static const struct ethtool_ops vxge_ethtool_ops = {
 	.get_settings		= vxge_ethtool_gset,
 	.set_settings		= vxge_ethtool_sset,
@@ -1140,6 +1174,7 @@ static const struct ethtool_ops vxge_ethtool_ops = {
 	.phys_id		= vxge_ethtool_idnic,
 	.get_sset_count		= vxge_ethtool_get_sset_count,
 	.get_ethtool_stats	= vxge_get_ethtool_stats,
+	.set_flags		= vxge_set_flags,
 };
 
 void initialize_ethtool_ops(struct net_device *ndev)
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index a69542e..8a59fe9 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -503,6 +503,13 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 		else
 			skb_checksum_none_assert(skb);
 
+		/* rth_hash_type and rth_it_hit are non-zero regardless of
+		 * whether rss is enabled.  Only the rth_value is zero/non-zero
+		 * if rss is disabled/enabled, so key off of that.
+		 */
+		if (ext_info.rth_value)
+			skb->rxhash = ext_info.rth_value;
+
 		vxge_rx_complete(ring, skb, ext_info.vlan,
 			pkt_length, &ext_info);
 
@@ -1679,15 +1686,6 @@ static enum vxge_hw_status vxge_rth_configure(struct vxgedev *vdev)
 		mtable[index] = index % vdev->no_of_vpath;
 	}
 
-	/* Fill RTH hash types */
-	hash_types.hash_type_tcpipv4_en   = vdev->config.rth_hash_type_tcpipv4;
-	hash_types.hash_type_ipv4_en      = vdev->config.rth_hash_type_ipv4;
-	hash_types.hash_type_tcpipv6_en   = vdev->config.rth_hash_type_tcpipv6;
-	hash_types.hash_type_ipv6_en      = vdev->config.rth_hash_type_ipv6;
-	hash_types.hash_type_tcpipv6ex_en =
-					vdev->config.rth_hash_type_tcpipv6ex;
-	hash_types.hash_type_ipv6ex_en    = vdev->config.rth_hash_type_ipv6ex;
-
 	/* set indirection table, bucket-to-vpath mapping */
 	status = vxge_hw_vpath_rts_rth_itable_set(vdev->vp_handles,
 						vdev->no_of_vpath,
@@ -1700,12 +1698,21 @@ static enum vxge_hw_status vxge_rth_configure(struct vxgedev *vdev)
 		return status;
 	}
 
+	/* Fill RTH hash types */
+	hash_types.hash_type_tcpipv4_en   = vdev->config.rth_hash_type_tcpipv4;
+	hash_types.hash_type_ipv4_en      = vdev->config.rth_hash_type_ipv4;
+	hash_types.hash_type_tcpipv6_en   = vdev->config.rth_hash_type_tcpipv6;
+	hash_types.hash_type_ipv6_en      = vdev->config.rth_hash_type_ipv6;
+	hash_types.hash_type_tcpipv6ex_en =
+					vdev->config.rth_hash_type_tcpipv6ex;
+	hash_types.hash_type_ipv6ex_en    = vdev->config.rth_hash_type_ipv6ex;
+
 	/*
-	* Because the itable_set() method uses the active_table field
-	* for the target virtual path the RTH config should be updated
-	* for all VPATHs. The h/w only uses the lowest numbered VPATH
-	* when steering frames.
-	*/
+	 * Because the itable_set() method uses the active_table field
+	 * for the target virtual path the RTH config should be updated
+	 * for all VPATHs. The h/w only uses the lowest numbered VPATH
+	 * when steering frames.
+	 */
 	 for (index = 0; index < vdev->no_of_vpath; index++) {
 		status = vxge_hw_vpath_rts_rth_set(
 				vdev->vpaths[index].handle,
@@ -2586,6 +2593,8 @@ vxge_open(struct net_device *dev)
 			goto out2;
 		}
 	}
+	printk(KERN_INFO "%s: Receive Hashing Offload %s\n", dev->name,
+	       hldev->config.rth_en ? "enabled" : "disabled");
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
 		vpath = &vdev->vpaths[i];
@@ -3166,6 +3175,11 @@ int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 
 	initialize_ethtool_ops(ndev);
 
+	if (vdev->config.rth_steering != NO_STEERING) {
+		ndev->features |= NETIF_F_RXHASH;
+		hldev->config.rth_en = VXGE_HW_RTH_ENABLE;
+	}
+
 	/* Allocate memory for vpath */
 	vdev->vpaths = kzalloc((sizeof(struct vxge_vpath)) *
 				no_of_vpath, GFP_KERNEL);
@@ -4151,12 +4165,12 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 	ll_config->fifo_indicate_max_pkts = VXGE_FIFO_INDICATE_MAX_PKTS;
 	ll_config->addr_learn_en = addr_learn_en;
 	ll_config->rth_algorithm = RTH_ALG_JENKINS;
-	ll_config->rth_hash_type_tcpipv4 = VXGE_HW_RING_HASH_TYPE_TCP_IPV4;
-	ll_config->rth_hash_type_ipv4 = VXGE_HW_RING_HASH_TYPE_NONE;
-	ll_config->rth_hash_type_tcpipv6 = VXGE_HW_RING_HASH_TYPE_NONE;
-	ll_config->rth_hash_type_ipv6 = VXGE_HW_RING_HASH_TYPE_NONE;
-	ll_config->rth_hash_type_tcpipv6ex = VXGE_HW_RING_HASH_TYPE_NONE;
-	ll_config->rth_hash_type_ipv6ex = VXGE_HW_RING_HASH_TYPE_NONE;
+	ll_config->rth_hash_type_tcpipv4 = 1;
+	ll_config->rth_hash_type_ipv4 = 0;
+	ll_config->rth_hash_type_tcpipv6 = 0;
+	ll_config->rth_hash_type_ipv6 = 0;
+	ll_config->rth_hash_type_tcpipv6ex = 0;
+	ll_config->rth_hash_type_ipv6ex = 0;
 	ll_config->rth_bkt_sz = RTH_BUCKET_SIZE;
 	ll_config->tx_pause_enable = VXGE_PAUSE_CTRL_ENABLE;
 	ll_config->rx_pause_enable = VXGE_PAUSE_CTRL_ENABLE;
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index d4be07e..8641822 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -145,15 +145,15 @@ struct vxge_config {
 
 	int		addr_learn_en;
 
-	int		rth_steering;
-	int		rth_algorithm;
-	int		rth_hash_type_tcpipv4;
-	int		rth_hash_type_ipv4;
-	int		rth_hash_type_tcpipv6;
-	int		rth_hash_type_ipv6;
-	int		rth_hash_type_tcpipv6ex;
-	int		rth_hash_type_ipv6ex;
-	int		rth_bkt_sz;
+	u32		rth_steering:2,
+			rth_algorithm:2,
+			rth_hash_type_tcpipv4:1,
+			rth_hash_type_ipv4:1,
+			rth_hash_type_tcpipv6:1,
+			rth_hash_type_ipv6:1,
+			rth_hash_type_tcpipv6ex:1,
+			rth_hash_type_ipv6ex:1,
+			rth_bkt_sz:8;
 	int		rth_jhash_golden_ratio;
 	int		tx_steering_type;
 	int 	fifo_indicate_max_pkts;
diff --git a/drivers/net/vxge/vxge-traffic.h b/drivers/net/vxge/vxge-traffic.h
index 6fa07d1..20fda17 100644
--- a/drivers/net/vxge/vxge-traffic.h
+++ b/drivers/net/vxge/vxge-traffic.h
@@ -1912,34 +1912,6 @@ enum vxge_hw_ring_tcode {
 	VXGE_HW_RING_T_CODE_MULTI_ERR			= 0xF
 };
 
-/**
- * enum enum vxge_hw_ring_hash_type - RTH hash types
- * @VXGE_HW_RING_HASH_TYPE_NONE: No Hash
- * @VXGE_HW_RING_HASH_TYPE_TCP_IPV4: TCP IPv4
- * @VXGE_HW_RING_HASH_TYPE_UDP_IPV4: UDP IPv4
- * @VXGE_HW_RING_HASH_TYPE_IPV4: IPv4
- * @VXGE_HW_RING_HASH_TYPE_TCP_IPV6: TCP IPv6
- * @VXGE_HW_RING_HASH_TYPE_UDP_IPV6: UDP IPv6
- * @VXGE_HW_RING_HASH_TYPE_IPV6: IPv6
- * @VXGE_HW_RING_HASH_TYPE_TCP_IPV6_EX: TCP IPv6 extension
- * @VXGE_HW_RING_HASH_TYPE_UDP_IPV6_EX: UDP IPv6 extension
- * @VXGE_HW_RING_HASH_TYPE_IPV6_EX: IPv6 extension
- *
- * RTH hash types
- */
-enum vxge_hw_ring_hash_type {
-	VXGE_HW_RING_HASH_TYPE_NONE			= 0x0,
-	VXGE_HW_RING_HASH_TYPE_TCP_IPV4		= 0x1,
-	VXGE_HW_RING_HASH_TYPE_UDP_IPV4		= 0x2,
-	VXGE_HW_RING_HASH_TYPE_IPV4			= 0x3,
-	VXGE_HW_RING_HASH_TYPE_TCP_IPV6		= 0x4,
-	VXGE_HW_RING_HASH_TYPE_UDP_IPV6		= 0x5,
-	VXGE_HW_RING_HASH_TYPE_IPV6			= 0x6,
-	VXGE_HW_RING_HASH_TYPE_TCP_IPV6_EX	= 0x7,
-	VXGE_HW_RING_HASH_TYPE_UDP_IPV6_EX	= 0x8,
-	VXGE_HW_RING_HASH_TYPE_IPV6_EX		= 0x9
-};
-
 enum vxge_hw_status vxge_hw_ring_rxd_reserve(
 	struct __vxge_hw_ring *ring_handle,
 	void **rxdh);
-- 
1.7.0.4

