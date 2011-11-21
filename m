From: kaber@trash.net
Subject: [PATCH 17/17] netfilter: nf_nat: support IPv6 in amanda NAT helper
Date: Mon, 21 Nov 2011 06:46:09 +0100
Message-ID: <1321854369-3432-18-git-send-email-kaber@trash.net>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61172 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145Ab1KUFtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:49:17 -0500
In-Reply-To: <1321854369-3432-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/Kconfig          |    5 --
 net/ipv4/netfilter/Makefile         |    1 -
 net/ipv4/netfilter/nf_nat_amanda.c  |   85 -----------------------------------
 net/netfilter/Kconfig               |    5 ++
 net/netfilter/Makefile              |    1 +
 net/netfilter/nf_conntrack_amanda.c |    3 +-
 net/netfilter/nf_nat_amanda.c       |   85 +++++++++++++++++++++++++++++++++++
 7 files changed, 92 insertions(+), 93 deletions(-)
 delete mode 100644 net/ipv4/netfilter/nf_nat_amanda.c
 create mode 100644 net/netfilter/nf_nat_amanda.c

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 1b043a5..1c6917a 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -229,11 +229,6 @@ config NF_NAT_TFTP
 	depends on NF_CONNTRACK && NF_NAT_IPV4
 	default NF_NAT_IPV4 && NF_CONNTRACK_TFTP
 
-config NF_NAT_AMANDA
-	tristate
-	depends on NF_CONNTRACK && NF_NAT_IPV4
-	default NF_NAT_IPV4 && NF_CONNTRACK_AMANDA
-
 config NF_NAT_PPTP
 	tristate
 	depends on NF_CONNTRACK && NF_NAT_IPV4
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 0fa8715..b365cf2 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -20,7 +20,6 @@ obj-$(CONFIG_NF_NAT_IPV4) += nf_nat_ipv4.o
 obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
 
 # NAT helpers (nf_conntrack)
-obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
 obj-$(CONFIG_NF_NAT_H323) += nf_nat_h323.o
 obj-$(CONFIG_NF_NAT_IRC) += nf_nat_irc.o
 obj-$(CONFIG_NF_NAT_PPTP) += nf_nat_pptp.o
diff --git a/net/ipv4/netfilter/nf_nat_amanda.c b/net/ipv4/netfilter/nf_nat_amanda.c
deleted file mode 100644
index 044a7a0..0000000
--- a/net/ipv4/netfilter/nf_nat_amanda.c
+++ /dev/null
@@ -1,85 +0,0 @@
-/* Amanda extension for TCP NAT alteration.
- * (C) 2002 by Brian J. Murrell <netfilter@interlinx.bc.ca>
- * based on a copy of HW's ip_nat_irc.c as well as other modules
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/udp.h>
-
-#include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/nf_conntrack_helper.h>
-#include <net/netfilter/nf_conntrack_expect.h>
-#include <linux/netfilter/nf_conntrack_amanda.h>
-
-MODULE_AUTHOR("Brian J. Murrell <netfilter@interlinx.bc.ca>");
-MODULE_DESCRIPTION("Amanda NAT helper");
-MODULE_LICENSE("GPL");
-MODULE_ALIAS("ip_nat_amanda");
-
-static unsigned int help(struct sk_buff *skb,
-			 enum ip_conntrack_info ctinfo,
-			 unsigned int protoff,
-			 unsigned int matchoff,
-			 unsigned int matchlen,
-			 struct nf_conntrack_expect *exp)
-{
-	char buffer[sizeof("65535")];
-	u_int16_t port;
-	unsigned int ret;
-
-	/* Connection comes from client. */
-	exp->saved_proto.tcp.port = exp->tuple.dst.u.tcp.port;
-	exp->dir = IP_CT_DIR_ORIGINAL;
-
-	/* When you see the packet, we need to NAT it the same as the
-	 * this one (ie. same IP: it will be TCP and master is UDP). */
-	exp->expectfn = nf_nat_follow_master;
-
-	/* Try to get same port: if not, try to change it. */
-	for (port = ntohs(exp->saved_proto.tcp.port); port != 0; port++) {
-		int res;
-
-		exp->tuple.dst.u.tcp.port = htons(port);
-		res = nf_ct_expect_related(exp);
-		if (res == 0)
-			break;
-		else if (res != -EBUSY) {
-			port = 0;
-			break;
-		}
-	}
-
-	if (port == 0)
-		return NF_DROP;
-
-	sprintf(buffer, "%u", port);
-	ret = nf_nat_mangle_udp_packet(skb, exp->master, ctinfo,
-				       protoff, matchoff, matchlen,
-				       buffer, strlen(buffer));
-	if (ret != NF_ACCEPT)
-		nf_ct_unexpect_related(exp);
-	return ret;
-}
-
-static void __exit nf_nat_amanda_fini(void)
-{
-	rcu_assign_pointer(nf_nat_amanda_hook, NULL);
-	synchronize_rcu();
-}
-
-static int __init nf_nat_amanda_init(void)
-{
-	BUG_ON(nf_nat_amanda_hook != NULL);
-	rcu_assign_pointer(nf_nat_amanda_hook, help);
-	return 0;
-}
-
-module_init(nf_nat_amanda_init);
-module_exit(nf_nat_amanda_fini);
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 5ce87f7..02de8a9 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -321,6 +321,11 @@ config NF_NAT_PROTO_SCTP
 	depends on NF_NAT && NF_CT_PROTO_SCTP
 	select LIBCRC32C
 
+config NF_NAT_AMANDA
+	tristate
+	depends on NF_CONNTRACK && NF_NAT
+	default NF_NAT && NF_CONNTRACK_AMANDA
+
 config NF_NAT_FTP
 	tristate
 	depends on NF_CONNTRACK && NF_NAT
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index a747580..a28e44d 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -49,6 +49,7 @@ obj-$(CONFIG_NF_NAT_PROTO_UDPLITE) += nf_nat_proto_udplite.o
 obj-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
 
 # NAT helpers
+obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
 obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
 
 # transparent proxy support
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index dab3913..909c54d 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -156,8 +156,7 @@ static int amanda_help(struct sk_buff *skb,
 				  IPPROTO_TCP, NULL, &port);
 
 		nf_nat_amanda = rcu_dereference(nf_nat_amanda_hook);
-		if (nf_nat_amanda && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
-		    ct->status & IPS_NAT_MASK)
+		if (nf_nat_amanda && ct->status & IPS_NAT_MASK)
 			ret = nf_nat_amanda(skb, ctinfo, protoff,
 					    off - dataoff, len, exp);
 		else if (nf_ct_expect_related(exp) != 0)
diff --git a/net/netfilter/nf_nat_amanda.c b/net/netfilter/nf_nat_amanda.c
new file mode 100644
index 0000000..044a7a0
--- /dev/null
+++ b/net/netfilter/nf_nat_amanda.c
@@ -0,0 +1,85 @@
+/* Amanda extension for TCP NAT alteration.
+ * (C) 2002 by Brian J. Murrell <netfilter@interlinx.bc.ca>
+ * based on a copy of HW's ip_nat_irc.c as well as other modules
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/udp.h>
+
+#include <net/netfilter/nf_nat_helper.h>
+#include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_expect.h>
+#include <linux/netfilter/nf_conntrack_amanda.h>
+
+MODULE_AUTHOR("Brian J. Murrell <netfilter@interlinx.bc.ca>");
+MODULE_DESCRIPTION("Amanda NAT helper");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ip_nat_amanda");
+
+static unsigned int help(struct sk_buff *skb,
+			 enum ip_conntrack_info ctinfo,
+			 unsigned int protoff,
+			 unsigned int matchoff,
+			 unsigned int matchlen,
+			 struct nf_conntrack_expect *exp)
+{
+	char buffer[sizeof("65535")];
+	u_int16_t port;
+	unsigned int ret;
+
+	/* Connection comes from client. */
+	exp->saved_proto.tcp.port = exp->tuple.dst.u.tcp.port;
+	exp->dir = IP_CT_DIR_ORIGINAL;
+
+	/* When you see the packet, we need to NAT it the same as the
+	 * this one (ie. same IP: it will be TCP and master is UDP). */
+	exp->expectfn = nf_nat_follow_master;
+
+	/* Try to get same port: if not, try to change it. */
+	for (port = ntohs(exp->saved_proto.tcp.port); port != 0; port++) {
+		int res;
+
+		exp->tuple.dst.u.tcp.port = htons(port);
+		res = nf_ct_expect_related(exp);
+		if (res == 0)
+			break;
+		else if (res != -EBUSY) {
+			port = 0;
+			break;
+		}
+	}
+
+	if (port == 0)
+		return NF_DROP;
+
+	sprintf(buffer, "%u", port);
+	ret = nf_nat_mangle_udp_packet(skb, exp->master, ctinfo,
+				       protoff, matchoff, matchlen,
+				       buffer, strlen(buffer));
+	if (ret != NF_ACCEPT)
+		nf_ct_unexpect_related(exp);
+	return ret;
+}
+
+static void __exit nf_nat_amanda_fini(void)
+{
+	rcu_assign_pointer(nf_nat_amanda_hook, NULL);
+	synchronize_rcu();
+}
+
+static int __init nf_nat_amanda_init(void)
+{
+	BUG_ON(nf_nat_amanda_hook != NULL);
+	rcu_assign_pointer(nf_nat_amanda_hook, help);
+	return 0;
+}
+
+module_init(nf_nat_amanda_init);
+module_exit(nf_nat_amanda_fini);
-- 
1.7.1
