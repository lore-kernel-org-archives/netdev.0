From: kaber@trash.net
Subject: [PATCH 72/84] netfilter: xtables: inclusion of xt_TEE
Date: Mon, 10 May 2010 22:18:43 +0200
Message-ID: <1273522735-24672-73-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54508 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756939Ab0EJUT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:28 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jan Engelhardt <jengelh@medozas.de>

xt_TEE can be used to clone and reroute a packet. This can for
example be used to copy traffic at a router for logging purposes
to another dedicated machine.

References: http://www.gossamer-threads.com/lists/iptables/devel/68781
Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/Kbuild   |    1 +
 include/linux/netfilter/xt_TEE.h |    9 ++
 net/ipv4/ip_output.c             |    1 +
 net/ipv6/ip6_output.c            |    1 +
 net/netfilter/Kconfig            |    7 +
 net/netfilter/Makefile           |    1 +
 net/netfilter/xt_TEE.c           |  256 ++++++++++++++++++++++++++++++=
++++++++
 7 files changed, 276 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_TEE.h
 create mode 100644 net/netfilter/xt_TEE.c

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/K=
build
index a5a63e4..48767cd 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -16,6 +16,7 @@ header-y +=3D xt_RATEEST.h
 header-y +=3D xt_SECMARK.h
 header-y +=3D xt_TCPMSS.h
 header-y +=3D xt_TCPOPTSTRIP.h
+header-y +=3D xt_TEE.h
 header-y +=3D xt_TPROXY.h
 header-y +=3D xt_comment.h
 header-y +=3D xt_connbytes.h
diff --git a/include/linux/netfilter/xt_TEE.h b/include/linux/netfilter=
/xt_TEE.h
new file mode 100644
index 0000000..55d4a50
--- /dev/null
+++ b/include/linux/netfilter/xt_TEE.h
@@ -0,0 +1,9 @@
+#ifndef _XT_TEE_TARGET_H
+#define _XT_TEE_TARGET_H
+
+struct xt_tee_tginfo {
+	union nf_inet_addr gw;
+	char oif[16];
+};
+
+#endif /* _XT_TEE_TARGET_H */
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index f09135e..0abfdde 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -309,6 +309,7 @@ int ip_output(struct sk_buff *skb)
 			    ip_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
+EXPORT_SYMBOL_GPL(ip_output);
=20
 int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c10a38a..d09be7f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -176,6 +176,7 @@ int ip6_output(struct sk_buff *skb)
 			    ip6_finish_output,
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
+EXPORT_SYMBOL_GPL(ip6_output);
=20
 /*
  *	xmit an sk_buff (used by TCP)
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 8055786..673a6c8 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -502,6 +502,13 @@ config NETFILTER_XT_TARGET_RATEEST
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
+config NETFILTER_XT_TARGET_TEE
+	tristate '"TEE" - packet cloning to alternate destiantion'
+	depends on NETFILTER_ADVANCED
+	---help---
+	This option adds a "TEE" target with which a packet can be cloned and
+	this clone be rerouted to another nexthop.
+
 config NETFILTER_XT_TARGET_TPROXY
 	tristate '"TPROXY" target support (EXPERIMENTAL)'
 	depends on EXPERIMENTAL
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index cd31afe..14e3a8f 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -59,6 +59,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_SECMARK) +=3D xt_SEC=
MARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TPROXY) +=3D xt_TPROXY.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TCPMSS) +=3D xt_TCPMSS.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP) +=3D xt_TCPOPTSTRIP.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_TEE) +=3D xt_TEE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TRACE) +=3D xt_TRACE.o
=20
 # matches
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
new file mode 100644
index 0000000..b3d7301
--- /dev/null
+++ b/net/netfilter/xt_TEE.c
@@ -0,0 +1,256 @@
+/*
+ *	"TEE" target extension for Xtables
+ *	Copyright =C2=A9 Sebastian Cla=C3=9Fen, 2007
+ *	Jan Engelhardt, 2007-2010
+ *
+ *	based on ipt_ROUTE.c from C=C3=A9dric de Launois
+ *	<delaunois@info.ucl.be>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	version 2 or later, as published by the Free Software Foundation.
+ */
+#include <linux/ip.h>
+#include <linux/module.h>
+#include <linux/route.h>
+#include <linux/skbuff.h>
+#include <net/checksum.h>
+#include <net/icmp.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/ip6_route.h>
+#include <net/route.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_TEE.h>
+
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
+#	define WITH_CONNTRACK 1
+#	include <net/netfilter/nf_conntrack.h>
+#endif
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#	define WITH_IPV6 1
+#endif
+
+static const union nf_inet_addr tee_zero_address;
+
+static struct net *pick_net(struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_NS
+	const struct dst_entry *dst;
+
+	if (skb->dev !=3D NULL)
+		return dev_net(skb->dev);
+	dst =3D skb_dst(skb);
+	if (dst !=3D NULL && dst->dev !=3D NULL)
+		return dev_net(dst->dev);
+#endif
+	return &init_net;
+}
+
+static bool tee_tg_route_oif(struct flowi *f, struct net *net,
+			     const struct xt_tee_tginfo *info)
+{
+	const struct net_device *dev;
+
+	if (*info->oif !=3D '\0')
+		return true;
+	dev =3D dev_get_by_name(net, info->oif);
+	if (dev =3D=3D NULL)
+		return false;
+	f->oif =3D dev->ifindex;
+	return true;
+}
+
+static bool
+tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info)
+{
+	const struct iphdr *iph =3D ip_hdr(skb);
+	struct net *net =3D pick_net(skb);
+	struct rtable *rt;
+	struct flowi fl;
+
+	memset(&fl, 0, sizeof(fl));
+	if (!tee_tg_route_oif(&fl, net, info))
+		return false;
+	fl.nl_u.ip4_u.daddr =3D info->gw.ip;
+	fl.nl_u.ip4_u.tos   =3D RT_TOS(iph->tos);
+	fl.nl_u.ip4_u.scope =3D RT_SCOPE_UNIVERSE;
+	if (ip_route_output_key(net, &rt, &fl) !=3D 0)
+		return false;
+
+	dst_release(skb_dst(skb));
+	skb_dst_set(skb, &rt->u.dst);
+	skb->dev      =3D rt->u.dst.dev;
+	skb->protocol =3D htons(ETH_P_IP);
+	return true;
+}
+
+static unsigned int
+tee_tg4(struct sk_buff *skb, const struct xt_target_param *par)
+{
+	const struct xt_tee_tginfo *info =3D par->targinfo;
+	struct iphdr *iph;
+
+	/*
+	 * Copy the skb, and route the copy. Will later return %XT_CONTINUE f=
or
+	 * the original skb, which should continue on its way as if nothing h=
as
+	 * happened. The copy should be independently delivered to the TEE
+	 * --gateway.
+	 */
+	skb =3D pskb_copy(skb, GFP_ATOMIC);
+	if (skb =3D=3D NULL)
+		return XT_CONTINUE;
+
+#ifdef WITH_CONNTRACK
+	/* Avoid counting cloned packets towards the original connection. */
+	nf_conntrack_put(skb->nfct);
+	skb->nfct     =3D &nf_conntrack_untracked.ct_general;
+	skb->nfctinfo =3D IP_CT_NEW;
+	nf_conntrack_get(skb->nfct);
+#endif
+	/*
+	 * If we are in PREROUTING/INPUT, the checksum must be recalculated
+	 * since the length could have changed as a result of defragmentation=
=2E
+	 *
+	 * We also decrease the TTL to mitigate potential TEE loops
+	 * between two hosts.
+	 *
+	 * Set %IP_DF so that the original source is notified of a potentiall=
y
+	 * decreased MTU on the clone route. IPv6 does this too.
+	 */
+	iph =3D ip_hdr(skb);
+	iph->frag_off |=3D htons(IP_DF);
+	if (par->hooknum =3D=3D NF_INET_PRE_ROUTING ||
+	    par->hooknum =3D=3D NF_INET_LOCAL_IN)
+		--iph->ttl;
+	ip_send_check(iph);
+
+	/*
+	 * Xtables is not reentrant currently, so a choice has to be made:
+	 * 1. return absolute verdict for the original and let the cloned
+	 *    packet travel through the chains
+	 * 2. let the original continue travelling and not pass the clone
+	 *    to Xtables.
+	 * #2 is chosen. Normally, we would use ip_local_out for the clone.
+	 * Because iph->check is already correct and we don't pass it to
+	 * Xtables anyway, a shortcut to dst_output [forwards to ip_output] c=
an
+	 * be taken. %IPSKB_REROUTED needs to be set so that ip_output does n=
ot
+	 * invoke POSTROUTING on the cloned packet.
+	 */
+	IPCB(skb)->flags |=3D IPSKB_REROUTED;
+	if (tee_tg_route4(skb, info))
+		ip_output(skb);
+	else
+		kfree_skb(skb);
+
+	return XT_CONTINUE;
+}
+
+#ifdef WITH_IPV6
+static bool
+tee_tg_route6(struct sk_buff *skb, const struct xt_tee_tginfo *info)
+{
+	const struct ipv6hdr *iph =3D ipv6_hdr(skb);
+	struct net *net =3D pick_net(skb);
+	struct dst_entry *dst;
+	struct flowi fl;
+
+	memset(&fl, 0, sizeof(fl));
+	if (!tee_tg_route_oif(&fl, net, info))
+		return false;
+	fl.nl_u.ip6_u.daddr =3D info->gw.in6;
+	fl.nl_u.ip6_u.flowlabel =3D ((iph->flow_lbl[0] & 0xF) << 16) |
+				  (iph->flow_lbl[1] << 8) | iph->flow_lbl[2];
+	dst =3D ip6_route_output(net, NULL, &fl);
+	if (dst =3D=3D NULL)
+		return false;
+
+	dst_release(skb_dst(skb));
+	skb_dst_set(skb, dst);
+	skb->dev      =3D dst->dev;
+	skb->protocol =3D htons(ETH_P_IPV6);
+	return true;
+}
+
+static unsigned int
+tee_tg6(struct sk_buff *skb, const struct xt_target_param *par)
+{
+	const struct xt_tee_tginfo *info =3D par->targinfo;
+
+	skb =3D pskb_copy(skb, GFP_ATOMIC);
+	if (skb =3D=3D NULL)
+		return XT_CONTINUE;
+
+#ifdef WITH_CONNTRACK
+	nf_conntrack_put(skb->nfct);
+	skb->nfct     =3D &nf_conntrack_untracked.ct_general;
+	skb->nfctinfo =3D IP_CT_NEW;
+	nf_conntrack_get(skb->nfct);
+#endif
+	if (par->hooknum =3D=3D NF_INET_PRE_ROUTING ||
+	    par->hooknum =3D=3D NF_INET_LOCAL_IN) {
+		struct ipv6hdr *iph =3D ipv6_hdr(skb);
+		--iph->hop_limit;
+	}
+	IP6CB(skb)->flags |=3D IP6SKB_REROUTED;
+	if (tee_tg_route6(skb, info))
+		ip6_output(skb);
+	else
+		kfree_skb(skb);
+
+	return XT_CONTINUE;
+}
+#endif /* WITH_IPV6 */
+
+static int tee_tg_check(const struct xt_tgchk_param *par)
+{
+	const struct xt_tee_tginfo *info =3D par->targinfo;
+
+	if (info->oif[sizeof(info->oif)-1] !=3D '\0')
+		return -EINVAL;
+	/* 0.0.0.0 and :: not allowed */
+	return (memcmp(&info->gw, &tee_zero_address,
+	       sizeof(tee_zero_address)) =3D=3D 0) ? -EINVAL : 0;
+}
+
+static struct xt_target tee_tg_reg[] __read_mostly =3D {
+	{
+		.name       =3D "TEE",
+		.revision   =3D 1,
+		.family     =3D NFPROTO_IPV4,
+		.target     =3D tee_tg4,
+		.targetsize =3D sizeof(struct xt_tee_tginfo),
+		.checkentry =3D tee_tg_check,
+		.me         =3D THIS_MODULE,
+	},
+#ifdef WITH_IPV6
+	{
+		.name       =3D "TEE",
+		.revision   =3D 1,
+		.family     =3D NFPROTO_IPV6,
+		.target     =3D tee_tg6,
+		.targetsize =3D sizeof(struct xt_tee_tginfo),
+		.checkentry =3D tee_tg_check,
+		.me         =3D THIS_MODULE,
+	},
+#endif
+};
+
+static int __init tee_tg_init(void)
+{
+	return xt_register_targets(tee_tg_reg, ARRAY_SIZE(tee_tg_reg));
+}
+
+static void __exit tee_tg_exit(void)
+{
+	xt_unregister_targets(tee_tg_reg, ARRAY_SIZE(tee_tg_reg));
+}
+
+module_init(tee_tg_init);
+module_exit(tee_tg_exit);
+MODULE_AUTHOR("Sebastian Cla=C3=9Fen <sebastian.classen@freenet.ag>");
+MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
+MODULE_DESCRIPTION("Xtables: Reroute packet copy");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_TEE");
+MODULE_ALIAS("ip6t_TEE");
--=20
1.7.0.4

