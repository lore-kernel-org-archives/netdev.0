From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 6/9] genetlink: remove family pointer from genl_multicast_group
Date: Tue, 19 Nov 2013 15:19:36 +0100
Message-ID: <1384870779-17571-7-git-send-email-johannes@sipsolutions.net>
References: <1384870779-17571-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:41397 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab3KSOTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 09:19:47 -0500
In-Reply-To: <1384870779-17571-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

There's no reason to have the family pointer there since it
can just be passed internally where needed, so remove it.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h |  2 --
 net/netlink/genetlink.c | 38 ++++++++++++++++++--------------------
 2 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 067569d..d8a8b1f 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -13,10 +13,8 @@
  * @id: multicast group ID, assigned by the core, to use with
  *      genlmsg_multicast().
  * @list: list entry for linking
- * @family: pointer to family, need not be set before registering
  */
 struct genl_multicast_group {
-	struct genl_family	*family;	/* private */
 	struct list_head	list;		/* private */
 	char			name[GENL_NAMSIZ];
 	u32			id;
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 6efb0e9..e9ef640 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -77,7 +77,8 @@ static unsigned long mc_group_start = 0x3 | BIT(GENL_ID_VFS_DQUOT);
 static unsigned long *mc_groups = &mc_group_start;
 static unsigned long mc_groups_longs = 1;
 
-static int genl_ctrl_event(int event, void *data);
+static int genl_ctrl_event(int event, struct genl_family *family,
+			   struct genl_multicast_group *grp);
 
 static inline unsigned int genl_family_hash(unsigned int id)
 {
@@ -235,9 +236,8 @@ int genl_register_mc_group(struct genl_family *family,
 	grp->id = id;
 	set_bit(id, mc_groups);
 	list_add_tail(&grp->list, &family->mcast_groups);
-	grp->family = family;
 
-	genl_ctrl_event(CTRL_CMD_NEWMCAST_GRP, grp);
+	genl_ctrl_event(CTRL_CMD_NEWMCAST_GRP, family, grp);
  out:
 	genl_unlock_all();
 	return err;
@@ -248,7 +248,6 @@ static void __genl_unregister_mc_group(struct genl_family *family,
 				       struct genl_multicast_group *grp)
 {
 	struct net *net;
-	BUG_ON(grp->family != family);
 
 	netlink_table_grab();
 	rcu_read_lock();
@@ -260,9 +259,8 @@ static void __genl_unregister_mc_group(struct genl_family *family,
 	if (grp->id != 1)
 		clear_bit(grp->id, mc_groups);
 	list_del(&grp->list);
-	genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, grp);
+	genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, family, grp);
 	grp->id = 0;
-	grp->family = NULL;
 }
 
 static void genl_unregister_mc_groups(struct genl_family *family)
@@ -364,7 +362,7 @@ int __genl_register_family(struct genl_family *family)
 	list_add_tail(&family->family_list, genl_family_chain(family->id));
 	genl_unlock_all();
 
-	genl_ctrl_event(CTRL_CMD_NEWFAMILY, family);
+	genl_ctrl_event(CTRL_CMD_NEWFAMILY, family, NULL);
 
 	return 0;
 
@@ -400,7 +398,7 @@ int genl_unregister_family(struct genl_family *family)
 		genl_unlock_all();
 
 		kfree(family->attrbuf);
-		genl_ctrl_event(CTRL_CMD_DELFAMILY, family);
+		genl_ctrl_event(CTRL_CMD_DELFAMILY, family, NULL);
 		return 0;
 	}
 
@@ -693,7 +691,8 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int ctrl_fill_mcgrp_info(struct genl_multicast_group *grp, u32 portid,
+static int ctrl_fill_mcgrp_info(struct genl_family *family,
+				struct genl_multicast_group *grp, u32 portid,
 				u32 seq, u32 flags, struct sk_buff *skb,
 				u8 cmd)
 {
@@ -705,8 +704,8 @@ static int ctrl_fill_mcgrp_info(struct genl_multicast_group *grp, u32 portid,
 	if (hdr == NULL)
 		return -1;
 
-	if (nla_put_string(skb, CTRL_ATTR_FAMILY_NAME, grp->family->name) ||
-	    nla_put_u16(skb, CTRL_ATTR_FAMILY_ID, grp->family->id))
+	if (nla_put_string(skb, CTRL_ATTR_FAMILY_NAME, family->name) ||
+	    nla_put_u16(skb, CTRL_ATTR_FAMILY_ID, family->id))
 		goto nla_put_failure;
 
 	nla_grps = nla_nest_start(skb, CTRL_ATTR_MCAST_GROUPS);
@@ -783,7 +782,8 @@ static struct sk_buff *ctrl_build_family_msg(struct genl_family *family,
 	return skb;
 }
 
-static struct sk_buff *ctrl_build_mcgrp_msg(struct genl_multicast_group *grp,
+static struct sk_buff *ctrl_build_mcgrp_msg(struct genl_family *family,
+					    struct genl_multicast_group *grp,
 					    u32 portid, int seq, u8 cmd)
 {
 	struct sk_buff *skb;
@@ -793,7 +793,7 @@ static struct sk_buff *ctrl_build_mcgrp_msg(struct genl_multicast_group *grp,
 	if (skb == NULL)
 		return ERR_PTR(-ENOBUFS);
 
-	err = ctrl_fill_mcgrp_info(grp, portid, seq, 0, skb, cmd);
+	err = ctrl_fill_mcgrp_info(family, grp, portid, seq, 0, skb, cmd);
 	if (err < 0) {
 		nlmsg_free(skb);
 		return ERR_PTR(err);
@@ -855,11 +855,10 @@ static int ctrl_getfamily(struct sk_buff *skb, struct genl_info *info)
 	return genlmsg_reply(msg, info);
 }
 
-static int genl_ctrl_event(int event, void *data)
+static int genl_ctrl_event(int event, struct genl_family *family,
+			   struct genl_multicast_group *grp)
 {
 	struct sk_buff *msg;
-	struct genl_family *family;
-	struct genl_multicast_group *grp;
 
 	/* genl is still initialising */
 	if (!init_net.genl_sock)
@@ -868,14 +867,13 @@ static int genl_ctrl_event(int event, void *data)
 	switch (event) {
 	case CTRL_CMD_NEWFAMILY:
 	case CTRL_CMD_DELFAMILY:
-		family = data;
+		WARN_ON(grp);
 		msg = ctrl_build_family_msg(family, 0, 0, event);
 		break;
 	case CTRL_CMD_NEWMCAST_GRP:
 	case CTRL_CMD_DELMCAST_GRP:
-		grp = data;
-		family = grp->family;
-		msg = ctrl_build_mcgrp_msg(data, 0, 0, event);
+		BUG_ON(!grp);
+		msg = ctrl_build_mcgrp_msg(family, grp, 0, 0, event);
 		break;
 	default:
 		return -EINVAL;
-- 
1.8.4.rc3
