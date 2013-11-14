From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 5/9] genetlink: remove genl_register_ops/genl_unregister_ops
Date: Thu, 14 Nov 2013 17:14:43 +0100
Message-ID: <1384445687-30948-6-git-send-email-johannes@sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
 <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Cc: linux-wimax@intel.com, Balbir Singh <bsingharora@gmail.com>,
	netfilter-devel@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:49290 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754854Ab3KNQOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 11:14:55 -0500
In-Reply-To: <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

genl_register_ops() is still needed for internal registration,
but is no longer available to users of the API.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h |  2 --
 net/netlink/genetlink.c | 57 +------------------------------------------------
 2 files changed, 1 insertion(+), 58 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 9b787b6..617d718 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -141,8 +141,6 @@ static inline int genl_register_family_with_ops(struct genl_family *family,
 }
 
 int genl_unregister_family(struct genl_family *family);
-int genl_register_ops(struct genl_family *, struct genl_ops *ops);
-int genl_unregister_ops(struct genl_family *, struct genl_ops *ops);
 int genl_register_mc_group(struct genl_family *family,
 			   struct genl_multicast_group *grp);
 void genl_unregister_mc_group(struct genl_family *family,
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 0c741ce..fbccb45 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -283,22 +283,7 @@ static void genl_unregister_mc_groups(struct genl_family *family)
 		__genl_unregister_mc_group(family, grp);
 }
 
-/**
- * genl_register_ops - register generic netlink operations
- * @family: generic netlink family
- * @ops: operations to be registered
- *
- * Registers the specified operations and assigns them to the specified
- * family. Either a doit or dumpit callback must be specified or the
- * operation will fail. Only one operation structure per command
- * identifier may be registered.
- *
- * See include/net/genetlink.h for more documenation on the operations
- * structure.
- *
- * Returns 0 on success or a negative error code.
- */
-int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
+static int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 {
 	int err = -EINVAL;
 
@@ -326,42 +311,6 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 errout:
 	return err;
 }
-EXPORT_SYMBOL(genl_register_ops);
-
-/**
- * genl_unregister_ops - unregister generic netlink operations
- * @family: generic netlink family
- * @ops: operations to be unregistered
- *
- * Unregisters the specified operations and unassigns them from the
- * specified family. The operation blocks until the current message
- * processing has finished and doesn't start again until the
- * unregister process has finished.
- *
- * Note: It is not necessary to unregister all operations before
- *       unregistering the family, unregistering the family will cause
- *       all assigned operations to be unregistered automatically.
- *
- * Returns 0 on success or a negative error code.
- */
-int genl_unregister_ops(struct genl_family *family, struct genl_ops *ops)
-{
-	struct genl_ops *rc;
-
-	genl_lock_all();
-	list_for_each_entry(rc, &family->ops_list, ops_list) {
-		if (rc == ops) {
-			list_del(&ops->ops_list);
-			genl_unlock_all();
-			genl_ctrl_event(CTRL_CMD_DELOPS, ops);
-			return 0;
-		}
-	}
-	genl_unlock_all();
-
-	return -ENOENT;
-}
-EXPORT_SYMBOL(genl_unregister_ops);
 
 /**
  * __genl_register_family - register a generic netlink family
@@ -451,10 +400,6 @@ EXPORT_SYMBOL(__genl_register_family);
  * See include/net/genetlink.h for more documenation on the operations
  * structure.
  *
- * This is equivalent to calling genl_register_family() followed by
- * genl_register_ops() for every operation entry in the table taking
- * care to unregister the family on error path.
- *
  * Return 0 on success or a negative error code.
  */
 int __genl_register_family_with_ops(struct genl_family *family,
-- 
1.8.4.rc3
