From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 19/19] nfp: allow ring size reconfiguration at runtime
Date: Wed,  3 Feb 2016 11:45:25 +0000
Message-ID: <1454499925-16359-20-git-send-email-jakub.kicinski@netronome.com>
References: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35303 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933137AbcBCLpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:54 -0500
Received: by mail-wm0-f44.google.com with SMTP id r129so160916326wmr.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:54 -0800 (PST)
In-Reply-To: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since much of the required changes have already been made for
changing MTU at runtime let's use it for ring size changes as
well.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   1 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 129 +++++++++++++++++++++
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  30 ++---
 3 files changed, 139 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 1e08c9cf3ee0..90ad6264e62c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -724,6 +724,7 @@ void nfp_net_rss_write_key(struct nfp_net *nn);
 void nfp_net_coalesce_write_cfg(struct nfp_net *nn);
 int nfp_net_irqs_alloc(struct nfp_net *nn);
 void nfp_net_irqs_disable(struct nfp_net *nn);
+int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt);
 
 #ifdef CONFIG_NFP_NET_DEBUG
 void nfp_net_debugfs_create(void);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 2c86a10abcd3..70d366bdd4b7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1442,6 +1442,59 @@ err_alloc:
 	return -ENOMEM;
 }
 
+static struct nfp_net_tx_ring *
+nfp_net_shadow_tx_rings_prepare(struct nfp_net *nn, u32 buf_cnt)
+{
+	struct nfp_net_tx_ring *rings;
+	unsigned int r;
+
+	rings = kcalloc(nn->num_tx_rings, sizeof(*rings), GFP_KERNEL);
+	if (!rings)
+		return NULL;
+
+	for (r = 0; r < nn->num_tx_rings; r++) {
+		nfp_net_tx_ring_init(&rings[r], nn->tx_rings[r].r_vec, r);
+
+		if (nfp_net_tx_ring_alloc(&rings[r], buf_cnt))
+			goto err_free_prev;
+	}
+
+	return rings;
+
+err_free_prev:
+	while (r--)
+		nfp_net_tx_ring_free(&rings[r]);
+	kfree(rings);
+	return NULL;
+}
+
+static struct nfp_net_tx_ring *
+nfp_net_shadow_tx_rings_swap(struct nfp_net *nn, struct nfp_net_tx_ring *rings)
+{
+	struct nfp_net_tx_ring *old = nn->tx_rings;
+	unsigned int r;
+
+	for (r = 0; r < nn->num_tx_rings; r++)
+		old[r].r_vec->tx_ring = &rings[r];
+
+	nn->tx_rings = rings;
+	return old;
+}
+
+static void
+nfp_net_shadow_tx_rings_free(struct nfp_net *nn, struct nfp_net_tx_ring *rings)
+{
+	unsigned int r;
+
+	if (!rings)
+		return;
+
+	for (r = 0; r < nn->num_tx_rings; r++)
+		nfp_net_tx_ring_free(&rings[r]);
+
+	kfree(rings);
+}
+
 /**
  * nfp_net_rx_ring_free() - Free resources allocated to a RX ring
  * @rx_ring:  RX ring to free
@@ -1558,6 +1611,9 @@ nfp_net_shadow_rx_rings_free(struct nfp_net *nn, struct nfp_net_rx_ring *rings)
 {
 	unsigned int r;
 
+	if (!rings)
+		return;
+
 	for (r = 0; r < nn->num_r_vecs; r++) {
 		nfp_net_rx_ring_bufs_free(nn, &rings[r]);
 		nfp_net_rx_ring_free(&rings[r]);
@@ -2100,6 +2156,79 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 	return err;
 }
 
+int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
+{
+	struct nfp_net_tx_ring *tx_rings = NULL;
+	struct nfp_net_rx_ring *rx_rings = NULL;
+	u32 old_rxd_cnt, old_txd_cnt;
+	int err, err2;
+
+	if (!(nn->ctrl & NFP_NET_CFG_CTRL_ENABLE)) {
+		nn->rxd_cnt = rxd_cnt;
+		nn->txd_cnt = txd_cnt;
+		return 0;
+	}
+
+	old_rxd_cnt = nn->rxd_cnt;
+	old_txd_cnt = nn->txd_cnt;
+
+	/* Prepare new rings */
+	if (nn->rxd_cnt != rxd_cnt) {
+		rx_rings = nfp_net_shadow_rx_rings_prepare(nn, nn->fl_bufsz,
+							   rxd_cnt);
+		if (!rx_rings)
+			return -ENOMEM;
+	}
+	if (nn->txd_cnt != txd_cnt) {
+		tx_rings = nfp_net_shadow_tx_rings_prepare(nn, txd_cnt);
+		if (!tx_rings) {
+			nfp_net_shadow_rx_rings_free(nn, rx_rings);
+			return -ENOMEM;
+		}
+	}
+
+	/* Stop device, swap in new rings, try to start the device */
+	nfp_net_close_stack(nn);
+	nfp_net_clear_config_and_disable(nn);
+
+	if (rx_rings)
+		rx_rings = nfp_net_shadow_rx_rings_swap(nn, rx_rings);
+	if (tx_rings)
+		tx_rings = nfp_net_shadow_tx_rings_swap(nn, tx_rings);
+
+	nn->rxd_cnt = rxd_cnt;
+	nn->txd_cnt = txd_cnt;
+
+	err = nfp_net_set_config_and_enable(nn);
+	if (err) {
+		/* Try with old configuration and old rings */
+		if (rx_rings)
+			rx_rings = nfp_net_shadow_rx_rings_swap(nn, rx_rings);
+		if (tx_rings)
+			tx_rings = nfp_net_shadow_tx_rings_swap(nn, tx_rings);
+
+		nn->rxd_cnt = old_rxd_cnt;
+		nn->txd_cnt = old_txd_cnt;
+
+		err2 = nfp_net_set_config_and_enable(nn);
+		if (err2) {
+			nn_err(nn, "Can't restore ring config - FW communication failed (%d,%d)\n",
+			       err, err2);
+			nfp_net_shadow_rx_rings_free(nn, rx_rings);
+			nfp_net_shadow_tx_rings_free(nn, tx_rings);
+			nfp_net_close_free_all(nn);
+			return err2;
+		}
+	}
+
+	nfp_net_shadow_rx_rings_free(nn, rx_rings);
+	nfp_net_shadow_tx_rings_free(nn, tx_rings);
+
+	nfp_net_open_stack(nn);
+
+	return err;
+}
+
 static struct rtnl_link_stats64 *nfp_net_stat64(struct net_device *netdev,
 						struct rtnl_link_stats64 *stats)
 {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 9a4084a68db5..ccfef1f17627 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -153,37 +153,25 @@ static int nfp_net_set_ringparam(struct net_device *netdev,
 	struct nfp_net *nn = netdev_priv(netdev);
 	u32 rxd_cnt, txd_cnt;
 
-	if (netif_running(netdev)) {
-		/* Some NIC drivers allow reconfiguration on the fly,
-		 * some down the interface, change and then up it
-		 * again.  For now we don't allow changes when the
-		 * device is up.
-		 */
-		nn_warn(nn, "Can't change rings while device is up\n");
-		return -EBUSY;
-	}
-
 	/* We don't have separate queues/rings for small/large frames. */
 	if (ring->rx_mini_pending || ring->rx_jumbo_pending)
 		return -EINVAL;
 
 	/* Round up to supported values */
 	rxd_cnt = roundup_pow_of_two(ring->rx_pending);
-	rxd_cnt = max_t(u32, rxd_cnt, NFP_NET_MIN_RX_DESCS);
-	rxd_cnt = min_t(u32, rxd_cnt, NFP_NET_MAX_RX_DESCS);
-
 	txd_cnt = roundup_pow_of_two(ring->tx_pending);
-	txd_cnt = max_t(u32, txd_cnt, NFP_NET_MIN_TX_DESCS);
-	txd_cnt = min_t(u32, txd_cnt, NFP_NET_MAX_TX_DESCS);
 
-	if (nn->rxd_cnt != rxd_cnt || nn->txd_cnt != txd_cnt)
-		nn_dbg(nn, "Change ring size: RxQ %u->%u, TxQ %u->%u\n",
-		       nn->rxd_cnt, rxd_cnt, nn->txd_cnt, txd_cnt);
+	if (rxd_cnt < NFP_NET_MIN_RX_DESCS || rxd_cnt > NFP_NET_MAX_RX_DESCS ||
+	    txd_cnt < NFP_NET_MIN_TX_DESCS || txd_cnt > NFP_NET_MAX_TX_DESCS)
+		return -EINVAL;
 
-	nn->rxd_cnt = rxd_cnt;
-	nn->txd_cnt = txd_cnt;
+	if (nn->rxd_cnt == rxd_cnt && nn->txd_cnt == txd_cnt)
+		return 0;
 
-	return 0;
+	nn_dbg(nn, "Change ring size: RxQ %u->%u, TxQ %u->%u\n",
+	       nn->rxd_cnt, rxd_cnt, nn->txd_cnt, txd_cnt);
+
+	return nfp_net_set_ring_size(nn, rxd_cnt, txd_cnt);
 }
 
 static void nfp_net_get_strings(struct net_device *netdev,
-- 
1.9.1
