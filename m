From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v3 2/2] genl: Hold reference on correct module while netlink-dump.
Date: Fri, 23 Aug 2013 12:45:04 -0700
Message-ID: <1377287104-13297-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:59448 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754170Ab3HWTpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 15:45:07 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb10so1066193pad.9
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 12:45:07 -0700 (PDT)
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
v2-v3:
get rid of extra argument (struct module *).
v1-v2:
No need to ref count genl module.
---
 include/net/genetlink.h |   20 ++++++++++++++++++--
 net/netlink/genetlink.c |   20 +++++++++++---------
 2 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 93024a4..8e0b6c8 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -61,6 +61,7 @@ struct genl_family {
 	struct list_head	ops_list;	/* private */
 	struct list_head	family_list;	/* private */
 	struct list_head	mcast_groups;	/* private */
+	struct module		*module;
 };
 
 /**
@@ -121,9 +122,24 @@ struct genl_ops {
 	struct list_head	ops_list;
 };
 
-extern int genl_register_family(struct genl_family *family);
-extern int genl_register_family_with_ops(struct genl_family *family,
+extern int __genl_register_family(struct genl_family *family);
+
+static inline int genl_register_family(struct genl_family *family)
+{
+	family->module = THIS_MODULE;
+	return __genl_register_family(family);
+}
+
+extern int __genl_register_family_with_ops(struct genl_family *family,
 	struct genl_ops *ops, size_t n_ops);
+
+static inline int genl_register_family_with_ops(struct genl_family *family,
+	struct genl_ops *ops, size_t n_ops)
+{
+	family->module = THIS_MODULE;
+	return __genl_register_family_with_ops(family, ops, n_ops);
+}
+
 extern int genl_unregister_family(struct genl_family *family);
 extern int genl_register_ops(struct genl_family *, struct genl_ops *ops);
 extern int genl_unregister_ops(struct genl_family *, struct genl_ops *ops);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f09d387..f1c81d5 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -364,7 +364,7 @@ int genl_unregister_ops(struct genl_family *family, struct genl_ops *ops)
 EXPORT_SYMBOL(genl_unregister_ops);
 
 /**
- * genl_register_family - register a generic netlink family
+ * __genl_register_family - register a generic netlink family
  * @family: generic netlink family
  *
  * Registers the specified family after validating it first. Only one
@@ -374,7 +374,7 @@ EXPORT_SYMBOL(genl_unregister_ops);
  *
  * Return 0 on success or a negative error code.
  */
-int genl_register_family(struct genl_family *family)
+int __genl_register_family(struct genl_family *family)
 {
 	int err = -EINVAL;
 
@@ -430,10 +430,10 @@ errout_locked:
 errout:
 	return err;
 }
-EXPORT_SYMBOL(genl_register_family);
+EXPORT_SYMBOL(__genl_register_family);
 
 /**
- * genl_register_family_with_ops - register a generic netlink family
+ * __genl_register_family_with_ops - register a generic netlink family
  * @family: generic netlink family
  * @ops: operations to be registered
  * @n_ops: number of elements to register
@@ -457,12 +457,12 @@ EXPORT_SYMBOL(genl_register_family);
  *
  * Return 0 on success or a negative error code.
  */
-int genl_register_family_with_ops(struct genl_family *family,
+int __genl_register_family_with_ops(struct genl_family *family,
 	struct genl_ops *ops, size_t n_ops)
 {
 	int err, i;
 
-	err = genl_register_family(family);
+	err = __genl_register_family(family);
 	if (err)
 		return err;
 
@@ -476,7 +476,7 @@ err_out:
 	genl_unregister_family(family);
 	return err;
 }
-EXPORT_SYMBOL(genl_register_family_with_ops);
+EXPORT_SYMBOL(__genl_register_family_with_ops);
 
 /**
  * genl_unregister_family - unregister generic netlink family
@@ -603,22 +603,24 @@ static int genl_family_rcv_msg(struct genl_family *family,
 
 		if (!family->parallel_ops) {
 			struct netlink_dump_control c = {
+				.module = family->module,
 				.data = ops,
 				.dump = genl_lock_dumpit,
 				.done = genl_lock_done,
 			};
 
 			genl_unlock();
-			rc = netlink_dump_start(net->genl_sock, skb, nlh, &c);
+			rc = __netlink_dump_start(net->genl_sock, skb, nlh, &c);
 			genl_lock();
 
 		} else {
 			struct netlink_dump_control c = {
+				.module = family->module,
 				.dump = ops->dumpit,
 				.done = ops->done,
 			};
 
-			rc = netlink_dump_start(net->genl_sock, skb, nlh, &c);
+			rc = __netlink_dump_start(net->genl_sock, skb, nlh, &c);
 		}
 
 		return rc;
-- 
1.7.1
