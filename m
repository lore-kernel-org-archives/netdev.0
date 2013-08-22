From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 2/2] genl: Hold reference on correct module while netlink-dump.
Date: Wed, 21 Aug 2013 20:58:12 -0700
Message-ID: <1377143892-20763-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:40611 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752790Ab3HVD6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 23:58:15 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so1238465pbc.36
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 20:58:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netlink dump operations take module as parameter to hold
reference for entire netlink dump duration.
Currently it holds ref only on genl module which is not correct
when we use ops registered to genl from another module.
Following patch adds module pointer to genl_ops so that netlink
can hold ref count on it.

CC: Jesse Gross <jesse@nicira.com>
CC: Johannes Berg <johannes.berg@intel.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/genetlink.h |   21 ++++++++++++++++++---
 net/netlink/genetlink.c |   39 ++++++++++++++++++++++++---------------
 2 files changed, 42 insertions(+), 18 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 93024a4..7f57b2c 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -119,13 +119,28 @@ struct genl_ops {
 					 struct netlink_callback *cb);
 	int		       (*done)(struct netlink_callback *cb);
 	struct list_head	ops_list;
+	struct module		*module;
 };
 
 extern int genl_register_family(struct genl_family *family);
-extern int genl_register_family_with_ops(struct genl_family *family,
-	struct genl_ops *ops, size_t n_ops);
+
+extern int __genl_register_family_with_ops(struct genl_family *family,
+	struct genl_ops *ops, size_t n_ops, struct module *module);
+
+static inline int genl_register_family_with_ops(struct genl_family *family,
+	struct genl_ops *ops, size_t n_ops)
+{
+	return __genl_register_family_with_ops(family, ops, n_ops, THIS_MODULE);
+}
+
 extern int genl_unregister_family(struct genl_family *family);
-extern int genl_register_ops(struct genl_family *, struct genl_ops *ops);
+extern int __genl_register_ops(struct genl_family *f, struct genl_ops *ops,
+			       struct module *module);
+static inline int genl_register_ops(struct genl_family *f, struct genl_ops *ops)
+{
+	return __genl_register_ops(f, ops, THIS_MODULE);
+}
+
 extern int genl_unregister_ops(struct genl_family *, struct genl_ops *ops);
 extern int genl_register_mc_group(struct genl_family *family,
 				  struct genl_multicast_group *grp);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 3669039..23430c7 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -284,7 +284,7 @@ static void genl_unregister_mc_groups(struct genl_family *family)
 }
 
 /**
- * genl_register_ops - register generic netlink operations
+ * __genl_register_ops - register generic netlink operations
  * @family: generic netlink family
  * @ops: operations to be registered
  *
@@ -298,7 +298,8 @@ static void genl_unregister_mc_groups(struct genl_family *family)
  *
  * Returns 0 on success or a negative error code.
  */
-int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
+int __genl_register_ops(struct genl_family *family, struct genl_ops *ops,
+			struct module *module)
 {
 	int err = -EINVAL;
 
@@ -317,6 +318,7 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 	if (ops->policy)
 		ops->flags |= GENL_CMD_CAP_HASPOL;
 
+	ops->module = module;
 	genl_lock_all();
 	list_add_tail(&ops->ops_list, &family->ops_list);
 	genl_unlock_all();
@@ -326,7 +328,7 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 errout:
 	return err;
 }
-EXPORT_SYMBOL(genl_register_ops);
+EXPORT_SYMBOL(__genl_register_ops);
 
 /**
  * genl_unregister_ops - unregister generic netlink operations
@@ -433,7 +435,7 @@ errout:
 EXPORT_SYMBOL(genl_register_family);
 
 /**
- * genl_register_family_with_ops - register a generic netlink family
+ * __genl_register_family_with_ops - register a generic netlink family
  * @family: generic netlink family
  * @ops: operations to be registered
  * @n_ops: number of elements to register
@@ -457,8 +459,8 @@ EXPORT_SYMBOL(genl_register_family);
  *
  * Return 0 on success or a negative error code.
  */
-int genl_register_family_with_ops(struct genl_family *family,
-	struct genl_ops *ops, size_t n_ops)
+int __genl_register_family_with_ops(struct genl_family *family,
+	struct genl_ops *ops, size_t n_ops, struct module *module)
 {
 	int err, i;
 
@@ -467,7 +469,7 @@ int genl_register_family_with_ops(struct genl_family *family,
 		return err;
 
 	for (i = 0; i < n_ops; ++i, ++ops) {
-		err = genl_register_ops(family, ops);
+		err = __genl_register_ops(family, ops, module);
 		if (err)
 			goto err_out;
 	}
@@ -476,7 +478,7 @@ err_out:
 	genl_unregister_family(family);
 	return err;
 }
-EXPORT_SYMBOL(genl_register_family_with_ops);
+EXPORT_SYMBOL(__genl_register_family_with_ops);
 
 /**
  * genl_unregister_family - unregister generic netlink family
@@ -558,11 +560,14 @@ static int genl_lock_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 static int genl_lock_done(struct netlink_callback *cb)
 {
 	struct genl_ops *ops = cb->data;
-	int rc;
+	int rc = 0;
 
-	genl_lock();
-	rc = ops->done(cb);
-	genl_unlock();
+	if (ops->done) {
+		genl_lock();
+		rc = ops->done(cb);
+		genl_unlock();
+	}
+	module_put(ops->module);
 	return rc;
 }
 
@@ -605,14 +610,18 @@ static int genl_family_rcv_msg(struct genl_family *family,
 			genl_unlock();
 			c.data = ops;
 			c.dump = genl_lock_dumpit;
-			if (ops->done)
-				c.done = genl_lock_done;
+			c.done = genl_lock_done;
+			c.module = THIS_MODULE;
+
+			if (!try_module_get(ops->module))
+				return -EPROTONOSUPPORT;
 		} else {
 			c.dump = ops->dumpit;
 			c.done = ops->done;
+			c.module = ops->module;
 		}
 
-		rc = netlink_dump_start(net->genl_sock, skb, nlh, &c);
+		rc = __netlink_dump_start(net->genl_sock, skb, nlh, &c);
 		if (!family->parallel_ops)
 			genl_lock();
 		return rc;
-- 
1.7.1
