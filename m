From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v5 3/6] virtio_net: Add XDP support
Date: Wed, 07 Dec 2016 12:11:57 -0800
Message-ID: <20161207201157.28121.39934.stgit@john-Precision-Tower-5810>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, brouer@redhat.com
To: daniel@iogearbox.net, mst@redhat.com, shm@cumulusnetworks.com,
        davem@davemloft.net, tgraf@suug.ch, alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35101 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932243AbcLGUNs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 15:13:48 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so24438026pga.2
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 12:12:19 -0800 (PST)
In-Reply-To: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>

This adds XDP support to virtio_net. Some requirements must be
met for XDP to be enabled depending on the mode. First it will
only be supported with LRO disabled so that data is not pushed
across multiple buffers. Second the MTU must be less than a page
size to avoid having to handle XDP across multiple pages.

If mergeable receive is enabled this patch only supports the case
where header and data are in the same buf which we can check when
a packet is received by looking at num_buf. If the num_buf is
greater than 1 and a XDP program is loaded the packet is dropped
and a warning is thrown. When any_header_sg is set this does not
happen and both header and data is put in a single buffer as expected
so we check this when XDP programs are loaded.  Subsequent patches
will process the packet in a degraded mode to ensure connectivity
and correctness is not lost even if backend pushes packets into
multiple buffers.

If big packets mode is enabled and MTU/LRO conditions above are
met then XDP is allowed.

This patch was tested with qemu with vhost=on and vhost=off where
mergeable and big_packet modes were forced via hard coding feature
negotiation. Multiple buffers per packet was forced via a small
test patch to vhost.c in the vhost=on qemu mode.

Suggested-by: Shrijeet Mukherjee <shrijeet@gmail.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |  175 +++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 170 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index a5c47b1..a009299 100644
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
 
+	struct bpf_prog __rcu *xdp_prog;
+
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
@@ -324,6 +327,38 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	return skb;
 }
 
+static u32 do_xdp_prog(struct virtnet_info *vi,
+		       struct bpf_prog *xdp_prog,
+		       struct page *page, int offset, int len)
+{
+	int hdr_padded_len;
+	struct xdp_buff xdp;
+	u32 act;
+	u8 *buf;
+
+	buf = page_address(page) + offset;
+
+	if (vi->mergeable_rx_bufs)
+		hdr_padded_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
+	else
+		hdr_padded_len = sizeof(struct padded_vnet_hdr);
+
+	xdp.data = buf + hdr_padded_len;
+	xdp.data_end = xdp.data + (len - vi->hdr_len);
+
+	act = bpf_prog_run_xdp(xdp_prog, &xdp);
+	switch (act) {
+	case XDP_PASS:
+		return XDP_PASS;
+	default:
+		bpf_warn_invalid_xdp_action(act);
+	case XDP_TX:
+	case XDP_ABORTED:
+	case XDP_DROP:
+		return XDP_DROP;
+	}
+}
+
 static struct sk_buff *receive_small(struct virtnet_info *vi, void *buf, unsigned int len)
 {
 	struct sk_buff * skb = buf;
@@ -340,14 +375,32 @@ static struct sk_buff *receive_big(struct net_device *dev,
 				   void *buf,
 				   unsigned int len)
 {
+	struct bpf_prog *xdp_prog;
 	struct page *page = buf;
-	struct sk_buff *skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
+	struct sk_buff *skb;
 
+	rcu_read_lock();
+	xdp_prog = rcu_dereference(rq->xdp_prog);
+	if (xdp_prog) {
+		struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
+		u32 act;
+
+		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
+			goto err_xdp;
+		act = do_xdp_prog(vi, xdp_prog, page, 0, len);
+		if (act == XDP_DROP)
+			goto err_xdp;
+	}
+	rcu_read_unlock();
+
+	skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
 	if (unlikely(!skb))
 		goto err;
 
 	return skb;
 
+err_xdp:
+	rcu_read_unlock();
 err:
 	dev->stats.rx_dropped++;
 	give_pages(rq, page);
@@ -365,11 +418,42 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	u16 num_buf = virtio16_to_cpu(vi->vdev, hdr->num_buffers);
 	struct page *page = virt_to_head_page(buf);
 	int offset = buf - page_address(page);
-	unsigned int truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
+	struct sk_buff *head_skb, *curr_skb;
+	struct bpf_prog *xdp_prog;
+	unsigned int truesize;
+
+	rcu_read_lock();
+	xdp_prog = rcu_dereference(rq->xdp_prog);
+	if (xdp_prog) {
+		u32 act;
+
+		/* No known backend devices should send packets with
+		 * more than a single buffer when XDP conditions are
+		 * met. However it is not strictly illegal so the case
+		 * is handled as an exception and a warning is thrown.
+		 */
+		if (unlikely(num_buf > 1)) {
+			bpf_warn_invalid_xdp_buffer();
+			goto err_xdp;
+		}
 
-	struct sk_buff *head_skb = page_to_skb(vi, rq, page, offset, len,
-					       truesize);
-	struct sk_buff *curr_skb = head_skb;
+		/* Transient failure which in theory could occur if
+		 * in-flight packets from before XDP was enabled reach
+		 * the receive path after XDP is loaded. In practice I
+		 * was not able to create this condition.
+		 */
+		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
+			goto err_xdp;
+
+		act = do_xdp_prog(vi, xdp_prog, page, offset, len);
+		if (act == XDP_DROP)
+			goto err_xdp;
+	}
+	rcu_read_unlock();
+
+	truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
+	head_skb = page_to_skb(vi, rq, page, offset, len, truesize);
+	curr_skb = head_skb;
 
 	if (unlikely(!curr_skb))
 		goto err_skb;
@@ -423,6 +507,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	ewma_pkt_len_add(&rq->mrg_avg_pkt_len, head_skb->len);
 	return head_skb;
 
+err_xdp:
+	rcu_read_unlock();
 err_skb:
 	put_page(page);
 	while (--num_buf) {
@@ -1328,6 +1414,13 @@ static int virtnet_set_channels(struct net_device *dev,
 	if (queue_pairs > vi->max_queue_pairs || queue_pairs == 0)
 		return -EINVAL;
 
+	/* For now we don't support modifying channels while XDP is loaded
+	 * also when XDP is loaded all RX queues have XDP programs so we only
+	 * need to check a single RX queue.
+	 */
+	if (vi->rq[0].xdp_prog)
+		return -EINVAL;
+
 	get_online_cpus();
 	err = virtnet_set_queues(vi, queue_pairs);
 	if (!err) {
@@ -1449,6 +1542,69 @@ static int virtnet_set_features(struct net_device *netdev,
 	return 0;
 }
 
+static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
+{
+	unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct bpf_prog *old_prog;
+	int i;
+
+	if ((dev->features & NETIF_F_LRO) && prog) {
+		netdev_warn(dev, "can't set XDP while LRO is on, disable LRO first\n");
+		return -EINVAL;
+	}
+
+	if (vi->mergeable_rx_bufs && !vi->any_header_sg) {
+		netdev_warn(dev, "XDP expects header/data in single page\n");
+		return -EINVAL;
+	}
+
+	if (dev->mtu > max_sz) {
+		netdev_warn(dev, "XDP requires MTU less than %lu\n", max_sz);
+		return -EINVAL;
+	}
+
+	if (prog) {
+		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
+		if (IS_ERR(prog))
+			return PTR_ERR(prog);
+	}
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		old_prog = rtnl_dereference(vi->rq[i].xdp_prog);
+		rcu_assign_pointer(vi->rq[i].xdp_prog, prog);
+		if (old_prog)
+			bpf_prog_put(old_prog);
+	}
+
+	return 0;
+}
+
+static bool virtnet_xdp_query(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		if (vi->rq[i].xdp_prog)
+			return true;
+	}
+	return false;
+}
+
+static int virtnet_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+{
+	switch (xdp->command) {
+	case XDP_SETUP_PROG:
+		return virtnet_xdp_set(dev, xdp->prog);
+	case XDP_QUERY_PROG:
+		xdp->prog_attached = virtnet_xdp_query(dev);
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
 static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
@@ -1466,6 +1622,7 @@ static int virtnet_set_features(struct net_device *netdev,
 	.ndo_busy_poll		= virtnet_busy_poll,
 #endif
 	.ndo_set_features	= virtnet_set_features,
+	.ndo_xdp		= virtnet_xdp,
 };
 
 static void virtnet_config_changed_work(struct work_struct *work)
@@ -1527,12 +1684,20 @@ static void virtnet_free_queues(struct virtnet_info *vi)
 
 static void free_receive_bufs(struct virtnet_info *vi)
 {
+	struct bpf_prog *old_prog;
 	int i;
 
+	rtnl_lock();
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		while (vi->rq[i].pages)
 			__free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
+
+		old_prog = rtnl_dereference(vi->rq[i].xdp_prog);
+		RCU_INIT_POINTER(vi->rq[i].xdp_prog, NULL);
+		if (old_prog)
+			bpf_prog_put(old_prog);
 	}
+	rtnl_unlock();
 }
 
 static void free_receive_page_frags(struct virtnet_info *vi)
