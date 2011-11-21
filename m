From: kaber@trash.net
Subject: [PATCH 12/17] netfilter: ipv6: add IPv6 NAT support
Date: Mon, 21 Nov 2011 06:46:04 +0100
Message-ID: <1321854369-3432-13-git-send-email-kaber@trash.net>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61110 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab1KUFrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:47:48 -0500
In-Reply-To: <1321854369-3432-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nfnetlink_conntrack.h  |    2 +
 include/net/netfilter/nf_nat_l3proto.h         |    5 +
 include/net/netfilter/nf_nat_l4proto.h         |    1 +
 include/net/netns/ipv6.h                       |    1 +
 net/core/secure_seq.c                          |    1 +
 net/ipv6/netfilter/Kconfig                     |   12 +
 net/ipv6/netfilter/Makefile                    |    4 +
 net/ipv6/netfilter/ip6table_nat.c              |  318 ++++++++++++++++++++++++
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   14 +
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       |  285 +++++++++++++++++++++
 net/ipv6/netfilter/nf_nat_proto_icmpv6.c       |   88 +++++++
 net/netfilter/nf_nat_core.c                    |    2 +
 net/netfilter/xt_nat.c                         |    2 +
 13 files changed, 735 insertions(+), 0 deletions(-)
 create mode 100644 net/ipv6/netfilter/ip6table_nat.c
 create mode 100644 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
 create mode 100644 net/ipv6/netfilter/nf_nat_proto_icmpv6.c

diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index 5f0bed8..2c5c304 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -143,6 +143,8 @@ enum ctattr_nat {
 	CTA_NAT_V4_MAXIP,
 #define CTA_NAT_MAXIP CTA_NAT_V4_MAXIP
 	CTA_NAT_PROTO,
+	CTA_NAT_V6_MINIP,
+	CTA_NAT_V6_MAXIP,
 	__CTA_NAT_MAX
 };
 #define CTA_NAT_MAX (__CTA_NAT_MAX - 1)
diff --git a/include/net/netfilter/nf_nat_l3proto.h b/include/net/netfilter/nf_nat_l3proto.h
index 3df4a67..57d9e27 100644
--- a/include/net/netfilter/nf_nat_l3proto.h
+++ b/include/net/netfilter/nf_nat_l3proto.h
@@ -43,5 +43,10 @@ extern int nf_nat_icmp_reply_translation(struct sk_buff *skb,
 					 struct nf_conn *ct,
 					 enum ip_conntrack_info ctinfo,
 					 unsigned int hooknum);
+extern int nf_nat_icmpv6_reply_translation(struct sk_buff *skb,
+					   struct nf_conn *ct,
+					   enum ip_conntrack_info ctinfo,
+					   unsigned int hooknum,
+					   unsigned int hdrlen);
 
 #endif /* _NF_NAT_L3PROTO_H */
diff --git a/include/net/netfilter/nf_nat_l4proto.h b/include/net/netfilter/nf_nat_l4proto.h
index c340480..b82221e 100644
--- a/include/net/netfilter/nf_nat_l4proto.h
+++ b/include/net/netfilter/nf_nat_l4proto.h
@@ -52,6 +52,7 @@ extern const struct nf_nat_l4proto *__nf_nat_l4proto_find(u8 l3proto, u8 l4proto
 extern const struct nf_nat_l4proto nf_nat_l4proto_tcp;
 extern const struct nf_nat_l4proto nf_nat_l4proto_udp;
 extern const struct nf_nat_l4proto nf_nat_l4proto_icmp;
+extern const struct nf_nat_l4proto nf_nat_l4proto_icmpv6;
 extern const struct nf_nat_l4proto nf_nat_l4proto_unknown;
 
 extern bool nf_nat_l4proto_in_range(const struct nf_conntrack_tuple *tuple,
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 81abfcb..049d3a9 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -39,6 +39,7 @@ struct netns_ipv6 {
 #ifdef CONFIG_SECURITY
 	struct xt_table		*ip6table_security;
 #endif
+	struct xt_table		*ip6table_nat;
 #endif
 	struct rt6_info         *ip6_null_entry;
 	struct rt6_statistics   *rt6_stats;
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 45329d7..5c6ae6b 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -74,6 +74,7 @@ u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
 
 	return hash[0];
 }
+EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 #endif
 
 #ifdef CONFIG_INET
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 4484648..ef15839 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -25,6 +25,18 @@ config NF_CONNTRACK_IPV6
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NF_NAT_IPV6
+	tristate "IPv6 NAT"
+	depends on NF_CONNTRACK_IPV6
+	default m if NETFILTER_ADVANCED=n
+	select NF_NAT
+	help
+	  The IPv6 NAT option allows masquerading, port forwarding and other
+	  forms of full Network Address Port Translation. It is controlled by
+	  the `nat' table in ip6tables, see the man page for ip6tables(8).
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP6_NF_QUEUE
 	tristate "IP6 Userspace queueing via NETLINK (OBSOLETE)"
 	depends on INET && IPV6 && NETFILTER
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index abfee91..c709dae 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_IP6_NF_MANGLE) += ip6table_mangle.o
 obj-$(CONFIG_IP6_NF_QUEUE) += ip6_queue.o
 obj-$(CONFIG_IP6_NF_RAW) += ip6table_raw.o
 obj-$(CONFIG_IP6_NF_SECURITY) += ip6table_security.o
+obj-$(CONFIG_NF_NAT_IPV6) += ip6table_nat.o
 
 # objects for l3 independent conntrack
 nf_conntrack_ipv6-y  :=  nf_conntrack_l3proto_ipv6.o nf_conntrack_proto_icmpv6.o
@@ -16,6 +17,9 @@ nf_conntrack_ipv6-y  :=  nf_conntrack_l3proto_ipv6.o nf_conntrack_proto_icmpv6.o
 # l3 independent conntrack
 obj-$(CONFIG_NF_CONNTRACK_IPV6) += nf_conntrack_ipv6.o nf_defrag_ipv6.o
 
+nf_nat_ipv6-y		:= nf_nat_l3proto_ipv6.o nf_nat_proto_icmpv6.o
+obj-$(CONFIG_NF_NAT_IPV6) += nf_nat_ipv6.o
+
 # defrag
 nf_defrag_ipv6-y := nf_defrag_ipv6_hooks.o nf_conntrack_reasm.o
 obj-$(CONFIG_NF_DEFRAG_IPV6) += nf_defrag_ipv6.o
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
new file mode 100644
index 0000000..7fdb6f8
--- /dev/null
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -0,0 +1,318 @@
+/*
+ * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Based on Rusty Russell's IPv4 NAT code. Development of IPv6 NAT
+ * funded by Astaro.
+ */
+
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#include <linux/ipv6.h>
+#include <net/ipv6.h>
+
+#include <net/netfilter/nf_nat.h>
+#include <net/netfilter/nf_nat_core.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+
+static const struct xt_table nf_nat_ipv6_table = {
+	.name		= "nat",
+	.valid_hooks	= (1 << NF_INET_PRE_ROUTING) |
+			  (1 << NF_INET_POST_ROUTING) |
+			  (1 << NF_INET_LOCAL_OUT) |
+			  (1 << NF_INET_LOCAL_IN),
+	.me		= THIS_MODULE,
+	.af		= NFPROTO_IPV6,
+};
+
+static unsigned int alloc_null_binding(struct nf_conn *ct, unsigned int hooknum)
+{
+	/* Force range to this IP; let proto decide mapping for
+	 * per-proto parts (hence not IP_NAT_RANGE_PROTO_SPECIFIED).
+	 */
+	struct nf_nat_range range;
+
+	range.flags = 0;
+	pr_debug("Allocating NULL binding for %p (%pI6)\n", ct,
+		 HOOK2MANIP(hooknum) == NF_NAT_MANIP_SRC ?
+		 &ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip6 :
+		 &ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3.ip6);
+
+	return nf_nat_setup_info(ct, &range, HOOK2MANIP(hooknum));
+}
+
+static unsigned int nf_nat_rule_find(struct sk_buff *skb, unsigned int hooknum,
+				     const struct net_device *in,
+				     const struct net_device *out,
+				     struct nf_conn *ct)
+{
+	struct net *net = nf_ct_net(ct);
+	unsigned int ret;
+
+	ret = ip6t_do_table(skb, hooknum, in, out, net->ipv6.ip6table_nat);
+	if (ret == NF_ACCEPT) {
+		if (!nf_nat_initialized(ct, HOOK2MANIP(hooknum)))
+			ret = alloc_null_binding(ct, hooknum);
+	}
+	return ret;
+}
+
+static unsigned int
+nf_nat_ipv6_fn(unsigned int hooknum,
+	       struct sk_buff *skb,
+	       const struct net_device *in,
+	       const struct net_device *out,
+	       int (*okfn)(struct sk_buff *))
+{
+	struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn_nat *nat;
+	enum nf_nat_manip_type maniptype = HOOK2MANIP(hooknum);
+	int hdrlen;
+	u8 nexthdr;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	/* Can't track?  It's not due to stress, or conntrack would
+	 * have dropped it.  Hence it's the user's responsibilty to
+	 * packet filter it out, or implement conntrack/NAT for that
+	 * protocol. 8) --RR
+	 */
+	if (!ct)
+		return NF_ACCEPT;
+
+	/* Don't try to NAT if this packet is not conntracked */
+	if (nf_ct_is_untracked(ct))
+		return NF_ACCEPT;
+
+	nat = nfct_nat(ct);
+	if (!nat) {
+		/* NAT module was loaded late. */
+		if (nf_ct_is_confirmed(ct))
+			return NF_ACCEPT;
+		nat = nf_ct_ext_add(ct, NF_CT_EXT_NAT, GFP_ATOMIC);
+		if (nat == NULL) {
+			pr_debug("failed to add NAT extension\n");
+			return NF_ACCEPT;
+		}
+	}
+
+	switch (ctinfo) {
+	case IP_CT_RELATED:
+	case IP_CT_RELATED_REPLY:
+		nexthdr = ipv6_hdr(skb)->nexthdr;
+		hdrlen = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr), &nexthdr);
+
+		if (hdrlen >= 0 && nexthdr == IPPROTO_ICMPV6) {
+			if (!nf_nat_icmpv6_reply_translation(skb, ct, ctinfo,
+							     hooknum, hdrlen))
+				return NF_DROP;
+			else
+				return NF_ACCEPT;
+		}
+		/* Fall thru... (Only ICMPs can be IP_CT_IS_REPLY) */
+	case IP_CT_NEW:
+		/* Seen it before?  This can happen for loopback, retrans,
+		 * or local packets.
+		 */
+		if (!nf_nat_initialized(ct, maniptype)) {
+			unsigned int ret;
+
+			ret = nf_nat_rule_find(skb, hooknum, in, out, ct);
+			if (ret != NF_ACCEPT)
+				return ret;
+		} else
+			pr_debug("Already setup manip %s for ct %p\n",
+				 maniptype == NF_NAT_MANIP_SRC ? "SRC" : "DST",
+				 ct);
+		break;
+
+	default:
+		/* ESTABLISHED */
+		NF_CT_ASSERT(ctinfo == IP_CT_ESTABLISHED ||
+			     ctinfo == IP_CT_ESTABLISHED_REPLY);
+	}
+
+	return nf_nat_packet(ct, ctinfo, hooknum, skb);
+}
+
+static unsigned int
+nf_nat_ipv6_in(unsigned int hooknum,
+	       struct sk_buff *skb,
+	       const struct net_device *in,
+	       const struct net_device *out,
+	       int (*okfn)(struct sk_buff *))
+{
+	unsigned int ret;
+	struct in6_addr daddr = ipv6_hdr(skb)->daddr;
+
+	ret = nf_nat_ipv6_fn(hooknum, skb, in, out, okfn);
+	if (ret != NF_DROP && ret != NF_STOLEN &&
+	    ipv6_addr_cmp(&daddr, &ipv6_hdr(skb)->daddr))
+		skb_dst_drop(skb);
+
+	return ret;
+}
+
+static unsigned int
+nf_nat_ipv6_out(unsigned int hooknum,
+		struct sk_buff *skb,
+		const struct net_device *in,
+		const struct net_device *out,
+		int (*okfn)(struct sk_buff *))
+{
+#ifdef CONFIG_XFRM
+	const struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+#endif
+	unsigned int ret;
+
+	/* root is playing with raw sockets. */
+	if (skb->len < sizeof(struct ipv6hdr))
+		return NF_ACCEPT;
+
+	ret = nf_nat_ipv6_fn(hooknum, skb, in, out, okfn);
+#ifdef CONFIG_XFRM
+	if (ret != NF_DROP && ret != NF_STOLEN &&
+	    !(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
+	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
+		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+
+		if (!nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.src.u3,
+				      &ct->tuplehash[!dir].tuple.dst.u3) ||
+		    (ct->tuplehash[dir].tuple.src.u.all !=
+		     ct->tuplehash[!dir].tuple.dst.u.all))
+			if (nf_xfrm_me_harder(skb, AF_INET6) < 0)
+				ret = NF_DROP;
+	}
+#endif
+	return ret;
+}
+
+static unsigned int
+nf_nat_ipv6_local_fn(unsigned int hooknum,
+		     struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out,
+		     int (*okfn)(struct sk_buff *))
+{
+	const struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+	unsigned int ret;
+
+	/* root is playing with raw sockets. */
+	if (skb->len < sizeof(struct ipv6hdr))
+		return NF_ACCEPT;
+
+	ret = nf_nat_ipv6_fn(hooknum, skb, in, out, okfn);
+	if (ret != NF_DROP && ret != NF_STOLEN &&
+	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
+		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+
+		if (!nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.dst.u3,
+				      &ct->tuplehash[!dir].tuple.src.u3)) {
+			if (ip6_route_me_harder(skb))
+				ret = NF_DROP;
+		}
+#ifdef CONFIG_XFRM
+		else if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
+			 ct->tuplehash[dir].tuple.dst.u.all !=
+			 ct->tuplehash[!dir].tuple.src.u.all)
+			if (nf_xfrm_me_harder(skb, AF_INET6))
+				ret = NF_DROP;
+#endif
+	}
+	return ret;
+}
+
+static struct nf_hook_ops nf_nat_ipv6_ops[] __read_mostly = {
+	/* Before packet filtering, change destination */
+	{
+		.hook		= nf_nat_ipv6_in,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_PRE_ROUTING,
+		.priority	= NF_IP_PRI_NAT_DST,
+	},
+	/* After packet filtering, change source */
+	{
+		.hook		= nf_nat_ipv6_out,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_POST_ROUTING,
+		.priority	= NF_IP_PRI_NAT_SRC,
+	},
+	/* Before packet filtering, change destination */
+	{
+		.hook		= nf_nat_ipv6_local_fn,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_LOCAL_OUT,
+		.priority	= NF_IP_PRI_NAT_DST,
+	},
+	/* After packet filtering, change source */
+	{
+		.hook		= nf_nat_ipv6_fn,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_LOCAL_IN,
+		.priority	= NF_IP_PRI_NAT_SRC,
+	},
+};
+
+static int __net_init ip6table_nat_net_init(struct net *net)
+{
+	struct ip6t_replace *repl;
+
+	repl = ip6t_alloc_initial_table(&nf_nat_ipv6_table);
+	if (repl == NULL)
+		return -ENOMEM;
+	net->ipv6.ip6table_nat = ip6t_register_table(net, &nf_nat_ipv6_table, repl);
+	kfree(repl);
+	if (IS_ERR(net->ipv6.ip6table_nat))
+		return PTR_ERR(net->ipv6.ip6table_nat);
+	return 0;
+}
+
+static void __net_exit ip6table_nat_net_exit(struct net *net)
+{
+	ip6t_unregister_table(net, net->ipv6.ip6table_nat);
+}
+
+static struct pernet_operations ip6table_nat_net_ops = {
+	.init	= ip6table_nat_net_init,
+	.exit	= ip6table_nat_net_exit,
+};
+
+static int __init ip6table_nat_init(void)
+{
+	int err;
+
+	err = register_pernet_subsys(&ip6table_nat_net_ops);
+	if (err < 0)
+		goto err1;
+
+	err = nf_register_hooks(nf_nat_ipv6_ops, ARRAY_SIZE(nf_nat_ipv6_ops));
+	if (err < 0)
+		goto err2;
+	return 0;
+
+err2:
+	unregister_pernet_subsys(&ip6table_nat_net_ops);
+err1:
+	return err;
+}
+
+static void __exit ip6table_nat_exit(void)
+{
+	nf_unregister_hooks(nf_nat_ipv6_ops, ARRAY_SIZE(nf_nat_ipv6_ops));
+	unregister_pernet_subsys(&ip6table_nat_net_ops);
+}
+
+module_init(ip6table_nat_init);
+module_exit(ip6table_nat_exit);
+
+MODULE_LICENSE("GPL");
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 4111050..e6cc7ac 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -28,6 +28,7 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
+#include <net/netfilter/nf_nat_helper.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 #include <net/netfilter/nf_log.h>
 
@@ -184,6 +185,19 @@ static unsigned int ipv6_confirm(unsigned int hooknum,
 			      "nf_ct_%s: dropping packet", helper->name);
 		return ret;
 	}
+
+	/* adjust seqs for loopback traffic only in outgoing direction */
+	if (test_bit(IPS_SEQ_ADJUST_BIT, &ct->status) &&
+	    !nf_is_loopback_packet(skb)) {
+		typeof(nf_nat_seq_adjust_hook) seq_adjust;
+
+		seq_adjust = rcu_dereference(nf_nat_seq_adjust_hook);
+		if (!seq_adjust ||
+		    !seq_adjust(skb, ct, ctinfo, protoff)) {
+			NF_CT_STAT_INC_ATOMIC(nf_ct_net(ct), drop);
+			return NF_DROP;
+		}
+	}
 out:
 	/* We've seen it coming out the other side: confirm it */
 	return nf_conntrack_confirm(skb);
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
new file mode 100644
index 0000000..42d801d
--- /dev/null
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -0,0 +1,285 @@
+/*
+ * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Development of IPv6 NAT funded by Astaro.
+ */
+
+#include <linux/types.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ipv6.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
+#include <net/secure_seq.h>
+#include <net/checksum.h>
+#include <net/ip6_route.h>
+#include <net/ipv6.h>
+
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_nat_core.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/netfilter/nf_nat_l4proto.h>
+
+static const struct nf_nat_l3proto nf_nat_l3proto_ipv6;
+
+#ifdef CONFIG_XFRM
+static void nf_nat_ipv6_decode_session(struct sk_buff *skb,
+				       const struct nf_conn *ct,
+				       enum ip_conntrack_dir dir,
+				       unsigned long statusbit,
+				       struct flowi *fl)
+{
+	const struct nf_conntrack_tuple *t = &ct->tuplehash[dir].tuple;
+	struct flowi6 *fl6 = &fl->u.ip6;
+
+	if (ct->status & statusbit) {
+		fl6->daddr = t->dst.u3.in6;
+		if (t->dst.protonum == IPPROTO_TCP ||
+		    t->dst.protonum == IPPROTO_UDP ||
+		    t->dst.protonum == IPPROTO_UDPLITE ||
+		    t->dst.protonum == IPPROTO_DCCP ||
+		    t->dst.protonum == IPPROTO_SCTP)
+			fl6->fl6_dport = t->dst.u.all;
+	}
+
+	statusbit ^= IPS_NAT_MASK;
+
+	if (ct->status & statusbit) {
+		fl6->saddr = t->src.u3.in6;
+		if (t->dst.protonum == IPPROTO_TCP ||
+		    t->dst.protonum == IPPROTO_UDP ||
+		    t->dst.protonum == IPPROTO_UDPLITE ||
+		    t->dst.protonum == IPPROTO_DCCP ||
+		    t->dst.protonum == IPPROTO_SCTP)
+			fl6->fl6_sport = t->src.u.all;
+	}
+}
+#endif
+
+static int nf_nat_ipv6_in_range(const struct nf_conntrack_tuple *t,
+				const struct nf_nat_range *range)
+{
+	return ipv6_addr_cmp(&t->src.u3.in6, &range->min_addr.in6) >= 0 &&
+	       ipv6_addr_cmp(&t->src.u3.in6, &range->max_addr.in6) <= 0;
+}
+
+static u32 nf_nat_ipv6_secure_port(const struct nf_conntrack_tuple *t,
+				   __be16 dport)
+{
+	return secure_ipv6_port_ephemeral(t->src.u3.ip6, t->dst.u3.ip6, dport);
+}
+
+static bool nf_nat_ipv6_manip_pkt(struct sk_buff *skb,
+				  unsigned int iphdroff,
+				  const struct nf_nat_l4proto *l4proto,
+				  const struct nf_conntrack_tuple *target,
+				  enum nf_nat_manip_type maniptype)
+{
+	struct ipv6hdr *ipv6h;
+	int hdroff;
+	u8 nexthdr;
+
+	if (!skb_make_writable(skb, iphdroff + sizeof(*ipv6h)))
+		return false;
+
+	ipv6h = (void *)skb->data + iphdroff;
+	nexthdr = ipv6h->nexthdr;
+	hdroff = ipv6_skip_exthdr(skb, iphdroff + sizeof(*ipv6h), &nexthdr);
+	if (hdroff < 0)
+		return false; // FIXME: indicate success?
+
+	if (!l4proto->manip_pkt(skb, &nf_nat_l3proto_ipv6, iphdroff, hdroff,
+				target, maniptype))
+		return false;
+
+	if (maniptype == NF_NAT_MANIP_SRC)
+		ipv6_addr_copy(&ipv6h->saddr, &target->src.u3.in6);
+	else
+		ipv6_addr_copy(&ipv6h->daddr, &target->dst.u3.in6);
+
+	return true;
+}
+
+static void nf_nat_ipv6_csum_update(struct sk_buff *skb,
+				    unsigned int iphdroff, __sum16 *check,
+				    const struct nf_conntrack_tuple *t,
+				    enum nf_nat_manip_type maniptype)
+{
+	const struct ipv6hdr *ipv6h = (struct ipv6hdr *)(skb->data + iphdroff);
+	const struct in6_addr *oldip, *newip;
+
+	if (maniptype == NF_NAT_MANIP_SRC) {
+		oldip = &ipv6h->saddr;
+		newip = &t->src.u3.in6;
+	} else {
+		oldip = &ipv6h->daddr;
+		newip = &t->dst.u3.in6;
+	}
+	inet_proto_csum_replace16(check, skb, oldip->s6_addr32,
+				  newip->s6_addr32, 1);
+}
+
+static void nf_nat_ipv6_csum_recalc(struct sk_buff *skb,
+				    u8 proto, void *data, __sum16 *check,
+				    int datalen, int oldlen)
+{
+	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		if (!(rt->rt6i_flags & RTF_LOCAL) && // FIXME
+		    (!skb->dev || skb->dev->features & NETIF_F_V6_CSUM)) {
+			skb->ip_summed = CHECKSUM_PARTIAL;
+			skb->csum_start = skb_headroom(skb) +
+					  skb_network_offset(skb) +
+					  (data - (void *)skb->data);
+			skb->csum_offset = (void *)check - data;
+			*check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
+						  datalen, proto, 0);
+		} else {
+			*check = 0;
+			*check = csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
+						 datalen, proto,
+						 csum_partial(data, datalen,
+							      0));
+			if (proto == IPPROTO_UDP && !*check)
+				*check = CSUM_MANGLED_0;
+		}
+	} else
+		inet_proto_csum_replace2(check, skb,
+					 htons(oldlen), htons(datalen), 1);
+}
+
+static int nf_nat_ipv6_nlattr_to_range(struct nlattr *tb[],
+				       struct nf_nat_range *range)
+{
+	if (tb[CTA_NAT_V6_MINIP]) {
+		nla_memcpy(&range->min_addr.ip6, tb[CTA_NAT_V6_MINIP],
+			   sizeof(struct in6_addr));
+		range->flags |= NF_NAT_RANGE_MAP_IPS;
+	}
+
+	if (tb[CTA_NAT_V6_MAXIP])
+		nla_memcpy(&range->max_addr.ip6, tb[CTA_NAT_V6_MAXIP],
+			   sizeof(struct in6_addr));
+	else
+		range->max_addr = range->min_addr;
+
+	return 0;
+}
+
+static const struct nf_nat_l3proto nf_nat_l3proto_ipv6 = {
+	.l3proto		= NFPROTO_IPV6,
+	.secure_port		= nf_nat_ipv6_secure_port,
+	.in_range		= nf_nat_ipv6_in_range,
+	.manip_pkt		= nf_nat_ipv6_manip_pkt,
+	.csum_update		= nf_nat_ipv6_csum_update,
+	.csum_recalc		= nf_nat_ipv6_csum_recalc,
+	.nlattr_to_range	= nf_nat_ipv6_nlattr_to_range,
+#ifdef CONFIG_XFRM
+	.decode_session	= nf_nat_ipv6_decode_session,
+#endif
+};
+
+int nf_nat_icmpv6_reply_translation(struct sk_buff *skb,
+				    struct nf_conn *ct,
+				    enum ip_conntrack_info ctinfo,
+				    unsigned int hooknum,
+				    unsigned int hdrlen)
+{
+	struct {
+		struct icmp6hdr	icmp6;
+		struct ipv6hdr	ip6;
+	} *inside;
+	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+	enum nf_nat_manip_type manip = HOOK2MANIP(hooknum);
+	const struct nf_nat_l4proto *l4proto;
+	struct nf_conntrack_tuple target;
+	unsigned long statusbit;
+
+	NF_CT_ASSERT(ctinfo == IP_CT_RELATED || ctinfo == IP_CT_RELATED_REPLY);
+
+	if (!skb_make_writable(skb, hdrlen + sizeof(*inside)))
+		return 0;
+	if (nf_ip6_checksum(skb, hooknum, hdrlen, IPPROTO_ICMPV6))
+		return 0;
+
+	inside = (void *)skb->data + hdrlen;
+	if (inside->icmp6.icmp6_type == NDISC_REDIRECT) {
+		if ((ct->status & IPS_NAT_DONE_MASK) != IPS_NAT_DONE_MASK)
+			return 0;
+		if (ct->status & IPS_NAT_MASK)
+			return 0;
+	}
+
+	if (manip == NF_NAT_MANIP_SRC)
+		statusbit = IPS_SRC_NAT;
+	else
+		statusbit = IPS_DST_NAT;
+
+	/* Invert if this is reply direction */
+	if (dir == IP_CT_DIR_REPLY)
+		statusbit ^= IPS_NAT_MASK;
+
+	if (!(ct->status & statusbit))
+		return 1;
+
+	l4proto = __nf_nat_l4proto_find(NFPROTO_IPV6, inside->ip6.nexthdr);
+	if (!nf_nat_ipv6_manip_pkt(skb, hdrlen + sizeof(inside->icmp6),
+				   l4proto, &ct->tuplehash[!dir].tuple, !manip))
+		return 0;
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+		inside = (void *)skb->data + hdrlen;
+		inside->icmp6.icmp6_cksum = 0;
+		inside->icmp6.icmp6_cksum =
+			csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
+					skb->len - hdrlen, IPPROTO_ICMPV6,
+					csum_partial(&inside->icmp6,
+						     skb->len - hdrlen, 0));
+	}
+
+	nf_ct_invert_tuplepr(&target, &ct->tuplehash[!dir].tuple);
+	l4proto = __nf_nat_l4proto_find(NFPROTO_IPV6, IPPROTO_ICMPV6);
+	if (!nf_nat_ipv6_manip_pkt(skb, 0, l4proto, &target, manip))
+		return 0;
+
+	return 1;
+}
+EXPORT_SYMBOL_GPL(nf_nat_icmpv6_reply_translation);
+
+static int __init nf_nat_l3proto_ipv6_init(void)
+{
+	int err;
+
+	err = nf_nat_l3proto_register(&nf_nat_l3proto_ipv6);
+	if (err < 0)
+		goto err1;
+	err = nf_nat_l4proto_register(&nf_nat_l4proto_icmpv6);
+	if (err < 0)
+		goto err2;
+	return err;
+
+err2:
+	nf_nat_l3proto_unregister(&nf_nat_l3proto_ipv6);
+err1:
+	return err;
+}
+
+static void __exit nf_nat_l3proto_ipv6_exit(void)
+{
+	nf_nat_l4proto_unregister(&nf_nat_l4proto_icmpv6);
+	nf_nat_l3proto_unregister(&nf_nat_l3proto_ipv6);
+}
+
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("nf-nat-" __stringify(AF_INET6));
+
+module_init(nf_nat_l3proto_ipv6_init);
+module_exit(nf_nat_l3proto_ipv6_exit);
diff --git a/net/ipv6/netfilter/nf_nat_proto_icmpv6.c b/net/ipv6/netfilter/nf_nat_proto_icmpv6.c
new file mode 100644
index 0000000..32bd6c1
--- /dev/null
+++ b/net/ipv6/netfilter/nf_nat_proto_icmpv6.c
@@ -0,0 +1,88 @@
+/*
+ * Copyright (c) 2011 Patrick Mchardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Based on Rusty Russell's IPv4 ICMP NAT code. Development of IPv6
+ * NAT funded by Astaro.
+ */
+
+#include <linux/types.h>
+#include <linux/init.h>
+#include <linux/icmpv6.h>
+
+#include <linux/netfilter.h>
+#include <net/netfilter/nf_nat.h>
+#include <net/netfilter/nf_nat_core.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/netfilter/nf_nat_l4proto.h>
+
+static bool
+icmpv6_in_range(const struct nf_conntrack_tuple *tuple,
+		enum nf_nat_manip_type maniptype,
+		const union nf_conntrack_man_proto *min,
+		const union nf_conntrack_man_proto *max)
+{
+	return ntohs(tuple->src.u.icmp.id) >= ntohs(min->icmp.id) &&
+	       ntohs(tuple->src.u.icmp.id) <= ntohs(max->icmp.id);
+}
+
+static void
+icmpv6_unique_tuple(const struct nf_nat_l3proto *l3proto,
+		    struct nf_conntrack_tuple *tuple,
+		    const struct nf_nat_range *range,
+		    enum nf_nat_manip_type maniptype,
+		    const struct nf_conn *ct)
+{
+	static u16 id;
+	unsigned int range_size;
+	unsigned int i;
+
+	range_size = ntohs(range->max_proto.icmp.id) -
+		     ntohs(range->min_proto.icmp.id) + 1;
+
+	if (!(range->flags & NF_NAT_RANGE_PROTO_SPECIFIED))
+		range_size = 0xffff;
+
+	for (i = 0; ; ++id) {
+		tuple->src.u.icmp.id = htons(ntohs(range->min_proto.icmp.id) +
+					     (id % range_size));
+		if (++i == range_size || !nf_nat_used_tuple(tuple, ct))
+			return;
+	}
+}
+
+static bool
+icmpv6_manip_pkt(struct sk_buff *skb,
+		 const struct nf_nat_l3proto *l3proto,
+		 unsigned int iphdroff, unsigned int hdroff,
+		 const struct nf_conntrack_tuple *tuple,
+		 enum nf_nat_manip_type maniptype)
+{
+	struct icmp6hdr *hdr;
+
+	if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
+		return false;
+
+	hdr = (struct icmp6hdr *)(skb->data + hdroff);
+	l3proto->csum_update(skb, iphdroff, &hdr->icmp6_cksum,
+			     tuple, maniptype);
+	inet_proto_csum_replace2(&hdr->icmp6_cksum, skb,
+				 hdr->icmp6_identifier,
+				 tuple->src.u.icmp.id, 0);
+	hdr->icmp6_identifier = tuple->src.u.icmp.id;
+	return true;
+}
+
+const struct nf_nat_l4proto nf_nat_l4proto_icmpv6 = {
+	.l3proto		= NFPROTO_IPV6,
+	.l4proto		= IPPROTO_ICMPV6,
+	.manip_pkt		= icmpv6_manip_pkt,
+	.in_range		= icmpv6_in_range,
+	.unique_tuple		= icmpv6_unique_tuple,
+#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
+#endif
+};
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index dcee3b6..15b9262 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -594,6 +594,8 @@ static int nfnetlink_parse_nat_proto(struct nlattr *attr,
 static const struct nla_policy nat_nla_policy[CTA_NAT_MAX+1] = {
 	[CTA_NAT_V4_MINIP]	= { .type = NLA_U32 },
 	[CTA_NAT_V4_MAXIP]	= { .type = NLA_U32 },
+	[CTA_NAT_V6_MINIP]	= { .len = sizeof(struct in6_addr) },
+	[CTA_NAT_V6_MAXIP]	= { .len = sizeof(struct in6_addr) },
 	[CTA_NAT_PROTO]		= { .type = NLA_NESTED },
 };
 
diff --git a/net/netfilter/xt_nat.c b/net/netfilter/xt_nat.c
index 8b94bb8..3a01caf 100644
--- a/net/netfilter/xt_nat.c
+++ b/net/netfilter/xt_nat.c
@@ -180,4 +180,6 @@ module_exit(xt_nat_exit);
 
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_SNAT");
+MODULE_ALIAS("ip6t_SNAT");
 MODULE_ALIAS("ipt_DNAT");
+MODULE_ALIAS("ip6t_DNAT");
-- 
1.7.1
