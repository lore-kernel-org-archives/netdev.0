From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/2] genl: Allow concurrent genl callbacks.
Date: Thu, 18 Apr 2013 14:22:19 -0700
Message-ID: <1366320139-16768-1-git-send-email-pshelar@nicira.com>
Cc: dev@openvswitch.org, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:32773 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751153Ab3DRVWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 17:22:34 -0400
Received: by mail-ob0-f200.google.com with SMTP id x4so5901573obh.7
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 14:22:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All genl callbacks are serialized by genl-mutex. This can become
bottleneck in multi threaded case.
Following patch adds an parameter to genl_family so that a
particular family can get concurrent netlink callback without
genl_lock held.
New rw-sem is used to protect genl callback from genl family unregister.
in case of lockless genl-family read-lock is taken for callbacks and
write lock is taken for register or unregistration for any family.
In case of locked genl family semaphore and gel-mutex is locked for
any openration.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/genetlink.h |    1 +
 net/netlink/genetlink.c |  168 +++++++++++++++++++++++++++++++++++++----------
 2 files changed, 133 insertions(+), 36 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index bdfbe68..144e3f4 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -50,6 +50,7 @@ struct genl_family {
 	unsigned int		version;
 	unsigned int		maxattr;
 	bool			netnsok;
+	bool			lockless;
 	int			(*pre_doit)(struct genl_ops *ops,
 					    struct sk_buff *skb,
 					    struct genl_info *info);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 5a55be3..23361b2 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -16,10 +16,12 @@
 #include <linux/skbuff.h>
 #include <linux/mutex.h>
 #include <linux/bitmap.h>
+#include <linux/rwsem.h>
 #include <net/sock.h>
 #include <net/genetlink.h>
 
 static DEFINE_MUTEX(genl_mutex); /* serialization of message processing */
+static DECLARE_RWSEM(cb_lock);
 
 void genl_lock(void)
 {
@@ -41,6 +43,18 @@ int lockdep_genl_is_held(void)
 EXPORT_SYMBOL(lockdep_genl_is_held);
 #endif
 
+static void genl_lock_all(void)
+{
+	down_write(&cb_lock);
+	genl_lock();
+}
+
+static void genl_unlock_all(void)
+{
+	genl_unlock();
+	up_write(&cb_lock);
+}
+
 #define GENL_FAM_TAB_SIZE	16
 #define GENL_FAM_TAB_MASK	(GENL_FAM_TAB_SIZE - 1)
 
@@ -144,7 +158,7 @@ int genl_register_mc_group(struct genl_family *family,
 	BUG_ON(grp->name[0] == '\0');
 	BUG_ON(memchr(grp->name, '\0', GENL_NAMSIZ) == NULL);
 
-	genl_lock();
+	genl_lock_all();
 
 	/* special-case our own group */
 	if (grp == &notify_grp)
@@ -213,7 +227,7 @@ int genl_register_mc_group(struct genl_family *family,
 
 	genl_ctrl_event(CTRL_CMD_NEWMCAST_GRP, grp);
  out:
-	genl_unlock();
+	genl_unlock_all();
 	return err;
 }
 EXPORT_SYMBOL(genl_register_mc_group);
@@ -255,9 +269,9 @@ static void __genl_unregister_mc_group(struct genl_family *family,
 void genl_unregister_mc_group(struct genl_family *family,
 			      struct genl_multicast_group *grp)
 {
-	genl_lock();
+	genl_lock_all();
 	__genl_unregister_mc_group(family, grp);
-	genl_unlock();
+	genl_unlock_all();
 }
 EXPORT_SYMBOL(genl_unregister_mc_group);
 
@@ -303,9 +317,9 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 	if (ops->policy)
 		ops->flags |= GENL_CMD_CAP_HASPOL;
 
-	genl_lock();
+	genl_lock_all();
 	list_add_tail(&ops->ops_list, &family->ops_list);
-	genl_unlock();
+	genl_unlock_all();
 
 	genl_ctrl_event(CTRL_CMD_NEWOPS, ops);
 	err = 0;
@@ -334,16 +348,16 @@ int genl_unregister_ops(struct genl_family *family, struct genl_ops *ops)
 {
 	struct genl_ops *rc;
 
-	genl_lock();
+	genl_lock_all();
 	list_for_each_entry(rc, &family->ops_list, ops_list) {
 		if (rc == ops) {
 			list_del(&ops->ops_list);
-			genl_unlock();
+			genl_unlock_all();
 			genl_ctrl_event(CTRL_CMD_DELOPS, ops);
 			return 0;
 		}
 	}
-	genl_unlock();
+	genl_unlock_all();
 
 	return -ENOENT;
 }
@@ -373,7 +387,7 @@ int genl_register_family(struct genl_family *family)
 	INIT_LIST_HEAD(&family->ops_list);
 	INIT_LIST_HEAD(&family->mcast_groups);
 
-	genl_lock();
+	genl_lock_all();
 
 	if (genl_family_find_byname(family->name)) {
 		err = -EEXIST;
@@ -394,7 +408,7 @@ int genl_register_family(struct genl_family *family)
 		goto errout_locked;
 	}
 
-	if (family->maxattr) {
+	if (family->maxattr && !family->lockless) {
 		family->attrbuf = kmalloc((family->maxattr+1) *
 					sizeof(struct nlattr *), GFP_KERNEL);
 		if (family->attrbuf == NULL) {
@@ -405,14 +419,14 @@ int genl_register_family(struct genl_family *family)
 		family->attrbuf = NULL;
 
 	list_add_tail(&family->family_list, genl_family_chain(family->id));
-	genl_unlock();
+	genl_unlock_all();
 
 	genl_ctrl_event(CTRL_CMD_NEWFAMILY, family);
 
 	return 0;
 
 errout_locked:
-	genl_unlock();
+	genl_unlock_all();
 errout:
 	return err;
 }
@@ -476,7 +490,7 @@ int genl_unregister_family(struct genl_family *family)
 {
 	struct genl_family *rc;
 
-	genl_lock();
+	genl_lock_all();
 
 	genl_unregister_mc_groups(family);
 
@@ -486,14 +500,14 @@ int genl_unregister_family(struct genl_family *family)
 
 		list_del(&rc->family_list);
 		INIT_LIST_HEAD(&family->ops_list);
-		genl_unlock();
+		genl_unlock_all();
 
 		kfree(family->attrbuf);
 		genl_ctrl_event(CTRL_CMD_DELFAMILY, family);
 		return 0;
 	}
 
-	genl_unlock();
+	genl_unlock_all();
 
 	return -ENOENT;
 }
@@ -530,19 +544,53 @@ void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
 }
 EXPORT_SYMBOL(genlmsg_put);
 
-static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int __genl_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct genl_ops *ops = cb->data;
+
+	return ops->dumpit(skb, cb);
+}
+
+static int __genl_done(struct netlink_callback *cb)
+{
+	struct genl_ops *ops = cb->data;
+
+	return ops->done(cb);
+}
+
+static int genl_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int ret;
+
+	genl_lock();
+	ret = __genl_dump(skb, cb);
+	genl_unlock();
+
+	return ret;
+}
+
+static int genl_done(struct netlink_callback *cb)
+{
+	int ret;
+
+	genl_lock();
+	ret = __genl_done(cb);
+	genl_unlock();
+
+	return ret;
+}
+
+static int genl_family_rcv_msg(struct genl_family *family,
+			       struct sk_buff *skb,
+			       struct nlmsghdr *nlh)
 {
 	struct genl_ops *ops;
-	struct genl_family *family;
 	struct net *net = sock_net(skb->sk);
 	struct genl_info info;
 	struct genlmsghdr *hdr = nlmsg_data(nlh);
+	struct nlattr **attrbuf;
 	int hdrlen, err;
 
-	family = genl_family_find_byid(nlh->nlmsg_type);
-	if (family == NULL)
-		return -ENOENT;
-
 	/* this family doesn't exist in this netns */
 	if (!family->netnsok && !net_eq(net, &init_net))
 		return -ENOENT;
@@ -560,26 +608,52 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EPERM;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c;
+
 		if (ops->dumpit == NULL)
 			return -EOPNOTSUPP;
 
-		genl_unlock();
-		{
-			struct netlink_dump_control c = {
-				.dump = ops->dumpit,
-				.done = ops->done,
-			};
-			err = netlink_dump_start(net->genl_sock, skb, nlh, &c);
+		if (family->lockless) {
+			c.dump = __genl_dump;
+			if (ops->done)
+				c.done = __genl_done;
+			else
+				c.done = NULL;
+		} else {
+			c.dump = genl_dump;
+			if (ops->done)
+				c.done = genl_done;
+			else
+				c.done = NULL;
 		}
-		genl_lock();
+		c.min_dump_alloc = 0;
+		c.data = ops;
+		c.module = THIS_MODULE;
+
+		if (!family->lockless)
+			genl_unlock();
+
+		err = netlink_dump_start(net->genl_sock, skb, nlh, &c);
+
+		if (!family->lockless)
+			genl_lock();
+
 		return err;
 	}
 
 	if (ops->doit == NULL)
 		return -EOPNOTSUPP;
 
-	if (family->attrbuf) {
-		err = nlmsg_parse(nlh, hdrlen, family->attrbuf, family->maxattr,
+	if (family->maxattr && family->lockless) {
+		attrbuf = kmalloc((family->maxattr+1) *
+					sizeof(struct nlattr *), GFP_KERNEL);
+		if (attrbuf == NULL)
+			return -ENOMEM;
+	} else
+		attrbuf = family->attrbuf;
+
+	if (attrbuf) {
+		err = nlmsg_parse(nlh, hdrlen, attrbuf, family->maxattr,
 				  ops->policy);
 		if (err < 0)
 			return err;
@@ -590,7 +664,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	info.nlhdr = nlh;
 	info.genlhdr = nlmsg_data(nlh);
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
-	info.attrs = family->attrbuf;
+	info.attrs = attrbuf;
 	genl_info_net_set(&info, net);
 	memset(&info.user_ptr, 0, sizeof(info.user_ptr));
 
@@ -605,14 +679,37 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (family->post_doit)
 		family->post_doit(ops, skb, &info);
 
+	if (family->lockless)
+		kfree(attrbuf);
+
+	return err;
+}
+
+static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	struct genl_family *family;
+	int err;
+
+	family = genl_family_find_byid(nlh->nlmsg_type);
+	if (family == NULL)
+		return -ENOENT;
+
+	if (!family->lockless)
+		genl_lock();
+
+	err = genl_family_rcv_msg(family, skb, nlh);
+
+	if (!family->lockless)
+		genl_unlock();
+
 	return err;
 }
 
 static void genl_rcv(struct sk_buff *skb)
 {
-	genl_lock();
+	down_read(&cb_lock);
 	netlink_rcv_skb(skb, &genl_rcv_msg);
-	genl_unlock();
+	up_read(&cb_lock);
 }
 
 /**************************************************************************
@@ -918,7 +1015,6 @@ static int __net_init genl_pernet_init(struct net *net)
 {
 	struct netlink_kernel_cfg cfg = {
 		.input		= genl_rcv,
-		.cb_mutex	= &genl_mutex,
 		.flags		= NL_CFG_F_NONROOT_RECV,
 	};
 
-- 
1.7.1
