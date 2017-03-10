From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 02/13] nfp: move control BAR pointer into data path structure
Date: Fri, 10 Mar 2017 10:38:28 -0800
Message-ID: <20170310183839.39568-3-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36644 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755401AbdCJSj1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:27 -0500
Received: by mail-pg0-f42.google.com with SMTP id g2so24402898pge.3
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:26 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Control BAR pointer is used to unmask interrupts so it should be
in the first cacheline of adapter structure.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h        | 21 +++++++++++----------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c    | 14 +++++++-------
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c   |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c |  4 ++--
 4 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 7d2c38604372..90a44fad6bd5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -447,6 +447,7 @@ struct nfp_stat_pair {
  * @xdp_prog:		Installed XDP program
  * @tx_rings:		Array of pre-allocated TX ring structures
  * @rx_rings:		Array of pre-allocated RX ring structures
+ * @ctrl_bar:		Pointer to mapped control BAR
  *
  * @txd_cnt:		Size of the TX ring in number of descriptors
  * @rxd_cnt:		Size of the RX ring in number of descriptors
@@ -474,6 +475,8 @@ struct nfp_net_dp {
 	struct nfp_net_tx_ring *tx_rings;
 	struct nfp_net_rx_ring *rx_rings;
 
+	u8 __iomem *ctrl_bar;
+
 	/* Cold data follows */
 
 	unsigned int txd_cnt;
@@ -527,7 +530,6 @@ struct nfp_net_dp {
  * @vxlan_ports:	VXLAN ports for RX inner csum offload communicated to HW
  * @vxlan_usecnt:	IPv4/IPv6 VXLAN port use counts
  * @qcp_cfg:            Pointer to QCP queue used for configuration notification
- * @ctrl_bar:           Pointer to mapped control BAR
  * @tx_bar:             Pointer to mapped TX queues
  * @rx_bar:             Pointer to mapped FL/RX queues
  * @debugfs_dir:	Device directory in debugfs
@@ -595,7 +597,6 @@ struct nfp_net {
 
 	u8 __iomem *qcp_cfg;
 
-	u8 __iomem *ctrl_bar;
 	u8 __iomem *tx_bar;
 	u8 __iomem *rx_bar;
 
@@ -622,42 +623,42 @@ struct nfp_net_ring_set {
  */
 static inline u16 nn_readb(struct nfp_net *nn, int off)
 {
-	return readb(nn->ctrl_bar + off);
+	return readb(nn->dp.ctrl_bar + off);
 }
 
 static inline void nn_writeb(struct nfp_net *nn, int off, u8 val)
 {
-	writeb(val, nn->ctrl_bar + off);
+	writeb(val, nn->dp.ctrl_bar + off);
 }
 
 static inline u16 nn_readw(struct nfp_net *nn, int off)
 {
-	return readw(nn->ctrl_bar + off);
+	return readw(nn->dp.ctrl_bar + off);
 }
 
 static inline void nn_writew(struct nfp_net *nn, int off, u16 val)
 {
-	writew(val, nn->ctrl_bar + off);
+	writew(val, nn->dp.ctrl_bar + off);
 }
 
 static inline u32 nn_readl(struct nfp_net *nn, int off)
 {
-	return readl(nn->ctrl_bar + off);
+	return readl(nn->dp.ctrl_bar + off);
 }
 
 static inline void nn_writel(struct nfp_net *nn, int off, u32 val)
 {
-	writel(val, nn->ctrl_bar + off);
+	writel(val, nn->dp.ctrl_bar + off);
 }
 
 static inline u64 nn_readq(struct nfp_net *nn, int off)
 {
-	return readq(nn->ctrl_bar + off);
+	return readq(nn->dp.ctrl_bar + off);
 }
 
 static inline void nn_writeq(struct nfp_net *nn, int off, u64 val)
 {
-	writeq(val, nn->ctrl_bar + off);
+	writeq(val, nn->dp.ctrl_bar + off);
 }
 
 /* Flush posted PCI writes by reading something without side effects */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 4620c1bba96e..969c30589f23 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -307,7 +307,7 @@ static void nfp_net_get_stats(struct net_device *netdev,
 			break;
 
 		case NFP_NET_DEV_ET_STATS:
-			io_p = nn->ctrl_bar + nfp_net_et_stats[i].off;
+			io_p = nn->dp.ctrl_bar + nfp_net_et_stats[i].off;
 			data[i] = readq(io_p);
 			break;
 		}
@@ -339,15 +339,15 @@ static void nfp_net_get_stats(struct net_device *netdev,
 	for (j = 0; j < NN_ET_RVEC_GATHER_STATS; j++)
 		data[i++] = gathered_stats[j];
 	for (j = 0; j < nn->dp.num_tx_rings; j++) {
-		io_p = nn->ctrl_bar + NFP_NET_CFG_TXR_STATS(j);
+		io_p = nn->dp.ctrl_bar + NFP_NET_CFG_TXR_STATS(j);
 		data[i++] = readq(io_p);
-		io_p = nn->ctrl_bar + NFP_NET_CFG_TXR_STATS(j) + 8;
+		io_p = nn->dp.ctrl_bar + NFP_NET_CFG_TXR_STATS(j) + 8;
 		data[i++] = readq(io_p);
 	}
 	for (j = 0; j < nn->dp.num_rx_rings; j++) {
-		io_p = nn->ctrl_bar + NFP_NET_CFG_RXR_STATS(j);
+		io_p = nn->dp.ctrl_bar + NFP_NET_CFG_RXR_STATS(j);
 		data[i++] = readq(io_p);
-		io_p = nn->ctrl_bar + NFP_NET_CFG_RXR_STATS(j) + 8;
+		io_p = nn->dp.ctrl_bar + NFP_NET_CFG_RXR_STATS(j) + 8;
 		data[i++] = readq(io_p);
 	}
 }
@@ -461,7 +461,7 @@ static int nfp_net_set_rss_hash_opt(struct nfp_net *nn,
 	if (new_rss_cfg == nn->rss_cfg)
 		return 0;
 
-	writel(new_rss_cfg, nn->ctrl_bar + NFP_NET_CFG_RSS_CTRL);
+	writel(new_rss_cfg, nn->dp.ctrl_bar + NFP_NET_CFG_RSS_CTRL);
 	err = nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_RSS);
 	if (err)
 		return err;
@@ -573,7 +573,7 @@ static void nfp_net_get_regs(struct net_device *netdev,
 	regs->version = nn_readl(nn, NFP_NET_CFG_VERSION);
 
 	for (i = 0; i < NFP_NET_CFG_BAR_SZ / sizeof(u32); i++)
-		regs_buf[i] = readl(nn->ctrl_bar + (i * sizeof(u32)));
+		regs_buf[i] = readl(nn->dp.ctrl_bar + (i * sizeof(u32)));
 }
 
 static int nfp_net_get_coalesce(struct net_device *netdev,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 3935d19a273d..2025cb7c6d90 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -306,7 +306,7 @@ nfp_net_pf_alloc_port_netdev(struct nfp_pf *pf, void __iomem *ctrl_bar,
 
 	nn->cpp = pf->cpp;
 	nn->fw_ver = *fw_ver;
-	nn->ctrl_bar = ctrl_bar;
+	nn->dp.ctrl_bar = ctrl_bar;
 	nn->tx_bar = tx_bar;
 	nn->rx_bar = rx_bar;
 	nn->dp.is_vf = 0;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
index bc0bdbc1c8fd..86e61be6f35c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
@@ -210,7 +210,7 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	vf->nn = nn;
 
 	nn->fw_ver = fw_ver;
-	nn->ctrl_bar = ctrl_bar;
+	nn->dp.ctrl_bar = ctrl_bar;
 	nn->dp.is_vf = 1;
 	nn->stride_tx = stride;
 	nn->stride_rx = stride;
@@ -338,7 +338,7 @@ static void nfp_netvf_pci_remove(struct pci_dev *pdev)
 	} else {
 		iounmap(vf->q_bar);
 	}
-	iounmap(nn->ctrl_bar);
+	iounmap(nn->dp.ctrl_bar);
 
 	nfp_net_netdev_free(nn);
 
-- 
2.11.0
