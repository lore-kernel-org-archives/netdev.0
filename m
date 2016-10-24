From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 3/5] genetlink: statically initialize families
Date: Mon, 24 Oct 2016 14:40:03 +0200
Message-ID: <1477312805-7110-4-git-send-email-johannes@sipsolutions.net>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51694 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938736AbcJXMkL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 08:40:11 -0400
In-Reply-To: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Instead of providing macros/inline functions to initialize
the families, make all users initialize them statically and
get rid of the macros.

This reduces the kernel code size by about 1.6k on x86-64
(with allyesconfig).

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/acpi/event.c                  |  1 +
 drivers/net/gtp.c                     | 21 +++++++----
 drivers/net/macsec.c                  | 21 +++++++----
 drivers/net/team/team.c               | 22 +++++++----
 drivers/net/wireless/mac80211_hwsim.c | 26 +++++++------
 drivers/scsi/pmcraid.c                |  1 +
 drivers/target/target_core_user.c     |  1 +
 drivers/thermal/thermal_core.c        |  1 +
 fs/dlm/netlink.c                      | 15 +++++---
 fs/quota/netlink.c                    |  1 +
 include/linux/drbd_genl.h             |  2 +-
 include/linux/genl_magic_func.h       | 28 ++++++++------
 include/net/genetlink.h               | 71 ++++++-----------------------------
 kernel/taskstats.c                    | 17 ++++++---
 net/batman-adv/netlink.c              | 25 +++++++-----
 net/core/devlink.c                    | 27 +++++++------
 net/core/drop_monitor.c               | 20 ++++++----
 net/hsr/hsr_netlink.c                 | 22 +++++++----
 net/ieee802154/netlink.c              | 23 +++++++-----
 net/ieee802154/nl802154.c             | 34 ++++++++---------
 net/ipv4/fou.c                        | 22 ++++++-----
 net/ipv4/tcp_metrics.c                | 22 ++++++-----
 net/ipv6/ila/ila_xlat.c               | 24 +++++++-----
 net/irda/irnetlink.c                  | 19 ++++++----
 net/l2tp/l2tp_netlink.c               | 25 +++++++-----
 net/netfilter/ipvs/ip_vs_ctl.c        | 22 ++++++-----
 net/netlabel/netlabel_calipso.c       | 20 ++++++----
 net/netlabel/netlabel_cipso_v4.c      | 21 ++++++-----
 net/netlabel/netlabel_mgmt.c          | 20 ++++++----
 net/netlabel/netlabel_unlabeled.c     | 20 ++++++----
 net/netlink/genetlink.c               | 35 +++++++++--------
 net/nfc/netlink.c                     | 24 +++++++-----
 net/openvswitch/datapath.c            |  4 ++
 net/tipc/netlink.c                    | 22 ++++++-----
 net/tipc/netlink_compat.c             | 20 +++++-----
 net/wimax/stack.c                     | 19 +++++-----
 net/wireless/nl80211.c                | 33 ++++++++--------
 37 files changed, 414 insertions(+), 337 deletions(-)

diff --git a/drivers/acpi/event.c b/drivers/acpi/event.c
index 8dfca3d53131..1ab12ad7d5ba 100644
--- a/drivers/acpi/event.c
+++ b/drivers/acpi/event.c
@@ -83,6 +83,7 @@ static const struct genl_multicast_group acpi_event_mcgrps[] = {
 };
 
 static struct genl_family acpi_event_genl_family = {
+	.module = THIS_MODULE,
 	.name = ACPI_GENL_FAMILY_NAME,
 	.version = ACPI_GENL_VERSION,
 	.maxattr = ACPI_GENL_ATTR_MAX,
diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index f66737ba1299..0604fd78f826 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -1094,13 +1094,7 @@ static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
 	return 0;
 }
 
-static struct genl_family gtp_genl_family = {
-	.name		= "gtp",
-	.version	= 0,
-	.hdrsize	= 0,
-	.maxattr	= GTPA_MAX,
-	.netnsok	= true,
-};
+static struct genl_family gtp_genl_family;
 
 static int gtp_genl_fill_info(struct sk_buff *skb, u32 snd_portid, u32 snd_seq,
 			      u32 type, struct pdp_ctx *pctx)
@@ -1296,6 +1290,17 @@ static const struct genl_ops gtp_genl_ops[] = {
 	},
 };
 
+static struct genl_family gtp_genl_family = {
+	.name		= "gtp",
+	.version	= 0,
+	.hdrsize	= 0,
+	.maxattr	= GTPA_MAX,
+	.netnsok	= true,
+	.module		= THIS_MODULE,
+	.ops		= gtp_genl_ops,
+	.n_ops		= ARRAY_SIZE(gtp_genl_ops),
+};
+
 static int __net_init gtp_net_init(struct net *net)
 {
 	struct gtp_net *gn = net_generic(net, gtp_net_id);
@@ -1335,7 +1340,7 @@ static int __init gtp_init(void)
 	if (err < 0)
 		goto error_out;
 
-	err = genl_register_family_with_ops(&gtp_genl_family, gtp_genl_ops);
+	err = genl_register_family(&gtp_genl_family);
 	if (err < 0)
 		goto unreg_rtnl_link;
 
diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index a5309b81a786..63ca7a3c77cf 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -1421,13 +1421,7 @@ static void clear_tx_sa(struct macsec_tx_sa *tx_sa)
 	macsec_txsa_put(tx_sa);
 }
 
-static struct genl_family macsec_fam = {
-	.name		= MACSEC_GENL_NAME,
-	.hdrsize	= 0,
-	.version	= MACSEC_GENL_VERSION,
-	.maxattr	= MACSEC_ATTR_MAX,
-	.netnsok	= true,
-};
+static struct genl_family macsec_fam;
 
 static struct net_device *get_dev_from_nl(struct net *net,
 					  struct nlattr **attrs)
@@ -2654,6 +2648,17 @@ static const struct genl_ops macsec_genl_ops[] = {
 	},
 };
 
+static struct genl_family macsec_fam = {
+	.name		= MACSEC_GENL_NAME,
+	.hdrsize	= 0,
+	.version	= MACSEC_GENL_VERSION,
+	.maxattr	= MACSEC_ATTR_MAX,
+	.netnsok	= true,
+	.module		= THIS_MODULE,
+	.ops		= macsec_genl_ops,
+	.n_ops		= ARRAY_SIZE(macsec_genl_ops),
+};
+
 static netdev_tx_t macsec_start_xmit(struct sk_buff *skb,
 				     struct net_device *dev)
 {
@@ -3461,7 +3466,7 @@ static int __init macsec_init(void)
 	if (err)
 		goto notifier;
 
-	err = genl_register_family_with_ops(&macsec_fam, macsec_genl_ops);
+	err = genl_register_family(&macsec_fam);
 	if (err)
 		goto rtnl;
 
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 0b50205764ff..46bf7c1216c0 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2150,12 +2150,7 @@ static struct rtnl_link_ops team_link_ops __read_mostly = {
  * Generic netlink custom interface
  ***********************************/
 
-static struct genl_family team_nl_family = {
-	.name		= TEAM_GENL_NAME,
-	.version	= TEAM_GENL_VERSION,
-	.maxattr	= TEAM_ATTR_MAX,
-	.netnsok	= true,
-};
+static struct genl_family team_nl_family;
 
 static const struct nla_policy team_nl_policy[TEAM_ATTR_MAX + 1] = {
 	[TEAM_ATTR_UNSPEC]			= { .type = NLA_UNSPEC, },
@@ -2745,6 +2740,18 @@ static const struct genl_multicast_group team_nl_mcgrps[] = {
 	{ .name = TEAM_GENL_CHANGE_EVENT_MC_GRP_NAME, },
 };
 
+static struct genl_family team_nl_family = {
+	.name		= TEAM_GENL_NAME,
+	.version	= TEAM_GENL_VERSION,
+	.maxattr	= TEAM_ATTR_MAX,
+	.netnsok	= true,
+	.module		= THIS_MODULE,
+	.ops		= team_nl_ops,
+	.n_ops		= ARRAY_SIZE(team_nl_ops),
+	.mcgrps		= team_nl_mcgrps,
+	.n_mcgrps	= ARRAY_SIZE(team_nl_mcgrps),
+};
+
 static int team_nl_send_multicast(struct sk_buff *skb,
 				  struct team *team, u32 portid)
 {
@@ -2768,8 +2775,7 @@ static int team_nl_send_event_port_get(struct team *team,
 
 static int team_nl_init(void)
 {
-	return genl_register_family_with_ops_groups(&team_nl_family, team_nl_ops,
-						    team_nl_mcgrps);
+	return genl_register_family(&team_nl_family);
 }
 
 static void team_nl_fini(void)
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 54b6cd62676e..5d4637e586e8 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -587,14 +587,8 @@ struct hwsim_radiotap_ack_hdr {
 	__le16 rt_chbitmask;
 } __packed;
 
-/* MAC80211_HWSIM netlinf family */
-static struct genl_family hwsim_genl_family = {
-	.hdrsize = 0,
-	.name = "MAC80211_HWSIM",
-	.version = 1,
-	.maxattr = HWSIM_ATTR_MAX,
-	.netnsok = true,
-};
+/* MAC80211_HWSIM netlink family */
+static struct genl_family hwsim_genl_family;
 
 enum hwsim_multicast_groups {
 	HWSIM_MCGRP_CONFIG,
@@ -3234,6 +3228,18 @@ static const struct genl_ops hwsim_ops[] = {
 	},
 };
 
+static struct genl_family hwsim_genl_family = {
+	.name = "MAC80211_HWSIM",
+	.version = 1,
+	.maxattr = HWSIM_ATTR_MAX,
+	.netnsok = true,
+	.module = THIS_MODULE,
+	.ops = hwsim_ops,
+	.n_ops = ARRAY_SIZE(hwsim_ops),
+	.mcgrps = hwsim_mcgrps,
+	.n_mcgrps = ARRAY_SIZE(hwsim_mcgrps),
+};
+
 static void destroy_radio(struct work_struct *work)
 {
 	struct mac80211_hwsim_data *data =
@@ -3287,9 +3293,7 @@ static int hwsim_init_netlink(void)
 
 	printk(KERN_INFO "mac80211_hwsim: initializing netlink\n");
 
-	rc = genl_register_family_with_ops_groups(&hwsim_genl_family,
-						  hwsim_ops,
-						  hwsim_mcgrps);
+	rc = genl_register_family(&hwsim_genl_family);
 	if (rc)
 		goto failure;
 
diff --git a/drivers/scsi/pmcraid.c b/drivers/scsi/pmcraid.c
index cc50eb87b28a..c0ab7bb8c3ce 100644
--- a/drivers/scsi/pmcraid.c
+++ b/drivers/scsi/pmcraid.c
@@ -1369,6 +1369,7 @@ static struct genl_multicast_group pmcraid_mcgrps[] = {
 };
 
 static struct genl_family pmcraid_event_family = {
+	.module = THIS_MODULE,
 	.name = "pmcraid",
 	.version = 1,
 	.maxattr = PMCRAID_AEN_ATTR_MAX,
diff --git a/drivers/target/target_core_user.c b/drivers/target/target_core_user.c
index 313a0ef3cda7..3483372f5562 100644
--- a/drivers/target/target_core_user.c
+++ b/drivers/target/target_core_user.c
@@ -148,6 +148,7 @@ static const struct genl_multicast_group tcmu_mcgrps[] = {
 
 /* Our generic netlink family */
 static struct genl_family tcmu_genl_family = {
+	.module = THIS_MODULE,
 	.hdrsize = 0,
 	.name = "TCM-USER",
 	.version = 1,
diff --git a/drivers/thermal/thermal_core.c b/drivers/thermal/thermal_core.c
index 68d7503f6417..93b6caab2d9f 100644
--- a/drivers/thermal/thermal_core.c
+++ b/drivers/thermal/thermal_core.c
@@ -2164,6 +2164,7 @@ static const struct genl_multicast_group thermal_event_mcgrps[] = {
 };
 
 static struct genl_family thermal_event_genl_family = {
+	.module = THIS_MODULE,
 	.name = THERMAL_GENL_FAMILY_NAME,
 	.version = THERMAL_GENL_VERSION,
 	.maxattr = THERMAL_GENL_ATTR_MAX,
diff --git a/fs/dlm/netlink.c b/fs/dlm/netlink.c
index 00d226956264..04042d69573c 100644
--- a/fs/dlm/netlink.c
+++ b/fs/dlm/netlink.c
@@ -16,10 +16,7 @@
 static uint32_t dlm_nl_seqnum;
 static uint32_t listener_nlportid;
 
-static struct genl_family family = {
-	.name		= DLM_GENL_NAME,
-	.version	= DLM_GENL_VERSION,
-};
+static struct genl_family family;
 
 static int prepare_data(u8 cmd, struct sk_buff **skbp, size_t size)
 {
@@ -75,9 +72,17 @@ static struct genl_ops dlm_nl_ops[] = {
 	},
 };
 
+static struct genl_family family = {
+	.name		= DLM_GENL_NAME,
+	.version	= DLM_GENL_VERSION,
+	.ops		= dlm_nl_ops,
+	.n_ops		= ARRAY_SIZE(dlm_nl_ops),
+	.module		= THIS_MODULE,
+};
+
 int __init dlm_netlink_init(void)
 {
-	return genl_register_family_with_ops(&family, dlm_nl_ops);
+	return genl_register_family(&family);
 }
 
 void dlm_netlink_exit(void)
diff --git a/fs/quota/netlink.c b/fs/quota/netlink.c
index 3965a5cdfaa2..9457c7b0dfa2 100644
--- a/fs/quota/netlink.c
+++ b/fs/quota/netlink.c
@@ -13,6 +13,7 @@ static const struct genl_multicast_group quota_mcgrps[] = {
 
 /* Netlink family structure for quota */
 static struct genl_family quota_genl_family = {
+	.module = THIS_MODULE,
 	.hdrsize = 0,
 	.name = "VFS_DQUOT",
 	.version = 1,
diff --git a/include/linux/drbd_genl.h b/include/linux/drbd_genl.h
index c934d3a96b5e..2896f93808ae 100644
--- a/include/linux/drbd_genl.h
+++ b/include/linux/drbd_genl.h
@@ -67,7 +67,7 @@
  *	genl_magic_func.h
  *		generates an entry in the static genl_ops array,
  *		and static register/unregister functions to
- *		genl_register_family_with_ops().
+ *		genl_register_family().
  *
  *	flags and handler:
  *		GENL_op_init( .doit = x, .dumpit = y, .flags = something)
diff --git a/include/linux/genl_magic_func.h b/include/linux/genl_magic_func.h
index 7c070c1fe457..40c2e39362c8 100644
--- a/include/linux/genl_magic_func.h
+++ b/include/linux/genl_magic_func.h
@@ -259,15 +259,7 @@ static struct genl_ops ZZZ_genl_ops[] __read_mostly = {
  *									{{{2
  */
 #define ZZZ_genl_family		CONCAT_(GENL_MAGIC_FAMILY, _genl_family)
-static struct genl_family ZZZ_genl_family __read_mostly = {
-	.name = __stringify(GENL_MAGIC_FAMILY),
-	.version = GENL_MAGIC_VERSION,
-#ifdef GENL_MAGIC_FAMILY_HDRSZ
-	.hdrsize = NLA_ALIGN(GENL_MAGIC_FAMILY_HDRSZ),
-#endif
-	.maxattr = ARRAY_SIZE(drbd_tla_nl_policy)-1,
-};
-
+static struct genl_family ZZZ_genl_family;
 /*
  * Magic: define multicast groups
  * Magic: define multicast group registration helper
@@ -301,11 +293,23 @@ static int CONCAT_(GENL_MAGIC_FAMILY, _genl_multicast_ ## group)(	\
 #undef GENL_mc_group
 #define GENL_mc_group(group)
 
+static struct genl_family ZZZ_genl_family __read_mostly = {
+	.name = __stringify(GENL_MAGIC_FAMILY),
+	.version = GENL_MAGIC_VERSION,
+#ifdef GENL_MAGIC_FAMILY_HDRSZ
+	.hdrsize = NLA_ALIGN(GENL_MAGIC_FAMILY_HDRSZ),
+#endif
+	.maxattr = ARRAY_SIZE(drbd_tla_nl_policy)-1,
+	.ops = ZZZ_genl_ops,
+	.n_ops = ARRAY_SIZE(ZZZ_genl_ops),
+	.mcgrps = ZZZ_genl_mcgrps,
+	.n_mcgrps = ARRAY_SIZE(ZZZ_genl_mcgrps),
+	.module = THIS_MODULE,
+};
+
 int CONCAT_(GENL_MAGIC_FAMILY, _genl_register)(void)
 {
-	return genl_register_family_with_ops_groups(&ZZZ_genl_family,	\
-						    ZZZ_genl_ops,	\
-						    ZZZ_genl_mcgrps);
+	return genl_register_family(&ZZZ_genl_family);
 }
 
 void CONCAT_(GENL_MAGIC_FAMILY, _genl_unregister)(void)
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 43a5c3975a2f..2298b50cee34 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -39,13 +39,14 @@ struct genl_info;
  *	Note that unbind() will not be called symmetrically if the
  *	generic netlink family is removed while there are still open
  *	sockets.
- * @attrbuf: buffer to store parsed attributes
- * @family_list: family list
- * @mcgrps: multicast groups used by this family (private)
- * @n_mcgrps: number of multicast groups (private)
+ * @attrbuf: buffer to store parsed attributes (private)
+ * @family_list: family list (private)
+ * @mcgrps: multicast groups used by this family
+ * @n_mcgrps: number of multicast groups
  * @mcgrp_offset: starting number of multicast group IDs in this family
- * @ops: the operations supported by this family (private)
- * @n_ops: number of operations supported by this family (private)
+ *	(private)
+ * @ops: the operations supported by this family
+ * @n_ops: number of operations supported by this family
  */
 struct genl_family {
 	unsigned int		id;		/* private */
@@ -64,10 +65,10 @@ struct genl_family {
 	int			(*mcast_bind)(struct net *net, int group);
 	void			(*mcast_unbind)(struct net *net, int group);
 	struct nlattr **	attrbuf;	/* private */
-	const struct genl_ops *	ops;		/* private */
-	const struct genl_multicast_group *mcgrps; /* private */
-	unsigned int		n_ops;		/* private */
-	unsigned int		n_mcgrps;	/* private */
+	const struct genl_ops *	ops;
+	const struct genl_multicast_group *mcgrps;
+	unsigned int		n_ops;
+	unsigned int		n_mcgrps;
 	unsigned int		mcgrp_offset;	/* private */
 	struct list_head	family_list;	/* private */
 	struct module		*module;
@@ -132,55 +133,7 @@ struct genl_ops {
 	u8			flags;
 };
 
-int __genl_register_family(struct genl_family *family);
-
-static inline int genl_register_family(struct genl_family *family)
-{
-	family->module = THIS_MODULE;
-	return __genl_register_family(family);
-}
-
-/**
- * genl_register_family_with_ops - register a generic netlink family with ops
- * @family: generic netlink family
- * @ops: operations to be registered
- * @n_ops: number of elements to register
- *
- * Registers the specified family and operations from the specified table.
- * Only one family may be registered with the same family name or identifier.
- *
- * Either a doit or dumpit callback must be specified for every registered
- * operation or the function will fail. Only one operation structure per
- * command identifier may be registered.
- *
- * See include/net/genetlink.h for more documenation on the operations
- * structure.
- *
- * Return 0 on success or a negative error code.
- */
-static inline int
-_genl_register_family_with_ops_grps(struct genl_family *family,
-				    const struct genl_ops *ops, size_t n_ops,
-				    const struct genl_multicast_group *mcgrps,
-				    size_t n_mcgrps)
-{
-	family->module = THIS_MODULE;
-	family->ops = ops;
-	family->n_ops = n_ops;
-	family->mcgrps = mcgrps;
-	family->n_mcgrps = n_mcgrps;
-	return __genl_register_family(family);
-}
-
-#define genl_register_family_with_ops(family, ops)			\
-	_genl_register_family_with_ops_grps((family),			\
-					    (ops), ARRAY_SIZE(ops),	\
-					    NULL, 0)
-#define genl_register_family_with_ops_groups(family, ops, grps)	\
-	_genl_register_family_with_ops_grps((family),			\
-					    (ops), ARRAY_SIZE(ops),	\
-					    (grps), ARRAY_SIZE(grps))
-
+int genl_register_family(struct genl_family *family);
 int genl_unregister_family(struct genl_family *family);
 void genl_notify(struct genl_family *family, struct sk_buff *skb,
 		 struct genl_info *info, u32 group, gfp_t flags);
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index d7a1a9461a10..4075ece592f2 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -41,11 +41,7 @@ static DEFINE_PER_CPU(__u32, taskstats_seqnum);
 static int family_registered;
 struct kmem_cache *taskstats_cache;
 
-static struct genl_family family = {
-	.name		= TASKSTATS_GENL_NAME,
-	.version	= TASKSTATS_GENL_VERSION,
-	.maxattr	= TASKSTATS_CMD_ATTR_MAX,
-};
+static struct genl_family family;
 
 static const struct nla_policy taskstats_cmd_get_policy[TASKSTATS_CMD_ATTR_MAX+1] = {
 	[TASKSTATS_CMD_ATTR_PID]  = { .type = NLA_U32 },
@@ -650,6 +646,15 @@ static const struct genl_ops taskstats_ops[] = {
 	},
 };
 
+static struct genl_family family = {
+	.name		= TASKSTATS_GENL_NAME,
+	.version	= TASKSTATS_GENL_VERSION,
+	.maxattr	= TASKSTATS_CMD_ATTR_MAX,
+	.module		= THIS_MODULE,
+	.ops		= taskstats_ops,
+	.n_ops		= ARRAY_SIZE(taskstats_ops),
+};
+
 /* Needed early in initialization */
 void __init taskstats_init_early(void)
 {
@@ -666,7 +671,7 @@ static int __init taskstats_init(void)
 {
 	int rc;
 
-	rc = genl_register_family_with_ops(&family, taskstats_ops);
+	rc = genl_register_family(&family);
 	if (rc)
 		return rc;
 
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index a03b0ed7e8dd..e28cec34a016 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -48,13 +48,7 @@
 #include "tp_meter.h"
 #include "translation-table.h"
 
-struct genl_family batadv_netlink_family = {
-	.hdrsize = 0,
-	.name = BATADV_NL_NAME,
-	.version = 1,
-	.maxattr = BATADV_ATTR_MAX,
-	.netnsok = true,
-};
+struct genl_family batadv_netlink_family;
 
 /* multicast groups */
 enum batadv_netlink_multicast_groups {
@@ -609,6 +603,19 @@ static struct genl_ops batadv_netlink_ops[] = {
 
 };
 
+struct genl_family batadv_netlink_family = {
+	.hdrsize = 0,
+	.name = BATADV_NL_NAME,
+	.version = 1,
+	.maxattr = BATADV_ATTR_MAX,
+	.netnsok = true,
+	.module = THIS_MODULE,
+	.ops = batadv_netlink_ops,
+	.n_ops = ARRAY_SIZE(batadv_netlink_ops),
+	.mcgrps = batadv_netlink_mcgrps,
+	.n_mcgrps = ARRAY_SIZE(batadv_netlink_mcgrps),
+};
+
 /**
  * batadv_netlink_register - register batadv genl netlink family
  */
@@ -616,9 +623,7 @@ void __init batadv_netlink_register(void)
 {
 	int ret;
 
-	ret = genl_register_family_with_ops_groups(&batadv_netlink_family,
-						   batadv_netlink_ops,
-						   batadv_netlink_mcgrps);
+	ret = genl_register_family(&batadv_netlink_family);
 	if (ret)
 		pr_warn("unable to register netlink family");
 }
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 701d61eab9a7..6f01d41b1851 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -341,14 +341,7 @@ static void devlink_nl_post_doit(const struct genl_ops *ops,
 	mutex_unlock(&devlink_mutex);
 }
 
-static struct genl_family devlink_nl_family = {
-	.name		= DEVLINK_GENL_NAME,
-	.version	= DEVLINK_GENL_VERSION,
-	.maxattr	= DEVLINK_ATTR_MAX,
-	.netnsok	= true,
-	.pre_doit	= devlink_nl_pre_doit,
-	.post_doit	= devlink_nl_post_doit,
-};
+static struct genl_family devlink_nl_family;
 
 enum devlink_multicast_groups {
 	DEVLINK_MCGRP_CONFIG,
@@ -1617,6 +1610,20 @@ static const struct genl_ops devlink_nl_ops[] = {
 	},
 };
 
+static struct genl_family devlink_nl_family = {
+	.name		= DEVLINK_GENL_NAME,
+	.version	= DEVLINK_GENL_VERSION,
+	.maxattr	= DEVLINK_ATTR_MAX,
+	.netnsok	= true,
+	.pre_doit	= devlink_nl_pre_doit,
+	.post_doit	= devlink_nl_post_doit,
+	.module		= THIS_MODULE,
+	.ops		= devlink_nl_ops,
+	.n_ops		= ARRAY_SIZE(devlink_nl_ops),
+	.mcgrps		= devlink_nl_mcgrps,
+	.n_mcgrps	= ARRAY_SIZE(devlink_nl_mcgrps),
+};
+
 /**
  *	devlink_alloc - Allocate new devlink instance resources
  *
@@ -1839,9 +1846,7 @@ EXPORT_SYMBOL_GPL(devlink_sb_unregister);
 
 static int __init devlink_module_init(void)
 {
-	return genl_register_family_with_ops_groups(&devlink_nl_family,
-						    devlink_nl_ops,
-						    devlink_nl_mcgrps);
+	return genl_register_family(&devlink_nl_family);
 }
 
 static void __exit devlink_module_exit(void)
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index a5320dfcd978..80c002794ff6 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -59,11 +59,7 @@ struct dm_hw_stat_delta {
 	unsigned long last_drop_val;
 };
 
-static struct genl_family net_drop_monitor_family = {
-	.hdrsize        = 0,
-	.name           = "NET_DM",
-	.version        = 2,
-};
+static struct genl_family net_drop_monitor_family;
 
 static DEFINE_PER_CPU(struct per_cpu_dm_data, dm_cpu_data);
 
@@ -350,6 +346,17 @@ static const struct genl_ops dropmon_ops[] = {
 	},
 };
 
+static struct genl_family net_drop_monitor_family = {
+	.hdrsize        = 0,
+	.name           = "NET_DM",
+	.version        = 2,
+	.module		= THIS_MODULE,
+	.ops		= dropmon_ops,
+	.n_ops		= ARRAY_SIZE(dropmon_ops),
+	.mcgrps		= dropmon_mcgrps,
+	.n_mcgrps	= ARRAY_SIZE(dropmon_mcgrps),
+};
+
 static struct notifier_block dropmon_net_notifier = {
 	.notifier_call = dropmon_net_event
 };
@@ -366,8 +373,7 @@ static int __init init_net_drop_monitor(void)
 		return -ENOSPC;
 	}
 
-	rc = genl_register_family_with_ops_groups(&net_drop_monitor_family,
-						  dropmon_ops, dropmon_mcgrps);
+	rc = genl_register_family(&net_drop_monitor_family);
 	if (rc) {
 		pr_err("Could not create drop monitor netlink family\n");
 		return rc;
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 2ad039492bee..aab34c7f6f89 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -131,12 +131,7 @@ static const struct nla_policy hsr_genl_policy[HSR_A_MAX + 1] = {
 	[HSR_A_IF2_SEQ] = { .type = NLA_U16 },
 };
 
-static struct genl_family hsr_genl_family = {
-	.hdrsize = 0,
-	.name = "HSR",
-	.version = 1,
-	.maxattr = HSR_A_MAX,
-};
+static struct genl_family hsr_genl_family;
 
 static const struct genl_multicast_group hsr_mcgrps[] = {
 	{ .name = "hsr-network", },
@@ -466,6 +461,18 @@ static const struct genl_ops hsr_ops[] = {
 	},
 };
 
+static struct genl_family hsr_genl_family = {
+	.hdrsize = 0,
+	.name = "HSR",
+	.version = 1,
+	.maxattr = HSR_A_MAX,
+	.module = THIS_MODULE,
+	.ops = hsr_ops,
+	.n_ops = ARRAY_SIZE(hsr_ops),
+	.mcgrps = hsr_mcgrps,
+	.n_mcgrps = ARRAY_SIZE(hsr_mcgrps),
+};
+
 int __init hsr_netlink_init(void)
 {
 	int rc;
@@ -474,8 +481,7 @@ int __init hsr_netlink_init(void)
 	if (rc)
 		goto fail_rtnl_link_register;
 
-	rc = genl_register_family_with_ops_groups(&hsr_genl_family, hsr_ops,
-						  hsr_mcgrps);
+	rc = genl_register_family(&hsr_genl_family);
 	if (rc)
 		goto fail_genl_register_family;
 
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 19144158b696..08e62470bac2 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -28,13 +28,6 @@
 static unsigned int ieee802154_seq_num;
 static DEFINE_SPINLOCK(ieee802154_seq_lock);
 
-struct genl_family nl802154_family = {
-	.hdrsize	= 0,
-	.name		= IEEE802154_NL_NAME,
-	.version	= 1,
-	.maxattr	= IEEE802154_ATTR_MAX,
-};
-
 /* Requests to userspace */
 struct sk_buff *ieee802154_nl_create(int flags, u8 req)
 {
@@ -138,11 +131,21 @@ static const struct genl_multicast_group ieee802154_mcgrps[] = {
 	[IEEE802154_BEACON_MCGRP] = { .name = IEEE802154_MCAST_BEACON_NAME, },
 };
 
+struct genl_family nl802154_family = {
+	.hdrsize	= 0,
+	.name		= IEEE802154_NL_NAME,
+	.version	= 1,
+	.maxattr	= IEEE802154_ATTR_MAX,
+	.module		= THIS_MODULE,
+	.ops		= ieee8021154_ops,
+	.n_ops		= ARRAY_SIZE(ieee8021154_ops),
+	.mcgrps		= ieee802154_mcgrps,
+	.n_mcgrps	= ARRAY_SIZE(ieee802154_mcgrps),
+};
+
 int __init ieee802154_nl_init(void)
 {
-	return genl_register_family_with_ops_groups(&nl802154_family,
-						    ieee8021154_ops,
-						    ieee802154_mcgrps);
+	return genl_register_family(&nl802154_family);
 }
 
 void ieee802154_nl_exit(void)
diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index 182299858f1d..f7e75578aedd 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -26,22 +26,8 @@
 #include "rdev-ops.h"
 #include "core.h"
 
-static int nl802154_pre_doit(const struct genl_ops *ops, struct sk_buff *skb,
-			     struct genl_info *info);
-
-static void nl802154_post_doit(const struct genl_ops *ops, struct sk_buff *skb,
-			       struct genl_info *info);
-
 /* the netlink family */
-static struct genl_family nl802154_fam = {
-	.name = NL802154_GENL_NAME,	/* have users key off the name instead */
-	.hdrsize = 0,			/* no private header */
-	.version = 1,			/* no particular meaning now */
-	.maxattr = NL802154_ATTR_MAX,
-	.netnsok = true,
-	.pre_doit = nl802154_pre_doit,
-	.post_doit = nl802154_post_doit,
-};
+static struct genl_family nl802154_fam;
 
 /* multicast groups */
 enum nl802154_multicast_groups {
@@ -2476,11 +2462,25 @@ static const struct genl_ops nl802154_ops[] = {
 #endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
 };
 
+static struct genl_family nl802154_fam = {
+	.name = NL802154_GENL_NAME,	/* have users key off the name instead */
+	.hdrsize = 0,			/* no private header */
+	.version = 1,			/* no particular meaning now */
+	.maxattr = NL802154_ATTR_MAX,
+	.netnsok = true,
+	.pre_doit = nl802154_pre_doit,
+	.post_doit = nl802154_post_doit,
+	.module = THIS_MODULE,
+	.ops = nl802154_ops,
+	.n_ops = ARRAY_SIZE(nl802154_ops),
+	.mcgrps = nl802154_mcgrps,
+	.n_mcgrps = ARRAY_SIZE(nl802154_mcgrps),
+};
+
 /* initialisation/exit functions */
 int nl802154_init(void)
 {
-	return genl_register_family_with_ops_groups(&nl802154_fam, nl802154_ops,
-						    nl802154_mcgrps);
+	return genl_register_family(&nl802154_fam);
 }
 
 void nl802154_exit(void)
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index e3fc527c5d37..5b5226a2434f 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -622,13 +622,7 @@ static int fou_destroy(struct net *net, struct fou_cfg *cfg)
 	return err;
 }
 
-static struct genl_family fou_nl_family = {
-	.hdrsize	= 0,
-	.name		= FOU_GENL_NAME,
-	.version	= FOU_GENL_VERSION,
-	.maxattr	= FOU_ATTR_MAX,
-	.netnsok	= true,
-};
+static struct genl_family fou_nl_family;
 
 static const struct nla_policy fou_nl_policy[FOU_ATTR_MAX + 1] = {
 	[FOU_ATTR_PORT] = { .type = NLA_U16, },
@@ -830,6 +824,17 @@ static const struct genl_ops fou_nl_ops[] = {
 	},
 };
 
+static struct genl_family fou_nl_family = {
+	.hdrsize	= 0,
+	.name		= FOU_GENL_NAME,
+	.version	= FOU_GENL_VERSION,
+	.maxattr	= FOU_ATTR_MAX,
+	.netnsok	= true,
+	.module		= THIS_MODULE,
+	.ops		= fou_nl_ops,
+	.n_ops		= ARRAY_SIZE(fou_nl_ops),
+};
+
 size_t fou_encap_hlen(struct ip_tunnel_encap *e)
 {
 	return sizeof(struct udphdr);
@@ -1085,8 +1090,7 @@ static int __init fou_init(void)
 	if (ret)
 		goto exit;
 
-	ret = genl_register_family_with_ops(&fou_nl_family,
-					    fou_nl_ops);
+	ret = genl_register_family(&fou_nl_family);
 	if (ret < 0)
 		goto unregister;
 
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 3da305127b32..bba3c72c4a39 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -742,13 +742,7 @@ void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
 	rcu_read_unlock();
 }
 
-static struct genl_family tcp_metrics_nl_family = {
-	.hdrsize	= 0,
-	.name		= TCP_METRICS_GENL_NAME,
-	.version	= TCP_METRICS_GENL_VERSION,
-	.maxattr	= TCP_METRICS_ATTR_MAX,
-	.netnsok	= true,
-};
+static struct genl_family tcp_metrics_nl_family;
 
 static const struct nla_policy tcp_metrics_nl_policy[TCP_METRICS_ATTR_MAX + 1] = {
 	[TCP_METRICS_ATTR_ADDR_IPV4]	= { .type = NLA_U32, },
@@ -1115,6 +1109,17 @@ static const struct genl_ops tcp_metrics_nl_ops[] = {
 	},
 };
 
+static struct genl_family tcp_metrics_nl_family = {
+	.hdrsize	= 0,
+	.name		= TCP_METRICS_GENL_NAME,
+	.version	= TCP_METRICS_GENL_VERSION,
+	.maxattr	= TCP_METRICS_ATTR_MAX,
+	.netnsok	= true,
+	.module		= THIS_MODULE,
+	.ops		= tcp_metrics_nl_ops,
+	.n_ops		= ARRAY_SIZE(tcp_metrics_nl_ops),
+};
+
 static unsigned int tcpmhash_entries;
 static int __init set_tcpmhash_entries(char *str)
 {
@@ -1178,8 +1183,7 @@ void __init tcp_metrics_init(void)
 	if (ret < 0)
 		panic("Could not allocate the tcp_metrics hash table\n");
 
-	ret = genl_register_family_with_ops(&tcp_metrics_nl_family,
-					    tcp_metrics_nl_ops);
+	ret = genl_register_family(&tcp_metrics_nl_family);
 	if (ret < 0)
 		panic("Could not register tcp_metrics generic netlink\n");
 }
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index 0d57e27d1cdd..97f7b0cc4675 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -118,14 +118,7 @@ static const struct rhashtable_params rht_params = {
 	.obj_cmpfn = ila_cmpfn,
 };
 
-static struct genl_family ila_nl_family = {
-	.hdrsize	= 0,
-	.name		= ILA_GENL_NAME,
-	.version	= ILA_GENL_VERSION,
-	.maxattr	= ILA_ATTR_MAX,
-	.netnsok	= true,
-	.parallel_ops	= true,
-};
+static struct genl_family ila_nl_family;
 
 static const struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
 	[ILA_ATTR_LOCATOR] = { .type = NLA_U64, },
@@ -560,6 +553,18 @@ static const struct genl_ops ila_nl_ops[] = {
 	},
 };
 
+static struct genl_family ila_nl_family = {
+	.hdrsize	= 0,
+	.name		= ILA_GENL_NAME,
+	.version	= ILA_GENL_VERSION,
+	.maxattr	= ILA_ATTR_MAX,
+	.netnsok	= true,
+	.parallel_ops	= true,
+	.module		= THIS_MODULE,
+	.ops		= ila_nl_ops,
+	.n_ops		= ARRAY_SIZE(ila_nl_ops),
+};
+
 #define ILA_HASH_TABLE_SIZE 1024
 
 static __net_init int ila_init_net(struct net *net)
@@ -630,8 +635,7 @@ int ila_xlat_init(void)
 	if (ret)
 		goto exit;
 
-	ret = genl_register_family_with_ops(&ila_nl_family,
-					    ila_nl_ops);
+	ret = genl_register_family(&ila_nl_family);
 	if (ret < 0)
 		goto unregister;
 
diff --git a/net/irda/irnetlink.c b/net/irda/irnetlink.c
index f23b81aa91fe..07877347c2f7 100644
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -24,12 +24,7 @@
 
 
 
-static struct genl_family irda_nl_family = {
-	.name = IRDA_NL_NAME,
-	.hdrsize = 0,
-	.version = IRDA_NL_VERSION,
-	.maxattr = IRDA_NL_CMD_MAX,
-};
+static struct genl_family irda_nl_family;
 
 static struct net_device * ifname_to_netdev(struct net *net, struct genl_info *info)
 {
@@ -146,9 +141,19 @@ static const struct genl_ops irda_nl_ops[] = {
 
 };
 
+static struct genl_family irda_nl_family = {
+	.name = IRDA_NL_NAME,
+	.hdrsize = 0,
+	.version = IRDA_NL_VERSION,
+	.maxattr = IRDA_NL_CMD_MAX,
+	.module = THIS_MODULE,
+	.ops = irda_nl_ops,
+	.n_ops = ARRAY_SIZE(irda_nl_ops),
+};
+
 int irda_nl_register(void)
 {
-	return genl_register_family_with_ops(&irda_nl_family, irda_nl_ops);
+	return genl_register_family(&irda_nl_family);
 }
 
 void irda_nl_unregister(void)
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 4fbf1f41ac52..e4e8c0769a6b 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -31,13 +31,7 @@
 #include "l2tp_core.h"
 
 
-static struct genl_family l2tp_nl_family = {
-	.name		= L2TP_GENL_NAME,
-	.version	= L2TP_GENL_VERSION,
-	.hdrsize	= 0,
-	.maxattr	= L2TP_ATTR_MAX,
-	.netnsok	= true,
-};
+static struct genl_family l2tp_nl_family;
 
 static const struct genl_multicast_group l2tp_multicast_group[] = {
 	{
@@ -976,6 +970,19 @@ static const struct genl_ops l2tp_nl_ops[] = {
 	},
 };
 
+static struct genl_family l2tp_nl_family = {
+	.name		= L2TP_GENL_NAME,
+	.version	= L2TP_GENL_VERSION,
+	.hdrsize	= 0,
+	.maxattr	= L2TP_ATTR_MAX,
+	.netnsok	= true,
+	.module		= THIS_MODULE,
+	.ops		= l2tp_nl_ops,
+	.n_ops		= ARRAY_SIZE(l2tp_nl_ops),
+	.mcgrps		= l2tp_multicast_group,
+	.n_mcgrps	= ARRAY_SIZE(l2tp_multicast_group),
+};
+
 int l2tp_nl_register_ops(enum l2tp_pwtype pw_type, const struct l2tp_nl_cmd_ops *ops)
 {
 	int ret;
@@ -1012,9 +1019,7 @@ EXPORT_SYMBOL_GPL(l2tp_nl_unregister_ops);
 static int l2tp_nl_init(void)
 {
 	pr_info("L2TP netlink interface\n");
-	return genl_register_family_with_ops_groups(&l2tp_nl_family,
-						    l2tp_nl_ops,
-						    l2tp_multicast_group);
+	return genl_register_family(&l2tp_nl_family);
 }
 
 static void l2tp_nl_cleanup(void)
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ceed66cdd03e..ea3e8aed063f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2840,13 +2840,7 @@ static struct nf_sockopt_ops ip_vs_sockopts = {
  */
 
 /* IPVS genetlink family */
-static struct genl_family ip_vs_genl_family = {
-	.hdrsize	= 0,
-	.name		= IPVS_GENL_NAME,
-	.version	= IPVS_GENL_VERSION,
-	.maxattr	= IPVS_CMD_MAX,
-	.netnsok        = true,         /* Make ipvsadm to work on netns */
-};
+static struct genl_family ip_vs_genl_family;
 
 /* Policy used for first-level command attributes */
 static const struct nla_policy ip_vs_cmd_policy[IPVS_CMD_ATTR_MAX + 1] = {
@@ -3871,10 +3865,20 @@ static const struct genl_ops ip_vs_genl_ops[] = {
 	},
 };
 
+static struct genl_family ip_vs_genl_family = {
+	.hdrsize	= 0,
+	.name		= IPVS_GENL_NAME,
+	.version	= IPVS_GENL_VERSION,
+	.maxattr	= IPVS_CMD_MAX,
+	.netnsok        = true,         /* Make ipvsadm to work on netns */
+	.module		= THIS_MODULE,
+	.ops		= ip_vs_genl_ops,
+	.n_ops		= ARRAY_SIZE(ip_vs_genl_ops),
+};
+
 static int __init ip_vs_genl_register(void)
 {
-	return genl_register_family_with_ops(&ip_vs_genl_family,
-					     ip_vs_genl_ops);
+	return genl_register_family(&ip_vs_genl_family);
 }
 
 static void ip_vs_genl_unregister(void)
diff --git a/net/netlabel/netlabel_calipso.c b/net/netlabel/netlabel_calipso.c
index 152e503b8c5d..ca7c9c411a5c 100644
--- a/net/netlabel/netlabel_calipso.c
+++ b/net/netlabel/netlabel_calipso.c
@@ -60,12 +60,7 @@ struct netlbl_domhsh_walk_arg {
 };
 
 /* NetLabel Generic NETLINK CALIPSO family */
-static struct genl_family netlbl_calipso_gnl_family = {
-	.hdrsize = 0,
-	.name = NETLBL_NLTYPE_CALIPSO_NAME,
-	.version = NETLBL_PROTO_VERSION,
-	.maxattr = NLBL_CALIPSO_A_MAX,
-};
+static struct genl_family netlbl_calipso_gnl_family;
 
 /* NetLabel Netlink attribute policy */
 static const struct nla_policy calipso_genl_policy[NLBL_CALIPSO_A_MAX + 1] = {
@@ -354,6 +349,16 @@ static const struct genl_ops netlbl_calipso_ops[] = {
 	},
 };
 
+static struct genl_family netlbl_calipso_gnl_family = {
+	.hdrsize = 0,
+	.name = NETLBL_NLTYPE_CALIPSO_NAME,
+	.version = NETLBL_PROTO_VERSION,
+	.maxattr = NLBL_CALIPSO_A_MAX,
+	.module = THIS_MODULE,
+	.ops = netlbl_calipso_ops,
+	.n_ops = ARRAY_SIZE(netlbl_calipso_ops),
+};
+
 /* NetLabel Generic NETLINK Protocol Functions
  */
 
@@ -367,8 +372,7 @@ static const struct genl_ops netlbl_calipso_ops[] = {
  */
 int __init netlbl_calipso_genl_init(void)
 {
-	return genl_register_family_with_ops(&netlbl_calipso_gnl_family,
-					     netlbl_calipso_ops);
+	return genl_register_family(&netlbl_calipso_gnl_family);
 }
 
 static const struct netlbl_calipso_ops *calipso_ops;
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 755b284e7ad4..a665eae91245 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -59,13 +59,7 @@ struct netlbl_domhsh_walk_arg {
 };
 
 /* NetLabel Generic NETLINK CIPSOv4 family */
-static struct genl_family netlbl_cipsov4_gnl_family = {
-	.hdrsize = 0,
-	.name = NETLBL_NLTYPE_CIPSOV4_NAME,
-	.version = NETLBL_PROTO_VERSION,
-	.maxattr = NLBL_CIPSOV4_A_MAX,
-};
-
+static struct genl_family netlbl_cipsov4_gnl_family;
 /* NetLabel Netlink attribute policy */
 static const struct nla_policy netlbl_cipsov4_genl_policy[NLBL_CIPSOV4_A_MAX + 1] = {
 	[NLBL_CIPSOV4_A_DOI] = { .type = NLA_U32 },
@@ -766,6 +760,16 @@ static const struct genl_ops netlbl_cipsov4_ops[] = {
 	},
 };
 
+static struct genl_family netlbl_cipsov4_gnl_family = {
+	.hdrsize = 0,
+	.name = NETLBL_NLTYPE_CIPSOV4_NAME,
+	.version = NETLBL_PROTO_VERSION,
+	.maxattr = NLBL_CIPSOV4_A_MAX,
+	.module = THIS_MODULE,
+	.ops = netlbl_cipsov4_ops,
+	.n_ops = ARRAY_SIZE(netlbl_cipsov4_ops),
+};
+
 /*
  * NetLabel Generic NETLINK Protocol Functions
  */
@@ -780,6 +784,5 @@ static const struct genl_ops netlbl_cipsov4_ops[] = {
  */
 int __init netlbl_cipsov4_genl_init(void)
 {
-	return genl_register_family_with_ops(&netlbl_cipsov4_gnl_family,
-					     netlbl_cipsov4_ops);
+	return genl_register_family(&netlbl_cipsov4_gnl_family);
 }
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 3b00f2368fcd..ecfe8eb149db 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -60,12 +60,7 @@ struct netlbl_domhsh_walk_arg {
 };
 
 /* NetLabel Generic NETLINK CIPSOv4 family */
-static struct genl_family netlbl_mgmt_gnl_family = {
-	.hdrsize = 0,
-	.name = NETLBL_NLTYPE_MGMT_NAME,
-	.version = NETLBL_PROTO_VERSION,
-	.maxattr = NLBL_MGMT_A_MAX,
-};
+static struct genl_family netlbl_mgmt_gnl_family;
 
 /* NetLabel Netlink attribute policy */
 static const struct nla_policy netlbl_mgmt_genl_policy[NLBL_MGMT_A_MAX + 1] = {
@@ -833,6 +828,16 @@ static const struct genl_ops netlbl_mgmt_genl_ops[] = {
 	},
 };
 
+static struct genl_family netlbl_mgmt_gnl_family = {
+	.hdrsize = 0,
+	.name = NETLBL_NLTYPE_MGMT_NAME,
+	.version = NETLBL_PROTO_VERSION,
+	.maxattr = NLBL_MGMT_A_MAX,
+	.module = THIS_MODULE,
+	.ops = netlbl_mgmt_genl_ops,
+	.n_ops = ARRAY_SIZE(netlbl_mgmt_genl_ops),
+};
+
 /*
  * NetLabel Generic NETLINK Protocol Functions
  */
@@ -847,6 +852,5 @@ static const struct genl_ops netlbl_mgmt_genl_ops[] = {
  */
 int __init netlbl_mgmt_genl_init(void)
 {
-	return genl_register_family_with_ops(&netlbl_mgmt_gnl_family,
-					     netlbl_mgmt_genl_ops);
+	return genl_register_family(&netlbl_mgmt_gnl_family);
 }
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index c2ea8d1f653a..5dbbad41114f 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -123,12 +123,7 @@ static struct netlbl_unlhsh_iface __rcu *netlbl_unlhsh_def;
 static u8 netlabel_unlabel_acceptflg;
 
 /* NetLabel Generic NETLINK unlabeled family */
-static struct genl_family netlbl_unlabel_gnl_family = {
-	.hdrsize = 0,
-	.name = NETLBL_NLTYPE_UNLABELED_NAME,
-	.version = NETLBL_PROTO_VERSION,
-	.maxattr = NLBL_UNLABEL_A_MAX,
-};
+static struct genl_family netlbl_unlabel_gnl_family;
 
 /* NetLabel Netlink attribute policy */
 static const struct nla_policy netlbl_unlabel_genl_policy[NLBL_UNLABEL_A_MAX + 1] = {
@@ -1377,6 +1372,16 @@ static const struct genl_ops netlbl_unlabel_genl_ops[] = {
 	},
 };
 
+static struct genl_family netlbl_unlabel_gnl_family = {
+	.hdrsize = 0,
+	.name = NETLBL_NLTYPE_UNLABELED_NAME,
+	.version = NETLBL_PROTO_VERSION,
+	.maxattr = NLBL_UNLABEL_A_MAX,
+	.module = THIS_MODULE,
+	.ops = netlbl_unlabel_genl_ops,
+	.n_ops = ARRAY_SIZE(netlbl_unlabel_genl_ops),
+};
+
 /*
  * NetLabel Generic NETLINK Protocol Functions
  */
@@ -1391,8 +1396,7 @@ static const struct genl_ops netlbl_unlabel_genl_ops[] = {
  */
 int __init netlbl_unlabel_genl_init(void)
 {
-	return genl_register_family_with_ops(&netlbl_unlabel_gnl_family,
-					     netlbl_unlabel_genl_ops);
+	return genl_register_family(&netlbl_unlabel_gnl_family);
 }
 
 /*
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f19ec969edee..ca582ee4ae05 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -344,18 +344,18 @@ static int genl_validate_ops(const struct genl_family *family)
 }
 
 /**
- * __genl_register_family - register a generic netlink family
+ * genl_register_family - register a generic netlink family
  * @family: generic netlink family
  *
  * Registers the specified family after validating it first. Only one
  * family may be registered with the same family name or identifier.
  *
- * The family's ops array must already be assigned, you can use the
- * genl_register_family_with_ops() helper function.
+ * The family's ops, multicast groups and module pointer must already
+ * be assigned.
  *
  * Return 0 on success or a negative error code.
  */
-int __genl_register_family(struct genl_family *family)
+int genl_register_family(struct genl_family *family)
 {
 	int err, i;
 
@@ -429,7 +429,7 @@ int __genl_register_family(struct genl_family *family)
 	genl_unlock_all();
 	return err;
 }
-EXPORT_SYMBOL(__genl_register_family);
+EXPORT_SYMBOL(genl_register_family);
 
 /**
  * genl_unregister_family - unregister generic netlink family
@@ -452,7 +452,6 @@ int genl_unregister_family(struct genl_family *family)
 		genl_unregister_mc_groups(family);
 
 		list_del(&rc->family_list);
-		family->n_ops = 0;
 		up_write(&cb_lock);
 		wait_event(genl_sk_destructing_waitq,
 			   atomic_read(&genl_sk_destructing_cnt) == 0);
@@ -681,13 +680,7 @@ static void genl_rcv(struct sk_buff *skb)
  * Controller
  **************************************************************************/
 
-static struct genl_family genl_ctrl = {
-	.id = GENL_ID_CTRL,
-	.name = "nlctrl",
-	.version = 0x2,
-	.maxattr = CTRL_ATTR_MAX,
-	.netnsok = true,
-};
+static struct genl_family genl_ctrl;
 
 static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
 			  u32 flags, struct sk_buff *skb, u8 cmd)
@@ -997,6 +990,19 @@ static const struct genl_multicast_group genl_ctrl_groups[] = {
 	{ .name = "notify", },
 };
 
+static struct genl_family genl_ctrl = {
+	.module = THIS_MODULE,
+	.ops = genl_ctrl_ops,
+	.n_ops = ARRAY_SIZE(genl_ctrl_ops),
+	.mcgrps = genl_ctrl_groups,
+	.n_mcgrps = ARRAY_SIZE(genl_ctrl_groups),
+	.id = GENL_ID_CTRL,
+	.name = "nlctrl",
+	.version = 0x2,
+	.maxattr = CTRL_ATTR_MAX,
+	.netnsok = true,
+};
+
 static int genl_bind(struct net *net, int group)
 {
 	int i, err = -ENOENT;
@@ -1086,8 +1092,7 @@ static int __init genl_init(void)
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++)
 		INIT_LIST_HEAD(&family_ht[i]);
 
-	err = genl_register_family_with_ops_groups(&genl_ctrl, genl_ctrl_ops,
-						   genl_ctrl_groups);
+	err = genl_register_family(&genl_ctrl);
 	if (err < 0)
 		goto problem;
 
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index c230403e066c..450b1e5144cc 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -38,13 +38,7 @@ static const struct genl_multicast_group nfc_genl_mcgrps[] = {
 	{ .name = NFC_GENL_MCAST_EVENT_NAME, },
 };
 
-static struct genl_family nfc_genl_family = {
-	.hdrsize = 0,
-	.name = NFC_GENL_NAME,
-	.version = NFC_GENL_VERSION,
-	.maxattr = NFC_ATTR_MAX,
-};
-
+static struct genl_family nfc_genl_family;
 static const struct nla_policy nfc_genl_policy[NFC_ATTR_MAX + 1] = {
 	[NFC_ATTR_DEVICE_INDEX] = { .type = NLA_U32 },
 	[NFC_ATTR_DEVICE_NAME] = { .type = NLA_STRING,
@@ -1752,6 +1746,18 @@ static const struct genl_ops nfc_genl_ops[] = {
 	},
 };
 
+static struct genl_family nfc_genl_family = {
+	.hdrsize = 0,
+	.name = NFC_GENL_NAME,
+	.version = NFC_GENL_VERSION,
+	.maxattr = NFC_ATTR_MAX,
+	.module = THIS_MODULE,
+	.ops = nfc_genl_ops,
+	.n_ops = ARRAY_SIZE(nfc_genl_ops),
+	.mcgrps = nfc_genl_mcgrps,
+	.n_mcgrps = ARRAY_SIZE(nfc_genl_mcgrps),
+};
+
 
 struct urelease_work {
 	struct	work_struct w;
@@ -1837,9 +1843,7 @@ int __init nfc_genl_init(void)
 {
 	int rc;
 
-	rc = genl_register_family_with_ops_groups(&nfc_genl_family,
-						  nfc_genl_ops,
-						  nfc_genl_mcgrps);
+	rc = genl_register_family(&nfc_genl_family);
 	if (rc)
 		return rc;
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index f9fef7dfba15..ad6a111a0014 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -679,6 +679,7 @@ static struct genl_family dp_packet_genl_family = {
 	.parallel_ops = true,
 	.ops = dp_packet_genl_ops,
 	.n_ops = ARRAY_SIZE(dp_packet_genl_ops),
+	.module = THIS_MODULE,
 };
 
 static void get_dp_stats(const struct datapath *dp, struct ovs_dp_stats *stats,
@@ -1445,6 +1446,7 @@ static struct genl_family dp_flow_genl_family = {
 	.n_ops = ARRAY_SIZE(dp_flow_genl_ops),
 	.mcgrps = &ovs_dp_flow_multicast_group,
 	.n_mcgrps = 1,
+	.module = THIS_MODULE,
 };
 
 static size_t ovs_dp_cmd_msg_size(void)
@@ -1830,6 +1832,7 @@ static struct genl_family dp_datapath_genl_family = {
 	.n_ops = ARRAY_SIZE(dp_datapath_genl_ops),
 	.mcgrps = &ovs_dp_datapath_multicast_group,
 	.n_mcgrps = 1,
+	.module = THIS_MODULE,
 };
 
 /* Called with ovs_mutex or RCU read lock. */
@@ -2251,6 +2254,7 @@ struct genl_family dp_vport_genl_family = {
 	.n_ops = ARRAY_SIZE(dp_vport_genl_ops),
 	.mcgrps = &ovs_dp_vport_multicast_group,
 	.n_mcgrps = 1,
+	.module = THIS_MODULE,
 };
 
 static struct genl_family * const dp_genl_families[] = {
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 383b8fedabc7..74a405bf107b 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -135,14 +135,6 @@ const struct nla_policy tipc_nl_udp_policy[TIPC_NLA_UDP_MAX + 1] = {
 /* Users of the legacy API (tipc-config) can't handle that we add operations,
  * so we have a separate genl handling for the new API.
  */
-struct genl_family tipc_genl_family = {
-	.name		= TIPC_GENL_V2_NAME,
-	.version	= TIPC_GENL_V2_VERSION,
-	.hdrsize	= 0,
-	.maxattr	= TIPC_NLA_MAX,
-	.netnsok	= true,
-};
-
 static const struct genl_ops tipc_genl_v2_ops[] = {
 	{
 		.cmd	= TIPC_NL_BEARER_DISABLE,
@@ -257,6 +249,17 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 #endif
 };
 
+struct genl_family tipc_genl_family = {
+	.name		= TIPC_GENL_V2_NAME,
+	.version	= TIPC_GENL_V2_VERSION,
+	.hdrsize	= 0,
+	.maxattr	= TIPC_NLA_MAX,
+	.netnsok	= true,
+	.module		= THIS_MODULE,
+	.ops		= tipc_genl_v2_ops,
+	.n_ops		= ARRAY_SIZE(tipc_genl_v2_ops),
+};
+
 int tipc_nlmsg_parse(const struct nlmsghdr *nlh, struct nlattr ***attr)
 {
 	u32 maxattr = tipc_genl_family.maxattr;
@@ -272,8 +275,7 @@ int tipc_netlink_start(void)
 {
 	int res;
 
-	res = genl_register_family_with_ops(&tipc_genl_family,
-					    tipc_genl_v2_ops);
+	res = genl_register_family(&tipc_genl_family);
 	if (res) {
 		pr_err("Failed to register netlink interface\n");
 		return res;
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index f04428e4c8e5..07b19931e458 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -1215,27 +1215,29 @@ static int tipc_nl_compat_recv(struct sk_buff *skb, struct genl_info *info)
 	return err;
 }
 
+static struct genl_ops tipc_genl_compat_ops[] = {
+	{
+		.cmd		= TIPC_GENL_CMD,
+		.doit		= tipc_nl_compat_recv,
+	},
+};
+
 static struct genl_family tipc_genl_compat_family = {
 	.name		= TIPC_GENL_NAME,
 	.version	= TIPC_GENL_VERSION,
 	.hdrsize	= TIPC_GENL_HDRLEN,
 	.maxattr	= 0,
 	.netnsok	= true,
-};
-
-static struct genl_ops tipc_genl_compat_ops[] = {
-	{
-		.cmd		= TIPC_GENL_CMD,
-		.doit		= tipc_nl_compat_recv,
-	},
+	.module		= THIS_MODULE,
+	.ops		= tipc_genl_compat_ops,
+	.n_ops		= ARRAY_SIZE(tipc_genl_compat_ops),
 };
 
 int tipc_netlink_compat_start(void)
 {
 	int res;
 
-	res = genl_register_family_with_ops(&tipc_genl_compat_family,
-					    tipc_genl_compat_ops);
+	res = genl_register_family(&tipc_genl_compat_family);
 	if (res) {
 		pr_err("Failed to register legacy compat interface\n");
 		return res;
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 8ac83a41585f..587e1627681f 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -572,15 +572,20 @@ struct d_level D_LEVEL[] = {
 size_t D_LEVEL_SIZE = ARRAY_SIZE(D_LEVEL);
 
 
+static const struct genl_multicast_group wimax_gnl_mcgrps[] = {
+	{ .name = "msg", },
+};
+
 struct genl_family wimax_gnl_family = {
 	.name = "WiMAX",
 	.version = WIMAX_GNL_VERSION,
 	.hdrsize = 0,
 	.maxattr = WIMAX_GNL_ATTR_MAX,
-};
-
-static const struct genl_multicast_group wimax_gnl_mcgrps[] = {
-	{ .name = "msg", },
+	.module = THIS_MODULE,
+	.ops = wimax_gnl_ops,
+	.n_ops = ARRAY_SIZE(wimax_gnl_ops),
+	.mcgrps = wimax_gnl_mcgrps,
+	.n_mcgrps = ARRAY_SIZE(wimax_gnl_mcgrps),
 };
 
 
@@ -595,11 +600,7 @@ int __init wimax_subsys_init(void)
 	d_parse_params(D_LEVEL, D_LEVEL_SIZE, wimax_debug_params,
 		       "wimax.debug");
 
-	snprintf(wimax_gnl_family.name, sizeof(wimax_gnl_family.name),
-		 "WiMAX");
-	result = genl_register_family_with_ops_groups(&wimax_gnl_family,
-						      wimax_gnl_ops,
-						      wimax_gnl_mcgrps);
+	result = genl_register_family(&wimax_gnl_family);
 	if (unlikely(result < 0)) {
 		pr_err("cannot register generic netlink family: %d\n", result);
 		goto error_register_family;
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 714beafe05e0..8e5ca3c47593 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -32,21 +32,8 @@ static int nl80211_crypto_settings(struct cfg80211_registered_device *rdev,
 				   struct cfg80211_crypto_settings *settings,
 				   int cipher_limit);
 
-static int nl80211_pre_doit(const struct genl_ops *ops, struct sk_buff *skb,
-			    struct genl_info *info);
-static void nl80211_post_doit(const struct genl_ops *ops, struct sk_buff *skb,
-			      struct genl_info *info);
-
 /* the netlink family */
-static struct genl_family nl80211_fam = {
-	.name = NL80211_GENL_NAME,	/* have users key off the name instead */
-	.hdrsize = 0,			/* no private header */
-	.version = 1,			/* no particular meaning now */
-	.maxattr = NL80211_ATTR_MAX,
-	.netnsok = true,
-	.pre_doit = nl80211_pre_doit,
-	.post_doit = nl80211_post_doit,
-};
+static struct genl_family nl80211_fam;
 
 /* multicast groups */
 enum nl80211_multicast_groups {
@@ -12599,6 +12586,21 @@ static const struct genl_ops nl80211_ops[] = {
 	},
 };
 
+static struct genl_family nl80211_fam = {
+	.name = NL80211_GENL_NAME,	/* have users key off the name instead */
+	.hdrsize = 0,			/* no private header */
+	.version = 1,			/* no particular meaning now */
+	.maxattr = NL80211_ATTR_MAX,
+	.netnsok = true,
+	.pre_doit = nl80211_pre_doit,
+	.post_doit = nl80211_post_doit,
+	.module = THIS_MODULE,
+	.ops = nl80211_ops,
+	.n_ops = ARRAY_SIZE(nl80211_ops),
+	.mcgrps = nl80211_mcgrps,
+	.n_mcgrps = ARRAY_SIZE(nl80211_mcgrps),
+};
+
 /* notification functions */
 
 void nl80211_notify_wiphy(struct cfg80211_registered_device *rdev,
@@ -14565,8 +14567,7 @@ int nl80211_init(void)
 {
 	int err;
 
-	err = genl_register_family_with_ops_groups(&nl80211_fam, nl80211_ops,
-						   nl80211_mcgrps);
+	err = genl_register_family(&nl80211_fam);
 	if (err)
 		return err;
 
-- 
2.8.1
