From: kaber@trash.net
Subject: [PATCH 77/79] netfilter: nf_conntrack: nf_conntrack snmp helper
Date: Wed, 19 Jan 2011 20:15:17 +0100
Message-ID: <1295464519-21763-78-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51974 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982Ab1ASTPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:46 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Olsa <jolsa@redhat.com>

Adding support for SNMP broadcast connection tracking. The SNMP
broadcast requests are now paired with the SNMP responses.
Thus allowing using SNMP broadcasts with firewall enabled.

Please refer to the following conversation:
http://marc.info/?l=netfilter-devel&m=125992205006600&w=2

Patrick McHardy wrote:
> > The best solution would be to add generic broadcast tracking, the
> > use of expectations for this is a bit of abuse.
> > The second best choice I guess would be to move the help() function
> > to a shared module and generalize it so it can be used for both.
This patch implements the "second best choice".

Since the netbios-ns conntrack module uses the same helper
functionality as the snmp, only one helper function is added
for both snmp and netbios-ns modules into the new object -
nf_conntrack_broadcast.

Signed-off-by: Jiri Olsa <jolsa@redhat.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nf_conntrack_snmp.h |    9 +++
 include/net/netfilter/nf_conntrack_helper.h |    6 ++
 net/ipv4/netfilter/Kconfig                  |    3 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c      |    9 ++-
 net/netfilter/Kconfig                       |   19 ++++++
 net/netfilter/Makefile                      |    2 +
 net/netfilter/nf_conntrack_broadcast.c      |   82 +++++++++++++++++++++++++++
 net/netfilter/nf_conntrack_netbios_ns.c     |   74 +++---------------------
 net/netfilter/nf_conntrack_snmp.c           |   77 +++++++++++++++++++++++++
 9 files changed, 211 insertions(+), 70 deletions(-)
 create mode 100644 include/linux/netfilter/nf_conntrack_snmp.h
 create mode 100644 net/netfilter/nf_conntrack_broadcast.c
 create mode 100644 net/netfilter/nf_conntrack_snmp.c

diff --git a/include/linux/netfilter/nf_conntrack_snmp.h b/include/linux/netfilter/nf_conntrack_snmp.h
new file mode 100644
index 0000000..064bc63
--- /dev/null
+++ b/include/linux/netfilter/nf_conntrack_snmp.h
@@ -0,0 +1,9 @@
+#ifndef _NF_CONNTRACK_SNMP_H
+#define _NF_CONNTRACK_SNMP_H
+
+extern int (*nf_nat_snmp_hook)(struct sk_buff *skb,
+				unsigned int protoff,
+				struct nf_conn *ct,
+				enum ip_conntrack_info ctinfo);
+
+#endif /* _NF_CONNTRACK_SNMP_H */
diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 32c305d..f1c1311 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -63,4 +63,10 @@ static inline struct nf_conn_help *nfct_help(const struct nf_conn *ct)
 extern int nf_conntrack_helper_init(void);
 extern void nf_conntrack_helper_fini(void);
 
+extern int nf_conntrack_broadcast_help(struct sk_buff *skb,
+				       unsigned int protoff,
+				       struct nf_conn *ct,
+				       enum ip_conntrack_info ctinfo,
+				       unsigned int timeout);
+
 #endif /*_NF_CONNTRACK_HELPER_H*/
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index babd1a2..f926a31 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -206,8 +206,9 @@ config IP_NF_TARGET_REDIRECT
 
 config NF_NAT_SNMP_BASIC
 	tristate "Basic SNMP-ALG support"
-	depends on NF_NAT
+	depends on NF_CONNTRACK_SNMP && NF_NAT
 	depends on NETFILTER_ADVANCED
+	default NF_NAT && NF_CONNTRACK_SNMP
 	---help---
 
 	  This module implements an Application Layer Gateway (ALG) for
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index ee5f419..8812a02 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -54,6 +54,7 @@
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_nat_helper.h>
+#include <linux/netfilter/nf_conntrack_snmp.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("James Morris <jmorris@intercode.com.au>");
@@ -1310,9 +1311,9 @@ static int __init nf_nat_snmp_basic_init(void)
 {
 	int ret = 0;
 
-	ret = nf_conntrack_helper_register(&snmp_helper);
-	if (ret < 0)
-		return ret;
+	BUG_ON(nf_nat_snmp_hook != NULL);
+	rcu_assign_pointer(nf_nat_snmp_hook, help);
+
 	ret = nf_conntrack_helper_register(&snmp_trap_helper);
 	if (ret < 0) {
 		nf_conntrack_helper_unregister(&snmp_helper);
@@ -1323,7 +1324,7 @@ static int __init nf_nat_snmp_basic_init(void)
 
 static void __exit nf_nat_snmp_basic_fini(void)
 {
-	nf_conntrack_helper_unregister(&snmp_helper);
+	rcu_assign_pointer(nf_nat_snmp_hook, NULL);
 	nf_conntrack_helper_unregister(&snmp_trap_helper);
 }
 
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index e2480bd..939b504 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -185,9 +185,13 @@ config NF_CONNTRACK_IRC
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NF_CONNTRACK_BROADCAST
+	tristate
+
 config NF_CONNTRACK_NETBIOS_NS
 	tristate "NetBIOS name service protocol support"
 	depends on NETFILTER_ADVANCED
+	select NF_CONNTRACK_BROADCAST
 	help
 	  NetBIOS name service requests are sent as broadcast messages from an
 	  unprivileged port and responded to with unicast messages to the
@@ -204,6 +208,21 @@ config NF_CONNTRACK_NETBIOS_NS
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NF_CONNTRACK_SNMP
+	tristate "SNMP service protocol support"
+	depends on NETFILTER_ADVANCED
+	select NF_CONNTRACK_BROADCAST
+	help
+	  SNMP service requests are sent as broadcast messages from an
+	  unprivileged port and responded to with unicast messages to the
+	  same port. This make them hard to firewall properly because connection
+	  tracking doesn't deal with broadcasts. This helper tracks locally
+	  originating SNMP service requests and the corresponding
+	  responses. It relies on correct IP address configuration, specifically
+	  netmask and broadcast address.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NF_CONNTRACK_PPTP
 	tristate "PPtP protocol support"
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 401d574..2c2628d 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -28,7 +28,9 @@ obj-$(CONFIG_NF_CONNTRACK_AMANDA) += nf_conntrack_amanda.o
 obj-$(CONFIG_NF_CONNTRACK_FTP) += nf_conntrack_ftp.o
 obj-$(CONFIG_NF_CONNTRACK_H323) += nf_conntrack_h323.o
 obj-$(CONFIG_NF_CONNTRACK_IRC) += nf_conntrack_irc.o
+obj-$(CONFIG_NF_CONNTRACK_BROADCAST) += nf_conntrack_broadcast.o
 obj-$(CONFIG_NF_CONNTRACK_NETBIOS_NS) += nf_conntrack_netbios_ns.o
+obj-$(CONFIG_NF_CONNTRACK_SNMP) += nf_conntrack_snmp.o
 obj-$(CONFIG_NF_CONNTRACK_PPTP) += nf_conntrack_pptp.o
 obj-$(CONFIG_NF_CONNTRACK_SANE) += nf_conntrack_sane.o
 obj-$(CONFIG_NF_CONNTRACK_SIP) += nf_conntrack_sip.o
diff --git a/net/netfilter/nf_conntrack_broadcast.c b/net/netfilter/nf_conntrack_broadcast.c
new file mode 100644
index 0000000..4e99cca
--- /dev/null
+++ b/net/netfilter/nf_conntrack_broadcast.c
@@ -0,0 +1,82 @@
+/*
+ *      broadcast connection tracking helper
+ *
+ *      (c) 2005 Patrick McHardy <kaber@trash.net>
+ *
+ *      This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/ip.h>
+#include <net/route.h>
+#include <linux/inetdevice.h>
+#include <linux/skbuff.h>
+
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_expect.h>
+
+int nf_conntrack_broadcast_help(struct sk_buff *skb,
+				unsigned int protoff,
+				struct nf_conn *ct,
+				enum ip_conntrack_info ctinfo,
+				unsigned int timeout)
+{
+	struct nf_conntrack_expect *exp;
+	struct iphdr *iph = ip_hdr(skb);
+	struct rtable *rt = skb_rtable(skb);
+	struct in_device *in_dev;
+	struct nf_conn_help *help = nfct_help(ct);
+	__be32 mask = 0;
+
+	/* we're only interested in locally generated packets */
+	if (skb->sk == NULL)
+		goto out;
+	if (rt == NULL || !(rt->rt_flags & RTCF_BROADCAST))
+		goto out;
+	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
+		goto out;
+
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(rt->dst.dev);
+	if (in_dev != NULL) {
+		for_primary_ifa(in_dev) {
+			if (ifa->ifa_broadcast == iph->daddr) {
+				mask = ifa->ifa_mask;
+				break;
+			}
+		} endfor_ifa(in_dev);
+	}
+	rcu_read_unlock();
+
+	if (mask == 0)
+		goto out;
+
+	exp = nf_ct_expect_alloc(ct);
+	if (exp == NULL)
+		goto out;
+
+	exp->tuple                = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
+	exp->tuple.src.u.udp.port = help->helper->tuple.src.u.udp.port;
+
+	exp->mask.src.u3.ip       = mask;
+	exp->mask.src.u.udp.port  = htons(0xFFFF);
+
+	exp->expectfn             = NULL;
+	exp->flags                = NF_CT_EXPECT_PERMANENT;
+	exp->class		  = NF_CT_EXPECT_CLASS_DEFAULT;
+	exp->helper               = NULL;
+
+	nf_ct_expect_related(exp);
+	nf_ct_expect_put(exp);
+
+	nf_ct_refresh(ct, skb, timeout * HZ);
+out:
+	return NF_ACCEPT;
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_broadcast_help);
+
+MODULE_LICENSE("GPL");
diff --git a/net/netfilter/nf_conntrack_netbios_ns.c b/net/netfilter/nf_conntrack_netbios_ns.c
index aadde01..4c8f30a 100644
--- a/net/netfilter/nf_conntrack_netbios_ns.c
+++ b/net/netfilter/nf_conntrack_netbios_ns.c
@@ -18,14 +18,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
-#include <linux/skbuff.h>
-#include <linux/netdevice.h>
-#include <linux/inetdevice.h>
-#include <linux/if_addr.h>
 #include <linux/in.h>
-#include <linux/ip.h>
-#include <linux/netfilter.h>
-#include <net/route.h>
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_helper.h>
@@ -40,75 +33,26 @@ MODULE_ALIAS("ip_conntrack_netbios_ns");
 MODULE_ALIAS_NFCT_HELPER("netbios_ns");
 
 static unsigned int timeout __read_mostly = 3;
-module_param(timeout, uint, 0400);
+module_param(timeout, uint, S_IRUSR);
 MODULE_PARM_DESC(timeout, "timeout for master connection/replies in seconds");
 
-static int help(struct sk_buff *skb, unsigned int protoff,
-		struct nf_conn *ct, enum ip_conntrack_info ctinfo)
-{
-	struct nf_conntrack_expect *exp;
-	struct iphdr *iph = ip_hdr(skb);
-	struct rtable *rt = skb_rtable(skb);
-	struct in_device *in_dev;
-	__be32 mask = 0;
-
-	/* we're only interested in locally generated packets */
-	if (skb->sk == NULL)
-		goto out;
-	if (rt == NULL || !(rt->rt_flags & RTCF_BROADCAST))
-		goto out;
-	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
-		goto out;
-
-	rcu_read_lock();
-	in_dev = __in_dev_get_rcu(rt->dst.dev);
-	if (in_dev != NULL) {
-		for_primary_ifa(in_dev) {
-			if (ifa->ifa_broadcast == iph->daddr) {
-				mask = ifa->ifa_mask;
-				break;
-			}
-		} endfor_ifa(in_dev);
-	}
-	rcu_read_unlock();
-
-	if (mask == 0)
-		goto out;
-
-	exp = nf_ct_expect_alloc(ct);
-	if (exp == NULL)
-		goto out;
-
-	exp->tuple                = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
-	exp->tuple.src.u.udp.port = htons(NMBD_PORT);
-
-	exp->mask.src.u3.ip       = mask;
-	exp->mask.src.u.udp.port  = htons(0xFFFF);
-
-	exp->expectfn             = NULL;
-	exp->flags                = NF_CT_EXPECT_PERMANENT;
-	exp->class		  = NF_CT_EXPECT_CLASS_DEFAULT;
-	exp->helper               = NULL;
-
-	nf_ct_expect_related(exp);
-	nf_ct_expect_put(exp);
-
-	nf_ct_refresh(ct, skb, timeout * HZ);
-out:
-	return NF_ACCEPT;
-}
-
 static struct nf_conntrack_expect_policy exp_policy = {
 	.max_expected	= 1,
 };
 
+static int netbios_ns_help(struct sk_buff *skb, unsigned int protoff,
+		   struct nf_conn *ct, enum ip_conntrack_info ctinfo)
+{
+	return nf_conntrack_broadcast_help(skb, protoff, ct, ctinfo, timeout);
+}
+
 static struct nf_conntrack_helper helper __read_mostly = {
 	.name			= "netbios-ns",
-	.tuple.src.l3num	= AF_INET,
+	.tuple.src.l3num	= NFPROTO_IPV4,
 	.tuple.src.u.udp.port	= cpu_to_be16(NMBD_PORT),
 	.tuple.dst.protonum	= IPPROTO_UDP,
 	.me			= THIS_MODULE,
-	.help			= help,
+	.help			= netbios_ns_help,
 	.expect_policy		= &exp_policy,
 };
 
diff --git a/net/netfilter/nf_conntrack_snmp.c b/net/netfilter/nf_conntrack_snmp.c
new file mode 100644
index 0000000..6e545e2
--- /dev/null
+++ b/net/netfilter/nf_conntrack_snmp.c
@@ -0,0 +1,77 @@
+/*
+ *      SNMP service broadcast connection tracking helper
+ *
+ *      (c) 2011 Jiri Olsa <jolsa@redhat.com>
+ *
+ *      This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/in.h>
+
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_expect.h>
+
+#define SNMP_PORT	161
+
+MODULE_AUTHOR("Jiri Olsa <jolsa@redhat.com>");
+MODULE_DESCRIPTION("SNMP service broadcast connection tracking helper");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NFCT_HELPER("snmp");
+
+static unsigned int timeout __read_mostly = 30;
+module_param(timeout, uint, S_IRUSR);
+MODULE_PARM_DESC(timeout, "timeout for master connection/replies in seconds");
+
+int (*nf_nat_snmp_hook)(struct sk_buff *skb,
+			unsigned int protoff,
+			struct nf_conn *ct,
+			enum ip_conntrack_info ctinfo);
+EXPORT_SYMBOL_GPL(nf_nat_snmp_hook);
+
+static int snmp_conntrack_help(struct sk_buff *skb, unsigned int protoff,
+		struct nf_conn *ct, enum ip_conntrack_info ctinfo)
+{
+	typeof(nf_nat_snmp_hook) nf_nat_snmp;
+
+	nf_conntrack_broadcast_help(skb, protoff, ct, ctinfo, timeout);
+
+	nf_nat_snmp = rcu_dereference(nf_nat_snmp_hook);
+	if (nf_nat_snmp && ct->status & IPS_NAT_MASK)
+		return nf_nat_snmp(skb, protoff, ct, ctinfo);
+
+	return NF_ACCEPT;
+}
+
+static struct nf_conntrack_expect_policy exp_policy = {
+	.max_expected	= 1,
+};
+
+static struct nf_conntrack_helper helper __read_mostly = {
+	.name			= "snmp",
+	.tuple.src.l3num	= NFPROTO_IPV4,
+	.tuple.src.u.udp.port	= cpu_to_be16(SNMP_PORT),
+	.tuple.dst.protonum	= IPPROTO_UDP,
+	.me			= THIS_MODULE,
+	.help			= snmp_conntrack_help,
+	.expect_policy		= &exp_policy,
+};
+
+static int __init nf_conntrack_snmp_init(void)
+{
+	exp_policy.timeout = timeout;
+	return nf_conntrack_helper_register(&helper);
+}
+
+static void __exit nf_conntrack_snmp_fini(void)
+{
+	nf_conntrack_helper_unregister(&helper);
+}
+
+module_init(nf_conntrack_snmp_init);
+module_exit(nf_conntrack_snmp_fini);
-- 
1.7.2.3

