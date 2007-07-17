From: Johannes Berg <johannes@sipsolutions.net>
Subject: [patch 3/3] generic netlink: dynamic multicast groups
Date: Tue, 17 Jul 2007 14:27:09 +0200
Message-ID: <20070717123644.010813000@sipsolutions.net>
References: <20070717122706.899784000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Zhang Rui <rui.zhang@intel.com>, jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42476 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470AbXGQMmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 08:42:05 -0400
Content-Disposition: inline; filename=022-genl-multicast-groups.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce API to dynamically register and unregister multicast groups.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 include/linux/genetlink.h |   13 +++
 include/net/genetlink.h   |   22 +++++
 net/netlink/genetlink.c   |  190 ++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 218 insertions(+), 7 deletions(-)

--- wireless-dev.orig/include/net/genetlink.h	2007-07-17 14:05:13.760964463 +0200
+++ wireless-dev/include/net/genetlink.h	2007-07-17 14:05:31.780964463 +0200
@@ -5,6 +5,22 @@
 #include <net/netlink.h>
 
 /**
+ * struct genl_multicast_group - generic netlink multicast group
+ * @name: name of the multicast group, names are per-family
+ * @id: multicast group ID, assigned by the core, to use with
+ *      genlmsg_multicast().
+ * @list: list entry for linking
+ * @family: pointer to family, need not be set before registering
+ */
+struct genl_multicast_group
+{
+	struct genl_family	*family;	/* private */
+	struct list_head	list;		/* private */
+	char			name[GENL_NAMSIZ];
+	u32			id;
+};
+
+/**
  * struct genl_family - generic netlink family
  * @id: protocol family idenfitier
  * @hdrsize: length of user specific header in bytes
@@ -14,6 +30,7 @@
  * @attrbuf: buffer to store parsed attributes
  * @ops_list: list of all assigned operations
  * @family_list: family list
+ * @mcast_groups: multicast groups list
  */
 struct genl_family
 {
@@ -25,6 +42,7 @@ struct genl_family
 	struct nlattr **	attrbuf;	/* private */
 	struct list_head	ops_list;	/* private */
 	struct list_head	family_list;	/* private */
+	struct list_head	mcast_groups;	/* private */
 };
 
 /**
@@ -73,6 +91,10 @@ extern int genl_register_family(struct g
 extern int genl_unregister_family(struct genl_family *family);
 extern int genl_register_ops(struct genl_family *, struct genl_ops *ops);
 extern int genl_unregister_ops(struct genl_family *, struct genl_ops *ops);
+extern int genl_register_mc_group(struct genl_family *family,
+				  struct genl_multicast_group *grp);
+extern void genl_unregister_mc_group(struct genl_family *family,
+				     struct genl_multicast_group *grp);
 
 extern struct sock *genl_sock;
 
--- wireless-dev.orig/net/netlink/genetlink.c	2007-07-17 14:05:13.860964463 +0200
+++ wireless-dev/net/netlink/genetlink.c	2007-07-17 14:05:31.780964463 +0200
@@ -3,6 +3,7 @@
  *
  * 		Authors:	Jamal Hadi Salim
  * 				Thomas Graf <tgraf@suug.ch>
+ *				Johannes Berg <johannes@sipsolutions.net>
  */
 
 #include <linux/module.h>
@@ -13,6 +14,7 @@
 #include <linux/string.h>
 #include <linux/skbuff.h>
 #include <linux/mutex.h>
+#include <linux/bitmap.h>
 #include <net/sock.h>
 #include <net/genetlink.h>
 
@@ -42,6 +44,17 @@ static void genl_unlock(void)
 #define GENL_FAM_TAB_MASK	(GENL_FAM_TAB_SIZE - 1)
 
 static struct list_head family_ht[GENL_FAM_TAB_SIZE];
+/*
+ * Bitmap of multicast groups that are currently in use.
+ *
+ * To avoid an allocation at boot of just one unsigned long,
+ * declare it global instead.
+ * Bit 0 is marked as already used since group 0 is invalid,
+ * bit 1 is marked as already used since group 1 is the controller group.
+ */
+static unsigned long mc_group_start = 0x3;
+static unsigned long *mc_groups = &mc_group_start;
+static unsigned long mc_groups_longs = 1;
 
 static int genl_ctrl_event(int event, void *data);
 
@@ -116,6 +129,77 @@ static inline u16 genl_generate_id(void)
 	return id_gen_idx;
 }
 
+int genl_register_mc_group(struct genl_family *family,
+			   struct genl_multicast_group *grp)
+{
+	int id = find_first_zero_bit(mc_groups,
+				     mc_groups_longs * BITS_PER_LONG);
+	unsigned long *new_groups;
+	size_t nlen = (mc_groups_longs + 1) * sizeof(unsigned long);
+	int err;
+
+	genl_lock();
+
+	if (id >= mc_groups_longs * BITS_PER_LONG) {
+		if (mc_groups == &mc_group_start) {
+			new_groups = kzalloc(nlen, GFP_KERNEL);
+			if (!mc_groups) {
+				err = -ENOMEM;
+				goto out;
+			}
+			mc_groups = new_groups;
+			*mc_groups = mc_group_start;
+		} else {
+			new_groups = krealloc(mc_groups, nlen, GFP_KERNEL);
+			if (!new_groups) {
+				err = -ENOMEM;
+				goto out;
+			}
+			mc_groups = new_groups;
+			mc_groups[mc_groups_longs] = 0;
+		}
+		mc_groups_longs++;
+	}
+
+	err = netlink_change_ngroups(NETLINK_GENERIC,
+				     sizeof(unsigned long) * NETLINK_GENERIC);
+	if (err)
+		goto out;
+
+	grp->id = id;
+	set_bit(id, mc_groups);
+	list_add_tail(&grp->list, &family->mcast_groups);
+	grp->family = family;
+
+	genl_ctrl_event(CTRL_CMD_NEWMCAST_GRP, grp);
+ out:
+	genl_unlock();
+	return 0;
+}
+EXPORT_SYMBOL(genl_register_mc_group);
+
+void genl_unregister_mc_group(struct genl_family *family,
+			      struct genl_multicast_group *grp)
+{
+	BUG_ON(grp->family != family);
+	genl_lock();
+	netlink_clear_multicast_users(NETLINK_GENERIC, grp->id);
+	clear_bit(grp->id, mc_groups);
+	list_del(&grp->list);
+	genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, grp);
+	grp->id = 0;
+	grp->family = NULL;
+	genl_unlock();
+}
+
+static void genl_unregister_mc_groups(struct genl_family *family)
+{
+	struct genl_multicast_group *grp, *tmp;
+
+	list_for_each_entry_safe(grp, tmp, &family->mcast_groups, list)
+		genl_unregister_mc_group(family, grp);
+}
+
 /**
  * genl_register_ops - register generic netlink operations
  * @family: generic netlink family
@@ -216,6 +300,7 @@ int genl_register_family(struct genl_fam
 		goto errout;
 
 	INIT_LIST_HEAD(&family->ops_list);
+	INIT_LIST_HEAD(&family->mcast_groups);
 
 	genl_lock();
 
@@ -275,6 +360,8 @@ int genl_unregister_family(struct genl_f
 {
 	struct genl_family *rc;
 
+	genl_unregister_mc_groups(family);
+
 	genl_lock();
 
 	list_for_each_entry(rc, genl_family_chain(family->id), family_list) {
@@ -410,6 +497,67 @@ static int ctrl_fill_info(struct genl_fa
 		nla_nest_end(skb, nla_ops);
 	}
 
+	if (!list_empty(&family->mcast_groups)) {
+		struct genl_multicast_group *grp;
+		struct nlattr *nla_grps;
+		int idx = 1;
+
+		nla_grps = nla_nest_start(skb, CTRL_ATTR_MCAST_GROUPS);
+		if (nla_grps == NULL)
+			goto nla_put_failure;
+
+		list_for_each_entry(grp, &family->mcast_groups, list) {
+			struct nlattr *nest;
+
+			nest = nla_nest_start(skb, idx++);
+			if (nest == NULL)
+				goto nla_put_failure;
+
+			NLA_PUT_U32(skb, CTRL_ATTR_MCAST_GRP_ID, grp->id);
+			NLA_PUT_STRING(skb, CTRL_ATTR_MCAST_GRP_NAME,
+				       grp->name);
+
+			nla_nest_end(skb, nest);
+		}
+		nla_nest_end(skb, nla_grps);
+	}
+
+	return genlmsg_end(skb, hdr);
+
+nla_put_failure:
+	return genlmsg_cancel(skb, hdr);
+}
+
+static int ctrl_fill_mcgrp_info(struct genl_multicast_group *grp, u32 pid,
+				u32 seq, u32 flags, struct sk_buff *skb,
+				u8 cmd)
+{
+	void *hdr;
+	struct nlattr *nla_grps;
+	struct nlattr *nest;
+
+	hdr = genlmsg_put(skb, pid, seq, &genl_ctrl, flags, cmd);
+	if (hdr == NULL)
+		return -1;
+
+	NLA_PUT_STRING(skb, CTRL_ATTR_FAMILY_NAME, grp->family->name);
+	NLA_PUT_U16(skb, CTRL_ATTR_FAMILY_ID, grp->family->id);
+
+	nla_grps = nla_nest_start(skb, CTRL_ATTR_MCAST_GROUPS);
+	if (nla_grps == NULL)
+		goto nla_put_failure;
+
+	nest = nla_nest_start(skb, 1);
+	if (nest == NULL)
+		goto nla_put_failure;
+
+	NLA_PUT_U32(skb, CTRL_ATTR_MCAST_GRP_ID, grp->id);
+	NLA_PUT_STRING(skb, CTRL_ATTR_MCAST_GRP_NAME,
+		       grp->name);
+
+	nla_nest_end(skb, nest);
+	nla_nest_end(skb, nla_grps);
+
 	return genlmsg_end(skb, hdr);
 
 nla_put_failure:
@@ -453,8 +601,8 @@ errout:
 	return skb->len;
 }
 
-static struct sk_buff *ctrl_build_msg(struct genl_family *family, u32 pid,
-				      int seq, u8 cmd)
+static struct sk_buff *ctrl_build_family_msg(struct genl_family *family,
+					     u32 pid, int seq, u8 cmd)
 {
 	struct sk_buff *skb;
 	int err;
@@ -472,6 +620,25 @@ static struct sk_buff *ctrl_build_msg(st
 	return skb;
 }
 
+static struct sk_buff *ctrl_build_mcgrp_msg(struct genl_multicast_group *grp,
+					    u32 pid, int seq, u8 cmd)
+{
+	struct sk_buff *skb;
+	int err;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (skb == NULL)
+		return ERR_PTR(-ENOBUFS);
+
+	err = ctrl_fill_mcgrp_info(grp, pid, seq, 0, skb, cmd);
+	if (err < 0) {
+		nlmsg_free(skb);
+		return ERR_PTR(err);
+	}
+
+	return skb;
+}
+
 static const struct nla_policy ctrl_policy[CTRL_ATTR_MAX+1] = {
 	[CTRL_ATTR_FAMILY_ID]	= { .type = NLA_U16 },
 	[CTRL_ATTR_FAMILY_NAME]	= { .type = NLA_NUL_STRING,
@@ -501,8 +668,8 @@ static int ctrl_getfamily(struct sk_buff
 		goto errout;
 	}
 
-	msg = ctrl_build_msg(res, info->snd_pid, info->snd_seq,
-			     CTRL_CMD_NEWFAMILY);
+	msg = ctrl_build_family_msg(res, info->snd_pid, info->snd_seq,
+				    CTRL_CMD_NEWFAMILY);
 	if (IS_ERR(msg)) {
 		err = PTR_ERR(msg);
 		goto errout;
@@ -523,7 +690,15 @@ static int genl_ctrl_event(int event, vo
 	switch (event) {
 	case CTRL_CMD_NEWFAMILY:
 	case CTRL_CMD_DELFAMILY:
-		msg = ctrl_build_msg(data, 0, 0, event);
+		msg = ctrl_build_family_msg(data, 0, 0, event);
+		if (IS_ERR(msg))
+			return PTR_ERR(msg);
+
+		genlmsg_multicast(msg, 0, GENL_ID_CTRL, GFP_KERNEL);
+		break;
+	case CTRL_CMD_NEWMCAST_GRP:
+	case CTRL_CMD_DELMCAST_GRP:
+		msg = ctrl_build_mcgrp_msg(data, 0, 0, event);
 		if (IS_ERR(msg))
 			return PTR_ERR(msg);
 
@@ -557,8 +732,9 @@ static int __init genl_init(void)
 		goto errout_register;
 
 	netlink_set_nonroot(NETLINK_GENERIC, NL_NONROOT_RECV);
-	genl_sock = netlink_kernel_create(NETLINK_GENERIC, GENL_MAX_ID,
-					  genl_rcv, NULL, THIS_MODULE);
+	/* only one static multicast group */
+	genl_sock = netlink_kernel_create(NETLINK_GENERIC, 1, genl_rcv,
+					  NULL, THIS_MODULE);
 	if (genl_sock == NULL)
 		panic("GENL: Cannot initialize generic netlink\n");
 
--- wireless-dev.orig/include/linux/genetlink.h	2007-07-17 14:05:13.800964463 +0200
+++ wireless-dev/include/linux/genetlink.h	2007-07-17 14:05:31.780964463 +0200
@@ -39,6 +39,9 @@ enum {
 	CTRL_CMD_NEWOPS,
 	CTRL_CMD_DELOPS,
 	CTRL_CMD_GETOPS,
+	CTRL_CMD_NEWMCAST_GRP,
+	CTRL_CMD_DELMCAST_GRP,
+	CTRL_CMD_GETMCAST_GRP, /* unused */
 	__CTRL_CMD_MAX,
 };
 
@@ -52,6 +55,7 @@ enum {
 	CTRL_ATTR_HDRSIZE,
 	CTRL_ATTR_MAXATTR,
 	CTRL_ATTR_OPS,
+	CTRL_ATTR_MCAST_GROUPS,
 	__CTRL_ATTR_MAX,
 };
 
@@ -66,4 +70,13 @@ enum {
 
 #define CTRL_ATTR_OP_MAX (__CTRL_ATTR_OP_MAX - 1)
 
+enum {
+	CTRL_ATTR_MCAST_GRP_UNSPEC,
+	CTRL_ATTR_MCAST_GRP_NAME,
+	CTRL_ATTR_MCAST_GRP_ID,
+	__CTRL_ATTR_MCAST_GRP_MAX,
+};
+
+#define CTRL_ATTR_MCAST_GRP_MAX (__CTRL_ATTR_MCAST_GRP_MAX - 1)
+
 #endif	/* __LINUX_GENERIC_NETLINK_H */

-- 

