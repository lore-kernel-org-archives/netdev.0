From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 3/5] virtio_net: Add XDP support
Date: Sat, 19 Nov 2016 18:50:33 -0800
Message-ID: <20161120025033.19187.11082.stgit@john-Precision-Tower-5810>
References: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bblanco@plumgrid.com,
        john.fastabend@gmail.com, john.r.fastabend@intel.com,
        brouer@redhat.com, tgraf@suug.ch
To: daniel@iogearbox.net, eric.dumazet@gmail.com, mst@redhat.com,
        kubakici@wp.pl, shm@cumulusnetworks.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34897 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753004AbcKTCvB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 21:51:01 -0500
Received: by mail-pf0-f195.google.com with SMTP id i88so15874538pfk.2
        for <netdev@vger.kernel.org>; Sat, 19 Nov 2016 18:51:01 -0800 (PST)
In-Reply-To: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shrijeet Mukherjee <shrijeet@gmail.com>

This adds XDP support to virtio_net. Some requirements must be
met for XDP to be enabled depending on the mode. First it will
only be supported with LRO disabled so that data is not pushed
across multiple buffers. The MTU must be less than a page size
to avoid having to handle XDP across multiple pages.

If mergeable receive is enabled this first series only supports
the case where header and data are in the same buf which we can
check when a packet is received by looking at num_buf. If the
num_buf is greater than 1 and a XDP program is loaded the packet
is dropped and a warning is thrown. When any_header_sg is set this
does not happen and both header and data is put in a single buffer
as expected so we check this when XDP programs are loaded. Note I
have only tested this with Linux vhost backend.

If big packets mode is enabled and MTU/LRO conditions above are
met then XDP is allowed.

A follow on patch can be generated to solve the mergeable receive
case with num_bufs equal to 2. Buffers greater than two may not
be handled has easily.

Suggested-by: Shrijeet Mukherjee <shrijeet@gmail.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |  146 +++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 142 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 8189e5b..8f99a53 100644
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
@@ -340,9 +375,19 @@ static struct sk_buff *receive_big(struct net_device *dev,
 				   void *buf,
 				   unsigned int len)
 {
+	struct bpf_prog *xdp_prog;
 	struct page *page = buf;
-	struct sk_buff *skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
+	struct sk_buff *skb;
 
+	xdp_prog = rcu_dereference_bh(rq->xdp_prog);
+	if (xdp_prog) {
+		u32 act = do_xdp_prog(vi, xdp_prog, page, 0, len);
+
+		if (act == XDP_DROP)
+			goto err;
+	}
+
+	skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
 	if (unlikely(!skb))
 		goto err;
 
@@ -366,10 +411,25 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	struct page *page = virt_to_head_page(buf);
 	int offset = buf - page_address(page);
 	unsigned int truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
+	struct sk_buff *head_skb, *curr_skb;
+	struct bpf_prog *xdp_prog;
 
-	struct sk_buff *head_skb = page_to_skb(vi, rq, page, offset, len,
-					       truesize);
-	struct sk_buff *curr_skb = head_skb;
+	xdp_prog = rcu_dereference_bh(rq->xdp_prog);
+	if (xdp_prog) {
+		u32 act;
+
+		if (num_buf > 1) {
+			bpf_warn_invalid_xdp_buffer();
+			goto err_skb;
+		}
+
+		act = do_xdp_prog(vi, xdp_prog, page, offset, len);
+		if (act == XDP_DROP)
+			goto err_skb;
+	}
+
+	head_skb = page_to_skb(vi, rq, page, offset, len, truesize);
+	curr_skb = head_skb;
 
 	if (unlikely(!curr_skb))
 		goto err_skb;
@@ -1328,6 +1388,13 @@ static int virtnet_set_channels(struct net_device *dev,
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
@@ -1454,6 +1521,68 @@ static int virtnet_set_features(struct net_device *netdev,
 	return 0;
 }
 
+static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
+{
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
+	if (dev->mtu > PAGE_SIZE) {
+		netdev_warn(dev, "XDP requires MTU less than %lu\n", PAGE_SIZE);
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
@@ -1471,6 +1600,7 @@ static int virtnet_set_features(struct net_device *netdev,
 	.ndo_busy_poll		= virtnet_busy_poll,
 #endif
 	.ndo_set_features	= virtnet_set_features,
+	.ndo_xdp		= virtnet_xdp,
 };
 
 static void virtnet_config_changed_work(struct work_struct *work)
@@ -1527,12 +1657,20 @@ static void virtnet_free_queues(struct virtnet_info *vi)
 
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
