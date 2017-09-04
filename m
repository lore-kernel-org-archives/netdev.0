From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/12] net: Remove CONFIG_NETFILTER_DEBUG and _ASSERT() macros.
Date: Mon,  4 Sep 2017 22:11:09 +0200
Message-ID: <1504555874-4168-8-git-send-email-pablo@netfilter.org>
References: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42172 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754685AbdIDULa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 4 Sep 2017 16:11:30 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 057E5532F92
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 22:11:03 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EBE90B502A
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 22:11:02 +0200 (CEST)
In-Reply-To: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varsha Rao <rvarsha016@gmail.com>

This patch removes CONFIG_NETFILTER_DEBUG and _ASSERT() macros as they
are no longer required. Replace _ASSERT() macros with WARN_ON().

Signed-off-by: Varsha Rao <rvarsha016@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 arch/parisc/configs/c3000_defconfig  |  1 -
 arch/sh/configs/se7751_defconfig     |  1 -
 include/net/netfilter/nf_conntrack.h |  6 ------
 net/Kconfig                          |  7 -------
 net/bridge/netfilter/ebtables.c      | 20 ++++++++------------
 net/ipv4/netfilter/ip_tables.c       | 12 +++---------
 net/ipv6/netfilter/ip6_tables.c      | 12 +++---------
 7 files changed, 14 insertions(+), 45 deletions(-)

diff --git a/arch/parisc/configs/c3000_defconfig b/arch/parisc/configs/c3000_defconfig
index 0764d3971cf6..8d41a73bd71b 100644
--- a/arch/parisc/configs/c3000_defconfig
+++ b/arch/parisc/configs/c3000_defconfig
@@ -31,7 +31,6 @@ CONFIG_IP_PNP_BOOTP=y
 CONFIG_INET6_IPCOMP=m
 CONFIG_IPV6_TUNNEL=m
 CONFIG_NETFILTER=y
-CONFIG_NETFILTER_DEBUG=y
 CONFIG_NET_PKTGEN=m
 CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
 CONFIG_DEVTMPFS=y
diff --git a/arch/sh/configs/se7751_defconfig b/arch/sh/configs/se7751_defconfig
index 75c92fc1876b..56b5e4ce8d4a 100644
--- a/arch/sh/configs/se7751_defconfig
+++ b/arch/sh/configs/se7751_defconfig
@@ -28,7 +28,6 @@ CONFIG_IP_PNP_RARP=y
 # CONFIG_INET_LRO is not set
 # CONFIG_IPV6 is not set
 CONFIG_NETFILTER=y
-CONFIG_NETFILTER_DEBUG=y
 CONFIG_IP_NF_QUEUE=y
 CONFIG_MTD=y
 CONFIG_MTD_PARTITIONS=y
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 0385cb08c478..fdc9c64a1c94 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -44,12 +44,6 @@ union nf_conntrack_expect_proto {
 #include <linux/types.h>
 #include <linux/skbuff.h>
 
-#ifdef CONFIG_NETFILTER_DEBUG
-#define NF_CT_ASSERT(x)		WARN_ON(!(x))
-#else
-#define NF_CT_ASSERT(x)
-#endif
-
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
 
diff --git a/net/Kconfig b/net/Kconfig
index e0e7c62c88f0..9dba2715919d 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -166,13 +166,6 @@ menuconfig NETFILTER
 
 if NETFILTER
 
-config NETFILTER_DEBUG
-	bool "Network packet filtering debugging"
-	depends on NETFILTER
-	help
-	  You can say Y here if you want to get additional messages useful in
-	  debugging the netfilter code.
-
 config NETFILTER_ADVANCED
 	bool "Advanced netfilter configuration"
 	depends on NETFILTER
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 54c7ef4e970e..83951f978445 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -252,13 +252,11 @@ unsigned int ebt_do_table(struct sk_buff *skb,
 		}
 		if (verdict == EBT_RETURN) {
 letsreturn:
-#ifdef CONFIG_NETFILTER_DEBUG
-			if (sp == 0) {
-				BUGPRINT("RETURN on base chain");
+			if (WARN(sp == 0, "RETURN on base chain")) {
 				/* act like this is EBT_CONTINUE */
 				goto letscontinue;
 			}
-#endif
+
 			sp--;
 			/* put all the local variables right */
 			i = cs[sp].n;
@@ -271,26 +269,24 @@ unsigned int ebt_do_table(struct sk_buff *skb,
 		}
 		if (verdict == EBT_CONTINUE)
 			goto letscontinue;
-#ifdef CONFIG_NETFILTER_DEBUG
-		if (verdict < 0) {
-			BUGPRINT("bogus standard verdict\n");
+
+		if (WARN(verdict < 0, "bogus standard verdict\n")) {
 			read_unlock_bh(&table->lock);
 			return NF_DROP;
 		}
-#endif
+
 		/* jump to a udc */
 		cs[sp].n = i + 1;
 		cs[sp].chaininfo = chaininfo;
 		cs[sp].e = ebt_next_entry(point);
 		i = 0;
 		chaininfo = (struct ebt_entries *) (base + verdict);
-#ifdef CONFIG_NETFILTER_DEBUG
-		if (chaininfo->distinguisher) {
-			BUGPRINT("jump to non-chain\n");
+
+		if (WARN(chaininfo->distinguisher, "jump to non-chain\n")) {
 			read_unlock_bh(&table->lock);
 			return NF_DROP;
 		}
-#endif
+
 		nentries = chaininfo->nentries;
 		point = (struct ebt_entry *)chaininfo->data;
 		counter_base = cb_base + chaininfo->counter_offset;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index ce1d97579ce8..576cba2b57e9 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -35,12 +35,6 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("IPv4 packet filter");
 
-#ifdef CONFIG_NETFILTER_DEBUG
-#define IP_NF_ASSERT(x)		WARN_ON(!(x))
-#else
-#define IP_NF_ASSERT(x)
-#endif
-
 void *ipt_alloc_initial_table(const struct xt_table *info)
 {
 	return xt_alloc_initial_table(ipt, IPT);
@@ -263,7 +257,7 @@ ipt_do_table(struct sk_buff *skb,
 	acpar.hotdrop = false;
 	acpar.state   = state;
 
-	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
+	WARN_ON(!(table->valid_hooks & (1 << hook)));
 	local_bh_disable();
 	addend = xt_write_recseq_begin();
 	private = table->private;
@@ -293,7 +287,7 @@ ipt_do_table(struct sk_buff *skb,
 		const struct xt_entry_match *ematch;
 		struct xt_counters *counter;
 
-		IP_NF_ASSERT(e);
+		WARN_ON(!e);
 		if (!ip_packet_match(ip, indev, outdev,
 		    &e->ip, acpar.fragoff)) {
  no_match:
@@ -312,7 +306,7 @@ ipt_do_table(struct sk_buff *skb,
 		ADD_COUNTER(*counter, skb->len, 1);
 
 		t = ipt_get_target(e);
-		IP_NF_ASSERT(t->u.kernel.target);
+		WARN_ON(!t->u.kernel.target);
 
 #if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 		/* The packet is traced: log it */
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 9f6644958e5e..54b1e75eded1 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -39,12 +39,6 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("IPv6 packet filter");
 
-#ifdef CONFIG_NETFILTER_DEBUG
-#define IP_NF_ASSERT(x)	WARN_ON(!(x))
-#else
-#define IP_NF_ASSERT(x)
-#endif
-
 void *ip6t_alloc_initial_table(const struct xt_table *info)
 {
 	return xt_alloc_initial_table(ip6t, IP6T);
@@ -284,7 +278,7 @@ ip6t_do_table(struct sk_buff *skb,
 	acpar.hotdrop = false;
 	acpar.state   = state;
 
-	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
+	WARN_ON(!(table->valid_hooks & (1 << hook)));
 
 	local_bh_disable();
 	addend = xt_write_recseq_begin();
@@ -315,7 +309,7 @@ ip6t_do_table(struct sk_buff *skb,
 		const struct xt_entry_match *ematch;
 		struct xt_counters *counter;
 
-		IP_NF_ASSERT(e);
+		WARN_ON(!e);
 		acpar.thoff = 0;
 		if (!ip6_packet_match(skb, indev, outdev, &e->ipv6,
 		    &acpar.thoff, &acpar.fragoff, &acpar.hotdrop)) {
@@ -335,7 +329,7 @@ ip6t_do_table(struct sk_buff *skb,
 		ADD_COUNTER(*counter, skb->len, 1);
 
 		t = ip6t_get_target_c(e);
-		IP_NF_ASSERT(t->u.kernel.target);
+		WARN_ON(!t->u.kernel.target);
 
 #if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 		/* The packet is traced: log it */
-- 
2.1.4
