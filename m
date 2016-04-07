From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v5 net-next 05/15] nfp: allocate ring SW structs dynamically
Date: Thu,  7 Apr 2016 19:39:38 +0100
Message-ID: <1460054388-471-6-git-send-email-jakub.kicinski@netronome.com>
References: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:36685 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757077AbcDGSkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 14:40:25 -0400
Received: by mail-qk0-f182.google.com with SMTP id i4so34628849qkc.3
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 11:40:24 -0700 (PDT)
In-Reply-To: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To be able to switch rings more easily on config changes
allocate them dynamically, separately from nfp_net structure.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  6 ++---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 28 +++++++++++++++++-----
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   | 20 +++++++++-------
 3 files changed, 37 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 75683fb26734..fc005c982b7d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -472,6 +472,9 @@ struct nfp_net {
 
 	u32 rx_offset;
 
+	struct nfp_net_tx_ring *tx_rings;
+	struct nfp_net_rx_ring *rx_rings;
+
 #ifdef CONFIG_PCI_IOV
 	unsigned int num_vfs;
 	struct vf_data_storage *vfinfo;
@@ -504,9 +507,6 @@ struct nfp_net {
 	int txd_cnt;
 	int rxd_cnt;
 
-	struct nfp_net_tx_ring tx_rings[NFP_NET_MAX_TX_RINGS];
-	struct nfp_net_rx_ring rx_rings[NFP_NET_MAX_RX_RINGS];
-
 	u8 num_irqs;
 	u8 num_r_vecs;
 	struct nfp_net_r_vector r_vecs[NFP_NET_MAX_TX_RINGS];
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 7cd20fcd631a..66fab7162b7c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -413,12 +413,6 @@ static void nfp_net_irqs_assign(struct net_device *netdev)
 		r_vec->irq_idx = NFP_NET_NON_Q_VECTORS + r;
 
 		cpumask_set_cpu(r, &r_vec->affinity_mask);
-
-		r_vec->tx_ring = &nn->tx_rings[r];
-		nfp_net_tx_ring_init(r_vec->tx_ring, r_vec, r);
-
-		r_vec->rx_ring = &nn->rx_rings[r];
-		nfp_net_rx_ring_init(r_vec->rx_ring, r_vec, r);
 	}
 }
 
@@ -1503,6 +1497,12 @@ nfp_net_prepare_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 	struct msix_entry *entry = &nn->irq_entries[r_vec->irq_idx];
 	int err;
 
+	r_vec->tx_ring = &nn->tx_rings[idx];
+	nfp_net_tx_ring_init(r_vec->tx_ring, r_vec, idx);
+
+	r_vec->rx_ring = &nn->rx_rings[idx];
+	nfp_net_rx_ring_init(r_vec->rx_ring, r_vec, idx);
+
 	snprintf(r_vec->name, sizeof(r_vec->name),
 		 "%s-rxtx-%d", nn->netdev->name, idx);
 	err = request_irq(entry->vector, r_vec->handler, 0, r_vec->name, r_vec);
@@ -1693,6 +1693,15 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 		goto err_free_exn;
 	disable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
 
+	nn->rx_rings = kcalloc(nn->num_rx_rings, sizeof(*nn->rx_rings),
+			       GFP_KERNEL);
+	if (!nn->rx_rings)
+		goto err_free_lsc;
+	nn->tx_rings = kcalloc(nn->num_tx_rings, sizeof(*nn->tx_rings),
+			       GFP_KERNEL);
+	if (!nn->tx_rings)
+		goto err_free_rx_rings;
+
 	for (r = 0; r < nn->num_r_vecs; r++) {
 		err = nfp_net_prepare_vector(nn, &nn->r_vecs[r], r);
 		if (err)
@@ -1807,6 +1816,10 @@ err_free_tx_ring_p:
 err_cleanup_vec_p:
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 	}
+	kfree(nn->tx_rings);
+err_free_rx_rings:
+	kfree(nn->rx_rings);
+err_free_lsc:
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 err_free_exn:
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
@@ -1852,6 +1865,9 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 	}
 
+	kfree(nn->rx_rings);
+	kfree(nn->tx_rings);
+
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index 4c97c713121c..f86a1f13d27b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -40,8 +40,9 @@ static struct dentry *nfp_dir;
 
 static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 {
-	struct nfp_net_rx_ring *rx_ring = file->private;
 	int fl_rd_p, fl_wr_p, rx_rd_p, rx_wr_p, rxd_cnt;
+	struct nfp_net_r_vector *r_vec = file->private;
+	struct nfp_net_rx_ring *rx_ring;
 	struct nfp_net_rx_desc *rxd;
 	struct sk_buff *skb;
 	struct nfp_net *nn;
@@ -49,9 +50,10 @@ static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 
 	rtnl_lock();
 
-	if (!rx_ring->r_vec || !rx_ring->r_vec->nfp_net)
+	if (!r_vec->nfp_net || !r_vec->rx_ring)
 		goto out;
-	nn = rx_ring->r_vec->nfp_net;
+	nn = r_vec->nfp_net;
+	rx_ring = r_vec->rx_ring;
 	if (!netif_running(nn->netdev))
 		goto out;
 
@@ -115,7 +117,8 @@ static const struct file_operations nfp_rx_q_fops = {
 
 static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 {
-	struct nfp_net_tx_ring *tx_ring = file->private;
+	struct nfp_net_r_vector *r_vec = file->private;
+	struct nfp_net_tx_ring *tx_ring;
 	struct nfp_net_tx_desc *txd;
 	int d_rd_p, d_wr_p, txd_cnt;
 	struct sk_buff *skb;
@@ -124,9 +127,10 @@ static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 
 	rtnl_lock();
 
-	if (!tx_ring->r_vec || !tx_ring->r_vec->nfp_net)
+	if (!r_vec->nfp_net || !r_vec->tx_ring)
 		goto out;
-	nn = tx_ring->r_vec->nfp_net;
+	nn = r_vec->nfp_net;
+	tx_ring = r_vec->tx_ring;
 	if (!netif_running(nn->netdev))
 		goto out;
 
@@ -207,13 +211,13 @@ void nfp_net_debugfs_adapter_add(struct nfp_net *nn)
 	for (i = 0; i < nn->num_rx_rings; i++) {
 		sprintf(int_name, "%d", i);
 		debugfs_create_file(int_name, S_IRUSR, rx,
-				    &nn->rx_rings[i], &nfp_rx_q_fops);
+				    &nn->r_vecs[i], &nfp_rx_q_fops);
 	}
 
 	for (i = 0; i < nn->num_tx_rings; i++) {
 		sprintf(int_name, "%d", i);
 		debugfs_create_file(int_name, S_IRUSR, tx,
-				    &nn->tx_rings[i], &nfp_tx_q_fops);
+				    &nn->r_vecs[i], &nfp_tx_q_fops);
 	}
 }
 
-- 
1.9.1
