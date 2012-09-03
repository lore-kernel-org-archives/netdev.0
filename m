From: pablo@netfilter.org
Subject: [PATCH 17/25] netfilter: nf_nat: support IPv6 in TFTP NAT helper
Date: Tue,  4 Sep 2012 01:54:04 +0200
Message-ID: <1346716452-3080-18-git-send-email-pablo@netfilter.org>
References: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/Kconfig        |    5 ----
 net/ipv4/netfilter/Makefile       |    1 -
 net/ipv4/netfilter/nf_nat_tftp.c  |   50 -------------------------------------
 net/netfilter/Kconfig             |    5 ++++
 net/netfilter/Makefile            |    1 +
 net/netfilter/nf_conntrack_tftp.c |    3 +--
 net/netfilter/nf_nat_tftp.c       |   50 +++++++++++++++++++++++++++++++++++++
 7 files changed, 57 insertions(+), 58 deletions(-)
 delete mode 100644 net/ipv4/netfilter/nf_nat_tftp.c
 create mode 100644 net/netfilter/nf_nat_tftp.c

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 843fe17..131e537 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -221,11 +221,6 @@ config NF_NAT_PROTO_GRE
 	tristate
 	depends on NF_NAT_IPV4 && NF_CT_PROTO_GRE
 
-config NF_NAT_TFTP
-	tristate
-	depends on NF_CONNTRACK && NF_NAT_IPV4
-	default NF_NAT_IPV4 && NF_CONNTRACK_TFTP
-
 config NF_NAT_PPTP
 	tristate
 	depends on NF_CONNTRACK && NF_NAT_IPV4
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 17e649b..b7dd189 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -23,7 +23,6 @@ obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
 obj-$(CONFIG_NF_NAT_H323) += nf_nat_h323.o
 obj-$(CONFIG_NF_NAT_PPTP) += nf_nat_pptp.o
 obj-$(CONFIG_NF_NAT_SNMP_BASIC) += nf_nat_snmp_basic.o
-obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
 
 # NAT protocols (nf_nat)
 obj-$(CONFIG_NF_NAT_PROTO_GRE) += nf_nat_proto_gre.o
diff --git a/net/ipv4/netfilter/nf_nat_tftp.c b/net/ipv4/netfilter/nf_nat_tftp.c
deleted file mode 100644
index ccabbda..0000000
--- a/net/ipv4/netfilter/nf_nat_tftp.c
+++ /dev/null
@@ -1,50 +0,0 @@
-/* (C) 2001-2002 Magnus Boden <mb@ozaba.mine.nu>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/udp.h>
-
-#include <net/netfilter/nf_conntrack_helper.h>
-#include <net/netfilter/nf_conntrack_expect.h>
-#include <net/netfilter/nf_nat_helper.h>
-#include <linux/netfilter/nf_conntrack_tftp.h>
-
-MODULE_AUTHOR("Magnus Boden <mb@ozaba.mine.nu>");
-MODULE_DESCRIPTION("TFTP NAT helper");
-MODULE_LICENSE("GPL");
-MODULE_ALIAS("ip_nat_tftp");
-
-static unsigned int help(struct sk_buff *skb,
-			 enum ip_conntrack_info ctinfo,
-			 struct nf_conntrack_expect *exp)
-{
-	const struct nf_conn *ct = exp->master;
-
-	exp->saved_proto.udp.port
-		= ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.udp.port;
-	exp->dir = IP_CT_DIR_REPLY;
-	exp->expectfn = nf_nat_follow_master;
-	if (nf_ct_expect_related(exp) != 0)
-		return NF_DROP;
-	return NF_ACCEPT;
-}
-
-static void __exit nf_nat_tftp_fini(void)
-{
-	RCU_INIT_POINTER(nf_nat_tftp_hook, NULL);
-	synchronize_rcu();
-}
-
-static int __init nf_nat_tftp_init(void)
-{
-	BUG_ON(nf_nat_tftp_hook != NULL);
-	RCU_INIT_POINTER(nf_nat_tftp_hook, help);
-	return 0;
-}
-
-module_init(nf_nat_tftp_init);
-module_exit(nf_nat_tftp_fini);
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index cabe4da..052836e 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -400,6 +400,11 @@ config NF_NAT_SIP
 	depends on NF_CONNTRACK && NF_NAT
 	default NF_NAT && NF_CONNTRACK_SIP
 
+config NF_NAT_TFTP
+	tristate
+	depends on NF_CONNTRACK && NF_NAT
+	default NF_NAT && NF_CONNTRACK_TFTP
+
 endif # NF_CONNTRACK
 
 # transparent proxy support
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 0dd7929..403ea812 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -59,6 +59,7 @@ obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
 obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
 obj-$(CONFIG_NF_NAT_IRC) += nf_nat_irc.o
 obj-$(CONFIG_NF_NAT_SIP) += nf_nat_sip.o
+obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
 
 # transparent proxy support
 obj-$(CONFIG_NETFILTER_TPROXY) += nf_tproxy_core.o
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index 9363e1c..81fc61c 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -72,8 +72,7 @@ static int tftp_help(struct sk_buff *skb,
 		nf_ct_dump_tuple(&exp->tuple);
 
 		nf_nat_tftp = rcu_dereference(nf_nat_tftp_hook);
-		if (nf_nat_tftp && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
-		    ct->status & IPS_NAT_MASK)
+		if (nf_nat_tftp && ct->status & IPS_NAT_MASK)
 			ret = nf_nat_tftp(skb, ctinfo, exp);
 		else if (nf_ct_expect_related(exp) != 0)
 			ret = NF_DROP;
diff --git a/net/netfilter/nf_nat_tftp.c b/net/netfilter/nf_nat_tftp.c
new file mode 100644
index 0000000..ccabbda
--- /dev/null
+++ b/net/netfilter/nf_nat_tftp.c
@@ -0,0 +1,50 @@
+/* (C) 2001-2002 Magnus Boden <mb@ozaba.mine.nu>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/udp.h>
+
+#include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_nat_helper.h>
+#include <linux/netfilter/nf_conntrack_tftp.h>
+
+MODULE_AUTHOR("Magnus Boden <mb@ozaba.mine.nu>");
+MODULE_DESCRIPTION("TFTP NAT helper");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ip_nat_tftp");
+
+static unsigned int help(struct sk_buff *skb,
+			 enum ip_conntrack_info ctinfo,
+			 struct nf_conntrack_expect *exp)
+{
+	const struct nf_conn *ct = exp->master;
+
+	exp->saved_proto.udp.port
+		= ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.udp.port;
+	exp->dir = IP_CT_DIR_REPLY;
+	exp->expectfn = nf_nat_follow_master;
+	if (nf_ct_expect_related(exp) != 0)
+		return NF_DROP;
+	return NF_ACCEPT;
+}
+
+static void __exit nf_nat_tftp_fini(void)
+{
+	RCU_INIT_POINTER(nf_nat_tftp_hook, NULL);
+	synchronize_rcu();
+}
+
+static int __init nf_nat_tftp_init(void)
+{
+	BUG_ON(nf_nat_tftp_hook != NULL);
+	RCU_INIT_POINTER(nf_nat_tftp_hook, help);
+	return 0;
+}
+
+module_init(nf_nat_tftp_init);
+module_exit(nf_nat_tftp_fini);
-- 
1.7.10.4

