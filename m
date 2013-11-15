From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] genetlink: unify registration functions
Date: Fri, 15 Nov 2013 14:19:08 +0100
Message-ID: <1384521548-13241-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:53010 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018Ab3KONTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 08:19:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Now that the ops assignment is just two variables rather than a
long list iteration etc., there's no reason to separately export
__genl_register_family() and __genl_register_family_with_ops().

Unify the two functions into __genl_register_family() and make
genl_register_family_with_ops() call it after assigning the ops.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h | 28 ++++++++++++++++++++++----
 net/netlink/genetlink.c | 53 +++++++++++++++----------------------------------
 2 files changed, 40 insertions(+), 41 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 0b6a144..e96385d 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -131,14 +131,34 @@ static inline int genl_register_family(struct genl_family *family)
 	return __genl_register_family(family);
 }
 
-int __genl_register_family_with_ops(struct genl_family *family,
-				    const struct genl_ops *ops, size_t n_ops);
-
+/**
+ * genl_register_family_with_ops - register a generic netlink family with ops
+ * @family: generic netlink family
+ * @ops: operations to be registered
+ * @n_ops: number of elements to register
+ *
+ * Registers the specified family and operations from the specified table.
+ * Only one family may be registered with the same family name or identifier.
+ *
+ * The family id may equal GENL_ID_GENERATE causing an unique id to
+ * be automatically generated and assigned.
+ *
+ * Either a doit or dumpit callback must be specified for every registered
+ * operation or the function will fail. Only one operation structure per
+ * command identifier may be registered.
+ *
+ * See include/net/genetlink.h for more documenation on the operations
+ * structure.
+ *
+ * Return 0 on success or a negative error code.
+ */
 static inline int genl_register_family_with_ops(struct genl_family *family,
 	const struct genl_ops *ops, size_t n_ops)
 {
 	family->module = THIS_MODULE;
-	return __genl_register_family_with_ops(family, ops, n_ops);
+	family->ops = ops;
+	family->n_ops = n_ops;
+	return __genl_register_family(family);
 }
 
 int genl_unregister_family(struct genl_family *family);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index a7c62d3..f07eb56 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -283,12 +283,18 @@ static void genl_unregister_mc_groups(struct genl_family *family)
 		__genl_unregister_mc_group(family, grp);
 }
 
-static int genl_validate_add_ops(struct genl_family *family,
-				 const struct genl_ops *ops,
-				 unsigned int n_ops)
+static int genl_validate_ops(struct genl_family *family)
 {
+	const struct genl_ops *ops = family->ops;
+	unsigned int n_ops = family->n_ops;
 	int i, j;
 
+	if (WARN_ON(n_ops && !ops))
+		return -EINVAL;
+
+	if (!n_ops)
+		return 0;
+
 	for (i = 0; i < n_ops; i++) {
 		if (ops[i].dumpit == NULL && ops[i].doit == NULL)
 			return -EINVAL;
@@ -313,6 +319,9 @@ static int genl_validate_add_ops(struct genl_family *family,
  * The family id may equal GENL_ID_GENERATE causing an unique id to
  * be automatically generated and assigned.
  *
+ * The family's ops array must already be assigned, you can use the
+ * genl_register_family_with_ops() helper function.
+ *
  * Return 0 on success or a negative error code.
  */
 int __genl_register_family(struct genl_family *family)
@@ -325,6 +334,10 @@ int __genl_register_family(struct genl_family *family)
 	if (family->id > GENL_MAX_ID)
 		goto errout;
 
+	err = genl_validate_ops(family);
+	if (err)
+		return err;
+
 	INIT_LIST_HEAD(&family->mcast_groups);
 
 	genl_lock_all();
@@ -373,40 +386,6 @@ errout:
 EXPORT_SYMBOL(__genl_register_family);
 
 /**
- * __genl_register_family_with_ops - register a generic netlink family
- * @family: generic netlink family
- * @ops: operations to be registered
- * @n_ops: number of elements to register
- *
- * Registers the specified family and operations from the specified table.
- * Only one family may be registered with the same family name or identifier.
- *
- * The family id may equal GENL_ID_GENERATE causing an unique id to
- * be automatically generated and assigned.
- *
- * Either a doit or dumpit callback must be specified for every registered
- * operation or the function will fail. Only one operation structure per
- * command identifier may be registered.
- *
- * See include/net/genetlink.h for more documenation on the operations
- * structure.
- *
- * Return 0 on success or a negative error code.
- */
-int __genl_register_family_with_ops(struct genl_family *family,
-	const struct genl_ops *ops, size_t n_ops)
-{
-	int err;
-
-	err = genl_validate_add_ops(family, ops, n_ops);
-	if (err)
-		return err;
-
-	return __genl_register_family(family);
-}
-EXPORT_SYMBOL(__genl_register_family_with_ops);
-
-/**
  * genl_unregister_family - unregister generic netlink family
  * @family: generic netlink family
  *
-- 
1.8.4.rc3
