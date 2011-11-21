From: kaber@trash.net
Subject: [PATCH 16/17] netfilter: nf_nat: support IPv6 in FTP NAT helper
Date: Mon, 21 Nov 2011 06:46:08 +0100
Message-ID: <1321854369-3432-17-git-send-email-kaber@trash.net>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61170 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab1KUFtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:49:16 -0500
In-Reply-To: <1321854369-3432-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/Kconfig       |    5 --
 net/ipv4/netfilter/Makefile      |    1 -
 net/ipv4/netfilter/nf_nat_ftp.c  |  137 ------------------------------------
 net/netfilter/Kconfig            |    5 ++
 net/netfilter/Makefile           |    3 +
 net/netfilter/nf_conntrack_ftp.c |    3 +-
 net/netfilter/nf_nat_ftp.c       |  142 ++++++++++++++++++++++++++++++++++++++
 7 files changed, 151 insertions(+), 145 deletions(-)
 delete mode 100644 net/ipv4/netfilter/nf_nat_ftp.c
 create mode 100644 net/netfilter/nf_nat_ftp.c

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 56a1742..1b043a5 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -219,11 +219,6 @@ config NF_NAT_PROTO_GRE
 	tristate
 	depends on NF_NAT_IPV4 && NF_CT_PROTO_GRE
 
-config NF_NAT_FTP
-	tristate
-	depends on NF_CONNTRACK && NF_NAT_IPV4
-	default NF_NAT_IPV4 && NF_CONNTRACK_FTP
-
 config NF_NAT_IRC
 	tristate
 	depends on NF_CONNTRACK && NF_NAT_IPV4
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index a655e00..0fa8715 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -21,7 +21,6 @@ obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
 
 # NAT helpers (nf_conntrack)
 obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
-obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
 obj-$(CONFIG_NF_NAT_H323) += nf_nat_h323.o
 obj-$(CONFIG_NF_NAT_IRC) += nf_nat_irc.o
 obj-$(CONFIG_NF_NAT_PPTP) += nf_nat_pptp.o
diff --git a/net/ipv4/netfilter/nf_nat_ftp.c b/net/ipv4/netfilter/nf_nat_ftp.c
deleted file mode 100644
index f0d85a1..0000000
--- a/net/ipv4/netfilter/nf_nat_ftp.c
+++ /dev/null
@@ -1,137 +0,0 @@
-/* FTP extension for TCP NAT alteration. */
-
-/* (C) 1999-2001 Paul `Rusty' Russell
- * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/moduleparam.h>
-#include <linux/ip.h>
-#include <linux/tcp.h>
-#include <linux/netfilter_ipv4.h>
-#include <net/netfilter/nf_nat.h>
-#include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/nf_conntrack_helper.h>
-#include <net/netfilter/nf_conntrack_expect.h>
-#include <linux/netfilter/nf_conntrack_ftp.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Rusty Russell <rusty@rustcorp.com.au>");
-MODULE_DESCRIPTION("ftp NAT helper");
-MODULE_ALIAS("ip_nat_ftp");
-
-/* FIXME: Time out? --RR */
-
-static int nf_nat_ftp_fmt_cmd(enum nf_ct_ftp_type type,
-			      char *buffer, size_t buflen,
-			      __be32 addr, u16 port)
-{
-	switch (type) {
-	case NF_CT_FTP_PORT:
-	case NF_CT_FTP_PASV:
-		return snprintf(buffer, buflen, "%u,%u,%u,%u,%u,%u",
-				((unsigned char *)&addr)[0],
-				((unsigned char *)&addr)[1],
-				((unsigned char *)&addr)[2],
-				((unsigned char *)&addr)[3],
-				port >> 8,
-				port & 0xFF);
-	case NF_CT_FTP_EPRT:
-		return snprintf(buffer, buflen, "|1|%pI4|%u|", &addr, port);
-	case NF_CT_FTP_EPSV:
-		return snprintf(buffer, buflen, "|||%u|", port);
-	}
-
-	return 0;
-}
-
-/* So, this packet has hit the connection tracking matching code.
-   Mangle it, and change the expectation to match the new version. */
-static unsigned int nf_nat_ftp(struct sk_buff *skb,
-			       enum ip_conntrack_info ctinfo,
-			       enum nf_ct_ftp_type type,
-			       unsigned int protoff,
-			       unsigned int matchoff,
-			       unsigned int matchlen,
-			       struct nf_conntrack_expect *exp)
-{
-	__be32 newip;
-	u_int16_t port;
-	int dir = CTINFO2DIR(ctinfo);
-	struct nf_conn *ct = exp->master;
-	char buffer[sizeof("|1|255.255.255.255|65535|")];
-	unsigned int buflen;
-
-	pr_debug("FTP_NAT: type %i, off %u len %u\n", type, matchoff, matchlen);
-
-	/* Connection will come from wherever this packet goes, hence !dir */
-	newip = ct->tuplehash[!dir].tuple.dst.u3.ip;
-	exp->saved_proto.tcp.port = exp->tuple.dst.u.tcp.port;
-	exp->dir = !dir;
-
-	/* When you see the packet, we need to NAT it the same as the
-	 * this one. */
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
-	buflen = nf_nat_ftp_fmt_cmd(type, buffer, sizeof(buffer), newip, port);
-	if (!buflen)
-		goto out;
-
-	pr_debug("calling nf_nat_mangle_tcp_packet\n");
-
-	if (!nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff, matchoff,
-				      matchlen, buffer, buflen))
-		goto out;
-
-	return NF_ACCEPT;
-
-out:
-	nf_ct_unexpect_related(exp);
-	return NF_DROP;
-}
-
-static void __exit nf_nat_ftp_fini(void)
-{
-	rcu_assign_pointer(nf_nat_ftp_hook, NULL);
-	synchronize_rcu();
-}
-
-static int __init nf_nat_ftp_init(void)
-{
-	BUG_ON(nf_nat_ftp_hook != NULL);
-	rcu_assign_pointer(nf_nat_ftp_hook, nf_nat_ftp);
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
-module_init(nf_nat_ftp_init);
-module_exit(nf_nat_ftp_fini);
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 9e29e5c..5ce87f7 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -321,6 +321,11 @@ config NF_NAT_PROTO_SCTP
 	depends on NF_NAT && NF_CT_PROTO_SCTP
 	select LIBCRC32C
 
+config NF_NAT_FTP
+	tristate
+	depends on NF_CONNTRACK && NF_NAT
+	default NF_NAT && NF_CONNTRACK_FTP
+
 endif # NF_CONNTRACK
 
 # transparent proxy support
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index af649c1..a747580 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -48,6 +48,9 @@ obj-$(CONFIG_NF_NAT_PROTO_DCCP) += nf_nat_proto_dccp.o
 obj-$(CONFIG_NF_NAT_PROTO_UDPLITE) += nf_nat_proto_udplite.o
 obj-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
 
+# NAT helpers
+obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
+
 # transparent proxy support
 obj-$(CONFIG_NETFILTER_TPROXY) += nf_tproxy_core.o
 
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index c6634ad..80614dd 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -488,8 +488,7 @@ static int help(struct sk_buff *skb,
 	/* Now, NAT might want to mangle the packet, and register the
 	 * (possibly changed) expectation itself. */
 	nf_nat_ftp = rcu_dereference(nf_nat_ftp_hook);
-	if (nf_nat_ftp && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
-	    ct->status & IPS_NAT_MASK)
+	if (nf_nat_ftp && ct->status & IPS_NAT_MASK)
 		ret = nf_nat_ftp(skb, ctinfo, search[dir][i].ftptype,
 				 protoff, matchoff, matchlen, exp);
 	else {
diff --git a/net/netfilter/nf_nat_ftp.c b/net/netfilter/nf_nat_ftp.c
new file mode 100644
index 0000000..26c79dd
--- /dev/null
+++ b/net/netfilter/nf_nat_ftp.c
@@ -0,0 +1,142 @@
+/* FTP extension for TCP NAT alteration. */
+
+/* (C) 1999-2001 Paul `Rusty' Russell
+ * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/tcp.h>
+#include <linux/netfilter_ipv4.h>
+#include <net/netfilter/nf_nat.h>
+#include <net/netfilter/nf_nat_helper.h>
+#include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_expect.h>
+#include <linux/netfilter/nf_conntrack_ftp.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Rusty Russell <rusty@rustcorp.com.au>");
+MODULE_DESCRIPTION("ftp NAT helper");
+MODULE_ALIAS("ip_nat_ftp");
+
+/* FIXME: Time out? --RR */
+
+static int nf_nat_ftp_fmt_cmd(struct nf_conn *ct, enum nf_ct_ftp_type type,
+			      char *buffer, size_t buflen,
+			      union nf_inet_addr *addr, u16 port)
+{
+	switch (type) {
+	case NF_CT_FTP_PORT:
+	case NF_CT_FTP_PASV:
+		return snprintf(buffer, buflen, "%u,%u,%u,%u,%u,%u",
+				((unsigned char *)&addr->ip)[0],
+				((unsigned char *)&addr->ip)[1],
+				((unsigned char *)&addr->ip)[2],
+				((unsigned char *)&addr->ip)[3],
+				port >> 8,
+				port & 0xFF);
+	case NF_CT_FTP_EPRT:
+		if (nf_ct_l3num(ct) == NFPROTO_IPV4)
+			return snprintf(buffer, buflen, "|1|%pI4|%u|",
+					&addr->ip, port);
+		else
+			return snprintf(buffer, buflen, "|2|%pI6|%u|",
+					&addr->ip6, port);
+	case NF_CT_FTP_EPSV:
+		return snprintf(buffer, buflen, "|||%u|", port);
+	}
+
+	return 0;
+}
+
+/* So, this packet has hit the connection tracking matching code.
+   Mangle it, and change the expectation to match the new version. */
+static unsigned int nf_nat_ftp(struct sk_buff *skb,
+			       enum ip_conntrack_info ctinfo,
+			       enum nf_ct_ftp_type type,
+			       unsigned int protoff,
+			       unsigned int matchoff,
+			       unsigned int matchlen,
+			       struct nf_conntrack_expect *exp)
+{
+	union nf_inet_addr newaddr;
+	u_int16_t port;
+	int dir = CTINFO2DIR(ctinfo);
+	struct nf_conn *ct = exp->master;
+	char buffer[sizeof("|1||65535|") + INET6_ADDRSTRLEN];
+	unsigned int buflen;
+
+	pr_debug("FTP_NAT: type %i, off %u len %u\n", type, matchoff, matchlen);
+
+	/* Connection will come from wherever this packet goes, hence !dir */
+	newaddr = ct->tuplehash[!dir].tuple.dst.u3;
+	exp->saved_proto.tcp.port = exp->tuple.dst.u.tcp.port;
+	exp->dir = !dir;
+
+	/* When you see the packet, we need to NAT it the same as the
+	 * this one. */
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
+	buflen = nf_nat_ftp_fmt_cmd(ct, type, buffer, sizeof(buffer),
+				    &newaddr, port);
+	if (!buflen)
+		goto out;
+
+	pr_debug("calling nf_nat_mangle_tcp_packet\n");
+
+	if (!nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff, matchoff,
+				      matchlen, buffer, buflen))
+		goto out;
+
+	return NF_ACCEPT;
+
+out:
+	nf_ct_unexpect_related(exp);
+	return NF_DROP;
+}
+
+static void __exit nf_nat_ftp_fini(void)
+{
+	rcu_assign_pointer(nf_nat_ftp_hook, NULL);
+	synchronize_rcu();
+}
+
+static int __init nf_nat_ftp_init(void)
+{
+	BUG_ON(nf_nat_ftp_hook != NULL);
+	rcu_assign_pointer(nf_nat_ftp_hook, nf_nat_ftp);
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
+module_init(nf_nat_ftp_init);
+module_exit(nf_nat_ftp_fini);
-- 
1.7.1
