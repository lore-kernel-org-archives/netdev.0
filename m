From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/3] net: netlink: virtual tap device management
Date: Fri, 21 Jun 2013 19:38:07 +0200
Message-ID: <1371836288-13122-3-git-send-email-dborkman@redhat.com>
References: <1371836288-13122-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32948 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423307Ab3FURiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 13:38:13 -0400
In-Reply-To: <1371836288-13122-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to the networking receive path with ptype_all taps, we add
the possibility to register netdevices that are for ARPHRD_NETLINK to
the netlink subsystem, so that those can be used for netlink analyzers
resp. debuggers. We do not offer a direct callback function as out-of-tree
modules could do crap with it. Instead, a netdevice must be registered
properly and only receives a clone, managed by the netlink layer. Symbols
are exported as GPL-only.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/netlink.h  |  10 +++++
 net/netlink/af_netlink.c | 107 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 117 insertions(+)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index f78b430..86fde81a 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -145,4 +145,14 @@ static inline int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	return __netlink_dump_start(ssk, skb, nlh, control);
 }
 
+struct netlink_tap {
+	struct net_device *dev;
+	struct module *module;
+	struct list_head list;
+};
+
+extern int netlink_add_tap(struct netlink_tap *nt);
+extern int __netlink_remove_tap(struct netlink_tap *nt);
+extern int netlink_remove_tap(struct netlink_tap *nt);
+
 #endif	/* __LINUX_NETLINK_H */
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8978755..796f1a5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -57,6 +57,7 @@
 #include <linux/audit.h>
 #include <linux/mutex.h>
 #include <linux/vmalloc.h>
+#include <linux/if_arp.h>
 #include <asm/cacheflush.h>
 
 #include <net/net_namespace.h>
@@ -101,6 +102,9 @@ static atomic_t nl_table_users = ATOMIC_INIT(0);
 
 static ATOMIC_NOTIFIER_HEAD(netlink_chain);
 
+static DEFINE_SPINLOCK(netlink_tap_lock);
+static struct list_head netlink_tap_all __read_mostly;
+
 static inline u32 netlink_group_mask(u32 group)
 {
 	return group ? 1 << (group - 1) : 0;
@@ -111,6 +115,100 @@ static inline struct hlist_head *nl_portid_hashfn(struct nl_portid_hash *hash, u
 	return &hash->table[jhash_1word(portid, hash->rnd) & hash->mask];
 }
 
+int netlink_add_tap(struct netlink_tap *nt)
+{
+	if (unlikely(nt->dev->type != ARPHRD_NETLINK))
+		return -EINVAL;
+
+	spin_lock(&netlink_tap_lock);
+	list_add_rcu(&nt->list, &netlink_tap_all);
+	spin_unlock(&netlink_tap_lock);
+
+	if (nt->module)
+		__module_get(nt->module);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(netlink_add_tap);
+
+int __netlink_remove_tap(struct netlink_tap *nt)
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
+
+	return found ? 0 : -ENODEV;
+}
+EXPORT_SYMBOL_GPL(__netlink_remove_tap);
+
+int netlink_remove_tap(struct netlink_tap *nt)
+{
+	int ret;
+
+	ret = __netlink_remove_tap(nt);
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(netlink_remove_tap);
+
+static int __netlink_deliver_tap_skb(struct sk_buff *skb,
+				     struct net_device *dev)
+{
+	struct sk_buff *nskb;
+	int ret = -ENOMEM;
+
+	dev_hold(dev);
+	nskb = skb_clone(skb, GFP_ATOMIC);
+	if (nskb) {
+		nskb->dev = dev;
+		ret = dev_queue_xmit(nskb);
+		if (unlikely(ret > 0))
+			ret = net_xmit_errno(ret);
+	}
+
+	dev_put(dev);
+	return ret;
+}
+
+static void __netlink_deliver_tap(struct sk_buff *skb)
+{
+	int ret;
+	struct netlink_tap *tmp;
+
+	list_for_each_entry_rcu(tmp, &netlink_tap_all, list) {
+		ret = __netlink_deliver_tap_skb(skb, tmp->dev);
+		if (unlikely(ret))
+			break;
+	}
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
@@ -1518,6 +1616,8 @@ static int __netlink_sendskb(struct sock *sk, struct sk_buff *skb)
 {
 	int len = skb->len;
 
+	netlink_deliver_tap(skb);
+
 #ifdef CONFIG_NETLINK_MMAP
 	if (netlink_skb_is_mmaped(skb))
 		netlink_queue_mmaped_skb(sk, skb);
@@ -1578,6 +1678,11 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 
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
@@ -2975,6 +3080,8 @@ static int __init netlink_proto_init(void)
 		nl_table[i].compare = netlink_compare;
 	}
 
+	INIT_LIST_HEAD(&netlink_tap_all);
+
 	netlink_add_usersock_entry();
 
 	sock_register(&netlink_family_ops);
-- 
1.7.11.7
