From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 6/7] genetlink: register family ops as array
Date: Thu, 14 Nov 2013 10:14:45 +0100
Message-ID: <1384420486-8713-7-git-send-email-johannes@sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:47802 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563Ab3KNJOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 04:14:52 -0500
In-Reply-To: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Instead of using a linked list, use an array. This reduces
the data size needed by the users of genetlink, for example
in wireless (net/wireless/nl80211.c) on 64-bit it frees up
over 1K of data space.

Remove the attempted sending of CTRL_CMD_NEWOPS ctrl event
since genl_ctrl_event(CTRL_CMD_NEWOPS, ...) only returns
-EINVAL anyway, therefore no such event could ever be sent.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h |  5 ++--
 net/netlink/genetlink.c | 71 ++++++++++++++++++++++---------------------------
 2 files changed, 34 insertions(+), 42 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 617d718..abd4146 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -39,7 +39,6 @@ struct genl_info;
  * @post_doit: called after an operation's doit callback, it may
  *	undo operations done by pre_doit, for example release locks
  * @attrbuf: buffer to store parsed attributes
- * @ops_list: list of all assigned operations
  * @family_list: family list
  * @mcast_groups: multicast groups list
  */
@@ -58,7 +57,8 @@ struct genl_family {
 					     struct sk_buff *skb,
 					     struct genl_info *info);
 	struct nlattr **	attrbuf;	/* private */
-	struct list_head	ops_list;	/* private */
+	struct genl_ops *	ops;
+	unsigned int		n_ops;
 	struct list_head	family_list;	/* private */
 	struct list_head	mcast_groups;	/* private */
 	struct module		*module;
@@ -119,7 +119,6 @@ struct genl_ops {
 	int		       (*dumpit)(struct sk_buff *skb,
 					 struct netlink_callback *cb);
 	int		       (*done)(struct netlink_callback *cb);
-	struct list_head	ops_list;
 };
 
 int __genl_register_family(struct genl_family *family);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index fbccb45..d5a7f98 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -109,9 +109,10 @@ static struct genl_family *genl_family_find_byname(char *name)
 static struct genl_ops *genl_get_cmd(u8 cmd, struct genl_family *family)
 {
 	struct genl_ops *ops;
+	unsigned int i;
 
-	list_for_each_entry(ops, &family->ops_list, ops_list)
-		if (ops->cmd == cmd)
+	for (i = 0; i < family->n_ops; i++)
+		if (family->ops[i].cmd == cmd)
 			return ops;
 
 	return NULL;
@@ -283,32 +284,33 @@ static void genl_unregister_mc_groups(struct genl_family *family)
 		__genl_unregister_mc_group(family, grp);
 }
 
-static int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
+static int genl_validate_add_ops(struct genl_family *family, struct genl_ops *ops,
+				 unsigned int n_ops)
 {
+	int i, j;
 	int err = -EINVAL;
 
-	if (ops->dumpit == NULL && ops->doit == NULL)
-		goto errout;
+	for (i = 0; i < n_ops; i++)
+		if (ops[i].dumpit == NULL && ops[i].doit == NULL)
+			return -EINVAL;
 
-	if (genl_get_cmd(ops->cmd, family)) {
-		err = -EEXIST;
-		goto errout;
+	for (i = 0; i < n_ops; i++) {
+		for (j = i; j < n_ops; j++) {
+			if (ops[i].cmd == ops[j].cmd)
+				return -EINVAL;
+		}
+		if (ops[i].dumpit)
+			ops[i].flags |= GENL_CMD_CAP_DUMP;
+		if (ops[i].doit)
+			ops[i].flags |= GENL_CMD_CAP_DO;
+		if (ops[i].policy)
+			ops[i].flags |= GENL_CMD_CAP_HASPOL;
 	}
 
-	if (ops->dumpit)
-		ops->flags |= GENL_CMD_CAP_DUMP;
-	if (ops->doit)
-		ops->flags |= GENL_CMD_CAP_DO;
-	if (ops->policy)
-		ops->flags |= GENL_CMD_CAP_HASPOL;
+	/* family is not registered yet, so no locking needed */
+	family->ops = ops;
+	family->n_ops = n_ops;
 
-	genl_lock_all();
-	list_add_tail(&ops->ops_list, &family->ops_list);
-	genl_unlock_all();
-
-	genl_ctrl_event(CTRL_CMD_NEWOPS, ops);
-	err = 0;
-errout:
 	return err;
 }
 
@@ -333,7 +335,6 @@ int __genl_register_family(struct genl_family *family)
 	if (family->id > GENL_MAX_ID)
 		goto errout;
 
-	INIT_LIST_HEAD(&family->ops_list);
 	INIT_LIST_HEAD(&family->mcast_groups);
 
 	genl_lock_all();
@@ -405,21 +406,13 @@ EXPORT_SYMBOL(__genl_register_family);
 int __genl_register_family_with_ops(struct genl_family *family,
 	struct genl_ops *ops, size_t n_ops)
 {
-	int err, i;
+	int err;
 
-	err = __genl_register_family(family);
+	err = genl_validate_add_ops(family, ops, n_ops);
 	if (err)
 		return err;
 
-	for (i = 0; i < n_ops; ++i, ++ops) {
-		err = genl_register_ops(family, ops);
-		if (err)
-			goto err_out;
-	}
-	return 0;
-err_out:
-	genl_unregister_family(family);
-	return err;
+	return __genl_register_family(family);
 }
 EXPORT_SYMBOL(__genl_register_family_with_ops);
 
@@ -444,7 +437,7 @@ int genl_unregister_family(struct genl_family *family)
 			continue;
 
 		list_del(&rc->family_list);
-		INIT_LIST_HEAD(&family->ops_list);
+		family->n_ops = 0;
 		genl_unlock_all();
 
 		kfree(family->attrbuf);
@@ -671,19 +664,19 @@ static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
 	    nla_put_u32(skb, CTRL_ATTR_MAXATTR, family->maxattr))
 		goto nla_put_failure;
 
-	if (!list_empty(&family->ops_list)) {
+	if (family->n_ops) {
 		struct nlattr *nla_ops;
-		struct genl_ops *ops;
-		int idx = 1;
+		int i;
 
 		nla_ops = nla_nest_start(skb, CTRL_ATTR_OPS);
 		if (nla_ops == NULL)
 			goto nla_put_failure;
 
-		list_for_each_entry(ops, &family->ops_list, ops_list) {
+		for (i = 0; i < family->n_ops; i++) {
 			struct nlattr *nest;
+			struct genl_ops *ops = &family->ops[i];
 
-			nest = nla_nest_start(skb, idx++);
+			nest = nla_nest_start(skb, i + 1);
 			if (nest == NULL)
 				goto nla_put_failure;
 
-- 
1.8.4.rc3
