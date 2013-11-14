From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 7/7] genetlink: allow making ops const
Date: Thu, 14 Nov 2013 10:14:46 +0100
Message-ID: <1384420486-8713-8-git-send-email-johannes@sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:47807 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589Ab3KNJOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 04:14:53 -0500
In-Reply-To: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Allow making the ops array const by not modifying the ops
flags on registration but rather only when ops are sent
out in the family information.

No users are updated yet.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h |  6 +++---
 net/netlink/genetlink.c | 23 +++++++++++++----------
 2 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index abd4146..0b6b10b 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -57,7 +57,7 @@ struct genl_family {
 					     struct sk_buff *skb,
 					     struct genl_info *info);
 	struct nlattr **	attrbuf;	/* private */
-	struct genl_ops *	ops;
+	const struct genl_ops *	ops;
 	unsigned int		n_ops;
 	struct list_head	family_list;	/* private */
 	struct list_head	mcast_groups;	/* private */
@@ -130,10 +130,10 @@ static inline int genl_register_family(struct genl_family *family)
 }
 
 int __genl_register_family_with_ops(struct genl_family *family,
-				    struct genl_ops *ops, size_t n_ops);
+				    const struct genl_ops *ops, size_t n_ops);
 
 static inline int genl_register_family_with_ops(struct genl_family *family,
-	struct genl_ops *ops, size_t n_ops)
+	const struct genl_ops *ops, size_t n_ops)
 {
 	family->module = THIS_MODULE;
 	return __genl_register_family_with_ops(family, ops, n_ops);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index d5a7f98..3ad151f 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -284,7 +284,8 @@ static void genl_unregister_mc_groups(struct genl_family *family)
 		__genl_unregister_mc_group(family, grp);
 }
 
-static int genl_validate_add_ops(struct genl_family *family, struct genl_ops *ops,
+static int genl_validate_add_ops(struct genl_family *family,
+				 const struct genl_ops *ops,
 				 unsigned int n_ops)
 {
 	int i, j;
@@ -299,12 +300,6 @@ static int genl_validate_add_ops(struct genl_family *family, struct genl_ops *op
 			if (ops[i].cmd == ops[j].cmd)
 				return -EINVAL;
 		}
-		if (ops[i].dumpit)
-			ops[i].flags |= GENL_CMD_CAP_DUMP;
-		if (ops[i].doit)
-			ops[i].flags |= GENL_CMD_CAP_DO;
-		if (ops[i].policy)
-			ops[i].flags |= GENL_CMD_CAP_HASPOL;
 	}
 
 	/* family is not registered yet, so no locking needed */
@@ -404,7 +399,7 @@ EXPORT_SYMBOL(__genl_register_family);
  * Return 0 on success or a negative error code.
  */
 int __genl_register_family_with_ops(struct genl_family *family,
-	struct genl_ops *ops, size_t n_ops)
+	const struct genl_ops *ops, size_t n_ops)
 {
 	int err;
 
@@ -674,14 +669,22 @@ static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
 
 		for (i = 0; i < family->n_ops; i++) {
 			struct nlattr *nest;
-			struct genl_ops *ops = &family->ops[i];
+			const struct genl_ops *ops = &family->ops[i];
+			u32 flags = ops->flags;
+
+			if (ops->dumpit)
+				flags |= GENL_CMD_CAP_DUMP;
+			if (ops->doit)
+				flags |= GENL_CMD_CAP_DO;
+			if (ops->policy)
+				flags |= GENL_CMD_CAP_HASPOL;
 
 			nest = nla_nest_start(skb, i + 1);
 			if (nest == NULL)
 				goto nla_put_failure;
 
 			if (nla_put_u32(skb, CTRL_ATTR_OP_ID, ops->cmd) ||
-			    nla_put_u32(skb, CTRL_ATTR_OP_FLAGS, ops->flags))
+			    nla_put_u32(skb, CTRL_ATTR_OP_FLAGS, flags))
 				goto nla_put_failure;
 
 			nla_nest_end(skb, nest);
-- 
1.8.4.rc3
