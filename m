From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 4/5] genetlink: use idr to track families
Date: Mon, 24 Oct 2016 14:40:04 +0200
Message-ID: <1477312805-7110-5-git-send-email-johannes@sipsolutions.net>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51698 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938728AbcJXMkL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 08:40:11 -0400
In-Reply-To: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Since generic netlink family IDs are small integers, allocated
densely, IDR is an ideal match for lookups. Replace the existing
hand-written hash-table with IDR for allocation and lookup.

This lets the families only be written to once, during register,
since the list_head can be removed and removal of a family won't
cause any writes.

It also slightly reduces the code size (by about 1.3k on x86-64).

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h        |  31 +++--
 include/uapi/linux/genetlink.h |   2 +
 net/netlink/genetlink.c        | 271 ++++++++++++++++-------------------------
 3 files changed, 123 insertions(+), 181 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 2298b50cee34..3ec87bacc0f5 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -40,7 +40,6 @@ struct genl_info;
  *	generic netlink family is removed while there are still open
  *	sockets.
  * @attrbuf: buffer to store parsed attributes (private)
- * @family_list: family list (private)
  * @mcgrps: multicast groups used by this family
  * @n_mcgrps: number of multicast groups
  * @mcgrp_offset: starting number of multicast group IDs in this family
@@ -70,11 +69,10 @@ struct genl_family {
 	unsigned int		n_ops;
 	unsigned int		n_mcgrps;
 	unsigned int		mcgrp_offset;	/* private */
-	struct list_head	family_list;	/* private */
 	struct module		*module;
 };
 
-struct nlattr **genl_family_attrbuf(struct genl_family *family);
+struct nlattr **genl_family_attrbuf(const struct genl_family *family);
 
 /**
  * struct genl_info - receiving information
@@ -134,12 +132,12 @@ struct genl_ops {
 };
 
 int genl_register_family(struct genl_family *family);
-int genl_unregister_family(struct genl_family *family);
-void genl_notify(struct genl_family *family, struct sk_buff *skb,
+int genl_unregister_family(const struct genl_family *family);
+void genl_notify(const struct genl_family *family, struct sk_buff *skb,
 		 struct genl_info *info, u32 group, gfp_t flags);
 
 void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
-		  struct genl_family *family, int flags, u8 cmd);
+		  const struct genl_family *family, int flags, u8 cmd);
 
 /**
  * genlmsg_nlhdr - Obtain netlink header from user specified header
@@ -148,8 +146,8 @@ void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
  *
  * Returns pointer to netlink header.
  */
-static inline struct nlmsghdr *genlmsg_nlhdr(void *user_hdr,
-					     struct genl_family *family)
+static inline struct nlmsghdr *
+genlmsg_nlhdr(void *user_hdr, const struct genl_family *family)
 {
 	return (struct nlmsghdr *)((char *)user_hdr -
 				   family->hdrsize -
@@ -185,7 +183,7 @@ static inline int genlmsg_parse(const struct nlmsghdr *nlh,
  */
 static inline void genl_dump_check_consistent(struct netlink_callback *cb,
 					      void *user_hdr,
-					      struct genl_family *family)
+					      const struct genl_family *family)
 {
 	nl_dump_check_consistent(cb, genlmsg_nlhdr(user_hdr, family));
 }
@@ -202,7 +200,7 @@ static inline void genl_dump_check_consistent(struct netlink_callback *cb,
  */
 static inline void *genlmsg_put_reply(struct sk_buff *skb,
 				      struct genl_info *info,
-				      struct genl_family *family,
+				      const struct genl_family *family,
 				      int flags, u8 cmd)
 {
 	return genlmsg_put(skb, info->snd_portid, info->snd_seq, family,
@@ -239,7 +237,7 @@ static inline void genlmsg_cancel(struct sk_buff *skb, void *hdr)
  * @group: offset of multicast group in groups array
  * @flags: allocation flags
  */
-static inline int genlmsg_multicast_netns(struct genl_family *family,
+static inline int genlmsg_multicast_netns(const struct genl_family *family,
 					  struct net *net, struct sk_buff *skb,
 					  u32 portid, unsigned int group, gfp_t flags)
 {
@@ -257,7 +255,7 @@ static inline int genlmsg_multicast_netns(struct genl_family *family,
  * @group: offset of multicast group in groups array
  * @flags: allocation flags
  */
-static inline int genlmsg_multicast(struct genl_family *family,
+static inline int genlmsg_multicast(const struct genl_family *family,
 				    struct sk_buff *skb, u32 portid,
 				    unsigned int group, gfp_t flags)
 {
@@ -275,7 +273,7 @@ static inline int genlmsg_multicast(struct genl_family *family,
  *
  * This function must hold the RTNL or rcu_read_lock().
  */
-int genlmsg_multicast_allns(struct genl_family *family,
+int genlmsg_multicast_allns(const struct genl_family *family,
 			    struct sk_buff *skb, u32 portid,
 			    unsigned int group, gfp_t flags);
 
@@ -359,8 +357,9 @@ static inline struct sk_buff *genlmsg_new(size_t payload, gfp_t flags)
  * This function returns the number of broadcast listeners that have set the
  * NETLINK_RECV_NO_ENOBUFS socket option.
  */
-static inline int genl_set_err(struct genl_family *family, struct net *net,
-			       u32 portid, u32 group, int code)
+static inline int genl_set_err(const struct genl_family *family,
+			       struct net *net, u32 portid,
+			       u32 group, int code)
 {
 	if (WARN_ON_ONCE(group >= family->n_mcgrps))
 		return -EINVAL;
@@ -368,7 +367,7 @@ static inline int genl_set_err(struct genl_family *family, struct net *net,
 	return netlink_set_err(net->genl_sock, portid, group, code);
 }
 
-static inline int genl_has_listeners(struct genl_family *family,
+static inline int genl_has_listeners(const struct genl_family *family,
 				     struct net *net, unsigned int group)
 {
 	if (WARN_ON_ONCE(group >= family->n_mcgrps))
diff --git a/include/uapi/linux/genetlink.h b/include/uapi/linux/genetlink.h
index d9b2db4a29c6..adc899381e0d 100644
--- a/include/uapi/linux/genetlink.h
+++ b/include/uapi/linux/genetlink.h
@@ -29,6 +29,8 @@ struct genlmsghdr {
 #define GENL_ID_CTRL		NLMSG_MIN_TYPE
 #define GENL_ID_VFS_DQUOT	(NLMSG_MIN_TYPE + 1)
 #define GENL_ID_PMCRAID		(NLMSG_MIN_TYPE + 2)
+/* must be last reserved + 1 */
+#define GENL_START_ALLOC	(NLMSG_MIN_TYPE + 3)
 
 /**************************************************************************
  * Controller
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index ca582ee4ae05..85659921e7b2 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -17,6 +17,7 @@
 #include <linux/mutex.h>
 #include <linux/bitmap.h>
 #include <linux/rwsem.h>
+#include <linux/idr.h>
 #include <net/sock.h>
 #include <net/genetlink.h>
 
@@ -58,10 +59,8 @@ static void genl_unlock_all(void)
 	up_write(&cb_lock);
 }
 
-#define GENL_FAM_TAB_SIZE	16
-#define GENL_FAM_TAB_MASK	(GENL_FAM_TAB_SIZE - 1)
+static DEFINE_IDR(genl_fam_idr);
 
-static struct list_head family_ht[GENL_FAM_TAB_SIZE];
 /*
  * Bitmap of multicast groups that are currently in use.
  *
@@ -86,45 +85,29 @@ static unsigned long mc_group_start = 0x3 | BIT(GENL_ID_CTRL) |
 static unsigned long *mc_groups = &mc_group_start;
 static unsigned long mc_groups_longs = 1;
 
-static int genl_ctrl_event(int event, struct genl_family *family,
+static int genl_ctrl_event(int event, const struct genl_family *family,
 			   const struct genl_multicast_group *grp,
 			   int grp_id);
 
-static inline unsigned int genl_family_hash(unsigned int id)
+static const struct genl_family *genl_family_find_byid(unsigned int id)
 {
-	return id & GENL_FAM_TAB_MASK;
+	return idr_find(&genl_fam_idr, id);
 }
 
-static inline struct list_head *genl_family_chain(unsigned int id)
+static const struct genl_family *genl_family_find_byname(char *name)
 {
-	return &family_ht[genl_family_hash(id)];
-}
-
-static struct genl_family *genl_family_find_byid(unsigned int id)
-{
-	struct genl_family *f;
+	const struct genl_family *family;
+	unsigned int id;
 
-	list_for_each_entry(f, genl_family_chain(id), family_list)
-		if (f->id == id)
-			return f;
+	idr_for_each_entry(&genl_fam_idr, family, id)
+		if (strcmp(family->name, name) == 0)
+			return family;
 
 	return NULL;
 }
 
-static struct genl_family *genl_family_find_byname(char *name)
-{
-	struct genl_family *f;
-	int i;
-
-	for (i = 0; i < GENL_FAM_TAB_SIZE; i++)
-		list_for_each_entry(f, genl_family_chain(i), family_list)
-			if (strcmp(f->name, name) == 0)
-				return f;
-
-	return NULL;
-}
-
-static const struct genl_ops *genl_get_cmd(u8 cmd, struct genl_family *family)
+static const struct genl_ops *genl_get_cmd(u8 cmd,
+					   const struct genl_family *family)
 {
 	int i;
 
@@ -135,26 +118,6 @@ static const struct genl_ops *genl_get_cmd(u8 cmd, struct genl_family *family)
 	return NULL;
 }
 
-/* Of course we are going to have problems once we hit
- * 2^16 alive types, but that can only happen by year 2K
-*/
-static u16 genl_generate_id(void)
-{
-	static u16 id_gen_idx = GENL_MIN_ID;
-	int i;
-
-	for (i = 0; i <= GENL_MAX_ID - GENL_MIN_ID; i++) {
-		if (id_gen_idx != GENL_ID_VFS_DQUOT &&
-		    id_gen_idx != GENL_ID_PMCRAID &&
-		    !genl_family_find_byid(id_gen_idx))
-			return id_gen_idx;
-		if (++id_gen_idx > GENL_MAX_ID)
-			id_gen_idx = GENL_MIN_ID;
-	}
-
-	return 0;
-}
-
 static int genl_allocate_reserve_groups(int n_groups, int *first_id)
 {
 	unsigned long *new_groups;
@@ -295,7 +258,7 @@ static int genl_validate_assign_mc_groups(struct genl_family *family)
 	return err;
 }
 
-static void genl_unregister_mc_groups(struct genl_family *family)
+static void genl_unregister_mc_groups(const struct genl_family *family)
 {
 	struct net *net;
 	int i;
@@ -358,6 +321,7 @@ static int genl_validate_ops(const struct genl_family *family)
 int genl_register_family(struct genl_family *family)
 {
 	int err, i;
+	int start = GENL_START_ALLOC, end = GENL_MAX_ID;
 
 	err = genl_validate_ops(family);
 	if (err)
@@ -370,34 +334,20 @@ int genl_register_family(struct genl_family *family)
 		goto errout_locked;
 	}
 
+	/*
+	 * Sadly, a few cases need to be special-cased
+	 * due to them having previously abused the API
+	 * and having used their family ID also as their
+	 * multicast group ID, so we use reserved IDs
+	 * for both to be sure we can do that mapping.
+	 */
 	if (family == &genl_ctrl) {
-		family->id = GENL_ID_CTRL;
-	} else {
-		u16 newid;
-
-		/* this should be left zero in the struct */
-		WARN_ON(family->id);
-
-		/*
-		 * Sadly, a few cases need to be special-cased
-		 * due to them having previously abused the API
-		 * and having used their family ID also as their
-		 * multicast group ID, so we use reserved IDs
-		 * for both to be sure we can do that mapping.
-		 */
-		if (strcmp(family->name, "pmcraid") == 0)
-			newid = GENL_ID_PMCRAID;
-		else if (strcmp(family->name, "VFS_DQUOT") == 0)
-			newid = GENL_ID_VFS_DQUOT;
-		else
-			newid = genl_generate_id();
-
-		if (!newid) {
-			err = -ENOMEM;
-			goto errout_locked;
-		}
-
-		family->id = newid;
+		/* and this needs to be special for initial family lookups */
+		start = end = GENL_ID_CTRL;
+	} else if (strcmp(family->name, "pmcraid") == 0) {
+		start = end = GENL_ID_PMCRAID;
+	} else if (strcmp(family->name, "VFS_DQUOT") == 0) {
+		start = end = GENL_ID_VFS_DQUOT;
 	}
 
 	if (family->maxattr && !family->parallel_ops) {
@@ -410,11 +360,15 @@ int genl_register_family(struct genl_family *family)
 	} else
 		family->attrbuf = NULL;
 
+	family->id = idr_alloc(&genl_fam_idr, family,
+			       start, end + 1, GFP_KERNEL);
+	if (!family->id)
+		goto errout_locked;
+
 	err = genl_validate_assign_mc_groups(family);
 	if (err)
-		goto errout_locked;
+		goto errout_remove;
 
-	list_add_tail(&family->family_list, genl_family_chain(family->id));
 	genl_unlock_all();
 
 	/* send all events */
@@ -425,6 +379,8 @@ int genl_register_family(struct genl_family *family)
 
 	return 0;
 
+errout_remove:
+	idr_remove(&genl_fam_idr, family->id);
 errout_locked:
 	genl_unlock_all();
 	return err;
@@ -439,32 +395,29 @@ EXPORT_SYMBOL(genl_register_family);
  *
  * Returns 0 on success or a negative error code.
  */
-int genl_unregister_family(struct genl_family *family)
+int genl_unregister_family(const struct genl_family *family)
 {
-	struct genl_family *rc;
-
 	genl_lock_all();
 
-	list_for_each_entry(rc, genl_family_chain(family->id), family_list) {
-		if (family->id != rc->id || strcmp(rc->name, family->name))
-			continue;
+	if (genl_family_find_byid(family->id)) {
+		genl_unlock_all();
+		return -ENOENT;
+	}
 
-		genl_unregister_mc_groups(family);
+	genl_unregister_mc_groups(family);
 
-		list_del(&rc->family_list);
-		up_write(&cb_lock);
-		wait_event(genl_sk_destructing_waitq,
-			   atomic_read(&genl_sk_destructing_cnt) == 0);
-		genl_unlock();
+	idr_remove(&genl_fam_idr, family->id);
 
-		kfree(family->attrbuf);
-		genl_ctrl_event(CTRL_CMD_DELFAMILY, family, NULL, 0);
-		return 0;
-	}
+	up_write(&cb_lock);
+	wait_event(genl_sk_destructing_waitq,
+		   atomic_read(&genl_sk_destructing_cnt) == 0);
+	genl_unlock();
 
-	genl_unlock_all();
+	kfree(family->attrbuf);
 
-	return -ENOENT;
+	genl_ctrl_event(CTRL_CMD_DELFAMILY, family, NULL, 0);
+
+	return 0;
 }
 EXPORT_SYMBOL(genl_unregister_family);
 
@@ -480,7 +433,7 @@ EXPORT_SYMBOL(genl_unregister_family);
  * Returns pointer to user specific header
  */
 void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
-				struct genl_family *family, int flags, u8 cmd)
+		  const struct genl_family *family, int flags, u8 cmd)
 {
 	struct nlmsghdr *nlh;
 	struct genlmsghdr *hdr;
@@ -539,7 +492,7 @@ static int genl_lock_done(struct netlink_callback *cb)
 	return rc;
 }
 
-static int genl_family_rcv_msg(struct genl_family *family,
+static int genl_family_rcv_msg(const struct genl_family *family,
 			       struct sk_buff *skb,
 			       struct nlmsghdr *nlh)
 {
@@ -651,7 +604,7 @@ static int genl_family_rcv_msg(struct genl_family *family,
 
 static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	struct genl_family *family;
+	const struct genl_family *family;
 	int err;
 
 	family = genl_family_find_byid(nlh->nlmsg_type);
@@ -682,7 +635,7 @@ static void genl_rcv(struct sk_buff *skb)
 
 static struct genl_family genl_ctrl;
 
-static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
+static int ctrl_fill_info(const struct genl_family *family, u32 portid, u32 seq,
 			  u32 flags, struct sk_buff *skb, u8 cmd)
 {
 	void *hdr;
@@ -769,7 +722,7 @@ static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
 	return -EMSGSIZE;
 }
 
-static int ctrl_fill_mcgrp_info(struct genl_family *family,
+static int ctrl_fill_mcgrp_info(const struct genl_family *family,
 				const struct genl_multicast_group *grp,
 				int grp_id, u32 portid, u32 seq, u32 flags,
 				struct sk_buff *skb, u8 cmd)
@@ -812,37 +765,30 @@ static int ctrl_fill_mcgrp_info(struct genl_family *family,
 
 static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 {
-
-	int i, n = 0;
+	int n = 0;
 	struct genl_family *rt;
 	struct net *net = sock_net(skb->sk);
-	int chains_to_skip = cb->args[0];
-	int fams_to_skip = cb->args[1];
-
-	for (i = chains_to_skip; i < GENL_FAM_TAB_SIZE; i++) {
-		n = 0;
-		list_for_each_entry(rt, genl_family_chain(i), family_list) {
-			if (!rt->netnsok && !net_eq(net, &init_net))
-				continue;
-			if (++n < fams_to_skip)
-				continue;
-			if (ctrl_fill_info(rt, NETLINK_CB(cb->skb).portid,
-					   cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					   skb, CTRL_CMD_NEWFAMILY) < 0)
-				goto errout;
-		}
+	int fams_to_skip = cb->args[0];
+	unsigned int id;
 
-		fams_to_skip = 0;
-	}
+	idr_for_each_entry(&genl_fam_idr, rt, id) {
+		if (!rt->netnsok && !net_eq(net, &init_net))
+			continue;
+
+		if (n++ < fams_to_skip)
+			continue;
 
-errout:
-	cb->args[0] = i;
-	cb->args[1] = n;
+		if (ctrl_fill_info(rt, NETLINK_CB(cb->skb).portid,
+				   cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				   skb, CTRL_CMD_NEWFAMILY) < 0)
+			break;
+	}
 
+	cb->args[0] = n;
 	return skb->len;
 }
 
-static struct sk_buff *ctrl_build_family_msg(struct genl_family *family,
+static struct sk_buff *ctrl_build_family_msg(const struct genl_family *family,
 					     u32 portid, int seq, u8 cmd)
 {
 	struct sk_buff *skb;
@@ -862,7 +808,7 @@ static struct sk_buff *ctrl_build_family_msg(struct genl_family *family,
 }
 
 static struct sk_buff *
-ctrl_build_mcgrp_msg(struct genl_family *family,
+ctrl_build_mcgrp_msg(const struct genl_family *family,
 		     const struct genl_multicast_group *grp,
 		     int grp_id, u32 portid, int seq, u8 cmd)
 {
@@ -892,7 +838,7 @@ static const struct nla_policy ctrl_policy[CTRL_ATTR_MAX+1] = {
 static int ctrl_getfamily(struct sk_buff *skb, struct genl_info *info)
 {
 	struct sk_buff *msg;
-	struct genl_family *res = NULL;
+	const struct genl_family *res = NULL;
 	int err = -EINVAL;
 
 	if (info->attrs[CTRL_ATTR_FAMILY_ID]) {
@@ -936,7 +882,7 @@ static int ctrl_getfamily(struct sk_buff *skb, struct genl_info *info)
 	return genlmsg_reply(msg, info);
 }
 
-static int genl_ctrl_event(int event, struct genl_family *family,
+static int genl_ctrl_event(int event, const struct genl_family *family,
 			   const struct genl_multicast_group *grp,
 			   int grp_id)
 {
@@ -1005,25 +951,24 @@ static struct genl_family genl_ctrl = {
 
 static int genl_bind(struct net *net, int group)
 {
-	int i, err = -ENOENT;
+	struct genl_family *f;
+	int err = -ENOENT;
+	unsigned int id;
 
 	down_read(&cb_lock);
-	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
-		struct genl_family *f;
-
-		list_for_each_entry(f, genl_family_chain(i), family_list) {
-			if (group >= f->mcgrp_offset &&
-			    group < f->mcgrp_offset + f->n_mcgrps) {
-				int fam_grp = group - f->mcgrp_offset;
-
-				if (!f->netnsok && net != &init_net)
-					err = -ENOENT;
-				else if (f->mcast_bind)
-					err = f->mcast_bind(net, fam_grp);
-				else
-					err = 0;
-				break;
-			}
+
+	idr_for_each_entry(&genl_fam_idr, f, id) {
+		if (group >= f->mcgrp_offset &&
+		    group < f->mcgrp_offset + f->n_mcgrps) {
+			int fam_grp = group - f->mcgrp_offset;
+
+			if (!f->netnsok && net != &init_net)
+				err = -ENOENT;
+			else if (f->mcast_bind)
+				err = f->mcast_bind(net, fam_grp);
+			else
+				err = 0;
+			break;
 		}
 	}
 	up_read(&cb_lock);
@@ -1033,21 +978,19 @@ static int genl_bind(struct net *net, int group)
 
 static void genl_unbind(struct net *net, int group)
 {
-	int i;
+	struct genl_family *f;
+	unsigned int id;
 
 	down_read(&cb_lock);
-	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
-		struct genl_family *f;
 
-		list_for_each_entry(f, genl_family_chain(i), family_list) {
-			if (group >= f->mcgrp_offset &&
-			    group < f->mcgrp_offset + f->n_mcgrps) {
-				int fam_grp = group - f->mcgrp_offset;
+	idr_for_each_entry(&genl_fam_idr, f, id) {
+		if (group >= f->mcgrp_offset &&
+		    group < f->mcgrp_offset + f->n_mcgrps) {
+			int fam_grp = group - f->mcgrp_offset;
 
-				if (f->mcast_unbind)
-					f->mcast_unbind(net, fam_grp);
-				break;
-			}
+			if (f->mcast_unbind)
+				f->mcast_unbind(net, fam_grp);
+			break;
 		}
 	}
 	up_read(&cb_lock);
@@ -1087,10 +1030,7 @@ static struct pernet_operations genl_pernet_ops = {
 
 static int __init genl_init(void)
 {
-	int i, err;
-
-	for (i = 0; i < GENL_FAM_TAB_SIZE; i++)
-		INIT_LIST_HEAD(&family_ht[i]);
+	int err;
 
 	err = genl_register_family(&genl_ctrl);
 	if (err < 0)
@@ -1118,7 +1058,7 @@ subsys_initcall(genl_init);
  * You cannot use this function with a family that has parallel_ops
  * and you can only use it within (pre/post) doit/dumpit callbacks.
  */
-struct nlattr **genl_family_attrbuf(struct genl_family *family)
+struct nlattr **genl_family_attrbuf(const struct genl_family *family)
 {
 	if (!WARN_ON(family->parallel_ops))
 		lockdep_assert_held(&genl_mutex);
@@ -1156,8 +1096,9 @@ static int genlmsg_mcast(struct sk_buff *skb, u32 portid, unsigned long group,
 	return err;
 }
 
-int genlmsg_multicast_allns(struct genl_family *family, struct sk_buff *skb,
-			    u32 portid, unsigned int group, gfp_t flags)
+int genlmsg_multicast_allns(const struct genl_family *family,
+			    struct sk_buff *skb, u32 portid,
+			    unsigned int group, gfp_t flags)
 {
 	if (WARN_ON_ONCE(group >= family->n_mcgrps))
 		return -EINVAL;
@@ -1166,7 +1107,7 @@ int genlmsg_multicast_allns(struct genl_family *family, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(genlmsg_multicast_allns);
 
-void genl_notify(struct genl_family *family, struct sk_buff *skb,
+void genl_notify(const struct genl_family *family, struct sk_buff *skb,
 		 struct genl_info *info, u32 group, gfp_t flags)
 {
 	struct net *net = genl_info_net(info);
-- 
2.8.1
