From: pablo@netfilter.org
Subject: [PATCH 4/4] netfilter: nfnetlink_queue: fix compilation with NF_CONNTRACK disabled
Date: Tue, 19 Jun 2012 05:16:29 +0200
Message-ID: <1340075789-6196-5-git-send-email-pablo@netfilter.org>
References: <1340075789-6196-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340075789-6196-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

In "9cb0176 netfilter: add glue code to integrate nfnetlink_queue and ctnetlink"
the compilation with NF_CONNTRACK disabled is broken. This patch fixes this
issue.

I have moved the conntrack part into nfnetlink_queue_ct.c to avoid
peppering the entire nfnetlink_queue.c code with ifdefs.

I also needed to rename nfnetlink_queue.c to nfnetlink_queue_pkt.c
to update the net/netfilter/Makefile to support conditional compilation
of the conntrack integration.

This patch also adds CONFIG_NETFILTER_QUEUE_CT in case you want to explicitly
disable the integration between nf_conntrack and nfnetlink_queue.

Reported-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nfnetlink_queue.h            |   43 +++++++++
 net/netfilter/Kconfig                              |    9 ++
 net/netfilter/Makefile                             |    2 +
 net/netfilter/nf_conntrack_netlink.c               |   11 +--
 .../{nfnetlink_queue.c => nfnetlink_queue_core.c}  |   49 ++--------
 net/netfilter/nfnetlink_queue_ct.c                 |   97 ++++++++++++++++++++
 6 files changed, 164 insertions(+), 47 deletions(-)
 create mode 100644 include/net/netfilter/nfnetlink_queue.h
 rename net/netfilter/{nfnetlink_queue.c => nfnetlink_queue_core.c} (95%)
 create mode 100644 net/netfilter/nfnetlink_queue_ct.c

diff --git a/include/net/netfilter/nfnetlink_queue.h b/include/net/netfilter/nfnetlink_queue.h
new file mode 100644
index 0000000..9f8095c
--- /dev/null
+++ b/include/net/netfilter/nfnetlink_queue.h
@@ -0,0 +1,43 @@
+#ifndef _NET_NFNL_QUEUE_H_
+#define _NET_NFNL_QUEUE_H_
+
+#include <linux/netfilter/nf_conntrack_common.h>
+
+struct nf_conn;
+
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+struct nf_conn *nfqnl_ct_get(struct sk_buff *entskb, size_t *size,
+			     enum ip_conntrack_info *ctinfo);
+struct nf_conn *nfqnl_ct_parse(const struct sk_buff *skb,
+			       const struct nlattr *attr,
+			       enum ip_conntrack_info *ctinfo);
+int nfqnl_ct_put(struct sk_buff *skb, struct nf_conn *ct,
+		 enum ip_conntrack_info ctinfo);
+void nfqnl_ct_seq_adjust(struct sk_buff *skb, struct nf_conn *ct,
+			 enum ip_conntrack_info ctinfo, int diff);
+#else
+inline struct nf_conn *
+nfqnl_ct_get(struct sk_buff *entskb, size_t *size, enum ip_conntrack_info *ctinfo)
+{
+	return NULL;
+}
+
+inline struct nf_conn *nfqnl_ct_parse(const struct sk_buff *skb,
+				      const struct nlattr *attr,
+				      enum ip_conntrack_info *ctinfo)
+{
+	return NULL;
+}
+
+inline int
+nfqnl_ct_put(struct sk_buff *skb, struct nf_conn *ct, enum ip_conntrack_info ctinfo)
+{
+	return 0;
+}
+
+inline void nfqnl_ct_seq_adjust(struct sk_buff *skb, struct nf_conn *ct,
+				enum ip_conntrack_info ctinfo, int diff)
+{
+}
+#endif /* NF_CONNTRACK */
+#endif
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index f1a52ba..c19b214 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -340,6 +340,7 @@ config NF_CT_NETLINK_HELPER
 	select NETFILTER_NETLINK
 	depends on NF_CT_NETLINK
 	depends on NETFILTER_NETLINK_QUEUE
+	depends on NETFILTER_NETLINK_QUEUE_CT
 	depends on NETFILTER_ADVANCED
 	help
 	  This option enables the user-space connection tracking helpers
@@ -347,6 +348,14 @@ config NF_CT_NETLINK_HELPER
 
 	  If unsure, say `N'.
 
+config NETFILTER_NETLINK_QUEUE_CT
+        bool "NFQUEUE integration with Connection Tracking"
+        default n
+        depends on NETFILTER_NETLINK_QUEUE
+	help
+	  If this option is enabled, NFQUEUE can include Connection Tracking
+	  information together with the packet is the enqueued via NFNETLINK.
+
 endif # NF_CONNTRACK
 
 # transparent proxy support
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 7cc2019..1c5160f 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -9,6 +9,8 @@ obj-$(CONFIG_NETFILTER) = netfilter.o
 
 obj-$(CONFIG_NETFILTER_NETLINK) += nfnetlink.o
 obj-$(CONFIG_NETFILTER_NETLINK_ACCT) += nfnetlink_acct.o
+nfnetlink_queue-y := nfnetlink_queue_core.o
+nfnetlink_queue-$(CONFIG_NETFILTER_NETLINK_QUEUE_CT) += nfnetlink_queue_ct.o
 obj-$(CONFIG_NETFILTER_NETLINK_QUEUE) += nfnetlink_queue.o
 obj-$(CONFIG_NETFILTER_NETLINK_LOG) += nfnetlink_log.o
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 76271a1..31d1d8f 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1627,8 +1627,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	return err;
 }
 
-#if defined(CONFIG_NETFILTER_NETLINK_QUEUE) ||	\
-    defined(CONFIG_NETFILTER_NETLINK_QUEUE_MODULE)
+#ifdef CONFIG_NETFILTER_NETLINK_QUEUE_CT
 static size_t
 ctnetlink_nfqueue_build_size(const struct nf_conn *ct)
 {
@@ -1762,7 +1761,7 @@ static struct nfq_ct_hook ctnetlink_nfqueue_hook = {
 	.seq_adjust	= nf_nat_tcp_seq_adjust,
 #endif
 };
-#endif /* CONFIG_NETFILTER_NETLINK_QUEUE */
+#endif /* CONFIG_NETFILTER_NETLINK_QUEUE_CT */
 
 /***********************************************************************
  * EXPECT
@@ -2568,8 +2567,7 @@ static int __init ctnetlink_init(void)
 		pr_err("ctnetlink_init: cannot register pernet operations\n");
 		goto err_unreg_exp_subsys;
 	}
-#if defined(CONFIG_NETFILTER_NETLINK_QUEUE) ||	\
-    defined(CONFIG_NETFILTER_NETLINK_QUEUE_MODULE)
+#ifdef CONFIG_NETFILTER_NETLINK_QUEUE_CT
 	/* setup interaction between nf_queue and nf_conntrack_netlink. */
 	RCU_INIT_POINTER(nfq_ct_hook, &ctnetlink_nfqueue_hook);
 #endif
@@ -2590,8 +2588,7 @@ static void __exit ctnetlink_exit(void)
 	unregister_pernet_subsys(&ctnetlink_net_ops);
 	nfnetlink_subsys_unregister(&ctnl_exp_subsys);
 	nfnetlink_subsys_unregister(&ctnl_subsys);
-#if defined(CONFIG_NETFILTER_NETLINK_QUEUE) ||	\
-    defined(CONFIG_NETFILTER_NETLINK_QUEUE_MODULE)
+#ifdef CONFIG_NETFILTER_NETLINK_QUEUE_CT
 	RCU_INIT_POINTER(nfq_ct_hook, NULL);
 #endif
 }
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue_core.c
similarity index 95%
rename from net/netfilter/nfnetlink_queue.c
rename to net/netfilter/nfnetlink_queue_core.c
index ff82c79..d36b95e 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -30,7 +30,7 @@
 #include <linux/list.h>
 #include <net/sock.h>
 #include <net/netfilter/nf_queue.h>
-#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nfnetlink_queue.h>
 
 #include <linux/atomic.h>
 
@@ -234,7 +234,6 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	struct sk_buff *entskb = entry->skb;
 	struct net_device *indev;
 	struct net_device *outdev;
-	struct nfq_ct_hook *nfq_ct;
 	struct nf_conn *ct = NULL;
 	enum ip_conntrack_info uninitialized_var(ctinfo);
 
@@ -270,17 +269,8 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		break;
 	}
 
-	/* rcu_read_lock()ed by __nf_queue already. */
-	nfq_ct = rcu_dereference(nfq_ct_hook);
-	if (nfq_ct != NULL && (queue->flags & NFQA_CFG_F_CONNTRACK)) {
-		ct = nf_ct_get(entskb, &ctinfo);
-		if (ct) {
-			if (!nf_ct_is_untracked(ct))
-				size += nfq_ct->build_size(ct);
-			else
-				ct = NULL;
-		}
-	}
+	if (queue->flags & NFQA_CFG_F_CONNTRACK)
+		ct = nfqnl_ct_get(entskb, &size, &ctinfo);
 
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb)
@@ -404,23 +394,8 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 			BUG();
 	}
 
-	if (ct) {
-		struct nlattr *nest_parms;
-		u_int32_t tmp;
-
-		nest_parms = nla_nest_start(skb, NFQA_CT | NLA_F_NESTED);
-		if (!nest_parms)
-			goto nla_put_failure;
-
-		if (nfq_ct->build(skb, ct) < 0)
-			goto nla_put_failure;
-
-		nla_nest_end(skb, nest_parms);
-
-		tmp = ctinfo;
-		if (nla_put_u32(skb, NFQA_CT_INFO, htonl(ctinfo)))
-			goto nla_put_failure;
-	}
+	if (ct && nfqnl_ct_put(skb, ct, ctinfo) < 0)
+		goto nla_put_failure;
 
 	nlh->nlmsg_len = skb->tail - old_tail;
 	return skb;
@@ -764,7 +739,6 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	struct nfqnl_instance *queue;
 	unsigned int verdict;
 	struct nf_queue_entry *entry;
-	struct nfq_ct_hook *nfq_ct;
 	enum ip_conntrack_info uninitialized_var(ctinfo);
 	struct nf_conn *ct = NULL;
 
@@ -786,13 +760,8 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 		return -ENOENT;
 
 	rcu_read_lock();
-	nfq_ct = rcu_dereference(nfq_ct_hook);
-	if (nfq_ct != NULL &&
-	    (queue->flags & NFQA_CFG_F_CONNTRACK) && nfqa[NFQA_CT]) {
-		ct = nf_ct_get(entry->skb, &ctinfo);
-		if (ct && !nf_ct_is_untracked(ct))
-			nfq_ct->parse(nfqa[NFQA_CT], ct);
-	}
+	if (nfqa[NFQA_CT] && (queue->flags & NFQA_CFG_F_CONNTRACK))
+		ct = nfqnl_ct_parse(entry->skb, nfqa[NFQA_CT], &ctinfo);
 
 	if (nfqa[NFQA_PAYLOAD]) {
 		u16 payload_len = nla_len(nfqa[NFQA_PAYLOAD]);
@@ -802,8 +771,8 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 				 payload_len, entry, diff) < 0)
 			verdict = NF_DROP;
 
-		if (ct && (ct->status & IPS_NAT_MASK) && diff)
-			nfq_ct->seq_adjust(skb, ct, ctinfo, diff);
+		if (ct)
+			nfqnl_ct_seq_adjust(skb, ct, ctinfo, diff);
 	}
 	rcu_read_unlock();
 
diff --git a/net/netfilter/nfnetlink_queue_ct.c b/net/netfilter/nfnetlink_queue_ct.c
new file mode 100644
index 0000000..68ef550
--- /dev/null
+++ b/net/netfilter/nfnetlink_queue_ct.c
@@ -0,0 +1,97 @@
+/*
+ * (C) 2012 by Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/skbuff.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_queue.h>
+#include <net/netfilter/nf_conntrack.h>
+
+struct nf_conn *nfqnl_ct_get(struct sk_buff *entskb, size_t *size,
+			     enum ip_conntrack_info *ctinfo)
+{
+	struct nfq_ct_hook *nfq_ct;
+	struct nf_conn *ct;
+
+	/* rcu_read_lock()ed by __nf_queue already. */
+	nfq_ct = rcu_dereference(nfq_ct_hook);
+	if (nfq_ct == NULL)
+		return NULL;
+
+	ct = nf_ct_get(entskb, ctinfo);
+	if (ct) {
+		if (!nf_ct_is_untracked(ct))
+			*size += nfq_ct->build_size(ct);
+		else
+			ct = NULL;
+	}
+	return ct;
+}
+
+struct nf_conn *
+nfqnl_ct_parse(const struct sk_buff *skb, const struct nlattr *attr,
+	       enum ip_conntrack_info *ctinfo)
+{
+	struct nfq_ct_hook *nfq_ct;
+	struct nf_conn *ct;
+
+	/* rcu_read_lock()ed by __nf_queue already. */
+	nfq_ct = rcu_dereference(nfq_ct_hook);
+	if (nfq_ct == NULL)
+		return NULL;
+
+	ct = nf_ct_get(skb, ctinfo);
+	if (ct && !nf_ct_is_untracked(ct))
+		nfq_ct->parse(attr, ct);
+
+	return ct;
+}
+
+int nfqnl_ct_put(struct sk_buff *skb, struct nf_conn *ct,
+		 enum ip_conntrack_info ctinfo)
+{
+	struct nfq_ct_hook *nfq_ct;
+	struct nlattr *nest_parms;
+	u_int32_t tmp;
+
+	nfq_ct = rcu_dereference(nfq_ct_hook);
+	if (nfq_ct == NULL)
+		return 0;
+
+	nest_parms = nla_nest_start(skb, NFQA_CT | NLA_F_NESTED);
+	if (!nest_parms)
+		goto nla_put_failure;
+
+	if (nfq_ct->build(skb, ct) < 0)
+		goto nla_put_failure;
+
+	nla_nest_end(skb, nest_parms);
+
+	tmp = ctinfo;
+	if (nla_put_be32(skb, NFQA_CT_INFO, htonl(tmp)))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+void nfqnl_ct_seq_adjust(struct sk_buff *skb, struct nf_conn *ct,
+			 enum ip_conntrack_info ctinfo, int diff)
+{
+	struct nfq_ct_hook *nfq_ct;
+
+	nfq_ct = rcu_dereference(nfq_ct_hook);
+	if (nfq_ct == NULL)
+		return;
+
+	if ((ct->status & IPS_NAT_MASK) && diff)
+		nfq_ct->seq_adjust(skb, ct, ctinfo, diff);
+}
-- 
1.7.10

