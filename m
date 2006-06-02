From: akpm@osdl.org
Subject: [patch 09/17] secmark: Add secmark support to core networking.
Date: Thu, 01 Jun 2006 20:32:30 -0700
Message-ID: <200606020328.k523SBkh028829@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:181 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751205AbWFBD2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:17 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: James Morris <jmorris@namei.org>

Add a secmark field to the skbuff structure, to allow security subsystems to
place security markings on network packets.  This is similar to the nfmark
field, except is intended for implementing security policy, rather than than
networking policy.

This patch was already acked in principle by Dave Miller.

Signed-off-by: James Morris <jmorris@namei.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/linux/skbuff.h          |   22 ++++++++++++++++++++++
 net/Kconfig                     |    7 +++++++
 net/core/skbuff.c               |    3 ++-
 net/ipv4/ip_output.c            |    1 +
 net/ipv4/netfilter/ipt_REJECT.c |    1 +
 net/ipv6/ip6_output.c           |    1 +
 6 files changed, 34 insertions(+), 1 deletion(-)

diff -puN include/linux/skbuff.h~secmark-add-secmark-support-to-core-networking include/linux/skbuff.h
--- devel/include/linux/skbuff.h~secmark-add-secmark-support-to-core-networking	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/include/linux/skbuff.h	2006-06-01 20:31:50.000000000 -0700
@@ -209,6 +209,7 @@ enum {
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
  *	@tc_index: Traffic control index
  *	@tc_verd: traffic control verdict
+ *	@secmark: security marking
  */
 
 struct sk_buff {
@@ -288,6 +289,9 @@ struct sk_buff {
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
 #endif
+#ifdef CONFIG_NETWORK_SECMARK
+	__u32			secmark;
+#endif
 
 
 	/* These elements must be at the end, see alloc_skb() for details.  */
@@ -1399,5 +1403,23 @@ static inline void nf_reset(struct sk_bu
 static inline void nf_reset(struct sk_buff *skb) {}
 #endif /* CONFIG_NETFILTER */
 
+#ifdef CONFIG_NETWORK_SECMARK
+static inline void skb_copy_secmark(struct sk_buff *to, const struct sk_buff *from)
+{
+	to->secmark = from->secmark;
+}
+
+static inline void skb_init_secmark(struct sk_buff *skb)
+{
+	skb->secmark = 0;
+}
+#else
+static inline void skb_copy_secmark(struct sk_buff *to, const struct sk_buff *from)
+{ }
+
+static inline void skb_init_secmark(struct sk_buff *skb)
+{ }
+#endif
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff -puN net/core/skbuff.c~secmark-add-secmark-support-to-core-networking net/core/skbuff.c
--- devel/net/core/skbuff.c~secmark-add-secmark-support-to-core-networking	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/net/core/skbuff.c	2006-06-01 20:31:50.000000000 -0700
@@ -464,7 +464,7 @@ struct sk_buff *skb_clone(struct sk_buff
 	n->tc_verd = CLR_TC_MUNGED(n->tc_verd);
 	C(input_dev);
 #endif
-
+	skb_copy_secmark(n, skb);
 #endif
 	C(truesize);
 	atomic_set(&n->users, 1);
@@ -526,6 +526,7 @@ static void copy_skb_header(struct sk_bu
 #endif
 	new->tc_index	= old->tc_index;
 #endif
+	skb_copy_secmark(new, old);
 	atomic_set(&new->users, 1);
 	skb_shinfo(new)->tso_size = skb_shinfo(old)->tso_size;
 	skb_shinfo(new)->tso_segs = skb_shinfo(old)->tso_segs;
diff -puN net/ipv4/ip_output.c~secmark-add-secmark-support-to-core-networking net/ipv4/ip_output.c
--- devel/net/ipv4/ip_output.c~secmark-add-secmark-support-to-core-networking	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/net/ipv4/ip_output.c	2006-06-01 20:31:50.000000000 -0700
@@ -410,6 +410,7 @@ static void ip_copy_metadata(struct sk_b
 	nf_bridge_get(to->nf_bridge);
 #endif
 #endif
+	skb_copy_secmark(to, from);
 }
 
 /*
diff -puN net/ipv4/netfilter/ipt_REJECT.c~secmark-add-secmark-support-to-core-networking net/ipv4/netfilter/ipt_REJECT.c
--- devel/net/ipv4/netfilter/ipt_REJECT.c~secmark-add-secmark-support-to-core-networking	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/net/ipv4/netfilter/ipt_REJECT.c	2006-06-01 20:31:50.000000000 -0700
@@ -147,6 +147,7 @@ static void send_reset(struct sk_buff *o
 	/* This packet will not be the same as the other: clear nf fields */
 	nf_reset(nskb);
 	nskb->nfmark = 0;
+	skb_init_secmark(nskb);
 
 	tcph = (struct tcphdr *)((u_int32_t*)nskb->nh.iph + nskb->nh.iph->ihl);
 
diff -puN net/ipv6/ip6_output.c~secmark-add-secmark-support-to-core-networking net/ipv6/ip6_output.c
--- devel/net/ipv6/ip6_output.c~secmark-add-secmark-support-to-core-networking	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/net/ipv6/ip6_output.c	2006-06-01 20:31:50.000000000 -0700
@@ -459,6 +459,7 @@ static void ip6_copy_metadata(struct sk_
 	nf_bridge_get(to->nf_bridge);
 #endif
 #endif
+	skb_copy_secmark(to, from);
 }
 
 int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
diff -puN net/Kconfig~secmark-add-secmark-support-to-core-networking net/Kconfig
--- devel/net/Kconfig~secmark-add-secmark-support-to-core-networking	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/net/Kconfig	2006-06-01 20:31:50.000000000 -0700
@@ -66,6 +66,13 @@ source "net/ipv6/Kconfig"
 
 endif # if INET
 
+config NETWORK_SECMARK
+	bool "Security Marking"
+	help
+	  This enables security marking of network packets, similar
+	  to nfmark, but designated for security purposes.
+	  If you are unsure how to answer this question, answer N.
+
 menuconfig NETFILTER
 	bool "Network packet filtering (replaces ipchains)"
 	---help---
_
