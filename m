From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 16:56:46 +0200
Message-ID: <1183129006.4089.84.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net>
	 <1183122920.4089.63.camel@johannes.berg>  <468507C9.2000800@trash.net>
	 <1183124085.4089.66.camel@johannes.berg>  <46850CB8.8000509@trash.net>
	 <1183124981.4089.69.camel@johannes.berg>  <46850EDE.5020804@trash.net>
	 <1183125924.4089.73.camel@johannes.berg>
	 <1183126739.4089.76.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:55273 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757917AbXF2O6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 10:58:08 -0400
In-Reply-To: <1183126739.4089.76.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-06-29 at 16:19 +0200, Johannes Berg wrote:

> Uh huh, this reallocation is buggy. Fixed version below.

More breakage, sorry about the patch-spam.

Btw, I notice that the bug we talked about isn't present in practice
since we have no multicast users except for the always-present
controller :)

New patch below. I'll get this tested and maybe a bit nicer and I'll try
to fix the bug too, but not before the weekend.

---
 include/linux/genetlink.h |   13 ++++++
 include/net/genetlink.h   |   18 ++++++++
 net/netlink/genetlink.c   |   93 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 124 insertions(+)

--- wireless-dev.orig/include/net/genetlink.h	2007-06-26 16:58:42.154806179 +0200
+++ wireless-dev/include/net/genetlink.h	2007-06-29 15:40:35.547910932 +0200
@@ -5,6 +5,20 @@
 #include <net/netlink.h>
 
 /**
+ * struct genl_multicast_group - generic netlink multicast group
+ * @name: name of the multicast group, names are per-family
+ * @id: multicast group ID, assigned by the core, to use with
+ *      genlmsg_multicast().
+ * @list: list entry for linking
+ */
+struct genl_multicast_group
+{
+	struct list_head	list;		/* private */
+	char			name[GENL_NAMSIZ];
+	u32			id;
+};
+
+/**
  * struct genl_family - generic netlink family
  * @id: protocol family idenfitier
  * @hdrsize: length of user specific header in bytes
@@ -14,6 +28,7 @@
  * @attrbuf: buffer to store parsed attributes
  * @ops_list: list of all assigned operations
  * @family_list: family list
+ * @mcast_groups: multicast groups list
  */
 struct genl_family
 {
@@ -25,6 +40,7 @@ struct genl_family
 	struct nlattr **	attrbuf;	/* private */
 	struct list_head	ops_list;	/* private */
 	struct list_head	family_list;	/* private */
+	struct list_head	mcast_groups;	/* private */
 };
 
 /**
@@ -73,6 +89,8 @@ extern int genl_register_family(struct g
 extern int genl_unregister_family(struct genl_family *family);
 extern int genl_register_ops(struct genl_family *, struct genl_ops *ops);
 extern int genl_unregister_ops(struct genl_family *, struct genl_ops *ops);
+extern int genl_register_mc_group(struct genl_family *family,
+				  struct genl_multicast_group *grp);
 
 extern struct sock *genl_sock;
 
--- wireless-dev.orig/net/netlink/genetlink.c	2007-06-26 16:58:42.244806179 +0200
+++ wireless-dev/net/netlink/genetlink.c	2007-06-29 16:48:35.007910932 +0200
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
 
@@ -42,6 +44,16 @@ static void genl_unlock(void)
 #define GENL_FAM_TAB_MASK	(GENL_FAM_TAB_SIZE - 1)
 
 static struct list_head family_ht[GENL_FAM_TAB_SIZE];
+/*
+ * Bitmap of multicast groups that are currently in use.
+ *
+ * To avoid an allocation at boot of just one unsigned long,
+ * declare it global instead.
+ * Bit 1 is marked as already used since group 1 is the controller group.
+ */
+static unsigned long mc_group_start = 0x2;
+static unsigned long *mc_groups = &mc_group_start;
+static unsigned long mc_groups_longs = 1;
 
 static int genl_ctrl_event(int event, void *data);
 
@@ -116,6 +128,59 @@ static inline u16 genl_generate_id(void)
 	return id_gen_idx;
 }
 
+int genl_register_mc_group(struct genl_family *family,
+			   struct genl_multicast_group *grp)
+{
+	int id = find_first_zero_bit(mc_groups,
+				     mc_groups_longs * BITS_PER_LONG);
+	unsigned long *new_groups;
+	size_t nlen = (mc_groups_longs + 1) * sizeof(unsigned long);
+
+	if (id >= mc_groups_longs * BITS_PER_LONG) {
+		if (mc_groups == &mc_group_start) {
+			new_groups = kzalloc(nlen, GFP_KERNEL);
+			if (!mc_groups)
+				return -ENOMEM;
+			mc_groups = new_groups;
+			*mc_groups = mc_group_start;
+		} else {
+			new_groups = krealloc(mc_groups, nlen, GFP_KERNEL);
+			if (!new_groups)
+				return -ENOMEM;
+			mc_groups = new_groups;
+			mc_groups[mc_groups_longs] = 0;
+		}
+		mc_groups_longs++;
+	}
+
+	grp->id = id;
+	set_bit(id, mc_groups);
+	list_add_tail(&grp->list, &family->mcast_groups);
+
+	genl_ctrl_event(CTRL_CMD_NEWMCAST_GRP, family);
+
+	return 0;
+}
+EXPORT_SYMBOL(genl_register_mc_group);
+
+static void genl_unregister_mc_group(struct genl_multicast_group *grp)
+{
+	/*
+	 * TODO: fix multicast group re-use by clearing the bit
+	 *	 for this group in all genetlink sockets.
+	 */
+	clear_bit(grp->id, mc_groups);
+	list_del(&grp->list);
+}
+
+static void genl_unregister_mc_groups(struct genl_family *family)
+{
+	struct genl_multicast_group *grp, *tmp;
+
+	list_for_each_entry_safe(grp, tmp, &family->mcast_groups, list)
+		genl_unregister_mc_group(grp);
+}
+
 /**
  * genl_register_ops - register generic netlink operations
  * @family: generic netlink family
@@ -290,6 +355,8 @@ int genl_unregister_family(struct genl_f
 		return 0;
 	}
 
+	genl_unregister_mc_groups(family);
+
 	genl_unlock();
 
 	return -ENOENT;
@@ -410,6 +477,31 @@ static int ctrl_fill_info(struct genl_fa
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
 	return genlmsg_end(skb, hdr);
 
 nla_put_failure:
@@ -523,6 +615,7 @@ static int genl_ctrl_event(int event, vo
 	switch (event) {
 	case CTRL_CMD_NEWFAMILY:
 	case CTRL_CMD_DELFAMILY:
+	case CTRL_CMD_NEWMCAST_GRP:
 		msg = ctrl_build_msg(data, 0, 0, event);
 		if (IS_ERR(msg))
 			return PTR_ERR(msg);
--- wireless-dev.orig/include/linux/genetlink.h	2007-06-26 16:58:42.174806179 +0200
+++ wireless-dev/include/linux/genetlink.h	2007-06-29 16:00:05.687910932 +0200
@@ -39,6 +39,9 @@ enum {
 	CTRL_CMD_NEWOPS,
 	CTRL_CMD_DELOPS,
 	CTRL_CMD_GETOPS,
+	CTRL_CMD_NEWMCAST_GRP,
+	CTRL_CMD_DELMCAST_GRP, /* unused */
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


