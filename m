From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [patch v3 01/11] netlink: add reference of module in netlink_dump_start
Date: Thu, 4 Oct 2012 12:41:19 +0800
Message-ID: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	pablo@netfilter.org, stephen.hemminger@vyatta.com, jengelh@inai.de,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I get a panic when I use ss -a and rmmod inet_diag at the
same time.

it's because netlink_dump use inet_diag_dump witch function
belongs to module inet_diag.

I search the codes and find many modules have the same problem.
We need add reference of the module witch the cb->dump belongs
to.

Thanks for all help from Stephen,Jan,Eric,Steffen and Pablo.

Change From v2:

delete netlink_dump_done,and call module_put in netlink_dump
and netlink_sock_destruct.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/linux/netlink.h  |    5 ++++-
 net/netlink/af_netlink.c |   21 +++++++++++++++++----
 2 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index f80c56a..bf4e501 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -245,6 +245,8 @@ struct netlink_callback {
 					struct netlink_callback *cb);
 	int			(*done)(struct netlink_callback *cb);
 	void			*data;
+	/* the module that dump function belong to */
+	struct module		*module;
 	u16			family;
 	u16			min_dump_alloc;
 	unsigned int		prev_seq, seq;
@@ -262,8 +264,9 @@ __nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int fla
 
 struct netlink_dump_control {
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *);
-	int (*done)(struct netlink_callback*);
+	int (*done)(struct netlink_callback *);
 	void *data;
+	struct module *module;
 	u16 min_dump_alloc;
 };
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 0f2e3ad..0905dfb 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -169,6 +169,7 @@ static void netlink_sock_destruct(struct sock *sk)
 	if (nlk->cb) {
 		if (nlk->cb->done)
 			nlk->cb->done(nlk->cb);
+		module_put(nlk->cb->module);
 		netlink_destroy_callback(nlk->cb);
 	}
 
@@ -1755,6 +1756,8 @@ static int netlink_dump(struct sock *sk)
 
 	if (cb->done)
 		cb->done(cb);
+
+	module_put(cb->module);
 	nlk->cb = NULL;
 	mutex_unlock(nlk->cb_mutex);
 
@@ -1784,6 +1787,7 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	cb->done = control->done;
 	cb->nlh = nlh;
 	cb->data = control->data;
+	cb->module = control->module;
 	cb->min_dump_alloc = control->min_dump_alloc;
 	atomic_inc(&skb->users);
 	cb->skb = skb;
@@ -1794,19 +1798,28 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
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
 	}
+	/* add reference of module witch cb->dump belong to */
+	if (!try_module_get(cb->module)) {
+		mutex_unlock(nlk->cb_mutex);
+		netlink_destroy_callback(cb);
+		ret = -EPROTONOSUPPORT;
+		goto out;
+	}
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

