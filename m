From: pablo@netfilter.org
Subject: [PATCH 16/25] netfilter: nf_nat: support IPv6 in IRC NAT helper
Date: Tue,  4 Sep 2012 01:54:03 +0200
Message-ID: <1346716452-3080-17-git-send-email-pablo@netfilter.org>
References: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37148 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098Ab2ICXz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 19:55:58 -0400
In-Reply-To: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/Kconfig       |    5 --
 net/ipv4/netfilter/Makefile      |    1 -
 net/ipv4/netfilter/nf_nat_irc.c  |   99 --------------------------------------
 net/netfilter/Kconfig            |    5 ++
 net/netfilter/Makefile           |    1 +
 net/netfilter/nf_conntrack_irc.c |    3 +-
 net/netfilter/nf_nat_irc.c       |   93 +++++++++++++++++++++++++++++++++++
 7 files changed, 100 insertions(+), 107 deletions(-)
 delete mode 100644 net/ipv4/netfilter/nf_nat_irc.c
 create mode 100644 net/netfilter/nf_nat_irc.c

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 30197f8..843fe17 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -221,11 +221,6 @@ config NF_NAT_PROTO_GRE
 	tristate
 	depends on NF_NAT_IPV4 && NF_CT_PROTO_GRE
 
-config NF_NAT_IRC
-	tristate
-	depends on NF_CONNTRACK && NF_NAT_IPV4
-	default NF_NAT_IPV4 && NF_CONNTRACK_IRC
-
 config NF_NAT_TFTP
 	tristate
 	depends on NF_CONNTRACK && NF_NAT_IPV4
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 8914abf..17e649b 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -21,7 +21,6 @@ obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
 
 # NAT helpers (nf_conntrack)
 obj-$(CONFIG_NF_NAT_H323) += nf_nat_h323.o
-obj-$(CONFIG_NF_NAT_IRC) += nf_nat_irc.o
 obj-$(CONFIG_NF_NAT_PPTP) += nf_nat_pptp.o
 obj-$(CONFIG_NF_NAT_SNMP_BASIC) += nf_nat_snmp_basic.o
 obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
diff --git a/net/ipv4/netfilter/nf_nat_irc.c b/net/ipv4/netfilter/nf_nat_irc.c
deleted file mode 100644
index 1ce37f8..0000000
--- a/net/ipv4/netfilter/nf_nat_irc.c
+++ /dev/null
@@ -1,99 +0,0 @@
-/* IRC extension for TCP NAT alteration.
- *
- * (C) 2000-2001 by Harald Welte <laforge@gnumonks.org>
- * (C) 2004 Rusty Russell <rusty@rustcorp.com.au> IBM Corporation
- * based on a copy of RR's ip_nat_ftp.c
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#include <linux/module.h>
-#include <linux/moduleparam.h>
-#include <linux/tcp.h>
-#include <linux/kernel.h>
-
-#include <net/netfilter/nf_nat.h>
-#include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/nf_conntrack_helper.h>
-#include <net/netfilter/nf_conntrack_expect.h>
-#include <linux/netfilter/nf_conntrack_irc.h>
-
-MODULE_AUTHOR("Harald Welte <laforge@gnumonks.org>");
-MODULE_DESCRIPTION("IRC (DCC) NAT helper");
-MODULE_LICENSE("GPL");
-MODULE_ALIAS("ip_nat_irc");
-
-static unsigned int help(struct sk_buff *skb,
-			 enum ip_conntrack_info ctinfo,
-			 unsigned int protoff,
-			 unsigned int matchoff,
-			 unsigned int matchlen,
-			 struct nf_conntrack_expect *exp)
-{
-	char buffer[sizeof("4294967296 65635")];
-	u_int32_t ip;
-	u_int16_t port;
-	unsigned int ret;
-
-	/* Reply comes from server. */
-	exp->saved_proto.tcp.port = exp->tuple.dst.u.tcp.port;
-	exp->dir = IP_CT_DIR_REPLY;
-	exp->expectfn = nf_nat_follow_master;
-
-	/* Try to get same port: if not, try to change it. */
-	for (port = ntohs(exp->saved_proto.tcp.port); port != 0; port++) {
-		int ret;
-
-		exp->tuple.dst.u.tcp.port = htons(port);
-		ret = nf_ct_expect_related(exp);
-		if (ret == 0)
-			break;
-		else if (ret != -EBUSY) {
-			port = 0;
-			break;
-		}
-	}
-
-	if (port == 0)
-		return NF_DROP;
-
-	ip = ntohl(exp->master->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip);
-	sprintf(buffer, "%u %u", ip, port);
-	pr_debug("nf_nat_irc: inserting '%s' == %pI4, port %u\n",
-		 buffer, &ip, port);
-
-	ret = nf_nat_mangle_tcp_packet(skb, exp->master, ctinfo,
-				       protoff, matchoff, matchlen, buffer,
-				       strlen(buffer));
-	if (ret != NF_ACCEPT)
-		nf_ct_unexpect_related(exp);
-	return ret;
-}
-
-static void __exit nf_nat_irc_fini(void)
-{
-	RCU_INIT_POINTER(nf_nat_irc_hook, NULL);
-	synchronize_rcu();
-}
-
-static int __init nf_nat_irc_init(void)
-{
-	BUG_ON(nf_nat_irc_hook != NULL);
-	RCU_INIT_POINTER(nf_nat_irc_hook, help);
-	return 0;
-}
-
-/* Prior to 2.6.11, we had a ports param.  No longer, but don't break users. */
-static int warn_set(const char *val, struct kernel_param *kp)
-{
-	printk(KERN_INFO KBUILD_MODNAME
-	       ": kernel >= 2.6.10 only uses 'ports' for conntrack modules\n");
-	return 0;
-}
-module_param_call(ports, warn_set, NULL, NULL, 0);
-
-module_init(nf_nat_irc_init);
-module_exit(nf_nat_irc_fini);
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index bf3e464..cabe4da 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -390,6 +390,11 @@ config NF_NAT_FTP
 	depends on NF_CONNTRACK && NF_NAT
 	default NF_NAT && NF_CONNTRACK_FTP
 
+config NF_NAT_IRC
+	tristate
+	depends on NF_CONNTRACK && NF_NAT
+	default NF_NAT && NF_CONNTRACK_IRC
+
 config NF_NAT_SIP
 	tristate
 	depends on NF_CONNTRACK && NF_NAT
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 7d6d1a0..0dd7929 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -57,6 +57,7 @@ obj-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
 # NAT helpers
 obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
 obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
+obj-$(CONFIG_NF_NAT_IRC) += nf_nat_irc.o
 obj-$(CONFIG_NF_NAT_SIP) += nf_nat_sip.o
 
 # transparent proxy support
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 95d097c..3b20aa7 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -205,8 +205,7 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 					  IPPROTO_TCP, NULL, &port);
 
 			nf_nat_irc = rcu_dereference(nf_nat_irc_hook);
-			if (nf_nat_irc && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
-			    ct->status & IPS_NAT_MASK)
+			if (nf_nat_irc && ct->status & IPS_NAT_MASK)
 				ret = nf_nat_irc(skb, ctinfo, protoff,
 						 addr_beg_p - ib_ptr,
 						 addr_end_p - addr_beg_p,
diff --git a/net/netfilter/nf_nat_irc.c b/net/netfilter/nf_nat_irc.c
new file mode 100644
index 0000000..1fedee6
--- /dev/null
+++ b/net/netfilter/nf_nat_irc.c
@@ -0,0 +1,93 @@
+/* IRC extension for TCP NAT alteration.
+ *
+ * (C) 2000-2001 by Harald Welte <laforge@gnumonks.org>
+ * (C) 2004 Rusty Russell <rusty@rustcorp.com.au> IBM Corporation
+ * based on a copy of RR's ip_nat_ftp.c
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/tcp.h>
+#include <linux/kernel.h>
+
+#include <net/netfilter/nf_nat.h>
+#include <net/netfilter/nf_nat_helper.h>
+#include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_expect.h>
+#include <linux/netfilter/nf_conntrack_irc.h>
+
+MODULE_AUTHOR("Harald Welte <laforge@gnumonks.org>");
+MODULE_DESCRIPTION("IRC (DCC) NAT helper");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ip_nat_irc");
+
+static unsigned int help(struct sk_buff *skb,
+			 enum ip_conntrack_info ctinfo,
+			 unsigned int protoff,
+			 unsigned int matchoff,
+			 unsigned int matchlen,
+			 struct nf_conntrack_expect *exp)
+{
+	char buffer[sizeof("4294967296 65635")];
+	u_int16_t port;
+	unsigned int ret;
+
+	/* Reply comes from server. */
+	exp->saved_proto.tcp.port = exp->tuple.dst.u.tcp.port;
+	exp->dir = IP_CT_DIR_REPLY;
+	exp->expectfn = nf_nat_follow_master;
+
+	/* Try to get same port: if not, try to change it. */
+	for (port = ntohs(exp->saved_proto.tcp.port); port != 0; port++) {
+		int ret;
+
+		exp->tuple.dst.u.tcp.port = htons(port);
+		ret = nf_ct_expect_related(exp);
+		if (ret == 0)
+			break;
+		else if (ret != -EBUSY) {
+			port = 0;
+			break;
+		}
+	}
+
+	if (port == 0)
+		return NF_DROP;
+
+	ret = nf_nat_mangle_tcp_packet(skb, exp->master, ctinfo,
+				       protoff, matchoff, matchlen, buffer,
+				       strlen(buffer));
+	if (ret != NF_ACCEPT)
+		nf_ct_unexpect_related(exp);
+	return ret;
+}
+
+static void __exit nf_nat_irc_fini(void)
+{
+	RCU_INIT_POINTER(nf_nat_irc_hook, NULL);
+	synchronize_rcu();
+}
+
+static int __init nf_nat_irc_init(void)
+{
+	BUG_ON(nf_nat_irc_hook != NULL);
+	RCU_INIT_POINTER(nf_nat_irc_hook, help);
+	return 0;
+}
+
+/* Prior to 2.6.11, we had a ports param.  No longer, but don't break users. */
+static int warn_set(const char *val, struct kernel_param *kp)
+{
+	printk(KERN_INFO KBUILD_MODNAME
+	       ": kernel >= 2.6.10 only uses 'ports' for conntrack modules\n");
+	return 0;
+}
+module_param_call(ports, warn_set, NULL, NULL, 0);
+
+module_init(nf_nat_irc_init);
+module_exit(nf_nat_irc_fini);
-- 
1.7.10.4
