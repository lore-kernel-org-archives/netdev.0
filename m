From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [patch v4 1/2] netlink: add reference of module in netlink_dump_start
Date: Fri, 5 Oct 2012 14:15:48 +0800
Message-ID: <1349417749-24869-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
	pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	jengelh-9+2X+4sQBs8@public.gmane.org, Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I get a panic when I use ss -a and rmmod inet_diag at the
same time.

it's because netlink_dump use inet_diag_dump witch function
belongs to module inet_diag.

I search the codes and find many modules have the same problem.
We need add reference of the module which the cb->dump belongs
to.

Thanks for all help from Stephen,Jan,Eric,Steffen and Pablo.

Change From v3:
change netlink_dump_start to inline,suggestion from Pablo and
Eric.

Change From v2:
delete netlink_dump_done,and call module_put in netlink_dump
and netlink_sock_destruct.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/netlink.h  |   20 ++++++++++++++++----
 net/netlink/af_netlink.c |   29 +++++++++++++++++++++--------
 2 files changed, 37 insertions(+), 12 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index f80c56a..6d3af05 100644
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
@@ -262,14 +264,24 @@ __nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int fla
 
 struct netlink_dump_control {
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *);
-	int (*done)(struct netlink_callback*);
+	int (*done)(struct netlink_callback *);
 	void *data;
+	struct module *module;
 	u16 min_dump_alloc;
 };
 
-extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
-			      const struct nlmsghdr *nlh,
-			      struct netlink_dump_control *control);
+extern int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
+				const struct nlmsghdr *nlh,
+				struct netlink_dump_control *control);
+static inline int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
+				     const struct nlmsghdr *nlh,
+				     struct netlink_dump_control *control)
+{
+	if (!control->module)
+		control->module = THIS_MODULE;
+
+	return __netlink_dump_start(ssk, skb, nlh, control);
+}
 
 #endif /* __KERNEL__ */
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 0f2e3ad..01e944a 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -169,6 +169,8 @@ static void netlink_sock_destruct(struct sock *sk)
 	if (nlk->cb) {
 		if (nlk->cb->done)
 			nlk->cb->done(nlk->cb);
+
+		module_put(nlk->cb->module);
 		netlink_destroy_callback(nlk->cb);
 	}
 
@@ -1758,6 +1760,7 @@ static int netlink_dump(struct sock *sk)
 	nlk->cb = NULL;
 	mutex_unlock(nlk->cb_mutex);
 
+	module_put(cb->module);
 	netlink_consume_callback(cb);
 	return 0;
 
@@ -1767,9 +1770,9 @@ errout_skb:
 	return err;
 }
 
-int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
-		       const struct nlmsghdr *nlh,
-		       struct netlink_dump_control *control)
+int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
+			 const struct nlmsghdr *nlh,
+			 struct netlink_dump_control *control)
 {
 	struct netlink_callback *cb;
 	struct sock *sk;
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
+	/* add reference of module which cb->dump belongs to */
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
@@ -1817,7 +1830,7 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	 */
 	return -EINTR;
 }
-EXPORT_SYMBOL(netlink_dump_start);
+EXPORT_SYMBOL(__netlink_dump_start);
 
 void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 {
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
