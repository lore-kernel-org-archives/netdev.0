From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: =?y?q?=5BPATCH=2003/15=5D=20netfilter=3A=20factor=20out=20packet=20duplication=20for=20IPv4/IPv6?=
Date: Wed, 19 Aug 2015 21:18:19 +0200
Message-ID: <1440011911-4359-4-git-send-email-pablo@netfilter.org>
References: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=y
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44890 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751743AbbHSTMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 15:12:37 -0400
In-Reply-To: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extracted from the xtables TEE target. This creates two new modules for=
 IPv4
and IPv6 that are shared between the TEE target and the new nf_tables d=
up
expressions.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv4/nf_dup_ipv4.h |    7 ++
 include/net/netfilter/ipv6/nf_dup_ipv6.h |    7 ++
 net/ipv4/netfilter/Kconfig               |    6 ++
 net/ipv4/netfilter/Makefile              |    2 +
 net/ipv4/netfilter/nf_dup_ipv4.c         |  120 ++++++++++++++++++++++=
+
 net/ipv6/netfilter/Kconfig               |    6 ++
 net/ipv6/netfilter/Makefile              |    2 +
 net/ipv6/netfilter/nf_dup_ipv6.c         |   96 ++++++++++++++++++
 net/netfilter/Kconfig                    |    2 +
 net/netfilter/xt_TEE.c                   |  158 ++--------------------=
--------
 10 files changed, 254 insertions(+), 152 deletions(-)
 create mode 100644 include/net/netfilter/ipv4/nf_dup_ipv4.h
 create mode 100644 include/net/netfilter/ipv6/nf_dup_ipv6.h
 create mode 100644 net/ipv4/netfilter/nf_dup_ipv4.c
 create mode 100644 net/ipv6/netfilter/nf_dup_ipv6.c

diff --git a/include/net/netfilter/ipv4/nf_dup_ipv4.h b/include/net/net=
filter/ipv4/nf_dup_ipv4.h
new file mode 100644
index 0000000..42008f1
--- /dev/null
+++ b/include/net/netfilter/ipv4/nf_dup_ipv4.h
@@ -0,0 +1,7 @@
+#ifndef _NF_DUP_IPV4_H_
+#define _NF_DUP_IPV4_H_
+
+void nf_dup_ipv4(struct sk_buff *skb, unsigned int hooknum,
+		 const struct in_addr *gw, int oif);
+
+#endif /* _NF_DUP_IPV4_H_ */
diff --git a/include/net/netfilter/ipv6/nf_dup_ipv6.h b/include/net/net=
filter/ipv6/nf_dup_ipv6.h
new file mode 100644
index 0000000..ed6bd66
--- /dev/null
+++ b/include/net/netfilter/ipv6/nf_dup_ipv6.h
@@ -0,0 +1,7 @@
+#ifndef _NF_DUP_IPV6_H_
+#define _NF_DUP_IPV6_H_
+
+void nf_dup_ipv6(struct sk_buff *skb, unsigned int hooknum,
+		 const struct in6_addr *gw, int oif);
+
+#endif /* _NF_DUP_IPV6_H_ */
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 2199a5d..0142ea2 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -67,6 +67,12 @@ config NF_TABLES_ARP
=20
 endif # NF_TABLES
=20
+config NF_DUP_IPV4
+	tristate "Netfilter IPv4 packet duplication to alternate destination"
+	help
+	  This option enables the nf_dup_ipv4 core, which duplicates an IPv4
+	  packet to be rerouted to another destination.
+
 config NF_LOG_ARP
 	tristate "ARP packet logging"
 	default m if NETFILTER_ADVANCED=3Dn
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 7fe6c70..9136ffc 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -70,3 +70,5 @@ obj-$(CONFIG_IP_NF_ARP_MANGLE) +=3D arpt_mangle.o
=20
 # just filtering instance of ARP tables for now
 obj-$(CONFIG_IP_NF_ARPFILTER) +=3D arptable_filter.o
+
+obj-$(CONFIG_NF_DUP_IPV4) +=3D nf_dup_ipv4.o
diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_d=
up_ipv4.c
new file mode 100644
index 0000000..eff85ab
--- /dev/null
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -0,0 +1,120 @@
+/*
+ * (C) 2007 by Sebastian Cla=C3=9Fen <sebastian.classen@freenet.ag>
+ * (C) 2007-2010 by Jan Engelhardt <jengelh@medozas.de>
+ *
+ * Extracted from xt_TEE.c
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License version 2 or late=
r, as
+ * published by the Free Software Foundation.
+ */
+#include <linux/ip.h>
+#include <linux/module.h>
+#include <linux/percpu.h>
+#include <linux/route.h>
+#include <linux/skbuff.h>
+#include <net/checksum.h>
+#include <net/icmp.h>
+#include <net/ip.h>
+#include <net/route.h>
+#include <net/netfilter/ipv4/nf_dup_ipv4.h>
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+#include <net/netfilter/nf_conntrack.h>
+#endif
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
+static bool nf_dup_ipv4_route(struct sk_buff *skb, const struct in_add=
r *gw,
+			      int oif)
+{
+	const struct iphdr *iph =3D ip_hdr(skb);
+	struct net *net =3D pick_net(skb);
+	struct rtable *rt;
+	struct flowi4 fl4;
+
+	memset(&fl4, 0, sizeof(fl4));
+	if (oif !=3D -1)
+		fl4.flowi4_oif =3D oif;
+
+	fl4.daddr =3D gw->s_addr;
+	fl4.flowi4_tos =3D RT_TOS(iph->tos);
+	fl4.flowi4_scope =3D RT_SCOPE_UNIVERSE;
+	fl4.flowi4_flags =3D FLOWI_FLAG_KNOWN_NH;
+	rt =3D ip_route_output_key(net, &fl4);
+	if (IS_ERR(rt))
+		return false;
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->dst);
+	skb->dev      =3D rt->dst.dev;
+	skb->protocol =3D htons(ETH_P_IP);
+
+	return true;
+}
+
+void nf_dup_ipv4(struct sk_buff *skb, unsigned int hooknum,
+		 const struct in_addr *gw, int oif)
+{
+	struct iphdr *iph;
+
+	if (__this_cpu_read(nf_skb_duplicated))
+		return;
+	/*
+	 * Copy the skb, and route the copy. Will later return %XT_CONTINUE f=
or
+	 * the original skb, which should continue on its way as if nothing h=
as
+	 * happened. The copy should be independently delivered to the gatewa=
y.
+	 */
+	skb =3D pskb_copy(skb, GFP_ATOMIC);
+	if (skb =3D=3D NULL)
+		return;
+
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	/* Avoid counting cloned packets towards the original connection. */
+	nf_conntrack_put(skb->nfct);
+	skb->nfct     =3D &nf_ct_untracked_get()->ct_general;
+	skb->nfctinfo =3D IP_CT_NEW;
+	nf_conntrack_get(skb->nfct);
+#endif
+	/*
+	 * If we are in PREROUTING/INPUT, the checksum must be recalculated
+	 * since the length could have changed as a result of defragmentation=
=2E
+	 *
+	 * We also decrease the TTL to mitigate potential loops between two
+	 * hosts.
+	 *
+	 * Set %IP_DF so that the original source is notified of a potentiall=
y
+	 * decreased MTU on the clone route. IPv6 does this too.
+	 */
+	iph =3D ip_hdr(skb);
+	iph->frag_off |=3D htons(IP_DF);
+	if (hooknum =3D=3D NF_INET_PRE_ROUTING ||
+	    hooknum =3D=3D NF_INET_LOCAL_IN)
+		--iph->ttl;
+	ip_send_check(iph);
+
+	if (nf_dup_ipv4_route(skb, gw, oif)) {
+		__this_cpu_write(nf_skb_duplicated, true);
+		ip_local_out(skb);
+		__this_cpu_write(nf_skb_duplicated, false);
+	} else {
+		kfree_skb(skb);
+	}
+}
+EXPORT_SYMBOL_GPL(nf_dup_ipv4);
+
+MODULE_AUTHOR("Sebastian Cla=C3=9Fen <sebastian.classen@freenet.ag>");
+MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
+MODULE_DESCRIPTION("nf_dup_ipv4: Duplicate IPv4 packet");
+MODULE_LICENSE("GPL");
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index b552cf0..298daf3 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -50,6 +50,12 @@ config NFT_REJECT_IPV6
 endif # NF_TABLES_IPV6
 endif # NF_TABLES
=20
+config NF_DUP_IPV6
+	tristate "Netfilter IPv6 packet duplication to alternate destination"
+	help
+	  This option enables the nf_dup_ipv6 core, which duplicates an IPv6
+	  packet to be rerouted to another destination.
+
 config NF_REJECT_IPV6
 	tristate "IPv6 packet rejection"
 	default m if NETFILTER_ADVANCED=3Dn
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index c36e0a5..dc6c732 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -30,6 +30,8 @@ obj-$(CONFIG_NF_LOG_IPV6) +=3D nf_log_ipv6.o
 # reject
 obj-$(CONFIG_NF_REJECT_IPV6) +=3D nf_reject_ipv6.o
=20
+obj-$(CONFIG_NF_DUP_IPV6) +=3D nf_dup_ipv6.o
+
 # nf_tables
 obj-$(CONFIG_NF_TABLES_IPV6) +=3D nf_tables_ipv6.o
 obj-$(CONFIG_NFT_CHAIN_ROUTE_IPV6) +=3D nft_chain_route_ipv6.o
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_d=
up_ipv6.c
new file mode 100644
index 0000000..399fdda
--- /dev/null
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -0,0 +1,96 @@
+/*
+ * (C) 2007 by Sebastian Cla=C3=9Fen <sebastian.classen@freenet.ag>
+ * (C) 2007-2010 by Jan Engelhardt <jengelh@medozas.de>
+ *
+ * Extracted from xt_TEE.c
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License version 2 or late=
r, as
+ * published by the Free Software Foundation.
+ */
+#include <linux/module.h>
+#include <linux/percpu.h>
+#include <linux/skbuff.h>
+#include <net/ipv6.h>
+#include <net/ip6_route.h>
+#include <net/netfilter/ipv6/nf_dup_ipv6.h>
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+#include <net/netfilter/nf_conntrack.h>
+#endif
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
+static bool nf_dup_ipv6_route(struct sk_buff *skb, const struct in6_ad=
dr *gw,
+			      int oif)
+{
+	const struct ipv6hdr *iph =3D ipv6_hdr(skb);
+	struct net *net =3D pick_net(skb);
+	struct dst_entry *dst;
+	struct flowi6 fl6;
+
+	memset(&fl6, 0, sizeof(fl6));
+	if (oif !=3D -1)
+		fl6.flowi6_oif =3D oif;
+
+	fl6.daddr =3D *gw;
+	fl6.flowlabel =3D ((iph->flow_lbl[0] & 0xF) << 16) |
+			 (iph->flow_lbl[1] << 8) | iph->flow_lbl[2];
+	dst =3D ip6_route_output(net, NULL, &fl6);
+	if (dst->error) {
+		dst_release(dst);
+		return false;
+	}
+	skb_dst_drop(skb);
+	skb_dst_set(skb, dst);
+	skb->dev      =3D dst->dev;
+	skb->protocol =3D htons(ETH_P_IPV6);
+
+	return true;
+}
+
+void nf_dup_ipv6(struct sk_buff *skb, unsigned int hooknum,
+		 const struct in6_addr *gw, int oif)
+{
+	if (__this_cpu_read(nf_skb_duplicated))
+		return;
+	skb =3D pskb_copy(skb, GFP_ATOMIC);
+	if (skb =3D=3D NULL)
+		return;
+
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	nf_conntrack_put(skb->nfct);
+	skb->nfct     =3D &nf_ct_untracked_get()->ct_general;
+	skb->nfctinfo =3D IP_CT_NEW;
+	nf_conntrack_get(skb->nfct);
+#endif
+	if (hooknum =3D=3D NF_INET_PRE_ROUTING ||
+	    hooknum =3D=3D NF_INET_LOCAL_IN) {
+		struct ipv6hdr *iph =3D ipv6_hdr(skb);
+		--iph->hop_limit;
+	}
+	if (nf_dup_ipv6_route(skb, gw, oif)) {
+		__this_cpu_write(nf_skb_duplicated, true);
+		ip6_local_out(skb);
+		__this_cpu_write(nf_skb_duplicated, false);
+	} else {
+		kfree_skb(skb);
+	}
+}
+EXPORT_SYMBOL_GPL(nf_dup_ipv6);
+
+MODULE_AUTHOR("Sebastian Cla=C3=9Fen <sebastian.classen@freenet.ag>");
+MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
+MODULE_DESCRIPTION("nf_dup_ipv6: IPv6 packet duplication");
+MODULE_LICENSE("GPL");
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 6eae69a..3e1b4ab 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -867,6 +867,8 @@ config NETFILTER_XT_TARGET_TEE
 	depends on NETFILTER_ADVANCED
 	depends on IPV6 || IPV6=3Dn
 	depends on !NF_CONNTRACK || NF_CONNTRACK
+	select NF_DUP_IPV4
+	select NF_DUP_IPV6 if IP6_NF_IPTABLES
 	---help---
 	This option adds a "TEE" target with which a packet can be cloned and
 	this clone be rerouted to another nexthop.
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 0ed9fb6..49fee6a 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -10,23 +10,14 @@
  *	modify it under the terms of the GNU General Public License
  *	version 2 or later, as published by the Free Software Foundation.
  */
-#include <linux/ip.h>
 #include <linux/module.h>
-#include <linux/percpu.h>
-#include <linux/route.h>
 #include <linux/skbuff.h>
-#include <linux/notifier.h>
-#include <net/checksum.h>
-#include <net/icmp.h>
-#include <net/ip.h>
-#include <net/ipv6.h>
-#include <net/ip6_route.h>
-#include <net/route.h>
+#include <linux/route.h>
 #include <linux/netfilter/x_tables.h>
+#include <net/route.h>
+#include <net/netfilter/ipv4/nf_dup_ipv4.h>
+#include <net/netfilter/ipv6/nf_dup_ipv6.h>
 #include <linux/netfilter/xt_TEE.h>
-#if IS_ENABLED(CONFIG_NF_CONNTRACK)
-#include <net/netfilter/nf_conntrack.h>
-#endif
=20
 struct xt_tee_priv {
 	struct notifier_block	notifier;
@@ -36,161 +27,24 @@ struct xt_tee_priv {
=20
 static const union nf_inet_addr tee_zero_address;
=20
-static struct net *pick_net(struct sk_buff *skb)
-{
-#ifdef CONFIG_NET_NS
-	const struct dst_entry *dst;
-
-	if (skb->dev !=3D NULL)
-		return dev_net(skb->dev);
-	dst =3D skb_dst(skb);
-	if (dst !=3D NULL && dst->dev !=3D NULL)
-		return dev_net(dst->dev);
-#endif
-	return &init_net;
-}
-
-static bool
-tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info)
-{
-	const struct iphdr *iph =3D ip_hdr(skb);
-	struct net *net =3D pick_net(skb);
-	struct rtable *rt;
-	struct flowi4 fl4;
-
-	memset(&fl4, 0, sizeof(fl4));
-	if (info->priv) {
-		if (info->priv->oif =3D=3D -1)
-			return false;
-		fl4.flowi4_oif =3D info->priv->oif;
-	}
-	fl4.daddr =3D info->gw.ip;
-	fl4.flowi4_tos =3D RT_TOS(iph->tos);
-	fl4.flowi4_scope =3D RT_SCOPE_UNIVERSE;
-	fl4.flowi4_flags =3D FLOWI_FLAG_KNOWN_NH;
-	rt =3D ip_route_output_key(net, &fl4);
-	if (IS_ERR(rt))
-		return false;
-
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
-	skb->dev      =3D rt->dst.dev;
-	skb->protocol =3D htons(ETH_P_IP);
-	return true;
-}
-
 static unsigned int
 tee_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tee_tginfo *info =3D par->targinfo;
-	struct iphdr *iph;
=20
-	if (__this_cpu_read(nf_skb_duplicated))
-		return XT_CONTINUE;
-	/*
-	 * Copy the skb, and route the copy. Will later return %XT_CONTINUE f=
or
-	 * the original skb, which should continue on its way as if nothing h=
as
-	 * happened. The copy should be independently delivered to the TEE
-	 * --gateway.
-	 */
-	skb =3D pskb_copy(skb, GFP_ATOMIC);
-	if (skb =3D=3D NULL)
-		return XT_CONTINUE;
-
-#if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	/* Avoid counting cloned packets towards the original connection. */
-	nf_conntrack_put(skb->nfct);
-	skb->nfct     =3D &nf_ct_untracked_get()->ct_general;
-	skb->nfctinfo =3D IP_CT_NEW;
-	nf_conntrack_get(skb->nfct);
-#endif
-	/*
-	 * If we are in PREROUTING/INPUT, the checksum must be recalculated
-	 * since the length could have changed as a result of defragmentation=
=2E
-	 *
-	 * We also decrease the TTL to mitigate potential TEE loops
-	 * between two hosts.
-	 *
-	 * Set %IP_DF so that the original source is notified of a potentiall=
y
-	 * decreased MTU on the clone route. IPv6 does this too.
-	 */
-	iph =3D ip_hdr(skb);
-	iph->frag_off |=3D htons(IP_DF);
-	if (par->hooknum =3D=3D NF_INET_PRE_ROUTING ||
-	    par->hooknum =3D=3D NF_INET_LOCAL_IN)
-		--iph->ttl;
-	ip_send_check(iph);
+	nf_dup_ipv4(skb, par->hooknum, &info->gw.in, info->priv->oif);
=20
-	if (tee_tg_route4(skb, info)) {
-		__this_cpu_write(nf_skb_duplicated, true);
-		ip_local_out(skb);
-		__this_cpu_write(nf_skb_duplicated, false);
-	} else {
-		kfree_skb(skb);
-	}
 	return XT_CONTINUE;
 }
=20
 #if IS_ENABLED(CONFIG_IPV6)
-static bool
-tee_tg_route6(struct sk_buff *skb, const struct xt_tee_tginfo *info)
-{
-	const struct ipv6hdr *iph =3D ipv6_hdr(skb);
-	struct net *net =3D pick_net(skb);
-	struct dst_entry *dst;
-	struct flowi6 fl6;
-
-	memset(&fl6, 0, sizeof(fl6));
-	if (info->priv) {
-		if (info->priv->oif =3D=3D -1)
-			return false;
-		fl6.flowi6_oif =3D info->priv->oif;
-	}
-	fl6.daddr =3D info->gw.in6;
-	fl6.flowlabel =3D ((iph->flow_lbl[0] & 0xF) << 16) |
-			   (iph->flow_lbl[1] << 8) | iph->flow_lbl[2];
-	fl6.flowi6_flags =3D FLOWI_FLAG_KNOWN_NH;
-	dst =3D ip6_route_output(net, NULL, &fl6);
-	if (dst->error) {
-		dst_release(dst);
-		return false;
-	}
-	skb_dst_drop(skb);
-	skb_dst_set(skb, dst);
-	skb->dev      =3D dst->dev;
-	skb->protocol =3D htons(ETH_P_IPV6);
-	return true;
-}
-
 static unsigned int
 tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tee_tginfo *info =3D par->targinfo;
=20
-	if (__this_cpu_read(nf_skb_duplicated))
-		return XT_CONTINUE;
-	skb =3D pskb_copy(skb, GFP_ATOMIC);
-	if (skb =3D=3D NULL)
-		return XT_CONTINUE;
+	nf_dup_ipv6(skb, par->hooknum, &info->gw.in6, info->priv->oif);
=20
-#if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	nf_conntrack_put(skb->nfct);
-	skb->nfct     =3D &nf_ct_untracked_get()->ct_general;
-	skb->nfctinfo =3D IP_CT_NEW;
-	nf_conntrack_get(skb->nfct);
-#endif
-	if (par->hooknum =3D=3D NF_INET_PRE_ROUTING ||
-	    par->hooknum =3D=3D NF_INET_LOCAL_IN) {
-		struct ipv6hdr *iph =3D ipv6_hdr(skb);
-		--iph->hop_limit;
-	}
-	if (tee_tg_route6(skb, info)) {
-		__this_cpu_write(nf_skb_duplicated, true);
-		ip6_local_out(skb);
-		__this_cpu_write(nf_skb_duplicated, false);
-	} else {
-		kfree_skb(skb);
-	}
 	return XT_CONTINUE;
 }
 #endif
--=20
1.7.10.4
