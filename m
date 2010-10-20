From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH 7/9] tproxy: added IPv6 support to the TPROXY target
Date: Wed, 20 Oct 2010 13:21:18 +0200
Message-ID: <20101020112118.6260.51773.stgit@este.odu>
References: <20101020112118.6260.31618.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20101020112118.6260.31618.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Scheidler <bazsi@balabit.hu>

This requires a new revision as the old target structure was
IPv4 specific.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
---
 include/linux/netfilter/xt_TPROXY.h |   15 +-
 net/netfilter/xt_TPROXY.c           |  262 ++++++++++++++++++++++++++++++-----
 2 files changed, 236 insertions(+), 41 deletions(-)

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
index 67cbed8..6ce76d6 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -1,7 +1,7 @@
 /*
  * Transparent proxy support for Linux/iptables
  *
- * Copyright (c) 2006-2007 BalaBit IT Ltd.
+ * Copyright (c) 2006-2010 BalaBit IT Ltd.
  * Author: Balazs Scheidler, Krisztian Kovacs
  *
  * This program is free software; you can redistribute it and/or modify
@@ -19,15 +19,18 @@
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
 #include <linux/netfilter/xt_TPROXY.h>
 
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+#include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 #include <net/netfilter/nf_tproxy_core.h>
 
 /**
- * tproxy_handle_time_wait() - handle TCP TIME_WAIT reopen redirections
+ * tproxy_handle_time_wait4() - handle IPv4 TCP TIME_WAIT reopen redirections
  * @skb:	The skb being processed.
- * @par:	Iptables target parameters.
+ * @laddr:	IPv4 address to redirect to or zero.
+ * @lport:	TCP port to redirect to or zero.
  * @sk:		The TIME_WAIT TCP socket found by the lookup.
  *
  * We have to handle SYN packets arriving to TIME_WAIT sockets
@@ -35,16 +38,16 @@
  * redirect the new connection to the proxy if there's a listener
  * socket present.
  *
- * tproxy_handle_time_wait() consumes the socket reference passed in.
+ * tproxy_handle_time_wait4() consumes the socket reference passed in.
  *
  * Returns the listener socket if there's one, the TIME_WAIT socket if
  * no such listener is found, or NULL if the TCP header is incomplete.
  */
 static struct sock *
-tproxy_handle_time_wait(struct sk_buff *skb, const struct xt_action_param *par, struct sock *sk)
+tproxy_handle_time_wait4(struct sk_buff *skb, __be32 laddr, __be16 lport,
+			struct sock *sk)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	const struct xt_tproxy_target_info *tgi = par->targinfo;
 	struct tcphdr _hdr, *hp;
 
 	hp = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_hdr), &_hdr);
@@ -59,13 +62,64 @@ tproxy_handle_time_wait(struct sk_buff *skb, const struct xt_action_param *par,
 		struct sock *sk2;
 
 		sk2 = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
-					    iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
-					    hp->source, tgi->lport ? tgi->lport : hp->dest,
-					    par->in, NFT_LOOKUP_LISTENER);
+					    iph->saddr, laddr ? laddr : iph->daddr,
+					    hp->source, lport ? lport : hp->dest,
+					    skb->dev, NFT_LOOKUP_LISTENER);
+		if (sk2) {
+			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
+			inet_twsk_put(inet_twsk(sk));
+			sk = sk2;
+		}
+	}
+
+	return sk;
+}
+
+/**
+ * tproxy_handle_time_wait6() - handle IPv6 TCP TIME_WAIT reopen redirections
+ * @skb:	The skb being processed.
+ * @tproto:	Transport protocol.
+ * @thoff:	Transport protocol header offset.
+ * @par:	Iptables target parameters.
+ * @sk:		The TIME_WAIT TCP socket found by the lookup.
+ *
+ * We have to handle SYN packets arriving to TIME_WAIT sockets
+ * differently: instead of reopening the connection we should rather
+ * redirect the new connection to the proxy if there's a listener
+ * socket present.
+ *
+ * tproxy_handle_time_wait6() consumes the socket reference passed in.
+ *
+ * Returns the listener socket if there's one, the TIME_WAIT socket if
+ * no such listener is found, or NULL if the TCP header is incomplete.
+ */
+static struct sock *
+tproxy_handle_time_wait6(struct sk_buff *skb, int tproto, int thoff,
+			 const struct xt_action_param *par,
+			 struct sock *sk)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct tcphdr _hdr, *hp;
+	const struct xt_tproxy_target_info_v1 *tgi = par->targinfo;
+
+	hp = skb_header_pointer(skb, thoff, sizeof(_hdr), &_hdr);
+	if (hp == NULL) {
+		inet_twsk_put(inet_twsk(sk));
+		return NULL;
+	}
+
+	if (hp->syn && !hp->rst && !hp->ack && !hp->fin) {
+		/* SYN to a TIME_WAIT socket, we'd rather redirect it
+		 * to a listener socket if there's one */
+		struct sock *sk2;
+
+		sk2 = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+					    &iph->saddr,
+					    !ipv6_addr_any(&tgi->laddr.in6) ? &tgi->laddr.in6 : &iph->daddr,
+					    hp->source,
+					    tgi->lport ? tgi->lport : hp->dest,
+					    skb->dev, NFT_LOOKUP_LISTENER);
 		if (sk2) {
-			/* yeah, there's one, let's kill the TIME_WAIT
-			 * socket and redirect to the listener
-			 */
 			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
 			inet_twsk_put(inet_twsk(sk));
 			sk = sk2;
@@ -76,10 +130,10 @@ tproxy_handle_time_wait(struct sk_buff *skb, const struct xt_action_param *par,
 }
 
 static unsigned int
-tproxy_tg(struct sk_buff *skb, const struct xt_action_param *par)
+tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport,
+	   u_int32_t mark_mask, u_int32_t mark_value)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	const struct xt_tproxy_target_info *tgi = par->targinfo;
 	struct udphdr _hdr, *hp;
 	struct sock *sk;
 
@@ -87,39 +141,140 @@ tproxy_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	if (hp == NULL)
 		return NF_DROP;
 
+	/* check if there's an ongoing connection on the packet
+	 * addresses, this happens if the redirect already happened
+	 * and the current packet belongs to an already established
+	 * connection */
 	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
 				   iph->saddr, iph->daddr,
 				   hp->source, hp->dest,
-				   par->in, NFT_LOOKUP_ESTABLISHED);
+				   skb->dev, NFT_LOOKUP_ESTABLISHED);
 
 	/* UDP has no TCP_TIME_WAIT state, so we never enter here */
 	if (sk && sk->sk_state == TCP_TIME_WAIT)
-		sk = tproxy_handle_time_wait(skb, par, sk);
+		/* reopening a TIME_WAIT connection needs special handling */
+		sk = tproxy_handle_time_wait4(skb, laddr, lport, sk);
 	else if (!sk)
+		/* no, there's no established connection, check if
+		 * there's a listener on the redirected addr/port */
 		sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
-					   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
-					   hp->source, tgi->lport ? tgi->lport : hp->dest,
-					   par->in, NFT_LOOKUP_LISTENER);
+					   iph->saddr, laddr ? laddr : iph->daddr,
+					   hp->source, lport ? lport : hp->dest,
+					   skb->dev, NFT_LOOKUP_LISTENER);
 
 	/* NOTE: assign_sock consumes our sk reference */
 	if (sk && nf_tproxy_assign_sock(skb, sk)) {
 		/* This should be in a separate target, but we don't do multiple
 		   targets on the same rule yet */
-		skb->mark = (skb->mark & ~tgi->mark_mask) ^ tgi->mark_value;
+		skb->mark = (skb->mark & ~mark_mask) ^ mark_value;
 
-		pr_debug("redirecting: proto %u %08x:%u -> %08x:%u, mark: %x\n",
-			 iph->protocol, ntohl(iph->daddr), ntohs(hp->dest),
-			 ntohl(tgi->laddr), ntohs(tgi->lport), skb->mark);
+		pr_debug("redirecting: proto %u %pI4:%u -> %pI4:%u, mark: %x\n",
+			 iph->protocol, &iph->daddr, ntohs(hp->dest),
+			 &laddr, ntohs(lport), skb->mark);
 		return NF_ACCEPT;
 	}
 
 	pr_debug("no socket, dropping: proto %u %08x:%u -> %08x:%u, mark: %x\n",
 		 iph->protocol, ntohl(iph->daddr), ntohs(hp->dest),
-		 ntohl(tgi->laddr), ntohs(tgi->lport), skb->mark);
+		 ntohl(laddr), ntohs(lport), skb->mark);
+	return NF_DROP;
+}
+
+static unsigned int
+tproxy_tg4_v0(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_tproxy_target_info_v0 *tgi = par->targinfo;
+
+	return tproxy_tg4(skb, tgi->laddr, tgi->lport, tgi->mark_mask, tgi->mark_value);
+}
+
+static unsigned int
+tproxy_tg4_v1(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_tproxy_target_info_v1 *tgi = par->targinfo;
+
+	return tproxy_tg4(skb, tgi->laddr.ip, tgi->lport, tgi->mark_mask, tgi->mark_value);
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static unsigned int
+tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct xt_tproxy_target_info_v1 *tgi = par->targinfo;
+	struct udphdr _hdr, *hp;
+	struct sock *sk;
+	int thoff;
+	int tproto;
+
+	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL);
+	if (tproto < 0) {
+		pr_debug("unable to find transport header in IPv6 packet, dropping\n");
+		return NF_DROP;
+	}
+
+	hp = skb_header_pointer(skb, thoff, sizeof(_hdr), &_hdr);
+	if (hp == NULL) {
+		pr_debug("unable to grab transport header contents in IPv6 packet, dropping\n");
+		return NF_DROP;
+	}
+
+	/* check if there's an ongoing connection on the packet
+	 * addresses, this happens if the redirect already happened
+	 * and the current packet belongs to an already established
+	 * connection */
+	sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+				   &iph->saddr, &iph->daddr,
+				   hp->source, hp->dest,
+				   par->in, NFT_LOOKUP_ESTABLISHED);
+
+	/* UDP has no TCP_TIME_WAIT state, so we never enter here */
+	if (sk && sk->sk_state == TCP_TIME_WAIT)
+		/* reopening a TIME_WAIT connection needs special handling */
+		sk = tproxy_handle_time_wait6(skb, tproto, thoff, par, sk);
+	else if (!sk)
+		/* no there's no established connection, check if
+		 * there's a listener on the redirected addr/port */
+		sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+					   &iph->saddr,
+					   !ipv6_addr_any(&tgi->laddr.in6) ? &tgi->laddr.in6 : &iph->daddr,
+					   hp->source,
+					   tgi->lport ? tgi->lport : hp->dest,
+					   par->in, NFT_LOOKUP_LISTENER);
+
+	/* NOTE: assign_sock consumes our sk reference */
+	if (sk && nf_tproxy_assign_sock(skb, sk)) {
+		/* This should be in a separate target, but we don't do multiple
+		   targets on the same rule yet */
+		skb->mark = (skb->mark & ~tgi->mark_mask) ^ tgi->mark_value;
+
+		pr_debug("redirecting: proto %u %pI6:%u -> %pI6:%u, mark: %x\n",
+			 tproto, &iph->saddr, ntohs(hp->dest),
+			 &tgi->laddr.in6, ntohs(tgi->lport), skb->mark);
+		return NF_ACCEPT;
+	}
+
+	pr_debug("no socket, dropping: proto %u %pI6:%u -> %pI6:%u, mark: %x\n",
+		 tproto, &iph->saddr, ntohs(hp->dest),
+		 &tgi->laddr.in6, ntohs(tgi->lport), skb->mark);
 	return NF_DROP;
 }
 
-static int tproxy_tg_check(const struct xt_tgchk_param *par)
+static int tproxy_tg6_check(const struct xt_tgchk_param *par)
+{
+	const struct ip6t_ip6 *i = par->entryinfo;
+
+	if ((i->proto == IPPROTO_TCP || i->proto == IPPROTO_UDP)
+	    && !(i->flags & IP6T_INV_PROTO))
+		return 0;
+
+	pr_info("Can be used only in combination with "
+		"either -p tcp or -p udp\n");
+	return -EINVAL;
+}
+#endif
+
+static int tproxy_tg4_check(const struct xt_tgchk_param *par)
 {
 	const struct ipt_ip *i = par->entryinfo;
 
@@ -132,31 +287,64 @@ static int tproxy_tg_check(const struct xt_tgchk_param *par)
 	return -EINVAL;
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
+		.revision	= 0,
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
+		.revision	= 1,
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
+		.revision	= 1,
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
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	nf_defrag_ipv6_enable();
+#endif
+
+	return xt_register_targets(tproxy_tg_reg, ARRAY_SIZE(tproxy_tg_reg));
 }
 
 static void __exit tproxy_tg_exit(void)
 {
-	xt_unregister_target(&tproxy_tg_reg);
+	xt_unregister_targets(tproxy_tg_reg, ARRAY_SIZE(tproxy_tg_reg));
 }
 
 module_init(tproxy_tg_init);
 module_exit(tproxy_tg_exit);
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Krisztian Kovacs");
+MODULE_AUTHOR("Balazs Scheidler, Krisztian Kovacs");
 MODULE_DESCRIPTION("Netfilter transparent proxy (TPROXY) target module.");
 MODULE_ALIAS("ipt_TPROXY");
+MODULE_ALIAS("ip6t_TPROXY");


