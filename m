From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 09/62: nfnetlink: netns support
Date: Tue, 16 Feb 2010 15:55:31 +0100 (MET)
Message-ID: <20100216145529.2796.82119.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit cd8c20b650f49354722b8cc1f03320b004815a0a
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Wed Jan 13 16:02:14 2010 +0100

    netfilter: nfnetlink: netns support
    
    Make nfnl socket per-petns.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 49d321f..5392386 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -73,11 +73,11 @@ struct nfnetlink_subsystem {
 extern int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n);
 extern int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n);
 
-extern int nfnetlink_has_listeners(unsigned int group);
-extern int nfnetlink_send(struct sk_buff *skb, u32 pid, unsigned group, 
+extern int nfnetlink_has_listeners(struct net *net, unsigned int group);
+extern int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned group,
 			  int echo, gfp_t flags);
-extern void nfnetlink_set_err(u32 pid, u32 group, int error);
-extern int nfnetlink_unicast(struct sk_buff *skb, u_int32_t pid, int flags);
+extern void nfnetlink_set_err(struct net *net, u32 pid, u32 group, int error);
+extern int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u_int32_t pid, int flags);
 
 extern void nfnl_lock(void);
 extern void nfnl_unlock(void);
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index f307e13..82b7be4 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -81,6 +81,8 @@ struct net {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	struct netns_ct		ct;
 #endif
+	struct sock		*nfnl;
+	struct sock		*nfnl_stash;
 #endif
 #ifdef CONFIG_XFRM
 	struct netns_xfrm	xfrm;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 59d8064..d4c5d06 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -482,7 +482,7 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	} else
 		return 0;
 
-	if (!item->report && !nfnetlink_has_listeners(group))
+	if (!item->report && !nfnetlink_has_listeners(&init_net, group))
 		return 0;
 
 	skb = nlmsg_new(ctnetlink_nlmsg_size(ct), GFP_ATOMIC);
@@ -559,7 +559,8 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	rcu_read_unlock();
 
 	nlmsg_end(skb, nlh);
-	err = nfnetlink_send(skb, item->pid, group, item->report, GFP_ATOMIC);
+	err = nfnetlink_send(skb, &init_net, item->pid, group, item->report,
+			     GFP_ATOMIC);
 	if (err == -ENOBUFS || err == -EAGAIN)
 		return -ENOBUFS;
 
@@ -571,7 +572,7 @@ nla_put_failure:
 nlmsg_failure:
 	kfree_skb(skb);
 errout:
-	nfnetlink_set_err(0, group, -ENOBUFS);
+	nfnetlink_set_err(&init_net, 0, group, -ENOBUFS);
 	return 0;
 }
 #endif /* CONFIG_NF_CONNTRACK_EVENTS */
@@ -1539,7 +1540,7 @@ ctnetlink_expect_event(unsigned int events, struct nf_exp_event *item)
 		return 0;
 
 	if (!item->report &&
-	    !nfnetlink_has_listeners(NFNLGRP_CONNTRACK_EXP_NEW))
+	    !nfnetlink_has_listeners(&init_net, NFNLGRP_CONNTRACK_EXP_NEW))
 		return 0;
 
 	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
@@ -1562,7 +1563,7 @@ ctnetlink_expect_event(unsigned int events, struct nf_exp_event *item)
 	rcu_read_unlock();
 
 	nlmsg_end(skb, nlh);
-	nfnetlink_send(skb, item->pid, NFNLGRP_CONNTRACK_EXP_NEW,
+	nfnetlink_send(skb, &init_net, item->pid, NFNLGRP_CONNTRACK_EXP_NEW,
 		       item->report, GFP_ATOMIC);
 	return 0;
 
@@ -1572,7 +1573,7 @@ nla_put_failure:
 nlmsg_failure:
 	kfree_skb(skb);
 errout:
-	nfnetlink_set_err(0, 0, -ENOBUFS);
+	nfnetlink_set_err(&init_net, 0, 0, -ENOBUFS);
 	return 0;
 }
 #endif
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index eedc0c1..8eb0cc2 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -40,7 +40,6 @@ MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_NETFILTER);
 
 static char __initdata nfversion[] = "0.30";
 
-static struct sock *nfnl = NULL;
 static const struct nfnetlink_subsystem *subsys_table[NFNL_SUBSYS_COUNT];
 static DEFINE_MUTEX(nfnl_mutex);
 
@@ -101,34 +100,35 @@ nfnetlink_find_client(u_int16_t type, const struct nfnetlink_subsystem *ss)
 	return &ss->cb[cb_id];
 }
 
-int nfnetlink_has_listeners(unsigned int group)
+int nfnetlink_has_listeners(struct net *net, unsigned int group)
 {
-	return netlink_has_listeners(nfnl, group);
+	return netlink_has_listeners(net->nfnl, group);
 }
 EXPORT_SYMBOL_GPL(nfnetlink_has_listeners);
 
-int nfnetlink_send(struct sk_buff *skb, u32 pid,
+int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid,
 		   unsigned group, int echo, gfp_t flags)
 {
-	return nlmsg_notify(nfnl, skb, pid, group, echo, flags);
+	return nlmsg_notify(net->nfnl, skb, pid, group, echo, flags);
 }
 EXPORT_SYMBOL_GPL(nfnetlink_send);
 
-void nfnetlink_set_err(u32 pid, u32 group, int error)
+void nfnetlink_set_err(struct net *net, u32 pid, u32 group, int error)
 {
-	netlink_set_err(nfnl, pid, group, error);
+	netlink_set_err(net->nfnl, pid, group, error);
 }
 EXPORT_SYMBOL_GPL(nfnetlink_set_err);
 
-int nfnetlink_unicast(struct sk_buff *skb, u_int32_t pid, int flags)
+int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u_int32_t pid, int flags)
 {
-	return netlink_unicast(nfnl, skb, pid, flags);
+	return netlink_unicast(net->nfnl, skb, pid, flags);
 }
 EXPORT_SYMBOL_GPL(nfnetlink_unicast);
 
 /* Process one complete nfnetlink message. */
 static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
+	struct net *net = sock_net(skb->sk);
 	const struct nfnl_callback *nc;
 	const struct nfnetlink_subsystem *ss;
 	int type, err;
@@ -170,7 +170,7 @@ replay:
 		if (err < 0)
 			return err;
 
-		err = nc->call(nfnl, skb, nlh, (const struct nlattr **)cda);
+		err = nc->call(net->nfnl, skb, nlh, (const struct nlattr **)cda);
 		if (err == -EAGAIN)
 			goto replay;
 		return err;
@@ -184,26 +184,45 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 	nfnl_unlock();
 }
 
-static void __exit nfnetlink_exit(void)
+static int __net_init nfnetlink_net_init(struct net *net)
 {
-	printk("Removing netfilter NETLINK layer.\n");
-	netlink_kernel_release(nfnl);
-	return;
+	struct sock *nfnl;
+
+	nfnl = netlink_kernel_create(net, NETLINK_NETFILTER, NFNLGRP_MAX,
+				     nfnetlink_rcv, NULL, THIS_MODULE);
+	if (!nfnl)
+		return -ENOMEM;
+	net->nfnl_stash = nfnl;
+	rcu_assign_pointer(net->nfnl, nfnl);
+	return 0;
 }
 
-static int __init nfnetlink_init(void)
+static void __net_exit nfnetlink_net_exit_batch(struct list_head *net_exit_list)
 {
-	printk("Netfilter messages via NETLINK v%s.\n", nfversion);
+	struct net *net;
 
-	nfnl = netlink_kernel_create(&init_net, NETLINK_NETFILTER, NFNLGRP_MAX,
-				     nfnetlink_rcv, NULL, THIS_MODULE);
-	if (!nfnl) {
-		printk(KERN_ERR "cannot initialize nfnetlink!\n");
-		return -ENOMEM;
-	}
+	list_for_each_entry(net, net_exit_list, exit_list)
+		rcu_assign_pointer(net->nfnl, NULL);
+	synchronize_net();
+	list_for_each_entry(net, net_exit_list, exit_list)
+		netlink_kernel_release(net->nfnl_stash);
+}
 
-	return 0;
+static struct pernet_operations nfnetlink_net_ops = {
+	.init		= nfnetlink_net_init,
+	.exit_batch	= nfnetlink_net_exit_batch,
+};
+
+static int __init nfnetlink_init(void)
+{
+	printk("Netfilter messages via NETLINK v%s.\n", nfversion);
+	return register_pernet_subsys(&nfnetlink_net_ops);
 }
 
+static void __exit nfnetlink_exit(void)
+{
+	printk("Removing netfilter NETLINK layer.\n");
+	unregister_pernet_subsys(&nfnetlink_net_ops);
+}
 module_init(nfnetlink_init);
 module_exit(nfnetlink_exit);
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 9de0470..285e902 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -323,7 +323,8 @@ __nfulnl_send(struct nfulnl_instance *inst)
 			  NLMSG_DONE,
 			  sizeof(struct nfgenmsg));
 
-	status = nfnetlink_unicast(inst->skb, inst->peer_pid, MSG_DONTWAIT);
+	status = nfnetlink_unicast(inst->skb, &init_net, inst->peer_pid,
+				   MSG_DONTWAIT);
 
 	inst->qlen = 0;
 	inst->skb = NULL;
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 7e3fa41..5c589b2 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -420,7 +420,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	}
 
 	/* nfnetlink_unicast will either free the nskb or add it to a socket */
-	err = nfnetlink_unicast(nskb, queue->peer_pid, MSG_DONTWAIT);
+	err = nfnetlink_unicast(nskb, &init_net, queue->peer_pid, MSG_DONTWAIT);
 	if (err < 0) {
 		queue->queue_user_dropped++;
 		goto err_out_unlock;
