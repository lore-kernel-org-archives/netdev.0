From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 07/10] netfilter: nfnetlink_log: add net namespace support for nfnetlink_log
Date: Thu, 7 Feb 2013 15:49:47 +0800
Message-ID: <1360223390-15589-7-git-send-email-gaofeng@cn.fujitsu.com>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: containers@lists.linux-foundation.org, pablo@netfilter.org,
	ebiederm@xmission.com, netdev@vger.kernel.org, lve@guap.ru,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:1611 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752328Ab3BGHtf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 02:49:35 -0500
In-Reply-To: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes /proc/net/netfilter/nfnetlink_log pernet,
and netns has it's own instance table and lock.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nfnetlink_log.c | 178 +++++++++++++++++++++++++++---------------
 1 file changed, 117 insertions(+), 61 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 8f35467..7ccc88a 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -32,6 +32,7 @@
 #include <linux/slab.h>
 #include <net/sock.h>
 #include <net/netfilter/nf_log.h>
+#include <net/netns/generic.h>
 #include <net/netfilter/nfnetlink_log.h>
 
 #include <linux/atomic.h>
@@ -56,6 +57,7 @@ struct nfulnl_instance {
 	unsigned int qlen;		/* number of nlmsgs in skb */
 	struct sk_buff *skb;		/* pre-allocatd skb */
 	struct timer_list timer;
+	struct net *net;
 	struct user_namespace *peer_user_ns;	/* User namespace of the peer process */
 	int peer_portid;			/* PORTID of the peer process */
 
@@ -71,26 +73,36 @@ struct nfulnl_instance {
 	struct rcu_head rcu;
 };
 
-static DEFINE_SPINLOCK(instances_lock);
-static atomic_t global_seq;
+
 
 #define INSTANCE_BUCKETS	16
-static struct hlist_head instance_table[INSTANCE_BUCKETS];
 static unsigned int hash_init;
 
+static int nfnl_log_net_id __read_mostly;
+struct nfnl_log_net {
+	spinlock_t instances_lock;
+	struct hlist_head instance_table[INSTANCE_BUCKETS];
+	atomic_t global_seq;
+};
+
+static struct nfnl_log_net *nfnl_log_pernet(struct net *net)
+{
+	return net_generic(net, nfnl_log_net_id);
+}
+
 static inline u_int8_t instance_hashfn(u_int16_t group_num)
 {
 	return ((group_num & 0xff) % INSTANCE_BUCKETS);
 }
 
 static struct nfulnl_instance *
-__instance_lookup(u_int16_t group_num)
+__instance_lookup(struct nfnl_log_net *log, u_int16_t group_num)
 {
 	struct hlist_head *head;
 	struct hlist_node *pos;
 	struct nfulnl_instance *inst;
 
-	head = &instance_table[instance_hashfn(group_num)];
+	head = &log->instance_table[instance_hashfn(group_num)];
 	hlist_for_each_entry_rcu(inst, pos, head, hlist) {
 		if (inst->group_num == group_num)
 			return inst;
@@ -105,12 +117,12 @@ instance_get(struct nfulnl_instance *inst)
 }
 
 static struct nfulnl_instance *
-instance_lookup_get(u_int16_t group_num)
+instance_lookup_get(struct nfnl_log_net *log, u_int16_t group_num)
 {
 	struct nfulnl_instance *inst;
 
 	rcu_read_lock_bh();
-	inst = __instance_lookup(group_num);
+	inst = __instance_lookup(log, group_num);
 	if (inst && !atomic_inc_not_zero(&inst->use))
 		inst = NULL;
 	rcu_read_unlock_bh();
@@ -120,7 +132,11 @@ instance_lookup_get(u_int16_t group_num)
 
 static void nfulnl_instance_free_rcu(struct rcu_head *head)
 {
-	kfree(container_of(head, struct nfulnl_instance, rcu));
+	struct nfulnl_instance *inst;
+	inst = container_of(head, struct nfulnl_instance, rcu);
+
+	put_net(inst->net);
+	kfree(inst);
 	module_put(THIS_MODULE);
 }
 
@@ -134,13 +150,15 @@ instance_put(struct nfulnl_instance *inst)
 static void nfulnl_timer(unsigned long data);
 
 static struct nfulnl_instance *
-instance_create(u_int16_t group_num, int portid, struct user_namespace *user_ns)
+instance_create(struct net *net, u_int16_t group_num,
+		int portid, struct user_namespace *user_ns)
 {
 	struct nfulnl_instance *inst;
+	struct nfnl_log_net *log = nfnl_log_pernet(net);
 	int err;
 
-	spin_lock_bh(&instances_lock);
-	if (__instance_lookup(group_num)) {
+	spin_lock_bh(&log->instances_lock);
+	if (__instance_lookup(log, group_num)) {
 		err = -EEXIST;
 		goto out_unlock;
 	}
@@ -163,7 +181,7 @@ instance_create(u_int16_t group_num, int portid, struct user_namespace *user_ns)
 	atomic_set(&inst->use, 2);
 
 	setup_timer(&inst->timer, nfulnl_timer, (unsigned long)inst);
-
+	inst->net = get_net(net);
 	inst->peer_user_ns = user_ns;
 	inst->peer_portid = portid;
 	inst->group_num = group_num;
@@ -175,14 +193,15 @@ instance_create(u_int16_t group_num, int portid, struct user_namespace *user_ns)
 	inst->copy_range 	= NFULNL_COPY_RANGE_MAX;
 
 	hlist_add_head_rcu(&inst->hlist,
-		       &instance_table[instance_hashfn(group_num)]);
+		       &log->instance_table[instance_hashfn(group_num)]);
+
 
-	spin_unlock_bh(&instances_lock);
+	spin_unlock_bh(&log->instances_lock);
 
 	return inst;
 
 out_unlock:
-	spin_unlock_bh(&instances_lock);
+	spin_unlock_bh(&log->instances_lock);
 	return ERR_PTR(err);
 }
 
@@ -211,11 +230,12 @@ __instance_destroy(struct nfulnl_instance *inst)
 }
 
 static inline void
-instance_destroy(struct nfulnl_instance *inst)
+instance_destroy(struct nfnl_log_net *log,
+		 struct nfulnl_instance *inst)
 {
-	spin_lock_bh(&instances_lock);
+	spin_lock_bh(&log->instances_lock);
 	__instance_destroy(inst);
-	spin_unlock_bh(&instances_lock);
+	spin_unlock_bh(&log->instances_lock);
 }
 
 static int
@@ -337,7 +357,7 @@ __nfulnl_send(struct nfulnl_instance *inst)
 		if (!nlh)
 			goto out;
 	}
-	status = nfnetlink_unicast(inst->skb, &init_net, inst->peer_portid,
+	status = nfnetlink_unicast(inst->skb, inst->net, inst->peer_portid,
 				   MSG_DONTWAIT);
 
 	inst->qlen = 0;
@@ -371,7 +391,8 @@ nfulnl_timer(unsigned long data)
 /* This is an inline function, we don't really care about a long
  * list of arguments */
 static inline int
-__build_packet_message(struct nfulnl_instance *inst,
+__build_packet_message(struct nfnl_log_net *log,
+			struct nfulnl_instance *inst,
 			const struct sk_buff *skb,
 			unsigned int data_len,
 			u_int8_t pf,
@@ -537,7 +558,7 @@ __build_packet_message(struct nfulnl_instance *inst,
 	/* global sequence number */
 	if ((inst->flags & NFULNL_CFG_F_SEQ_GLOBAL) &&
 	    nla_put_be32(inst->skb, NFULA_SEQ_GLOBAL,
-			 htonl(atomic_inc_return(&global_seq))))
+			 htonl(atomic_inc_return(&log->global_seq))))
 		goto nla_put_failure;
 
 	if (data_len) {
@@ -593,13 +614,15 @@ nfulnl_log_packet(u_int8_t pf,
 	const struct nf_loginfo *li;
 	unsigned int qthreshold;
 	unsigned int plen;
+	struct net *net = dev_net(in ? in : out);
+	struct nfnl_log_net *log = nfnl_log_pernet(net);
 
 	if (li_user && li_user->type == NF_LOG_TYPE_ULOG)
 		li = li_user;
 	else
 		li = &default_loginfo;
 
-	inst = instance_lookup_get(li->u.ulog.group);
+	inst = instance_lookup_get(log, li->u.ulog.group);
 	if (!inst)
 		return;
 
@@ -681,7 +704,7 @@ nfulnl_log_packet(u_int8_t pf,
 
 	inst->qlen++;
 
-	__build_packet_message(inst, skb, data_len, pf,
+	__build_packet_message(log, inst, skb, data_len, pf,
 				hooknum, in, out, prefix, plen);
 
 	if (inst->qlen >= qthreshold)
@@ -710,24 +733,24 @@ nfulnl_rcv_nl_event(struct notifier_block *this,
 		   unsigned long event, void *ptr)
 {
 	struct netlink_notify *n = ptr;
+	struct nfnl_log_net *log = nfnl_log_pernet(n->net);
 
 	if (event == NETLINK_URELEASE && n->protocol == NETLINK_NETFILTER) {
 		int i;
 
 		/* destroy all instances for this portid */
-		spin_lock_bh(&instances_lock);
+		spin_lock_bh(&log->instances_lock);
 		for  (i = 0; i < INSTANCE_BUCKETS; i++) {
 			struct hlist_node *tmp, *t2;
 			struct nfulnl_instance *inst;
-			struct hlist_head *head = &instance_table[i];
+			struct hlist_head *head = &log->instance_table[i];
 
 			hlist_for_each_entry_safe(inst, tmp, t2, head, hlist) {
-				if ((net_eq(n->net, &init_net)) &&
-				    (n->portid == inst->peer_portid))
+				if (n->portid == inst->peer_portid)
 					__instance_destroy(inst);
 			}
 		}
-		spin_unlock_bh(&instances_lock);
+		spin_unlock_bh(&log->instances_lock);
 	}
 	return NOTIFY_DONE;
 }
@@ -769,6 +792,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 	struct nfulnl_instance *inst;
 	struct nfulnl_msg_config_cmd *cmd = NULL;
 	struct net *net = sock_net(ctnl);
+	struct nfnl_log_net *log = nfnl_log_pernet(net);
 	int ret = 0;
 
 	if (nfula[NFULA_CFG_CMD]) {
@@ -785,7 +809,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 		}
 	}
 
-	inst = instance_lookup_get(group_num);
+	inst = instance_lookup_get(log, group_num);
 	if (inst && inst->peer_portid != NETLINK_CB(skb).portid) {
 		ret = -EPERM;
 		goto out_put;
@@ -799,7 +823,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 				goto out_put;
 			}
 
-			inst = instance_create(group_num,
+			inst = instance_create(net, group_num,
 					       NETLINK_CB(skb).portid,
 					       sk_user_ns(NETLINK_CB(skb).ssk));
 			if (IS_ERR(inst)) {
@@ -813,7 +837,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 				goto out;
 			}
 
-			instance_destroy(inst);
+			instance_destroy(log, inst);
 			goto out_put;
 		default:
 			ret = -ENOTSUPP;
@@ -896,55 +920,66 @@ static const struct nfnetlink_subsystem nfulnl_subsys = {
 
 #ifdef CONFIG_PROC_FS
 struct iter_state {
+	struct seq_net_private p;
 	unsigned int bucket;
 };
 
-static struct hlist_node *get_first(struct iter_state *st)
+static struct hlist_node *get_first(struct net *net, struct iter_state *st)
 {
+	struct nfnl_log_net *log;
 	if (!st)
 		return NULL;
 
+	log = nfnl_log_pernet(net);
+
 	for (st->bucket = 0; st->bucket < INSTANCE_BUCKETS; st->bucket++) {
-		if (!hlist_empty(&instance_table[st->bucket]))
-			return rcu_dereference_bh(hlist_first_rcu(&instance_table[st->bucket]));
+		struct hlist_head *head = &log->instance_table[st->bucket];
+		if (!hlist_empty(head))
+			return rcu_dereference_bh(hlist_first_rcu(head));
 	}
 	return NULL;
 }
 
-static struct hlist_node *get_next(struct iter_state *st, struct hlist_node *h)
+static struct hlist_node *get_next(struct net *net, struct iter_state *st,
+				   struct hlist_node *h)
 {
 	h = rcu_dereference_bh(hlist_next_rcu(h));
 	while (!h) {
+		struct nfnl_log_net *log;
+		struct hlist_head *head;
 		if (++st->bucket >= INSTANCE_BUCKETS)
 			return NULL;
 
-		h = rcu_dereference_bh(hlist_first_rcu(&instance_table[st->bucket]));
+		log = nfnl_log_pernet(net);
+		head = &log->instance_table[st->bucket];
+		h = rcu_dereference_bh(hlist_first_rcu(head));
 	}
 	return h;
 }
 
-static struct hlist_node *get_idx(struct iter_state *st, loff_t pos)
+static struct hlist_node *get_idx(struct net *net, struct iter_state *st,
+				  loff_t pos)
 {
 	struct hlist_node *head;
-	head = get_first(st);
+	head = get_first(net, st);
 
 	if (head)
-		while (pos && (head = get_next(st, head)))
+		while (pos && (head = get_next(net, st, head)))
 			pos--;
 	return pos ? NULL : head;
 }
 
-static void *seq_start(struct seq_file *seq, loff_t *pos)
+static void *seq_start(struct seq_file *s, loff_t *pos)
 	__acquires(rcu_bh)
 {
 	rcu_read_lock_bh();
-	return get_idx(seq->private, *pos);
+	return get_idx(seq_file_net(s), s->private, *pos);
 }
 
 static void *seq_next(struct seq_file *s, void *v, loff_t *pos)
 {
 	(*pos)++;
-	return get_next(s->private, v);
+	return get_next(seq_file_net(s), s->private, v);
 }
 
 static void seq_stop(struct seq_file *s, void *v)
@@ -973,8 +1008,8 @@ static const struct seq_operations nful_seq_ops = {
 
 static int nful_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &nful_seq_ops,
-			sizeof(struct iter_state));
+	return seq_open_net(inode, file, &nful_seq_ops,
+			    sizeof(struct iter_state));
 }
 
 static const struct file_operations nful_file_ops = {
@@ -982,17 +1017,44 @@ static const struct file_operations nful_file_ops = {
 	.open	 = nful_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release_net,
 };
 
 #endif /* PROC_FS */
 
-static int __init nfnetlink_log_init(void)
+static int __net_init nfnl_log_net_init(struct net *net)
 {
-	int i, status = -ENOMEM;
-
+	unsigned int i;
+	struct nfnl_log_net *log = nfnl_log_pernet(net);
 	for (i = 0; i < INSTANCE_BUCKETS; i++)
-		INIT_HLIST_HEAD(&instance_table[i]);
+		INIT_HLIST_HEAD(&log->instance_table[i]);
+	spin_lock_init(&log->instances_lock);
+
+#ifdef CONFIG_PROC_FS
+	if (!proc_create("nfnetlink_log", 0440,
+			net->xt.proc_netfilter, &nful_file_ops))
+		return -ENOMEM;
+#endif
+	return 0;
+}
+
+static void __net_exit nfnl_log_net_exit(struct net *net)
+{
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry("nfnetlink_log", net->xt.proc_netfilter);
+#endif
+}
+
+static struct pernet_operations nfnl_log_net_ops = {
+	.init	= nfnl_log_net_init,
+	.exit	= nfnl_log_net_exit,
+	.id	= &nfnl_log_net_id,
+	.size	= sizeof(struct nfnl_log_net),
+};
+
+static int __init nfnetlink_log_init(void)
+{
+	int status = -ENOMEM;
 
 	/* it's not really all that important to have a random value, so
 	 * we can do this from the init function, even if there hasn't
@@ -1002,29 +1064,25 @@ static int __init nfnetlink_log_init(void)
 	netlink_register_notifier(&nfulnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfulnl_subsys);
 	if (status < 0) {
-		printk(KERN_ERR "log: failed to create netlink socket\n");
+		pr_err("log: failed to create netlink socket\n");
 		goto cleanup_netlink_notifier;
 	}
 
 	status = nf_log_register(NFPROTO_UNSPEC, &nfulnl_logger);
 	if (status < 0) {
-		printk(KERN_ERR "log: failed to register logger\n");
+		pr_err("log: failed to register logger\n");
 		goto cleanup_subsys;
 	}
 
-#ifdef CONFIG_PROC_FS
-	if (!proc_create("nfnetlink_log", 0440,
-			 proc_net_netfilter, &nful_file_ops)) {
-		status = -ENOMEM;
+	status = register_pernet_subsys(&nfnl_log_net_ops);
+	if (status < 0) {
+		pr_err("log: failed to register pernet ops\n");
 		goto cleanup_logger;
 	}
-#endif
 	return status;
 
-#ifdef CONFIG_PROC_FS
 cleanup_logger:
 	nf_log_unregister(&nfulnl_logger);
-#endif
 cleanup_subsys:
 	nfnetlink_subsys_unregister(&nfulnl_subsys);
 cleanup_netlink_notifier:
@@ -1034,10 +1092,8 @@ cleanup_netlink_notifier:
 
 static void __exit nfnetlink_log_fini(void)
 {
+	unregister_pernet_subsys(&nfnl_log_net_ops);
 	nf_log_unregister(&nfulnl_logger);
-#ifdef CONFIG_PROC_FS
-	remove_proc_entry("nfnetlink_log", proc_net_netfilter);
-#endif
 	nfnetlink_subsys_unregister(&nfulnl_subsys);
 	netlink_unregister_notifier(&nfulnl_rtnl_notifier);
 }
-- 
1.7.11.7
