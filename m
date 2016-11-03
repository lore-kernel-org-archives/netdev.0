From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next resend 02/13] nfp: centralize runtime reconfiguration logic
Date: Thu,  3 Nov 2016 17:11:58 +0000
Message-ID: <1478193129-23476-3-git-send-email-jakub.kicinski@netronome.com>
References: <1478193129-23476-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33991 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932390AbcKCRMX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:12:23 -0400
Received: by mail-wm0-f46.google.com with SMTP id u144so4843228wmu.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 10:12:22 -0700 (PDT)
In-Reply-To: <1478193129-23476-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All functions which need to reallocate ring resources at runtime
look very similar.  Centralize that logic into a separate function.
Encapsulate configuration parameters in a structure.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  10 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 208 +++++++++------------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  19 ++
 3 files changed, 118 insertions(+), 119 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index e8713254786b..14b5e21cabf1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -583,6 +583,12 @@ struct nfp_net {
 	struct dentry *debugfs_dir;
 };
 
+struct nfp_net_ring_set {
+	unsigned int mtu;
+	unsigned int dcnt;
+	void *rings;
+};
+
 /* Functions to read/write from/to a BAR
  * Performs any endian conversion necessary.
  */
@@ -771,7 +777,9 @@ struct nfp_net *
 void nfp_net_coalesce_write_cfg(struct nfp_net *nn);
 int nfp_net_irqs_alloc(struct nfp_net *nn);
 void nfp_net_irqs_disable(struct nfp_net *nn);
-int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt);
+int
+nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_ring_set *rx,
+		      struct nfp_net_ring_set *tx);
 
 #ifdef CONFIG_NFP_NET_DEBUG
 void nfp_net_debugfs_create(void);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 97e0bbef13d1..e58532d27c5b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1573,7 +1573,7 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 }
 
 static struct nfp_net_tx_ring *
-nfp_net_shadow_tx_rings_prepare(struct nfp_net *nn, u32 buf_cnt)
+nfp_net_shadow_tx_rings_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
 	struct nfp_net_tx_ring *rings;
 	unsigned int r;
@@ -1585,11 +1585,11 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 	for (r = 0; r < nn->num_tx_rings; r++) {
 		nfp_net_tx_ring_init(&rings[r], nn->tx_rings[r].r_vec, r);
 
-		if (nfp_net_tx_ring_alloc(&rings[r], buf_cnt))
+		if (nfp_net_tx_ring_alloc(&rings[r], s->dcnt))
 			goto err_free_prev;
 	}
 
-	return rings;
+	return s->rings = rings;
 
 err_free_prev:
 	while (r--)
@@ -1598,27 +1598,29 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 	return NULL;
 }
 
-static struct nfp_net_tx_ring *
-nfp_net_shadow_tx_rings_swap(struct nfp_net *nn, struct nfp_net_tx_ring *rings)
+static void
+nfp_net_shadow_tx_rings_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
-	struct nfp_net_tx_ring *old = nn->tx_rings;
+	struct nfp_net_tx_ring *rings = s->rings;
+	struct nfp_net_ring_set new = *s;
 	unsigned int r;
 
+	s->dcnt = nn->txd_cnt;
+	s->rings = nn->tx_rings;
+
 	for (r = 0; r < nn->num_tx_rings; r++)
-		old[r].r_vec->tx_ring = &rings[r];
+		nn->tx_rings[r].r_vec->tx_ring = &rings[r];
 
-	nn->tx_rings = rings;
-	return old;
+	nn->txd_cnt = new.dcnt;
+	nn->tx_rings = new.rings;
 }
 
 static void
-nfp_net_shadow_tx_rings_free(struct nfp_net *nn, struct nfp_net_tx_ring *rings)
+nfp_net_shadow_tx_rings_free(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
+	struct nfp_net_tx_ring *rings = s->rings;
 	unsigned int r;
 
-	if (!rings)
-		return;
-
 	for (r = 0; r < nn->num_tx_rings; r++)
 		nfp_net_tx_ring_free(&rings[r]);
 
@@ -1691,9 +1693,9 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 }
 
 static struct nfp_net_rx_ring *
-nfp_net_shadow_rx_rings_prepare(struct nfp_net *nn, unsigned int fl_bufsz,
-				u32 buf_cnt)
+nfp_net_shadow_rx_rings_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
+	unsigned int fl_bufsz =	nfp_net_calc_fl_bufsz(nn, s->mtu);
 	struct nfp_net_rx_ring *rings;
 	unsigned int r;
 
@@ -1704,14 +1706,14 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 	for (r = 0; r < nn->num_rx_rings; r++) {
 		nfp_net_rx_ring_init(&rings[r], nn->rx_rings[r].r_vec, r);
 
-		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz, buf_cnt))
+		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz, s->dcnt))
 			goto err_free_prev;
 
 		if (nfp_net_rx_ring_bufs_alloc(nn, &rings[r]))
 			goto err_free_ring;
 	}
 
-	return rings;
+	return s->rings = rings;
 
 err_free_prev:
 	while (r--) {
@@ -1723,27 +1725,32 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 	return NULL;
 }
 
-static struct nfp_net_rx_ring *
-nfp_net_shadow_rx_rings_swap(struct nfp_net *nn, struct nfp_net_rx_ring *rings)
+static void
+nfp_net_shadow_rx_rings_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
-	struct nfp_net_rx_ring *old = nn->rx_rings;
+	struct nfp_net_rx_ring *rings = s->rings;
+	struct nfp_net_ring_set new = *s;
 	unsigned int r;
 
+	s->mtu = nn->netdev->mtu;
+	s->dcnt = nn->rxd_cnt;
+	s->rings = nn->rx_rings;
+
 	for (r = 0; r < nn->num_rx_rings; r++)
-		old[r].r_vec->rx_ring = &rings[r];
+		nn->rx_rings[r].r_vec->rx_ring = &rings[r];
 
-	nn->rx_rings = rings;
-	return old;
+	nn->netdev->mtu = new.mtu;
+	nn->fl_bufsz = nfp_net_calc_fl_bufsz(nn, new.mtu);
+	nn->rxd_cnt = new.dcnt;
+	nn->rx_rings = new.rings;
 }
 
 static void
-nfp_net_shadow_rx_rings_free(struct nfp_net *nn, struct nfp_net_rx_ring *rings)
+nfp_net_shadow_rx_rings_free(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
+	struct nfp_net_rx_ring *rings = s->rings;
 	unsigned int r;
 
-	if (!rings)
-		return;
-
 	for (r = 0; r < nn->num_rx_rings; r++) {
 		nfp_net_rx_ring_bufs_free(nn, &rings[r]);
 		nfp_net_rx_ring_free(&rings[r]);
@@ -2255,89 +2262,50 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 	nn->ctrl = new_ctrl;
 }
 
-static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
+static int
+nfp_net_ring_swap_enable(struct nfp_net *nn,
+			 struct nfp_net_ring_set *rx,
+			 struct nfp_net_ring_set *tx)
 {
-	unsigned int old_mtu, old_fl_bufsz, new_fl_bufsz;
-	struct nfp_net *nn = netdev_priv(netdev);
-	struct nfp_net_rx_ring *tmp_rings;
-	int err;
-
-	old_mtu = netdev->mtu;
-	old_fl_bufsz = nn->fl_bufsz;
-	new_fl_bufsz = nfp_net_calc_fl_bufsz(nn, new_mtu);
-
-	if (!netif_running(netdev)) {
-		netdev->mtu = new_mtu;
-		nn->fl_bufsz = new_fl_bufsz;
-		return 0;
-	}
-
-	/* Prepare new rings */
-	tmp_rings = nfp_net_shadow_rx_rings_prepare(nn, new_fl_bufsz,
-						    nn->rxd_cnt);
-	if (!tmp_rings)
-		return -ENOMEM;
-
-	/* Stop device, swap in new rings, try to start the firmware */
-	nfp_net_close_stack(nn);
-	nfp_net_clear_config_and_disable(nn);
-
-	tmp_rings = nfp_net_shadow_rx_rings_swap(nn, tmp_rings);
-
-	netdev->mtu = new_mtu;
-	nn->fl_bufsz = new_fl_bufsz;
-
-	err = nfp_net_set_config_and_enable(nn);
-	if (err) {
-		const int err_new = err;
+	if (rx)
+		nfp_net_shadow_rx_rings_swap(nn, rx);
+	if (tx)
+		nfp_net_shadow_tx_rings_swap(nn, tx);
 
-		/* Try with old configuration and old rings */
-		tmp_rings = nfp_net_shadow_rx_rings_swap(nn, tmp_rings);
-
-		netdev->mtu = old_mtu;
-		nn->fl_bufsz = old_fl_bufsz;
-
-		err = __nfp_net_set_config_and_enable(nn);
-		if (err)
-			nn_err(nn, "Can't restore MTU - FW communication failed (%d,%d)\n",
-			       err_new, err);
-	}
-
-	nfp_net_shadow_rx_rings_free(nn, tmp_rings);
-
-	nfp_net_open_stack(nn);
+	return __nfp_net_set_config_and_enable(nn);
+}
 
-	return err;
+static void
+nfp_net_ring_reconfig_down(struct nfp_net *nn,
+			   struct nfp_net_ring_set *rx,
+			   struct nfp_net_ring_set *tx)
+{
+	nn->netdev->mtu = rx ? rx->mtu : nn->netdev->mtu;
+	nn->fl_bufsz = nfp_net_calc_fl_bufsz(nn, nn->netdev->mtu);
+	nn->rxd_cnt = rx ? rx->dcnt : nn->rxd_cnt;
+	nn->txd_cnt = tx ? tx->dcnt : nn->txd_cnt;
 }
 
-int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
+int
+nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_ring_set *rx,
+		      struct nfp_net_ring_set *tx)
 {
-	struct nfp_net_tx_ring *tx_rings = NULL;
-	struct nfp_net_rx_ring *rx_rings = NULL;
-	u32 old_rxd_cnt, old_txd_cnt;
 	int err;
 
 	if (!netif_running(nn->netdev)) {
-		nn->rxd_cnt = rxd_cnt;
-		nn->txd_cnt = txd_cnt;
+		nfp_net_ring_reconfig_down(nn, rx, tx);
 		return 0;
 	}
 
-	old_rxd_cnt = nn->rxd_cnt;
-	old_txd_cnt = nn->txd_cnt;
-
 	/* Prepare new rings */
-	if (nn->rxd_cnt != rxd_cnt) {
-		rx_rings = nfp_net_shadow_rx_rings_prepare(nn, nn->fl_bufsz,
-							   rxd_cnt);
-		if (!rx_rings)
+	if (rx) {
+		if (!nfp_net_shadow_rx_rings_prepare(nn, rx))
 			return -ENOMEM;
 	}
-	if (nn->txd_cnt != txd_cnt) {
-		tx_rings = nfp_net_shadow_tx_rings_prepare(nn, txd_cnt);
-		if (!tx_rings) {
-			nfp_net_shadow_rx_rings_free(nn, rx_rings);
-			return -ENOMEM;
+	if (tx) {
+		if (!nfp_net_shadow_tx_rings_prepare(nn, tx)) {
+			err = -ENOMEM;
+			goto err_free_rx;
 		}
 	}
 
@@ -2345,39 +2313,43 @@ int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
 	nfp_net_close_stack(nn);
 	nfp_net_clear_config_and_disable(nn);
 
-	if (rx_rings)
-		rx_rings = nfp_net_shadow_rx_rings_swap(nn, rx_rings);
-	if (tx_rings)
-		tx_rings = nfp_net_shadow_tx_rings_swap(nn, tx_rings);
-
-	nn->rxd_cnt = rxd_cnt;
-	nn->txd_cnt = txd_cnt;
-
-	err = nfp_net_set_config_and_enable(nn);
+	err = nfp_net_ring_swap_enable(nn, rx, tx);
 	if (err) {
-		const int err_new = err;
-
-		/* Try with old configuration and old rings */
-		if (rx_rings)
-			rx_rings = nfp_net_shadow_rx_rings_swap(nn, rx_rings);
-		if (tx_rings)
-			tx_rings = nfp_net_shadow_tx_rings_swap(nn, tx_rings);
+		int err2;
 
-		nn->rxd_cnt = old_rxd_cnt;
-		nn->txd_cnt = old_txd_cnt;
+		nfp_net_clear_config_and_disable(nn);
 
-		err = __nfp_net_set_config_and_enable(nn);
-		if (err)
+		/* Try with old configuration and old rings */
+		err2 = nfp_net_ring_swap_enable(nn, rx, tx);
+		if (err2)
 			nn_err(nn, "Can't restore ring config - FW communication failed (%d,%d)\n",
-			       err_new, err);
+			       err, err2);
 	}
 
-	nfp_net_shadow_rx_rings_free(nn, rx_rings);
-	nfp_net_shadow_tx_rings_free(nn, tx_rings);
+	if (rx)
+		nfp_net_shadow_rx_rings_free(nn, rx);
+	if (tx)
+		nfp_net_shadow_tx_rings_free(nn, tx);
 
 	nfp_net_open_stack(nn);
 
 	return err;
+
+err_free_rx:
+	if (rx)
+		nfp_net_shadow_rx_rings_free(nn, rx);
+	return err;
+}
+
+static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	struct nfp_net_ring_set rx = {
+		.mtu = new_mtu,
+		.dcnt = nn->rxd_cnt,
+	};
+
+	return nfp_net_ring_reconfig(nn, &rx, NULL);
 }
 
 static struct rtnl_link_stats64 *nfp_net_stat64(struct net_device *netdev,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index a7386d1b2883..3f48256dc03c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -158,6 +158,25 @@ static void nfp_net_get_ringparam(struct net_device *netdev,
 	ring->tx_pending = nn->txd_cnt;
 }
 
+static int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
+{
+	struct nfp_net_ring_set *reconfig_rx = NULL, *reconfig_tx = NULL;
+	struct nfp_net_ring_set rx = {
+		.mtu = nn->netdev->mtu,
+		.dcnt = rxd_cnt,
+	};
+	struct nfp_net_ring_set tx = {
+		.dcnt = txd_cnt,
+	};
+
+	if (nn->rxd_cnt != rxd_cnt)
+		reconfig_rx = &rx;
+	if (nn->txd_cnt != txd_cnt)
+		reconfig_tx = &tx;
+
+	return nfp_net_ring_reconfig(nn, reconfig_rx, reconfig_tx);
+}
+
 static int nfp_net_set_ringparam(struct net_device *netdev,
 				 struct ethtool_ringparam *ring)
 {
-- 
1.9.1
