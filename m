From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 5/9] nfp: version independent support for chained RSS metadata
Date: Mon, 15 May 2017 17:55:19 -0700
Message-ID: <20170516005523.26124-6-jakub.kicinski@netronome.com>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, Edwin Peer <edwin.peer@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36366 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751309AbdEPA40 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 20:56:26 -0400
Received: by mail-pf0-f179.google.com with SMTP id m17so71278435pfg.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 17:56:26 -0700 (PDT)
In-Reply-To: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edwin Peer <edwin.peer@netronome.com>

ABI version 4 introduced metadata chaining. Using the ABI version to signal
metadata chaining precludes firmware that advertises new capabilities which
rely on prepended metadata from working on older kernels.

Capability bits are thus better suited to signalling the chained metadata
format. A new version of the RSS capability is introduced to distinguish
between the differing metadata formats for ABI versions other than 4.

Signed-off-by: Edwin Peer <edwin.peer@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c  | 20 +++++++++++++-------
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h    |  6 +++++-
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 12 ++++++------
 3 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index ae32c0e8d6e6..cc5a2eaef156 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2201,7 +2201,7 @@ static int nfp_net_set_config_and_enable(struct nfp_net *nn)
 
 	new_ctrl = nn->dp.ctrl;
 
-	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_RSS) {
+	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_RSS_ANY) {
 		nfp_net_rss_write_key(nn);
 		nfp_net_rss_write_itbl(nn);
 		nn_writel(nn, NFP_NET_CFG_RSS_CTRL, nn->rss_cfg);
@@ -3035,7 +3035,7 @@ void nfp_net_info(struct nfp_net *nn)
 		nn->fw_ver.resv, nn->fw_ver.class,
 		nn->fw_ver.major, nn->fw_ver.minor,
 		nn->max_mtu);
-	nn_info(nn, "CAP: %#x %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n",
+	nn_info(nn, "CAP: %#x %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n",
 		nn->cap,
 		nn->cap & NFP_NET_CFG_CTRL_PROMISC  ? "PROMISC "  : "",
 		nn->cap & NFP_NET_CFG_CTRL_L2BC     ? "L2BCFILT " : "",
@@ -3048,7 +3048,8 @@ void nfp_net_info(struct nfp_net *nn)
 		nn->cap & NFP_NET_CFG_CTRL_GATHER   ? "GATHER "   : "",
 		nn->cap & NFP_NET_CFG_CTRL_LSO      ? "TSO1 "     : "",
 		nn->cap & NFP_NET_CFG_CTRL_LSO2     ? "TSO2 "     : "",
-		nn->cap & NFP_NET_CFG_CTRL_RSS      ? "RSS "      : "",
+		nn->cap & NFP_NET_CFG_CTRL_RSS      ? "RSS1 "     : "",
+		nn->cap & NFP_NET_CFG_CTRL_RSS2     ? "RSS2 "     : "",
 		nn->cap & NFP_NET_CFG_CTRL_L2SWITCH ? "L2SWITCH " : "",
 		nn->cap & NFP_NET_CFG_CTRL_MSIXAUTO ? "AUTOMASK " : "",
 		nn->cap & NFP_NET_CFG_CTRL_IRQMOD   ? "IRQMOD "   : "",
@@ -3202,14 +3203,18 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	struct nfp_net *nn = netdev_priv(netdev);
 	int err;
 
-	nn->dp.chained_metadata_format = nn->fw_ver.major > 3;
-
 	nn->dp.rx_dma_dir = DMA_FROM_DEVICE;
 
 	/* Get some of the read-only fields from the BAR */
 	nn->cap = nn_readl(nn, NFP_NET_CFG_CAP);
 	nn->max_mtu = nn_readl(nn, NFP_NET_CFG_MAX_MTU);
 
+	/* Chained metadata is signalled by capabilities except in version 4 */
+	nn->dp.chained_metadata_format = nn->fw_ver.major == 4 ||
+					 nn->cap & NFP_NET_CFG_CTRL_CHAIN_META;
+	if (nn->dp.chained_metadata_format && nn->fw_ver.major != 4)
+		nn->cap &= ~NFP_NET_CFG_CTRL_RSS;
+
 	nfp_net_write_mac_addr(nn);
 
 	/* Determine RX packet/metadata boundary offset */
@@ -3259,10 +3264,11 @@ int nfp_net_netdev_init(struct net_device *netdev)
 		nn->dp.ctrl |= nn->cap & NFP_NET_CFG_CTRL_LSO2 ?:
 					 NFP_NET_CFG_CTRL_LSO;
 	}
-	if (nn->cap & NFP_NET_CFG_CTRL_RSS) {
+	if (nn->cap & NFP_NET_CFG_CTRL_RSS_ANY) {
 		netdev->hw_features |= NETIF_F_RXHASH;
 		nfp_net_rss_init(nn);
-		nn->dp.ctrl |= NFP_NET_CFG_CTRL_RSS;
+		nn->dp.ctrl |= nn->cap & NFP_NET_CFG_CTRL_RSS2 ?:
+					 NFP_NET_CFG_CTRL_RSS;
 	}
 	if (nn->cap & NFP_NET_CFG_CTRL_VXLAN &&
 	    nn->cap & NFP_NET_CFG_CTRL_NVGRE) {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index 1575e8fdb541..a049c5d6839d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -121,7 +121,7 @@
 #define   NFP_NET_CFG_CTRL_GATHER         (0x1 <<  9) /* Gather DMA */
 #define   NFP_NET_CFG_CTRL_LSO            (0x1 << 10) /* LSO/TSO (version 1) */
 #define   NFP_NET_CFG_CTRL_RINGCFG        (0x1 << 16) /* Ring runtime changes */
-#define   NFP_NET_CFG_CTRL_RSS            (0x1 << 17) /* RSS */
+#define   NFP_NET_CFG_CTRL_RSS		  (0x1 << 17) /* RSS (version 1) */
 #define   NFP_NET_CFG_CTRL_IRQMOD         (0x1 << 18) /* Interrupt moderation */
 #define   NFP_NET_CFG_CTRL_RINGPRIO       (0x1 << 19) /* Ring priorities */
 #define   NFP_NET_CFG_CTRL_MSIXAUTO       (0x1 << 20) /* MSI-X auto-masking */
@@ -132,9 +132,13 @@
 #define   NFP_NET_CFG_CTRL_NVGRE	  (0x1 << 25) /* NVGRE tunnel support */
 #define   NFP_NET_CFG_CTRL_BPF		  (0x1 << 27) /* BPF offload capable */
 #define   NFP_NET_CFG_CTRL_LSO2		  (0x1 << 28) /* LSO/TSO (version 2) */
+#define   NFP_NET_CFG_CTRL_RSS2		  (0x1 << 29) /* RSS (version 2) */
 
 #define NFP_NET_CFG_CTRL_LSO_ANY	(NFP_NET_CFG_CTRL_LSO | \
 					 NFP_NET_CFG_CTRL_LSO2)
+#define NFP_NET_CFG_CTRL_RSS_ANY	(NFP_NET_CFG_CTRL_RSS | \
+					 NFP_NET_CFG_CTRL_RSS2)
+#define NFP_NET_CFG_CTRL_CHAIN_META	NFP_NET_CFG_CTRL_RSS2
 
 #define NFP_NET_CFG_UPDATE              0x0004
 #define   NFP_NET_CFG_UPDATE_GEN          (0x1 <<  0) /* General update */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index abbb47e60cc3..70bb0a0152b9 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -496,7 +496,7 @@ static int nfp_net_get_rss_hash_opts(struct nfp_net *nn,
 
 	cmd->data = 0;
 
-	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS))
+	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS_ANY))
 		return -EOPNOTSUPP;
 
 	nfp_rss_flag = ethtool_flow_to_nfp_flag(cmd->flow_type);
@@ -533,7 +533,7 @@ static int nfp_net_set_rss_hash_opt(struct nfp_net *nn,
 	u32 nfp_rss_flag;
 	int err;
 
-	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS))
+	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS_ANY))
 		return -EOPNOTSUPP;
 
 	/* RSS only supports IP SA/DA and L4 src/dst ports  */
@@ -595,7 +595,7 @@ static u32 nfp_net_get_rxfh_indir_size(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
-	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS))
+	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS_ANY))
 		return 0;
 
 	return ARRAY_SIZE(nn->rss_itbl);
@@ -605,7 +605,7 @@ static u32 nfp_net_get_rxfh_key_size(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
-	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS))
+	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS_ANY))
 		return -EOPNOTSUPP;
 
 	return nfp_net_rss_key_sz(nn);
@@ -617,7 +617,7 @@ static int nfp_net_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 	struct nfp_net *nn = netdev_priv(netdev);
 	int i;
 
-	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS))
+	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS_ANY))
 		return -EOPNOTSUPP;
 
 	if (indir)
@@ -641,7 +641,7 @@ static int nfp_net_set_rxfh(struct net_device *netdev,
 	struct nfp_net *nn = netdev_priv(netdev);
 	int i;
 
-	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS) ||
+	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS_ANY) ||
 	    !(hfunc == ETH_RSS_HASH_NO_CHANGE || hfunc == nn->rss_hfunc))
 		return -EOPNOTSUPP;
 
-- 
2.11.0
