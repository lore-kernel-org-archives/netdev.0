From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 07/16] nfp: allow allocation and initialization of netdev-less vNICs
Date: Mon,  5 Jun 2017 17:01:48 -0700
Message-ID: <20170606000157.17556-8-jakub.kicinski@netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34246 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751276AbdFFACV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:21 -0400
Received: by mail-pf0-f180.google.com with SMTP id 9so89898407pfj.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:21 -0700 (PDT)
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vNICs used for sending and receiving control messages shouldn't
really have a netdev.  Add the ability to initialize vNICs for
netdev-less operation.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   2 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 170 ++++++++++++---------
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |   7 +-
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |   2 +-
 4 files changed, 105 insertions(+), 76 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 3eec4195c155..6b21c4d0ccfa 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -831,7 +831,7 @@ void nfp_net_get_fw_version(struct nfp_net_fw_version *fw_ver,
 			    void __iomem *ctrl_bar);
 
 struct nfp_net *
-nfp_net_alloc(struct pci_dev *pdev,
+nfp_net_alloc(struct pci_dev *pdev, bool needs_netdev,
 	      unsigned int max_tx_rings, unsigned int max_rx_rings);
 void nfp_net_free(struct nfp_net *nn);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index f8dba793a8fe..1cc7425ffd27 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -61,7 +61,7 @@
 #include <linux/log2.h>
 #include <linux/if_vlan.h>
 #include <linux/random.h>
-
+#include <linux/vmalloc.h>
 #include <linux/ktime.h>
 
 #include <net/vxlan.h>
@@ -1820,7 +1820,7 @@ nfp_net_tx_ring_alloc(struct nfp_net_dp *dp, struct nfp_net_tx_ring *tx_ring)
 	if (!tx_ring->txbufs)
 		goto err_alloc;
 
-	if (!tx_ring->is_xdp)
+	if (!tx_ring->is_xdp && dp->netdev)
 		netif_set_xps_queue(dp->netdev, &r_vec->affinity_mask,
 				    tx_ring->idx);
 
@@ -3034,30 +3034,39 @@ void nfp_net_info(struct nfp_net *nn)
 /**
  * nfp_net_alloc() - Allocate netdev and related structure
  * @pdev:         PCI device
+ * @needs_netdev: Whether to allocate a netdev for this vNIC
  * @max_tx_rings: Maximum number of TX rings supported by device
  * @max_rx_rings: Maximum number of RX rings supported by device
  *
  * This function allocates a netdev device and fills in the initial
- * part of the @struct nfp_net structure.
+ * part of the @struct nfp_net structure.  In case of control device
+ * nfp_net structure is allocated without the netdev.
  *
  * Return: NFP Net device structure, or ERR_PTR on error.
  */
-struct nfp_net *nfp_net_alloc(struct pci_dev *pdev,
+struct nfp_net *nfp_net_alloc(struct pci_dev *pdev, bool needs_netdev,
 			      unsigned int max_tx_rings,
 			      unsigned int max_rx_rings)
 {
-	struct net_device *netdev;
 	struct nfp_net *nn;
 
-	netdev = alloc_etherdev_mqs(sizeof(struct nfp_net),
-				    max_tx_rings, max_rx_rings);
-	if (!netdev)
-		return ERR_PTR(-ENOMEM);
+	if (needs_netdev) {
+		struct net_device *netdev;
 
-	SET_NETDEV_DEV(netdev, &pdev->dev);
-	nn = netdev_priv(netdev);
+		netdev = alloc_etherdev_mqs(sizeof(struct nfp_net),
+					    max_tx_rings, max_rx_rings);
+		if (!netdev)
+			return ERR_PTR(-ENOMEM);
+
+		SET_NETDEV_DEV(netdev, &pdev->dev);
+		nn = netdev_priv(netdev);
+		nn->dp.netdev = netdev;
+	} else {
+		nn = vzalloc(sizeof(*nn));
+		if (!nn)
+			return ERR_PTR(-ENOMEM);
+	}
 
-	nn->dp.netdev = netdev;
 	nn->dp.dev = &pdev->dev;
 	nn->pdev = pdev;
 
@@ -3091,7 +3100,10 @@ struct nfp_net *nfp_net_alloc(struct pci_dev *pdev,
  */
 void nfp_net_free(struct nfp_net *nn)
 {
-	free_netdev(nn->dp.netdev);
+	if (nn->dp.netdev)
+		free_netdev(nn->dp.netdev);
+	else
+		vfree(nn);
 }
 
 /**
@@ -3162,52 +3174,13 @@ static void nfp_net_irqmod_init(struct nfp_net *nn)
 	nn->tx_coalesce_max_frames = 64;
 }
 
-/**
- * nfp_net_init() - Initialise/finalise the nfp_net structure
- * @nn:		NFP Net device structure
- *
- * Return: 0 on success or negative errno on error.
- */
-int nfp_net_init(struct nfp_net *nn)
+static void nfp_net_netdev_init(struct nfp_net *nn)
 {
 	struct net_device *netdev = nn->dp.netdev;
-	int err;
-
-	nn->dp.rx_dma_dir = DMA_FROM_DEVICE;
-
-	/* Get some of the read-only fields from the BAR */
-	nn->cap = nn_readl(nn, NFP_NET_CFG_CAP);
-	nn->max_mtu = nn_readl(nn, NFP_NET_CFG_MAX_MTU);
-
-	/* Chained metadata is signalled by capabilities except in version 4 */
-	nn->dp.chained_metadata_format = nn->fw_ver.major == 4 ||
-					 nn->cap & NFP_NET_CFG_CTRL_CHAIN_META;
-	if (nn->dp.chained_metadata_format && nn->fw_ver.major != 4)
-		nn->cap &= ~NFP_NET_CFG_CTRL_RSS;
 
 	nfp_net_write_mac_addr(nn, nn->dp.netdev->dev_addr);
 
-	/* Determine RX packet/metadata boundary offset */
-	if (nn->fw_ver.major >= 2) {
-		u32 reg;
-
-		reg = nn_readl(nn, NFP_NET_CFG_RX_OFFSET);
-		if (reg > NFP_NET_MAX_PREPEND) {
-			nn_err(nn, "Invalid rx offset: %d\n", reg);
-			return -EINVAL;
-		}
-		nn->dp.rx_offset = reg;
-	} else {
-		nn->dp.rx_offset = NFP_NET_RX_OFFSET;
-	}
-
-	/* Set default MTU and Freelist buffer size */
-	if (nn->max_mtu < NFP_NET_DEFAULT_MTU)
-		netdev->mtu = nn->max_mtu;
-	else
-		netdev->mtu = NFP_NET_DEFAULT_MTU;
-	nn->dp.mtu = netdev->mtu;
-	nn->dp.fl_bufsz = nfp_net_calc_fl_bufsz(&nn->dp);
+	netdev->mtu = nn->dp.mtu;
 
 	/* Advertise/enable offloads based on capabilities
 	 *
@@ -3237,12 +3210,8 @@ int nfp_net_init(struct nfp_net *nn)
 		nn->dp.ctrl |= nn->cap & NFP_NET_CFG_CTRL_LSO2 ?:
 					 NFP_NET_CFG_CTRL_LSO;
 	}
-	if (nn->cap & NFP_NET_CFG_CTRL_RSS_ANY) {
+	if (nn->cap & NFP_NET_CFG_CTRL_RSS_ANY)
 		netdev->hw_features |= NETIF_F_RXHASH;
-		nfp_net_rss_init(nn);
-		nn->dp.ctrl |= nn->cap & NFP_NET_CFG_CTRL_RSS2 ?:
-					 NFP_NET_CFG_CTRL_RSS;
-	}
 	if (nn->cap & NFP_NET_CFG_CTRL_VXLAN &&
 	    nn->cap & NFP_NET_CFG_CTRL_NVGRE) {
 		if (nn->cap & NFP_NET_CFG_CTRL_LSO)
@@ -3277,6 +3246,68 @@ int nfp_net_init(struct nfp_net *nn)
 	netdev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
 	nn->dp.ctrl &= ~NFP_NET_CFG_CTRL_LSO_ANY;
 
+	/* Finalise the netdev setup */
+	netdev->netdev_ops = &nfp_net_netdev_ops;
+	netdev->watchdog_timeo = msecs_to_jiffies(5 * 1000);
+
+	/* MTU range: 68 - hw-specific max */
+	netdev->min_mtu = ETH_MIN_MTU;
+	netdev->max_mtu = nn->max_mtu;
+
+	netif_carrier_off(netdev);
+
+	nfp_net_set_ethtool_ops(netdev);
+}
+
+/**
+ * nfp_net_init() - Initialise/finalise the nfp_net structure
+ * @nn:		NFP Net device structure
+ *
+ * Return: 0 on success or negative errno on error.
+ */
+int nfp_net_init(struct nfp_net *nn)
+{
+	int err;
+
+	nn->dp.rx_dma_dir = DMA_FROM_DEVICE;
+
+	/* Get some of the read-only fields from the BAR */
+	nn->cap = nn_readl(nn, NFP_NET_CFG_CAP);
+	nn->max_mtu = nn_readl(nn, NFP_NET_CFG_MAX_MTU);
+
+	/* Chained metadata is signalled by capabilities except in version 4 */
+	nn->dp.chained_metadata_format = nn->fw_ver.major == 4 ||
+					 nn->cap & NFP_NET_CFG_CTRL_CHAIN_META;
+	if (nn->dp.chained_metadata_format && nn->fw_ver.major != 4)
+		nn->cap &= ~NFP_NET_CFG_CTRL_RSS;
+
+	/* Determine RX packet/metadata boundary offset */
+	if (nn->fw_ver.major >= 2) {
+		u32 reg;
+
+		reg = nn_readl(nn, NFP_NET_CFG_RX_OFFSET);
+		if (reg > NFP_NET_MAX_PREPEND) {
+			nn_err(nn, "Invalid rx offset: %d\n", reg);
+			return -EINVAL;
+		}
+		nn->dp.rx_offset = reg;
+	} else {
+		nn->dp.rx_offset = NFP_NET_RX_OFFSET;
+	}
+
+	/* Set default MTU and Freelist buffer size */
+	if (nn->max_mtu < NFP_NET_DEFAULT_MTU)
+		nn->dp.mtu = nn->max_mtu;
+	else
+		nn->dp.mtu = NFP_NET_DEFAULT_MTU;
+	nn->dp.fl_bufsz = nfp_net_calc_fl_bufsz(&nn->dp);
+
+	if (nn->cap & NFP_NET_CFG_CTRL_RSS_ANY) {
+		nfp_net_rss_init(nn);
+		nn->dp.ctrl |= nn->cap & NFP_NET_CFG_CTRL_RSS2 ?:
+					 NFP_NET_CFG_CTRL_RSS;
+	}
+
 	/* Allow L2 Broadcast and Multicast through by default, if supported */
 	if (nn->cap & NFP_NET_CFG_CTRL_L2BC)
 		nn->dp.ctrl |= NFP_NET_CFG_CTRL_L2BC;
@@ -3289,6 +3320,9 @@ int nfp_net_init(struct nfp_net *nn)
 		nn->dp.ctrl |= NFP_NET_CFG_CTRL_IRQMOD;
 	}
 
+	if (nn->dp.netdev)
+		nfp_net_netdev_init(nn);
+
 	/* Stash the re-configuration queue away.  First odd queue in TX Bar */
 	nn->qcp_cfg = nn->tx_bar + NFP_QCP_QUEUE_ADDR_SZ;
 
@@ -3301,20 +3335,11 @@ int nfp_net_init(struct nfp_net *nn)
 	if (err)
 		return err;
 
-	/* Finalise the netdev setup */
-	netdev->netdev_ops = &nfp_net_netdev_ops;
-	netdev->watchdog_timeo = msecs_to_jiffies(5 * 1000);
-
-	/* MTU range: 68 - hw-specific max */
-	netdev->min_mtu = ETH_MIN_MTU;
-	netdev->max_mtu = nn->max_mtu;
-
-	netif_carrier_off(netdev);
-
-	nfp_net_set_ethtool_ops(netdev);
 	nfp_net_vecs_init(nn);
 
-	return register_netdev(netdev);
+	if (!nn->dp.netdev)
+		return 0;
+	return register_netdev(nn->dp.netdev);
 }
 
 /**
@@ -3323,6 +3348,9 @@ int nfp_net_init(struct nfp_net *nn)
  */
 void nfp_net_clean(struct nfp_net *nn)
 {
+	if (!nn->dp.netdev)
+		return;
+
 	unregister_netdev(nn->dp.netdev);
 
 	if (nn->dp.xdp_prog)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 7dd310911d9f..dd2a99fca716 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -303,7 +303,8 @@ static void nfp_net_pf_free_vnics(struct nfp_pf *pf)
 }
 
 static struct nfp_net *
-nfp_net_pf_alloc_vnic(struct nfp_pf *pf, void __iomem *ctrl_bar,
+nfp_net_pf_alloc_vnic(struct nfp_pf *pf, bool needs_netdev,
+		      void __iomem *ctrl_bar,
 		      void __iomem *tx_bar, void __iomem *rx_bar,
 		      int stride, struct nfp_net_fw_version *fw_ver,
 		      unsigned int eth_id)
@@ -316,7 +317,7 @@ nfp_net_pf_alloc_vnic(struct nfp_pf *pf, void __iomem *ctrl_bar,
 	n_rx_rings = readl(ctrl_bar + NFP_NET_CFG_MAX_RXRINGS);
 
 	/* Allocate and initialise the vNIC */
-	nn = nfp_net_alloc(pf->pdev, n_tx_rings, n_rx_rings);
+	nn = nfp_net_alloc(pf->pdev, needs_netdev, n_tx_rings, n_rx_rings);
 	if (IS_ERR(nn))
 		return nn;
 
@@ -395,7 +396,7 @@ nfp_net_pf_alloc_vnics(struct nfp_pf *pf, void __iomem *ctrl_bar,
 		prev_tx_base = tgt_tx_base;
 		prev_rx_base = tgt_rx_base;
 
-		nn = nfp_net_pf_alloc_vnic(pf, ctrl_bar, tx_bar, rx_bar,
+		nn = nfp_net_pf_alloc_vnic(pf, true, ctrl_bar, tx_bar, rx_bar,
 					   stride, fw_ver, i);
 		if (IS_ERR(nn)) {
 			err = PTR_ERR(nn);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
index 3f1c7f0f392e..0bf3b0febd07 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
@@ -202,7 +202,7 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	rx_bar_off = NFP_PCIE_QUEUE(startq);
 
 	/* Allocate and initialise the netdev */
-	nn = nfp_net_alloc(pdev, max_tx_rings, max_rx_rings);
+	nn = nfp_net_alloc(pdev, true, max_tx_rings, max_rx_rings);
 	if (IS_ERR(nn)) {
 		err = PTR_ERR(nn);
 		goto err_ctrl_unmap;
-- 
2.11.0
