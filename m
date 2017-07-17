From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 02/12] net: xdp: support xdp generic on virtual
 devices
Date: Mon, 17 Jul 2017 09:26:45 -0700
Message-ID: <20170717162645.24315.62704.stgit@john-Precision-Tower-5810>
References: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, brouer@redhat.com, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36737 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbdGQQ1B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 12:27:01 -0400
Received: by mail-pg0-f68.google.com with SMTP id y129so20044441pgy.3
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 09:27:00 -0700 (PDT)
In-Reply-To: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP generic allows users to test XDP programs and/or run them with
degraded performance on devices that do not yet support XDP. For
testing I typically test eBPF programs using a set of veth devices.
This allows testing topologies that would otherwise be difficult to
setup especially in the early stages of development.

This patch adds a xdp generic hook to the netif_rx_internal()
function which is called from dev_forward_skb(). With this addition
attaching XDP programs to veth devices works as expected! Also I
noticed multiple drivers using netif_rx(). These devices will also
benefit and generic XDP will work for them as well.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Tested-by: Andy Gospodarek <andy@greyhouse.net>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/core/dev.c |  208 ++++++++++++++++++++++++++++++--------------------------
 1 file changed, 113 insertions(+), 95 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0244051..a1ed7b4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3865,6 +3865,107 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 	return NET_RX_DROP;
 }
 
+static u32 netif_receive_generic_xdp(struct sk_buff *skb,
+				     struct bpf_prog *xdp_prog)
+{
+	struct xdp_buff xdp;
+	u32 act = XDP_DROP;
+	void *orig_data;
+	int hlen, off;
+	u32 mac_len;
+
+	/* Reinjected packets coming from act_mirred or similar should
+	 * not get XDP generic processing.
+	 */
+	if (skb_cloned(skb))
+		return XDP_PASS;
+
+	if (skb_linearize(skb))
+		goto do_drop;
+
+	/* The XDP program wants to see the packet starting at the MAC
+	 * header.
+	 */
+	mac_len = skb->data - skb_mac_header(skb);
+	hlen = skb_headlen(skb) + mac_len;
+	xdp.data = skb->data - mac_len;
+	xdp.data_end = xdp.data + hlen;
+	xdp.data_hard_start = skb->data - skb_headroom(skb);
+	orig_data = xdp.data;
+
+	act = bpf_prog_run_xdp(xdp_prog, &xdp);
+
+	off = xdp.data - orig_data;
+	if (off > 0)
+		__skb_pull(skb, off);
+	else if (off < 0)
+		__skb_push(skb, -off);
+
+	switch (act) {
+	case XDP_TX:
+		__skb_push(skb, mac_len);
+		/* fall through */
+	case XDP_PASS:
+		break;
+
+	default:
+		bpf_warn_invalid_xdp_action(act);
+		/* fall through */
+	case XDP_ABORTED:
+		trace_xdp_exception(skb->dev, xdp_prog, act);
+		/* fall through */
+	case XDP_DROP:
+	do_drop:
+		kfree_skb(skb);
+		break;
+	}
+
+	return act;
+}
+
+/* When doing generic XDP we have to bypass the qdisc layer and the
+ * network taps in order to match in-driver-XDP behavior.
+ */
+static void generic_xdp_tx(struct sk_buff *skb, struct bpf_prog *xdp_prog)
+{
+	struct net_device *dev = skb->dev;
+	struct netdev_queue *txq;
+	bool free_skb = true;
+	int cpu, rc;
+
+	txq = netdev_pick_tx(dev, skb, NULL);
+	cpu = smp_processor_id();
+	HARD_TX_LOCK(dev, txq, cpu);
+	if (!netif_xmit_stopped(txq)) {
+		rc = netdev_start_xmit(skb, dev, txq, 0);
+		if (dev_xmit_complete(rc))
+			free_skb = false;
+	}
+	HARD_TX_UNLOCK(dev, txq);
+	if (free_skb) {
+		trace_xdp_exception(dev, xdp_prog, XDP_TX);
+		kfree_skb(skb);
+	}
+}
+
+static struct static_key generic_xdp_needed __read_mostly;
+
+static int do_xdp_generic(struct sk_buff *skb)
+{
+	struct bpf_prog *xdp_prog = rcu_dereference(skb->dev->xdp_prog);
+
+	if (xdp_prog) {
+		u32 act = netif_receive_generic_xdp(skb, xdp_prog);
+
+		if (act != XDP_PASS) {
+			if (act == XDP_TX)
+				generic_xdp_tx(skb, xdp_prog);
+			return XDP_DROP;
+		}
+	}
+	return XDP_PASS;
+}
+
 static int netif_rx_internal(struct sk_buff *skb)
 {
 	int ret;
@@ -3872,6 +3973,14 @@ static int netif_rx_internal(struct sk_buff *skb)
 	net_timestamp_check(netdev_tstamp_prequeue, skb);
 
 	trace_netif_rx(skb);
+
+	if (static_key_false(&generic_xdp_needed)) {
+		int ret = do_xdp_generic(skb);
+
+		if (ret != XDP_PASS)
+			return NET_RX_DROP;
+	}
+
 #ifdef CONFIG_RPS
 	if (static_key_false(&rps_needed)) {
 		struct rps_dev_flow voidflow, *rflow = &voidflow;
@@ -4338,8 +4447,6 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	return ret;
 }
 
-static struct static_key generic_xdp_needed __read_mostly;
-
 static int generic_xdp_install(struct net_device *dev, struct netdev_xdp *xdp)
 {
 	struct bpf_prog *old = rtnl_dereference(dev->xdp_prog);
@@ -4373,89 +4480,6 @@ static int generic_xdp_install(struct net_device *dev, struct netdev_xdp *xdp)
 	return ret;
 }
 
-static u32 netif_receive_generic_xdp(struct sk_buff *skb,
-				     struct bpf_prog *xdp_prog)
-{
-	struct xdp_buff xdp;
-	u32 act = XDP_DROP;
-	void *orig_data;
-	int hlen, off;
-	u32 mac_len;
-
-	/* Reinjected packets coming from act_mirred or similar should
-	 * not get XDP generic processing.
-	 */
-	if (skb_cloned(skb))
-		return XDP_PASS;
-
-	if (skb_linearize(skb))
-		goto do_drop;
-
-	/* The XDP program wants to see the packet starting at the MAC
-	 * header.
-	 */
-	mac_len = skb->data - skb_mac_header(skb);
-	hlen = skb_headlen(skb) + mac_len;
-	xdp.data = skb->data - mac_len;
-	xdp.data_end = xdp.data + hlen;
-	xdp.data_hard_start = skb->data - skb_headroom(skb);
-	orig_data = xdp.data;
-
-	act = bpf_prog_run_xdp(xdp_prog, &xdp);
-
-	off = xdp.data - orig_data;
-	if (off > 0)
-		__skb_pull(skb, off);
-	else if (off < 0)
-		__skb_push(skb, -off);
-
-	switch (act) {
-	case XDP_TX:
-		__skb_push(skb, mac_len);
-		/* fall through */
-	case XDP_PASS:
-		break;
-
-	default:
-		bpf_warn_invalid_xdp_action(act);
-		/* fall through */
-	case XDP_ABORTED:
-		trace_xdp_exception(skb->dev, xdp_prog, act);
-		/* fall through */
-	case XDP_DROP:
-	do_drop:
-		kfree_skb(skb);
-		break;
-	}
-
-	return act;
-}
-
-/* When doing generic XDP we have to bypass the qdisc layer and the
- * network taps in order to match in-driver-XDP behavior.
- */
-static void generic_xdp_tx(struct sk_buff *skb, struct bpf_prog *xdp_prog)
-{
-	struct net_device *dev = skb->dev;
-	struct netdev_queue *txq;
-	bool free_skb = true;
-	int cpu, rc;
-
-	txq = netdev_pick_tx(dev, skb, NULL);
-	cpu = smp_processor_id();
-	HARD_TX_LOCK(dev, txq, cpu);
-	if (!netif_xmit_stopped(txq)) {
-		rc = netdev_start_xmit(skb, dev, txq, 0);
-		if (dev_xmit_complete(rc))
-			free_skb = false;
-	}
-	HARD_TX_UNLOCK(dev, txq);
-	if (free_skb) {
-		trace_xdp_exception(dev, xdp_prog, XDP_TX);
-		kfree_skb(skb);
-	}
-}
-
 static int netif_receive_skb_internal(struct sk_buff *skb)
 {
 	int ret;
@@ -4468,17 +4492,11 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
 	rcu_read_lock();
 
 	if (static_key_false(&generic_xdp_needed)) {
-		struct bpf_prog *xdp_prog = rcu_dereference(skb->dev->xdp_prog);
-
-		if (xdp_prog) {
-			u32 act = netif_receive_generic_xdp(skb, xdp_prog);
+		int ret = do_xdp_generic(skb);
 
-			if (act != XDP_PASS) {
-				rcu_read_unlock();
-				if (act == XDP_TX)
-					generic_xdp_tx(skb, xdp_prog);
-				return NET_RX_DROP;
-			}
+		if (ret != XDP_PASS) {
+			rcu_read_unlock();
+			return NET_RX_DROP;
 		}
 	}
 
