From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 5/8] net: untangle ip_fragment and bridge netfilter
Date: Thu,  5 Mar 2015 00:52:37 +0100
Message-ID: <1425513160-496-6-git-send-email-fw@strlen.de>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33800 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752940AbbCDXw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 18:52:58 -0500
In-Reply-To: <1425513160-496-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Long time ago it was possible for the netfilter ip_conntrack
core to call ip_fragment in POST_ROUTING hook.

This is no longer the case, so the only case where bridge netfilter
ends up calling ip_fragment is the direct call site in br_netfilter.c.

Add ll and mtu arguments for ip_fragment and then get rid of the bridge
netfilter specific helpers from ip_fragment.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h | 17 -----------------
 include/net/ip.h                 |  4 ++--
 net/bridge/br_netfilter.c        | 12 +++++++++++-
 net/ipv4/ip_output.c             | 28 ++++++++++++++++------------
 4 files changed, 29 insertions(+), 32 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index bb39113..3b5e539 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -36,24 +36,8 @@ static inline unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
 	}
 }
 
-static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
-{
-	if (unlikely(skb->nf_bridge->mask & BRNF_PPPoE))
-		return PPPOE_SES_HLEN;
-	return 0;
-}
-
 int br_handle_frame_finish(struct sk_buff *skb);
 
-/* This is called by the IP fragmenting code and it ensures there is
- * enough room for the encapsulating header (if there is one). */
-static inline unsigned int nf_bridge_pad(const struct sk_buff *skb)
-{
-	if (skb->nf_bridge)
-		return nf_bridge_encap_header_len(skb);
-	return 0;
-}
-
 struct bridge_skb_cb {
 	union {
 		__be32 ipv4;
@@ -69,7 +53,6 @@ static inline void br_drop_fake_rtable(struct sk_buff *skb)
 }
 
 #else
-#define nf_bridge_pad(skb)			(0)
 #define br_drop_fake_rtable(skb)	        do { } while (0)
 #endif /* CONFIG_BRIDGE_NETFILTER */
 
diff --git a/include/net/ip.h b/include/net/ip.h
index 025c61c..9c34441 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -108,8 +108,8 @@ int ip_local_deliver(struct sk_buff *skb);
 int ip_mr_input(struct sk_buff *skb);
 int ip_output(struct sock *sk, struct sk_buff *skb);
 int ip_mc_output(struct sock *sk, struct sk_buff *skb);
-int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
-int ip_do_nat(struct sk_buff *skb);
+int ip_fragment(struct sk_buff *skb, unsigned int mtu_reserved,
+		unsigned int ll_reserved, int (*output)(struct sk_buff *));
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sk_buff *skb);
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index ef1fe28..cf4e93f 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -799,6 +799,13 @@ static int br_nf_push_frag_xmit(struct sk_buff *skb)
 	return br_dev_queue_push_xmit(skb);
 }
 
+static unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
+{
+	if (skb->nf_bridge->mask & BRNF_PPPoE)
+		return PPPOE_SES_HLEN;
+         return 0;
+}
+
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
 	int ret;
@@ -818,7 +825,10 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 			/* Drop invalid packet */
 			return NF_DROP;
 		IPCB(skb)->frag_max_size = frag_max_size;
-		ret = ip_fragment(skb, br_nf_push_frag_xmit);
+
+		ret = ip_fragment(skb, mtu_reserved,
+				  nf_bridge_encap_header_len(skb),
+				  br_nf_push_frag_xmit);
 	} else
 		ret = br_dev_queue_push_xmit(skb);
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index a7aea20..1b284eb 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -243,7 +243,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 		int err;
 
 		segs->next = NULL;
-		err = ip_fragment(segs, ip_finish_output2);
+		err = ip_fragment(segs, 0, 0, ip_finish_output2);
 
 		if (err && ret == 0)
 			ret = err;
@@ -266,7 +266,7 @@ static int ip_finish_output(struct sk_buff *skb)
 		return ip_finish_output_gso(skb);
 
 	if (skb->len > ip_skb_dst_mtu(skb))
-		return ip_fragment(skb, ip_finish_output2);
+		return ip_fragment(skb, 0, 0, ip_finish_output2);
 
 	return ip_finish_output2(skb);
 }
@@ -472,20 +472,28 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	skb_copy_secmark(to, from);
 }
 
-/*
+/**
+ *	ip_fragment - fragment IP datagram or send ICMP error
+ *
+ *	@skb: the skb to fragment
+ *	@mtu_reserved: extra MTU space required (used by bridge netfilter)
+ *	@ll_rs: extra linklayer space required (used by bridge netfilter)
+ *	@output: transmit function used to send fragments
+ *
  *	This IP datagram is too large to be sent in one piece.  Break it up into
  *	smaller pieces (each of size equal to IP header plus
  *	a block of the data of the original IP data part) that will yet fit in a
  *	single device frame, and queue such a frame for sending.
  */
-
-int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
+int ip_fragment(struct sk_buff *skb,
+		unsigned int mtu_reserved, unsigned int ll_rs,
+		int (*output)(struct sk_buff *))
 {
 	struct iphdr *iph;
 	int ptr;
 	struct net_device *dev;
 	struct sk_buff *skb2;
-	unsigned int mtu, hlen, left, len, ll_rs;
+	unsigned int mtu, hlen, left, len;
 	int offset;
 	__be16 not_last_frag;
 	struct rtable *rt = skb_rtable(skb);
@@ -515,11 +523,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	 */
 
 	hlen = iph->ihl * 4;
-	mtu = mtu - hlen;	/* Size of data space */
-#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (skb->nf_bridge)
-		mtu -= nf_bridge_mtu_reduction(skb);
-#endif
+	mtu = mtu - hlen - mtu_reserved;	/* Size of data space */
 	IPCB(skb)->flags |= IPSKB_FRAG_COMPLETE;
 
 	/* When frag_list is given, use it. First, check its validity:
@@ -639,7 +643,7 @@ slow_path:
 	/* for bridged IP traffic encapsulated inside f.e. a vlan header,
 	 * we need to make room for the encapsulating header
 	 */
-	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, nf_bridge_pad(skb));
+	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, ll_rs);
 
 	/*
 	 *	Fragment the datagram.
-- 
2.0.5
