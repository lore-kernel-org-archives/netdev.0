From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 8/8] genetlink: make multicast groups const, prevent abuse
Date: Sat, 16 Nov 2013 18:03:49 +0100
Message-ID: <1384621429-24543-9-git-send-email-johannes@sipsolutions.net>
References: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:57918 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140Ab3KPREC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 12:04:02 -0500
In-Reply-To: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Register generic netlink multicast groups as an array with
the family and give them contiguous group IDs. Then instead
of passing the global group ID to the various functions that
send messages, pass the ID relative to the family - for most
families that's just 0 because the only have one group.

This avoids the list_head and ID in each group, adding a new
field for the mcast group ID offset to the family.

At the same time, this allows us to prevent abusing groups
again like the quota and dropmon code did, since we can now
check that a family only uses a group it owns.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/acpi/event.c            |  26 ++--
 drivers/net/team/team.c         |  25 +---
 drivers/thermal/thermal_core.c  |  24 ++--
 fs/quota/netlink.c              |  15 ++-
 include/linux/genl_magic_func.h |  49 +++-----
 include/net/genetlink.h         |  47 ++++---
 net/core/drop_monitor.c         |  18 +--
 net/hsr/hsr_netlink.c           |  19 +--
 net/ieee802154/ieee802154.h     |   6 +-
 net/ieee802154/netlink.c        |  26 ++--
 net/ieee802154/nl-mac.c         |  22 ++--
 net/netlink/genetlink.c         | 273 ++++++++++++++++++++++++----------------
 net/nfc/netlink.c               |  51 +++-----
 net/openvswitch/datapath.c      |  43 +++----
 net/openvswitch/dp_notify.c     |   5 +-
 net/wimax/op-msg.c              |   3 +-
 net/wimax/stack.c               |  20 ++-
 net/wimax/wimax-internal.h      |   1 -
 net/wireless/nl80211.c          | 129 ++++++++-----------
 19 files changed, 371 insertions(+), 431 deletions(-)

diff --git a/drivers/acpi/event.c b/drivers/acpi/event.c
index 68a8755..aeb5aa6 100644
--- a/drivers/acpi/event.c
+++ b/drivers/acpi/event.c
@@ -78,15 +78,17 @@ enum {
 #define ACPI_GENL_VERSION		0x01
 #define ACPI_GENL_MCAST_GROUP_NAME 	"acpi_mc_group"
 
+static const struct genl_multicast_group acpi_event_mcgrps[] = {
+	{ .name = ACPI_GENL_MCAST_GROUP_NAME, },
+};
+
 static struct genl_family acpi_event_genl_family = {
 	.id = GENL_ID_GENERATE,
 	.name = ACPI_GENL_FAMILY_NAME,
 	.version = ACPI_GENL_VERSION,
 	.maxattr = ACPI_GENL_ATTR_MAX,
-};
-
-static struct genl_multicast_group acpi_event_mcgrp = {
-	.name = ACPI_GENL_MCAST_GROUP_NAME,
+	.mcgrps = acpi_event_mcgrps,
+	.n_mcgrps = ARRAY_SIZE(acpi_event_mcgrps),
 };
 
 int acpi_bus_generate_netlink_event(const char *device_class,
@@ -146,8 +148,7 @@ int acpi_bus_generate_netlink_event(const char *device_class,
 		return result;
 	}
 
-	genlmsg_multicast(&acpi_event_genl_family,
-			  skb, 0, acpi_event_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&acpi_event_genl_family, skb, 0, 0, GFP_ATOMIC);
 	return 0;
 }
 
@@ -155,18 +156,7 @@ EXPORT_SYMBOL(acpi_bus_generate_netlink_event);
 
 static int acpi_event_genetlink_init(void)
 {
-	int result;
-
-	result = genl_register_family(&acpi_event_genl_family);
-	if (result)
-		return result;
-
-	result = genl_register_mc_group(&acpi_event_genl_family,
-					&acpi_event_mcgrp);
-	if (result)
-		genl_unregister_family(&acpi_event_genl_family);
-
-	return result;
+	return genl_register_family(&acpi_event_genl_family);
 }
 
 #else
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 2721e29..0715de5 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2670,16 +2670,15 @@ static const struct genl_ops team_nl_ops[] = {
 	},
 };
 
-static struct genl_multicast_group team_change_event_mcgrp = {
-	.name = TEAM_GENL_CHANGE_EVENT_MC_GRP_NAME,
+static const struct genl_multicast_group team_nl_mcgrps[] = {
+	{ .name = TEAM_GENL_CHANGE_EVENT_MC_GRP_NAME, },
 };
 
 static int team_nl_send_multicast(struct sk_buff *skb,
 				  struct team *team, u32 portid)
 {
 	return genlmsg_multicast_netns(&team_nl_family, dev_net(team->dev),
-				       skb, 0, team_change_event_mcgrp.id,
-				       GFP_KERNEL);
+				       skb, 0, 0, GFP_KERNEL);
 }
 
 static int team_nl_send_event_options_get(struct team *team,
@@ -2698,22 +2697,8 @@ static int team_nl_send_event_port_get(struct team *team,
 
 static int team_nl_init(void)
 {
-	int err;
-
-	err = genl_register_family_with_ops(&team_nl_family, team_nl_ops);
-	if (err)
-		return err;
-
-	err = genl_register_mc_group(&team_nl_family, &team_change_event_mcgrp);
-	if (err)
-		goto err_change_event_grp_reg;
-
-	return 0;
-
-err_change_event_grp_reg:
-	genl_unregister_family(&team_nl_family);
-
-	return err;
+	return genl_register_family_with_ops_groups(&team_nl_family, team_nl_ops,
+						    team_nl_mcgrps);
 }
 
 static void team_nl_fini(void)
diff --git a/drivers/thermal/thermal_core.c b/drivers/thermal/thermal_core.c
index 2570a94..19edd61 100644
--- a/drivers/thermal/thermal_core.c
+++ b/drivers/thermal/thermal_core.c
@@ -1606,15 +1606,17 @@ exit:
 EXPORT_SYMBOL_GPL(thermal_zone_get_zone_by_name);
 
 #ifdef CONFIG_NET
+static const struct genl_multicast_group thermal_event_mcgrps[] = {
+	{ .name = THERMAL_GENL_MCAST_GROUP_NAME, },
+};
+
 static struct genl_family thermal_event_genl_family = {
 	.id = GENL_ID_GENERATE,
 	.name = THERMAL_GENL_FAMILY_NAME,
 	.version = THERMAL_GENL_VERSION,
 	.maxattr = THERMAL_GENL_ATTR_MAX,
-};
-
-static struct genl_multicast_group thermal_event_mcgrp = {
-	.name = THERMAL_GENL_MCAST_GROUP_NAME,
+	.mcgrps = thermal_event_mcgrps,
+	.n_mcgrps = ARRAY_SIZE(thermal_event_mcgrps),
 };
 
 int thermal_generate_netlink_event(struct thermal_zone_device *tz,
@@ -1676,7 +1678,7 @@ int thermal_generate_netlink_event(struct thermal_zone_device *tz,
 	}
 
 	result = genlmsg_multicast(&thermal_event_genl_family, skb, 0,
-				   thermal_event_mcgrp.id, GFP_ATOMIC);
+				   0, GFP_ATOMIC);
 	if (result)
 		dev_err(&tz->device, "Failed to send netlink event:%d", result);
 
@@ -1686,17 +1688,7 @@ EXPORT_SYMBOL_GPL(thermal_generate_netlink_event);
 
 static int genetlink_init(void)
 {
-	int result;
-
-	result = genl_register_family(&thermal_event_genl_family);
-	if (result)
-		return result;
-
-	result = genl_register_mc_group(&thermal_event_genl_family,
-					&thermal_event_mcgrp);
-	if (result)
-		genl_unregister_family(&thermal_event_genl_family);
-	return result;
+	return genl_register_family(&thermal_event_genl_family);
 }
 
 static void genetlink_exit(void)
diff --git a/fs/quota/netlink.c b/fs/quota/netlink.c
index 2e2220d..b8ae6f0 100644
--- a/fs/quota/netlink.c
+++ b/fs/quota/netlink.c
@@ -9,6 +9,10 @@
 #include <net/netlink.h>
 #include <net/genetlink.h>
 
+static const struct genl_multicast_group quota_mcgrps[] = {
+	{ .name = "VFS_DQUOT", /* not really used */ },
+};
+
 /* Netlink family structure for quota */
 static struct genl_family quota_genl_family = {
 	/*
@@ -22,10 +26,8 @@ static struct genl_family quota_genl_family = {
 	.name = "VFS_DQUOT",
 	.version = 1,
 	.maxattr = QUOTA_NL_A_MAX,
-};
-
-static struct genl_multicast_group quota_mcgrp = {
-	.name = "VFS_DQUOT", /* not really used */
+	.mcgrps = quota_mcgrps,
+	.n_mcgrps = ARRAY_SIZE(quota_mcgrps),
 };
 
 /**
@@ -88,7 +90,7 @@ void quota_send_warning(struct kqid qid, dev_t dev,
 		goto attr_err_out;
 	genlmsg_end(skb, msg_head);
 
-	genlmsg_multicast(&quota_genl_family, skb, 0, quota_mcgrp.id, GFP_NOFS);
+	genlmsg_multicast(&quota_genl_family, skb, 0, 0, GFP_NOFS);
 	return;
 attr_err_out:
 	printk(KERN_ERR "VFS: Not enough space to compose quota message!\n");
@@ -102,9 +104,6 @@ static int __init quota_init(void)
 	if (genl_register_family(&quota_genl_family) != 0)
 		printk(KERN_ERR
 		       "VFS: Failed to create quota netlink interface.\n");
-	if (genl_register_mc_group(&quota_genl_family, &quota_mcgrp))
-		printk(KERN_ERR
-		       "VFS: Failed to register quota mcast group.\n");
 	return 0;
 };
 
diff --git a/include/linux/genl_magic_func.h b/include/linux/genl_magic_func.h
index 5b9b8ae..c0894dd 100644
--- a/include/linux/genl_magic_func.h
+++ b/include/linux/genl_magic_func.h
@@ -273,49 +273,40 @@ static struct genl_family ZZZ_genl_family __read_mostly = {
  * Magic: define multicast groups
  * Magic: define multicast group registration helper
  */
+#define ZZZ_genl_mcgrps		CONCAT_(GENL_MAGIC_FAMILY, _genl_mcgrps)
+static const struct genl_multicast_group ZZZ_genl_mcgrps[] = {
+#undef GENL_mc_group
+#define GENL_mc_group(group) { .name = #group, },
+#include GENL_MAGIC_INCLUDE_FILE
+};
+
+enum CONCAT_(GENL_MAGIC_FAMILY, group_ids) {
+#undef GENL_mc_group
+#define GENL_mc_group(group) CONCAT_(GENL_MAGIC_FAMILY, _group_ ## group),
+#include GENL_MAGIC_INCLUDE_FILE
+};
+
 #undef GENL_mc_group
 #define GENL_mc_group(group)						\
-static struct genl_multicast_group					\
-CONCAT_(GENL_MAGIC_FAMILY, _mcg_ ## group) __read_mostly = {		\
-	.name = #group,							\
-};									\
 static int CONCAT_(GENL_MAGIC_FAMILY, _genl_multicast_ ## group)(	\
 	struct sk_buff *skb, gfp_t flags)				\
 {									\
 	unsigned int group_id =						\
-		CONCAT_(GENL_MAGIC_FAMILY, _mcg_ ## group).id;	\
-	if (!group_id)							\
-		return -EINVAL;						\
+		CONCAT_(GENL_MAGIC_FAMILY, _group_ ## group);		\
 	return genlmsg_multicast(&ZZZ_genl_family, skb, 0,		\
 				 group_id, flags);			\
 }
 
 #include GENL_MAGIC_INCLUDE_FILE
 
-int CONCAT_(GENL_MAGIC_FAMILY, _genl_register)(void)
-{
-	int err = genl_register_family_with_ops(&ZZZ_genl_family, ZZZ_genl_ops);
-	if (err)
-		return err;
-#undef GENL_mc_group
-#define GENL_mc_group(group)						\
-	err = genl_register_mc_group(&ZZZ_genl_family,			\
-		&CONCAT_(GENL_MAGIC_FAMILY, _mcg_ ## group));		\
-	if (err)							\
-		goto fail;						\
-	else								\
-		pr_info("%s: mcg %s: %u\n", #group,			\
-			__stringify(GENL_MAGIC_FAMILY),			\
-			CONCAT_(GENL_MAGIC_FAMILY, _mcg_ ## group).id);
-
-#include GENL_MAGIC_INCLUDE_FILE
-
 #undef GENL_mc_group
 #define GENL_mc_group(group)
-	return 0;
-fail:
-	genl_unregister_family(&ZZZ_genl_family);
-	return err;
+
+int CONCAT_(GENL_MAGIC_FAMILY, _genl_register)(void)
+{
+	return genl_register_family_with_ops_groups(&ZZZ_genl_family,	\
+						    ZZZ_genl_ops,	\
+						    ZZZ_genl_mcgrps);
 }
 
 void CONCAT_(GENL_MAGIC_FAMILY, _genl_unregister)(void)
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 3c7511b..dca75ad 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -10,14 +10,9 @@
 /**
  * struct genl_multicast_group - generic netlink multicast group
  * @name: name of the multicast group, names are per-family
- * @id: multicast group ID, assigned by the core, to use with
- *      genlmsg_multicast().
- * @list: list entry for linking
  */
 struct genl_multicast_group {
-	struct list_head	list;		/* private */
 	char			name[GENL_NAMSIZ];
-	u32			id;
 };
 
 struct genl_ops;
@@ -38,7 +33,9 @@ struct genl_info;
  *	undo operations done by pre_doit, for example release locks
  * @attrbuf: buffer to store parsed attributes
  * @family_list: family list
- * @mcast_groups: multicast groups list
+ * @mcgrps: multicast groups used by this family (private)
+ * @n_mcgrps: number of multicast groups (private)
+ * @mcgrp_offset: starting number of multicast group IDs in this family
  * @ops: the operations supported by this family (private)
  * @n_ops: number of operations supported by this family (private)
  */
@@ -58,9 +55,11 @@ struct genl_family {
 					     struct genl_info *info);
 	struct nlattr **	attrbuf;	/* private */
 	const struct genl_ops *	ops;		/* private */
+	const struct genl_multicast_group *mcgrps; /* private */
 	unsigned int		n_ops;		/* private */
+	unsigned int		n_mcgrps;	/* private */
+	unsigned int		mcgrp_offset;	/* private */
 	struct list_head	family_list;	/* private */
-	struct list_head	mcast_groups;	/* private */
 	struct module		*module;
 };
 
@@ -150,22 +149,30 @@ static inline int genl_register_family(struct genl_family *family)
  *
  * Return 0 on success or a negative error code.
  */
-static inline int _genl_register_family_with_ops(struct genl_family *family,
-						 const struct genl_ops *ops,
-						 size_t n_ops)
+static inline int
+_genl_register_family_with_ops_grps(struct genl_family *family,
+				    const struct genl_ops *ops, size_t n_ops,
+				    const struct genl_multicast_group *mcgrps,
+				    size_t n_mcgrps)
 {
 	family->module = THIS_MODULE;
 	family->ops = ops;
 	family->n_ops = n_ops;
+	family->mcgrps = mcgrps;
+	family->n_mcgrps = n_mcgrps;
 	return __genl_register_family(family);
 }
 
-#define genl_register_family_with_ops(family, ops)	\
-	_genl_register_family_with_ops((family), (ops), ARRAY_SIZE(ops))
+#define genl_register_family_with_ops(family, ops)			\
+	_genl_register_family_with_ops_grps((family),			\
+					    (ops), ARRAY_SIZE(ops),	\
+					    NULL, 0)
+#define genl_register_family_with_ops_groups(family, ops, grps)	\
+	_genl_register_family_with_ops_grps((family),			\
+					    (ops), ARRAY_SIZE(ops),	\
+					    (grps), ARRAY_SIZE(grps))
 
 int genl_unregister_family(struct genl_family *family);
-int genl_register_mc_group(struct genl_family *family,
-			   struct genl_multicast_group *grp);
 void genl_notify(struct genl_family *family,
 		 struct sk_buff *skb, struct net *net, u32 portid,
 		 u32 group, struct nlmsghdr *nlh, gfp_t flags);
@@ -251,13 +258,16 @@ static inline void genlmsg_cancel(struct sk_buff *skb, void *hdr)
  * @net: the net namespace
  * @skb: netlink message as socket buffer
  * @portid: own netlink portid to avoid sending to yourself
- * @group: multicast group id
+ * @group: offset of multicast group in groups array
  * @flags: allocation flags
  */
 static inline int genlmsg_multicast_netns(struct genl_family *family,
 					  struct net *net, struct sk_buff *skb,
 					  u32 portid, unsigned int group, gfp_t flags)
 {
+	if (group >= family->n_mcgrps)
+		return -EINVAL;
+	group = family->mcgrp_offset + group;
 	return nlmsg_multicast(net->genl_sock, skb, portid, group, flags);
 }
 
@@ -266,13 +276,16 @@ static inline int genlmsg_multicast_netns(struct genl_family *family,
  * @family: the generic netlink family
  * @skb: netlink message as socket buffer
  * @portid: own netlink portid to avoid sending to yourself
- * @group: multicast group id
+ * @group: offset of multicast group in groups array
  * @flags: allocation flags
  */
 static inline int genlmsg_multicast(struct genl_family *family,
 				    struct sk_buff *skb, u32 portid,
 				    unsigned int group, gfp_t flags)
 {
+	if (group >= family->n_mcgrps)
+		return -EINVAL;
+	group = family->mcgrp_offset + group;
 	return genlmsg_multicast_netns(family, &init_net, skb,
 				       portid, group, flags);
 }
@@ -282,7 +295,7 @@ static inline int genlmsg_multicast(struct genl_family *family,
  * @family: the generic netlink family
  * @skb: netlink message as socket buffer
  * @portid: own netlink portid to avoid sending to yourself
- * @group: multicast group id
+ * @group: offset of multicast group in groups array
  * @flags: allocation flags
  *
  * This function must hold the RTNL or rcu_read_lock().
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 1eab1dc..9589718 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -106,8 +106,8 @@ static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
 	return skb;
 }
 
-static struct genl_multicast_group dm_mcgrp = {
-	.name = "events",
+static struct genl_multicast_group dropmon_mcgrps[] = {
+	{ .name = "events", },
 };
 
 static void send_dm_alert(struct work_struct *work)
@@ -121,7 +121,7 @@ static void send_dm_alert(struct work_struct *work)
 
 	if (skb)
 		genlmsg_multicast(&net_drop_monitor_family, skb, 0,
-				  dm_mcgrp.id, GFP_KERNEL);
+				  0, GFP_KERNEL);
 }
 
 /*
@@ -369,19 +369,13 @@ static int __init init_net_drop_monitor(void)
 		return -ENOSPC;
 	}
 
-	rc = genl_register_family_with_ops(&net_drop_monitor_family,
-					   dropmon_ops);
+	rc = genl_register_family_with_ops_groups(&net_drop_monitor_family,
+						  dropmon_ops, dropmon_mcgrps);
 	if (rc) {
 		pr_err("Could not create drop monitor netlink family\n");
 		return rc;
 	}
-
-	rc = genl_register_mc_group(&net_drop_monitor_family, &dm_mcgrp);
-	if (rc) {
-		pr_err("Failed to register drop monitor mcast group\n");
-		goto out_unreg;
-	}
-	WARN_ON(dm_mcgrp.id != NET_DM_GRP_ALERT);
+	WARN_ON(net_drop_monitor_family.mcgrp_offset != NET_DM_GRP_ALERT);
 
 	rc = register_netdevice_notifier(&dropmon_net_notifier);
 	if (rc < 0) {
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 0009416..5325af8 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -90,8 +90,8 @@ static struct genl_family hsr_genl_family = {
 	.maxattr = HSR_A_MAX,
 };
 
-static struct genl_multicast_group hsr_network_genl_mcgrp = {
-	.name = "hsr-network",
+static const struct genl_multicast_group hsr_mcgrps[] = {
+	{ .name = "hsr-network", },
 };
 
 
@@ -129,8 +129,7 @@ void hsr_nl_ringerror(struct hsr_priv *hsr_priv, unsigned char addr[ETH_ALEN],
 		goto nla_put_failure;
 
 	genlmsg_end(skb, msg_head);
-	genlmsg_multicast(&hsr_genl_family, skb, 0,
-			  hsr_network_genl_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&hsr_genl_family, skb, 0, 0, GFP_ATOMIC);
 
 	return;
 
@@ -164,8 +163,7 @@ void hsr_nl_nodedown(struct hsr_priv *hsr_priv, unsigned char addr[ETH_ALEN])
 		goto nla_put_failure;
 
 	genlmsg_end(skb, msg_head);
-	genlmsg_multicast(&hsr_genl_family, skb, 0,
-			  hsr_network_genl_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&hsr_genl_family, skb, 0, 0, GFP_ATOMIC);
 
 	return;
 
@@ -416,18 +414,13 @@ int __init hsr_netlink_init(void)
 	if (rc)
 		goto fail_rtnl_link_register;
 
-	rc = genl_register_family_with_ops(&hsr_genl_family, hsr_ops);
+	rc = genl_register_family_with_ops_groups(&hsr_genl_family, hsr_ops,
+						  hsr_mcgrps);
 	if (rc)
 		goto fail_genl_register_family;
 
-	rc = genl_register_mc_group(&hsr_genl_family, &hsr_network_genl_mcgrp);
-	if (rc)
-		goto fail_genl_register_mc_group;
-
 	return 0;
 
-fail_genl_register_mc_group:
-	genl_unregister_family(&hsr_genl_family);
 fail_genl_register_family:
 	rtnl_link_unregister(&hsr_link_ops);
 fail_rtnl_link_register:
diff --git a/net/ieee802154/ieee802154.h b/net/ieee802154/ieee802154.h
index 14d5dab..cee4425 100644
--- a/net/ieee802154/ieee802154.h
+++ b/net/ieee802154/ieee802154.h
@@ -54,8 +54,10 @@ int ieee802154_dump_phy(struct sk_buff *skb, struct netlink_callback *cb);
 int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info);
 int ieee802154_del_iface(struct sk_buff *skb, struct genl_info *info);
 
-extern struct genl_multicast_group ieee802154_coord_mcgrp;
-extern struct genl_multicast_group ieee802154_beacon_mcgrp;
+enum ieee802154_mcgrp_ids {
+	IEEE802154_COORD_MCGRP,
+	IEEE802154_BEACON_MCGRP,
+};
 
 int ieee802154_associate_req(struct sk_buff *skb, struct genl_info *info);
 int ieee802154_associate_resp(struct sk_buff *skb, struct genl_info *info);
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 5172f46..43f1b2b 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -125,25 +125,17 @@ static const struct genl_ops ieee8021154_ops[] = {
 			ieee802154_dump_iface),
 };
 
-int __init ieee802154_nl_init(void)
-{
-	int rc;
-
-	rc = genl_register_family_with_ops(&nl802154_family, ieee8021154_ops);
-	if (rc)
-		return rc;
+static const struct genl_multicast_group ieee802154_mcgrps[] = {
+	[IEEE802154_COORD_MCGRP] = { .name = IEEE802154_MCAST_COORD_NAME, },
+	[IEEE802154_BEACON_MCGRP] = { .name = IEEE802154_MCAST_BEACON_NAME, },
+};
 
-	rc = genl_register_mc_group(&nl802154_family, &ieee802154_coord_mcgrp);
-	if (rc)
-		goto fail;
 
-	rc = genl_register_mc_group(&nl802154_family, &ieee802154_beacon_mcgrp);
-	if (rc)
-		goto fail;
-	return 0;
-fail:
-	genl_unregister_family(&nl802154_family);
-	return rc;
+int __init ieee802154_nl_init(void)
+{
+	return genl_register_family_with_ops_groups(&nl802154_family,
+						    ieee8021154_ops,
+						    ieee802154_mcgrps);
 }
 
 void __exit ieee802154_nl_exit(void)
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index 28d4930..ba5c1e0 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -39,14 +39,6 @@
 
 #include "ieee802154.h"
 
-struct genl_multicast_group ieee802154_coord_mcgrp = {
-	.name		= IEEE802154_MCAST_COORD_NAME,
-};
-
-struct genl_multicast_group ieee802154_beacon_mcgrp = {
-	.name		= IEEE802154_MCAST_BEACON_NAME,
-};
-
 int ieee802154_nl_assoc_indic(struct net_device *dev,
 		struct ieee802154_addr *addr, u8 cap)
 {
@@ -72,7 +64,7 @@ int ieee802154_nl_assoc_indic(struct net_device *dev,
 	    nla_put_u8(msg, IEEE802154_ATTR_CAPABILITY, cap))
 		goto nla_put_failure;
 
-	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
+	return ieee802154_nl_mcast(msg, IEEE802154_COORD_MCGRP);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -98,7 +90,7 @@ int ieee802154_nl_assoc_confirm(struct net_device *dev, u16 short_addr,
 	    nla_put_u16(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_STATUS, status))
 		goto nla_put_failure;
-	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
+	return ieee802154_nl_mcast(msg, IEEE802154_COORD_MCGRP);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -133,7 +125,7 @@ int ieee802154_nl_disassoc_indic(struct net_device *dev,
 	}
 	if (nla_put_u8(msg, IEEE802154_ATTR_REASON, reason))
 		goto nla_put_failure;
-	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
+	return ieee802154_nl_mcast(msg, IEEE802154_COORD_MCGRP);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -157,7 +149,7 @@ int ieee802154_nl_disassoc_confirm(struct net_device *dev, u8 status)
 		    dev->dev_addr) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_STATUS, status))
 		goto nla_put_failure;
-	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
+	return ieee802154_nl_mcast(msg, IEEE802154_COORD_MCGRP);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -183,7 +175,7 @@ int ieee802154_nl_beacon_indic(struct net_device *dev,
 	    nla_put_u16(msg, IEEE802154_ATTR_COORD_SHORT_ADDR, coord_addr) ||
 	    nla_put_u16(msg, IEEE802154_ATTR_COORD_PAN_ID, panid))
 		goto nla_put_failure;
-	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
+	return ieee802154_nl_mcast(msg, IEEE802154_COORD_MCGRP);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -214,7 +206,7 @@ int ieee802154_nl_scan_confirm(struct net_device *dev,
 	    (edl &&
 	     nla_put(msg, IEEE802154_ATTR_ED_LIST, 27, edl)))
 		goto nla_put_failure;
-	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
+	return ieee802154_nl_mcast(msg, IEEE802154_COORD_MCGRP);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -238,7 +230,7 @@ int ieee802154_nl_start_confirm(struct net_device *dev, u8 status)
 		    dev->dev_addr) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_STATUS, status))
 		goto nla_put_failure;
-	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
+	return ieee802154_nl_mcast(msg, IEEE802154_COORD_MCGRP);
 
 nla_put_failure:
 	nlmsg_free(msg);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 0e1e1fb..67b0fe8 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -69,16 +69,20 @@ static struct list_head family_ht[GENL_FAM_TAB_SIZE];
  * abuses the API and thinks it can statically use group 1.
  * That group will typically conflict with other groups that
  * any proper users use.
+ * Bit 16 is marked as used since it's used for generic netlink
+ * and the code no longer marks pre-reserved IDs as used.
  * Bit 17 is marked as already used since the VFS quota code
  * also abused this API and relied on family == group ID, we
  * cater to that by giving it a static family and group ID.
  */
-static unsigned long mc_group_start = 0x3 | BIT(GENL_ID_VFS_DQUOT);
+static unsigned long mc_group_start = 0x3 | BIT(GENL_ID_CTRL) |
+				      BIT(GENL_ID_VFS_DQUOT);
 static unsigned long *mc_groups = &mc_group_start;
 static unsigned long mc_groups_longs = 1;
 
 static int genl_ctrl_event(int event, struct genl_family *family,
-			   struct genl_multicast_group *grp);
+			   const struct genl_multicast_group *grp,
+			   int grp_id);
 
 static inline unsigned int genl_family_hash(unsigned int id)
 {
@@ -144,66 +148,108 @@ static u16 genl_generate_id(void)
 	return 0;
 }
 
-static struct genl_multicast_group notify_grp;
-
-/**
- * genl_register_mc_group - register a multicast group
- *
- * Registers the specified multicast group and notifies userspace
- * about the new group.
- *
- * Returns 0 on success or a negative error code.
- *
- * @family: The generic netlink family the group shall be registered for.
- * @grp: The group to register, must have a name.
- */
-int genl_register_mc_group(struct genl_family *family,
-			   struct genl_multicast_group *grp)
+static int genl_allocate_reserve_groups(int n_groups, int *first_id)
 {
-	int id;
 	unsigned long *new_groups;
-	int err = 0;
+	int start = 0;
+	int i;
+	int id;
+	bool fits;
+
+	do {
+		if (start == 0)
+			id = find_first_zero_bit(mc_groups,
+						 mc_groups_longs *
+						 BITS_PER_LONG);
+		else
+			id = find_next_zero_bit(mc_groups,
+						mc_groups_longs * BITS_PER_LONG,
+						start);
+
+		fits = true;
+		for (i = id;
+		     i < min_t(int, id + n_groups,
+			       mc_groups_longs * BITS_PER_LONG);
+		     i++) {
+			if (test_bit(i, mc_groups)) {
+				start = i;
+				fits = false;
+				break;
+			}
+		}
 
-	BUG_ON(grp->name[0] == '\0');
-	BUG_ON(memchr(grp->name, '\0', GENL_NAMSIZ) == NULL);
+		if (id >= mc_groups_longs * BITS_PER_LONG) {
+			unsigned long new_longs = mc_groups_longs +
+						  BITS_TO_LONGS(n_groups);
+			size_t nlen = new_longs * sizeof(unsigned long);
+
+			if (mc_groups == &mc_group_start) {
+				new_groups = kzalloc(nlen, GFP_KERNEL);
+				if (!new_groups)
+					return -ENOMEM;
+				mc_groups = new_groups;
+				*mc_groups = mc_group_start;
+			} else {
+				new_groups = krealloc(mc_groups, nlen,
+						      GFP_KERNEL);
+				if (!new_groups)
+					return -ENOMEM;
+				mc_groups = new_groups;
+				for (i = 0; i < BITS_TO_LONGS(n_groups); i++)
+					mc_groups[mc_groups_longs + i] = 0;
+			}
+			mc_groups_longs = new_longs;
+		}
+	} while (!fits);
 
-	genl_lock_all();
+	for (i = id; i < id + n_groups; i++)
+		set_bit(i, mc_groups);
+	*first_id = id;
+	return 0;
+}
+
+static struct genl_family genl_ctrl;
+
+static int genl_validate_assign_mc_groups(struct genl_family *family)
+{
+	int first_id;
+	int n_groups = family->n_mcgrps;
+	int err, i;
+
+	if (!n_groups)
+		return 0;
+
+	for (i = 0; i < n_groups; i++) {
+		const struct genl_multicast_group *grp = &family->mcgrps[i];
+
+		if (WARN_ON(grp->name[0] == '\0'))
+			return -EINVAL;
+		if (WARN_ON(memchr(grp->name, '\0', GENL_NAMSIZ) == NULL))
+			return -EINVAL;
+	}
 
 	/* special-case our own group and hacks */
-	if (grp == &notify_grp)
-		id = GENL_ID_CTRL;
-	else if (strcmp(family->name, "NET_DM") == 0)
-		id = 1;
-	else if (strcmp(family->name, "VFS_DQUOT") == 0)
-		id = GENL_ID_VFS_DQUOT;
-	else
-		id = find_first_zero_bit(mc_groups,
-					 mc_groups_longs * BITS_PER_LONG);
-
-
-	if (id >= mc_groups_longs * BITS_PER_LONG) {
-		size_t nlen = (mc_groups_longs + 1) * sizeof(unsigned long);
-
-		if (mc_groups == &mc_group_start) {
-			new_groups = kzalloc(nlen, GFP_KERNEL);
-			if (!new_groups) {
-				err = -ENOMEM;
-				goto out;
-			}
-			mc_groups = new_groups;
-			*mc_groups = mc_group_start;
-		} else {
-			new_groups = krealloc(mc_groups, nlen, GFP_KERNEL);
-			if (!new_groups) {
-				err = -ENOMEM;
-				goto out;
-			}
-			mc_groups = new_groups;
-			mc_groups[mc_groups_longs] = 0;
-		}
-		mc_groups_longs++;
+	if (family == &genl_ctrl) {
+		first_id = GENL_ID_CTRL;
+		BUG_ON(n_groups != 1);
+	} else if (strcmp(family->name, "NET_DM") == 0) {
+		first_id = 1;
+		BUG_ON(n_groups != 1);
+	} else if (strcmp(family->name, "VFS_DQUOT") == 0) {
+		first_id = GENL_ID_VFS_DQUOT;
+		BUG_ON(n_groups != 1);
+	} else {
+		err = genl_allocate_reserve_groups(n_groups, &first_id);
+		if (err)
+			return err;
 	}
 
+	family->mcgrp_offset = first_id;
+
+	/* if still initializing, can't and don't need to to realloc bitmaps */
+	if (!init_net.genl_sock)
+		return 0;
+
 	if (family->netnsok) {
 		struct net *net;
 
@@ -221,7 +267,7 @@ int genl_register_mc_group(struct genl_family *family,
 				 */
 				rcu_read_unlock();
 				netlink_table_ungrab();
-				goto out;
+				return err;
 			}
 		}
 		rcu_read_unlock();
@@ -230,45 +276,35 @@ int genl_register_mc_group(struct genl_family *family,
 		err = netlink_change_ngroups(init_net.genl_sock,
 					     mc_groups_longs * BITS_PER_LONG);
 		if (err)
-			goto out;
+			return err;
 	}
 
-	grp->id = id;
-	set_bit(id, mc_groups);
-	list_add_tail(&grp->list, &family->mcast_groups);
-
-	genl_ctrl_event(CTRL_CMD_NEWMCAST_GRP, family, grp);
- out:
-	genl_unlock_all();
-	return err;
+	return 0;
 }
-EXPORT_SYMBOL(genl_register_mc_group);
 
-static void __genl_unregister_mc_group(struct genl_family *family,
-				       struct genl_multicast_group *grp)
+static void genl_unregister_mc_groups(struct genl_family *family)
 {
 	struct net *net;
+	int i;
 
 	netlink_table_grab();
 	rcu_read_lock();
-	for_each_net_rcu(net)
-		__netlink_clear_multicast_users(net->genl_sock, grp->id);
+	for_each_net_rcu(net) {
+		for (i = 0; i < family->n_mcgrps; i++)
+			__netlink_clear_multicast_users(
+				net->genl_sock, family->mcgrp_offset + i);
+	}
 	rcu_read_unlock();
 	netlink_table_ungrab();
 
-	if (grp->id != 1)
-		clear_bit(grp->id, mc_groups);
-	list_del(&grp->list);
-	genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, family, grp);
-	grp->id = 0;
-}
-
-static void genl_unregister_mc_groups(struct genl_family *family)
-{
-	struct genl_multicast_group *grp, *tmp;
+	for (i = 0; i < family->n_mcgrps; i++) {
+		int grp_id = family->mcgrp_offset + i;
 
-	list_for_each_entry_safe(grp, tmp, &family->mcast_groups, list)
-		__genl_unregister_mc_group(family, grp);
+		if (grp_id != 1)
+			clear_bit(grp_id, mc_groups);
+		genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, family,
+				&family->mcgrps[i], grp_id);
+	}
 }
 
 static int genl_validate_ops(struct genl_family *family)
@@ -314,7 +350,7 @@ static int genl_validate_ops(struct genl_family *family)
  */
 int __genl_register_family(struct genl_family *family)
 {
-	int err = -EINVAL;
+	int err = -EINVAL, i;
 
 	if (family->id && family->id < GENL_MIN_ID)
 		goto errout;
@@ -326,8 +362,6 @@ int __genl_register_family(struct genl_family *family)
 	if (err)
 		return err;
 
-	INIT_LIST_HEAD(&family->mcast_groups);
-
 	genl_lock_all();
 
 	if (genl_family_find_byname(family->name)) {
@@ -359,10 +393,18 @@ int __genl_register_family(struct genl_family *family)
 	} else
 		family->attrbuf = NULL;
 
+	err = genl_validate_assign_mc_groups(family);
+	if (err)
+		goto errout_locked;
+
 	list_add_tail(&family->family_list, genl_family_chain(family->id));
 	genl_unlock_all();
 
-	genl_ctrl_event(CTRL_CMD_NEWFAMILY, family, NULL);
+	/* send all events */
+	genl_ctrl_event(CTRL_CMD_NEWFAMILY, family, NULL, 0);
+	for (i = 0; i < family->n_mcgrps; i++)
+		genl_ctrl_event(CTRL_CMD_NEWMCAST_GRP, family,
+				&family->mcgrps[i], family->mcgrp_offset + i);
 
 	return 0;
 
@@ -398,7 +440,7 @@ int genl_unregister_family(struct genl_family *family)
 		genl_unlock_all();
 
 		kfree(family->attrbuf);
-		genl_ctrl_event(CTRL_CMD_DELFAMILY, family, NULL);
+		genl_ctrl_event(CTRL_CMD_DELFAMILY, family, NULL, 0);
 		return 0;
 	}
 
@@ -658,23 +700,26 @@ static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
 		nla_nest_end(skb, nla_ops);
 	}
 
-	if (!list_empty(&family->mcast_groups)) {
-		struct genl_multicast_group *grp;
+	if (family->n_mcgrps) {
 		struct nlattr *nla_grps;
-		int idx = 1;
+		int i;
 
 		nla_grps = nla_nest_start(skb, CTRL_ATTR_MCAST_GROUPS);
 		if (nla_grps == NULL)
 			goto nla_put_failure;
 
-		list_for_each_entry(grp, &family->mcast_groups, list) {
+		for (i = 0; i < family->n_mcgrps; i++) {
 			struct nlattr *nest;
+			const struct genl_multicast_group *grp;
 
-			nest = nla_nest_start(skb, idx++);
+			grp = &family->mcgrps[i];
+
+			nest = nla_nest_start(skb, i + 1);
 			if (nest == NULL)
 				goto nla_put_failure;
 
-			if (nla_put_u32(skb, CTRL_ATTR_MCAST_GRP_ID, grp->id) ||
+			if (nla_put_u32(skb, CTRL_ATTR_MCAST_GRP_ID,
+					family->mcgrp_offset + i) ||
 			    nla_put_string(skb, CTRL_ATTR_MCAST_GRP_NAME,
 					   grp->name))
 				goto nla_put_failure;
@@ -692,9 +737,9 @@ nla_put_failure:
 }
 
 static int ctrl_fill_mcgrp_info(struct genl_family *family,
-				struct genl_multicast_group *grp, u32 portid,
-				u32 seq, u32 flags, struct sk_buff *skb,
-				u8 cmd)
+				const struct genl_multicast_group *grp,
+				int grp_id, u32 portid, u32 seq, u32 flags,
+				struct sk_buff *skb, u8 cmd)
 {
 	void *hdr;
 	struct nlattr *nla_grps;
@@ -716,7 +761,7 @@ static int ctrl_fill_mcgrp_info(struct genl_family *family,
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	if (nla_put_u32(skb, CTRL_ATTR_MCAST_GRP_ID, grp->id) ||
+	if (nla_put_u32(skb, CTRL_ATTR_MCAST_GRP_ID, grp_id) ||
 	    nla_put_string(skb, CTRL_ATTR_MCAST_GRP_NAME,
 			   grp->name))
 		goto nla_put_failure;
@@ -782,9 +827,10 @@ static struct sk_buff *ctrl_build_family_msg(struct genl_family *family,
 	return skb;
 }
 
-static struct sk_buff *ctrl_build_mcgrp_msg(struct genl_family *family,
-					    struct genl_multicast_group *grp,
-					    u32 portid, int seq, u8 cmd)
+static struct sk_buff *
+ctrl_build_mcgrp_msg(struct genl_family *family,
+		     const struct genl_multicast_group *grp,
+		     int grp_id, u32 portid, int seq, u8 cmd)
 {
 	struct sk_buff *skb;
 	int err;
@@ -793,7 +839,8 @@ static struct sk_buff *ctrl_build_mcgrp_msg(struct genl_family *family,
 	if (skb == NULL)
 		return ERR_PTR(-ENOBUFS);
 
-	err = ctrl_fill_mcgrp_info(family, grp, portid, seq, 0, skb, cmd);
+	err = ctrl_fill_mcgrp_info(family, grp, grp_id, portid,
+				   seq, 0, skb, cmd);
 	if (err < 0) {
 		nlmsg_free(skb);
 		return ERR_PTR(err);
@@ -856,7 +903,8 @@ static int ctrl_getfamily(struct sk_buff *skb, struct genl_info *info)
 }
 
 static int genl_ctrl_event(int event, struct genl_family *family,
-			   struct genl_multicast_group *grp)
+			   const struct genl_multicast_group *grp,
+			   int grp_id)
 {
 	struct sk_buff *msg;
 
@@ -873,7 +921,7 @@ static int genl_ctrl_event(int event, struct genl_family *family,
 	case CTRL_CMD_NEWMCAST_GRP:
 	case CTRL_CMD_DELMCAST_GRP:
 		BUG_ON(!grp);
-		msg = ctrl_build_mcgrp_msg(family, grp, 0, 0, event);
+		msg = ctrl_build_mcgrp_msg(family, grp, grp_id, 0, 0, event);
 		break;
 	default:
 		return -EINVAL;
@@ -884,11 +932,11 @@ static int genl_ctrl_event(int event, struct genl_family *family,
 
 	if (!family->netnsok) {
 		genlmsg_multicast_netns(&genl_ctrl, &init_net, msg, 0,
-					GENL_ID_CTRL, GFP_KERNEL);
+					0, GFP_KERNEL);
 	} else {
 		rcu_read_lock();
 		genlmsg_multicast_allns(&genl_ctrl, msg, 0,
-					GENL_ID_CTRL, GFP_ATOMIC);
+					0, GFP_ATOMIC);
 		rcu_read_unlock();
 	}
 
@@ -904,8 +952,8 @@ static struct genl_ops genl_ctrl_ops[] = {
 	},
 };
 
-static struct genl_multicast_group notify_grp = {
-	.name		= "notify",
+static struct genl_multicast_group genl_ctrl_groups[] = {
+	{ .name = "notify", },
 };
 
 static int __net_init genl_pernet_init(struct net *net)
@@ -945,7 +993,8 @@ static int __init genl_init(void)
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++)
 		INIT_LIST_HEAD(&family_ht[i]);
 
-	err = genl_register_family_with_ops(&genl_ctrl, genl_ctrl_ops);
+	err = genl_register_family_with_ops_groups(&genl_ctrl, genl_ctrl_ops,
+						   genl_ctrl_groups);
 	if (err < 0)
 		goto problem;
 
@@ -953,10 +1002,6 @@ static int __init genl_init(void)
 	if (err)
 		goto problem;
 
-	err = genl_register_mc_group(&genl_ctrl, &notify_grp);
-	if (err < 0)
-		goto problem;
-
 	return 0;
 
 problem:
@@ -997,6 +1042,9 @@ static int genlmsg_mcast(struct sk_buff *skb, u32 portid, unsigned long group,
 int genlmsg_multicast_allns(struct genl_family *family, struct sk_buff *skb,
 			    u32 portid, unsigned int group, gfp_t flags)
 {
+	if (group >= family->n_mcgrps)
+		return -EINVAL;
+	group = family->mcgrp_offset + group;
 	return genlmsg_mcast(skb, portid, group, flags);
 }
 EXPORT_SYMBOL(genlmsg_multicast_allns);
@@ -1011,6 +1059,9 @@ void genl_notify(struct genl_family *family,
 	if (nlh)
 		report = nlmsg_report(nlh);
 
+	if (group >= family->n_mcgrps)
+		return;
+	group = family->mcgrp_offset + group;
 	nlmsg_notify(sk, skb, portid, group, report, flags);
 }
 EXPORT_SYMBOL(genl_notify);
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 3092df31..a9b2342 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -30,8 +30,8 @@
 #include "nfc.h"
 #include "llcp.h"
 
-static struct genl_multicast_group nfc_genl_event_mcgrp = {
-	.name = NFC_GENL_MCAST_EVENT_NAME,
+static const struct genl_multicast_group nfc_genl_mcgrps[] = {
+	{ .name = NFC_GENL_MCAST_EVENT_NAME, },
 };
 
 static struct genl_family nfc_genl_family = {
@@ -194,8 +194,7 @@ int nfc_genl_targets_found(struct nfc_dev *dev)
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_multicast(&nfc_genl_family, msg, 0,
-				 nfc_genl_event_mcgrp.id, GFP_ATOMIC);
+	return genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_ATOMIC);
 
 nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -224,8 +223,7 @@ int nfc_genl_target_lost(struct nfc_dev *dev, u32 target_idx)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(&nfc_genl_family, msg, 0,
-			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_KERNEL);
 
 	return 0;
 
@@ -257,8 +255,7 @@ int nfc_genl_tm_activated(struct nfc_dev *dev, u32 protocol)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(&nfc_genl_family, msg, 0,
-			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_KERNEL);
 
 	return 0;
 
@@ -288,8 +285,7 @@ int nfc_genl_tm_deactivated(struct nfc_dev *dev)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(&nfc_genl_family, msg, 0,
-			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_KERNEL);
 
 	return 0;
 
@@ -322,8 +318,7 @@ int nfc_genl_device_added(struct nfc_dev *dev)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(&nfc_genl_family, msg, 0,
-			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_KERNEL);
 
 	return 0;
 
@@ -353,8 +348,7 @@ int nfc_genl_device_removed(struct nfc_dev *dev)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(&nfc_genl_family, msg, 0,
-			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_KERNEL);
 
 	return 0;
 
@@ -420,8 +414,7 @@ int nfc_genl_llc_send_sdres(struct nfc_dev *dev, struct hlist_head *sdres_list)
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_multicast(&nfc_genl_family, msg, 0,
-				 nfc_genl_event_mcgrp.id, GFP_ATOMIC);
+	return genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_ATOMIC);
 
 nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -455,8 +448,7 @@ int nfc_genl_se_added(struct nfc_dev *dev, u32 se_idx, u16 type)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(&nfc_genl_family, msg, 0,
-			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_KERNEL);
 
 	return 0;
 
@@ -487,8 +479,7 @@ int nfc_genl_se_removed(struct nfc_dev *dev, u32 se_idx)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(&nfc_genl_family, msg, 0,
-			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_KERNEL);
 
 	return 0;
 
@@ -609,8 +600,7 @@ int nfc_genl_dep_link_up_event(struct nfc_dev *dev, u32 target_idx,
 
 	dev->dep_link_up = true;
 
-	genlmsg_multicast(&nfc_genl_family, msg, 0,
-			  nfc_genl_event_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_ATOMIC);
 
 	return 0;
 
@@ -642,8 +632,7 @@ int nfc_genl_dep_link_down_event(struct nfc_dev *dev)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(&nfc_genl_family, msg, 0,
-			  nfc_genl_event_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_ATOMIC);
 
 	return 0;
 
@@ -1148,8 +1137,7 @@ int nfc_genl_fw_download_done(struct nfc_dev *dev, const char *firmware_name,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(&nfc_genl_family, msg, 0,
-			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_KERNEL);
 
 	return 0;
 
@@ -1320,8 +1308,7 @@ static void se_io_cb(void *context, u8 *apdu, size_t apdu_len, int err)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(&nfc_genl_family, msg, 0,
-			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0, 0, GFP_KERNEL);
 
 	kfree(ctx);
 
@@ -1549,15 +1536,15 @@ int __init nfc_genl_init(void)
 {
 	int rc;
 
-	rc = genl_register_family_with_ops(&nfc_genl_family, nfc_genl_ops);
+	rc = genl_register_family_with_ops_groups(&nfc_genl_family,
+						  nfc_genl_ops,
+						  nfc_genl_mcgrps);
 	if (rc)
 		return rc;
 
-	rc = genl_register_mc_group(&nfc_genl_family, &nfc_genl_event_mcgrp);
-
 	netlink_register_notifier(&nl_notifier);
 
-	return rc;
+	return 0;
 }
 
 /**
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 1de9446..20215ff 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -62,11 +62,10 @@
 int ovs_net_id __read_mostly;
 
 static void ovs_notify(struct genl_family *family,
-		       struct sk_buff *skb, struct genl_info *info,
-		       struct genl_multicast_group *grp)
+		       struct sk_buff *skb, struct genl_info *info)
 {
 	genl_notify(family, skb, genl_info_net(info), info->snd_portid,
-		    grp->id, info->nlhdr, GFP_KERNEL);
+		    0, info->nlhdr, GFP_KERNEL);
 }
 
 /**
@@ -878,11 +877,10 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	ovs_unlock();
 
 	if (!IS_ERR(reply))
-		ovs_notify(&dp_flow_genl_family, reply, info,
-			   &ovs_dp_flow_multicast_group);
+		ovs_notify(&dp_flow_genl_family, reply, info);
 	else
 		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
-				ovs_dp_flow_multicast_group.id, PTR_ERR(reply));
+				dp_flow_genl_family.mcgrp_offset, PTR_ERR(reply));
 	return 0;
 
 err_flow_free:
@@ -992,8 +990,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	ovs_flow_free(flow, true);
 	ovs_unlock();
 
-	ovs_notify(&dp_flow_genl_family, reply, info,
-		   &ovs_dp_flow_multicast_group);
+	ovs_notify(&dp_flow_genl_family, reply, info);
 	return 0;
 unlock:
 	ovs_unlock();
@@ -1240,8 +1237,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	ovs_unlock();
 
-	ovs_notify(&dp_datapath_genl_family, reply, info,
-		   &ovs_dp_datapath_multicast_group);
+	ovs_notify(&dp_datapath_genl_family, reply, info);
 	return 0;
 
 err_destroy_local_port:
@@ -1306,8 +1302,7 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	__dp_destroy(dp);
 	ovs_unlock();
 
-	ovs_notify(&dp_datapath_genl_family, reply, info,
-		   &ovs_dp_datapath_multicast_group);
+	ovs_notify(&dp_datapath_genl_family, reply, info);
 
 	return 0;
 unlock:
@@ -1332,14 +1327,13 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(reply)) {
 		err = PTR_ERR(reply);
 		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
-				ovs_dp_datapath_multicast_group.id, err);
+				dp_datapath_genl_family.mcgrp_offset, err);
 		err = 0;
 		goto unlock;
 	}
 
 	ovs_unlock();
-	ovs_notify(&dp_datapath_genl_family, reply, info,
-		   &ovs_dp_datapath_multicast_group);
+	ovs_notify(&dp_datapath_genl_family, reply, info);
 
 	return 0;
 unlock:
@@ -1601,8 +1595,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto exit_unlock;
 	}
 
-	ovs_notify(&dp_vport_genl_family, reply, info,
-		   &ovs_dp_vport_multicast_group);
+	ovs_notify(&dp_vport_genl_family, reply, info);
 
 exit_unlock:
 	ovs_unlock();
@@ -1649,8 +1642,7 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	BUG_ON(err < 0);
 
 	ovs_unlock();
-	ovs_notify(&dp_vport_genl_family, reply, info,
-		   &ovs_dp_vport_multicast_group);
+	ovs_notify(&dp_vport_genl_family, reply, info);
 	return 0;
 
 exit_free:
@@ -1687,8 +1679,7 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	err = 0;
 	ovs_dp_detach_port(vport);
 
-	ovs_notify(&dp_vport_genl_family, reply, info,
-		   &ovs_dp_vport_multicast_group);
+	ovs_notify(&dp_vport_genl_family, reply, info);
 
 exit_unlock:
 	ovs_unlock();
@@ -1790,7 +1781,7 @@ struct genl_family_and_ops {
 	struct genl_family *family;
 	const struct genl_ops *ops;
 	int n_ops;
-	struct genl_multicast_group *group;
+	const struct genl_multicast_group *group;
 };
 
 static const struct genl_family_and_ops dp_genl_families[] = {
@@ -1828,16 +1819,12 @@ static int dp_register_genl(void)
 
 		f->family->ops = f->ops;
 		f->family->n_ops = f->n_ops;
+		f->family->mcgrps = f->group;
+		f->family->n_mcgrps = f->group ? 1 : 0;
 		err = genl_register_family(f->family);
 		if (err)
 			goto error;
 		n_registered++;
-
-		if (f->group) {
-			err = genl_register_mc_group(f->family, f->group);
-			if (err)
-				goto error;
-		}
 	}
 
 	return 0;
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index aa29d85..d9e50dc 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -35,15 +35,14 @@ static void dp_detach_port_notify(struct vport *vport)
 	ovs_dp_detach_port(vport);
 	if (IS_ERR(notify)) {
 		netlink_set_err(ovs_dp_get_net(dp)->genl_sock, 0,
-				ovs_dp_vport_multicast_group.id,
+				dp_vport_genl_family.mcgrp_offset,
 				PTR_ERR(notify));
 		return;
 	}
 
 	genlmsg_multicast_netns(&dp_vport_genl_family,
 				ovs_dp_get_net(dp), notify, 0,
-				ovs_dp_vport_multicast_group.id,
-				GFP_KERNEL);
+				0, GFP_KERNEL);
 }
 
 void ovs_dp_notify_wq(struct work_struct *work)
diff --git a/net/wimax/op-msg.c b/net/wimax/op-msg.c
index f37dd3c..c278b33 100644
--- a/net/wimax/op-msg.c
+++ b/net/wimax/op-msg.c
@@ -279,8 +279,7 @@ int wimax_msg_send(struct wimax_dev *wimax_dev, struct sk_buff *skb)
 
 	d_printf(1, dev, "CTX: wimax msg, %zu bytes\n", size);
 	d_dump(2, dev, msg, size);
-	genlmsg_multicast(&wimax_gnl_family, skb, 0,
-			  wimax_gnl_mcg.id, GFP_KERNEL);
+	genlmsg_multicast(&wimax_gnl_family, skb, 0, 0, GFP_KERNEL);
 	d_printf(1, dev, "CTX: genl multicast done\n");
 	return 0;
 }
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 1888874..aa9b067 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -116,8 +116,8 @@ struct sk_buff *wimax_gnl_re_state_change_alloc(
 		dev_err(dev, "RE_STCH: can't create message\n");
 		goto error_new;
 	}
-	data = genlmsg_put(report_skb, 0, wimax_gnl_mcg.id, &wimax_gnl_family,
-			   0, WIMAX_GNL_RE_STATE_CHANGE);
+	data = genlmsg_put(report_skb, 0, wimax_gnl_family.mcgrp_offset,
+			   &wimax_gnl_family, 0, WIMAX_GNL_RE_STATE_CHANGE);
 	if (data == NULL) {
 		dev_err(dev, "RE_STCH: can't put data into message\n");
 		goto error_put;
@@ -177,8 +177,7 @@ int wimax_gnl_re_state_change_send(
 		goto out;
 	}
 	genlmsg_end(report_skb, header);
-	genlmsg_multicast(&wimax_gnl_family, report_skb, 0,
-			  wimax_gnl_mcg.id, GFP_KERNEL);
+	genlmsg_multicast(&wimax_gnl_family, report_skb, 0, 0, GFP_KERNEL);
 out:
 	d_fnend(3, dev, "(wimax_dev %p report_skb %p) = %d\n",
 		wimax_dev, report_skb, result);
@@ -580,8 +579,8 @@ struct genl_family wimax_gnl_family = {
 	.maxattr = WIMAX_GNL_ATTR_MAX,
 };
 
-struct genl_multicast_group wimax_gnl_mcg = {
-	.name = "msg",
+static const struct genl_multicast_group wimax_gnl_mcgrps[] = {
+	{ .name = "msg", },
 };
 
 
@@ -598,21 +597,18 @@ int __init wimax_subsys_init(void)
 
 	snprintf(wimax_gnl_family.name, sizeof(wimax_gnl_family.name),
 		 "WiMAX");
-	result = genl_register_family_with_ops(&wimax_gnl_family,
-					       wimax_gnl_ops);
+	result = genl_register_family_with_ops_groups(&wimax_gnl_family,
+						      wimax_gnl_ops,
+						      wimax_gnl_mcgrps);
 	if (unlikely(result < 0)) {
 		printk(KERN_ERR "cannot register generic netlink family: %d\n",
 		       result);
 		goto error_register_family;
 	}
 
-	result = genl_register_mc_group(&wimax_gnl_family, &wimax_gnl_mcg);
-	if (result < 0)
-		goto error_mc_group;
 	d_fnend(4, NULL, "() = 0\n");
 	return 0;
 
-error_mc_group:
 	genl_unregister_family(&wimax_gnl_family);
 error_register_family:
 	d_fnend(4, NULL, "() = %d\n", result);
diff --git a/net/wimax/wimax-internal.h b/net/wimax/wimax-internal.h
index 8567d30..b445b82 100644
--- a/net/wimax/wimax-internal.h
+++ b/net/wimax/wimax-internal.h
@@ -86,7 +86,6 @@ void wimax_rfkill_rm(struct wimax_dev *);
 
 /* generic netlink */
 extern struct genl_family wimax_gnl_family;
-extern struct genl_multicast_group wimax_gnl_mcg;
 
 /* ops */
 int wimax_gnl_doit_msg_from_user(struct sk_buff *skb, struct genl_info *info);
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index f20edfd..a1eb210 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -47,6 +47,25 @@ static struct genl_family nl80211_fam = {
 	.post_doit = nl80211_post_doit,
 };
 
+/* multicast groups */
+enum nl80211_multicast_groups {
+	NL80211_MCGRP_CONFIG,
+	NL80211_MCGRP_SCAN,
+	NL80211_MCGRP_REGULATORY,
+	NL80211_MCGRP_MLME,
+	NL80211_MCGRP_TESTMODE /* keep last - ifdef! */
+};
+
+static const struct genl_multicast_group nl80211_mcgrps[] = {
+	[NL80211_MCGRP_CONFIG] = { .name = "config", },
+	[NL80211_MCGRP_SCAN] = { .name = "scan", },
+	[NL80211_MCGRP_REGULATORY] = { .name = "regulatory", },
+	[NL80211_MCGRP_MLME] = { .name = "mlme", },
+#ifdef CONFIG_NL80211_TESTMODE
+	[NL80211_MCGRP_TESTMODE] = { .name = "testmode", }
+#endif
+};
+
 /* returns ERR_PTR values */
 static struct wireless_dev *
 __cfg80211_wdev_from_attrs(struct net *netns, struct nlattr **attrs)
@@ -6656,10 +6675,6 @@ static int nl80211_set_mcast_rate(struct sk_buff *skb, struct genl_info *info)
 
 
 #ifdef CONFIG_NL80211_TESTMODE
-static struct genl_multicast_group nl80211_testmode_mcgrp = {
-	.name = "testmode",
-};
-
 static int nl80211_testmode_do(struct sk_buff *skb, struct genl_info *info)
 {
 	struct cfg80211_registered_device *rdev = info->user_ptr[0];
@@ -6869,7 +6884,7 @@ void cfg80211_testmode_event(struct sk_buff *skb, gfp_t gfp)
 	nla_nest_end(skb, data);
 	genlmsg_end(skb, hdr);
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), skb, 0,
-				nl80211_testmode_mcgrp.id, gfp);
+				NL80211_MCGRP_TESTMODE, gfp);
 }
 EXPORT_SYMBOL(cfg80211_testmode_event);
 #endif
@@ -9566,21 +9581,6 @@ static const struct genl_ops nl80211_ops[] = {
 	},
 };
 
-static struct genl_multicast_group nl80211_mlme_mcgrp = {
-	.name = "mlme",
-};
-
-/* multicast groups */
-static struct genl_multicast_group nl80211_config_mcgrp = {
-	.name = "config",
-};
-static struct genl_multicast_group nl80211_scan_mcgrp = {
-	.name = "scan",
-};
-static struct genl_multicast_group nl80211_regulatory_mcgrp = {
-	.name = "regulatory",
-};
-
 /* notification functions */
 
 void nl80211_notify_dev_rename(struct cfg80211_registered_device *rdev)
@@ -9598,7 +9598,7 @@ void nl80211_notify_dev_rename(struct cfg80211_registered_device *rdev)
 	}
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_config_mcgrp.id, GFP_KERNEL);
+				NL80211_MCGRP_CONFIG, GFP_KERNEL);
 }
 
 static int nl80211_add_scan_req(struct sk_buff *msg,
@@ -9708,7 +9708,7 @@ void nl80211_send_scan_start(struct cfg80211_registered_device *rdev,
 	}
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_scan_mcgrp.id, GFP_KERNEL);
+				NL80211_MCGRP_SCAN, GFP_KERNEL);
 }
 
 void nl80211_send_scan_done(struct cfg80211_registered_device *rdev,
@@ -9727,7 +9727,7 @@ void nl80211_send_scan_done(struct cfg80211_registered_device *rdev,
 	}
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_scan_mcgrp.id, GFP_KERNEL);
+				NL80211_MCGRP_SCAN, GFP_KERNEL);
 }
 
 void nl80211_send_scan_aborted(struct cfg80211_registered_device *rdev,
@@ -9746,7 +9746,7 @@ void nl80211_send_scan_aborted(struct cfg80211_registered_device *rdev,
 	}
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_scan_mcgrp.id, GFP_KERNEL);
+				NL80211_MCGRP_SCAN, GFP_KERNEL);
 }
 
 void nl80211_send_sched_scan_results(struct cfg80211_registered_device *rdev,
@@ -9765,7 +9765,7 @@ void nl80211_send_sched_scan_results(struct cfg80211_registered_device *rdev,
 	}
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_scan_mcgrp.id, GFP_KERNEL);
+				NL80211_MCGRP_SCAN, GFP_KERNEL);
 }
 
 void nl80211_send_sched_scan(struct cfg80211_registered_device *rdev,
@@ -9783,7 +9783,7 @@ void nl80211_send_sched_scan(struct cfg80211_registered_device *rdev,
 	}
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_scan_mcgrp.id, GFP_KERNEL);
+				NL80211_MCGRP_SCAN, GFP_KERNEL);
 }
 
 /*
@@ -9838,7 +9838,7 @@ void nl80211_send_reg_change_event(struct regulatory_request *request)
 
 	rcu_read_lock();
 	genlmsg_multicast_allns(&nl80211_fam, msg, 0,
-				nl80211_regulatory_mcgrp.id, GFP_ATOMIC);
+				NL80211_MCGRP_REGULATORY, GFP_ATOMIC);
 	rcu_read_unlock();
 
 	return;
@@ -9874,7 +9874,7 @@ static void nl80211_send_mlme_event(struct cfg80211_registered_device *rdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -9962,7 +9962,7 @@ static void nl80211_send_mlme_timeout(struct cfg80211_registered_device *rdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10018,7 +10018,7 @@ void nl80211_send_connect_result(struct cfg80211_registered_device *rdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10057,7 +10057,7 @@ void nl80211_send_roamed(struct cfg80211_registered_device *rdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10095,7 +10095,7 @@ void nl80211_send_disconnected(struct cfg80211_registered_device *rdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, GFP_KERNEL);
+				NL80211_MCGRP_MLME, GFP_KERNEL);
 	return;
 
  nla_put_failure:
@@ -10129,7 +10129,7 @@ void nl80211_send_ibss_bssid(struct cfg80211_registered_device *rdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10170,7 +10170,7 @@ void cfg80211_notify_new_peer_candidate(struct net_device *dev, const u8 *addr,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10209,7 +10209,7 @@ void nl80211_michael_mic_failure(struct cfg80211_registered_device *rdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10262,7 +10262,7 @@ void nl80211_send_beacon_hint_event(struct wiphy *wiphy,
 
 	rcu_read_lock();
 	genlmsg_multicast_allns(&nl80211_fam, msg, 0,
-				nl80211_regulatory_mcgrp.id, GFP_ATOMIC);
+				NL80211_MCGRP_REGULATORY, GFP_ATOMIC);
 	rcu_read_unlock();
 
 	return;
@@ -10308,7 +10308,7 @@ static void nl80211_send_remain_on_chan_event(
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10363,7 +10363,7 @@ void cfg80211_new_sta(struct net_device *dev, const u8 *mac_addr,
 	}
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 }
 EXPORT_SYMBOL(cfg80211_new_sta);
 
@@ -10393,7 +10393,7 @@ void cfg80211_del_sta(struct net_device *dev, const u8 *mac_addr, gfp_t gfp)
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10429,7 +10429,7 @@ void cfg80211_conn_failed(struct net_device *dev, const u8 *mac_addr,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10591,7 +10591,7 @@ void cfg80211_mgmt_tx_status(struct wireless_dev *wdev, u64 cookie,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10640,7 +10640,7 @@ void cfg80211_cqm_rssi_notify(struct net_device *dev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10685,7 +10685,7 @@ static void nl80211_gtk_rekey_notify(struct cfg80211_registered_device *rdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10743,7 +10743,7 @@ nl80211_pmksa_candidate_notify(struct cfg80211_registered_device *rdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10790,7 +10790,7 @@ static void nl80211_ch_switch_notify(struct cfg80211_registered_device *rdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10867,7 +10867,7 @@ void cfg80211_cqm_txe_notify(struct net_device *dev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10916,7 +10916,7 @@ nl80211_radar_notify(struct cfg80211_registered_device *rdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -10963,7 +10963,7 @@ void cfg80211_cqm_pktloss_notify(struct net_device *dev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -11003,7 +11003,7 @@ void cfg80211_probe_status(struct net_device *dev, const u8 *addr,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -11155,7 +11155,7 @@ void cfg80211_report_wowlan_wakeup(struct wireless_dev *wdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  free_msg:
@@ -11197,7 +11197,7 @@ void cfg80211_tdls_oper_request(struct net_device *dev, const u8 *peer,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, gfp);
+				NL80211_MCGRP_MLME, gfp);
 	return;
 
  nla_put_failure:
@@ -11280,7 +11280,7 @@ void cfg80211_ft_event(struct net_device *netdev,
 	genlmsg_end(msg, hdr);
 
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				nl80211_mlme_mcgrp.id, GFP_KERNEL);
+				NL80211_MCGRP_MLME, GFP_KERNEL);
 }
 EXPORT_SYMBOL(cfg80211_ft_event);
 
@@ -11329,32 +11329,11 @@ int nl80211_init(void)
 {
 	int err;
 
-	err = genl_register_family_with_ops(&nl80211_fam, nl80211_ops);
+	err = genl_register_family_with_ops_groups(&nl80211_fam, nl80211_ops,
+						   nl80211_mcgrps);
 	if (err)
 		return err;
 
-	err = genl_register_mc_group(&nl80211_fam, &nl80211_config_mcgrp);
-	if (err)
-		goto err_out;
-
-	err = genl_register_mc_group(&nl80211_fam, &nl80211_scan_mcgrp);
-	if (err)
-		goto err_out;
-
-	err = genl_register_mc_group(&nl80211_fam, &nl80211_regulatory_mcgrp);
-	if (err)
-		goto err_out;
-
-	err = genl_register_mc_group(&nl80211_fam, &nl80211_mlme_mcgrp);
-	if (err)
-		goto err_out;
-
-#ifdef CONFIG_NL80211_TESTMODE
-	err = genl_register_mc_group(&nl80211_fam, &nl80211_testmode_mcgrp);
-	if (err)
-		goto err_out;
-#endif
-
 	err = netlink_register_notifier(&nl80211_netlink_notifier);
 	if (err)
 		goto err_out;
-- 
1.8.4.rc3
