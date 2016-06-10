From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] bpf: enforce recursion limit on redirects
Date: Fri, 10 Jun 2016 21:19:06 +0200
Message-ID: <7c9b6cb837c3e25b56c60ba64be67acea31c6b6a.1465578089.git.daniel@iogearbox.net>
References: <cover.1465578089.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52771 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752840AbcFJTTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 15:19:13 -0400
In-Reply-To: <cover.1465578089.git.daniel@iogearbox.net>
In-Reply-To: <cover.1465578089.git.daniel@iogearbox.net>
References: <cover.1465578089.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Respect the stack's xmit_recursion limit for calls into dev_queue_xmit().
Currently, they are not handeled by the limiter when attached to clsact's
egress parent, for example, and a buggy program redirecting it to the
same device again could run into stack overflow eventually. It would be
good if we could notify an admin to give him a chance to react. We reuse
xmit_recursion instead of having one private to eBPF, so that the stack's
current recursion depth will be taken into account as well. Follow-up to
commit 3896d655f4d4 ("bpf: introduce bpf_clone_redirect() helper") and
27b29f63058d ("bpf: add bpf_redirect() helper").

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/netdevice.h |  2 ++
 net/core/dev.c            |  6 ++----
 net/core/filter.c         | 55 +++++++++++++++++++++++++++++------------------
 3 files changed, 38 insertions(+), 25 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4f234b1..94eef35 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2389,6 +2389,8 @@ void synchronize_net(void);
 int init_dummy_netdev(struct net_device *dev);
 
 DECLARE_PER_CPU(int, xmit_recursion);
+#define XMIT_RECURSION_LIMIT	10
+
 static inline int dev_recursion_level(void)
 {
 	return this_cpu_read(xmit_recursion);
diff --git a/net/core/dev.c b/net/core/dev.c
index c43c9d2..b148357 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3144,8 +3144,6 @@ static void skb_update_prio(struct sk_buff *skb)
 DEFINE_PER_CPU(int, xmit_recursion);
 EXPORT_SYMBOL(xmit_recursion);
 
-#define RECURSION_LIMIT 10
-
 /**
  *	dev_loopback_xmit - loop back @skb
  *	@net: network namespace this loopback is happening in
@@ -3388,8 +3386,8 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 		int cpu = smp_processor_id(); /* ok because BHs are off */
 
 		if (txq->xmit_lock_owner != cpu) {
-
-			if (__this_cpu_read(xmit_recursion) > RECURSION_LIMIT)
+			if (unlikely(__this_cpu_read(xmit_recursion) >
+				     XMIT_RECURSION_LIMIT))
 				goto recursion_alert;
 
 			skb = validate_xmit_skb(skb, dev);
diff --git a/net/core/filter.c b/net/core/filter.c
index 68adb5f..d11744d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1603,9 +1603,36 @@ static const struct bpf_func_proto bpf_csum_diff_proto = {
 	.arg5_type	= ARG_ANYTHING,
 };
 
+static inline int __bpf_rx_skb(struct net_device *dev, struct sk_buff *skb)
+{
+	if (skb_at_tc_ingress(skb))
+		skb_postpush_rcsum(skb, skb_mac_header(skb), skb->mac_len);
+
+	return dev_forward_skb(dev, skb);
+}
+
+static inline int __bpf_tx_skb(struct net_device *dev, struct sk_buff *skb)
+{
+	int ret;
+
+	if (unlikely(__this_cpu_read(xmit_recursion) > XMIT_RECURSION_LIMIT)) {
+		net_crit_ratelimited("bpf: recursion limit reached on datapath, buggy bpf program?\n");
+		kfree_skb(skb);
+		return -ENETDOWN;
+	}
+
+	skb->dev = dev;
+
+	__this_cpu_inc(xmit_recursion);
+	ret = dev_queue_xmit(skb);
+	__this_cpu_dec(xmit_recursion);
+
+	return ret;
+}
+
 static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 {
-	struct sk_buff *skb = (struct sk_buff *) (long) r1, *skb2;
+	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	struct net_device *dev;
 
 	if (unlikely(flags & ~(BPF_F_INGRESS)))
@@ -1615,19 +1642,12 @@ static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 	if (unlikely(!dev))
 		return -EINVAL;
 
-	skb2 = skb_clone(skb, GFP_ATOMIC);
-	if (unlikely(!skb2))
+	skb = skb_clone(skb, GFP_ATOMIC);
+	if (unlikely(!skb))
 		return -ENOMEM;
 
-	if (flags & BPF_F_INGRESS) {
-		if (skb_at_tc_ingress(skb2))
-			skb_postpush_rcsum(skb2, skb_mac_header(skb2),
-					   skb2->mac_len);
-		return dev_forward_skb(dev, skb2);
-	}
-
-	skb2->dev = dev;
-	return dev_queue_xmit(skb2);
+	return flags & BPF_F_INGRESS ?
+	       __bpf_rx_skb(dev, skb) : __bpf_tx_skb(dev, skb);
 }
 
 static const struct bpf_func_proto bpf_clone_redirect_proto = {
@@ -1671,15 +1691,8 @@ int skb_do_redirect(struct sk_buff *skb)
 		return -EINVAL;
 	}
 
-	if (ri->flags & BPF_F_INGRESS) {
-		if (skb_at_tc_ingress(skb))
-			skb_postpush_rcsum(skb, skb_mac_header(skb),
-					   skb->mac_len);
-		return dev_forward_skb(dev, skb);
-	}
-
-	skb->dev = dev;
-	return dev_queue_xmit(skb);
+	return ri->flags & BPF_F_INGRESS ?
+	       __bpf_rx_skb(dev, skb) : __bpf_tx_skb(dev, skb);
 }
 
 static const struct bpf_func_proto bpf_redirect_proto = {
-- 
1.9.3
