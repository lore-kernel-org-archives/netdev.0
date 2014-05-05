From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/2] net: ip: push gso skb forwarding handling down the stack
Date: Mon,  5 May 2014 15:00:43 +0200
Message-ID: <1399294844-7231-2-git-send-email-fw@strlen.de>
References: <1399294844-7231-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36397 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932187AbaEENGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 09:06:12 -0400
In-Reply-To: <1399294844-7231-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doing the segmentation in the forward path has one major drawback:

When using virtio, we may process gso udp packets coming
from host network stack.  In that case, netfilter POSTROUTING
will see one packet with udp header followed by multiple ip
fragments.

Delay the segmentation and do it after POSTROUTING invocation
to avoid this.

Fixes: fe6cc55f3a9 ("net: ip, ipv6: handle gso skbs in forwarding path")
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/ip_forward.c | 50 --------------------------------------------------
 net/ipv4/ip_output.c  | 51 ++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 48 insertions(+), 53 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index c29ae83..6f111e4 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -56,53 +56,6 @@ static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
 	return true;
 }
 
-static bool ip_gso_exceeds_dst_mtu(const struct sk_buff *skb)
-{
-	unsigned int mtu;
-
-	if (skb->local_df || !skb_is_gso(skb))
-		return false;
-
-	mtu = ip_dst_mtu_maybe_forward(skb_dst(skb), true);
-
-	/* if seglen > mtu, do software segmentation for IP fragmentation on
-	 * output.  DF bit cannot be set since ip_forward would have sent
-	 * icmp error.
-	 */
-	return skb_gso_network_seglen(skb) > mtu;
-}
-
-/* called if GSO skb needs to be fragmented on forward */
-static int ip_forward_finish_gso(struct sk_buff *skb)
-{
-	struct dst_entry *dst = skb_dst(skb);
-	netdev_features_t features;
-	struct sk_buff *segs;
-	int ret = 0;
-
-	features = netif_skb_dev_features(skb, dst->dev);
-	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
-	if (IS_ERR(segs)) {
-		kfree_skb(skb);
-		return -ENOMEM;
-	}
-
-	consume_skb(skb);
-
-	do {
-		struct sk_buff *nskb = segs->next;
-		int err;
-
-		segs->next = NULL;
-		err = dst_output(segs);
-
-		if (err && ret == 0)
-			ret = err;
-		segs = nskb;
-	} while (segs);
-
-	return ret;
-}
 
 static int ip_forward_finish(struct sk_buff *skb)
 {
@@ -114,9 +67,6 @@ static int ip_forward_finish(struct sk_buff *skb)
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	if (ip_gso_exceeds_dst_mtu(skb))
-		return ip_forward_finish_gso(skb);
-
 	return dst_output(skb);
 }
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 1cbeba5..a52f501 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -211,6 +211,48 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	return -EINVAL;
 }
 
+static int ip_finish_output_gso(struct sk_buff *skb)
+{
+	netdev_features_t features;
+	struct sk_buff *segs;
+	int ret = 0;
+
+	/* common case: locally created skb or seglen is <= mtu */
+	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
+	      skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
+		return ip_finish_output2(skb);
+
+	/* Slowpath -  GSO segment length is exceeding the dst MTU.
+	 *
+	 * This can happen in two cases:
+	 * 1) TCP GRO packet, DF bit not set
+	 * 2) skb arrived via virtio-net, we thus get TSO/GSO skbs directly
+	 * from host network stack.
+	 */
+	features = netif_skb_features(skb);
+	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
+	if (IS_ERR(segs)) {
+		kfree_skb(skb);
+		return -ENOMEM;
+	}
+
+	consume_skb(skb);
+
+	do {
+		struct sk_buff *nskb = segs->next;
+		int err;
+
+		segs->next = NULL;
+		err = ip_fragment(segs, ip_finish_output2);
+
+		if (err && ret == 0)
+			ret = err;
+		segs = nskb;
+	} while (segs);
+
+	return ret;
+}
+
 static int ip_finish_output(struct sk_buff *skb)
 {
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
@@ -220,10 +262,13 @@ static int ip_finish_output(struct sk_buff *skb)
 		return dst_output(skb);
 	}
 #endif
-	if (skb->len > ip_skb_dst_mtu(skb) && !skb_is_gso(skb))
+	if (skb_is_gso(skb))
+		return ip_finish_output_gso(skb);
+
+	if (skb->len > ip_skb_dst_mtu(skb))
 		return ip_fragment(skb, ip_finish_output2);
-	else
-		return ip_finish_output2(skb);
+
+	return ip_finish_output2(skb);
 }
 
 int ip_mc_output(struct sock *sk, struct sk_buff *skb)
-- 
1.8.1.5
