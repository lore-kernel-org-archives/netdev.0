From: James Morris <jmorris@namei.org>
Subject: [RFC] [SECMARK 01/08] Add secmark support to core networking
Date: Sun, 7 May 2006 11:33:10 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605071131500.8588@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@lists.samba.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:19661 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932181AbWEGPdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 11:33:13 -0400
To: selinux@tycho.nsa.gov
In-Reply-To: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a secmark field to the skbuff structure, to allow security 
subsystems to place security markings on network packets.  This is similar 
to the nfmark field, except is intended for implementing security policy, 
rather than than networking policy.

This patch was already acked in principle by Dave Miller.


Signed-off-by: James Morris <jmorris@namei.org>

---

 include/linux/skbuff.h          |   22 ++++++++++++++++++++++
 net/Kconfig                     |    7 +++++++
 net/core/skbuff.c               |    3 ++-
 net/ipv4/ip_output.c            |    1 +
 net/ipv4/netfilter/ipt_REJECT.c |    1 +
 net/ipv6/ip6_output.c           |    1 +
 6 files changed, 34 insertions(+), 1 deletion(-)

diff -purN -X dontdiff linux-2.6.17-rc2-mm1.p/include/linux/skbuff.h linux-2.6.17-rc2-mm1.w/include/linux/skbuff.h
--- linux-2.6.17-rc2-mm1.p/include/linux/skbuff.h	2006-04-27 10:44:26.000000000 -0400
+++ linux-2.6.17-rc2-mm1.w/include/linux/skbuff.h	2006-04-27 23:43:32.000000000 -0400
@@ -209,6 +209,7 @@ enum {
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
  *	@tc_index: Traffic control index
  *	@tc_verd: traffic control verdict
+ *	@secmark: security marking
  */
 
 struct sk_buff {
@@ -285,6 +286,9 @@ struct sk_buff {
 	__u16			tc_verd;	/* traffic control verdict */
 #endif
 #endif
+#ifdef CONFIG_NETWORK_SECMARK
+	__u32			secmark;
+#endif
 
 
 	/* These elements must be at the end, see alloc_skb() for details.  */
@@ -1396,5 +1400,23 @@ static inline void nf_reset(struct sk_bu
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
diff -purN -X dontdiff linux-2.6.17-rc2-mm1.p/net/core/skbuff.c linux-2.6.17-rc2-mm1.w/net/core/skbuff.c
--- linux-2.6.17-rc2-mm1.p/net/core/skbuff.c	2006-04-27 10:44:26.000000000 -0400
+++ linux-2.6.17-rc2-mm1.w/net/core/skbuff.c	2006-04-27 23:43:32.000000000 -0400
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
diff -purN -X dontdiff linux-2.6.17-rc2-mm1.p/net/ipv4/ip_output.c linux-2.6.17-rc2-mm1.w/net/ipv4/ip_output.c
--- linux-2.6.17-rc2-mm1.p/net/ipv4/ip_output.c	2006-04-19 23:31:25.000000000 -0400
+++ linux-2.6.17-rc2-mm1.w/net/ipv4/ip_output.c	2006-04-27 23:43:32.000000000 -0400
@@ -410,6 +410,7 @@ static void ip_copy_metadata(struct sk_b
 	nf_bridge_get(to->nf_bridge);
 #endif
 #endif
+	skb_copy_secmark(to, from);
 }
 
 /*
diff -purN -X dontdiff linux-2.6.17-rc2-mm1.p/net/ipv4/netfilter/ipt_REJECT.c linux-2.6.17-rc2-mm1.w/net/ipv4/netfilter/ipt_REJECT.c
--- linux-2.6.17-rc2-mm1.p/net/ipv4/netfilter/ipt_REJECT.c	2006-04-19 23:31:25.000000000 -0400
+++ linux-2.6.17-rc2-mm1.w/net/ipv4/netfilter/ipt_REJECT.c	2006-04-27 23:43:32.000000000 -0400
@@ -147,6 +147,7 @@ static void send_reset(struct sk_buff *o
 	/* This packet will not be the same as the other: clear nf fields */
 	nf_reset(nskb);
 	nskb->nfmark = 0;
+	skb_init_secmark(nskb);
 
 	tcph = (struct tcphdr *)((u_int32_t*)nskb->nh.iph + nskb->nh.iph->ihl);
 
diff -purN -X dontdiff linux-2.6.17-rc2-mm1.p/net/ipv6/ip6_output.c linux-2.6.17-rc2-mm1.w/net/ipv6/ip6_output.c
--- linux-2.6.17-rc2-mm1.p/net/ipv6/ip6_output.c	2006-04-19 23:31:25.000000000 -0400
+++ linux-2.6.17-rc2-mm1.w/net/ipv6/ip6_output.c	2006-04-27 23:43:32.000000000 -0400
@@ -458,6 +458,7 @@ static void ip6_copy_metadata(struct sk_
 	nf_bridge_get(to->nf_bridge);
 #endif
 #endif
+	skb_copy_secmark(to, from);
 }
 
 int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
diff -purN -X dontdiff linux-2.6.17-rc2-mm1.p/net/Kconfig linux-2.6.17-rc2-mm1.w/net/Kconfig
--- linux-2.6.17-rc2-mm1.p/net/Kconfig	2006-04-19 23:31:25.000000000 -0400
+++ linux-2.6.17-rc2-mm1.w/net/Kconfig	2006-04-27 23:43:32.000000000 -0400
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
