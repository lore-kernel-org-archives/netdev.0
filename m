From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 2/5] genetlink: no longer support using static family IDs
Date: Mon, 24 Oct 2016 14:40:02 +0200
Message-ID: <1477312805-7110-3-git-send-email-johannes@sipsolutions.net>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51690 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934865AbcJXMkL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 08:40:11 -0400
In-Reply-To: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Static family IDs have never really been used, the only
use case was the workaround I introduced for those users
that assumed their family ID was also their multicast
group ID.

Additionally, because static family IDs would never be
reserved by the generic netlink code, using a relatively
low ID would only work for built-in families that can be
registered immediately after generic netlink is started,
which is basically only the control family (apart from
the workaround code, which I also had to add code for so
it would reserve those IDs)

Thus, anything other than GENL_ID_GENERATE is flawed and
luckily not used except in the cases I mentioned. Move
those workarounds into a few lines of code, and then get
rid of GENL_ID_GENERATE entirely, making it more robust.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/acpi/event.c                  |  1 -
 drivers/net/gtp.c                     |  1 -
 drivers/net/macsec.c                  |  1 -
 drivers/net/team/team.c               |  1 -
 drivers/net/wireless/mac80211_hwsim.c |  1 -
 drivers/scsi/pmcraid.c                |  6 ------
 drivers/target/target_core_user.c     |  1 -
 drivers/thermal/thermal_core.c        |  1 -
 fs/dlm/netlink.c                      |  1 -
 fs/quota/netlink.c                    |  7 -------
 include/linux/genl_magic_func.h       |  1 -
 include/net/genetlink.h               |  7 ++-----
 include/uapi/linux/genetlink.h        |  1 -
 kernel/taskstats.c                    |  1 -
 net/batman-adv/netlink.c              |  1 -
 net/core/devlink.c                    |  1 -
 net/core/drop_monitor.c               |  1 -
 net/hsr/hsr_netlink.c                 |  1 -
 net/ieee802154/netlink.c              |  1 -
 net/ieee802154/nl802154.c             |  1 -
 net/ipv4/fou.c                        |  1 -
 net/ipv4/tcp_metrics.c                |  1 -
 net/ipv6/ila/ila_xlat.c               |  1 -
 net/irda/irnetlink.c                  |  1 -
 net/l2tp/l2tp_netlink.c               |  1 -
 net/netfilter/ipvs/ip_vs_ctl.c        |  1 -
 net/netlabel/netlabel_calipso.c       |  1 -
 net/netlabel/netlabel_cipso_v4.c      |  1 -
 net/netlabel/netlabel_mgmt.c          |  1 -
 net/netlabel/netlabel_unlabeled.c     |  1 -
 net/netlink/genetlink.c               | 37 +++++++++++++++++++++--------------
 net/nfc/netlink.c                     |  1 -
 net/openvswitch/datapath.c            |  4 ----
 net/tipc/netlink.c                    |  1 -
 net/tipc/netlink_compat.c             |  1 -
 net/wimax/stack.c                     |  1 -
 net/wireless/nl80211.c                |  1 -
 37 files changed, 24 insertions(+), 69 deletions(-)

diff --git a/drivers/acpi/event.c b/drivers/acpi/event.c
index e24ea4e796e4..8dfca3d53131 100644
--- a/drivers/acpi/event.c
+++ b/drivers/acpi/event.c
@@ -83,7 +83,6 @@ static const struct genl_multicast_group acpi_event_mcgrps[] = {
 };
 
 static struct genl_family acpi_event_genl_family = {
-	.id = GENL_ID_GENERATE,
 	.name = ACPI_GENL_FAMILY_NAME,
 	.version = ACPI_GENL_VERSION,
 	.maxattr = ACPI_GENL_ATTR_MAX,
diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 97e0cbca0a08..f66737ba1299 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -1095,7 +1095,6 @@ static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
 }
 
 static struct genl_family gtp_genl_family = {
-	.id		= GENL_ID_GENERATE,
 	.name		= "gtp",
 	.version	= 0,
 	.hdrsize	= 0,
diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 1a134cb2d52c..a5309b81a786 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -1422,7 +1422,6 @@ static void clear_tx_sa(struct macsec_tx_sa *tx_sa)
 }
 
 static struct genl_family macsec_fam = {
-	.id		= GENL_ID_GENERATE,
 	.name		= MACSEC_GENL_NAME,
 	.hdrsize	= 0,
 	.version	= MACSEC_GENL_VERSION,
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index a380649bf6b5..0b50205764ff 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2151,7 +2151,6 @@ static struct rtnl_link_ops team_link_ops __read_mostly = {
  ***********************************/
 
 static struct genl_family team_nl_family = {
-	.id		= GENL_ID_GENERATE,
 	.name		= TEAM_GENL_NAME,
 	.version	= TEAM_GENL_VERSION,
 	.maxattr	= TEAM_ATTR_MAX,
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index e95b79bccf9b..54b6cd62676e 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -589,7 +589,6 @@ struct hwsim_radiotap_ack_hdr {
 
 /* MAC80211_HWSIM netlinf family */
 static struct genl_family hwsim_genl_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = "MAC80211_HWSIM",
 	.version = 1,
diff --git a/drivers/scsi/pmcraid.c b/drivers/scsi/pmcraid.c
index 68a5c347fae9..cc50eb87b28a 100644
--- a/drivers/scsi/pmcraid.c
+++ b/drivers/scsi/pmcraid.c
@@ -1369,12 +1369,6 @@ static struct genl_multicast_group pmcraid_mcgrps[] = {
 };
 
 static struct genl_family pmcraid_event_family = {
-	/*
-	 * Due to prior multicast group abuse (the code having assumed that
-	 * the family ID can be used as a multicast group ID) we need to
-	 * statically allocate a family (and thus group) ID.
-	 */
-	.id = GENL_ID_PMCRAID,
 	.name = "pmcraid",
 	.version = 1,
 	.maxattr = PMCRAID_AEN_ATTR_MAX,
diff --git a/drivers/target/target_core_user.c b/drivers/target/target_core_user.c
index 62bf4fe5704a..313a0ef3cda7 100644
--- a/drivers/target/target_core_user.c
+++ b/drivers/target/target_core_user.c
@@ -148,7 +148,6 @@ static const struct genl_multicast_group tcmu_mcgrps[] = {
 
 /* Our generic netlink family */
 static struct genl_family tcmu_genl_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = "TCM-USER",
 	.version = 1,
diff --git a/drivers/thermal/thermal_core.c b/drivers/thermal/thermal_core.c
index 226b0b4aced6..68d7503f6417 100644
--- a/drivers/thermal/thermal_core.c
+++ b/drivers/thermal/thermal_core.c
@@ -2164,7 +2164,6 @@ static const struct genl_multicast_group thermal_event_mcgrps[] = {
 };
 
 static struct genl_family thermal_event_genl_family = {
-	.id = GENL_ID_GENERATE,
 	.name = THERMAL_GENL_FAMILY_NAME,
 	.version = THERMAL_GENL_VERSION,
 	.maxattr = THERMAL_GENL_ATTR_MAX,
diff --git a/fs/dlm/netlink.c b/fs/dlm/netlink.c
index 1e6e227134d7..00d226956264 100644
--- a/fs/dlm/netlink.c
+++ b/fs/dlm/netlink.c
@@ -17,7 +17,6 @@ static uint32_t dlm_nl_seqnum;
 static uint32_t listener_nlportid;
 
 static struct genl_family family = {
-	.id		= GENL_ID_GENERATE,
 	.name		= DLM_GENL_NAME,
 	.version	= DLM_GENL_VERSION,
 };
diff --git a/fs/quota/netlink.c b/fs/quota/netlink.c
index 8b252673d454..3965a5cdfaa2 100644
--- a/fs/quota/netlink.c
+++ b/fs/quota/netlink.c
@@ -13,13 +13,6 @@ static const struct genl_multicast_group quota_mcgrps[] = {
 
 /* Netlink family structure for quota */
 static struct genl_family quota_genl_family = {
-	/*
-	 * Needed due to multicast group ID abuse - old code assumed
-	 * the family ID was also a valid multicast group ID (which
-	 * isn't true) and userspace might thus rely on it. Assign a
-	 * static ID for this group to make dealing with that easier.
-	 */
-	.id = GENL_ID_VFS_DQUOT,
 	.hdrsize = 0,
 	.name = "VFS_DQUOT",
 	.version = 1,
diff --git a/include/linux/genl_magic_func.h b/include/linux/genl_magic_func.h
index 667c31101b8b..7c070c1fe457 100644
--- a/include/linux/genl_magic_func.h
+++ b/include/linux/genl_magic_func.h
@@ -260,7 +260,6 @@ static struct genl_ops ZZZ_genl_ops[] __read_mostly = {
  */
 #define ZZZ_genl_family		CONCAT_(GENL_MAGIC_FAMILY, _genl_family)
 static struct genl_family ZZZ_genl_family __read_mostly = {
-	.id = GENL_ID_GENERATE,
 	.name = __stringify(GENL_MAGIC_FAMILY),
 	.version = GENL_MAGIC_VERSION,
 #ifdef GENL_MAGIC_FAMILY_HDRSZ
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index ef9defb3f5bc..43a5c3975a2f 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -20,7 +20,7 @@ struct genl_info;
 
 /**
  * struct genl_family - generic netlink family
- * @id: protocol family idenfitier
+ * @id: protocol family identifier (private)
  * @hdrsize: length of user specific header in bytes
  * @name: name of family
  * @version: protocol version
@@ -48,7 +48,7 @@ struct genl_info;
  * @n_ops: number of operations supported by this family (private)
  */
 struct genl_family {
-	unsigned int		id;
+	unsigned int		id;		/* private */
 	unsigned int		hdrsize;
 	char			name[GENL_NAMSIZ];
 	unsigned int		version;
@@ -149,9 +149,6 @@ static inline int genl_register_family(struct genl_family *family)
  * Registers the specified family and operations from the specified table.
  * Only one family may be registered with the same family name or identifier.
  *
- * The family id may equal GENL_ID_GENERATE causing an unique id to
- * be automatically generated and assigned.
- *
  * Either a doit or dumpit callback must be specified for every registered
  * operation or the function will fail. Only one operation structure per
  * command identifier may be registered.
diff --git a/include/uapi/linux/genetlink.h b/include/uapi/linux/genetlink.h
index 5512c90af7e3..d9b2db4a29c6 100644
--- a/include/uapi/linux/genetlink.h
+++ b/include/uapi/linux/genetlink.h
@@ -26,7 +26,6 @@ struct genlmsghdr {
 /*
  * List of reserved static generic netlink identifiers:
  */
-#define GENL_ID_GENERATE	0
 #define GENL_ID_CTRL		NLMSG_MIN_TYPE
 #define GENL_ID_VFS_DQUOT	(NLMSG_MIN_TYPE + 1)
 #define GENL_ID_PMCRAID		(NLMSG_MIN_TYPE + 2)
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index b3f05ee20d18..d7a1a9461a10 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -42,7 +42,6 @@ static int family_registered;
 struct kmem_cache *taskstats_cache;
 
 static struct genl_family family = {
-	.id		= GENL_ID_GENERATE,
 	.name		= TASKSTATS_GENL_NAME,
 	.version	= TASKSTATS_GENL_VERSION,
 	.maxattr	= TASKSTATS_CMD_ATTR_MAX,
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 64cb6acbe0a6..a03b0ed7e8dd 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -49,7 +49,6 @@
 #include "translation-table.h"
 
 struct genl_family batadv_netlink_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = BATADV_NL_NAME,
 	.version = 1,
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 1b5063088f1a..701d61eab9a7 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -342,7 +342,6 @@ static void devlink_nl_post_doit(const struct genl_ops *ops,
 }
 
 static struct genl_family devlink_nl_family = {
-	.id		= GENL_ID_GENERATE,
 	.name		= DEVLINK_GENL_NAME,
 	.version	= DEVLINK_GENL_VERSION,
 	.maxattr	= DEVLINK_ATTR_MAX,
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 72cfb0c61125..a5320dfcd978 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -60,7 +60,6 @@ struct dm_hw_stat_delta {
 };
 
 static struct genl_family net_drop_monitor_family = {
-	.id             = GENL_ID_GENERATE,
 	.hdrsize        = 0,
 	.name           = "NET_DM",
 	.version        = 2,
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index d4d1617f43a8..2ad039492bee 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -132,7 +132,6 @@ static const struct nla_policy hsr_genl_policy[HSR_A_MAX + 1] = {
 };
 
 static struct genl_family hsr_genl_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = "HSR",
 	.version = 1,
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index c8133c07ceee..19144158b696 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -29,7 +29,6 @@ static unsigned int ieee802154_seq_num;
 static DEFINE_SPINLOCK(ieee802154_seq_lock);
 
 struct genl_family nl802154_family = {
-	.id		= GENL_ID_GENERATE,
 	.hdrsize	= 0,
 	.name		= IEEE802154_NL_NAME,
 	.version	= 1,
diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index 21aabadccd0e..182299858f1d 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -34,7 +34,6 @@ static void nl802154_post_doit(const struct genl_ops *ops, struct sk_buff *skb,
 
 /* the netlink family */
 static struct genl_family nl802154_fam = {
-	.id = GENL_ID_GENERATE,		/* don't bother with a hardcoded ID */
 	.name = NL802154_GENL_NAME,	/* have users key off the name instead */
 	.hdrsize = 0,			/* no private header */
 	.version = 1,			/* no particular meaning now */
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index cf50f7e2b012..e3fc527c5d37 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -623,7 +623,6 @@ static int fou_destroy(struct net *net, struct fou_cfg *cfg)
 }
 
 static struct genl_family fou_nl_family = {
-	.id		= GENL_ID_GENERATE,
 	.hdrsize	= 0,
 	.name		= FOU_GENL_NAME,
 	.version	= FOU_GENL_VERSION,
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index bf1f3b2b29d1..3da305127b32 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -743,7 +743,6 @@ void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
 }
 
 static struct genl_family tcp_metrics_nl_family = {
-	.id		= GENL_ID_GENERATE,
 	.hdrsize	= 0,
 	.name		= TCP_METRICS_GENL_NAME,
 	.version	= TCP_METRICS_GENL_VERSION,
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index e604013dd814..0d57e27d1cdd 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -119,7 +119,6 @@ static const struct rhashtable_params rht_params = {
 };
 
 static struct genl_family ila_nl_family = {
-	.id		= GENL_ID_GENERATE,
 	.hdrsize	= 0,
 	.name		= ILA_GENL_NAME,
 	.version	= ILA_GENL_VERSION,
diff --git a/net/irda/irnetlink.c b/net/irda/irnetlink.c
index e15c40e86660..f23b81aa91fe 100644
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -25,7 +25,6 @@
 
 
 static struct genl_family irda_nl_family = {
-	.id = GENL_ID_GENERATE,
 	.name = IRDA_NL_NAME,
 	.hdrsize = 0,
 	.version = IRDA_NL_VERSION,
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index bf3117771822..4fbf1f41ac52 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -32,7 +32,6 @@
 
 
 static struct genl_family l2tp_nl_family = {
-	.id		= GENL_ID_GENERATE,
 	.name		= L2TP_GENL_NAME,
 	.version	= L2TP_GENL_VERSION,
 	.hdrsize	= 0,
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c3c809b2e712..ceed66cdd03e 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2841,7 +2841,6 @@ static struct nf_sockopt_ops ip_vs_sockopts = {
 
 /* IPVS genetlink family */
 static struct genl_family ip_vs_genl_family = {
-	.id		= GENL_ID_GENERATE,
 	.hdrsize	= 0,
 	.name		= IPVS_GENL_NAME,
 	.version	= IPVS_GENL_VERSION,
diff --git a/net/netlabel/netlabel_calipso.c b/net/netlabel/netlabel_calipso.c
index 2ec93c5e77bb..152e503b8c5d 100644
--- a/net/netlabel/netlabel_calipso.c
+++ b/net/netlabel/netlabel_calipso.c
@@ -61,7 +61,6 @@ struct netlbl_domhsh_walk_arg {
 
 /* NetLabel Generic NETLINK CALIPSO family */
 static struct genl_family netlbl_calipso_gnl_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = NETLBL_NLTYPE_CALIPSO_NAME,
 	.version = NETLBL_PROTO_VERSION,
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 7fd1104ba900..755b284e7ad4 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -60,7 +60,6 @@ struct netlbl_domhsh_walk_arg {
 
 /* NetLabel Generic NETLINK CIPSOv4 family */
 static struct genl_family netlbl_cipsov4_gnl_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = NETLBL_NLTYPE_CIPSOV4_NAME,
 	.version = NETLBL_PROTO_VERSION,
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index f85d0e07af2d..3b00f2368fcd 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -61,7 +61,6 @@ struct netlbl_domhsh_walk_arg {
 
 /* NetLabel Generic NETLINK CIPSOv4 family */
 static struct genl_family netlbl_mgmt_gnl_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = NETLBL_NLTYPE_MGMT_NAME,
 	.version = NETLBL_PROTO_VERSION,
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 4528cff9138b..c2ea8d1f653a 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -124,7 +124,6 @@ static u8 netlabel_unlabel_acceptflg;
 
 /* NetLabel Generic NETLINK unlabeled family */
 static struct genl_family netlbl_unlabel_gnl_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = NETLBL_NLTYPE_UNLABELED_NAME,
 	.version = NETLBL_PROTO_VERSION,
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 01291b7a27bb..f19ec969edee 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -349,8 +349,6 @@ static int genl_validate_ops(const struct genl_family *family)
  *
  * Registers the specified family after validating it first. Only one
  * family may be registered with the same family name or identifier.
- * The family id may equal GENL_ID_GENERATE causing an unique id to
- * be automatically generated and assigned.
  *
  * The family's ops array must already be assigned, you can use the
  * genl_register_family_with_ops() helper function.
@@ -359,13 +357,7 @@ static int genl_validate_ops(const struct genl_family *family)
  */
 int __genl_register_family(struct genl_family *family)
 {
-	int err = -EINVAL, i;
-
-	if (family->id && family->id < GENL_MIN_ID)
-		goto errout;
-
-	if (family->id > GENL_MAX_ID)
-		goto errout;
+	int err, i;
 
 	err = genl_validate_ops(family);
 	if (err)
@@ -378,8 +370,27 @@ int __genl_register_family(struct genl_family *family)
 		goto errout_locked;
 	}
 
-	if (family->id == GENL_ID_GENERATE) {
-		u16 newid = genl_generate_id();
+	if (family == &genl_ctrl) {
+		family->id = GENL_ID_CTRL;
+	} else {
+		u16 newid;
+
+		/* this should be left zero in the struct */
+		WARN_ON(family->id);
+
+		/*
+		 * Sadly, a few cases need to be special-cased
+		 * due to them having previously abused the API
+		 * and having used their family ID also as their
+		 * multicast group ID, so we use reserved IDs
+		 * for both to be sure we can do that mapping.
+		 */
+		if (strcmp(family->name, "pmcraid") == 0)
+			newid = GENL_ID_PMCRAID;
+		else if (strcmp(family->name, "VFS_DQUOT") == 0)
+			newid = GENL_ID_VFS_DQUOT;
+		else
+			newid = genl_generate_id();
 
 		if (!newid) {
 			err = -ENOMEM;
@@ -387,9 +398,6 @@ int __genl_register_family(struct genl_family *family)
 		}
 
 		family->id = newid;
-	} else if (genl_family_find_byid(family->id)) {
-		err = -EEXIST;
-		goto errout_locked;
 	}
 
 	if (family->maxattr && !family->parallel_ops) {
@@ -419,7 +427,6 @@ int __genl_register_family(struct genl_family *family)
 
 errout_locked:
 	genl_unlock_all();
-errout:
 	return err;
 }
 EXPORT_SYMBOL(__genl_register_family);
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 79786bf62b88..c230403e066c 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -39,7 +39,6 @@ static const struct genl_multicast_group nfc_genl_mcgrps[] = {
 };
 
 static struct genl_family nfc_genl_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = NFC_GENL_NAME,
 	.version = NFC_GENL_VERSION,
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 194435aa1165..f9fef7dfba15 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -671,7 +671,6 @@ static const struct genl_ops dp_packet_genl_ops[] = {
 };
 
 static struct genl_family dp_packet_genl_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_PACKET_FAMILY,
 	.version = OVS_PACKET_VERSION,
@@ -1436,7 +1435,6 @@ static const struct genl_ops dp_flow_genl_ops[] = {
 };
 
 static struct genl_family dp_flow_genl_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_FLOW_FAMILY,
 	.version = OVS_FLOW_VERSION,
@@ -1822,7 +1820,6 @@ static const struct genl_ops dp_datapath_genl_ops[] = {
 };
 
 static struct genl_family dp_datapath_genl_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_DATAPATH_FAMILY,
 	.version = OVS_DATAPATH_VERSION,
@@ -2244,7 +2241,6 @@ static const struct genl_ops dp_vport_genl_ops[] = {
 };
 
 struct genl_family dp_vport_genl_family = {
-	.id = GENL_ID_GENERATE,
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_VPORT_FAMILY,
 	.version = OVS_VPORT_VERSION,
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 4b94f3cfe3af..383b8fedabc7 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -136,7 +136,6 @@ const struct nla_policy tipc_nl_udp_policy[TIPC_NLA_UDP_MAX + 1] = {
  * so we have a separate genl handling for the new API.
  */
 struct genl_family tipc_genl_family = {
-	.id		= GENL_ID_GENERATE,
 	.name		= TIPC_GENL_V2_NAME,
 	.version	= TIPC_GENL_V2_VERSION,
 	.hdrsize	= 0,
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 1fd464764765..f04428e4c8e5 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -1216,7 +1216,6 @@ static int tipc_nl_compat_recv(struct sk_buff *skb, struct genl_info *info)
 }
 
 static struct genl_family tipc_genl_compat_family = {
-	.id		= GENL_ID_GENERATE,
 	.name		= TIPC_GENL_NAME,
 	.version	= TIPC_GENL_VERSION,
 	.hdrsize	= TIPC_GENL_HDRLEN,
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 3f816e2971ee..8ac83a41585f 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -573,7 +573,6 @@ size_t D_LEVEL_SIZE = ARRAY_SIZE(D_LEVEL);
 
 
 struct genl_family wimax_gnl_family = {
-	.id = GENL_ID_GENERATE,
 	.name = "WiMAX",
 	.version = WIMAX_GNL_VERSION,
 	.hdrsize = 0,
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 7d8cb3330c86..714beafe05e0 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -39,7 +39,6 @@ static void nl80211_post_doit(const struct genl_ops *ops, struct sk_buff *skb,
 
 /* the netlink family */
 static struct genl_family nl80211_fam = {
-	.id = GENL_ID_GENERATE,		/* don't bother with a hardcoded ID */
 	.name = NL80211_GENL_NAME,	/* have users key off the name instead */
 	.hdrsize = 0,			/* no private header */
 	.version = 1,			/* no particular meaning now */
-- 
2.8.1
