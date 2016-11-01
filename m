From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/12] netfilter: nf_log: add packet logging for netdev family
Date: Tue,  1 Nov 2016 22:26:29 +0100
Message-ID: <1478035593-1362-9-git-send-email-pablo@netfilter.org>
References: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52606 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932462AbcKAV1N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 17:27:13 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 93C0C16839B
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:06 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 81CF8BAC32
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:06 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3B707BAC32
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:04 +0100 (CET)
In-Reply-To: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move layer 2 packet logging into nf_log_l2packet() that resides in
nf_log_common.c, so this can be shared by both bridge and netdev
families.

This patch adds the boiler plate code to register the netdev logging
family.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_log.h       |  5 +++
 net/bridge/netfilter/Kconfig         |  1 +
 net/bridge/netfilter/nf_log_bridge.c | 16 +-------
 net/netfilter/Kconfig                |  4 ++
 net/netfilter/Makefile               |  3 ++
 net/netfilter/nf_log_common.c        | 27 ++++++++++++
 net/netfilter/nf_log_netdev.c        | 80 ++++++++++++++++++++++++++++++++++++
 7 files changed, 121 insertions(+), 15 deletions(-)
 create mode 100644 net/netfilter/nf_log_netdev.c

diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_log.h
index 309cd267be4f..a559aa41253c 100644
--- a/include/net/netfilter/nf_log.h
+++ b/include/net/netfilter/nf_log.h
@@ -109,5 +109,10 @@ void nf_log_dump_packet_common(struct nf_log_buf *m, u_int8_t pf,
 			       const struct net_device *out,
 			       const struct nf_loginfo *loginfo,
 			       const char *prefix);
+void nf_log_l2packet(struct net *net, u_int8_t pf, unsigned int hooknum,
+		     const struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out,
+		     const struct nf_loginfo *loginfo, const char *prefix);
 
 #endif /* _NF_LOG_H */
diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
index 9cebf47ac840..e7ef1a1ef3a6 100644
--- a/net/bridge/netfilter/Kconfig
+++ b/net/bridge/netfilter/Kconfig
@@ -22,6 +22,7 @@ config NFT_BRIDGE_REJECT
 
 config NF_LOG_BRIDGE
 	tristate "Bridge packet logging"
+	select NF_LOG_COMMON
 
 endif # NF_TABLES_BRIDGE
 
diff --git a/net/bridge/netfilter/nf_log_bridge.c b/net/bridge/netfilter/nf_log_bridge.c
index 1663df598545..c197b1f844ee 100644
--- a/net/bridge/netfilter/nf_log_bridge.c
+++ b/net/bridge/netfilter/nf_log_bridge.c
@@ -24,21 +24,7 @@ static void nf_log_bridge_packet(struct net *net, u_int8_t pf,
 				 const struct nf_loginfo *loginfo,
 				 const char *prefix)
 {
-	switch (eth_hdr(skb)->h_proto) {
-	case htons(ETH_P_IP):
-		nf_log_packet(net, NFPROTO_IPV4, hooknum, skb, in, out,
-			      loginfo, "%s", prefix);
-		break;
-	case htons(ETH_P_IPV6):
-		nf_log_packet(net, NFPROTO_IPV6, hooknum, skb, in, out,
-			      loginfo, "%s", prefix);
-		break;
-	case htons(ETH_P_ARP):
-	case htons(ETH_P_RARP):
-		nf_log_packet(net, NFPROTO_ARP, hooknum, skb, in, out,
-			      loginfo, "%s", prefix);
-		break;
-	}
+	nf_log_l2packet(net, pf, hooknum, skb, in, out, loginfo, prefix);
 }
 
 static struct nf_logger nf_bridge_logger __read_mostly = {
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 9bcf899ce16e..854dadb196a1 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -57,6 +57,10 @@ config NF_CONNTRACK
 config NF_LOG_COMMON
 	tristate
 
+config NF_LOG_NETDEV
+	tristate "Netdev packet logging"
+	select NF_LOG_COMMON
+
 if NF_CONNTRACK
 
 config NF_CONNTRACK_MARK
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 8faa36c0686d..8edd791743fe 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -48,6 +48,9 @@ nf_nat-y	:= nf_nat_core.o nf_nat_proto_unknown.o nf_nat_proto_common.o \
 # generic transport layer logging
 obj-$(CONFIG_NF_LOG_COMMON) += nf_log_common.o
 
+# packet logging for netdev family
+obj-$(CONFIG_NF_LOG_NETDEV) += nf_log_netdev.o
+
 obj-$(CONFIG_NF_NAT) += nf_nat.o
 obj-$(CONFIG_NF_NAT_REDIRECT) += nf_nat_redirect.o
 
diff --git a/net/netfilter/nf_log_common.c b/net/netfilter/nf_log_common.c
index 119fe1cb1ea9..ed9b80815fa0 100644
--- a/net/netfilter/nf_log_common.c
+++ b/net/netfilter/nf_log_common.c
@@ -175,6 +175,33 @@ nf_log_dump_packet_common(struct nf_log_buf *m, u_int8_t pf,
 }
 EXPORT_SYMBOL_GPL(nf_log_dump_packet_common);
 
+/* bridge and netdev logging families share this code. */
+void nf_log_l2packet(struct net *net, u_int8_t pf,
+		     unsigned int hooknum,
+		     const struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out,
+		     const struct nf_loginfo *loginfo,
+		     const char *prefix)
+{
+	switch (eth_hdr(skb)->h_proto) {
+	case htons(ETH_P_IP):
+		nf_log_packet(net, NFPROTO_IPV4, hooknum, skb, in, out,
+			      loginfo, "%s", prefix);
+		break;
+	case htons(ETH_P_IPV6):
+		nf_log_packet(net, NFPROTO_IPV6, hooknum, skb, in, out,
+			      loginfo, "%s", prefix);
+		break;
+	case htons(ETH_P_ARP):
+	case htons(ETH_P_RARP):
+		nf_log_packet(net, NFPROTO_ARP, hooknum, skb, in, out,
+			      loginfo, "%s", prefix);
+		break;
+	}
+}
+EXPORT_SYMBOL_GPL(nf_log_l2packet);
+
 static int __init nf_log_common_init(void)
 {
 	return 0;
diff --git a/net/netfilter/nf_log_netdev.c b/net/netfilter/nf_log_netdev.c
new file mode 100644
index 000000000000..1f645949f3d8
--- /dev/null
+++ b/net/netfilter/nf_log_netdev.c
@@ -0,0 +1,80 @@
+/*
+ * (C) 2016 by Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/spinlock.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <net/route.h>
+
+#include <linux/netfilter.h>
+#include <net/netfilter/nf_log.h>
+
+static void nf_log_netdev_packet(struct net *net, u_int8_t pf,
+				 unsigned int hooknum,
+				 const struct sk_buff *skb,
+				 const struct net_device *in,
+				 const struct net_device *out,
+				 const struct nf_loginfo *loginfo,
+				 const char *prefix)
+{
+	nf_log_l2packet(net, pf, hooknum, skb, in, out, loginfo, prefix);
+}
+
+static struct nf_logger nf_netdev_logger __read_mostly = {
+	.name		= "nf_log_netdev",
+	.type		= NF_LOG_TYPE_LOG,
+	.logfn		= nf_log_netdev_packet,
+	.me		= THIS_MODULE,
+};
+
+static int __net_init nf_log_netdev_net_init(struct net *net)
+{
+	return nf_log_set(net, NFPROTO_NETDEV, &nf_netdev_logger);
+}
+
+static void __net_exit nf_log_netdev_net_exit(struct net *net)
+{
+	nf_log_unset(net, &nf_netdev_logger);
+}
+
+static struct pernet_operations nf_log_netdev_net_ops = {
+	.init = nf_log_netdev_net_init,
+	.exit = nf_log_netdev_net_exit,
+};
+
+static int __init nf_log_netdev_init(void)
+{
+	int ret;
+
+	/* Request to load the real packet loggers. */
+	nf_logger_request_module(NFPROTO_IPV4, NF_LOG_TYPE_LOG);
+	nf_logger_request_module(NFPROTO_IPV6, NF_LOG_TYPE_LOG);
+	nf_logger_request_module(NFPROTO_ARP, NF_LOG_TYPE_LOG);
+
+	ret = register_pernet_subsys(&nf_log_netdev_net_ops);
+	if (ret < 0)
+		return ret;
+
+	nf_log_register(NFPROTO_NETDEV, &nf_netdev_logger);
+	return 0;
+}
+
+static void __exit nf_log_netdev_exit(void)
+{
+	unregister_pernet_subsys(&nf_log_netdev_net_ops);
+	nf_log_unregister(&nf_netdev_logger);
+}
+
+module_init(nf_log_netdev_init);
+module_exit(nf_log_netdev_exit);
+
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_DESCRIPTION("Netfilter netdev packet logging");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NF_LOGGER(5, 0); /* NFPROTO_NETDEV */
-- 
2.1.4
