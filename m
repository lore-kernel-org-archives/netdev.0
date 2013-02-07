From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 09/10] netfilter: nfnetlink_queue: add net namespace support for nfnetlink_queue
Date: Thu, 7 Feb 2013 15:49:49 +0800
Message-ID: <1360223390-15589-9-git-send-email-gaofeng@cn.fujitsu.com>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: containers@lists.linux-foundation.org, pablo@netfilter.org,
	ebiederm@xmission.com, netdev@vger.kernel.org, lve@guap.ru,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:1611 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752575Ab3BGHti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 02:49:38 -0500
In-Reply-To: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes /proc/net/netfilter/nfnetlink_queue pernet,
and netns has it's own instance table and lock.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nfnetlink_queue_core.c | 191 ++++++++++++++++++++++-------------
 1 file changed, 123 insertions(+), 68 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 3158d87..cc7a82a 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -30,6 +30,7 @@
 #include <linux/list.h>
 #include <net/sock.h>
 #include <net/netfilter/nf_queue.h>
+#include <net/netns/generic.h>
 #include <net/netfilter/nfnetlink_queue.h>
 
 #include <linux/atomic.h>
@@ -66,10 +67,18 @@ struct nfqnl_instance {
 
 typedef int (*nfqnl_cmpfn)(struct nf_queue_entry *, unsigned long);
 
-static DEFINE_SPINLOCK(instances_lock);
+static int nfnl_queue_net_id __read_mostly;
 
 #define INSTANCE_BUCKETS	16
-static struct hlist_head instance_table[INSTANCE_BUCKETS] __read_mostly;
+struct nfnl_queue_net {
+	spinlock_t instances_lock;
+	struct hlist_head instance_table[INSTANCE_BUCKETS];
+};
+
+static struct nfnl_queue_net *nfnl_queue_pernet(struct net *net)
+{
+	return net_generic(net, nfnl_queue_net_id);
+}
 
 static inline u_int8_t instance_hashfn(u_int16_t queue_num)
 {
@@ -77,13 +86,13 @@ static inline u_int8_t instance_hashfn(u_int16_t queue_num)
 }
 
 static struct nfqnl_instance *
-instance_lookup(u_int16_t queue_num)
+instance_lookup(struct nfnl_queue_net *q, u_int16_t queue_num)
 {
 	struct hlist_head *head;
 	struct hlist_node *pos;
 	struct nfqnl_instance *inst;
 
-	head = &instance_table[instance_hashfn(queue_num)];
+	head = &q->instance_table[instance_hashfn(queue_num)];
 	hlist_for_each_entry_rcu(inst, pos, head, hlist) {
 		if (inst->queue_num == queue_num)
 			return inst;
@@ -92,14 +101,15 @@ instance_lookup(u_int16_t queue_num)
 }
 
 static struct nfqnl_instance *
-instance_create(u_int16_t queue_num, int portid)
+instance_create(struct nfnl_queue_net *q, u_int16_t queue_num,
+		int portid)
 {
 	struct nfqnl_instance *inst;
 	unsigned int h;
 	int err;
 
-	spin_lock(&instances_lock);
-	if (instance_lookup(queue_num)) {
+	spin_lock(&q->instances_lock);
+	if (instance_lookup(q, queue_num)) {
 		err = -EEXIST;
 		goto out_unlock;
 	}
@@ -124,16 +134,16 @@ instance_create(u_int16_t queue_num, int portid)
 	}
 
 	h = instance_hashfn(queue_num);
-	hlist_add_head_rcu(&inst->hlist, &instance_table[h]);
+	hlist_add_head_rcu(&inst->hlist, &q->instance_table[h]);
 
-	spin_unlock(&instances_lock);
+	spin_unlock(&q->instances_lock);
 
 	return inst;
 
 out_free:
 	kfree(inst);
 out_unlock:
-	spin_unlock(&instances_lock);
+	spin_unlock(&q->instances_lock);
 	return ERR_PTR(err);
 }
 
@@ -159,11 +169,11 @@ __instance_destroy(struct nfqnl_instance *inst)
 }
 
 static void
-instance_destroy(struct nfqnl_instance *inst)
+instance_destroy(struct nfnl_queue_net *q, struct nfqnl_instance *inst)
 {
-	spin_lock(&instances_lock);
+	spin_lock(&q->instances_lock);
 	__instance_destroy(inst);
-	spin_unlock(&instances_lock);
+	spin_unlock(&q->instances_lock);
 }
 
 static inline void
@@ -424,9 +434,12 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	int err = -ENOBUFS;
 	__be32 *packet_id_ptr;
 	int failopen = 0;
+	struct net *net = dev_net(entry->indev ?
+				  entry->indev : entry->outdev);
+	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 
 	/* rcu_read_lock()ed by nf_hook_slow() */
-	queue = instance_lookup(queuenum);
+	queue = instance_lookup(q, queuenum);
 	if (!queue) {
 		err = -ESRCH;
 		goto err_out;
@@ -463,7 +476,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	*packet_id_ptr = htonl(entry->id);
 
 	/* nfnetlink_unicast will either free the nskb or add it to a socket */
-	err = nfnetlink_unicast(nskb, &init_net, queue->peer_portid, MSG_DONTWAIT);
+	err = nfnetlink_unicast(nskb, net, queue->peer_portid, MSG_DONTWAIT);
 	if (err < 0) {
 		queue->queue_user_dropped++;
 		goto err_out_unlock;
@@ -576,16 +589,16 @@ dev_cmp(struct nf_queue_entry *entry, unsigned long ifindex)
 /* drop all packets with either indev or outdev == ifindex from all queue
  * instances */
 static void
-nfqnl_dev_drop(int ifindex)
+nfqnl_dev_drop(struct net *net, int ifindex)
 {
 	int i;
-
+	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 	rcu_read_lock();
 
 	for (i = 0; i < INSTANCE_BUCKETS; i++) {
 		struct hlist_node *tmp;
 		struct nfqnl_instance *inst;
-		struct hlist_head *head = &instance_table[i];
+		struct hlist_head *head = &q->instance_table[i];
 
 		hlist_for_each_entry_rcu(inst, tmp, head, hlist)
 			nfqnl_flush(inst, dev_cmp, ifindex);
@@ -602,12 +615,9 @@ nfqnl_rcv_dev_event(struct notifier_block *this,
 {
 	struct net_device *dev = ptr;
 
-	if (!net_eq(dev_net(dev), &init_net))
-		return NOTIFY_DONE;
-
 	/* Drop any packets associated with the downed device */
 	if (event == NETDEV_DOWN)
-		nfqnl_dev_drop(dev->ifindex);
+		nfqnl_dev_drop(dev_net(dev), dev->ifindex);
 	return NOTIFY_DONE;
 }
 
@@ -620,24 +630,24 @@ nfqnl_rcv_nl_event(struct notifier_block *this,
 		   unsigned long event, void *ptr)
 {
 	struct netlink_notify *n = ptr;
+	struct nfnl_queue_net *q = nfnl_queue_pernet(n->net);
 
 	if (event == NETLINK_URELEASE && n->protocol == NETLINK_NETFILTER) {
 		int i;
 
 		/* destroy all instances for this portid */
-		spin_lock(&instances_lock);
+		spin_lock(&q->instances_lock);
 		for (i = 0; i < INSTANCE_BUCKETS; i++) {
 			struct hlist_node *tmp, *t2;
 			struct nfqnl_instance *inst;
-			struct hlist_head *head = &instance_table[i];
+			struct hlist_head *head = &q->instance_table[i];
 
 			hlist_for_each_entry_safe(inst, tmp, t2, head, hlist) {
-				if ((n->net == &init_net) &&
-				    (n->portid == inst->peer_portid))
+				if (n->portid == inst->peer_portid)
 					__instance_destroy(inst);
 			}
 		}
-		spin_unlock(&instances_lock);
+		spin_unlock(&q->instances_lock);
 	}
 	return NOTIFY_DONE;
 }
@@ -658,11 +668,13 @@ static const struct nla_policy nfqa_verdict_batch_policy[NFQA_MAX+1] = {
 	[NFQA_MARK]		= { .type = NLA_U32 },
 };
 
-static struct nfqnl_instance *verdict_instance_lookup(u16 queue_num, int nlportid)
+static struct nfqnl_instance *
+verdict_instance_lookup(struct nfnl_queue_net *q,
+			u16 queue_num, int nlportid)
 {
 	struct nfqnl_instance *queue;
 
-	queue = instance_lookup(queue_num);
+	queue = instance_lookup(q, queue_num);
 	if (!queue)
 		return ERR_PTR(-ENODEV);
 
@@ -706,7 +718,11 @@ nfqnl_recv_verdict_batch(struct sock *ctnl, struct sk_buff *skb,
 	LIST_HEAD(batch_list);
 	u16 queue_num = ntohs(nfmsg->res_id);
 
-	queue = verdict_instance_lookup(queue_num, NETLINK_CB(skb).portid);
+	struct net *net = sock_net(ctnl);
+	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
+
+	queue = verdict_instance_lookup(q, queue_num,
+					NETLINK_CB(skb).portid);
 	if (IS_ERR(queue))
 		return PTR_ERR(queue);
 
@@ -754,10 +770,13 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	enum ip_conntrack_info uninitialized_var(ctinfo);
 	struct nf_conn *ct = NULL;
 
-	queue = instance_lookup(queue_num);
-	if (!queue)
+	struct net *net = sock_net(ctnl);
+	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 
-	queue = verdict_instance_lookup(queue_num, NETLINK_CB(skb).portid);
+	queue = instance_lookup(q, queue_num);
+	if (!queue)
+		queue = verdict_instance_lookup(q, queue_num,
+						NETLINK_CB(skb).portid);
 	if (IS_ERR(queue))
 		return PTR_ERR(queue);
 
@@ -821,6 +840,8 @@ nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 	u_int16_t queue_num = ntohs(nfmsg->res_id);
 	struct nfqnl_instance *queue;
 	struct nfqnl_msg_config_cmd *cmd = NULL;
+	struct net *net = sock_net(ctnl);
+	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 	int ret = 0;
 
 	if (nfqa[NFQA_CFG_CMD]) {
@@ -834,7 +855,7 @@ nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 	}
 
 	rcu_read_lock();
-	queue = instance_lookup(queue_num);
+	queue = instance_lookup(q, queue_num);
 	if (queue && queue->peer_portid != NETLINK_CB(skb).portid) {
 		ret = -EPERM;
 		goto err_out_unlock;
@@ -847,7 +868,8 @@ nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 				ret = -EBUSY;
 				goto err_out_unlock;
 			}
-			queue = instance_create(queue_num, NETLINK_CB(skb).portid);
+			queue = instance_create(q, queue_num,
+						NETLINK_CB(skb).portid);
 			if (IS_ERR(queue)) {
 				ret = PTR_ERR(queue);
 				goto err_out_unlock;
@@ -858,7 +880,7 @@ nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 				ret = -ENODEV;
 				goto err_out_unlock;
 			}
-			instance_destroy(queue);
+			instance_destroy(q, queue);
 			break;
 		case NFQNL_CFG_CMD_PF_BIND:
 		case NFQNL_CFG_CMD_PF_UNBIND:
@@ -952,53 +974,63 @@ static const struct nfnetlink_subsystem nfqnl_subsys = {
 
 #ifdef CONFIG_PROC_FS
 struct iter_state {
+	struct seq_net_private p;
 	unsigned int bucket;
 };
 
-static struct hlist_node *get_first(struct seq_file *seq)
+static struct hlist_node *get_first(struct seq_file *s)
 {
-	struct iter_state *st = seq->private;
+	struct iter_state *st = s->private;
+	struct net *net;
+	struct nfnl_queue_net *q;
 
 	if (!st)
 		return NULL;
 
+	net = seq_file_net(s);
+	q = nfnl_queue_pernet(net);
 	for (st->bucket = 0; st->bucket < INSTANCE_BUCKETS; st->bucket++) {
-		if (!hlist_empty(&instance_table[st->bucket]))
-			return instance_table[st->bucket].first;
+		if (!hlist_empty(&q->instance_table[st->bucket]))
+			return q->instance_table[st->bucket].first;
 	}
 	return NULL;
 }
 
-static struct hlist_node *get_next(struct seq_file *seq, struct hlist_node *h)
+static struct hlist_node *get_next(struct seq_file *s,
+				   struct hlist_node *h)
 {
-	struct iter_state *st = seq->private;
+	struct iter_state *st = s->private;
+	struct net *net = seq_file_net(s);
 
 	h = h->next;
 	while (!h) {
+		struct nfnl_queue_net *q;
+
 		if (++st->bucket >= INSTANCE_BUCKETS)
 			return NULL;
 
-		h = instance_table[st->bucket].first;
+		q = nfnl_queue_pernet(net);
+		h = q->instance_table[st->bucket].first;
 	}
 	return h;
 }
 
-static struct hlist_node *get_idx(struct seq_file *seq, loff_t pos)
+static struct hlist_node *get_idx(struct seq_file *s, loff_t pos)
 {
 	struct hlist_node *head;
-	head = get_first(seq);
+	head = get_first(s);
 
 	if (head)
-		while (pos && (head = get_next(seq, head)))
+		while (pos && (head = get_next(s, head)))
 			pos--;
 	return pos ? NULL : head;
 }
 
-static void *seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(instances_lock)
+static void *seq_start(struct seq_file *s, loff_t *pos)
+	__acquires(nfnl_queue_pernet(seq_file_net(s))->instances_lock)
 {
-	spin_lock(&instances_lock);
-	return get_idx(seq, *pos);
+	spin_lock(&nfnl_queue_pernet(seq_file_net(s))->instances_lock);
+	return get_idx(s, *pos);
 }
 
 static void *seq_next(struct seq_file *s, void *v, loff_t *pos)
@@ -1008,9 +1040,9 @@ static void *seq_next(struct seq_file *s, void *v, loff_t *pos)
 }
 
 static void seq_stop(struct seq_file *s, void *v)
-	__releases(instances_lock)
+	__releases(nfnl_queue_pernet(seq_file_net(s))->instances_lock)
 {
-	spin_unlock(&instances_lock);
+	spin_unlock(&nfnl_queue_pernet(seq_file_net(s))->instances_lock);
 }
 
 static int seq_show(struct seq_file *s, void *v)
@@ -1034,7 +1066,7 @@ static const struct seq_operations nfqnl_seq_ops = {
 
 static int nfqnl_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &nfqnl_seq_ops,
+	return seq_open_net(inode, file, &nfqnl_seq_ops,
 			sizeof(struct iter_state));
 }
 
@@ -1043,39 +1075,64 @@ static const struct file_operations nfqnl_file_ops = {
 	.open	 = nfqnl_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release_net,
 };
 
 #endif /* PROC_FS */
 
-static int __init nfnetlink_queue_init(void)
+static int __net_init nfnl_queue_net_init(struct net *net)
 {
-	int i, status = -ENOMEM;
+	unsigned int i;
+	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 
 	for (i = 0; i < INSTANCE_BUCKETS; i++)
-		INIT_HLIST_HEAD(&instance_table[i]);
+		INIT_HLIST_HEAD(&q->instance_table[i]);
+	spin_lock_init(&q->instances_lock);
+
+#ifdef CONFIG_PROC_FS
+	if (!proc_create("nfnetlink_queue", 0440,
+			 net->xt.proc_netfilter, &nfqnl_file_ops))
+		return -ENOMEM;
+#endif
+	return 0;
+}
+
+static void __net_exit nfnl_queue_net_exit(struct net *net)
+{
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry("nfnetlink_queue", net->xt.proc_netfilter);
+#endif
+}
+
+static struct pernet_operations nfnl_queue_net_ops = {
+	.init	= nfnl_queue_net_init,
+	.exit	= nfnl_queue_net_exit,
+	.id	= &nfnl_queue_net_id,
+	.size	= sizeof(struct nfnl_queue_net),
+};
+
+static int __init nfnetlink_queue_init(void)
+{
+	int status = -ENOMEM;
 
 	netlink_register_notifier(&nfqnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfqnl_subsys);
 	if (status < 0) {
-		printk(KERN_ERR "nf_queue: failed to create netlink socket\n");
+		pr_err("nf_queue: failed to create netlink socket\n");
 		goto cleanup_netlink_notifier;
 	}
 
-#ifdef CONFIG_PROC_FS
-	if (!proc_create("nfnetlink_queue", 0440,
-			 proc_net_netfilter, &nfqnl_file_ops))
+	status = register_pernet_subsys(&nfnl_queue_net_ops);
+	if (status < 0) {
+		pr_err("nf_queue: failed to register pernet ops\n");
 		goto cleanup_subsys;
-#endif
-
+	}
 	register_netdevice_notifier(&nfqnl_dev_notifier);
 	nf_register_queue_handler(&nfqh);
 	return status;
 
-#ifdef CONFIG_PROC_FS
 cleanup_subsys:
 	nfnetlink_subsys_unregister(&nfqnl_subsys);
-#endif
 cleanup_netlink_notifier:
 	netlink_unregister_notifier(&nfqnl_rtnl_notifier);
 	return status;
@@ -1085,9 +1142,7 @@ static void __exit nfnetlink_queue_fini(void)
 {
 	nf_unregister_queue_handler();
 	unregister_netdevice_notifier(&nfqnl_dev_notifier);
-#ifdef CONFIG_PROC_FS
-	remove_proc_entry("nfnetlink_queue", proc_net_netfilter);
-#endif
+	unregister_pernet_subsys(&nfnl_queue_net_ops);
 	nfnetlink_subsys_unregister(&nfqnl_subsys);
 	netlink_unregister_notifier(&nfqnl_rtnl_notifier);
 
-- 
1.7.11.7
