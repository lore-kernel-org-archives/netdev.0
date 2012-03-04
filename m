From: pablo@netfilter.org
Subject: [PATCH 6/7] netfilter: nf_ct_ext: add timeout extension
Date: Sun,  4 Mar 2012 12:27:57 +0100
Message-ID: <1330860478-13184-7-git-send-email-pablo@netfilter.org>
References: <1330860478-13184-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49036 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753321Ab2CDL2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2012 06:28:14 -0500
In-Reply-To: <1330860478-13184-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds the timeout extension, which allows you to attach
specific timeout policies to flows.

This extension is only used by the template conntrack.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_extend.h  |    4 +
 include/net/netfilter/nf_conntrack_timeout.h |   78 ++++++++++++++++++++++++++
 net/netfilter/Kconfig                        |   10 +++
 net/netfilter/Makefile                       |    1 +
 net/netfilter/nf_conntrack_core.c            |    7 ++
 net/netfilter/nf_conntrack_timeout.c         |   60 ++++++++++++++++++++
 net/netfilter/nfnetlink_cttimeout.c          |   10 ---
 7 files changed, 160 insertions(+), 10 deletions(-)
 create mode 100644 include/net/netfilter/nf_conntrack_timeout.h
 create mode 100644 net/netfilter/nf_conntrack_timeout.c

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 2dcf317..96755c3 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -20,6 +20,9 @@ enum nf_ct_ext_id {
 #ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
 	NF_CT_EXT_TSTAMP,
 #endif
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+	NF_CT_EXT_TIMEOUT,
+#endif
 	NF_CT_EXT_NUM,
 };
 
@@ -29,6 +32,7 @@ enum nf_ct_ext_id {
 #define NF_CT_EXT_ECACHE_TYPE struct nf_conntrack_ecache
 #define NF_CT_EXT_ZONE_TYPE struct nf_conntrack_zone
 #define NF_CT_EXT_TSTAMP_TYPE struct nf_conn_tstamp
+#define NF_CT_EXT_TIMEOUT_TYPE struct nf_conn_timeout
 
 /* Extensions: optional stuff which isn't permanently in struct. */
 struct nf_ct_ext {
diff --git a/include/net/netfilter/nf_conntrack_timeout.h b/include/net/netfilter/nf_conntrack_timeout.h
new file mode 100644
index 0000000..0e04db4
--- /dev/null
+++ b/include/net/netfilter/nf_conntrack_timeout.h
@@ -0,0 +1,78 @@
+#ifndef _NF_CONNTRACK_TIMEOUT_H
+#define _NF_CONNTRACK_TIMEOUT_H
+
+#include <net/net_namespace.h>
+#include <linux/netfilter/nf_conntrack_common.h>
+#include <linux/netfilter/nf_conntrack_tuple_common.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_extend.h>
+
+#define CTNL_TIMEOUT_NAME_MAX	32
+
+struct ctnl_timeout {
+	struct list_head	head;
+	struct rcu_head		rcu_head;
+	atomic_t		refcnt;
+	char			name[CTNL_TIMEOUT_NAME_MAX];
+	__u16			l3num;
+	__u8			l4num;
+	char			data[0];
+};
+
+struct nf_conn_timeout {
+	struct ctnl_timeout	*timeout;
+};
+
+#define NF_CT_TIMEOUT_EXT_DATA(__t) (unsigned int *) &((__t)->timeout->data)
+
+static inline
+struct nf_conn_timeout *nf_ct_timeout_find(const struct nf_conn *ct)
+{
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+	return nf_ct_ext_find(ct, NF_CT_EXT_TIMEOUT);
+#else
+	return NULL;
+#endif
+}
+
+static inline
+struct nf_conn_timeout *nf_ct_timeout_ext_add(struct nf_conn *ct,
+					      struct ctnl_timeout *timeout,
+					      gfp_t gfp)
+{
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+	struct nf_conn_timeout *timeout_ext;
+
+	timeout_ext = nf_ct_ext_add(ct, NF_CT_EXT_TIMEOUT, gfp);
+	if (timeout_ext == NULL)
+		return NULL;
+
+	timeout_ext->timeout = timeout;
+
+	return timeout_ext;
+#else
+	return NULL;
+#endif
+};
+
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+extern int nf_conntrack_timeout_init(struct net *net);
+extern void nf_conntrack_timeout_fini(struct net *net);
+#else
+static inline int nf_conntrack_timeout_init(struct net *net)
+{
+        return 0;
+}
+
+static inline void nf_conntrack_timeout_fini(struct net *net)
+{
+        return;
+}
+#endif /* CONFIG_NF_CONNTRACK_TIMEOUT */
+
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+extern struct ctnl_timeout *(*nf_ct_timeout_find_get_hook)(const char *name);
+extern void (*nf_ct_timeout_put_hook)(struct ctnl_timeout *timeout);
+#endif
+
+#endif /* _NF_CONNTRACK_TIMEOUT_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index f3efb65..0c6f67e 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -103,6 +103,16 @@ config NF_CONNTRACK_EVENTS
 
 	  If unsure, say `N'.
 
+config NF_CONNTRACK_TIMEOUT
+	bool  'Connection tracking timeout'
+	depends on NETFILTER_ADVANCED
+	help
+	  This option enables support for connection tracking timeout
+	  extension. This allows you to attach timeout policies to flow
+	  via the CT target.
+
+	  If unsure, say `N'.
+
 config NF_CONNTRACK_TIMESTAMP
 	bool  'Connection tracking timestamping'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index cf7cdd6..ca36765 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -1,6 +1,7 @@
 netfilter-objs := core.o nf_log.o nf_queue.o nf_sockopt.o
 
 nf_conntrack-y	:= nf_conntrack_core.o nf_conntrack_standalone.o nf_conntrack_expect.o nf_conntrack_helper.o nf_conntrack_proto.o nf_conntrack_l3proto_generic.o nf_conntrack_proto_generic.o nf_conntrack_proto_tcp.o nf_conntrack_proto_udp.o nf_conntrack_extend.o nf_conntrack_acct.o
+nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMEOUT) += nf_conntrack_timeout.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMESTAMP) += nf_conntrack_timestamp.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_EVENTS) += nf_conntrack_ecache.o
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 7bf9532..183453d 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -44,6 +44,7 @@
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/nf_conntrack_timestamp.h>
+#include <net/netfilter/nf_conntrack_timeout.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_core.h>
 
@@ -1303,6 +1304,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 	}
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
+	nf_conntrack_timeout_fini(net);
 	nf_conntrack_ecache_fini(net);
 	nf_conntrack_tstamp_fini(net);
 	nf_conntrack_acct_fini(net);
@@ -1534,9 +1536,14 @@ static int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_ecache_init(net);
 	if (ret < 0)
 		goto err_ecache;
+	ret = nf_conntrack_timeout_init(net);
+	if (ret < 0)
+		goto err_timeout;
 
 	return 0;
 
+err_timeout:
+	nf_conntrack_timeout_fini(net);
 err_ecache:
 	nf_conntrack_tstamp_fini(net);
 err_tstamp:
diff --git a/net/netfilter/nf_conntrack_timeout.c b/net/netfilter/nf_conntrack_timeout.c
new file mode 100644
index 0000000..a878ce5
--- /dev/null
+++ b/net/netfilter/nf_conntrack_timeout.c
@@ -0,0 +1,60 @@
+/*
+ * (C) 2012 by Pablo Neira Ayuso <pablo@netfilter.org>
+ * (C) 2012 by Vyatta Inc. <http://www.vyatta.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation (or any later at your option).
+ */
+
+#include <linux/types.h>
+#include <linux/netfilter.h>
+#include <linux/skbuff.h>
+#include <linux/vmalloc.h>
+#include <linux/stddef.h>
+#include <linux/err.h>
+#include <linux/percpu.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/slab.h>
+#include <linux/export.h>
+
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_extend.h>
+#include <net/netfilter/nf_conntrack_timeout.h>
+
+struct ctnl_timeout *
+(*nf_ct_timeout_find_get_hook)(const char *name) __read_mostly;
+EXPORT_SYMBOL_GPL(nf_ct_timeout_find_get_hook);
+
+void (*nf_ct_timeout_put_hook)(struct ctnl_timeout *timeout) __read_mostly;
+EXPORT_SYMBOL_GPL(nf_ct_timeout_put_hook);
+
+static struct nf_ct_ext_type timeout_extend __read_mostly = {
+	.len	= sizeof(struct nf_conn_timeout),
+	.align	= __alignof__(struct nf_conn_timeout),
+	.id	= NF_CT_EXT_TIMEOUT,
+};
+
+int nf_conntrack_timeout_init(struct net *net)
+{
+	int ret = 0;
+
+	if (net_eq(net, &init_net)) {
+		ret = nf_ct_extend_register(&timeout_extend);
+		if (ret < 0) {
+			printk(KERN_ERR "nf_ct_timeout: Unable to register "
+					"timeout extension.\n");
+			return ret;
+		}
+	}
+
+	return 0;
+}
+
+void nf_conntrack_timeout_fini(struct net *net)
+{
+	if (net_eq(net, &init_net))
+		nf_ct_extend_unregister(&timeout_extend);
+}
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 23de417d3f..a5599be 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -37,16 +37,6 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
 MODULE_DESCRIPTION("cttimeout: Extended Netfilter Connection Tracking timeout tuning");
 
-struct ctnl_timeout {
-	struct list_head	head;
-	struct rcu_head		rcu_head;
-	atomic_t		refcnt;
-	char			name[CTNL_TIMEOUT_NAME_MAX];
-	__u16			l3num;
-	__u8			l4num;
-	char			data[0];
-};
-
 static LIST_HEAD(cttimeout_list);
 
 static const struct nla_policy cttimeout_nla_policy[CTA_TIMEOUT_MAX+1] = {
-- 
1.7.7.3
