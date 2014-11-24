From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/17] netfilter: refactor NAT redirect IPv6 code to use it from nf_tables
Date: Mon, 24 Nov 2014 14:27:39 +0100
Message-ID: <1416835674-11871-3-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44843 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932084AbaKXNZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 08:25:51 -0500
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

This patch refactors the IPv6 code so it can be usable both from xt and
nf_tables.

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv6/nf_nat_redirect.h |    8 +++
 net/ipv6/netfilter/Kconfig                   |    6 +++
 net/ipv6/netfilter/Makefile                  |    1 +
 net/ipv6/netfilter/nf_nat_redirect_ipv6.c    |   75 ++++++++++++++++++++++++++
 net/netfilter/Kconfig                        |    1 +
 net/netfilter/xt_REDIRECT.c                  |   40 +-------------
 6 files changed, 93 insertions(+), 38 deletions(-)
 create mode 100644 include/net/netfilter/ipv6/nf_nat_redirect.h
 create mode 100644 net/ipv6/netfilter/nf_nat_redirect_ipv6.c

diff --git a/include/net/netfilter/ipv6/nf_nat_redirect.h b/include/net/netfilter/ipv6/nf_nat_redirect.h
new file mode 100644
index 0000000..1ebdffc
--- /dev/null
+++ b/include/net/netfilter/ipv6/nf_nat_redirect.h
@@ -0,0 +1,8 @@
+#ifndef _NF_NAT_REDIRECT_IPV6_H_
+#define _NF_NAT_REDIRECT_IPV6_H_
+
+unsigned int
+nf_nat_redirect_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
+		     unsigned int hooknum);
+
+#endif /* _NF_NAT_REDIRECT_IPV6_H_ */
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 6af874f..462eebb 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -82,6 +82,12 @@ config NF_NAT_MASQUERADE_IPV6
 	  This is the kernel functionality to provide NAT in the masquerade
 	  flavour (automatic source address selection) for IPv6.
 
+config NF_NAT_REDIRECT_IPV6
+	tristate "IPv6 redirect support"
+	help
+	  This is the kernel functionality to provide NAT in the redirect
+	  flavour (redirect packet to local machine) for IPv6.
+
 config NFT_MASQ_IPV6
 	tristate "IPv6 masquerade support for nf_tables"
 	depends on NF_TABLES_IPV6
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index fbb25f0..6c2baab 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -19,6 +19,7 @@ obj-$(CONFIG_NF_CONNTRACK_IPV6) += nf_conntrack_ipv6.o
 nf_nat_ipv6-y		:= nf_nat_l3proto_ipv6.o nf_nat_proto_icmpv6.o
 obj-$(CONFIG_NF_NAT_IPV6) += nf_nat_ipv6.o
 obj-$(CONFIG_NF_NAT_MASQUERADE_IPV6) += nf_nat_masquerade_ipv6.o
+obj-$(CONFIG_NF_NAT_REDIRECT_IPV6) += nf_nat_redirect_ipv6.o
 
 # defrag
 nf_defrag_ipv6-y := nf_defrag_ipv6_hooks.o nf_conntrack_reasm.o
diff --git a/net/ipv6/netfilter/nf_nat_redirect_ipv6.c b/net/ipv6/netfilter/nf_nat_redirect_ipv6.c
new file mode 100644
index 0000000..ea1308a
--- /dev/null
+++ b/net/ipv6/netfilter/nf_nat_redirect_ipv6.c
@@ -0,0 +1,75 @@
+/*
+ * (C) 1999-2001 Paul `Rusty' Russell
+ * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
+ * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Based on Rusty Russell's IPv4 REDIRECT target. Development of IPv6
+ * NAT funded by Astaro.
+ */
+
+#include <linux/if.h>
+#include <linux/inetdevice.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/netfilter.h>
+#include <linux/types.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter/x_tables.h>
+#include <net/addrconf.h>
+#include <net/checksum.h>
+#include <net/protocol.h>
+#include <net/netfilter/nf_nat.h>
+#include <net/netfilter/ipv6/nf_nat_redirect.h>
+
+static const struct in6_addr loopback_addr = IN6ADDR_LOOPBACK_INIT;
+
+unsigned int
+nf_nat_redirect_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
+		     unsigned int hooknum)
+{
+	struct nf_nat_range newrange;
+	struct in6_addr newdst;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (hooknum == NF_INET_LOCAL_OUT) {
+		newdst = loopback_addr;
+	} else {
+		struct inet6_dev *idev;
+		struct inet6_ifaddr *ifa;
+		bool addr = false;
+
+		rcu_read_lock();
+		idev = __in6_dev_get(skb->dev);
+		if (idev != NULL) {
+			list_for_each_entry(ifa, &idev->addr_list, if_list) {
+				newdst = ifa->addr;
+				addr = true;
+				break;
+			}
+		}
+		rcu_read_unlock();
+
+		if (!addr)
+			return NF_DROP;
+	}
+
+	newrange.flags		= range->flags | NF_NAT_RANGE_MAP_IPS;
+	newrange.min_addr.in6	= newdst;
+	newrange.max_addr.in6	= newdst;
+	newrange.min_proto	= range->min_proto;
+	newrange.max_proto	= range->max_proto;
+
+	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_DST);
+}
+EXPORT_SYMBOL_GPL(nf_nat_redirect_ipv6);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index a0716a3..49deb4e 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -836,6 +836,7 @@ config NETFILTER_XT_TARGET_REDIRECT
 	tristate "REDIRECT target support"
 	depends on NF_NAT
 	select NF_NAT_REDIRECT_IPV4
+	select NF_NAT_REDIRECT_IPV6 if IP6_NF_IPTABLES
 	---help---
 	REDIRECT is a special case of NAT: all incoming connections are
 	mapped onto the incoming interface's address, causing the packets to
diff --git a/net/netfilter/xt_REDIRECT.c b/net/netfilter/xt_REDIRECT.c
index b4ffac5..b6ec67e 100644
--- a/net/netfilter/xt_REDIRECT.c
+++ b/net/netfilter/xt_REDIRECT.c
@@ -27,48 +27,12 @@
 #include <net/protocol.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/ipv4/nf_nat_redirect.h>
-
-static const struct in6_addr loopback_addr = IN6ADDR_LOOPBACK_INIT;
+#include <net/netfilter/ipv6/nf_nat_redirect.h>
 
 static unsigned int
 redirect_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	const struct nf_nat_range *range = par->targinfo;
-	struct nf_nat_range newrange;
-	struct in6_addr newdst;
-	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct;
-
-	ct = nf_ct_get(skb, &ctinfo);
-	if (par->hooknum == NF_INET_LOCAL_OUT)
-		newdst = loopback_addr;
-	else {
-		struct inet6_dev *idev;
-		struct inet6_ifaddr *ifa;
-		bool addr = false;
-
-		rcu_read_lock();
-		idev = __in6_dev_get(skb->dev);
-		if (idev != NULL) {
-			list_for_each_entry(ifa, &idev->addr_list, if_list) {
-				newdst = ifa->addr;
-				addr = true;
-				break;
-			}
-		}
-		rcu_read_unlock();
-
-		if (!addr)
-			return NF_DROP;
-	}
-
-	newrange.flags		= range->flags | NF_NAT_RANGE_MAP_IPS;
-	newrange.min_addr.in6	= newdst;
-	newrange.max_addr.in6	= newdst;
-	newrange.min_proto	= range->min_proto;
-	newrange.max_proto	= range->max_proto;
-
-	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_DST);
+	return nf_nat_redirect_ipv6(skb, par->targinfo, par->hooknum);
 }
 
 static int redirect_tg6_checkentry(const struct xt_tgchk_param *par)
-- 
1.7.10.4
