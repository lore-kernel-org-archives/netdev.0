From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/2] bonding: options handling cleanup
Date: Tue, 4 Mar 2014 16:36:44 -0800
Message-ID: <20140304163644.432f60d0@nehalam.linuxnetplumber.net>
References: <20140304163425.44995c59@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	David Miller <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35756 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756055AbaCEAgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 19:36:48 -0500
Received: by mail-pa0-f41.google.com with SMTP id fa1so301581pad.28
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 16:36:48 -0800 (PST)
In-Reply-To: <20140304163425.44995c59@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make local functions static (ie. only used in bond_options.c)
Make bond options parsing tables constant.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


---
 drivers/net/bonding/bond_main.c    |    3 
 drivers/net/bonding/bond_options.c |  190 ++++++++++++++++++++++++-------------
 drivers/net/bonding/bond_options.h |   57 +----------
 drivers/net/bonding/bond_sysfs.c   |   16 +--
 drivers/net/bonding/bonding.h      |    2 
 5 files changed, 141 insertions(+), 127 deletions(-)

--- a/drivers/net/bonding/bond_options.c	2014-03-04 16:00:13.886482614 -0800
+++ b/drivers/net/bonding/bond_options.c	2014-03-04 16:01:26.074087172 -0800
@@ -20,7 +20,59 @@
 #include <linux/inet.h>
 #include "bonding.h"
 
-static struct bond_opt_value bond_mode_tbl[] = {
+static int bond_option_active_slave_set(struct bonding *bond,
+					struct bond_opt_value *newval);
+static int bond_option_miimon_set(struct bonding *bond,
+				  struct bond_opt_value *newval);
+static int bond_option_updelay_set(struct bonding *bond,
+				   struct bond_opt_value *newval);
+static int bond_option_downdelay_set(struct bonding *bond,
+				     struct bond_opt_value *newval);
+static int bond_option_use_carrier_set(struct bonding *bond,
+				       struct bond_opt_value *newval);
+static int bond_option_arp_interval_set(struct bonding *bond,
+					struct bond_opt_value *newval);
+static int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
+static int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
+static int bond_option_arp_ip_targets_set(struct bonding *bond,
+					  struct bond_opt_value *newval);
+static int bond_option_arp_validate_set(struct bonding *bond,
+					struct bond_opt_value *newval);
+static int bond_option_arp_all_targets_set(struct bonding *bond,
+					   struct bond_opt_value *newval);
+static int bond_option_primary_set(struct bonding *bond,
+				   struct bond_opt_value *newval);
+static int bond_option_primary_reselect_set(struct bonding *bond,
+					    struct bond_opt_value *newval);
+static int bond_option_fail_over_mac_set(struct bonding *bond,
+					 struct bond_opt_value *newval);
+static int bond_option_xmit_hash_policy_set(struct bonding *bond,
+					    struct bond_opt_value *newval);
+static int bond_option_resend_igmp_set(struct bonding *bond,
+				       struct bond_opt_value *newval);
+static int bond_option_num_peer_notif_set(struct bonding *bond,
+					  struct bond_opt_value *newval);
+static int bond_option_all_slaves_active_set(struct bonding *bond,
+					     struct bond_opt_value *newval);
+static int bond_option_min_links_set(struct bonding *bond,
+				     struct bond_opt_value *newval);
+static int bond_option_lp_interval_set(struct bonding *bond,
+				       struct bond_opt_value *newval);
+static int bond_option_pps_set(struct bonding *bond,
+			       struct bond_opt_value *newval);
+static int bond_option_lacp_rate_set(struct bonding *bond,
+				     struct bond_opt_value *newval);
+static int bond_option_ad_select_set(struct bonding *bond,
+				     struct bond_opt_value *newval);
+static int bond_option_queue_id_set(struct bonding *bond,
+				    struct bond_opt_value *newval);
+static int bond_option_mode_set(struct bonding *bond,
+				struct bond_opt_value *newval);
+static int bond_option_slaves_set(struct bonding *bond,
+				  struct bond_opt_value *newval);
+
+
+static const struct bond_opt_value bond_mode_tbl[] = {
 	{ "balance-rr",    BOND_MODE_ROUNDROBIN,   BOND_VALFLAG_DEFAULT},
 	{ "active-backup", BOND_MODE_ACTIVEBACKUP, 0},
 	{ "balance-xor",   BOND_MODE_XOR,          0},
@@ -31,13 +83,13 @@ static struct bond_opt_value bond_mode_t
 	{ NULL,            -1,                     0},
 };
 
-static struct bond_opt_value bond_pps_tbl[] = {
+static const struct bond_opt_value bond_pps_tbl[] = {
 	{ "default", 1,         BOND_VALFLAG_DEFAULT},
 	{ "maxval",  USHRT_MAX, BOND_VALFLAG_MAX},
 	{ NULL,      -1,        0},
 };
 
-static struct bond_opt_value bond_xmit_hashtype_tbl[] = {
+static const struct bond_opt_value bond_xmit_hashtype_tbl[] = {
 	{ "layer2",   BOND_XMIT_POLICY_LAYER2, BOND_VALFLAG_DEFAULT},
 	{ "layer3+4", BOND_XMIT_POLICY_LAYER34, 0},
 	{ "layer2+3", BOND_XMIT_POLICY_LAYER23, 0},
@@ -46,7 +98,7 @@ static struct bond_opt_value bond_xmit_h
 	{ NULL,       -1,                       0},
 };
 
-static struct bond_opt_value bond_arp_validate_tbl[] = {
+static const struct bond_opt_value bond_arp_validate_tbl[] = {
 	{ "none",		BOND_ARP_VALIDATE_NONE,		BOND_VALFLAG_DEFAULT},
 	{ "active",		BOND_ARP_VALIDATE_ACTIVE,	0},
 	{ "backup",		BOND_ARP_VALIDATE_BACKUP,	0},
@@ -57,76 +109,76 @@ static struct bond_opt_value bond_arp_va
 	{ NULL,			-1,				0},
 };
 
-static struct bond_opt_value bond_arp_all_targets_tbl[] = {
+static const struct bond_opt_value bond_arp_all_targets_tbl[] = {
 	{ "any", BOND_ARP_TARGETS_ANY, BOND_VALFLAG_DEFAULT},
 	{ "all", BOND_ARP_TARGETS_ALL, 0},
 	{ NULL,  -1,                   0},
 };
 
-static struct bond_opt_value bond_fail_over_mac_tbl[] = {
+static const struct bond_opt_value bond_fail_over_mac_tbl[] = {
 	{ "none",   BOND_FOM_NONE,   BOND_VALFLAG_DEFAULT},
 	{ "active", BOND_FOM_ACTIVE, 0},
 	{ "follow", BOND_FOM_FOLLOW, 0},
 	{ NULL,     -1,              0},
 };
 
-static struct bond_opt_value bond_intmax_tbl[] = {
+static const struct bond_opt_value bond_intmax_tbl[] = {
 	{ "off",     0,       BOND_VALFLAG_DEFAULT},
 	{ "maxval",  INT_MAX, BOND_VALFLAG_MAX},
 };
 
-static struct bond_opt_value bond_lacp_rate_tbl[] = {
+static const struct bond_opt_value bond_lacp_rate_tbl[] = {
 	{ "slow", AD_LACP_SLOW, 0},
 	{ "fast", AD_LACP_FAST, 0},
 	{ NULL,   -1,           0},
 };
 
-static struct bond_opt_value bond_ad_select_tbl[] = {
+static const struct bond_opt_value bond_ad_select_tbl[] = {
 	{ "stable",    BOND_AD_STABLE,    BOND_VALFLAG_DEFAULT},
 	{ "bandwidth", BOND_AD_BANDWIDTH, 0},
 	{ "count",     BOND_AD_COUNT,     0},
 	{ NULL,        -1,                0},
 };
 
-static struct bond_opt_value bond_num_peer_notif_tbl[] = {
+static const struct bond_opt_value bond_num_peer_notif_tbl[] = {
 	{ "off",     0,   0},
 	{ "maxval",  255, BOND_VALFLAG_MAX},
 	{ "default", 1,   BOND_VALFLAG_DEFAULT},
 	{ NULL,      -1,  0}
 };
 
-static struct bond_opt_value bond_primary_reselect_tbl[] = {
+static const struct bond_opt_value bond_primary_reselect_tbl[] = {
 	{ "always",  BOND_PRI_RESELECT_ALWAYS,  BOND_VALFLAG_DEFAULT},
 	{ "better",  BOND_PRI_RESELECT_BETTER,  0},
 	{ "failure", BOND_PRI_RESELECT_FAILURE, 0},
 	{ NULL,      -1},
 };
 
-static struct bond_opt_value bond_use_carrier_tbl[] = {
+static const struct bond_opt_value bond_use_carrier_tbl[] = {
 	{ "off", 0,  0},
 	{ "on",  1,  BOND_VALFLAG_DEFAULT},
 	{ NULL,  -1, 0}
 };
 
-static struct bond_opt_value bond_all_slaves_active_tbl[] = {
+static const struct bond_opt_value bond_all_slaves_active_tbl[] = {
 	{ "off", 0,  BOND_VALFLAG_DEFAULT},
 	{ "on",  1,  0},
 	{ NULL,  -1, 0}
 };
 
-static struct bond_opt_value bond_resend_igmp_tbl[] = {
+static const struct bond_opt_value bond_resend_igmp_tbl[] = {
 	{ "off",     0,   0},
 	{ "maxval",  255, BOND_VALFLAG_MAX},
 	{ "default", 1,   BOND_VALFLAG_DEFAULT},
 	{ NULL,      -1,  0}
 };
 
-static struct bond_opt_value bond_lp_interval_tbl[] = {
+static const struct bond_opt_value bond_lp_interval_tbl[] = {
 	{ "minval",  1,       BOND_VALFLAG_MIN | BOND_VALFLAG_DEFAULT},
 	{ "maxval",  INT_MAX, BOND_VALFLAG_MAX},
 };
 
-static struct bond_option bond_opts[] = {
+static const struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
 		.name = "mode",
@@ -315,9 +367,9 @@ static struct bond_option bond_opts[] =
 };
 
 /* Searches for a value in opt's values[] table */
-struct bond_opt_value *bond_opt_get_val(unsigned int option, u64 val)
+const struct bond_opt_value *bond_opt_get_val(unsigned int option, u64 val)
 {
-	struct bond_option *opt;
+	const struct bond_option *opt;
 	int i;
 
 	opt = bond_opt_get(option);
@@ -331,7 +383,7 @@ struct bond_opt_value *bond_opt_get_val(
 }
 
 /* Searches for a value in opt's values[] table which matches the flagmask */
-static struct bond_opt_value *bond_opt_get_flags(const struct bond_option *opt,
+static const struct bond_opt_value *bond_opt_get_flags(const struct bond_option *opt,
 						 u32 flagmask)
 {
 	int i;
@@ -348,7 +400,7 @@ static struct bond_opt_value *bond_opt_g
  */
 static bool bond_opt_check_range(const struct bond_option *opt, u64 val)
 {
-	struct bond_opt_value *minval, *maxval;
+	const struct bond_opt_value *minval, *maxval;
 
 	minval = bond_opt_get_flags(opt, BOND_VALFLAG_MIN);
 	maxval = bond_opt_get_flags(opt, BOND_VALFLAG_MAX);
@@ -368,11 +420,12 @@ static bool bond_opt_check_range(const s
  * or the struct_opt_value that matched. It also strips the new line from
  * @val->string if it's present.
  */
-struct bond_opt_value *bond_opt_parse(const struct bond_option *opt,
-				      struct bond_opt_value *val)
+const struct bond_opt_value *bond_opt_parse(const struct bond_option *opt,
+					    struct bond_opt_value *val)
 {
 	char *p, valstr[BOND_OPT_MAX_NAMELEN + 1] = { 0, };
-	struct bond_opt_value *tbl, *ret = NULL;
+	const struct bond_opt_value *tbl;
+	const struct bond_opt_value *ret = NULL;
 	bool checkval;
 	int i, rv;
 
@@ -576,7 +629,7 @@ int bond_opt_tryset_rtnl(struct bonding
  * This function checks if option is valid and if so returns a pointer
  * to its entry in the bond_opts[] option array.
  */
-struct bond_option *bond_opt_get(unsigned int option)
+const struct bond_option *bond_opt_get(unsigned int option)
 {
 	if (!BOND_OPT_VALID(option))
 		return NULL;
@@ -622,8 +675,8 @@ struct net_device *bond_option_active_sl
 	return __bond_option_active_slave_get(bond, bond->curr_active_slave);
 }
 
-int bond_option_active_slave_set(struct bonding *bond,
-				 struct bond_opt_value *newval)
+static int bond_option_active_slave_set(struct bonding *bond,
+					struct bond_opt_value *newval)
 {
 	char ifname[IFNAMSIZ] = { 0, };
 	struct net_device *slave_dev;
@@ -691,7 +744,8 @@ int bond_option_active_slave_set(struct
 	return ret;
 }
 
-int bond_option_miimon_set(struct bonding *bond, struct bond_opt_value *newval)
+static int bond_option_miimon_set(struct bonding *bond,
+				  struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting MII monitoring interval to %llu\n",
 		bond->dev->name, newval->value);
@@ -728,7 +782,8 @@ int bond_option_miimon_set(struct bondin
 	return 0;
 }
 
-int bond_option_updelay_set(struct bonding *bond, struct bond_opt_value *newval)
+static int bond_option_updelay_set(struct bonding *bond,
+				   struct bond_opt_value *newval)
 {
 	int value = newval->value;
 
@@ -751,8 +806,8 @@ int bond_option_updelay_set(struct bondi
 	return 0;
 }
 
-int bond_option_downdelay_set(struct bonding *bond,
-			      struct bond_opt_value *newval)
+static int bond_option_downdelay_set(struct bonding *bond,
+				     struct bond_opt_value *newval)
 {
 	int value = newval->value;
 
@@ -775,8 +830,8 @@ int bond_option_downdelay_set(struct bon
 	return 0;
 }
 
-int bond_option_use_carrier_set(struct bonding *bond,
-				struct bond_opt_value *newval)
+static int bond_option_use_carrier_set(struct bonding *bond,
+				       struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting use_carrier to %llu\n",
 		bond->dev->name, newval->value);
@@ -785,8 +840,8 @@ int bond_option_use_carrier_set(struct b
 	return 0;
 }
 
-int bond_option_arp_interval_set(struct bonding *bond,
-				 struct bond_opt_value *newval)
+static int bond_option_arp_interval_set(struct bonding *bond,
+					struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting ARP monitoring interval to %llu\n",
 		bond->dev->name, newval->value);
@@ -867,7 +922,7 @@ static int _bond_option_arp_ip_target_ad
 	return 0;
 }
 
-int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target)
+static int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target)
 {
 	int ret;
 
@@ -879,7 +934,7 @@ int bond_option_arp_ip_target_add(struct
 	return ret;
 }
 
-int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target)
+static int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target)
 {
 	__be32 *targets = bond->params.arp_targets;
 	struct list_head *iter;
@@ -935,8 +990,8 @@ void bond_option_arp_ip_targets_clear(st
 	write_unlock_bh(&bond->lock);
 }
 
-int bond_option_arp_ip_targets_set(struct bonding *bond,
-				   struct bond_opt_value *newval)
+static int bond_option_arp_ip_targets_set(struct bonding *bond,
+					  struct bond_opt_value *newval)
 {
 	int ret = -EPERM;
 	__be32 target;
@@ -962,8 +1017,8 @@ int bond_option_arp_ip_targets_set(struc
 	return ret;
 }
 
-int bond_option_arp_validate_set(struct bonding *bond,
-				 struct bond_opt_value *newval)
+static int bond_option_arp_validate_set(struct bonding *bond,
+					struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting arp_validate to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -979,8 +1034,8 @@ int bond_option_arp_validate_set(struct
 	return 0;
 }
 
-int bond_option_arp_all_targets_set(struct bonding *bond,
-				    struct bond_opt_value *newval)
+static int bond_option_arp_all_targets_set(struct bonding *bond,
+					   struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting arp_all_targets to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -989,7 +1044,8 @@ int bond_option_arp_all_targets_set(stru
 	return 0;
 }
 
-int bond_option_primary_set(struct bonding *bond, struct bond_opt_value *newval)
+static int bond_option_primary_set(struct bonding *bond,
+				   struct bond_opt_value *newval)
 {
 	char *p, *primary = newval->string;
 	struct list_head *iter;
@@ -1041,8 +1097,8 @@ out:
 	return 0;
 }
 
-int bond_option_primary_reselect_set(struct bonding *bond,
-				     struct bond_opt_value *newval)
+static int bond_option_primary_reselect_set(struct bonding *bond,
+					    struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting primary_reselect to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -1057,8 +1113,8 @@ int bond_option_primary_reselect_set(str
 	return 0;
 }
 
-int bond_option_fail_over_mac_set(struct bonding *bond,
-				  struct bond_opt_value *newval)
+static int bond_option_fail_over_mac_set(struct bonding *bond,
+					 struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting fail_over_mac to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -1067,8 +1123,8 @@ int bond_option_fail_over_mac_set(struct
 	return 0;
 }
 
-int bond_option_xmit_hash_policy_set(struct bonding *bond,
-				     struct bond_opt_value *newval)
+static int bond_option_xmit_hash_policy_set(struct bonding *bond,
+					    struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting xmit hash policy to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -1077,8 +1133,8 @@ int bond_option_xmit_hash_policy_set(str
 	return 0;
 }
 
-int bond_option_resend_igmp_set(struct bonding *bond,
-				struct bond_opt_value *newval)
+static int bond_option_resend_igmp_set(struct bonding *bond,
+				       struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting resend_igmp to %llu\n",
 		bond->dev->name, newval->value);
@@ -1087,7 +1143,7 @@ int bond_option_resend_igmp_set(struct b
 	return 0;
 }
 
-int bond_option_num_peer_notif_set(struct bonding *bond,
+static int bond_option_num_peer_notif_set(struct bonding *bond,
 				   struct bond_opt_value *newval)
 {
 	bond->params.num_peer_notif = newval->value;
@@ -1095,8 +1151,8 @@ int bond_option_num_peer_notif_set(struc
 	return 0;
 }
 
-int bond_option_all_slaves_active_set(struct bonding *bond,
-				      struct bond_opt_value *newval)
+static int bond_option_all_slaves_active_set(struct bonding *bond,
+					     struct bond_opt_value *newval)
 {
 	struct list_head *iter;
 	struct slave *slave;
@@ -1116,8 +1172,8 @@ int bond_option_all_slaves_active_set(st
 	return 0;
 }
 
-int bond_option_min_links_set(struct bonding *bond,
-			      struct bond_opt_value *newval)
+static int bond_option_min_links_set(struct bonding *bond,
+				     struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting min links value to %llu\n",
 		bond->dev->name, newval->value);
@@ -1126,15 +1182,16 @@ int bond_option_min_links_set(struct bon
 	return 0;
 }
 
-int bond_option_lp_interval_set(struct bonding *bond,
-				struct bond_opt_value *newval)
+static int bond_option_lp_interval_set(struct bonding *bond,
+				       struct bond_opt_value *newval)
 {
 	bond->params.lp_interval = newval->value;
 
 	return 0;
 }
 
-int bond_option_pps_set(struct bonding *bond, struct bond_opt_value *newval)
+static int bond_option_pps_set(struct bonding *bond,
+			       struct bond_opt_value *newval)
 {
 	bond->params.packets_per_slave = newval->value;
 	if (newval->value > 0) {
@@ -1151,8 +1208,8 @@ int bond_option_pps_set(struct bonding *
 	return 0;
 }
 
-int bond_option_lacp_rate_set(struct bonding *bond,
-			      struct bond_opt_value *newval)
+static int bond_option_lacp_rate_set(struct bonding *bond,
+				     struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting LACP rate to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -1162,8 +1219,8 @@ int bond_option_lacp_rate_set(struct bon
 	return 0;
 }
 
-int bond_option_ad_select_set(struct bonding *bond,
-			      struct bond_opt_value *newval)
+static int bond_option_ad_select_set(struct bonding *bond,
+				     struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting ad_select to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -1172,8 +1229,8 @@ int bond_option_ad_select_set(struct bon
 	return 0;
 }
 
-int bond_option_queue_id_set(struct bonding *bond,
-			     struct bond_opt_value *newval)
+static int bond_option_queue_id_set(struct bonding *bond,
+				    struct bond_opt_value *newval)
 {
 	struct slave *slave, *update_slave;
 	struct net_device *sdev;
@@ -1233,7 +1290,8 @@ err_no_cmd:
 
 }
 
-int bond_option_slaves_set(struct bonding *bond, struct bond_opt_value *newval)
+static int bond_option_slaves_set(struct bonding *bond,
+				  struct bond_opt_value *newval)
 {
 	char command[IFNAMSIZ + 1] = { 0, };
 	struct net_device *dev;
--- a/drivers/net/bonding/bond_options.h	2014-03-04 16:00:13.886482614 -0800
+++ b/drivers/net/bonding/bond_options.h	2014-03-04 16:01:26.075087153 -0800
@@ -81,8 +81,8 @@ struct bonding;
 
 struct bond_option {
 	int id;
-	char *name;
-	char *desc;
+	const char *name;
+	const char *desc;
 	u32 flags;
 
 	/* unsuppmodes is used to denote modes in which the option isn't
@@ -92,7 +92,7 @@ struct bond_option {
 	/* supported values which this option can have, can be a subset of
 	 * BOND_OPTVAL_RANGE's value range
 	 */
-	struct bond_opt_value *values;
+	const struct bond_opt_value *values;
 
 	int (*set)(struct bonding *bond, struct bond_opt_value *val);
 };
@@ -100,10 +100,10 @@ struct bond_option {
 int __bond_opt_set(struct bonding *bond, unsigned int option,
 		   struct bond_opt_value *val);
 int bond_opt_tryset_rtnl(struct bonding *bond, unsigned int option, char *buf);
-struct bond_opt_value *bond_opt_parse(const struct bond_option *opt,
+const struct bond_opt_value *bond_opt_parse(const struct bond_option *opt,
 				      struct bond_opt_value *val);
-struct bond_option *bond_opt_get(unsigned int option);
-struct bond_opt_value *bond_opt_get_val(unsigned int option, u64 val);
+const struct bond_option *bond_opt_get(unsigned int option);
+const struct bond_opt_value *bond_opt_get_val(unsigned int option, u64 val);
 
 /* This helper is used to initialize a bond_opt_value structure for parameter
  * passing. There should be either a valid string or value, but not both.
@@ -122,49 +122,6 @@ static inline void __bond_opt_init(struc
 #define bond_opt_initval(optval, value) __bond_opt_init(optval, NULL, value)
 #define bond_opt_initstr(optval, str) __bond_opt_init(optval, str, ULLONG_MAX)
 
-int bond_option_mode_set(struct bonding *bond, struct bond_opt_value *newval);
-int bond_option_pps_set(struct bonding *bond, struct bond_opt_value *newval);
-int bond_option_xmit_hash_policy_set(struct bonding *bond,
-				     struct bond_opt_value *newval);
-int bond_option_arp_validate_set(struct bonding *bond,
-				 struct bond_opt_value *newval);
-int bond_option_arp_all_targets_set(struct bonding *bond,
-				    struct bond_opt_value *newval);
-int bond_option_fail_over_mac_set(struct bonding *bond,
-				  struct bond_opt_value *newval);
-int bond_option_arp_interval_set(struct bonding *bond,
-				 struct bond_opt_value *newval);
-int bond_option_arp_ip_targets_set(struct bonding *bond,
-				   struct bond_opt_value *newval);
 void bond_option_arp_ip_targets_clear(struct bonding *bond);
-int bond_option_downdelay_set(struct bonding *bond,
-			      struct bond_opt_value *newval);
-int bond_option_updelay_set(struct bonding *bond,
-			    struct bond_opt_value *newval);
-int bond_option_lacp_rate_set(struct bonding *bond,
-			      struct bond_opt_value *newval);
-int bond_option_min_links_set(struct bonding *bond,
-			      struct bond_opt_value *newval);
-int bond_option_ad_select_set(struct bonding *bond,
-			      struct bond_opt_value *newval);
-int bond_option_num_peer_notif_set(struct bonding *bond,
-				   struct bond_opt_value *newval);
-int bond_option_miimon_set(struct bonding *bond, struct bond_opt_value *newval);
-int bond_option_primary_set(struct bonding *bond,
-			    struct bond_opt_value *newval);
-int bond_option_primary_reselect_set(struct bonding *bond,
-				     struct bond_opt_value *newval);
-int bond_option_use_carrier_set(struct bonding *bond,
-				struct bond_opt_value *newval);
-int bond_option_active_slave_set(struct bonding *bond,
-				 struct bond_opt_value *newval);
-int bond_option_queue_id_set(struct bonding *bond,
-			     struct bond_opt_value *newval);
-int bond_option_all_slaves_active_set(struct bonding *bond,
-				      struct bond_opt_value *newval);
-int bond_option_resend_igmp_set(struct bonding *bond,
-				struct bond_opt_value *newval);
-int bond_option_lp_interval_set(struct bonding *bond,
-				struct bond_opt_value *newval);
-int bond_option_slaves_set(struct bonding *bond, struct bond_opt_value *newval);
+
 #endif /* _BOND_OPTIONS_H */
--- a/drivers/net/bonding/bond_main.c	2014-03-04 16:01:15.715286487 -0800
+++ b/drivers/net/bonding/bond_main.c	2014-03-04 16:01:26.076087134 -0800
@@ -3934,7 +3934,8 @@ static void bond_uninit(struct net_devic
 static int bond_check_params(struct bond_params *params)
 {
 	int arp_validate_value, fail_over_mac_value, primary_reselect_value, i;
-	struct bond_opt_value newval, *valptr;
+	struct bond_opt_value newval;
+	const struct bond_opt_value *valptr;
 	int arp_all_targets_value;
 
 	/*
--- a/drivers/net/bonding/bond_sysfs.c	2014-03-04 16:00:13.886482614 -0800
+++ b/drivers/net/bonding/bond_sysfs.c	2014-03-04 16:01:26.076087134 -0800
@@ -220,7 +220,7 @@ static ssize_t bonding_show_mode(struct
 				 struct device_attribute *attr, char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	struct bond_opt_value *val;
+	const struct bond_opt_value *val;
 
 	val = bond_opt_get_val(BOND_OPT_MODE, bond->params.mode);
 
@@ -251,7 +251,7 @@ static ssize_t bonding_show_xmit_hash(st
 				      char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	struct bond_opt_value *val;
+	const struct bond_opt_value *val;
 
 	val = bond_opt_get_val(BOND_OPT_XMIT_HASH, bond->params.xmit_policy);
 
@@ -282,7 +282,7 @@ static ssize_t bonding_show_arp_validate
 					 char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	struct bond_opt_value *val;
+	const struct bond_opt_value *val;
 
 	val = bond_opt_get_val(BOND_OPT_ARP_VALIDATE,
 			       bond->params.arp_validate);
@@ -314,7 +314,7 @@ static ssize_t bonding_show_arp_all_targ
 					 char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	struct bond_opt_value *val;
+	const struct bond_opt_value *val;
 
 	val = bond_opt_get_val(BOND_OPT_ARP_ALL_TARGETS,
 			       bond->params.arp_all_targets);
@@ -348,7 +348,7 @@ static ssize_t bonding_show_fail_over_ma
 					  char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	struct bond_opt_value *val;
+	const struct bond_opt_value *val;
 
 	val = bond_opt_get_val(BOND_OPT_FAIL_OVER_MAC,
 			       bond->params.fail_over_mac);
@@ -505,7 +505,7 @@ static ssize_t bonding_show_lacp(struct
 				 char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	struct bond_opt_value *val;
+	const struct bond_opt_value *val;
 
 	val = bond_opt_get_val(BOND_OPT_LACP_RATE, bond->params.lacp_fast);
 
@@ -558,7 +558,7 @@ static ssize_t bonding_show_ad_select(st
 				      char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	struct bond_opt_value *val;
+	const struct bond_opt_value *val;
 
 	val = bond_opt_get_val(BOND_OPT_AD_SELECT, bond->params.ad_select);
 
@@ -686,7 +686,7 @@ static ssize_t bonding_show_primary_rese
 					     char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	struct bond_opt_value *val;
+	const struct bond_opt_value *val;
 
 	val = bond_opt_get_val(BOND_OPT_PRIMARY_RESELECT,
 			       bond->params.primary_reselect);
--- a/drivers/net/bonding/bonding.h	2014-03-04 16:01:09.003415653 -0800
+++ b/drivers/net/bonding/bonding.h	2014-03-04 16:01:26.076087134 -0800
@@ -470,8 +470,6 @@ void bond_setup(struct net_device *bond_
 unsigned int bond_get_num_tx_queues(void);
 int bond_netlink_init(void);
 void bond_netlink_fini(void);
-int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
-int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 const char *bond_slave_link_status(s8 link);
