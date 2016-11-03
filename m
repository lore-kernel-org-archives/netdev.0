From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next resend 08/13] nfp: add support for ethtool .set_channels
Date: Thu,  3 Nov 2016 17:12:04 +0000
Message-ID: <1478193129-23476-9-git-send-email-jakub.kicinski@netronome.com>
References: <1478193129-23476-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:34866 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932778AbcKCRM3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:12:29 -0400
Received: by mail-lf0-f44.google.com with SMTP id b14so44779433lfg.2
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 10:12:28 -0700 (PDT)
In-Reply-To: <1478193129-23476-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow changing the number of rings via ethtool .set_channels API.
Runtime reconfig needs to be extended to handle number of rings.
We need to be able to activate interrupt vectors before rings are
assigned to them.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  1 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 93 +++++++++++++++++-----
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |  4 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 47 +++++++++++
 4 files changed, 123 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 14b5e21cabf1..486e7c6453bc 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -584,6 +584,7 @@ struct nfp_net {
 };
 
 struct nfp_net_ring_set {
+	unsigned int n_rings;
 	unsigned int mtu;
 	unsigned int dcnt;
 	void *rings;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 09cec6e2c6cf..506362729607 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -494,7 +494,7 @@ static void nfp_net_irqs_assign(struct net_device *netdev)
 	nn->lsc_handler = nfp_net_irq_lsc;
 	nn->exn_handler = nfp_net_irq_exn;
 
-	for (r = 0; r < nn->num_r_vecs; r++) {
+	for (r = 0; r < nn->max_r_vecs; r++) {
 		r_vec = &nn->r_vecs[r];
 		r_vec->nfp_net = nn;
 		r_vec->handler = nfp_net_irq_rxtx;
@@ -1578,12 +1578,12 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 	struct nfp_net_tx_ring *rings;
 	unsigned int r;
 
-	rings = kcalloc(nn->num_tx_rings, sizeof(*rings), GFP_KERNEL);
+	rings = kcalloc(s->n_rings, sizeof(*rings), GFP_KERNEL);
 	if (!rings)
 		return NULL;
 
-	for (r = 0; r < nn->num_tx_rings; r++) {
-		nfp_net_tx_ring_init(&rings[r], nn->tx_rings[r].r_vec, r);
+	for (r = 0; r < s->n_rings; r++) {
+		nfp_net_tx_ring_init(&rings[r], &nn->r_vecs[r], r);
 
 		if (nfp_net_tx_ring_alloc(&rings[r], s->dcnt))
 			goto err_free_prev;
@@ -1605,9 +1605,11 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 
 	s->dcnt = nn->txd_cnt;
 	s->rings = nn->tx_rings;
+	s->n_rings = nn->num_tx_rings;
 
 	nn->txd_cnt = new.dcnt;
 	nn->tx_rings = new.rings;
+	nn->num_tx_rings = new.n_rings;
 }
 
 static void
@@ -1616,7 +1618,7 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 	struct nfp_net_tx_ring *rings = s->rings;
 	unsigned int r;
 
-	for (r = 0; r < nn->num_tx_rings; r++)
+	for (r = 0; r < s->n_rings; r++)
 		nfp_net_tx_ring_free(&rings[r]);
 
 	kfree(rings);
@@ -1694,12 +1696,12 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 	struct nfp_net_rx_ring *rings;
 	unsigned int r;
 
-	rings = kcalloc(nn->num_rx_rings, sizeof(*rings), GFP_KERNEL);
+	rings = kcalloc(s->n_rings, sizeof(*rings), GFP_KERNEL);
 	if (!rings)
 		return NULL;
 
-	for (r = 0; r < nn->num_rx_rings; r++) {
-		nfp_net_rx_ring_init(&rings[r], nn->rx_rings[r].r_vec, r);
+	for (r = 0; r < s->n_rings; r++) {
+		nfp_net_rx_ring_init(&rings[r], &nn->r_vecs[r], r);
 
 		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz, s->dcnt))
 			goto err_free_prev;
@@ -1728,11 +1730,13 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 	s->mtu = nn->netdev->mtu;
 	s->dcnt = nn->rxd_cnt;
 	s->rings = nn->rx_rings;
+	s->n_rings = nn->num_rx_rings;
 
 	nn->netdev->mtu = new.mtu;
 	nn->fl_bufsz = nfp_net_calc_fl_bufsz(nn, new.mtu);
 	nn->rxd_cnt = new.dcnt;
 	nn->rx_rings = new.rings;
+	nn->num_rx_rings = new.n_rings;
 }
 
 static void
@@ -1741,7 +1745,7 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 	struct nfp_net_rx_ring *rings = s->rings;
 	unsigned int r;
 
-	for (r = 0; r < nn->num_rx_rings; r++) {
+	for (r = 0; r < s->n_rings; r++) {
 		nfp_net_rx_ring_bufs_free(nn, &rings[r]);
 		nfp_net_rx_ring_free(&rings[r]);
 	}
@@ -1764,19 +1768,20 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 	struct msix_entry *entry = &nn->irq_entries[r_vec->irq_idx];
 	int err;
 
+	/* Setup NAPI */
+	netif_napi_add(nn->netdev, &r_vec->napi,
+		       nfp_net_poll, NAPI_POLL_WEIGHT);
+
 	snprintf(r_vec->name, sizeof(r_vec->name),
 		 "%s-rxtx-%d", nn->netdev->name, idx);
 	err = request_irq(entry->vector, r_vec->handler, 0, r_vec->name, r_vec);
 	if (err) {
+		netif_napi_del(&r_vec->napi);
 		nn_err(nn, "Error requesting IRQ %d\n", entry->vector);
 		return err;
 	}
 	disable_irq(entry->vector);
 
-	/* Setup NAPI */
-	netif_napi_add(nn->netdev, &r_vec->napi,
-		       nfp_net_poll, NAPI_POLL_WEIGHT);
-
 	irq_set_affinity_hint(entry->vector, &r_vec->affinity_mask);
 
 	nn_dbg(nn, "RV%02d: irq=%03d/%03d\n", idx, entry->vector, entry->entry);
@@ -2036,10 +2041,12 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 	struct nfp_net_ring_set rx = {
+		.n_rings = nn->num_rx_rings,
 		.mtu = nn->netdev->mtu,
 		.dcnt = nn->rxd_cnt,
 	};
 	struct nfp_net_ring_set tx = {
+		.n_rings = nn->num_tx_rings,
 		.dcnt = nn->txd_cnt,
 	};
 	int err, r;
@@ -2239,49 +2246,89 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 }
 
 static int
-nfp_net_ring_swap_enable(struct nfp_net *nn,
+nfp_net_ring_swap_enable(struct nfp_net *nn, unsigned int *num_vecs,
 			 struct nfp_net_ring_set *rx,
 			 struct nfp_net_ring_set *tx)
 {
 	unsigned int r;
+	int err;
 
 	if (rx)
 		nfp_net_rx_ring_set_swap(nn, rx);
 	if (tx)
 		nfp_net_tx_ring_set_swap(nn, tx);
 
+	swap(*num_vecs, nn->num_r_vecs);
+
 	for (r = 0; r <	nn->max_r_vecs; r++)
 		nfp_net_vector_assign_rings(nn, &nn->r_vecs[r], r);
 
+	if (nn->netdev->real_num_rx_queues != nn->num_rx_rings) {
+		if (!netif_is_rxfh_configured(nn->netdev))
+			nfp_net_rss_init_itbl(nn);
+
+		err = netif_set_real_num_rx_queues(nn->netdev,
+						   nn->num_rx_rings);
+		if (err)
+			return err;
+	}
+
+	if (nn->netdev->real_num_tx_queues != nn->num_tx_rings) {
+		err = netif_set_real_num_tx_queues(nn->netdev,
+						   nn->num_tx_rings);
+		if (err)
+			return err;
+	}
+
 	return __nfp_net_set_config_and_enable(nn);
 }
 
 static void
 nfp_net_ring_reconfig_down(struct nfp_net *nn,
 			   struct nfp_net_ring_set *rx,
-			   struct nfp_net_ring_set *tx)
+			   struct nfp_net_ring_set *tx,
+			   unsigned int num_vecs)
 {
 	nn->netdev->mtu = rx ? rx->mtu : nn->netdev->mtu;
 	nn->fl_bufsz = nfp_net_calc_fl_bufsz(nn, nn->netdev->mtu);
 	nn->rxd_cnt = rx ? rx->dcnt : nn->rxd_cnt;
 	nn->txd_cnt = tx ? tx->dcnt : nn->txd_cnt;
+	nn->num_rx_rings = rx ? rx->n_rings : nn->num_rx_rings;
+	nn->num_tx_rings = tx ? tx->n_rings : nn->num_tx_rings;
+	nn->num_r_vecs = num_vecs;
+
+	if (!netif_is_rxfh_configured(nn->netdev))
+		nfp_net_rss_init_itbl(nn);
 }
 
 int
 nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_ring_set *rx,
 		      struct nfp_net_ring_set *tx)
 {
+	unsigned int num_vecs, r;
 	int err;
 
+	num_vecs = max(rx ? rx->n_rings : nn->num_rx_rings,
+		       tx ? tx->n_rings : nn->num_tx_rings);
+
 	if (!netif_running(nn->netdev)) {
-		nfp_net_ring_reconfig_down(nn, rx, tx);
+		nfp_net_ring_reconfig_down(nn, rx, tx, num_vecs);
 		return 0;
 	}
 
 	/* Prepare new rings */
+	for (r = nn->num_r_vecs; r < num_vecs; r++) {
+		err = nfp_net_prepare_vector(nn, &nn->r_vecs[r], r);
+		if (err) {
+			num_vecs = r;
+			goto err_cleanup_vecs;
+		}
+	}
 	if (rx) {
-		if (!nfp_net_rx_ring_set_prepare(nn, rx))
-			return -ENOMEM;
+		if (!nfp_net_rx_ring_set_prepare(nn, rx)) {
+			err = -ENOMEM;
+			goto err_cleanup_vecs;
+		}
 	}
 	if (tx) {
 		if (!nfp_net_tx_ring_set_prepare(nn, tx)) {
@@ -2294,18 +2341,20 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 	nfp_net_close_stack(nn);
 	nfp_net_clear_config_and_disable(nn);
 
-	err = nfp_net_ring_swap_enable(nn, rx, tx);
+	err = nfp_net_ring_swap_enable(nn, &num_vecs, rx, tx);
 	if (err) {
 		int err2;
 
 		nfp_net_clear_config_and_disable(nn);
 
 		/* Try with old configuration and old rings */
-		err2 = nfp_net_ring_swap_enable(nn, rx, tx);
+		err2 = nfp_net_ring_swap_enable(nn, &num_vecs, rx, tx);
 		if (err2)
 			nn_err(nn, "Can't restore ring config - FW communication failed (%d,%d)\n",
 			       err, err2);
 	}
+	for (r = num_vecs - 1; r >= nn->num_r_vecs; r--)
+		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 
 	if (rx)
 		nfp_net_rx_ring_set_free(nn, rx);
@@ -2319,6 +2368,9 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 err_free_rx:
 	if (rx)
 		nfp_net_rx_ring_set_free(nn, rx);
+err_cleanup_vecs:
+	for (r = num_vecs - 1; r >= nn->num_r_vecs; r--)
+		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 	return err;
 }
 
@@ -2326,6 +2378,7 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 	struct nfp_net_ring_set rx = {
+		.n_rings = nn->num_rx_rings,
 		.mtu = new_mtu,
 		.dcnt = nn->rxd_cnt,
 	};
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index 180cf70f0093..e90df8145323 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -207,13 +207,13 @@ void nfp_net_debugfs_adapter_add(struct nfp_net *nn)
 	if (IS_ERR_OR_NULL(rx) || IS_ERR_OR_NULL(tx))
 		return;
 
-	for (i = 0; i < nn->num_rx_rings; i++) {
+	for (i = 0; i < min(nn->max_rx_rings, nn->max_r_vecs); i++) {
 		sprintf(int_name, "%d", i);
 		debugfs_create_file(int_name, S_IRUSR, rx,
 				    &nn->r_vecs[i], &nfp_rx_q_fops);
 	}
 
-	for (i = 0; i < nn->num_tx_rings; i++) {
+	for (i = 0; i < min(nn->max_tx_rings, nn->max_r_vecs); i++) {
 		sprintf(int_name, "%d", i);
 		debugfs_create_file(int_name, S_IRUSR, tx,
 				    &nn->r_vecs[i], &nfp_tx_q_fops);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 3f48256dc03c..b87f1b73f200 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -162,10 +162,12 @@ static int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
 {
 	struct nfp_net_ring_set *reconfig_rx = NULL, *reconfig_tx = NULL;
 	struct nfp_net_ring_set rx = {
+		.n_rings = nn->num_rx_rings,
 		.mtu = nn->netdev->mtu,
 		.dcnt = rxd_cnt,
 	};
 	struct nfp_net_ring_set tx = {
+		.n_rings = nn->num_tx_rings,
 		.dcnt = txd_cnt,
 	};
 
@@ -648,6 +650,50 @@ static void nfp_net_get_channels(struct net_device *netdev,
 	channel->other_count = NFP_NET_NON_Q_VECTORS;
 }
 
+static int nfp_net_set_num_rings(struct nfp_net *nn, unsigned int total_rx,
+				 unsigned int total_tx)
+{
+	struct nfp_net_ring_set *reconfig_rx = NULL, *reconfig_tx = NULL;
+	struct nfp_net_ring_set rx = {
+		.n_rings = total_rx,
+		.mtu = nn->netdev->mtu,
+		.dcnt = nn->rxd_cnt,
+	};
+	struct nfp_net_ring_set tx = {
+		.n_rings = total_tx,
+		.dcnt = nn->txd_cnt,
+	};
+
+	if (nn->num_rx_rings != total_rx)
+		reconfig_rx = &rx;
+	if (nn->num_tx_rings != total_tx)
+		reconfig_tx = &tx;
+
+	return nfp_net_ring_reconfig(nn, reconfig_rx, reconfig_tx);
+}
+
+static int nfp_net_set_channels(struct net_device *netdev,
+				struct ethtool_channels *channel)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	unsigned int total_rx, total_tx;
+
+	/* Reject unsupported */
+	if (!channel->combined_count ||
+	    channel->other_count != NFP_NET_NON_Q_VECTORS ||
+	    (channel->rx_count && channel->tx_count))
+		return -EINVAL;
+
+	total_rx = channel->combined_count + channel->rx_count;
+	total_tx = channel->combined_count + channel->tx_count;
+
+	if (total_rx > min(nn->max_rx_rings, nn->max_r_vecs) ||
+	    total_tx > min(nn->max_tx_rings, nn->max_r_vecs))
+		return -EINVAL;
+
+	return nfp_net_set_num_rings(nn, total_rx, total_tx);
+}
+
 static const struct ethtool_ops nfp_net_ethtool_ops = {
 	.get_drvinfo		= nfp_net_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
@@ -667,6 +713,7 @@ static void nfp_net_get_channels(struct net_device *netdev,
 	.get_coalesce           = nfp_net_get_coalesce,
 	.set_coalesce           = nfp_net_set_coalesce,
 	.get_channels		= nfp_net_get_channels,
+	.set_channels		= nfp_net_set_channels,
 };
 
 void nfp_net_set_ethtool_ops(struct net_device *netdev)
-- 
1.9.1
