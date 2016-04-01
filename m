From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v4 net-next 10/15] nfp: slice .ndo_open() and .ndo_stop() up
Date: Fri,  1 Apr 2016 22:06:46 +0100
Message-ID: <1459544811-24879-11-git-send-email-jakub.kicinski@netronome.com>
References: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37471 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbcDAVHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 17:07:11 -0400
Received: by mail-wm0-f54.google.com with SMTP id p65so5356298wmp.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 14:07:10 -0700 (PDT)
In-Reply-To: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divide .ndo_open() and .ndo_stop() into logical, callable
chunks.  No functional changes.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 218 +++++++++++++--------
 1 file changed, 136 insertions(+), 82 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index f504de12ed2a..f171a7da8931 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1673,6 +1673,82 @@ nfp_net_vec_write_ring_data(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 	nn_writeb(nn, NFP_NET_CFG_TXR_VEC(idx), r_vec->irq_idx);
 }
 
+static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
+{
+	u32 new_ctrl, update = 0;
+	unsigned int r;
+	int err;
+
+	new_ctrl = nn->ctrl;
+
+	if (nn->cap & NFP_NET_CFG_CTRL_RSS) {
+		nfp_net_rss_write_key(nn);
+		nfp_net_rss_write_itbl(nn);
+		nn_writel(nn, NFP_NET_CFG_RSS_CTRL, nn->rss_cfg);
+		update |= NFP_NET_CFG_UPDATE_RSS;
+	}
+
+	if (nn->cap & NFP_NET_CFG_CTRL_IRQMOD) {
+		nfp_net_coalesce_write_cfg(nn);
+
+		new_ctrl |= NFP_NET_CFG_CTRL_IRQMOD;
+		update |= NFP_NET_CFG_UPDATE_IRQMOD;
+	}
+
+	for (r = 0; r < nn->num_r_vecs; r++)
+		nfp_net_vec_write_ring_data(nn, &nn->r_vecs[r], r);
+
+	nn_writeq(nn, NFP_NET_CFG_TXRS_ENABLE, nn->num_tx_rings == 64 ?
+		  0xffffffffffffffffULL : ((u64)1 << nn->num_tx_rings) - 1);
+
+	nn_writeq(nn, NFP_NET_CFG_RXRS_ENABLE, nn->num_rx_rings == 64 ?
+		  0xffffffffffffffffULL : ((u64)1 << nn->num_rx_rings) - 1);
+
+	nfp_net_write_mac_addr(nn, nn->netdev->dev_addr);
+
+	nn_writel(nn, NFP_NET_CFG_MTU, nn->netdev->mtu);
+	nn_writel(nn, NFP_NET_CFG_FLBUFSZ, nn->fl_bufsz);
+
+	/* Enable device */
+	new_ctrl |= NFP_NET_CFG_CTRL_ENABLE;
+	update |= NFP_NET_CFG_UPDATE_GEN;
+	update |= NFP_NET_CFG_UPDATE_MSIX;
+	update |= NFP_NET_CFG_UPDATE_RING;
+	if (nn->cap & NFP_NET_CFG_CTRL_RINGCFG)
+		new_ctrl |= NFP_NET_CFG_CTRL_RINGCFG;
+
+	nn_writel(nn, NFP_NET_CFG_CTRL, new_ctrl);
+	err = nfp_net_reconfig(nn, update);
+
+	nn->ctrl = new_ctrl;
+
+	/* Since reconfiguration requests while NFP is down are ignored we
+	 * have to wipe the entire VXLAN configuration and reinitialize it.
+	 */
+	if (nn->ctrl & NFP_NET_CFG_CTRL_VXLAN) {
+		memset(&nn->vxlan_ports, 0, sizeof(nn->vxlan_ports));
+		memset(&nn->vxlan_usecnt, 0, sizeof(nn->vxlan_usecnt));
+		vxlan_get_rx_port(nn->netdev);
+	}
+
+	return err;
+}
+
+/**
+ * nfp_net_set_config_and_enable() - Write control BAR and enable NFP
+ * @nn:      NFP Net device to reconfigure
+ */
+static int nfp_net_set_config_and_enable(struct nfp_net *nn)
+{
+	int err;
+
+	err = __nfp_net_set_config_and_enable(nn);
+	if (err)
+		nfp_net_clear_config_and_disable(nn);
+
+	return err;
+}
+
 /**
  * nfp_net_start_vec() - Start ring vector
  * @nn:      NFP Net device structure
@@ -1693,20 +1769,33 @@ nfp_net_start_vec(struct nfp_net *nn, struct nfp_net_r_vector *r_vec)
 	enable_irq(irq_vec);
 }
 
+/**
+ * nfp_net_open_stack() - Start the device from stack's perspective
+ * @nn:      NFP Net device to reconfigure
+ */
+static void nfp_net_open_stack(struct nfp_net *nn)
+{
+	unsigned int r;
+
+	for (r = 0; r < nn->num_r_vecs; r++)
+		nfp_net_start_vec(nn, &nn->r_vecs[r]);
+
+	netif_tx_wake_all_queues(nn->netdev);
+
+	enable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
+	nfp_net_read_link_status(nn);
+}
+
 static int nfp_net_netdev_open(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 	int err, r;
-	u32 update = 0;
-	u32 new_ctrl;
 
 	if (nn->ctrl & NFP_NET_CFG_CTRL_ENABLE) {
 		nn_err(nn, "Dev is already enabled: 0x%08x\n", nn->ctrl);
 		return -EBUSY;
 	}
 
-	new_ctrl = nn->ctrl;
-
 	/* Step 1: Allocate resources for rings and the like
 	 * - Request interrupts
 	 * - Allocate RX and TX ring resources
@@ -1759,20 +1848,6 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	if (err)
 		goto err_free_rings;
 
-	if (nn->cap & NFP_NET_CFG_CTRL_RSS) {
-		nfp_net_rss_write_key(nn);
-		nfp_net_rss_write_itbl(nn);
-		nn_writel(nn, NFP_NET_CFG_RSS_CTRL, nn->rss_cfg);
-		update |= NFP_NET_CFG_UPDATE_RSS;
-	}
-
-	if (nn->cap & NFP_NET_CFG_CTRL_IRQMOD) {
-		nfp_net_coalesce_write_cfg(nn);
-
-		new_ctrl |= NFP_NET_CFG_CTRL_IRQMOD;
-		update |= NFP_NET_CFG_UPDATE_IRQMOD;
-	}
-
 	/* Step 2: Configure the NFP
 	 * - Enable rings from 0 to tx_rings/rx_rings - 1.
 	 * - Write MAC address (in case it changed)
@@ -1780,43 +1855,9 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	 * - Set the Freelist buffer size
 	 * - Enable the FW
 	 */
-	for (r = 0; r < nn->num_r_vecs; r++)
-		nfp_net_vec_write_ring_data(nn, &nn->r_vecs[r], r);
-
-	nn_writeq(nn, NFP_NET_CFG_TXRS_ENABLE, nn->num_tx_rings == 64 ?
-		  0xffffffffffffffffULL : ((u64)1 << nn->num_tx_rings) - 1);
-
-	nn_writeq(nn, NFP_NET_CFG_RXRS_ENABLE, nn->num_rx_rings == 64 ?
-		  0xffffffffffffffffULL : ((u64)1 << nn->num_rx_rings) - 1);
-
-	nfp_net_write_mac_addr(nn, netdev->dev_addr);
-
-	nn_writel(nn, NFP_NET_CFG_MTU, netdev->mtu);
-	nn_writel(nn, NFP_NET_CFG_FLBUFSZ, nn->fl_bufsz);
-
-	/* Enable device */
-	new_ctrl |= NFP_NET_CFG_CTRL_ENABLE;
-	update |= NFP_NET_CFG_UPDATE_GEN;
-	update |= NFP_NET_CFG_UPDATE_MSIX;
-	update |= NFP_NET_CFG_UPDATE_RING;
-	if (nn->cap & NFP_NET_CFG_CTRL_RINGCFG)
-		new_ctrl |= NFP_NET_CFG_CTRL_RINGCFG;
-
-	nn_writel(nn, NFP_NET_CFG_CTRL, new_ctrl);
-	err = nfp_net_reconfig(nn, update);
+	err = nfp_net_set_config_and_enable(nn);
 	if (err)
-		goto err_clear_config;
-
-	nn->ctrl = new_ctrl;
-
-	/* Since reconfiguration requests while NFP is down are ignored we
-	 * have to wipe the entire VXLAN configuration and reinitialize it.
-	 */
-	if (nn->ctrl & NFP_NET_CFG_CTRL_VXLAN) {
-		memset(&nn->vxlan_ports, 0, sizeof(nn->vxlan_ports));
-		memset(&nn->vxlan_usecnt, 0, sizeof(nn->vxlan_usecnt));
-		vxlan_get_rx_port(netdev);
-	}
+		goto err_free_rings;
 
 	/* Step 3: Enable for kernel
 	 * - put some freelist descriptors on each RX ring
@@ -1824,18 +1865,10 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	 * - enable all TX queues
 	 * - set link state
 	 */
-	for (r = 0; r < nn->num_r_vecs; r++)
-		nfp_net_start_vec(nn, &nn->r_vecs[r]);
-
-	netif_tx_wake_all_queues(netdev);
-
-	enable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
-	nfp_net_read_link_status(nn);
+	nfp_net_open_stack(nn);
 
 	return 0;
 
-err_clear_config:
-	nfp_net_clear_config_and_disable(nn);
 err_free_rings:
 	r = nn->num_r_vecs;
 err_free_prev_vecs:
@@ -1859,36 +1892,31 @@ err_free_exn:
 }
 
 /**
- * nfp_net_netdev_close() - Called when the device is downed
- * @netdev:      netdev structure
+ * nfp_net_close_stack() - Quiescent the stack (part of close)
+ * @nn:	     NFP Net device to reconfigure
  */
-static int nfp_net_netdev_close(struct net_device *netdev)
+static void nfp_net_close_stack(struct nfp_net *nn)
 {
-	struct nfp_net *nn = netdev_priv(netdev);
-	int r;
-
-	if (!(nn->ctrl & NFP_NET_CFG_CTRL_ENABLE)) {
-		nn_err(nn, "Dev is not up: 0x%08x\n", nn->ctrl);
-		return 0;
-	}
+	unsigned int r;
 
-	/* Step 1: Disable RX and TX rings from the Linux kernel perspective
-	 */
 	disable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
-	netif_carrier_off(netdev);
+	netif_carrier_off(nn->netdev);
 	nn->link_up = false;
 
 	for (r = 0; r < nn->num_r_vecs; r++)
 		napi_disable(&nn->r_vecs[r].napi);
 
-	netif_tx_disable(netdev);
+	netif_tx_disable(nn->netdev);
+}
 
-	/* Step 2: Tell NFP
-	 */
-	nfp_net_clear_config_and_disable(nn);
+/**
+ * nfp_net_close_free_all() - Free all runtime resources
+ * @nn:      NFP Net device to reconfigure
+ */
+static void nfp_net_close_free_all(struct nfp_net *nn)
+{
+	unsigned int r;
 
-	/* Step 3: Free resources
-	 */
 	for (r = 0; r < nn->num_r_vecs; r++) {
 		nfp_net_rx_ring_reset(nn->r_vecs[r].rx_ring);
 		nfp_net_rx_ring_bufs_free(nn, nn->r_vecs[r].rx_ring);
@@ -1903,6 +1931,32 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
+}
+
+/**
+ * nfp_net_netdev_close() - Called when the device is downed
+ * @netdev:      netdev structure
+ */
+static int nfp_net_netdev_close(struct net_device *netdev)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	if (!(nn->ctrl & NFP_NET_CFG_CTRL_ENABLE)) {
+		nn_err(nn, "Dev is not up: 0x%08x\n", nn->ctrl);
+		return 0;
+	}
+
+	/* Step 1: Disable RX and TX rings from the Linux kernel perspective
+	 */
+	nfp_net_close_stack(nn);
+
+	/* Step 2: Tell NFP
+	 */
+	nfp_net_clear_config_and_disable(nn);
+
+	/* Step 3: Free resources
+	 */
+	nfp_net_close_free_all(nn);
 
 	nn_dbg(nn, "%s down", netdev->name);
 	return 0;
-- 
1.9.1
