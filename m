From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/17] netfilter: refactor NAT redirect IPv4 to use it from nf_tables
Date: Mon, 24 Nov 2014 14:27:38 +0100
Message-ID: <1416835674-11871-2-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44833 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753762AbaKXNZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 08:25:50 -0500
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

This patch refactors the IPv4 code so it can be usable both from xt and
nf_tables.

A similar patch follows-up to handle IPv6.

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv4/nf_nat_redirect.h |    9 +++
 net/ipv4/netfilter/Kconfig                   |    6 ++
 net/ipv4/netfilter/Makefile                  |    1 +
 net/ipv4/netfilter/nf_nat_redirect_ipv4.c    |   82 ++++++++++++++++++++++++++
 net/netfilter/Kconfig                        |    1 +
 net/netfilter/xt_REDIRECT.c                  |   44 +-------------
 6 files changed, 101 insertions(+), 42 deletions(-)
 create mode 100644 include/net/netfilter/ipv4/nf_nat_redirect.h
 create mode 100644 net/ipv4/netfilter/nf_nat_redirect_ipv4.c

diff --git a/include/net/netfilter/ipv4/nf_nat_redirect.h b/include/net/netfilter/ipv4/nf_nat_redirect.h
new file mode 100644
index 0000000..19e1df3
--- /dev/null
+++ b/include/net/netfilter/ipv4/nf_nat_redirect.h
@@ -0,0 +1,9 @@
+#ifndef _NF_NAT_REDIRECT_IPV4_H_
+#define _NF_NAT_REDIRECT_IPV4_H_
+
+unsigned int
+nf_nat_redirect_ipv4(struct sk_buff *skb,
+		     const struct nf_nat_ipv4_multi_range_compat *mr,
+		     unsigned int hooknum);
+
+#endif /* _NF_NAT_REDIRECT_IPV4_H_ */
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 4c019d5..a300e2c 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -104,6 +104,12 @@ config NF_NAT_MASQUERADE_IPV4
 	  This is the kernel functionality to provide NAT in the masquerade
 	  flavour (automatic source address selection).
 
+config NF_NAT_REDIRECT_IPV4
+	tristate "IPv4 redirect support"
+	help
+	  This is the kernel functionality to provide NAT in the redirect
+	  flavour (redirect packets to local machine).
+
 config NFT_MASQ_IPV4
 	tristate "IPv4 masquerading support for nf_tables"
 	depends on NF_TABLES_IPV4
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index f4cef5a..34e436c 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -31,6 +31,7 @@ obj-$(CONFIG_NF_NAT_H323) += nf_nat_h323.o
 obj-$(CONFIG_NF_NAT_PPTP) += nf_nat_pptp.o
 obj-$(CONFIG_NF_NAT_SNMP_BASIC) += nf_nat_snmp_basic.o
 obj-$(CONFIG_NF_NAT_MASQUERADE_IPV4) += nf_nat_masquerade_ipv4.o
+obj-$(CONFIG_NF_NAT_REDIRECT_IPV4) += nf_nat_redirect_ipv4.o
 
 # NAT protocols (nf_nat)
 obj-$(CONFIG_NF_NAT_PROTO_GRE) += nf_nat_proto_gre.o
diff --git a/net/ipv4/netfilter/nf_nat_redirect_ipv4.c b/net/ipv4/netfilter/nf_nat_redirect_ipv4.c
new file mode 100644
index 0000000..a220552
--- /dev/null
+++ b/net/ipv4/netfilter/nf_nat_redirect_ipv4.c
@@ -0,0 +1,82 @@
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
+#include <linux/netfilter/x_tables.h>
+#include <net/addrconf.h>
+#include <net/checksum.h>
+#include <net/protocol.h>
+#include <net/netfilter/nf_nat.h>
+#include <net/netfilter/ipv4/nf_nat_redirect.h>
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
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index ae5096a..a0716a3 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -835,6 +835,7 @@ config NETFILTER_XT_TARGET_RATEEST
 config NETFILTER_XT_TARGET_REDIRECT
 	tristate "REDIRECT target support"
 	depends on NF_NAT
+	select NF_NAT_REDIRECT_IPV4
 	---help---
 	REDIRECT is a special case of NAT: all incoming connections are
 	mapped onto the incoming interface's address, causing the packets to
diff --git a/net/netfilter/xt_REDIRECT.c b/net/netfilter/xt_REDIRECT.c
index 22a1030..b4ffac5 100644
--- a/net/netfilter/xt_REDIRECT.c
+++ b/net/netfilter/xt_REDIRECT.c
@@ -26,6 +26,7 @@
 #include <net/checksum.h>
 #include <net/protocol.h>
 #include <net/netfilter/nf_nat.h>
+#include <net/netfilter/ipv4/nf_nat_redirect.h>
 
 static const struct in6_addr loopback_addr = IN6ADDR_LOOPBACK_INIT;
 
@@ -98,48 +99,7 @@ static int redirect_tg4_check(const struct xt_tgchk_param *par)
 static unsigned int
 redirect_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-	__be32 newdst;
-	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
-	struct nf_nat_range newrange;
-
-	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
-		     par->hooknum == NF_INET_LOCAL_OUT);
-
-	ct = nf_ct_get(skb, &ctinfo);
-	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
-
-	/* Local packets: make them go to loopback */
-	if (par->hooknum == NF_INET_LOCAL_OUT)
-		newdst = htonl(0x7F000001);
-	else {
-		struct in_device *indev;
-		struct in_ifaddr *ifa;
-
-		newdst = 0;
-
-		rcu_read_lock();
-		indev = __in_dev_get_rcu(skb->dev);
-		if (indev && (ifa = indev->ifa_list))
-			newdst = ifa->ifa_local;
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
+	return nf_nat_redirect_ipv4(skb, par->targinfo, par->hooknum);
 }
 
 static struct xt_target redirect_tg_reg[] __read_mostly = {
-- 
1.7.10.4
