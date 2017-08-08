From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 5/7] rtnetlink: protect handler table with rcu
Date: Tue,  8 Aug 2017 18:02:34 +0200
Message-ID: <20170808160236.28562-6-fw@strlen.de>
References: <20170808160236.28562-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:35540 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752387AbdHHQCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 12:02:36 -0400
In-Reply-To: <20170808160236.28562-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note that netlink dumps still acquire rtnl mutex via the netlink
dump infrastructure.

Signed-off-by: Florian Westphal <fw@strlen.de>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/rtnetlink.c | 121 +++++++++++++++++++++++++++------------------------
 1 file changed, 65 insertions(+), 56 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index be01d8e48661..d45946177bc8 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -126,7 +126,7 @@ bool lockdep_rtnl_is_held(void)
 EXPORT_SYMBOL(lockdep_rtnl_is_held);
 #endif /* #ifdef CONFIG_PROVE_LOCKING */
 
-static struct rtnl_link *rtnl_msg_handlers[RTNL_FAMILY_MAX + 1];
+static struct rtnl_link __rcu *rtnl_msg_handlers[RTNL_FAMILY_MAX + 1];
 static refcount_t rtnl_msg_handlers_ref[RTNL_FAMILY_MAX + 1];
 
 static inline int rtm_msgindex(int msgtype)
@@ -143,36 +143,6 @@ static inline int rtm_msgindex(int msgtype)
 	return msgindex;
 }
 
-static rtnl_doit_func rtnl_get_doit(int protocol, int msgindex)
-{
-	struct rtnl_link *tab;
-
-	if (protocol <= RTNL_FAMILY_MAX)
-		tab = rtnl_msg_handlers[protocol];
-	else
-		tab = NULL;
-
-	if (tab == NULL || tab[msgindex].doit == NULL)
-		tab = rtnl_msg_handlers[PF_UNSPEC];
-
-	return tab[msgindex].doit;
-}
-
-static rtnl_dumpit_func rtnl_get_dumpit(int protocol, int msgindex)
-{
-	struct rtnl_link *tab;
-
-	if (protocol <= RTNL_FAMILY_MAX)
-		tab = rtnl_msg_handlers[protocol];
-	else
-		tab = NULL;
-
-	if (tab == NULL || tab[msgindex].dumpit == NULL)
-		tab = rtnl_msg_handlers[PF_UNSPEC];
-
-	return tab[msgindex].dumpit;
-}
-
 /**
  * __rtnl_register - Register a rtnetlink message type
  * @protocol: Protocol family or PF_UNSPEC
@@ -201,18 +171,17 @@ int __rtnl_register(int protocol, int msgtype,
 	BUG_ON(protocol < 0 || protocol > RTNL_FAMILY_MAX);
 	msgindex = rtm_msgindex(msgtype);
 
-	tab = rtnl_msg_handlers[protocol];
+	tab = rcu_dereference(rtnl_msg_handlers[protocol]);
 	if (tab == NULL) {
 		tab = kcalloc(RTM_NR_MSGTYPES, sizeof(*tab), GFP_KERNEL);
 		if (tab == NULL)
 			return -ENOBUFS;
 
-		rtnl_msg_handlers[protocol] = tab;
+		rcu_assign_pointer(rtnl_msg_handlers[protocol], tab);
 	}
 
 	if (doit)
 		tab[msgindex].doit = doit;
-
 	if (dumpit)
 		tab[msgindex].dumpit = dumpit;
 
@@ -249,16 +218,22 @@ EXPORT_SYMBOL_GPL(rtnl_register);
  */
 int rtnl_unregister(int protocol, int msgtype)
 {
+	struct rtnl_link *handlers;
 	int msgindex;
 
 	BUG_ON(protocol < 0 || protocol > RTNL_FAMILY_MAX);
 	msgindex = rtm_msgindex(msgtype);
 
-	if (rtnl_msg_handlers[protocol] == NULL)
+	rtnl_lock();
+	handlers = rtnl_dereference(rtnl_msg_handlers[protocol]);
+	if (!handlers) {
+		rtnl_unlock();
 		return -ENOENT;
+	}
 
-	rtnl_msg_handlers[protocol][msgindex].doit = NULL;
-	rtnl_msg_handlers[protocol][msgindex].dumpit = NULL;
+	handlers[msgindex].doit = NULL;
+	handlers[msgindex].dumpit = NULL;
+	rtnl_unlock();
 
 	return 0;
 }
@@ -278,10 +253,12 @@ void rtnl_unregister_all(int protocol)
 	BUG_ON(protocol < 0 || protocol > RTNL_FAMILY_MAX);
 
 	rtnl_lock();
-	handlers = rtnl_msg_handlers[protocol];
-	rtnl_msg_handlers[protocol] = NULL;
+	handlers = rtnl_dereference(rtnl_msg_handlers[protocol]);
+	RCU_INIT_POINTER(rtnl_msg_handlers[protocol], NULL);
 	rtnl_unlock();
 
+	synchronize_net();
+
 	while (refcount_read(&rtnl_msg_handlers_ref[protocol]) > 0)
 		schedule();
 	kfree(handlers);
@@ -2820,11 +2797,13 @@ static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
 	 * traverse the list of net devices and compute the minimum
 	 * buffer size based upon the filter mask.
 	 */
-	list_for_each_entry(dev, &net->dev_base_head, dev_list) {
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
 		min_ifinfo_dump_size = max_t(u16, min_ifinfo_dump_size,
 					     if_nlmsg_size(dev,
 						           ext_filter_mask));
 	}
+	rcu_read_unlock();
 
 	return nlmsg_total_size(min_ifinfo_dump_size);
 }
@@ -2836,19 +2815,29 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 
 	if (s_idx == 0)
 		s_idx = 1;
+
 	for (idx = 1; idx <= RTNL_FAMILY_MAX; idx++) {
 		int type = cb->nlh->nlmsg_type-RTM_BASE;
+		struct rtnl_link *handlers;
+		rtnl_dumpit_func dumpit;
+
 		if (idx < s_idx || idx == PF_PACKET)
 			continue;
-		if (rtnl_msg_handlers[idx] == NULL ||
-		    rtnl_msg_handlers[idx][type].dumpit == NULL)
+
+		handlers = rtnl_dereference(rtnl_msg_handlers[idx]);
+		if (!handlers)
 			continue;
+
+		dumpit = READ_ONCE(handlers[type].dumpit);
+		if (!dumpit)
+			continue;
+
 		if (idx > s_idx) {
 			memset(&cb->args[0], 0, sizeof(cb->args));
 			cb->prev_seq = 0;
 			cb->seq = 0;
 		}
-		if (rtnl_msg_handlers[idx][type].dumpit(skb, cb))
+		if (dumpit(skb, cb))
 			break;
 	}
 	cb->family = idx;
@@ -4151,11 +4140,12 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 			     struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
+	struct rtnl_link *handlers;
+	int err = -EOPNOTSUPP;
 	rtnl_doit_func doit;
 	int kind;
 	int family;
 	int type;
-	int err;
 
 	type = nlh->nlmsg_type;
 	if (type > RTM_MAX)
@@ -4173,23 +4163,40 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (kind != 2 && !netlink_net_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
+	if (family > ARRAY_SIZE(rtnl_msg_handlers))
+		family = PF_UNSPEC;
+
+	rcu_read_lock();
+	handlers = rcu_dereference(rtnl_msg_handlers[family]);
+	if (!handlers) {
+		family = PF_UNSPEC;
+		handlers = rcu_dereference(rtnl_msg_handlers[family]);
+	}
+
 	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
 		struct sock *rtnl;
 		rtnl_dumpit_func dumpit;
 		u16 min_dump_alloc = 0;
 
-		rtnl_lock();
+		dumpit = READ_ONCE(handlers[type].dumpit);
+		if (!dumpit) {
+			family = PF_UNSPEC;
+			handlers = rcu_dereference(rtnl_msg_handlers[PF_UNSPEC]);
+			if (!handlers)
+				goto err_unlock;
 
-		dumpit = rtnl_get_dumpit(family, type);
-		if (dumpit == NULL)
-			goto err_unlock;
+			dumpit = READ_ONCE(handlers[type].dumpit);
+			if (!dumpit)
+				goto err_unlock;
+		}
 
 		refcount_inc(&rtnl_msg_handlers_ref[family]);
 
 		if (type == RTM_GETLINK)
 			min_dump_alloc = rtnl_calcit(skb, nlh);
 
-		__rtnl_unlock();
+		rcu_read_unlock();
+
 		rtnl = net->rtnl;
 		{
 			struct netlink_dump_control c = {
@@ -4202,18 +4209,20 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 	}
 
-	rtnl_lock();
-	doit = rtnl_get_doit(family, type);
-	if (doit == NULL)
-		goto err_unlock;
+	rcu_read_unlock();
 
-	err = doit(skb, nlh, extack);
+	rtnl_lock();
+	handlers = rtnl_dereference(rtnl_msg_handlers[family]);
+	if (handlers) {
+		doit = READ_ONCE(handlers[type].doit);
+		if (doit)
+			err = doit(skb, nlh, extack);
+	}
 	rtnl_unlock();
-
 	return err;
 
 err_unlock:
-	rtnl_unlock();
+	rcu_read_unlock();
 	return -EOPNOTSUPP;
 }
 
-- 
2.13.0
