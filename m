From: Shrijeet Mukherjee <shrijeet@gmail.com>
Subject: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Sat, 22 Oct 2016 04:07:23 +0000
Message-ID: <1477109243-29520-1-git-send-email-shrijeet@gmail.com>
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: mst@redhat.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34359 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbcJVEHj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 00:07:39 -0400
Received: by mail-pf0-f194.google.com with SMTP id 128so10275969pfz.1
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 21:07:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for xdp ndo and also inserts the xdp program
call into the merged RX buffers and big buffers paths

* The small packet skb receive is skipped for now
* No TX for now

Signed-off-by: Shrijeet Mukherjee <shrijeet@gmail.com>
---
 drivers/net/virtio_net.c | 133 ++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 127 insertions(+), 6 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fad84f3..d5af3f7 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -22,6 +22,7 @@
 #include <linux/module.h>
 #include <linux/virtio.h>
 #include <linux/virtio_net.h>
+#include <linux/bpf.h>
 #include <linux/scatterlist.h>
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
@@ -81,6 +82,8 @@ struct receive_queue {
 
 	struct napi_struct napi;
 
+	struct bpf_prog *xdp_prog;
+
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
@@ -324,6 +327,51 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	return skb;
 }
 
+/* this function is not called from the receive_buf path directly as
+ * we want to use the page model for rx merge buffer and big buffers
+ * and not use the fast path for driving skb's around
+ */
+static inline u32 do_xdp_prog(struct virtnet_info *vi,
+			      struct receive_queue *rq,
+			      void *buf, int offset, int len)
+{
+	struct bpf_prog *xdp_prog;
+	struct xdp_buff xdp;
+	int hdr_padded_len;
+	u32 act;
+
+	/* A bpf program gets first chance to drop the packet. It may
+	 * read bytes but not past the end of the frag.
+	 */
+
+	xdp_prog = rcu_dereference(rq->xdp_prog);
+	if (xdp_prog) {
+		if (vi->mergeable_rx_bufs)
+			hdr_padded_len = sizeof(
+				struct virtio_net_hdr_mrg_rxbuf);
+		else
+			hdr_padded_len = sizeof(struct padded_vnet_hdr);
+
+		buf = (void *)((unsigned long)buf + offset + hdr_padded_len);
+
+		xdp.data = buf;
+		xdp.data_end = xdp.data + len;
+
+		act = bpf_prog_run_xdp(xdp_prog, &xdp);
+		switch (act) {
+		case XDP_PASS:
+			return XDP_PASS;
+		case XDP_TX:
+		case XDP_ABORTED:
+		case XDP_DROP:
+			return XDP_DROP;
+		default:
+			bpf_warn_invalid_xdp_action(act);
+		}
+	}
+	return XDP_PASS;
+}
+
 static struct sk_buff *receive_small(struct virtnet_info *vi, void *buf, unsigned int len)
 {
 	struct sk_buff * skb = buf;
@@ -341,8 +389,14 @@ static struct sk_buff *receive_big(struct net_device *dev,
 				   unsigned int len)
 {
 	struct page *page = buf;
-	struct sk_buff *skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
+	struct sk_buff *skb;
+	u32 act;
 
+	act = do_xdp_prog(vi, rq, buf, 0, len);
+	if (act == XDP_DROP)
+		goto err;
+
+	skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
 	if (unlikely(!skb))
 		goto err;
 
@@ -366,13 +420,22 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	struct page *page = virt_to_head_page(buf);
 	int offset = buf - page_address(page);
 	unsigned int truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
+	u32 act;
+	struct sk_buff *head_skb, *curr_skb;
 
-	struct sk_buff *head_skb = page_to_skb(vi, rq, page, offset, len,
-					       truesize);
-	struct sk_buff *curr_skb = head_skb;
+	act = do_xdp_prog(vi, rq, buf, offset, len);
+	/* controversial, but alternative is to create an SKB anyway then */
+	if (act == XDP_DROP) {
+		put_page(page);
+		return NULL;
+	}
+
+	head_skb = page_to_skb(vi, rq, page, offset, len, truesize);
+	curr_skb = head_skb;
 
 	if (unlikely(!curr_skb))
 		goto err_skb;
+
 	while (--num_buf) {
 		int num_skb_frags;
 
@@ -388,6 +451,13 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 
 		buf = mergeable_ctx_to_buf_address(ctx);
 		page = virt_to_head_page(buf);
+		offset = buf - page_address(page);
+
+		act = do_xdp_prog(vi, rq, buf, offset, len);
+		if (act != XDP_PASS) {
+			put_page(page);
+			continue;
+		}
 
 		num_skb_frags = skb_shinfo(curr_skb)->nr_frags;
 		if (unlikely(num_skb_frags == MAX_SKB_FRAGS)) {
@@ -409,7 +479,6 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			head_skb->len += len;
 			head_skb->truesize += truesize;
 		}
-		offset = buf - page_address(page);
 		if (skb_can_coalesce(curr_skb, num_skb_frags, page, offset)) {
 			put_page(page);
 			skb_coalesce_rx_frag(curr_skb, num_skb_frags - 1,
@@ -1430,6 +1499,52 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct bpf_prog *old_prog;
+	int i;
+
+	if (prog) {
+		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
+		if (IS_ERR(prog))
+			return PTR_ERR(prog);
+	}
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		old_prog = rcu_dereference(vi->rq[i].xdp_prog);
+		rcu_assign_pointer(vi->rq[i].xdp_prog, prog);
+		if (old_prog)
+			bpf_prog_put(old_prog);
+	}
+
+	return 0;
+}
+
+static int virtnet_xdp_query(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		if (vi->rq[i].xdp_prog)
+			return 1;
+	}
+	return 0;
+}
+
+static int virtnet_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+{
+	switch (xdp->command) {
+	case XDP_SETUP_PROG:
+		return virtnet_xdp_set(dev, xdp->prog);
+	case XDP_QUERY_PROG:
+		return virtnet_xdp_query(dev);
+	default:
+		return -EINVAL;
+	}
+}
+
 static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
@@ -1447,6 +1562,7 @@ static const struct net_device_ops virtnet_netdev = {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= virtnet_busy_poll,
 #endif
+	.ndo_xdp		= virtnet_xdp,
 };
 
 static void virtnet_config_changed_work(struct work_struct *work)
@@ -1503,11 +1619,17 @@ static void virtnet_free_queues(struct virtnet_info *vi)
 
 static void free_receive_bufs(struct virtnet_info *vi)
 {
+	struct bpf_prog *old_prog;
 	int i;
 
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		while (vi->rq[i].pages)
 			__free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
+
+		old_prog = rcu_dereference(vi->rq[i].xdp_prog);
+		RCU_INIT_POINTER(vi->rq[i].xdp_prog, NULL);
+		if (old_prog)
+			bpf_prog_put(old_prog);
 	}
 }
 
@@ -1878,7 +2000,6 @@ static int virtnet_probe(struct virtio_device *vdev)
 		if (virtnet_change_mtu(dev, mtu))
 			__virtio_clear_bit(vdev, VIRTIO_NET_F_MTU);
 	}
-
 	if (vi->any_header_sg)
 		dev->needed_headroom = vi->hdr_len;
 
-- 
2.1.4
