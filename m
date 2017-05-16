From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 6/9] nfp: add CHECKSUM_COMPLETE support
Date: Mon, 15 May 2017 17:55:20 -0700
Message-ID: <20170516005523.26124-7-jakub.kicinski@netronome.com>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Edwin Peer <edwin.peer@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34587 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751341AbdEPA4c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 20:56:32 -0400
Received: by mail-pg0-f49.google.com with SMTP id u28so67931966pgn.1
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 17:56:22 -0700 (PDT)
In-Reply-To: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce NFP_NET_CFG_CTRL_CSUM_COMPLETE capability and implement parsing
of CHECKSUM_COMPLETE metadata.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Edwin Peer <edwin.peer@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  4 ++-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 35 +++++++++++++++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  7 ++++-
 3 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index c6b7141dc50d..acd9811d08d1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -292,9 +292,11 @@ struct nfp_net_rx_desc {
 #define NFP_NET_META_FIELD_MASK GENMASK(NFP_NET_META_FIELD_SIZE - 1, 0)
 
 struct nfp_meta_parsed {
-	u32 hash_type;
+	u8 hash_type;
+	u8 csum_type;
 	u32 hash;
 	u32 mark;
+	__wsum csum;
 };
 
 struct nfp_net_rx_hash {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index cc5a2eaef156..d640b3331741 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1354,17 +1354,28 @@ static int nfp_net_rx_csum_has_errors(u16 flags)
  * @dp:  NFP Net data path struct
  * @r_vec: per-ring structure
  * @rxd: Pointer to RX descriptor
+ * @meta: Parsed metadata prepend
  * @skb: Pointer to SKB
  */
 static void nfp_net_rx_csum(struct nfp_net_dp *dp,
 			    struct nfp_net_r_vector *r_vec,
-			    struct nfp_net_rx_desc *rxd, struct sk_buff *skb)
+			    struct nfp_net_rx_desc *rxd,
+			    struct nfp_meta_parsed *meta, struct sk_buff *skb)
 {
 	skb_checksum_none_assert(skb);
 
 	if (!(dp->netdev->features & NETIF_F_RXCSUM))
 		return;
 
+	if (meta->csum_type) {
+		skb->ip_summed = meta->csum_type;
+		skb->csum = meta->csum;
+		u64_stats_update_begin(&r_vec->rx_sync);
+		r_vec->hw_csum_rx_ok++;
+		u64_stats_update_end(&r_vec->rx_sync);
+		return;
+	}
+
 	if (nfp_net_rx_csum_has_errors(le16_to_cpu(rxd->rxd.flags))) {
 		u64_stats_update_begin(&r_vec->rx_sync);
 		r_vec->hw_csum_rx_error++;
@@ -1449,6 +1460,12 @@ nfp_net_parse_meta(struct net_device *netdev, struct nfp_meta_parsed *meta,
 			meta->mark = get_unaligned_be32(data);
 			data += 4;
 			break;
+		case NFP_NET_META_CSUM:
+			meta->csum_type = CHECKSUM_COMPLETE;
+			meta->csum =
+				(__force __wsum)__get_unaligned_cpu32(data);
+			data += 4;
+			break;
 		default:
 			return NULL;
 		}
@@ -1712,7 +1729,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		skb_record_rx_queue(skb, rx_ring->idx);
 		skb->protocol = eth_type_trans(skb, dp->netdev);
 
-		nfp_net_rx_csum(dp, r_vec, rxd, skb);
+		nfp_net_rx_csum(dp, r_vec, rxd, &meta, skb);
 
 		if (rxd->rxd.flags & PCIE_DESC_RX_VLAN)
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
@@ -2712,9 +2729,9 @@ static int nfp_net_set_features(struct net_device *netdev,
 
 	if (changed & NETIF_F_RXCSUM) {
 		if (features & NETIF_F_RXCSUM)
-			new_ctrl |= NFP_NET_CFG_CTRL_RXCSUM;
+			new_ctrl |= nn->cap & NFP_NET_CFG_CTRL_RXCSUM_ANY;
 		else
-			new_ctrl &= ~NFP_NET_CFG_CTRL_RXCSUM;
+			new_ctrl &= ~NFP_NET_CFG_CTRL_RXCSUM_ANY;
 	}
 
 	if (changed & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)) {
@@ -3035,7 +3052,7 @@ void nfp_net_info(struct nfp_net *nn)
 		nn->fw_ver.resv, nn->fw_ver.class,
 		nn->fw_ver.major, nn->fw_ver.minor,
 		nn->max_mtu);
-	nn_info(nn, "CAP: %#x %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n",
+	nn_info(nn, "CAP: %#x %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n",
 		nn->cap,
 		nn->cap & NFP_NET_CFG_CTRL_PROMISC  ? "PROMISC "  : "",
 		nn->cap & NFP_NET_CFG_CTRL_L2BC     ? "L2BCFILT " : "",
@@ -3055,7 +3072,9 @@ void nfp_net_info(struct nfp_net *nn)
 		nn->cap & NFP_NET_CFG_CTRL_IRQMOD   ? "IRQMOD "   : "",
 		nn->cap & NFP_NET_CFG_CTRL_VXLAN    ? "VXLAN "    : "",
 		nn->cap & NFP_NET_CFG_CTRL_NVGRE    ? "NVGRE "	  : "",
-		nfp_net_ebpf_capable(nn)            ? "BPF "	  : "");
+		nfp_net_ebpf_capable(nn)            ? "BPF "	  : "",
+		nn->cap & NFP_NET_CFG_CTRL_CSUM_COMPLETE ?
+						      "RXCSUM_COMPLETE " : "");
 }
 
 /**
@@ -3246,9 +3265,9 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	 * supported.  By default we enable most features.
 	 */
 	netdev->hw_features = NETIF_F_HIGHDMA;
-	if (nn->cap & NFP_NET_CFG_CTRL_RXCSUM) {
+	if (nn->cap & NFP_NET_CFG_CTRL_RXCSUM_ANY) {
 		netdev->hw_features |= NETIF_F_RXCSUM;
-		nn->dp.ctrl |= NFP_NET_CFG_CTRL_RXCSUM;
+		nn->dp.ctrl |= nn->cap & NFP_NET_CFG_CTRL_RXCSUM_ANY;
 	}
 	if (nn->cap & NFP_NET_CFG_CTRL_TXCSUM) {
 		netdev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index a049c5d6839d..df75b8dc3617 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -71,6 +71,7 @@
 #define NFP_NET_META_FIELD_SIZE		4
 #define NFP_NET_META_HASH		1 /* next field carries hash type */
 #define NFP_NET_META_MARK		2
+#define NFP_NET_META_CSUM		6 /* checksum complete type */
 
 /**
  * Hash type pre-pended when a RSS hash was computed
@@ -133,12 +134,16 @@
 #define   NFP_NET_CFG_CTRL_BPF		  (0x1 << 27) /* BPF offload capable */
 #define   NFP_NET_CFG_CTRL_LSO2		  (0x1 << 28) /* LSO/TSO (version 2) */
 #define   NFP_NET_CFG_CTRL_RSS2		  (0x1 << 29) /* RSS (version 2) */
+#define   NFP_NET_CFG_CTRL_CSUM_COMPLETE  (0x1 << 30) /* Checksum complete */
 
 #define NFP_NET_CFG_CTRL_LSO_ANY	(NFP_NET_CFG_CTRL_LSO | \
 					 NFP_NET_CFG_CTRL_LSO2)
 #define NFP_NET_CFG_CTRL_RSS_ANY	(NFP_NET_CFG_CTRL_RSS | \
 					 NFP_NET_CFG_CTRL_RSS2)
-#define NFP_NET_CFG_CTRL_CHAIN_META	NFP_NET_CFG_CTRL_RSS2
+#define NFP_NET_CFG_CTRL_RXCSUM_ANY	(NFP_NET_CFG_CTRL_RXCSUM | \
+					 NFP_NET_CFG_CTRL_CSUM_COMPLETE)
+#define NFP_NET_CFG_CTRL_CHAIN_META	(NFP_NET_CFG_CTRL_RSS2 | \
+					 NFP_NET_CFG_CTRL_CSUM_COMPLETE)
 
 #define NFP_NET_CFG_UPDATE              0x0004
 #define   NFP_NET_CFG_UPDATE_GEN          (0x1 <<  0) /* General update */
-- 
2.11.0
