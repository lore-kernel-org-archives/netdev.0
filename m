From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC v3 5/8] virt_net: Changes to use generic XDP infrastructure
Date: Tue, 21 Feb 2017 11:34:14 -0800
Message-ID: <20170221193417.3641224-6-tom@herbertland.com>
References: <20170221193417.3641224-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55719 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754098AbdBUTe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 14:34:29 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LJWihV029723
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:29 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28rut5r07b-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:29 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 c2554604f86c11e6aefd0002c9dfb610-6df6a00 for <netdev@vger.kernel.org>; Tue,
 21 Feb 2017 11:34:28 -0800
In-Reply-To: <20170221193417.3641224-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change XDP program management functional interface to correspond to new
XDP API.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/virtio_net.c | 99 +++++++++++++++++++-----------------------------
 1 file changed, 39 insertions(+), 60 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index bf95016..1f5eddf 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -95,8 +95,6 @@ struct receive_queue {
 
 	struct napi_struct napi;
 
-	struct bpf_prog __rcu *xdp_prog;
-
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
@@ -142,6 +140,9 @@ struct virtnet_info {
 	/* Host can handle any s/g split between our header and packet data */
 	bool any_header_sg;
 
+	/* XDP has been enabled in device */
+	bool xdp_enabled;
+
 	/* Packet virtio header size */
 	u8 hdr_len;
 
@@ -394,19 +395,19 @@ static struct sk_buff *receive_small(struct net_device *dev,
 				     void *buf, unsigned int len)
 {
 	struct sk_buff *skb;
-	struct bpf_prog *xdp_prog;
 	unsigned int xdp_headroom = virtnet_get_headroom(vi);
 	unsigned int header_offset = VIRTNET_RX_PAD + xdp_headroom;
 	unsigned int headroom = vi->hdr_len + header_offset;
 	unsigned int buflen = SKB_DATA_ALIGN(GOOD_PACKET_LEN + headroom) +
 			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 	unsigned int delta = 0;
+	struct xdp_hook *last_hook;
+
 	len -= vi->hdr_len;
 
 	rcu_read_lock();
-	xdp_prog = rcu_dereference(rq->xdp_prog);
-	if (xdp_prog) {
-		struct virtio_net_hdr_mrg_rxbuf *hdr = buf + header_offset;
+	if (xdp_hook_run_needed_check(dev, &rq->napi)) {
+		struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
 		struct xdp_buff xdp;
 		void *orig_data;
 		u32 act;
@@ -418,8 +419,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
 		xdp.data = xdp.data_hard_start + xdp_headroom;
 		xdp.data_end = xdp.data + len;
 		orig_data = xdp.data;
-		act = bpf_prog_run_xdp(xdp_prog, &xdp);
-
+		act = xdp_hook_run_ret_last(&rq->napi, &xdp, &last_hook);
 		switch (act) {
 		case XDP_PASS:
 			/* Recalculate length in case bpf program changed it */
@@ -427,13 +427,13 @@ static struct sk_buff *receive_small(struct net_device *dev,
 			break;
 		case XDP_TX:
 			if (unlikely(!virtnet_xdp_xmit(vi, rq, &xdp)))
-				trace_xdp_exception(vi->dev, xdp_prog, act);
+				trace_xdp_hook_exception(vi->dev, last_hook, act);
 			rcu_read_unlock();
 			goto xdp_xmit;
 		default:
-			bpf_warn_invalid_xdp_action(act);
+			xdp_warn_invalid_action(act);
 		case XDP_ABORTED:
-			trace_xdp_exception(vi->dev, xdp_prog, act);
+			trace_xdp_hook_exception(vi->dev, last_hook, act);
 		case XDP_DROP:
 			goto err_xdp;
 		}
@@ -557,16 +557,15 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	struct page *page = virt_to_head_page(buf);
 	int offset = buf - page_address(page);
 	struct sk_buff *head_skb, *curr_skb;
-	struct bpf_prog *xdp_prog;
 	unsigned int truesize;
 
 	head_skb = NULL;
 
 	rcu_read_lock();
-	xdp_prog = rcu_dereference(rq->xdp_prog);
-	if (xdp_prog) {
+	if (xdp_hook_run_needed_check(dev, &rq->napi)) {
 		struct page *xdp_page;
 		struct xdp_buff xdp;
+		struct xdp_hook *last_hook;
 		void *data;
 		u32 act;
 
@@ -597,7 +596,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		xdp.data_hard_start = data - VIRTIO_XDP_HEADROOM + vi->hdr_len;
 		xdp.data = data + vi->hdr_len;
 		xdp.data_end = xdp.data + (len - vi->hdr_len);
-		act = bpf_prog_run_xdp(xdp_prog, &xdp);
+		act = xdp_hook_run_ret_last(&rq->napi, &xdp, &last_hook);
 
 		switch (act) {
 		case XDP_PASS:
@@ -620,16 +619,16 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			break;
 		case XDP_TX:
 			if (unlikely(!virtnet_xdp_xmit(vi, rq, &xdp)))
-				trace_xdp_exception(vi->dev, xdp_prog, act);
+				trace_xdp_hook_exception(vi->dev, last_hook, act);
 			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
 			if (unlikely(xdp_page != page))
 				goto err_xdp;
 			rcu_read_unlock();
 			goto xdp_xmit;
 		default:
-			bpf_warn_invalid_xdp_action(act);
+			xdp_warn_invalid_action(act);
 		case XDP_ABORTED:
-			trace_xdp_exception(vi->dev, xdp_prog, act);
+			trace_xdp_hook_exception(vi->dev, last_hook, act);
 		case XDP_DROP:
 			if (unlikely(xdp_page != page))
 				__free_pages(xdp_page, 0);
@@ -1606,7 +1605,7 @@ static int virtnet_set_channels(struct net_device *dev,
 	 * also when XDP is loaded all RX queues have XDP programs so we only
 	 * need to check a single RX queue.
 	 */
-	if (vi->rq[0].xdp_prog)
+	if (vi->xdp_enabled)
 		return -EINVAL;
 
 	get_online_cpus();
@@ -1778,11 +1777,20 @@ static int virtnet_reset(struct virtnet_info *vi, int curr_qp, int xdp_qp)
 	return ret;
 }
 
-static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
+static int virtnet_xdp_check_bpf(struct net_device *dev, struct bpf_prog *prog)
+{
+	if (prog && prog->xdp_adjust_head) {
+		netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static int virtnet_xdp_init(struct net_device *dev, bool enable)
 {
 	unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
 	struct virtnet_info *vi = netdev_priv(dev);
-	struct bpf_prog *old_prog;
 	u16 xdp_qp = 0, curr_qp;
 	int i, err;
 
@@ -1805,7 +1813,7 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	}
 
 	curr_qp = vi->curr_queue_pairs - vi->xdp_queue_pairs;
-	if (prog)
+	if (enable)
 		xdp_qp = nr_cpu_ids;
 
 	/* XDP requires extra queues for XDP_TX */
@@ -1815,12 +1823,6 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		return -ENOMEM;
 	}
 
-	if (prog) {
-		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
-		if (IS_ERR(prog))
-			return PTR_ERR(prog);
-	}
-
 	/* Changing the headroom in buffers is a disruptive operation because
 	 * existing buffers must be flushed and reallocated. This will happen
 	 * when a xdp program is initially added or xdp is disabled by removing
@@ -1836,12 +1838,7 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 
 	netif_set_real_num_rx_queues(dev, curr_qp + xdp_qp);
 
-	for (i = 0; i < vi->max_queue_pairs; i++) {
-		old_prog = rtnl_dereference(vi->rq[i].xdp_prog);
-		rcu_assign_pointer(vi->rq[i].xdp_prog, prog);
-		if (old_prog)
-			bpf_prog_put(old_prog);
-	}
+	vi->xdp_enabled = enable;
 
 	return 0;
 
@@ -1850,31 +1847,18 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	 * error up to user space for resolution. The underlying reset hung on
 	 * us so not much we can do here.
 	 */
-	if (prog)
-		bpf_prog_sub(prog, vi->max_queue_pairs - 1);
 	return err;
 }
 
-static bool virtnet_xdp_query(struct net_device *dev)
-{
-	struct virtnet_info *vi = netdev_priv(dev);
-	int i;
-
-	for (i = 0; i < vi->max_queue_pairs; i++) {
-		if (vi->rq[i].xdp_prog)
-			return true;
-	}
-	return false;
-}
-
 static int virtnet_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 {
 	switch (xdp->command) {
-	case XDP_SETUP_PROG:
-		return virtnet_xdp_set(dev, xdp->prog);
-	case XDP_QUERY_PROG:
-		xdp->prog_attached = virtnet_xdp_query(dev);
-		return 0;
+	case XDP_MODE_ON:
+		return virtnet_xdp_init(dev, true);
+	case XDP_MODE_OFF:
+		return virtnet_xdp_init(dev, false);
+	case XDP_CHECK_BPF_PROG:
+		return virtnet_xdp_check_bpf(dev, xdp->prog);
 	default:
 		return -EINVAL;
 	}
@@ -1955,17 +1939,11 @@ static void virtnet_free_queues(struct virtnet_info *vi)
 
 static void _free_receive_bufs(struct virtnet_info *vi)
 {
-	struct bpf_prog *old_prog;
 	int i;
 
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		while (vi->rq[i].pages)
 			__free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
-
-		old_prog = rtnl_dereference(vi->rq[i].xdp_prog);
-		RCU_INIT_POINTER(vi->rq[i].xdp_prog, NULL);
-		if (old_prog)
-			bpf_prog_put(old_prog);
 	}
 }
 
@@ -2274,7 +2252,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	/* Do we support "hardware" checksums? */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CSUM)) {
 		/* This opens up the world of extra features. */
-		dev->hw_features |= NETIF_F_HW_CSUM | NETIF_F_SG;
+		dev->hw_features |= NETIF_F_HW_CSUM | NETIF_F_SG |
+				    NETIF_F_XDP;
 		if (csum)
 			dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
 
-- 
2.9.3
