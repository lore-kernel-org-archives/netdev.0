From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] genetlink: don't allow unloading families while dumping
Date: Thu, 22 Aug 2013 09:21:49 +0200
Message-ID: <1377156109-7331-1-git-send-email-johannes@sipsolutions.net>
Cc: Pravin Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:33991 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab3HVHVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 03:21:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The netlink code will prevent unloading of a module while
the module is dumping, to prevent the dump() callback from
going away and crashing in the next call. However, generic
netlink just points to its family's dumpit call, which can
be in a different module, without pointing to that module.

Add a struct module pointer to generic netlink families and
pass the pointer to netlink_dump_start().

TODO: move/adjust the documentation

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h | 21 +++++++++++++++++++--
 net/netlink/genetlink.c | 10 +++++-----
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 93024a4..0bc3a53 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -42,6 +42,7 @@ struct genl_info;
  * @ops_list: list of all assigned operations
  * @family_list: family list
  * @mcast_groups: multicast groups list
+ * @module: the module containing this family
  */
 struct genl_family {
 	unsigned int		id;
@@ -61,6 +62,7 @@ struct genl_family {
 	struct list_head	ops_list;	/* private */
 	struct list_head	family_list;	/* private */
 	struct list_head	mcast_groups;	/* private */
+	struct module *		module;		/* private */
 };
 
 /**
@@ -121,9 +123,24 @@ struct genl_ops {
 	struct list_head	ops_list;
 };
 
-extern int genl_register_family(struct genl_family *family);
-extern int genl_register_family_with_ops(struct genl_family *family,
+extern int __genl_register_family(struct genl_family *family);
+extern int __genl_register_family_with_ops(struct genl_family *family,
 	struct genl_ops *ops, size_t n_ops);
+
+static inline int genl_register_family(struct genl_family *family)
+{
+	family->module = THIS_MODULE;
+	return __genl_register_family(family);
+}
+
+static inline int genl_register_family_with_ops(struct genl_family *family,
+						struct genl_ops *ops,
+						size_t n_ops)
+{
+	family->module = THIS_MODULE;
+	return __genl_register_family_with_ops(family, ops, n_ops);
+}
+
 extern int genl_unregister_family(struct genl_family *family);
 extern int genl_register_ops(struct genl_family *, struct genl_ops *ops);
 extern int genl_unregister_ops(struct genl_family *, struct genl_ops *ops);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2fd6dbe..8bab493 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -374,7 +374,7 @@ EXPORT_SYMBOL(genl_unregister_ops);
  *
  * Return 0 on success or a negative error code.
  */
-int genl_register_family(struct genl_family *family)
+int __genl_register_family(struct genl_family *family)
 {
 	int err = -EINVAL;
 
@@ -430,7 +430,7 @@ errout_locked:
 errout:
 	return err;
 }
-EXPORT_SYMBOL(genl_register_family);
+EXPORT_SYMBOL(__genl_register_family);
 
 /**
  * genl_register_family_with_ops - register a generic netlink family
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
-- 
1.8.4.rc2
