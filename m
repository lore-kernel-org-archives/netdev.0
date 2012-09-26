From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [patch v2 01/11] netlink: add reference of module in netlink_dump_start
Date: Wed, 26 Sep 2012 16:41:18 +0800
Message-ID: <1348648888-24943-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	pablo@netfilter.org, stephen.hemminger@vyatta.com, jengelh@inai.de,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I get a panic when I use ss -a and rmmod inet_diag at the
same time.

it's because netlink_dump use inet_diag_dump witch function
belongs to module inet_diag.

I search the codes and find many modules have the same problem.
We need add reference of the module witch the cb->dump belongs
to.

Thanks for all help from Stephen,Jan,Eric and Steffen.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/linux/netlink.h  |    6 +++++-
 net/netlink/af_netlink.c |   25 +++++++++++++++++++++----
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index f74dd13..381f7d6 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -232,6 +232,8 @@ struct netlink_callback {
 					struct netlink_callback *cb);
 	int			(*done)(struct netlink_callback *cb);
 	void			*data;
+	/* the module that dump function belong to */
+	struct module		*module;
 	u16			family;
 	u16			min_dump_alloc;
 	unsigned int		prev_seq, seq;
@@ -249,11 +251,13 @@ __nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
 
 struct netlink_dump_control {
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *);
-	int (*done)(struct netlink_callback*);
+	int (*done)(struct netlink_callback *);
 	void *data;
+	struct module *module;
 	u16 min_dump_alloc;
 };
 
+extern int netlink_dump_done(struct netlink_callback *cb);
 extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 			      const struct nlmsghdr *nlh,
 			      struct netlink_dump_control *control);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5270238..3190dae 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1769,6 +1769,13 @@ errout_skb:
 	return err;
 }
 
+int netlink_dump_done(struct netlink_callback *cb)
+{
+	module_put(cb->module);
+	return 0;
+}
+EXPORT_SYMBOL(netlink_dump_done);
+
 int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 		       const struct nlmsghdr *nlh,
 		       struct netlink_dump_control *control)
@@ -1786,6 +1793,7 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	cb->done = control->done;
 	cb->nlh = nlh;
 	cb->data = control->data;
+	cb->module = control->module;
 	cb->min_dump_alloc = control->min_dump_alloc;
 	atomic_inc(&skb->users);
 	cb->skb = skb;
@@ -1796,19 +1804,28 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 		return -ECONNREFUSED;
 	}
 	nlk = nlk_sk(sk);
-	/* A dump is in progress... */
+
 	mutex_lock(nlk->cb_mutex);
+	/* A dump is in progress... */
 	if (nlk->cb) {
 		mutex_unlock(nlk->cb_mutex);
 		netlink_destroy_callback(cb);
-		sock_put(sk);
-		return -EBUSY;
+		ret = -EBUSY;
+		goto out;
+	}
+	/* add reference of module witch cb->dump belong to */
+	if (!try_module_get(cb->module)) {
+		mutex_unlock(nlk->cb_mutex);
+		netlink_destroy_callback(cb);
+		ret = -EPROTONOSUPPORT;
+		goto out;
 	}
+
 	nlk->cb = cb;
 	mutex_unlock(nlk->cb_mutex);
 
 	ret = netlink_dump(sk);
-
+out:
 	sock_put(sk);
 
 	if (ret)
-- 
1.7.7.6
