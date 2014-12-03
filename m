From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/12] netfilter: combine IPv4 and IPv6 nf_nat_redirect code in one module
Date: Wed,  3 Dec 2014 13:55:35 +0100
Message-ID: <1417611342-25257-6-git-send-email-pablo@netfilter.org>
References: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48624 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752409AbaLCMxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 07:53:34 -0500
In-Reply-To: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This resolves linking problems with CONFIG_IPV6=n:

net/built-in.o: In function `redirect_tg6':
xt_REDIRECT.c:(.text+0x6d021): undefined reference to `nf_nat_redirect_ipv6'

Reported-by: Andreas Ruprecht <rupran@einserver.de>
Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv4/nf_nat_redirect.h |    9 --
 include/net/netfilter/ipv6/nf_nat_redirect.h |    8 --
 include/net/netfilter/nf_nat_redirect.h      |   12 +++
 net/ipv4/netfilter/Kconfig                   |    8 +-
 net/ipv4/netfilter/Makefile                  |    1 -
 net/ipv4/netfilter/nf_nat_redirect_ipv4.c    |   82 -----------------
 net/ipv4/netfilter/nft_redir_ipv4.c          |    2 +-
 net/ipv6/netfilter/Kconfig                   |    8 +-
 net/ipv6/netfilter/Makefile                  |    1 -
 net/ipv6/netfilter/nf_nat_redirect_ipv6.c    |   75 ---------------
 net/ipv6/netfilter/nft_redir_ipv6.c          |    2 +-
 net/netfilter/Kconfig                        |   10 +-
 net/netfilter/Makefile                       |    1 +
 net/netfilter/nf_nat_redirect.c              |  127 ++++++++++++++++++++++++++
 net/netfilter/xt_REDIRECT.c                  |    3 +-
 15 files changed, 153 insertions(+), 196 deletions(-)
 delete mode 100644 include/net/netfilter/ipv4/nf_nat_redirect.h
 delete mode 100644 include/net/netfilter/ipv6/nf_nat_redirect.h
 create mode 100644 include/net/netfilter/nf_nat_redirect.h
 delete mode 100644 net/ipv4/netfilter/nf_nat_redirect_ipv4.c
 delete mode 100644 net/ipv6/netfilter/nf_nat_redirect_ipv6.c
 create mode 100644 net/netfilter/nf_nat_redirect.c

diff --git a/include/net/netfilter/ipv4/nf_nat_redirect.h b/include/net/netfilter/ipv4/nf_nat_redirect.h
deleted file mode 100644
index 19e1df3..0000000
--- a/include/net/netfilter/ipv4/nf_nat_redirect.h
+++ /dev/null
@@ -1,9 +0,0 @@
-#ifndef _NF_NAT_REDIRECT_IPV4_H_
-#define _NF_NAT_REDIRECT_IPV4_H_
-
-unsigned int
-nf_nat_redirect_ipv4(struct sk_buff *skb,
-		     const struct nf_nat_ipv4_multi_range_compat *mr,
-		     unsigned int hooknum);
-
-#endif /* _NF_NAT_REDIRECT_IPV4_H_ */
diff --git a/include/net/netfilter/ipv6/nf_nat_redirect.h b/include/net/netfilter/ipv6/nf_nat_redirect.h
deleted file mode 100644
index 1ebdffc..0000000
--- a/include/net/netfilter/ipv6/nf_nat_redirect.h
+++ /dev/null
@@ -1,8 +0,0 @@
-#ifndef _NF_NAT_REDIRECT_IPV6_H_
-#define _NF_NAT_REDIRECT_IPV6_H_
-
-unsigned int
-nf_nat_redirect_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
-		     unsigned int hooknum);
-
-#endif /* _NF_NAT_REDIRECT_IPV6_H_ */
diff --git a/include/net/netfilter/nf_nat_redirect.h b/include/net/netfilter/nf_nat_redirect.h
new file mode 100644
index 0000000..73b7295
--- /dev/null
+++ b/include/net/netfilter/nf_nat_redirect.h
@@ -0,0 +1,12 @@
+#ifndef _NF_NAT_REDIRECT_H_
+#define _NF_NAT_REDIRECT_H_
+
+unsigned int
+nf_nat_redirect_ipv4(struct sk_buff *skb,
+		     const struct nf_nat_ipv4_multi_range_compat *mr,
+		     unsigned int hooknum);
+unsigned int
+nf_nat_redirect_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
+		     unsigned int hooknum);
+
+#endif /* _NF_NAT_REDIRECT_H_ */
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 8358b2d..59f883d 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -104,12 +104,6 @@ config NF_NAT_MASQUERADE_IPV4
 	  This is the kernel functionality to provide NAT in the masquerade
 	  flavour (automatic source address selection).
 
-config NF_NAT_REDIRECT_IPV4
-	tristate "IPv4 redirect support"
-	help
-	  This is the kernel functionality to provide NAT in the redirect
-	  flavour (redirect packets to local machine).
-
 config NFT_MASQ_IPV4
 	tristate "IPv4 masquerading support for nf_tables"
 	depends on NF_TABLES_IPV4
@@ -123,7 +117,7 @@ config NFT_REDIR_IPV4
 	tristate "IPv4 redirect support for nf_tables"
 	depends on NF_TABLES_IPV4
 	depends on NFT_REDIR
-	select NF_NAT_REDIRECT_IPV4
+	select NF_NAT_REDIRECT
 	help
 	  This is the expression that provides IPv4 redirect support for
 	  nf_tables.
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 902bcd1..7fe6c70 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -31,7 +31,6 @@ obj-$(CONFIG_NF_NAT_H323) += nf_nat_h323.o
 obj-$(CONFIG_NF_NAT_PPTP) += nf_nat_pptp.o
 obj-$(CONFIG_NF_NAT_SNMP_BASIC) += nf_nat_snmp_basic.o
 obj-$(CONFIG_NF_NAT_MASQUERADE_IPV4) += nf_nat_masquerade_ipv4.o
-obj-$(CONFIG_NF_NAT_REDIRECT_IPV4) += nf_nat_redirect_ipv4.o
 
 # NAT protocols (nf_nat)
 obj-$(CONFIG_NF_NAT_PROTO_GRE) += nf_nat_proto_gre.o
diff --git a/net/ipv4/netfilter/nf_nat_redirect_ipv4.c b/net/ipv4/netfilter/nf_nat_redirect_ipv4.c
deleted file mode 100644
index a220552..0000000
--- a/net/ipv4/netfilter/nf_nat_redirect_ipv4.c
+++ /dev/null
@@ -1,82 +0,0 @@
-/*
- * (C) 1999-2001 Paul `Rusty' Russell
- * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
- * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- * Based on Rusty Russell's IPv4 REDIRECT target. Development of IPv6
- * NAT funded by Astaro.
- */
-
-#include <linux/if.h>
-#include <linux/inetdevice.h>
-#include <linux/ip.h>
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/netdevice.h>
-#include <linux/netfilter.h>
-#include <linux/types.h>
-#include <linux/netfilter_ipv4.h>
-#include <linux/netfilter/x_tables.h>
-#include <net/addrconf.h>
-#include <net/checksum.h>
-#include <net/protocol.h>
-#include <net/netfilter/nf_nat.h>
-#include <net/netfilter/ipv4/nf_nat_redirect.h>
-
-unsigned int
-nf_nat_redirect_ipv4(struct sk_buff *skb,
-		     const struct nf_nat_ipv4_multi_range_compat *mr,
-		     unsigned int hooknum)
-{
-	struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-	__be32 newdst;
-	struct nf_nat_range newrange;
-
-	NF_CT_ASSERT(hooknum == NF_INET_PRE_ROUTING ||
-		     hooknum == NF_INET_LOCAL_OUT);
-
-	ct = nf_ct_get(skb, &ctinfo);
-	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
-
-	/* Local packets: make them go to loopback */
-	if (hooknum == NF_INET_LOCAL_OUT) {
-		newdst = htonl(0x7F000001);
-	} else {
-		struct in_device *indev;
-		struct in_ifaddr *ifa;
-
-		newdst = 0;
-
-		rcu_read_lock();
-		indev = __in_dev_get_rcu(skb->dev);
-		if (indev != NULL) {
-			ifa = indev->ifa_list;
-			newdst = ifa->ifa_local;
-		}
-		rcu_read_unlock();
-
-		if (!newdst)
-			return NF_DROP;
-	}
-
-	/* Transfer from original range. */
-	memset(&newrange.min_addr, 0, sizeof(newrange.min_addr));
-	memset(&newrange.max_addr, 0, sizeof(newrange.max_addr));
-	newrange.flags	     = mr->range[0].flags | NF_NAT_RANGE_MAP_IPS;
-	newrange.min_addr.ip = newdst;
-	newrange.max_addr.ip = newdst;
-	newrange.min_proto   = mr->range[0].min;
-	newrange.max_proto   = mr->range[0].max;
-
-	/* Hand modified range to generic setup. */
-	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_DST);
-}
-EXPORT_SYMBOL_GPL(nf_nat_redirect_ipv4);
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
diff --git a/net/ipv4/netfilter/nft_redir_ipv4.c b/net/ipv4/netfilter/nft_redir_ipv4.c
index 643c596..ff2d23d 100644
--- a/net/ipv4/netfilter/nft_redir_ipv4.c
+++ b/net/ipv4/netfilter/nft_redir_ipv4.c
@@ -14,7 +14,7 @@
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
 #include <net/netfilter/nf_nat.h>
-#include <net/netfilter/ipv4/nf_nat_redirect.h>
+#include <net/netfilter/nf_nat_redirect.h>
 #include <net/netfilter/nft_redir.h>
 
 static void nft_redir_ipv4_eval(const struct nft_expr *expr,
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 0dbe5c7..a069822 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -82,12 +82,6 @@ config NF_NAT_MASQUERADE_IPV6
 	  This is the kernel functionality to provide NAT in the masquerade
 	  flavour (automatic source address selection) for IPv6.
 
-config NF_NAT_REDIRECT_IPV6
-	tristate "IPv6 redirect support"
-	help
-	  This is the kernel functionality to provide NAT in the redirect
-	  flavour (redirect packet to local machine) for IPv6.
-
 config NFT_MASQ_IPV6
 	tristate "IPv6 masquerade support for nf_tables"
 	depends on NF_TABLES_IPV6
@@ -101,7 +95,7 @@ config NFT_REDIR_IPV6
 	tristate "IPv6 redirect support for nf_tables"
 	depends on NF_TABLES_IPV6
 	depends on NFT_REDIR
-	select NF_NAT_REDIRECT_IPV6
+	select NF_NAT_REDIRECT
 	help
 	  This is the expression that provides IPv4 redirect support for
 	  nf_tables.
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index d2ac9f5..c36e0a5 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -19,7 +19,6 @@ obj-$(CONFIG_NF_CONNTRACK_IPV6) += nf_conntrack_ipv6.o
 nf_nat_ipv6-y		:= nf_nat_l3proto_ipv6.o nf_nat_proto_icmpv6.o
 obj-$(CONFIG_NF_NAT_IPV6) += nf_nat_ipv6.o
 obj-$(CONFIG_NF_NAT_MASQUERADE_IPV6) += nf_nat_masquerade_ipv6.o
-obj-$(CONFIG_NF_NAT_REDIRECT_IPV6) += nf_nat_redirect_ipv6.o
 
 # defrag
 nf_defrag_ipv6-y := nf_defrag_ipv6_hooks.o nf_conntrack_reasm.o
diff --git a/net/ipv6/netfilter/nf_nat_redirect_ipv6.c b/net/ipv6/netfilter/nf_nat_redirect_ipv6.c
deleted file mode 100644
index ea1308a..0000000
--- a/net/ipv6/netfilter/nf_nat_redirect_ipv6.c
+++ /dev/null
@@ -1,75 +0,0 @@
-/*
- * (C) 1999-2001 Paul `Rusty' Russell
- * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
- * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- * Based on Rusty Russell's IPv4 REDIRECT target. Development of IPv6
- * NAT funded by Astaro.
- */
-
-#include <linux/if.h>
-#include <linux/inetdevice.h>
-#include <linux/ip.h>
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/netdevice.h>
-#include <linux/netfilter.h>
-#include <linux/types.h>
-#include <linux/netfilter_ipv6.h>
-#include <linux/netfilter/x_tables.h>
-#include <net/addrconf.h>
-#include <net/checksum.h>
-#include <net/protocol.h>
-#include <net/netfilter/nf_nat.h>
-#include <net/netfilter/ipv6/nf_nat_redirect.h>
-
-static const struct in6_addr loopback_addr = IN6ADDR_LOOPBACK_INIT;
-
-unsigned int
-nf_nat_redirect_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
-		     unsigned int hooknum)
-{
-	struct nf_nat_range newrange;
-	struct in6_addr newdst;
-	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct;
-
-	ct = nf_ct_get(skb, &ctinfo);
-	if (hooknum == NF_INET_LOCAL_OUT) {
-		newdst = loopback_addr;
-	} else {
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
-}
-EXPORT_SYMBOL_GPL(nf_nat_redirect_ipv6);
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
diff --git a/net/ipv6/netfilter/nft_redir_ipv6.c b/net/ipv6/netfilter/nft_redir_ipv6.c
index 83420ee..2433a6b 100644
--- a/net/ipv6/netfilter/nft_redir_ipv6.c
+++ b/net/ipv6/netfilter/nft_redir_ipv6.c
@@ -15,7 +15,7 @@
 #include <net/netfilter/nf_tables.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nft_redir.h>
-#include <net/netfilter/ipv6/nf_nat_redirect.h>
+#include <net/netfilter/nf_nat_redirect.h>
 
 static void nft_redir_ipv6_eval(const struct nft_expr *expr,
 				struct nft_data data[NFT_REG_MAX + 1],
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 57f15a9..b02660f 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -411,6 +411,13 @@ config NF_NAT_TFTP
 	depends on NF_CONNTRACK && NF_NAT
 	default NF_NAT && NF_CONNTRACK_TFTP
 
+config NF_NAT_REDIRECT
+        tristate "IPv4/IPv6 redirect support"
+	depends on NF_NAT
+        help
+          This is the kernel functionality to redirect packets to local
+          machine through NAT.
+
 config NETFILTER_SYNPROXY
 	tristate
 
@@ -844,8 +851,7 @@ config NETFILTER_XT_TARGET_RATEEST
 config NETFILTER_XT_TARGET_REDIRECT
 	tristate "REDIRECT target support"
 	depends on NF_NAT
-	select NF_NAT_REDIRECT_IPV4 if NF_NAT_IPV4
-	select NF_NAT_REDIRECT_IPV6 if NF_NAT_IPV6
+	select NF_NAT_REDIRECT
 	---help---
 	REDIRECT is a special case of NAT: all incoming connections are
 	mapped onto the incoming interface's address, causing the packets to
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index f3eb468..89f73a9 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -51,6 +51,7 @@ nf_nat-y	:= nf_nat_core.o nf_nat_proto_unknown.o nf_nat_proto_common.o \
 obj-$(CONFIG_NF_LOG_COMMON) += nf_log_common.o
 
 obj-$(CONFIG_NF_NAT) += nf_nat.o
+obj-$(CONFIG_NF_NAT_REDIRECT) += nf_nat_redirect.o
 
 # NAT protocols (nf_nat)
 obj-$(CONFIG_NF_NAT_PROTO_DCCP) += nf_nat_proto_dccp.o
diff --git a/net/netfilter/nf_nat_redirect.c b/net/netfilter/nf_nat_redirect.c
new file mode 100644
index 0000000..97b75f9
--- /dev/null
+++ b/net/netfilter/nf_nat_redirect.c
@@ -0,0 +1,127 @@
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
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter/x_tables.h>
+#include <net/addrconf.h>
+#include <net/checksum.h>
+#include <net/protocol.h>
+#include <net/netfilter/nf_nat.h>
+#include <net/netfilter/nf_nat_redirect.h>
+
+unsigned int
+nf_nat_redirect_ipv4(struct sk_buff *skb,
+		     const struct nf_nat_ipv4_multi_range_compat *mr,
+		     unsigned int hooknum)
+{
+	struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+	__be32 newdst;
+	struct nf_nat_range newrange;
+
+	NF_CT_ASSERT(hooknum == NF_INET_PRE_ROUTING ||
+		     hooknum == NF_INET_LOCAL_OUT);
+
+	ct = nf_ct_get(skb, &ctinfo);
+	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
+
+	/* Local packets: make them go to loopback */
+	if (hooknum == NF_INET_LOCAL_OUT) {
+		newdst = htonl(0x7F000001);
+	} else {
+		struct in_device *indev;
+		struct in_ifaddr *ifa;
+
+		newdst = 0;
+
+		rcu_read_lock();
+		indev = __in_dev_get_rcu(skb->dev);
+		if (indev != NULL) {
+			ifa = indev->ifa_list;
+			newdst = ifa->ifa_local;
+		}
+		rcu_read_unlock();
+
+		if (!newdst)
+			return NF_DROP;
+	}
+
+	/* Transfer from original range. */
+	memset(&newrange.min_addr, 0, sizeof(newrange.min_addr));
+	memset(&newrange.max_addr, 0, sizeof(newrange.max_addr));
+	newrange.flags	     = mr->range[0].flags | NF_NAT_RANGE_MAP_IPS;
+	newrange.min_addr.ip = newdst;
+	newrange.max_addr.ip = newdst;
+	newrange.min_proto   = mr->range[0].min;
+	newrange.max_proto   = mr->range[0].max;
+
+	/* Hand modified range to generic setup. */
+	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_DST);
+}
+EXPORT_SYMBOL_GPL(nf_nat_redirect_ipv4);
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
diff --git a/net/netfilter/xt_REDIRECT.c b/net/netfilter/xt_REDIRECT.c
index b6ec67e..03f0b37 100644
--- a/net/netfilter/xt_REDIRECT.c
+++ b/net/netfilter/xt_REDIRECT.c
@@ -26,8 +26,7 @@
 #include <net/checksum.h>
 #include <net/protocol.h>
 #include <net/netfilter/nf_nat.h>
-#include <net/netfilter/ipv4/nf_nat_redirect.h>
-#include <net/netfilter/ipv6/nf_nat_redirect.h>
+#include <net/netfilter/nf_nat_redirect.h>
 
 static unsigned int
 redirect_tg6(struct sk_buff *skb, const struct xt_action_param *par)
-- 
1.7.10.4
