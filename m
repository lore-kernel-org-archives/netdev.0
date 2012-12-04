From: pablo@netfilter.org
Subject: [PATCH 4/6] netfilter: kill support for per-af queue backends
Date: Tue,  4 Dec 2012 18:31:31 +0100
Message-ID: <1354642293-4114-5-git-send-email-pablo@netfilter.org>
References: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54457 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754320Ab2LDRb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 12:31:58 -0500
In-Reply-To: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

We used to have several queueing backends, but nowadays only
nfnetlink_queue remains.

In light of this there doesn't seem to be a good reason to
support per-af registering -- just hook up nfnetlink_queue on module
load and remove it on unload.

This means that the userspace BIND/UNBIND_PF commands are now obsolete;
the kernel will ignore them.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_queue.h     |    8 +-
 net/netfilter/core.c                 |    2 -
 net/netfilter/nf_queue.c             |  152 +++-------------------------------
 net/netfilter/nfnetlink_queue_core.c |   14 ++--
 4 files changed, 20 insertions(+), 156 deletions(-)

diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index 252fd10..fb1c0be 100644
--- a/include/net/netfilter/nf_queue.h
+++ b/include/net/netfilter/nf_queue.h
@@ -21,14 +21,10 @@ struct nf_queue_entry {
 struct nf_queue_handler {
 	int			(*outfn)(struct nf_queue_entry *entry,
 					 unsigned int queuenum);
-	char			*name;
 };
 
-extern int nf_register_queue_handler(u_int8_t pf,
-				     const struct nf_queue_handler *qh);
-extern int nf_unregister_queue_handler(u_int8_t pf,
-				       const struct nf_queue_handler *qh);
-extern void nf_unregister_queue_handlers(const struct nf_queue_handler *qh);
+void nf_register_queue_handler(const struct nf_queue_handler *qh);
+void nf_unregister_queue_handler(void);
 extern void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict);
 
 #endif /* _NF_QUEUE_H */
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 68912dad..a9c488b 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -295,8 +295,6 @@ void __init netfilter_init(void)
 		panic("cannot create netfilter proc entry");
 #endif
 
-	if (netfilter_queue_init() < 0)
-		panic("cannot initialize nf_queue");
 	if (netfilter_log_init() < 0)
 		panic("cannot initialize nf_log");
 }
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 8d2cf9e..d812c12 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -14,84 +14,32 @@
 #include "nf_internals.h"
 
 /*
- * A queue handler may be registered for each protocol.  Each is protected by
- * long term mutex.  The handler must provide an an outfn() to accept packets
- * for queueing and must reinject all packets it receives, no matter what.
+ * Hook for nfnetlink_queue to register its queue handler.
+ * We do this so that most of the NFQUEUE code can be modular.
+ *
+ * Once the queue is registered it must reinject all packets it
+ * receives, no matter what.
  */
-static const struct nf_queue_handler __rcu *queue_handler[NFPROTO_NUMPROTO] __read_mostly;
-
-static DEFINE_MUTEX(queue_handler_mutex);
+static const struct nf_queue_handler __rcu *queue_handler __read_mostly;
 
 /* return EBUSY when somebody else is registered, return EEXIST if the
  * same handler is registered, return 0 in case of success. */
-int nf_register_queue_handler(u_int8_t pf, const struct nf_queue_handler *qh)
+void nf_register_queue_handler(const struct nf_queue_handler *qh)
 {
-	int ret;
-	const struct nf_queue_handler *old;
-
-	if (pf >= ARRAY_SIZE(queue_handler))
-		return -EINVAL;
-
-	mutex_lock(&queue_handler_mutex);
-	old = rcu_dereference_protected(queue_handler[pf],
-					lockdep_is_held(&queue_handler_mutex));
-	if (old == qh)
-		ret = -EEXIST;
-	else if (old)
-		ret = -EBUSY;
-	else {
-		rcu_assign_pointer(queue_handler[pf], qh);
-		ret = 0;
-	}
-	mutex_unlock(&queue_handler_mutex);
-
-	return ret;
+	/* should never happen, we only have one queueing backend in kernel */
+	WARN_ON(rcu_access_pointer(queue_handler));
+	rcu_assign_pointer(queue_handler, qh);
 }
 EXPORT_SYMBOL(nf_register_queue_handler);
 
 /* The caller must flush their queue before this */
-int nf_unregister_queue_handler(u_int8_t pf, const struct nf_queue_handler *qh)
+void nf_unregister_queue_handler(void)
 {
-	const struct nf_queue_handler *old;
-
-	if (pf >= ARRAY_SIZE(queue_handler))
-		return -EINVAL;
-
-	mutex_lock(&queue_handler_mutex);
-	old = rcu_dereference_protected(queue_handler[pf],
-					lockdep_is_held(&queue_handler_mutex));
-	if (old && old != qh) {
-		mutex_unlock(&queue_handler_mutex);
-		return -EINVAL;
-	}
-
-	RCU_INIT_POINTER(queue_handler[pf], NULL);
-	mutex_unlock(&queue_handler_mutex);
-
+	RCU_INIT_POINTER(queue_handler, NULL);
 	synchronize_rcu();
-
-	return 0;
 }
 EXPORT_SYMBOL(nf_unregister_queue_handler);
 
-void nf_unregister_queue_handlers(const struct nf_queue_handler *qh)
-{
-	u_int8_t pf;
-
-	mutex_lock(&queue_handler_mutex);
-	for (pf = 0; pf < ARRAY_SIZE(queue_handler); pf++)  {
-		if (rcu_dereference_protected(
-				queue_handler[pf],
-				lockdep_is_held(&queue_handler_mutex)
-				) == qh)
-			RCU_INIT_POINTER(queue_handler[pf], NULL);
-	}
-	mutex_unlock(&queue_handler_mutex);
-
-	synchronize_rcu();
-}
-EXPORT_SYMBOL_GPL(nf_unregister_queue_handlers);
-
 static void nf_queue_entry_release_refs(struct nf_queue_entry *entry)
 {
 	/* Release those devices we held, or Alexey will kill me. */
@@ -137,7 +85,7 @@ static int __nf_queue(struct sk_buff *skb,
 	/* QUEUE == DROP if no one is waiting, to be safe. */
 	rcu_read_lock();
 
-	qh = rcu_dereference(queue_handler[pf]);
+	qh = rcu_dereference(queue_handler);
 	if (!qh) {
 		status = -ESRCH;
 		goto err_unlock;
@@ -344,77 +292,3 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	kfree(entry);
 }
 EXPORT_SYMBOL(nf_reinject);
-
-#ifdef CONFIG_PROC_FS
-static void *seq_start(struct seq_file *seq, loff_t *pos)
-{
-	if (*pos >= ARRAY_SIZE(queue_handler))
-		return NULL;
-
-	return pos;
-}
-
-static void *seq_next(struct seq_file *s, void *v, loff_t *pos)
-{
-	(*pos)++;
-
-	if (*pos >= ARRAY_SIZE(queue_handler))
-		return NULL;
-
-	return pos;
-}
-
-static void seq_stop(struct seq_file *s, void *v)
-{
-
-}
-
-static int seq_show(struct seq_file *s, void *v)
-{
-	int ret;
-	loff_t *pos = v;
-	const struct nf_queue_handler *qh;
-
-	rcu_read_lock();
-	qh = rcu_dereference(queue_handler[*pos]);
-	if (!qh)
-		ret = seq_printf(s, "%2lld NONE\n", *pos);
-	else
-		ret = seq_printf(s, "%2lld %s\n", *pos, qh->name);
-	rcu_read_unlock();
-
-	return ret;
-}
-
-static const struct seq_operations nfqueue_seq_ops = {
-	.start	= seq_start,
-	.next	= seq_next,
-	.stop	= seq_stop,
-	.show	= seq_show,
-};
-
-static int nfqueue_open(struct inode *inode, struct file *file)
-{
-	return seq_open(file, &nfqueue_seq_ops);
-}
-
-static const struct file_operations nfqueue_file_ops = {
-	.owner	 = THIS_MODULE,
-	.open	 = nfqueue_open,
-	.read	 = seq_read,
-	.llseek	 = seq_lseek,
-	.release = seq_release,
-};
-#endif /* PROC_FS */
-
-
-int __init netfilter_queue_init(void)
-{
-#ifdef CONFIG_PROC_FS
-	if (!proc_create("nf_queue", S_IRUGO,
-			 proc_net_netfilter, &nfqueue_file_ops))
-		return -1;
-#endif
-	return 0;
-}
-
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index e12d44e..3158d87 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -809,7 +809,6 @@ static const struct nla_policy nfqa_cfg_policy[NFQA_CFG_MAX+1] = {
 };
 
 static const struct nf_queue_handler nfqh = {
-	.name 	= "nf_queue",
 	.outfn	= &nfqnl_enqueue_packet,
 };
 
@@ -827,14 +826,10 @@ nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 	if (nfqa[NFQA_CFG_CMD]) {
 		cmd = nla_data(nfqa[NFQA_CFG_CMD]);
 
-		/* Commands without queue context - might sleep */
+		/* Obsolete commands without queue context */
 		switch (cmd->command) {
-		case NFQNL_CFG_CMD_PF_BIND:
-			return nf_register_queue_handler(ntohs(cmd->pf),
-							 &nfqh);
-		case NFQNL_CFG_CMD_PF_UNBIND:
-			return nf_unregister_queue_handler(ntohs(cmd->pf),
-							   &nfqh);
+		case NFQNL_CFG_CMD_PF_BIND: return 0;
+		case NFQNL_CFG_CMD_PF_UNBIND: return 0;
 		}
 	}
 
@@ -1074,6 +1069,7 @@ static int __init nfnetlink_queue_init(void)
 #endif
 
 	register_netdevice_notifier(&nfqnl_dev_notifier);
+	nf_register_queue_handler(&nfqh);
 	return status;
 
 #ifdef CONFIG_PROC_FS
@@ -1087,7 +1083,7 @@ cleanup_netlink_notifier:
 
 static void __exit nfnetlink_queue_fini(void)
 {
-	nf_unregister_queue_handlers(&nfqh);
+	nf_unregister_queue_handler();
 	unregister_netdevice_notifier(&nfqnl_dev_notifier);
 #ifdef CONFIG_PROC_FS
 	remove_proc_entry("nfnetlink_queue", proc_net_netfilter);
-- 
1.7.10.4
