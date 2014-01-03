From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next v2 5/5] bonding: add bounds checking for tbl params
Date: Fri, 03 Jan 2014 14:28:18 -0800
Message-ID: <20140103222818.1659.5188.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, jiri@resnulli.us, dingtianhong@huawei.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:40355 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362AbaACW2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 17:28:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add bounds checking for params defined with parm tbl.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_options.c |   79 +++++++++++++++++++++++-------------
 1 file changed, 51 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index c9691bf..945a666 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -19,19 +19,11 @@
 #include <linux/reciprocal_div.h>
 #include "bonding.h"
 
-static bool bond_mode_is_valid(int mode)
-{
-	int i;
-
-	for (i = 0; bond_mode_tbl[i].modename; i++);
-
-	return mode >= 0 && mode < i;
-}
-
 int bond_option_mode_set(struct bonding *bond, int mode)
 {
-	if (!bond_mode_is_valid(mode)) {
-		pr_err("invalid mode value %d.\n", mode);
+	if (bond_parm_tbl_lookup(mode, bond_mode_tbl) < 0) {
+		pr_err("%s: Ignoring invalid mode value %d.\n",
+		       bond->dev->name, mode);
 		return -EINVAL;
 	}
 
@@ -438,11 +430,18 @@ int bond_option_arp_ip_targets_set(struct bonding *bond, __be32 *targets,
 
 int bond_option_arp_validate_set(struct bonding *bond, int arp_validate)
 {
+	if (bond_parm_tbl_lookup(arp_validate, arp_validate_tbl) < 0) {
+		pr_err("%s: Ignoring invalid arp_validate value %d.\n",
+		       bond->dev->name, arp_validate);
+		return -EINVAL;
+	}
+
 	if (bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
 		pr_err("%s: arp_validate only supported in active-backup mode.\n",
 		       bond->dev->name);
 		return -EINVAL;
 	}
+
 	pr_info("%s: setting arp_validate to %s (%d).\n",
 		bond->dev->name, arp_validate_tbl[arp_validate].modename,
 		arp_validate);
@@ -460,6 +459,12 @@ int bond_option_arp_validate_set(struct bonding *bond, int arp_validate)
 
 int bond_option_arp_all_targets_set(struct bonding *bond, int arp_all_targets)
 {
+	if (bond_parm_tbl_lookup(arp_all_targets, arp_all_targets_tbl) < 0) {
+		pr_err("%s: Ignoring invalid arp_all_targets value %d.\n",
+		       bond->dev->name, arp_all_targets);
+		return -EINVAL;
+	}
+
 	pr_info("%s: setting arp_all_targets to %s (%d).\n",
 		bond->dev->name, arp_all_targets_tbl[arp_all_targets].modename,
 		arp_all_targets);
@@ -523,6 +528,12 @@ out:
 
 int bond_option_primary_reselect_set(struct bonding *bond, int primary_reselect)
 {
+	if (bond_parm_tbl_lookup(primary_reselect, pri_reselect_tbl) < 0) {
+		pr_err("%s: Ignoring invalid primary_reselect value %d.\n",
+		       bond->dev->name, primary_reselect);
+		return -EINVAL;
+	}
+
 	bond->params.primary_reselect = primary_reselect;
 	pr_info("%s: setting primary_reselect to %s (%d).\n",
 		bond->dev->name, pri_reselect_tbl[primary_reselect].modename,
@@ -539,6 +550,12 @@ int bond_option_primary_reselect_set(struct bonding *bond, int primary_reselect)
 
 int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac)
 {
+	if (bond_parm_tbl_lookup(fail_over_mac, fail_over_mac_tbl) < 0) {
+		pr_err("%s: Ignoring invalid fail_over_mac value %d.\n",
+		       bond->dev->name, fail_over_mac);
+		return -EINVAL;
+	}
+
 	if (bond_has_slaves(bond)) {
 		pr_err("%s: Can't alter fail_over_mac with slaves in bond.\n",
 		       bond->dev->name);
@@ -555,6 +572,12 @@ int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac)
 
 int bond_option_xmit_hash_policy_set(struct bonding *bond, int xmit_hash_policy)
 {
+	if (bond_parm_tbl_lookup(xmit_hash_policy, xmit_hashtype_tbl) < 0) {
+		pr_err("%s: Ignoring invalid xmit_hash_policy value %d.\n",
+		       bond->dev->name, xmit_hash_policy);
+		return -EINVAL;
+	}
+
 	bond->params.xmit_policy = xmit_hash_policy;
 	pr_info("%s: setting xmit hash policy to %s (%d).\n",
 		bond->dev->name,
@@ -659,6 +682,12 @@ int bond_option_packets_per_slave_set(struct bonding *bond,
 
 int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate)
 {
+	if (bond_parm_tbl_lookup(lacp_rate, bond_lacp_tbl) < 0) {
+		pr_err("%s: Ignoring invalid LACP rate value %d.\n",
+		       bond->dev->name, lacp_rate);
+		return -EINVAL;
+	}
+
 	if (bond->dev->flags & IFF_UP) {
 		pr_err("%s: Unable to update LACP rate because interface is up.\n",
 		       bond->dev->name);
@@ -671,35 +700,29 @@ int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate)
 		return -EPERM;
 	}
 
-	if ((lacp_rate == 1) || (lacp_rate == 0)) {
-		bond->params.lacp_fast = lacp_rate;
-		bond_3ad_update_lacp_rate(bond);
-		pr_info("%s: Setting LACP rate to %s (%d).\n",
-			bond->dev->name, bond_lacp_tbl[lacp_rate].modename,
-			lacp_rate);
-	} else {
-		pr_err("%s: Ignoring invalid LACP rate value %d.\n",
-		       bond->dev->name, lacp_rate);
-		return -EINVAL;
-	}
+	bond->params.lacp_fast = lacp_rate;
+	bond_3ad_update_lacp_rate(bond);
+	pr_info("%s: Setting LACP rate to %s (%d).\n",
+		bond->dev->name, bond_lacp_tbl[lacp_rate].modename,
+		lacp_rate);
 
 	return 0;
 }
 
 int bond_option_ad_select_set(struct bonding *bond, int ad_select)
 {
-	if (bond->dev->flags & IFF_UP) {
-		pr_err("%s: Unable to update ad_select because interface is up.\n",
-		       bond->dev->name);
-		return -EPERM;
-	}
-
 	if (bond_parm_tbl_lookup(ad_select, ad_select_tbl) < 0) {
 		pr_err("%s: Ignoring invalid ad_select value %d.\n",
 		       bond->dev->name, ad_select);
 		return -EINVAL;
 	}
 
+	if (bond->dev->flags & IFF_UP) {
+		pr_err("%s: Unable to update ad_select because interface is up.\n",
+		       bond->dev->name);
+		return -EPERM;
+	}
+
 	bond->params.ad_select = ad_select;
 	pr_info("%s: Setting ad_select to %s (%d).\n",
 		bond->dev->name, ad_select_tbl[ad_select].modename,
