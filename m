From: Venkat Venkatsubra <venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] IB/ipoib: order:1 failure in ipoib_cm_alloc_rx_skb causes
	softlockup
Date: Sat, 27 Sep 2014 11:20:34 -0700
Message-ID: <20140927182034.GA13698@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In ipoib_cm_alloc_rx_skb
  skb = dev_alloc_skb(IPOIB_CM_HEAD_SIZE + 12);
results in order:1 allocation because IPOIB_CM_HEAD_SIZE is defined as:
	IPOIB_ENCAP_LEN     = 4,
	IPOIB_CM_MTU  = 0x10000 - 0x10, /* padding to align header to 16 */
	IPOIB_CM_BUF_SIZE	= IPOIB_CM_MTU  + IPOIB_ENCAP_LEN,
	IPOIB_CM_HEAD_SIZE  = IPOIB_CM_BUF_SIZE % PAGE_SIZE,

For a 4Kbytes PAGE_SIZE IPOIB_CM_HEAD_SIZE ends up as
(65536 - 16 + 4) % 4096 = 4084 bytes resulting in
dev_alloc_skb(4084 + 12) or dev_alloc_skb(4096) or order:1 allocation.

This fix avoids this by redefining IPOIB_CM_HEAD_SIZE to whatever maximum
that can fit in a order:0 allocation and adjusting number of scatter/gather
elements to accommodate the rest of the bytes.

IPOIB_CM_RX_SG is incremented by 1 to accommodate one extra SG element.

Since using NET_SKB_PAD in IPOIB_CM_HEAD_SIZE now gives the below
compilation error due to max()
"braced-group within expression allowed only inside a function"
actual number of SG elements used is now computed in a variable.

Here is a stack trace of an order:1 failure:
 kswapd0: page allocation failure. order:1, mode:0x20
 Pid: 273, comm: kswapd0 Not tainted 2.6.32-400.11.1.el5uek #1
 Call Trace:
  <IRQ>  [<ffffffff810ddf74>] __alloc_pages_nodemask+0x524/0x595
  [<ffffffff8110da3f>] kmem_getpages+0x4f/0xf4
  [<ffffffff8110dc3c>] fallback_alloc+0x158/0x1ce
  [<ffffffff8110ddd3>] ____cache_alloc_node+0x121/0x134
  [<ffffffff8110e3f3>] kmem_cache_alloc_node_notrace+0x84/0xb9
  [<ffffffff8110e46e>] __kmalloc_node+0x46/0x73
  [<ffffffff813b9aa8>] ? __alloc_skb+0x72/0x13d
  [<ffffffff813b9aa8>] __alloc_skb+0x72/0x13d
  [<ffffffff813b9bdb>] alloc_skb+0x13/0x15
  [<ffffffff813b9f11>] dev_alloc_skb+0x1b/0x38
  [<ffffffffa029e722>] ipoib_cm_alloc_rx_skb+0x31/0x1de [ib_ipoib]
  [<ffffffffa029fd04>] ipoib_cm_handle_rx_wc+0x3a1/0x5b8 [ib_ipoib]
  [<ffffffffa0191bdc>] ? mlx4_ib_free_srq_wqe+0x27/0x54 [mlx4_ib]
  [<ffffffffa01894d4>] ? mlx4_ib_poll_cq+0x620/0x65e [mlx4_ib]
  [<ffffffff813b9015>] ? __kfree_skb+0x79/0x7e
  [<ffffffffa029e9f7>] ? netif_tx_lock+0x44/0x71 [ib_ipoib]
  [<ffffffffa029ae97>] ipoib_poll+0x87/0x128 [ib_ipoib]
  [<ffffffff813c4b69>] net_rx_action+0xc6/0x1cd
  [<ffffffff8105e8cd>] __do_softirq+0xd7/0x19e
  [<ffffffff810aefdc>] ? handle_IRQ_event+0x66/0x120
  [<ffffffff81012eec>] call_softirq+0x1c/0x30
  [<ffffffff81014695>] do_softirq+0x46/0x89
  [<ffffffff8105e752>] irq_exit+0x3b/0x7a
  [<ffffffff8145bea1>] do_IRQ+0x99/0xb0
  [<ffffffff81012713>] ret_from_intr+0x0/0x11
  <EOI>  [<ffffffff812379a3>] ? radix_tree_delete+0x8f/0x194
  [<ffffffffa03693b3>] ? __nfs_access_zap_cache+0x75/0xb0 [nfs]
  [<ffffffff81207d05>] ? ima_inode_free+0x35/0x55
  [<ffffffff8112fd9c>] ? __destroy_inode+0x26/0x66
  [<ffffffff8112fdf2>] ? destroy_inode+0x16/0x44
  [<ffffffff81130074>] ? dispose_list+0xb2/0xe1
  [<ffffffff81130251>] ? shrink_icache_memory+0x1ae/0x1e0
  [<ffffffff810e3f83>] ? shrink_slab+0xe1/0x153
  [<ffffffff810e5063>] ? kswapd+0x3dd/0x516
  [<ffffffff810e26f3>] ? isolate_pages_global+0x0/0x1ba
  [<ffffffff810432be>] ? need_resched+0x23/0x2d
  [<ffffffff81077030>] ? autoremove_wake_function+0x0/0x3d
  [<ffffffff810e4c86>] ? kswapd+0x0/0x516
  [<ffffffff81076c87>] ? kthread+0x6e/0x76
  [<ffffffff81012dea>] ? child_rip+0xa/0x20
  [<ffffffff81076c19>] ? kthread+0x0/0x76
  [<ffffffff81012de0>] ? child_rip+0x0/0x20

Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/ulp/ipoib/ipoib.h      | 11 +++++++++--
 drivers/infiniband/ulp/ipoib/ipoib_cm.c   | 21 +++++++++++++--------
 drivers/infiniband/ulp/ipoib/ipoib_main.c |  7 ++++++-
 3 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index 3edce61..e0b5a63 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -61,6 +61,11 @@ enum ipoib_flush_level {
 	IPOIB_FLUSH_HEAVY
 };
 
+/* 12 bytes added to align the IP header to a multiple of 16 bytes
+ * after IPoIB adds 4 byte header.
+ */
+#define	IPOIB_CM_HEAD_SIZE SKB_MAX_HEAD(NET_SKB_PAD + 12)
+
 enum {
 	IPOIB_ENCAP_LEN		  = 4,
 
@@ -69,8 +74,8 @@ enum {
 
 	IPOIB_CM_MTU		  = 0x10000 - 0x10, /* padding to align header to 16 */
 	IPOIB_CM_BUF_SIZE	  = IPOIB_CM_MTU  + IPOIB_ENCAP_LEN,
-	IPOIB_CM_HEAD_SIZE	  = IPOIB_CM_BUF_SIZE % PAGE_SIZE,
-	IPOIB_CM_RX_SG		  = ALIGN(IPOIB_CM_BUF_SIZE, PAGE_SIZE) / PAGE_SIZE,
+	/* +1 to accommodate residual data in the last SG element */
+	IPOIB_CM_RX_SG	    = ALIGN(IPOIB_CM_BUF_SIZE, PAGE_SIZE)/PAGE_SIZE + 1,
 	IPOIB_RX_RING_SIZE	  = 256,
 	IPOIB_TX_RING_SIZE	  = 128,
 	IPOIB_MAX_QUEUE_SIZE	  = 8192,
@@ -543,6 +548,8 @@ int ipoib_set_dev_features(struct ipoib_dev_priv *priv, struct ib_device *hca);
 /* We don't support UC connections at the moment */
 #define IPOIB_CM_SUPPORTED(ha)   (ha[0] & (IPOIB_FLAGS_RC))
 
+extern int ipoib_cm_rx_sg;
+
 #ifdef CONFIG_INFINIBAND_IPOIB_CM
 
 extern int ipoib_max_conn_qp;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 933efce..0b5154f6 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -122,13 +122,13 @@ static int ipoib_cm_post_receive_nonsrq(struct net_device *dev,
 
 	wr->wr_id = id | IPOIB_OP_CM | IPOIB_OP_RECV;
 
-	for (i = 0; i < IPOIB_CM_RX_SG; ++i)
+	for (i = 0; i < ipoib_cm_rx_sg; ++i)
 		sge[i].addr = rx->rx_ring[id].mapping[i];
 
 	ret = ib_post_recv(rx->qp, wr, &bad_wr);
 	if (unlikely(ret)) {
 		ipoib_warn(priv, "post recv failed for buf %d (%d)\n", id, ret);
-		ipoib_cm_dma_unmap_rx(priv, IPOIB_CM_RX_SG - 1,
+		ipoib_cm_dma_unmap_rx(priv, ipoib_cm_rx_sg - 1,
 				      rx->rx_ring[id].mapping);
 		dev_kfree_skb_any(rx->rx_ring[id].skb);
 		rx->rx_ring[id].skb = NULL;
@@ -199,7 +199,7 @@ static void ipoib_cm_free_rx_ring(struct net_device *dev,
 
 	for (i = 0; i < ipoib_recvq_size; ++i)
 		if (rx_ring[i].skb) {
-			ipoib_cm_dma_unmap_rx(priv, IPOIB_CM_RX_SG - 1,
+			ipoib_cm_dma_unmap_rx(priv, ipoib_cm_rx_sg - 1,
 					      rx_ring[i].mapping);
 			dev_kfree_skb_any(rx_ring[i].skb);
 		}
@@ -263,7 +263,7 @@ static struct ib_qp *ipoib_cm_create_rx_qp(struct net_device *dev,
 
 	if (!ipoib_cm_has_srq(dev)) {
 		attr.cap.max_recv_wr  = ipoib_recvq_size;
-		attr.cap.max_recv_sge = IPOIB_CM_RX_SG;
+		attr.cap.max_recv_sge = ipoib_cm_rx_sg;
 	}
 
 	return ib_create_qp(priv->pd, &attr);
@@ -382,7 +382,8 @@ static int ipoib_cm_nonsrq_init_rx(struct net_device *dev, struct ib_cm_id *cm_i
 	spin_unlock_irq(&priv->lock);
 
 	for (i = 0; i < ipoib_recvq_size; ++i) {
-		if (!ipoib_cm_alloc_rx_skb(dev, rx->rx_ring, i, IPOIB_CM_RX_SG - 1,
+		if (!ipoib_cm_alloc_rx_skb(dev, rx->rx_ring, i,
+					   ipoib_cm_rx_sg - 1,
 					   rx->rx_ring[i].mapping,
 					   GFP_KERNEL)) {
 			ipoib_warn(priv, "failed to allocate receive buffer %d\n", i);
@@ -1553,16 +1554,20 @@ int ipoib_cm_dev_init(struct net_device *dev)
 
 	ipoib_dbg(priv, "max_srq_sge=%d\n", attr.max_srq_sge);
 
-	attr.max_srq_sge = min_t(int, IPOIB_CM_RX_SG, attr.max_srq_sge);
+	attr.max_srq_sge = min_t(int, ipoib_cm_rx_sg, attr.max_srq_sge);
 	ipoib_cm_create_srq(dev, attr.max_srq_sge);
 	if (ipoib_cm_has_srq(dev)) {
-		priv->cm.max_cm_mtu = attr.max_srq_sge * PAGE_SIZE - 0x10;
+		int no_skb_frags = attr.max_srq_sge - 1;
+		u32 maxmtu;
+
+		maxmtu = no_skb_frags * PAGE_SIZE + IPOIB_CM_HEAD_SIZE - 0x10;
+		priv->cm.max_cm_mtu = min_t(int, maxmtu, IPOIB_CM_MTU);
 		priv->cm.num_frags  = attr.max_srq_sge;
 		ipoib_dbg(priv, "max_cm_mtu = 0x%x, num_frags=%d\n",
 			  priv->cm.max_cm_mtu, priv->cm.num_frags);
 	} else {
 		priv->cm.max_cm_mtu = IPOIB_CM_MTU;
-		priv->cm.num_frags  = IPOIB_CM_RX_SG;
+		priv->cm.num_frags  = ipoib_cm_rx_sg;
 	}
 
 	ipoib_cm_init_rx_wr(dev, &priv->cm.rx_wr, priv->cm.rx_sge);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 1310acf..50fb941 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -73,6 +73,8 @@ module_param_named(debug_level, ipoib_debug_level, int, 0644);
 MODULE_PARM_DESC(debug_level, "Enable debug tracing if > 0");
 #endif
 
+int	ipoib_cm_rx_sg;
+
 struct ipoib_path_iter {
 	struct net_device *dev;
 	struct ipoib_path  path;
@@ -1257,7 +1259,6 @@ static void ipoib_neigh_hash_uninit(struct net_device *dev)
 	wait_for_completion(&priv->ntbl.deleted);
 }
 
-
 int ipoib_dev_init(struct net_device *dev, struct ib_device *ca, int port)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
@@ -1719,6 +1720,10 @@ static void ipoib_remove_one(struct ib_device *device)
 static int __init ipoib_init_module(void)
 {
 	int ret;
+	int ipoib_cm_sg_len;
+
+	ipoib_cm_sg_len = IPOIB_CM_BUF_SIZE - IPOIB_CM_HEAD_SIZE;
+	ipoib_cm_rx_sg = ALIGN(ipoib_cm_sg_len, PAGE_SIZE)/PAGE_SIZE + 1;
 
 	ipoib_recvq_size = roundup_pow_of_two(ipoib_recvq_size);
 	ipoib_recvq_size = min(ipoib_recvq_size, IPOIB_MAX_QUEUE_SIZE);
-- 
1.8.2.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
