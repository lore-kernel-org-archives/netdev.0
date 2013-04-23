From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next v3 1/2] genl: Allow concurrent genl
	callbacks.
Date: Tue, 23 Apr 2013 10:48:30 -0700
Message-ID: <1366739310-18146-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

All genl callbacks are serialized by genl-mutex. This can become
bottleneck in multi threaded case.
Following patch adds an parameter to genl_family so that a
particular family can get concurrent netlink callback without
genl_lock held.
New rw-sem is used to protect genl callback from genl family unregister.
in case of parallel_ops genl-family read-lock is taken for callbacks and
write lock is taken for register or unregistration for any family.
In case of locked genl family semaphore and gel-mutex is locked for
any openration.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
v2-v3:
 - rename lockless flag to parallel_ops
 - simplified genl-dump locking.
v1-v2:
 - No change.
---
 include/net/genetlink.h |    1 +
 net/netlink/genetlink.c |  114 +++++++++++++++++++++++++++++++----------------
 2 files changed, 77 insertions(+), 38 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index bdfbe68..93024a4 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -50,6 +50,7 @@ struct genl_family {
 	unsigned int		version;
 	unsigned int		maxattr;
 	bool			netnsok;
+	bool			parallel_ops;
 	int			(*pre_doit)(struct genl_ops *ops,
 					    struct sk_buff *skb,
 					    struct genl_info *info);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 5a55be3..2f72598 100644
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
+	if (family->maxattr && !family->parallel_ops) {
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
@@ -530,19 +544,17 @@ void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
 }
 EXPORT_SYMBOL(genlmsg_put);
 
-static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
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
@@ -560,26 +572,30 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EPERM;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = ops->dumpit,
+			.done = ops->done,
+		};
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
-		}
-		genl_lock();
-		return err;
+		return netlink_dump_start(net->genl_sock, skb, nlh, &c);
 	}
 
 	if (ops->doit == NULL)
 		return -EOPNOTSUPP;
 
-	if (family->attrbuf) {
-		err = nlmsg_parse(nlh, hdrlen, family->attrbuf, family->maxattr,
+	if (family->maxattr && family->parallel_ops) {
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
@@ -590,7 +606,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	info.nlhdr = nlh;
 	info.genlhdr = nlmsg_data(nlh);
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
-	info.attrs = family->attrbuf;
+	info.attrs = attrbuf;
 	genl_info_net_set(&info, net);
 	memset(&info.user_ptr, 0, sizeof(info.user_ptr));
 
@@ -605,14 +621,37 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (family->post_doit)
 		family->post_doit(ops, skb, &info);
 
+	if (family->parallel_ops)
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
+	if (!family->parallel_ops)
+		genl_lock();
+
+	err = genl_family_rcv_msg(family, skb, nlh);
+
+	if (!family->parallel_ops)
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
@@ -918,7 +957,6 @@ static int __net_init genl_pernet_init(struct net *net)
 {
 	struct netlink_kernel_cfg cfg = {
 		.input		= genl_rcv,
-		.cb_mutex	= &genl_mutex,
 		.flags		= NL_CFG_F_NONROOT_RECV,
 	};
 
-- 
1.7.1
