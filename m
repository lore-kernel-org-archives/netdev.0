From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 11/13] TProxy: added IPv6 support to the TPROXY target
Date: Mon, 24 Aug 2009 14:51:47 +0200
Message-ID: <1253548005.12519.11.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:58470 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752493AbZIUQZB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 12:25:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This requires a new revision as the old target structure was
IPv4 specific.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 include/linux/netfilter/xt_TPROXY.h |   15 ++-
 net/netfilter/xt_TPROXY.c           |  246 +++++++++++++++++++++++++++++------
 2 files changed, 216 insertions(+), 45 deletions(-)

diff --git a/include/linux/netfilter/xt_TPROXY.h b/include/linux/netfilter/xt_TPROXY.h
index 152e8f9..7b4e06d 100644
--- a/include/linux/netfilter/xt_TPROXY.h
+++ b/include/linux/netfilter/xt_TPROXY.h
@@ -1,14 +1,21 @@
-#ifndef _XT_TPROXY_H_target
-#define _XT_TPROXY_H_target
+#ifndef _XT_TPROXY_H
+#define _XT_TPROXY_H
 
 /* TPROXY target is capable of marking the packet to perform
  * redirection. We can get rid of that whenever we get support for
  * mutliple targets in the same rule. */
-struct xt_tproxy_target_info {
+struct xt_tproxy_target_info_v0 {
 	u_int32_t mark_mask;
 	u_int32_t mark_value;
 	__be32 laddr;
 	__be16 lport;
 };
 
-#endif /* _XT_TPROXY_H_target */
+struct xt_tproxy_target_info_v1 {
+	u_int32_t mark_mask;
+	u_int32_t mark_value;
+	union nf_inet_addr laddr;
+	__be16 lport;
+};
+
+#endif /* _XT_TPROXY_H */
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 5592b72..4a345cd 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -19,52 +19,173 @@
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
 #include <linux/netfilter/xt_TPROXY.h>
 
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+#include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 #include <net/netfilter/nf_tproxy_core.h>
 
 static unsigned int
-tproxy_tg(struct sk_buff *skb, const struct xt_target_param *par)
+tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport, u_int32_t mark_mask, u_int32_t mark_value)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	const struct xt_tproxy_target_info *tgi = par->targinfo;
-	struct tcphdr _hdr, *hp;
+	struct udphdr _hdr, *hp;
 	struct sock *sk;
 
 	hp = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_hdr), &_hdr);
-	if (hp == NULL)
+	if (hp == NULL) {
+		pr_debug("TPROXY: packet is too short to contain a transport header, dropping\n");
 		return NF_DROP;
+	}
 
+        /* check if there's an ongoing connection on the packet
+	 * addresses, this happens if the redirect already happened
+	 * and the current packet belongs to an already established
+	 * connection */
 	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
 				   iph->saddr, iph->daddr,
 				   hp->source, hp->dest,
-				   par->in, NFT_LOOKUP_ESTABLISHED);
+				   skb->dev, NFT_LOOKUP_ESTABLISHED);
 
 	/* udp has no TCP_TIME_WAIT state, so we never enter here */
-	if (sk && sk->sk_state == TCP_TIME_WAIT &&
-	    hp->syn && !hp->rst && !hp->ack && !hp->fin) {
-		struct sock *sk2;
-
-		/* Hm.. we got a SYN to a TIME_WAIT socket, let's see if
-		 * there's a listener on the redirected port
-		 */
-		sk2 = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
-					   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
-					   hp->source, tgi->lport ? tgi->lport : hp->dest,
-					   par->in, NFT_LOOKUP_LISTENER);
-		if (sk2) {
+	if (sk && sk->sk_state == TCP_TIME_WAIT) {
+		struct tcphdr _hdr, *hp;
 
-			/* yeah, there's one, let's kill the TIME_WAIT
-			 * socket and redirect to the listener
+		hp = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_hdr), &_hdr);
+		if (hp == NULL)
+			return NF_DROP;
+		
+		if (hp->syn && !hp->rst && !hp->ack && !hp->fin) {
+			struct sock *sk2;
+			
+			/* Hm.. we got a SYN to a TIME_WAIT socket, let's see if
+			 * there's a listener on the redirected port
 			 */
-			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
-			inet_twsk_put(inet_twsk(sk));
-			sk = sk2;
+			sk2 = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
+						    iph->saddr, laddr ? laddr : iph->daddr,
+						    hp->source, lport ? lport : hp->dest,
+						    skb->dev, NFT_LOOKUP_LISTENER);
+			if (sk2) {
+				
+				/* yeah, there's one, let's kill the TIME_WAIT
+				 * socket and redirect to the listener
+				 */
+				inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
+				inet_twsk_put(inet_twsk(sk));
+				sk = sk2;
+			}
 		}
 	} else if (!sk) {
+		/* no there's no established connection, check if
+		 * there's a listener on the redirected addr/port */
 		sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
-					   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
+					   iph->saddr, laddr ? laddr : iph->daddr,
+					   hp->source, lport ? lport : hp->dest,
+					   skb->dev, NFT_LOOKUP_LISTENER);
+	}
+	/* NOTE: assign_sock consumes our sk reference */
+	if (sk && nf_tproxy_assign_sock(skb, sk)) {
+		/* This should be in a separate target, but we don't do multiple
+		   targets on the same rule yet */
+		skb->mark = (skb->mark & ~mark_mask) ^ mark_value;
+
+		pr_debug("TPROXY: redirecting: proto %u %08x:%u -> %08x:%u, mark: %x\n",
+			 iph->protocol, ntohl(iph->daddr), ntohs(hp->dest),
+			 ntohl(laddr), ntohs(lport), skb->mark);
+		return NF_ACCEPT;
+	}
+
+	pr_debug("TPROXY: no socket, dropping: proto %u %08x:%u -> %08x:%u, mark: %x\n",
+		 iph->protocol, ntohl(iph->daddr), ntohs(hp->dest),
+		 ntohl(laddr), ntohs(lport), skb->mark);
+	return NF_DROP;
+}
+
+static unsigned int
+tproxy_tg4_v0(struct sk_buff *skb, const struct xt_target_param *par)
+{
+	const struct xt_tproxy_target_info_v0 *tgi = par->targinfo;
+
+	return tproxy_tg4(skb, tgi->laddr, tgi->lport, tgi->mark_mask, tgi->mark_value);
+}
+
+static unsigned int
+tproxy_tg4_v1(struct sk_buff *skb, const struct xt_target_param *par)
+{
+	const struct xt_tproxy_target_info_v1 *tgi = par->targinfo;
+
+	return tproxy_tg4(skb, tgi->laddr.ip, tgi->lport, tgi->mark_mask, tgi->mark_value);
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static unsigned int
+tproxy_tg6_v1(struct sk_buff *skb, const struct xt_target_param *par)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct xt_tproxy_target_info_v1 *tgi = par->targinfo;
+	struct udphdr _hdr, *hp;
+	struct sock *sk;
+        int thoff;
+        int tproto;
+
+        tproto = ipv6_find_hdr(skb, &thoff, -1, NULL);
+        if (tproto < 0) {
+		pr_debug("TPROXY: Unable to find transport header in IPv6 packet, dropping\n");
+		return NF_DROP;
+        }
+
+	hp = skb_header_pointer(skb, thoff, sizeof(_hdr), &_hdr);
+	if (hp == NULL) {
+		pr_debug("TPROXY: Unable to grab transport header contents in IPv6 packet, dropping\n");
+		return NF_DROP;
+	}
+
+        /* check if there's an ongoing connection on the packet
+	 * addresses, this happens if the redirect already happened
+	 * and the current packet belongs to an already established
+	 * connection */
+	sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+				   &iph->saddr, &iph->daddr,
+				   hp->source, hp->dest,
+				   par->in, NFT_LOOKUP_ESTABLISHED);
+
+	/* udp has no TCP_TIME_WAIT state, so we never enter here */
+	if (sk && sk->sk_state == TCP_TIME_WAIT) {
+		struct tcphdr _hdr, *hp;
+
+		hp = skb_header_pointer(skb, thoff, sizeof(_hdr), &_hdr);
+		if (hp == NULL) {
+			pr_debug("TPROXY: Unable to grab TCP transport header contents in IPv6 packet, dropping\n");
+			return NF_DROP;
+		}
+
+		if (hp->syn && !hp->rst && !hp->ack && !hp->fin) {
+			struct sock *sk2;
+			
+
+			/* Hm.. we got a SYN to a TIME_WAIT socket, let's see if
+			 * there's a listener on the redirected port
+			 */
+			sk2 = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+						    &iph->saddr, !ipv6_addr_any(&tgi->laddr.in6) ? &tgi->laddr.in6 : &iph->daddr,
+						    hp->source, tgi->lport ? tgi->lport : hp->dest,
+						    par->in, NFT_LOOKUP_LISTENER);
+			if (sk2) {
+				
+				/* yeah, there's one, let's kill the TIME_WAIT
+				 * socket and redirect to the listener
+				 */
+				inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
+				inet_twsk_put(inet_twsk(sk));
+				sk = sk2;
+			}
+		}
+	} else if (!sk) {
+		/* no there's no established connection, check if
+		 * there's a listener on the redirected addr/port */
+		sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+					   &iph->saddr, !ipv6_addr_any(&tgi->laddr.in6) ? &tgi->laddr.in6 : &iph->daddr,
 					   hp->source, tgi->lport ? tgi->lport : hp->dest,
 					   par->in, NFT_LOOKUP_LISTENER);
 	}
@@ -74,51 +195,93 @@ tproxy_tg(struct sk_buff *skb, const struct xt_target_param *par)
 		   targets on the same rule yet */
 		skb->mark = (skb->mark & ~tgi->mark_mask) ^ tgi->mark_value;
 
-		pr_debug("redirecting: proto %u %08x:%u -> %08x:%u, mark: %x\n",
-			 iph->protocol, ntohl(iph->daddr), ntohs(hp->dest),
-			 ntohl(tgi->laddr), ntohs(tgi->lport), skb->mark);
+		pr_debug("TPROXY: redirecting: proto %u %pI6:%u -> %pI6:%u, mark: %x\n",
+			 tproto, &iph->saddr, ntohs(hp->dest),
+			 &tgi->laddr.in6, ntohs(tgi->lport), skb->mark);
 		return NF_ACCEPT;
 	}
 
-	pr_debug("no socket, dropping: proto %u %08x:%u -> %08x:%u, mark: %x\n",
-		 iph->protocol, ntohl(iph->daddr), ntohs(hp->dest),
-		 ntohl(tgi->laddr), ntohs(tgi->lport), skb->mark);
+	pr_debug("TPROXY: no socket, dropping: proto %u %pI6:%u -> %pI6:%u, mark: %x\n",
+		 tproto, &iph->saddr, ntohs(hp->dest),
+		 &tgi->laddr.in6, ntohs(tgi->lport), skb->mark);
 	return NF_DROP;
 }
+#endif
+
 
-static bool tproxy_tg_check(const struct xt_tgchk_param *par)
+static bool tproxy_tg4_check(const struct xt_tgchk_param *par)
 {
 	const struct ipt_ip *i = par->entryinfo;
 
 	if ((i->proto == IPPROTO_TCP || i->proto == IPPROTO_UDP)
 	    && !(i->invflags & IPT_INV_PROTO))
 		return true;
+	pr_info("xt_TPROXY: Can be used only in combination with "
+		"either -p tcp or -p udp\n");
+	return false;
+}
+
+static bool tproxy_tg6_check(const struct xt_tgchk_param *par)
+{
+	const struct ip6t_ip6 *i = par->entryinfo;
 
+	if ((i->proto == IPPROTO_TCP || i->proto == IPPROTO_UDP)
+	    && !(i->flags & IP6T_INV_PROTO))
+		return true;
 	pr_info("xt_TPROXY: Can be used only in combination with "
 		"either -p tcp or -p udp\n");
 	return false;
 }
 
-static struct xt_target tproxy_tg_reg __read_mostly = {
-	.name		= "TPROXY",
-	.family		= AF_INET,
-	.table		= "mangle",
-	.target		= tproxy_tg,
-	.targetsize	= sizeof(struct xt_tproxy_target_info),
-	.checkentry	= tproxy_tg_check,
-	.hooks		= 1 << NF_INET_PRE_ROUTING,
-	.me		= THIS_MODULE,
+static struct xt_target tproxy_tg_reg[] __read_mostly = {
+	{
+		.name		= "TPROXY",
+		.family		= NFPROTO_IPV4,
+		.table		= "mangle",
+		.target		= tproxy_tg4_v0,
+		.revision       = 0,
+		.targetsize	= sizeof(struct xt_tproxy_target_info_v0),
+		.checkentry	= tproxy_tg4_check,
+		.hooks		= 1 << NF_INET_PRE_ROUTING,
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "TPROXY",
+		.family		= NFPROTO_IPV4,
+		.table		= "mangle",
+		.target		= tproxy_tg4_v1,
+		.revision       = 1,
+		.targetsize	= sizeof(struct xt_tproxy_target_info_v1),
+		.checkentry	= tproxy_tg4_check,
+		.hooks		= 1 << NF_INET_PRE_ROUTING,
+		.me		= THIS_MODULE,
+	},
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	{
+		.name		= "TPROXY",
+		.family		= NFPROTO_IPV6,
+		.table		= "mangle",
+		.target		= tproxy_tg6_v1,
+		.revision       = 1,
+		.targetsize	= sizeof(struct xt_tproxy_target_info_v1),
+		.checkentry	= tproxy_tg6_check,
+		.hooks		= 1 << NF_INET_PRE_ROUTING,
+		.me		= THIS_MODULE,
+	},
+#endif
+
 };
 
 static int __init tproxy_tg_init(void)
 {
 	nf_defrag_ipv4_enable();
-	return xt_register_target(&tproxy_tg_reg);
+	nf_defrag_ipv6_enable();
+	return xt_register_targets(tproxy_tg_reg, ARRAY_SIZE(tproxy_tg_reg));
 }
 
 static void __exit tproxy_tg_exit(void)
 {
-	xt_unregister_target(&tproxy_tg_reg);
+	xt_unregister_targets(tproxy_tg_reg, ARRAY_SIZE(tproxy_tg_reg));
 }
 
 module_init(tproxy_tg_init);
@@ -127,3 +290,4 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Krisztian Kovacs");
 MODULE_DESCRIPTION("Netfilter transparent proxy (TPROXY) target module.");
 MODULE_ALIAS("ipt_TPROXY");
+MODULE_ALIAS("ip6t_TPROXY");
-- 
1.6.0.4

