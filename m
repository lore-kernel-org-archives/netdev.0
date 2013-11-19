From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 3/9] quota/genetlink: use proper genetlink multicast APIs
Date: Tue, 19 Nov 2013 15:19:33 +0100
Message-ID: <1384870779-17571-4-git-send-email-johannes@sipsolutions.net>
References: <1384870779-17571-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:41399 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727Ab3KSOTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 09:19:47 -0500
In-Reply-To: <1384870779-17571-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The quota code is abusing the genetlink API and is using
its family ID as the multicast group ID, which is invalid
and may belong to somebody else (and likely will.)

Make the quota code use the correct API, but since this
is already used as-is by userspace, reserve a family ID
for this code and also reserve that group ID to not break
userspace assumptions.

Acked-by: Jan Kara <jack@suse.cz>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 fs/quota/netlink.c             | 17 +++++++++++++++--
 include/uapi/linux/genetlink.h |  1 +
 net/netlink/genetlink.c        | 10 ++++++++--
 3 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/fs/quota/netlink.c b/fs/quota/netlink.c
index 16e8abb..aa22fe0 100644
--- a/fs/quota/netlink.c
+++ b/fs/quota/netlink.c
@@ -11,13 +11,23 @@
 
 /* Netlink family structure for quota */
 static struct genl_family quota_genl_family = {
-	.id = GENL_ID_GENERATE,
+	/*
+	 * Needed due to multicast group ID abuse - old code assumed
+	 * the family ID was also a valid multicast group ID (which
+	 * isn't true) and userspace might thus rely on it. Assign a
+	 * static ID for this group to make dealing with that easier.
+	 */
+	.id = GENL_ID_VFS_DQUOT,
 	.hdrsize = 0,
 	.name = "VFS_DQUOT",
 	.version = 1,
 	.maxattr = QUOTA_NL_A_MAX,
 };
 
+static struct genl_multicast_group quota_mcgrp = {
+	.name = "events",
+};
+
 /**
  * quota_send_warning - Send warning to userspace about exceeded quota
  * @type: The quota type: USRQQUOTA, GRPQUOTA,...
@@ -78,7 +88,7 @@ void quota_send_warning(struct kqid qid, dev_t dev,
 		goto attr_err_out;
 	genlmsg_end(skb, msg_head);
 
-	genlmsg_multicast(skb, 0, quota_genl_family.id, GFP_NOFS);
+	genlmsg_multicast(skb, 0, quota_mcgrp.id, GFP_NOFS);
 	return;
 attr_err_out:
 	printk(KERN_ERR "VFS: Not enough space to compose quota message!\n");
@@ -92,6 +102,9 @@ static int __init quota_init(void)
 	if (genl_register_family(&quota_genl_family) != 0)
 		printk(KERN_ERR
 		       "VFS: Failed to create quota netlink interface.\n");
+	if (genl_register_mc_group(&quota_genl_family, &quota_mcgrp))
+		printk(KERN_ERR
+		       "VFS: Failed to register quota mcast group.\n");
 	return 0;
 };
 
diff --git a/include/uapi/linux/genetlink.h b/include/uapi/linux/genetlink.h
index c880a41..1af72d82 100644
--- a/include/uapi/linux/genetlink.h
+++ b/include/uapi/linux/genetlink.h
@@ -27,6 +27,7 @@ struct genlmsghdr {
  */
 #define GENL_ID_GENERATE	0
 #define GENL_ID_CTRL		NLMSG_MIN_TYPE
+#define GENL_ID_VFS_DQUOT	(NLMSG_MIN_TYPE + 1)
 
 /**************************************************************************
  * Controller
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 353909d..bee91a7 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -69,8 +69,11 @@ static struct list_head family_ht[GENL_FAM_TAB_SIZE];
  * abuses the API and thinks it can statically use group 1.
  * That group will typically conflict with other groups that
  * any proper users use.
+ * Bit 17 is marked as already used since the VFS quota code
+ * also abused this API and relied on family == group ID, we
+ * cater to that by giving it a static family and group ID.
  */
-static unsigned long mc_group_start = 0x3;
+static unsigned long mc_group_start = 0x3 | BIT(GENL_ID_VFS_DQUOT);
 static unsigned long *mc_groups = &mc_group_start;
 static unsigned long mc_groups_longs = 1;
 
@@ -130,7 +133,8 @@ static u16 genl_generate_id(void)
 	int i;
 
 	for (i = 0; i <= GENL_MAX_ID - GENL_MIN_ID; i++) {
-		if (!genl_family_find_byid(id_gen_idx))
+		if (id_gen_idx != GENL_ID_VFS_DQUOT &&
+		    !genl_family_find_byid(id_gen_idx))
 			return id_gen_idx;
 		if (++id_gen_idx > GENL_MAX_ID)
 			id_gen_idx = GENL_MIN_ID;
@@ -169,6 +173,8 @@ int genl_register_mc_group(struct genl_family *family,
 		id = GENL_ID_CTRL;
 	else if (strcmp(family->name, "NET_DM") == 0)
 		id = 1;
+	else if (strcmp(family->name, "VFS_DQUOT") == 0)
+		id = GENL_ID_VFS_DQUOT;
 	else
 		id = find_first_zero_bit(mc_groups,
 					 mc_groups_longs * BITS_PER_LONG);
-- 
1.8.4.rc3
