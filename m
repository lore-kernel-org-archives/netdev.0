From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 22/41: use a linked list of loggers
Date: Tue, 24 Mar 2009 15:03:36 +0100 (MET)
Message-ID: <20090324140332.31401.93363.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34797 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758384AbZCXODj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:39 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ca735b3aaa945626ba65a3e51145bfe4ecd9e222
Author: Eric Leblond <eric@inl.fr>
Date:   Mon Mar 16 14:54:21 2009 +0100

    netfilter: use a linked list of loggers
    
    This patch modifies nf_log to use a linked list of loggers for each
    protocol. This list of loggers is read and write protected with a
    mutex.
    
    This patch separates registration and binding. To be used as
    logging module, a module has to register calling nf_log_register()
    and to bind to a protocol it has to call nf_log_bind_pf().
    This patch also converts the logging modules to the new API. For nfnetlink_log,
    it simply switchs call to register functions to call to bind function and
    adds a call to nf_log_register() during init. For other modules, it just
    remove a const flag from the logger structure and replace it with a
    __read_mostly.
    
    Signed-off-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_log.h
index 7182c06..920997f 100644
--- a/include/net/netfilter/nf_log.h
+++ b/include/net/netfilter/nf_log.h
@@ -1,6 +1,8 @@
 #ifndef _NF_LOG_H
 #define _NF_LOG_H
 
+#include <linux/netfilter.h>
+
 /* those NF_LOG_* defines and struct nf_loginfo are legacy definitios that will
  * disappear once iptables is replaced with pkttables.  Please DO NOT use them
  * for any new code! */
@@ -40,12 +42,15 @@ struct nf_logger {
 	struct module	*me;
 	nf_logfn 	*logfn;
 	char		*name;
+	struct list_head	list[NFPROTO_NUMPROTO];
 };
 
 /* Function to register/unregister log function. */
-int nf_log_register(u_int8_t pf, const struct nf_logger *logger);
-void nf_log_unregister(const struct nf_logger *logger);
-void nf_log_unregister_pf(u_int8_t pf);
+int nf_log_register(u_int8_t pf, struct nf_logger *logger);
+void nf_log_unregister(struct nf_logger *logger);
+
+int nf_log_bind_pf(u_int8_t pf, const struct nf_logger *logger);
+void nf_log_unbind_pf(u_int8_t pf);
 
 /* Calls the registered backend logging function */
 void nf_log_packet(u_int8_t pf,
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 27a78fb..acc44c6 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -464,7 +464,7 @@ static struct xt_target log_tg_reg __read_mostly = {
 	.me		= THIS_MODULE,
 };
 
-static const struct nf_logger ipt_log_logger ={
+static struct nf_logger ipt_log_logger __read_mostly = {
 	.name		= "ipt_LOG",
 	.logfn		= &ipt_log_packet,
 	.me		= THIS_MODULE,
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 18a2826..d32cc4b 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -379,7 +379,7 @@ static struct xt_target ulog_tg_reg __read_mostly = {
 	.me		= THIS_MODULE,
 };
 
-static struct nf_logger ipt_ulog_logger = {
+static struct nf_logger ipt_ulog_logger __read_mostly = {
 	.name		= "ipt_ULOG",
 	.logfn		= ipt_logfn,
 	.me		= THIS_MODULE,
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 37adf5a..7018cac 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -477,7 +477,7 @@ static struct xt_target log_tg6_reg __read_mostly = {
 	.me 		= THIS_MODULE,
 };
 
-static const struct nf_logger ip6t_logger = {
+static struct nf_logger ip6t_logger __read_mostly = {
 	.name		= "ip6t_LOG",
 	.logfn		= &ip6t_log_packet,
 	.me		= THIS_MODULE,
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index fa8ae5d..a228b5f 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -16,56 +16,60 @@
 #define NF_LOG_PREFIXLEN		128
 
 static const struct nf_logger *nf_loggers[NFPROTO_NUMPROTO] __read_mostly;
+static struct list_head nf_loggers_l[NFPROTO_NUMPROTO] __read_mostly;
 static DEFINE_MUTEX(nf_log_mutex);
 
-/* return EBUSY if somebody else is registered, EEXIST if the same logger
- * is registred, 0 on success. */
-int nf_log_register(u_int8_t pf, const struct nf_logger *logger)
+static struct nf_logger *__find_logger(int pf, const char *str_logger)
 {
-	int ret;
+	struct nf_logger *t;
 
-	if (pf >= ARRAY_SIZE(nf_loggers))
-		return -EINVAL;
-
-	/* Any setup of logging members must be done before
-	 * substituting pointer. */
-	ret = mutex_lock_interruptible(&nf_log_mutex);
-	if (ret < 0)
-		return ret;
-
-	if (!nf_loggers[pf])
-		rcu_assign_pointer(nf_loggers[pf], logger);
-	else if (nf_loggers[pf] == logger)
-		ret = -EEXIST;
-	else
-		ret = -EBUSY;
+	list_for_each_entry(t, &nf_loggers_l[pf], list[pf]) {
+		if (!strnicmp(str_logger, t->name, strlen(t->name)))
+			return t;
+	}
 
-	mutex_unlock(&nf_log_mutex);
-	return ret;
+	return NULL;
 }
-EXPORT_SYMBOL(nf_log_register);
 
-void nf_log_unregister_pf(u_int8_t pf)
+/* return EEXIST if the same logger is registred, 0 on success. */
+int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 {
+	const struct nf_logger *llog;
+
 	if (pf >= ARRAY_SIZE(nf_loggers))
-		return;
+		return -EINVAL;
+
 	mutex_lock(&nf_log_mutex);
-	rcu_assign_pointer(nf_loggers[pf], NULL);
+
+	if (pf == NFPROTO_UNSPEC) {
+		int i;
+		for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++)
+			list_add_tail(&(logger->list[i]), &(nf_loggers_l[i]));
+	} else {
+		/* register at end of list to honor first register win */
+		list_add_tail(&logger->list[pf], &nf_loggers_l[pf]);
+		llog = rcu_dereference(nf_loggers[pf]);
+		if (llog == NULL)
+			rcu_assign_pointer(nf_loggers[pf], logger);
+	}
+
 	mutex_unlock(&nf_log_mutex);
 
-	/* Give time to concurrent readers. */
-	synchronize_rcu();
+	return 0;
 }
-EXPORT_SYMBOL(nf_log_unregister_pf);
+EXPORT_SYMBOL(nf_log_register);
 
-void nf_log_unregister(const struct nf_logger *logger)
+void nf_log_unregister(struct nf_logger *logger)
 {
+	const struct nf_logger *c_logger;
 	int i;
 
 	mutex_lock(&nf_log_mutex);
 	for (i = 0; i < ARRAY_SIZE(nf_loggers); i++) {
-		if (nf_loggers[i] == logger)
+		c_logger = rcu_dereference(nf_loggers[i]);
+		if (c_logger == logger)
 			rcu_assign_pointer(nf_loggers[i], NULL);
+		list_del(&logger->list[i]);
 	}
 	mutex_unlock(&nf_log_mutex);
 
@@ -73,6 +77,27 @@ void nf_log_unregister(const struct nf_logger *logger)
 }
 EXPORT_SYMBOL(nf_log_unregister);
 
+int nf_log_bind_pf(u_int8_t pf, const struct nf_logger *logger)
+{
+	mutex_lock(&nf_log_mutex);
+	if (__find_logger(pf, logger->name) == NULL) {
+		mutex_unlock(&nf_log_mutex);
+		return -ENOENT;
+	}
+	rcu_assign_pointer(nf_loggers[pf], logger);
+	mutex_unlock(&nf_log_mutex);
+	return 0;
+}
+EXPORT_SYMBOL(nf_log_bind_pf);
+
+void nf_log_unbind_pf(u_int8_t pf)
+{
+	mutex_lock(&nf_log_mutex);
+	rcu_assign_pointer(nf_loggers[pf], NULL);
+	mutex_unlock(&nf_log_mutex);
+}
+EXPORT_SYMBOL(nf_log_unbind_pf);
+
 void nf_log_packet(u_int8_t pf,
 		   unsigned int hooknum,
 		   const struct sk_buff *skb,
@@ -163,10 +188,15 @@ static const struct file_operations nflog_file_ops = {
 
 int __init netfilter_log_init(void)
 {
+	int i;
 #ifdef CONFIG_PROC_FS
 	if (!proc_create("nf_log", S_IRUGO,
 			 proc_net_netfilter, &nflog_file_ops))
 		return -1;
 #endif
+
+	for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++)
+		INIT_LIST_HEAD(&(nf_loggers_l[i]));
+
 	return 0;
 }
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index fa49dc7..3eae3fc 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -691,7 +691,7 @@ nfulnl_recv_unsupp(struct sock *ctnl, struct sk_buff *skb,
 	return -ENOTSUPP;
 }
 
-static const struct nf_logger nfulnl_logger = {
+static struct nf_logger nfulnl_logger __read_mostly = {
 	.name	= "nfnetlink_log",
 	.logfn	= &nfulnl_log_packet,
 	.me	= THIS_MODULE,
@@ -723,9 +723,9 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 		/* Commands without queue context */
 		switch (cmd->command) {
 		case NFULNL_CFG_CMD_PF_BIND:
-			return nf_log_register(pf, &nfulnl_logger);
+			return nf_log_bind_pf(pf, &nfulnl_logger);
 		case NFULNL_CFG_CMD_PF_UNBIND:
-			nf_log_unregister_pf(pf);
+			nf_log_unbind_pf(pf);
 			return 0;
 		}
 	}
@@ -950,17 +950,25 @@ static int __init nfnetlink_log_init(void)
 		goto cleanup_netlink_notifier;
 	}
 
+	status = nf_log_register(NFPROTO_UNSPEC, &nfulnl_logger);
+	if (status < 0) {
+		printk(KERN_ERR "log: failed to register logger\n");
+		goto cleanup_subsys;
+	}
+
 #ifdef CONFIG_PROC_FS
 	if (!proc_create("nfnetlink_log", 0440,
 			 proc_net_netfilter, &nful_file_ops))
-		goto cleanup_subsys;
+		goto cleanup_logger;
 #endif
 	return status;
 
 #ifdef CONFIG_PROC_FS
+cleanup_logger:
+	nf_log_unregister(&nfulnl_logger);
+#endif
 cleanup_subsys:
 	nfnetlink_subsys_unregister(&nfulnl_subsys);
-#endif
 cleanup_netlink_notifier:
 	netlink_unregister_notifier(&nfulnl_rtnl_notifier);
 	return status;
