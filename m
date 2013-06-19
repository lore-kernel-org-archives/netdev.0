From: Daniel Borkmann <dborkman@redhat.com>
Subject: [RFC PATCH net-next 2/3] net: netlink: add registration/unregistration of virtual tap devices
Date: Wed, 19 Jun 2013 20:04:45 +0200
Message-ID: <1371665086-19677-3-git-send-email-dborkman@redhat.com>
References: <1371665086-19677-1-git-send-email-dborkman@redhat.com>
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51771 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934993Ab3FSSFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 14:05:19 -0400
In-Reply-To: <1371665086-19677-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to the networking receive path with ptype_all taps, we add
the possibility to register callbacks to the netlink subsystem, so
that those in-kernel cbs can be used for netlink analyzers/debugger.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/netlink.h  | 11 ++++++++
 net/netlink/af_netlink.c | 72 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 83 insertions(+)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index f78b430..5b4659c 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -145,4 +145,15 @@ static inline int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	return __netlink_dump_start(ssk, skb, nlh, control);
 }
 
+struct netlink_tap {
+	struct net_device *dev;
+	int (*func)(struct sk_buff *skb, struct net_device *dev);
+	struct module *module;
+	struct list_head list;
+};
+
+extern void netlink_add_tap(struct netlink_tap *nt);
+extern void __netlink_remove_tap(struct netlink_tap *nt);
+extern void netlink_remove_tap(struct netlink_tap *nt);
+
 #endif	/* __LINUX_NETLINK_H */
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8978755..83df95c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -101,6 +101,9 @@ static atomic_t nl_table_users = ATOMIC_INIT(0);
 
 static ATOMIC_NOTIFIER_HEAD(netlink_chain);
 
+static DEFINE_SPINLOCK(netlink_tap_lock);
+static struct list_head netlink_tap_all __read_mostly;
+
 static inline u32 netlink_group_mask(u32 group)
 {
 	return group ? 1 << (group - 1) : 0;
@@ -111,6 +114,66 @@ static inline struct hlist_head *nl_portid_hashfn(struct nl_portid_hash *hash, u
 	return &hash->table[jhash_1word(portid, hash->rnd) & hash->mask];
 }
 
+void netlink_add_tap(struct netlink_tap *nt)
+{
+	spin_lock(&netlink_tap_lock);
+	list_add_rcu(&nt->list, &netlink_tap_all);
+	spin_unlock(&netlink_tap_lock);
+
+	if (nt->module)
+		__module_get(nt->module);
+}
+EXPORT_SYMBOL_GPL(netlink_add_tap);
+
+void __netlink_remove_tap(struct netlink_tap *nt)
+{
+	bool found = false;
+	struct netlink_tap *tmp;
+
+	spin_lock(&netlink_tap_lock);
+
+	list_for_each_entry(tmp, &netlink_tap_all, list) {
+		if (nt == tmp) {
+			list_del_rcu(&nt->list);
+			found = true;
+			goto out;
+		}
+	}
+
+	pr_warn("__netlink_remove_tap: %p not found\n", nt);
+out:
+	spin_unlock(&netlink_tap_lock);
+
+	if (found && nt->module)
+		module_put(nt->module);
+}
+EXPORT_SYMBOL_GPL(__netlink_remove_tap);
+
+void netlink_remove_tap(struct netlink_tap *nt)
+{
+	__netlink_remove_tap(nt);
+	synchronize_net();
+}
+EXPORT_SYMBOL_GPL(netlink_remove_tap);
+
+static void __netlink_deliver_tap(struct sk_buff *skb)
+{
+	struct netlink_tap *tmp;
+
+	list_for_each_entry_rcu(tmp, &netlink_tap_all, list)
+		tmp->func(skb, tmp->dev);
+}
+
+static void netlink_deliver_tap(struct sk_buff *skb)
+{
+	rcu_read_lock();
+
+	if (unlikely(!list_empty(&netlink_tap_all)))
+		__netlink_deliver_tap(skb);
+
+	rcu_read_unlock();
+}
+
 static void netlink_overrun(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -1518,6 +1581,8 @@ static int __netlink_sendskb(struct sock *sk, struct sk_buff *skb)
 {
 	int len = skb->len;
 
+	netlink_deliver_tap(skb);
+
 #ifdef CONFIG_NETLINK_MMAP
 	if (netlink_skb_is_mmaped(skb))
 		netlink_queue_mmaped_skb(sk, skb);
@@ -1578,6 +1643,11 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 
 	ret = -ECONNREFUSED;
 	if (nlk->netlink_rcv != NULL) {
+		/* We could do a netlink_deliver_tap(skb) here as well
+		 * but since this is intended for the kernel only, we
+		 * should rather let it stay under the hood.
+		 */
+
 		ret = skb->len;
 		netlink_skb_set_owner_r(skb, sk);
 		NETLINK_CB(skb).sk = ssk;
@@ -2975,6 +3045,8 @@ static int __init netlink_proto_init(void)
 		nl_table[i].compare = netlink_compare;
 	}
 
+	INIT_LIST_HEAD(&netlink_tap_all);
+
 	netlink_add_usersock_entry();
 
 	sock_register(&netlink_family_ops);
-- 
1.7.11.7
