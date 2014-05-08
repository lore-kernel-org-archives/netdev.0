From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next] bonding: make a generic sysfs option store and fix comments
Date: Thu,  8 May 2014 14:23:54 +0200
Message-ID: <1399551834-31583-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22331 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179AbaEHMYF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2014 08:24:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a generic option store function for sysfs and remove the
specific ones. The attribute name is used to match against the option
which is to be set.
Also adjust the "name" of tlb_dynamic_lb option to match the sysfs
entry and fix the comments and comment style in bond_sysfs.c
The comments which showed obvious behaviour (i.e. behaviour that's seen
in the option's entry) are removed, the ones that explained important
points about the setting function have been moved above the respective
set function in bond_options.c

There's only 1 exception: num_unsol_na/num_grat_arp since it has 2 names

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
Note: I'm working on generic show() method as well, but that isn't ready
yet. Also on a solution to the exception mentioned above.
This patch was tested by setting all options in the bonding sysfs dir.

 drivers/net/bonding/bond_options.c |  29 +-
 drivers/net/bonding/bond_options.h |   1 +
 drivers/net/bonding/bond_sysfs.c   | 568 +++++--------------------------------
 3 files changed, 107 insertions(+), 491 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 9fba7a1e6d51..6dc49da106d6 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -374,7 +374,7 @@ static const struct bond_option bond_opts[] = {
 	},
 	[BOND_OPT_TLB_DYNAMIC_LB] = {
 		.id = BOND_OPT_TLB_DYNAMIC_LB,
-		.name = "dynamic_lb",
+		.name = "tlb_dynamic_lb",
 		.desc = "Enable dynamic flow shuffling",
 		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_TLB)),
 		.values = bond_tlb_dynamic_lb_tbl,
@@ -384,6 +384,21 @@ static const struct bond_option bond_opts[] = {
 	{ }
 };
 
+/* Searches for an option by name */
+const struct bond_option *bond_opt_get_by_name(const char *name)
+{
+	const struct bond_option *opt;
+	int option;
+
+	for (option = 0; option < BOND_OPT_LAST; option++) {
+		opt = bond_opt_get(option);
+		if (opt && !strcmp(opt->name, name))
+			return opt;
+	}
+
+	return NULL;
+}
+
 /* Searches for a value in opt's values[] table */
 const struct bond_opt_value *bond_opt_get_val(unsigned int option, u64 val)
 {
@@ -762,6 +777,10 @@ static int bond_option_active_slave_set(struct bonding *bond,
 	return ret;
 }
 
+/* There are two tricky bits here.  First, if MII monitoring is activated, then
+ * we must disable ARP monitoring.  Second, if the timer isn't running, we must
+ * start it.
+ */
 static int bond_option_miimon_set(struct bonding *bond,
 				  const struct bond_opt_value *newval)
 {
@@ -800,6 +819,10 @@ static int bond_option_miimon_set(struct bonding *bond,
 	return 0;
 }
 
+/* Set up and down delays. These must be multiples of the
+ * MII monitoring value, and are stored internally as the multiplier.
+ * Thus, we must translate to MS for the real world.
+ */
 static int bond_option_updelay_set(struct bonding *bond,
 				   const struct bond_opt_value *newval)
 {
@@ -858,6 +881,10 @@ static int bond_option_use_carrier_set(struct bonding *bond,
 	return 0;
 }
 
+/* There are two tricky bits here.  First, if ARP monitoring is activated, then
+ * we must disable MII monitoring.  Second, if the ARP timer isn't running,
+ * we must start it.
+ */
 static int bond_option_arp_interval_set(struct bonding *bond,
 					const struct bond_opt_value *newval)
 {
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index c1860f06145a..17ded5b29176 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -105,6 +105,7 @@ int bond_opt_tryset_rtnl(struct bonding *bond, unsigned int option, char *buf);
 const struct bond_opt_value *bond_opt_parse(const struct bond_option *opt,
 					    struct bond_opt_value *val);
 const struct bond_option *bond_opt_get(unsigned int option);
+const struct bond_option *bond_opt_get_by_name(const char *name);
 const struct bond_opt_value *bond_opt_get_val(unsigned int option, u64 val);
 
 /* This helper is used to initialize a bond_opt_value structure for parameter
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 431892f1a4ce..5a59b85cdfc2 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -45,8 +45,7 @@
 #define to_dev(obj)	container_of(obj, struct device, kobj)
 #define to_bond(cd)	((struct bonding *)(netdev_priv(to_net_dev(cd))))
 
-/*
- * "show" function for the bond_masters attribute.
+/* "show" function for the bond_masters attribute.
  * The class parameter is ignored.
  */
 static ssize_t bonding_show_bonds(struct class *cls,
@@ -88,14 +87,12 @@ static struct net_device *bond_get_by_name(struct bond_net *bn, const char *ifna
 	return NULL;
 }
 
-/*
- * "store" function for the bond_masters attribute.  This is what
+/* "store" function for the bond_masters attribute.  This is what
  * creates and deletes entire bonds.
  *
  * The class parameter is ignored.
  *
  */
-
 static ssize_t bonding_store_bonds(struct class *cls,
 				   struct class_attribute *attr,
 				   const char *buffer, size_t count)
@@ -158,9 +155,26 @@ static const struct class_attribute class_attr_bonding_masters = {
 	.store = bonding_store_bonds,
 };
 
-/*
- * Show the slaves in the current bond.
- */
+/* Generic "store" method for bonding sysfs option setting */
+static ssize_t bonding_sysfs_store_option(struct device *d,
+					  struct device_attribute *attr,
+					  const char *buffer, size_t count)
+{
+	struct bonding *bond = to_bond(d);
+	const struct bond_option *opt;
+	int ret;
+
+	opt = bond_opt_get_by_name(attr->attr.name);
+	if (WARN_ON(!opt))
+		return -ENOENT;
+	ret = bond_opt_tryset_rtnl(bond, opt->id, (char *)buffer);
+	if (!ret)
+		ret = count;
+
+	return ret;
+}
+
+/* Show the slaves in the current bond. */
 static ssize_t bonding_show_slaves(struct device *d,
 				   struct device_attribute *attr, char *buf)
 {
@@ -190,32 +204,10 @@ static ssize_t bonding_show_slaves(struct device *d,
 
 	return res;
 }
-
-/*
- * Set the slaves in the current bond.
- * This is supposed to be only thin wrapper for bond_enslave and bond_release.
- * All hard work should be done there.
- */
-static ssize_t bonding_store_slaves(struct device *d,
-				    struct device_attribute *attr,
-				    const char *buffer, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_SLAVES, (char *)buffer);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(slaves, S_IRUGO | S_IWUSR, bonding_show_slaves,
-		   bonding_store_slaves);
+		   bonding_sysfs_store_option);
 
-/*
- * Show and set the bonding mode.  The bond interface must be down to
- * change the mode.
- */
+/* Show the bonding mode. */
 static ssize_t bonding_show_mode(struct device *d,
 				 struct device_attribute *attr, char *buf)
 {
@@ -226,26 +218,10 @@ static ssize_t bonding_show_mode(struct device *d,
 
 	return sprintf(buf, "%s %d\n", val->string, bond->params.mode);
 }
-
-static ssize_t bonding_store_mode(struct device *d,
-				  struct device_attribute *attr,
-				  const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_MODE, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(mode, S_IRUGO | S_IWUSR,
-		   bonding_show_mode, bonding_store_mode);
+		   bonding_show_mode, bonding_sysfs_store_option);
 
-/*
- * Show and set the bonding transmit hash method.
- */
+/* Show the bonding transmit hash method. */
 static ssize_t bonding_show_xmit_hash(struct device *d,
 				      struct device_attribute *attr,
 				      char *buf)
@@ -257,26 +233,10 @@ static ssize_t bonding_show_xmit_hash(struct device *d,
 
 	return sprintf(buf, "%s %d\n", val->string, bond->params.xmit_policy);
 }
-
-static ssize_t bonding_store_xmit_hash(struct device *d,
-				       struct device_attribute *attr,
-				       const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_XMIT_HASH, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(xmit_hash_policy, S_IRUGO | S_IWUSR,
-		   bonding_show_xmit_hash, bonding_store_xmit_hash);
+		   bonding_show_xmit_hash, bonding_sysfs_store_option);
 
-/*
- * Show and set arp_validate.
- */
+/* Show arp_validate. */
 static ssize_t bonding_show_arp_validate(struct device *d,
 					 struct device_attribute *attr,
 					 char *buf)
@@ -289,26 +249,10 @@ static ssize_t bonding_show_arp_validate(struct device *d,
 
 	return sprintf(buf, "%s %d\n", val->string, bond->params.arp_validate);
 }
-
-static ssize_t bonding_store_arp_validate(struct device *d,
-					  struct device_attribute *attr,
-					  const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_ARP_VALIDATE, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
-
 static DEVICE_ATTR(arp_validate, S_IRUGO | S_IWUSR, bonding_show_arp_validate,
-		   bonding_store_arp_validate);
-/*
- * Show and set arp_all_targets.
- */
+		   bonding_sysfs_store_option);
+
+/* Show arp_all_targets. */
 static ssize_t bonding_show_arp_all_targets(struct device *d,
 					 struct device_attribute *attr,
 					 char *buf)
@@ -321,28 +265,10 @@ static ssize_t bonding_show_arp_all_targets(struct device *d,
 	return sprintf(buf, "%s %d\n",
 		       val->string, bond->params.arp_all_targets);
 }
-
-static ssize_t bonding_store_arp_all_targets(struct device *d,
-					  struct device_attribute *attr,
-					  const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_ARP_ALL_TARGETS, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
-
 static DEVICE_ATTR(arp_all_targets, S_IRUGO | S_IWUSR,
-		   bonding_show_arp_all_targets, bonding_store_arp_all_targets);
+		   bonding_show_arp_all_targets, bonding_sysfs_store_option);
 
-/*
- * Show and store fail_over_mac.  User only allowed to change the
- * value when there are no slaves.
- */
+/* Show fail_over_mac. */
 static ssize_t bonding_show_fail_over_mac(struct device *d,
 					  struct device_attribute *attr,
 					  char *buf)
@@ -355,30 +281,10 @@ static ssize_t bonding_show_fail_over_mac(struct device *d,
 
 	return sprintf(buf, "%s %d\n", val->string, bond->params.fail_over_mac);
 }
-
-static ssize_t bonding_store_fail_over_mac(struct device *d,
-					   struct device_attribute *attr,
-					   const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_FAIL_OVER_MAC, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
-
 static DEVICE_ATTR(fail_over_mac, S_IRUGO | S_IWUSR,
-		   bonding_show_fail_over_mac, bonding_store_fail_over_mac);
+		   bonding_show_fail_over_mac, bonding_sysfs_store_option);
 
-/*
- * Show and set the arp timer interval.  There are two tricky bits
- * here.  First, if ARP monitoring is activated, then we must disable
- * MII monitoring.  Second, if the ARP timer isn't running, we must
- * start it.
- */
+/* Show the arp timer interval. */
 static ssize_t bonding_show_arp_interval(struct device *d,
 					 struct device_attribute *attr,
 					 char *buf)
@@ -387,26 +293,10 @@ static ssize_t bonding_show_arp_interval(struct device *d,
 
 	return sprintf(buf, "%d\n", bond->params.arp_interval);
 }
-
-static ssize_t bonding_store_arp_interval(struct device *d,
-					  struct device_attribute *attr,
-					  const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_ARP_INTERVAL, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(arp_interval, S_IRUGO | S_IWUSR,
-		   bonding_show_arp_interval, bonding_store_arp_interval);
+		   bonding_show_arp_interval, bonding_sysfs_store_option);
 
-/*
- * Show and set the arp targets.
- */
+/* Show the arp targets. */
 static ssize_t bonding_show_arp_targets(struct device *d,
 					struct device_attribute *attr,
 					char *buf)
@@ -424,27 +314,10 @@ static ssize_t bonding_show_arp_targets(struct device *d,
 
 	return res;
 }
+static DEVICE_ATTR(arp_ip_target, S_IRUGO | S_IWUSR,
+		   bonding_show_arp_targets, bonding_sysfs_store_option);
 
-static ssize_t bonding_store_arp_targets(struct device *d,
-					 struct device_attribute *attr,
-					 const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_ARP_TARGETS, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
-static DEVICE_ATTR(arp_ip_target, S_IRUGO | S_IWUSR , bonding_show_arp_targets, bonding_store_arp_targets);
-
-/*
- * Show and set the up and down delays.  These must be multiples of the
- * MII monitoring value, and are stored internally as the multiplier.
- * Thus, we must translate to MS for the real world.
- */
+/* Show the up and down delays. */
 static ssize_t bonding_show_downdelay(struct device *d,
 				      struct device_attribute *attr,
 				      char *buf)
@@ -453,22 +326,8 @@ static ssize_t bonding_show_downdelay(struct device *d,
 
 	return sprintf(buf, "%d\n", bond->params.downdelay * bond->params.miimon);
 }
-
-static ssize_t bonding_store_downdelay(struct device *d,
-				       struct device_attribute *attr,
-				       const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_DOWNDELAY, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(downdelay, S_IRUGO | S_IWUSR,
-		   bonding_show_downdelay, bonding_store_downdelay);
+		   bonding_show_downdelay, bonding_sysfs_store_option);
 
 static ssize_t bonding_show_updelay(struct device *d,
 				    struct device_attribute *attr,
@@ -479,27 +338,10 @@ static ssize_t bonding_show_updelay(struct device *d,
 	return sprintf(buf, "%d\n", bond->params.updelay * bond->params.miimon);
 
 }
-
-static ssize_t bonding_store_updelay(struct device *d,
-				     struct device_attribute *attr,
-				     const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_UPDELAY, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(updelay, S_IRUGO | S_IWUSR,
-		   bonding_show_updelay, bonding_store_updelay);
+		   bonding_show_updelay, bonding_sysfs_store_option);
 
-/*
- * Show and set the LACP interval.  Interface must be down, and the mode
- * must be set to 802.3ad mode.
- */
+/* Show the LACP interval. */
 static ssize_t bonding_show_lacp(struct device *d,
 				 struct device_attribute *attr,
 				 char *buf)
@@ -511,22 +353,8 @@ static ssize_t bonding_show_lacp(struct device *d,
 
 	return sprintf(buf, "%s %d\n", val->string, bond->params.lacp_fast);
 }
-
-static ssize_t bonding_store_lacp(struct device *d,
-				  struct device_attribute *attr,
-				  const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_LACP_RATE, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR,
-		   bonding_show_lacp, bonding_store_lacp);
+		   bonding_show_lacp, bonding_sysfs_store_option);
 
 static ssize_t bonding_show_min_links(struct device *d,
 				      struct device_attribute *attr,
@@ -536,22 +364,8 @@ static ssize_t bonding_show_min_links(struct device *d,
 
 	return sprintf(buf, "%d\n", bond->params.min_links);
 }
-
-static ssize_t bonding_store_min_links(struct device *d,
-				       struct device_attribute *attr,
-				       const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_MINLINKS, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(min_links, S_IRUGO | S_IWUSR,
-		   bonding_show_min_links, bonding_store_min_links);
+		   bonding_show_min_links, bonding_sysfs_store_option);
 
 static ssize_t bonding_show_ad_select(struct device *d,
 				      struct device_attribute *attr,
@@ -564,27 +378,10 @@ static ssize_t bonding_show_ad_select(struct device *d,
 
 	return sprintf(buf, "%s %d\n", val->string, bond->params.ad_select);
 }
-
-
-static ssize_t bonding_store_ad_select(struct device *d,
-				       struct device_attribute *attr,
-				       const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_AD_SELECT, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(ad_select, S_IRUGO | S_IWUSR,
-		   bonding_show_ad_select, bonding_store_ad_select);
+		   bonding_show_ad_select, bonding_sysfs_store_option);
 
-/*
- * Show and set the number of peer notifications to send after a failover event.
- */
+/* Show and set the number of peer notifications to send after a failover event. */
 static ssize_t bonding_show_num_peer_notif(struct device *d,
 					   struct device_attribute *attr,
 					   char *buf)
@@ -611,12 +408,7 @@ static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR,
 static DEVICE_ATTR(num_unsol_na, S_IRUGO | S_IWUSR,
 		   bonding_show_num_peer_notif, bonding_store_num_peer_notif);
 
-/*
- * Show and set the MII monitor interval.  There are two tricky bits
- * here.  First, if MII monitoring is activated, then we must disable
- * ARP monitoring.  Second, if the timer isn't running, we must
- * start it.
- */
+/* Show the MII monitor interval. */
 static ssize_t bonding_show_miimon(struct device *d,
 				   struct device_attribute *attr,
 				   char *buf)
@@ -625,30 +417,10 @@ static ssize_t bonding_show_miimon(struct device *d,
 
 	return sprintf(buf, "%d\n", bond->params.miimon);
 }
-
-static ssize_t bonding_store_miimon(struct device *d,
-				    struct device_attribute *attr,
-				    const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_MIIMON, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(miimon, S_IRUGO | S_IWUSR,
-		   bonding_show_miimon, bonding_store_miimon);
+		   bonding_show_miimon, bonding_sysfs_store_option);
 
-/*
- * Show and set the primary slave.  The store function is much
- * simpler than bonding_store_slaves function because it only needs to
- * handle one interface name.
- * The bond must be a mode that supports a primary for this be
- * set.
- */
+/* Show the primary slave. */
 static ssize_t bonding_show_primary(struct device *d,
 				    struct device_attribute *attr,
 				    char *buf)
@@ -661,26 +433,10 @@ static ssize_t bonding_show_primary(struct device *d,
 
 	return count;
 }
-
-static ssize_t bonding_store_primary(struct device *d,
-				     struct device_attribute *attr,
-				     const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_PRIMARY, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR,
-		   bonding_show_primary, bonding_store_primary);
+		   bonding_show_primary, bonding_sysfs_store_option);
 
-/*
- * Show and set the primary_reselect flag.
- */
+/* Show the primary_reselect flag. */
 static ssize_t bonding_show_primary_reselect(struct device *d,
 					     struct device_attribute *attr,
 					     char *buf)
@@ -694,28 +450,10 @@ static ssize_t bonding_show_primary_reselect(struct device *d,
 	return sprintf(buf, "%s %d\n",
 		       val->string, bond->params.primary_reselect);
 }
-
-static ssize_t bonding_store_primary_reselect(struct device *d,
-					      struct device_attribute *attr,
-					      const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_PRIMARY_RESELECT,
-				   (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(primary_reselect, S_IRUGO | S_IWUSR,
-		   bonding_show_primary_reselect,
-		   bonding_store_primary_reselect);
+		   bonding_show_primary_reselect, bonding_sysfs_store_option);
 
-/*
- * Show and set the use_carrier flag.
- */
+/* Show the use_carrier flag. */
 static ssize_t bonding_show_carrier(struct device *d,
 				    struct device_attribute *attr,
 				    char *buf)
@@ -724,27 +462,11 @@ static ssize_t bonding_show_carrier(struct device *d,
 
 	return sprintf(buf, "%d\n", bond->params.use_carrier);
 }
-
-static ssize_t bonding_store_carrier(struct device *d,
-				     struct device_attribute *attr,
-				     const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_USE_CARRIER, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(use_carrier, S_IRUGO | S_IWUSR,
-		   bonding_show_carrier, bonding_store_carrier);
+		   bonding_show_carrier, bonding_sysfs_store_option);
 
 
-/*
- * Show and set currently active_slave.
- */
+/* Show currently active_slave. */
 static ssize_t bonding_show_active_slave(struct device *d,
 					 struct device_attribute *attr,
 					 char *buf)
@@ -761,27 +483,10 @@ static ssize_t bonding_show_active_slave(struct device *d,
 
 	return count;
 }
-
-static ssize_t bonding_store_active_slave(struct device *d,
-					  struct device_attribute *attr,
-					  const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_ACTIVE_SLAVE, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(active_slave, S_IRUGO | S_IWUSR,
-		   bonding_show_active_slave, bonding_store_active_slave);
+		   bonding_show_active_slave, bonding_sysfs_store_option);
 
-
-/*
- * Show link status of the bond interface.
- */
+/* Show link status of the bond interface. */
 static ssize_t bonding_show_mii_status(struct device *d,
 				       struct device_attribute *attr,
 				       char *buf)
@@ -792,9 +497,7 @@ static ssize_t bonding_show_mii_status(struct device *d,
 }
 static DEVICE_ATTR(mii_status, S_IRUGO, bonding_show_mii_status, NULL);
 
-/*
- * Show current 802.3ad aggregator ID.
- */
+/* Show current 802.3ad aggregator ID. */
 static ssize_t bonding_show_ad_aggregator(struct device *d,
 					  struct device_attribute *attr,
 					  char *buf)
@@ -814,9 +517,7 @@ static ssize_t bonding_show_ad_aggregator(struct device *d,
 static DEVICE_ATTR(ad_aggregator, S_IRUGO, bonding_show_ad_aggregator, NULL);
 
 
-/*
- * Show number of active 802.3ad ports.
- */
+/* Show number of active 802.3ad ports. */
 static ssize_t bonding_show_ad_num_ports(struct device *d,
 					 struct device_attribute *attr,
 					 char *buf)
@@ -836,9 +537,7 @@ static ssize_t bonding_show_ad_num_ports(struct device *d,
 static DEVICE_ATTR(ad_num_ports, S_IRUGO, bonding_show_ad_num_ports, NULL);
 
 
-/*
- * Show current 802.3ad actor key.
- */
+/* Show current 802.3ad actor key. */
 static ssize_t bonding_show_ad_actor_key(struct device *d,
 					 struct device_attribute *attr,
 					 char *buf)
@@ -858,9 +557,7 @@ static ssize_t bonding_show_ad_actor_key(struct device *d,
 static DEVICE_ATTR(ad_actor_key, S_IRUGO, bonding_show_ad_actor_key, NULL);
 
 
-/*
- * Show current 802.3ad partner key.
- */
+/* Show current 802.3ad partner key. */
 static ssize_t bonding_show_ad_partner_key(struct device *d,
 					   struct device_attribute *attr,
 					   char *buf)
@@ -880,9 +577,7 @@ static ssize_t bonding_show_ad_partner_key(struct device *d,
 static DEVICE_ATTR(ad_partner_key, S_IRUGO, bonding_show_ad_partner_key, NULL);
 
 
-/*
- * Show current 802.3ad partner mac.
- */
+/* Show current 802.3ad partner mac. */
 static ssize_t bonding_show_ad_partner_mac(struct device *d,
 					   struct device_attribute *attr,
 					   char *buf)
@@ -900,9 +595,7 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
 }
 static DEVICE_ATTR(ad_partner_mac, S_IRUGO, bonding_show_ad_partner_mac, NULL);
 
-/*
- * Show the queue_ids of the slaves in the current bond.
- */
+/* Show the queue_ids of the slaves in the current bond. */
 static ssize_t bonding_show_queue_id(struct device *d,
 				     struct device_attribute *attr,
 				     char *buf)
@@ -933,31 +626,11 @@ static ssize_t bonding_show_queue_id(struct device *d,
 
 	return res;
 }
-
-/*
- * Set the queue_ids of the  slaves in the current bond.  The bond
- * interface must be enslaved for this to work.
- */
-static ssize_t bonding_store_queue_id(struct device *d,
-				      struct device_attribute *attr,
-				      const char *buffer, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_QUEUE_ID, (char *)buffer);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(queue_id, S_IRUGO | S_IWUSR, bonding_show_queue_id,
-		   bonding_store_queue_id);
+		   bonding_sysfs_store_option);
 
 
-/*
- * Show and set the all_slaves_active flag.
- */
+/* Show the all_slaves_active flag. */
 static ssize_t bonding_show_slaves_active(struct device *d,
 					  struct device_attribute *attr,
 					  char *buf)
@@ -966,27 +639,10 @@ static ssize_t bonding_show_slaves_active(struct device *d,
 
 	return sprintf(buf, "%d\n", bond->params.all_slaves_active);
 }
-
-static ssize_t bonding_store_slaves_active(struct device *d,
-					   struct device_attribute *attr,
-					   const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_ALL_SLAVES_ACTIVE,
-				   (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
 static DEVICE_ATTR(all_slaves_active, S_IRUGO | S_IWUSR,
-		   bonding_show_slaves_active, bonding_store_slaves_active);
+		   bonding_show_slaves_active, bonding_sysfs_store_option);
 
-/*
- * Show and set the number of IGMP membership reports to send on link failure
- */
+/* Show the number of IGMP membership reports to send on link failure */
 static ssize_t bonding_show_resend_igmp(struct device *d,
 					struct device_attribute *attr,
 					char *buf)
@@ -995,23 +651,8 @@ static ssize_t bonding_show_resend_igmp(struct device *d,
 
 	return sprintf(buf, "%d\n", bond->params.resend_igmp);
 }
-
-static ssize_t bonding_store_resend_igmp(struct device *d,
-					 struct device_attribute *attr,
-					 const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_RESEND_IGMP, (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
-
 static DEVICE_ATTR(resend_igmp, S_IRUGO | S_IWUSR,
-		   bonding_show_resend_igmp, bonding_store_resend_igmp);
+		   bonding_show_resend_igmp, bonding_sysfs_store_option);
 
 
 static ssize_t bonding_show_lp_interval(struct device *d,
@@ -1019,25 +660,11 @@ static ssize_t bonding_show_lp_interval(struct device *d,
 					char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	return sprintf(buf, "%d\n", bond->params.lp_interval);
-}
-
-static ssize_t bonding_store_lp_interval(struct device *d,
-					 struct device_attribute *attr,
-					 const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_LP_INTERVAL, (char *)buf);
-	if (!ret)
-		ret = count;
 
-	return ret;
+	return sprintf(buf, "%d\n", bond->params.lp_interval);
 }
-
 static DEVICE_ATTR(lp_interval, S_IRUGO | S_IWUSR,
-		   bonding_show_lp_interval, bonding_store_lp_interval);
+		   bonding_show_lp_interval, bonding_sysfs_store_option);
 
 static ssize_t bonding_show_tlb_dynamic_lb(struct device *d,
 					   struct device_attribute *attr,
@@ -1046,26 +673,8 @@ static ssize_t bonding_show_tlb_dynamic_lb(struct device *d,
 	struct bonding *bond = to_bond(d);
 	return sprintf(buf, "%d\n", bond->params.tlb_dynamic_lb);
 }
-
-static ssize_t bonding_store_tlb_dynamic_lb(struct device *d,
-					    struct device_attribute *attr,
-					    const char *buf,
-					    size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
-
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_TLB_DYNAMIC_LB,
-				   (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
-}
-
 static DEVICE_ATTR(tlb_dynamic_lb, S_IRUGO | S_IWUSR,
-		   bonding_show_tlb_dynamic_lb,
-		   bonding_store_tlb_dynamic_lb);
+		   bonding_show_tlb_dynamic_lb, bonding_sysfs_store_option);
 
 static ssize_t bonding_show_packets_per_slave(struct device *d,
 					      struct device_attribute *attr,
@@ -1073,27 +682,11 @@ static ssize_t bonding_show_packets_per_slave(struct device *d,
 {
 	struct bonding *bond = to_bond(d);
 	unsigned int packets_per_slave = bond->params.packets_per_slave;
-	return sprintf(buf, "%u\n", packets_per_slave);
-}
-
-static ssize_t bonding_store_packets_per_slave(struct device *d,
-					       struct device_attribute *attr,
-					       const char *buf, size_t count)
-{
-	struct bonding *bond = to_bond(d);
-	int ret;
 
-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_PACKETS_PER_SLAVE,
-				   (char *)buf);
-	if (!ret)
-		ret = count;
-
-	return ret;
+	return sprintf(buf, "%u\n", packets_per_slave);
 }
-
 static DEVICE_ATTR(packets_per_slave, S_IRUGO | S_IWUSR,
-		   bonding_show_packets_per_slave,
-		   bonding_store_packets_per_slave);
+		   bonding_show_packets_per_slave, bonding_sysfs_store_option);
 
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
@@ -1136,8 +729,7 @@ static struct attribute_group bonding_group = {
 	.attrs = per_bond_attrs,
 };
 
-/*
- * Initialize sysfs.  This sets up the bonding_masters file in
+/* Initialize sysfs.  This sets up the bonding_masters file in
  * /sys/class/net.
  */
 int bond_create_sysfs(struct bond_net *bn)
@@ -1149,8 +741,7 @@ int bond_create_sysfs(struct bond_net *bn)
 
 	ret = netdev_class_create_file_ns(&bn->class_attr_bonding_masters,
 					  bn->net);
-	/*
-	 * Permit multiple loads of the module by ignoring failures to
+	/* Permit multiple loads of the module by ignoring failures to
 	 * create the bonding_masters sysfs file.  Bonding devices
 	 * created by second or subsequent loads of the module will
 	 * not be listed in, or controllable by, bonding_masters, but
@@ -1173,16 +764,13 @@ int bond_create_sysfs(struct bond_net *bn)
 
 }
 
-/*
- * Remove /sys/class/net/bonding_masters.
- */
+/* Remove /sys/class/net/bonding_masters. */
 void bond_destroy_sysfs(struct bond_net *bn)
 {
 	netdev_class_remove_file_ns(&bn->class_attr_bonding_masters, bn->net);
 }
 
-/*
- * Initialize sysfs for each bond.  This sets up and registers
+/* Initialize sysfs for each bond.  This sets up and registers
  * the 'bondctl' directory for each individual bond under /sys/class/net.
  */
 void bond_prepare_sysfs_group(struct bonding *bond)
-- 
1.8.5.3
