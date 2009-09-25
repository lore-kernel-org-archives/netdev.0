From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6 v2] bonding: introduce primary_reselect option
Date: Thu, 24 Sep 2009 17:34:08 -0700
Message-ID: <21492.1253838848@death.nxdomain.ibm.com>
References: <20090918195358.GB32154@psychotron.redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bonding-devel@lists.sourceforge.net, nicolas.2p.debian@free.fr
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:46159 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752836AbZIYAeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2009 20:34:10 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8P0XIiZ027514
	for <netdev@vger.kernel.org>; Thu, 24 Sep 2009 20:33:18 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8P0YE9r241000
	for <netdev@vger.kernel.org>; Thu, 24 Sep 2009 20:34:14 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8P0YCn4000711
	for <netdev@vger.kernel.org>; Thu, 24 Sep 2009 20:34:13 -0400
In-reply-to: <20090918195358.GB32154@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Jiri Pirko <jpirko@redhat.com>

In some cases there is not desirable to switch back to primary interface when
it's link recovers and rather stay with currently active one. We need to avoid
packetloss as much as we can in some cases. This is solved by introducing
primary_reselect option. Note that enslaved primary slave is set as current
active no matter what.

Patch modified by Jay Vosburgh as follows: fixed bug in action
after change of option setting via sysfs, revised the documentation
update, and bumped the bonding version number.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---

	Note that this patch depends on the "make ab_arp select active
slaves as other modes" patch recently approved, but not yet appearing in
net-next-2.6 as I write this.  http://patchwork.ozlabs.org/patch/32684/

 Documentation/networking/bonding.txt |   42 +++++++++++++++++++++-
 drivers/net/bonding/bond_main.c      |   66 +++++++++++++++++++++++++++++++---
 drivers/net/bonding/bond_main.c.rej  |   18 +++++++++
 drivers/net/bonding/bond_sysfs.c     |   53 +++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h        |   11 +++++-
 5 files changed, 182 insertions(+), 8 deletions(-)
 create mode 100644 drivers/net/bonding/bond_main.c.rej

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index d5181ce..61f516b 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -1,7 +1,7 @@
 
 		Linux Ethernet Bonding Driver HOWTO
 
-		Latest update: 12 November 2007
+		Latest update: 23 September 2009
 
 Initial release : Thomas Davis <tadavis at lbl.gov>
 Corrections, HA extensions : 2000/10/03-15 :
@@ -614,6 +614,46 @@ primary
 
 	The primary option is only valid for active-backup mode.
 
+primary_reselect
+
+	Specifies the reselection policy for the primary slave.  This
+	affects how the primary slave is chosen to become the active slave
+	when failure of the active slave or recovery of the primary slave
+	occurs.  This option is designed to prevent flip-flopping between
+	the primary slave and other slaves.  Possible values are:
+
+	always or 0 (default)
+
+		The primary slave becomes the active slave whenever it
+		comes back up.
+
+	better or 1
+
+		The primary slave becomes the active slave when it comes
+		back up, if the speed and duplex of the primary slave is
+		better than the speed and duplex of the current active
+		slave.
+
+	failure or 2
+
+		The primary slave becomes the active slave only if the
+		current active slave fails and the primary slave is up.
+
+	The primary_reselect setting is ignored in two cases:
+
+		If no slaves are active, the first slave to recover is
+		made the active slave.
+
+		When initially enslaved, the primary slave is always made
+		the active slave.
+
+	Changing the primary_reselect policy via sysfs will cause an
+	immediate selection of the best active slave according to the new
+	policy.  This may or may not result in a change of the active
+	slave, depending upon the circumstances.
+
+	This option was added for bonding version 3.6.0.
+
 updelay
 
 	Specifies the time, in milliseconds, to wait before enabling a
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 699bfdd..ba78baa 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -94,6 +94,7 @@ static int downdelay;
 static int use_carrier	= 1;
 static char *mode;
 static char *primary;
+static char *primary_reselect;
 static char *lacp_rate;
 static char *ad_select;
 static char *xmit_hash_policy;
@@ -126,6 +127,14 @@ MODULE_PARM_DESC(mode, "Mode of operation : 0 for balance-rr, "
 		       "6 for balance-alb");
 module_param(primary, charp, 0);
 MODULE_PARM_DESC(primary, "Primary network device to use");
+module_param(primary_reselect, charp, 0);
+MODULE_PARM_DESC(primary_reselect, "Reselect primary slave "
+				   "once it comes up; "
+				   "0 for always (default), "
+				   "1 for only if speed of primary is "
+				   "better, "
+				   "2 for only on active slave "
+				   "failure");
 module_param(lacp_rate, charp, 0);
 MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner "
 			    "(slow/fast)");
@@ -200,6 +209,13 @@ const struct bond_parm_tbl fail_over_mac_tbl[] = {
 {	NULL,			-1},
 };
 
+const struct bond_parm_tbl pri_reselect_tbl[] = {
+{	"always",		BOND_PRI_RESELECT_ALWAYS},
+{	"better",		BOND_PRI_RESELECT_BETTER},
+{	"failure",		BOND_PRI_RESELECT_FAILURE},
+{	NULL,			-1},
+};
+
 struct bond_parm_tbl ad_select_tbl[] = {
 {	"stable",	BOND_AD_STABLE},
 {	"bandwidth",	BOND_AD_BANDWIDTH},
@@ -1070,6 +1086,25 @@ out:
 
 }
 
+static bool bond_should_change_active(struct bonding *bond)
+{
+	struct slave *prim = bond->primary_slave;
+	struct slave *curr = bond->curr_active_slave;
+
+	if (!prim || !curr || curr->link != BOND_LINK_UP)
+		return true;
+	if (bond->force_primary) {
+		bond->force_primary = false;
+		return true;
+	}
+	if (bond->params.primary_reselect == BOND_PRI_RESELECT_BETTER &&
+	    (prim->speed < curr->speed ||
+	     (prim->speed == curr->speed && prim->duplex <= curr->duplex)))
+		return false;
+	if (bond->params.primary_reselect == BOND_PRI_RESELECT_FAILURE)
+		return false;
+	return true;
+}
 
 /**
  * find_best_interface - select the best available slave to be the active one
@@ -1094,7 +1129,8 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
 	}
 
 	if ((bond->primary_slave) &&
-	    bond->primary_slave->link == BOND_LINK_UP) {
+	    bond->primary_slave->link == BOND_LINK_UP &&
+	    bond_should_change_active(bond)) {
 		new_active = bond->primary_slave;
 	}
 
@@ -1675,8 +1711,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
 		/* if there is a primary slave, remember it */
-		if (strcmp(bond->params.primary, new_slave->dev->name) == 0)
+		if (strcmp(bond->params.primary, new_slave->dev->name) == 0) {
 			bond->primary_slave = new_slave;
+			bond->force_primary = true;
+		}
 	}
 
 	write_lock_bh(&bond->curr_slave_lock);
@@ -3198,11 +3236,14 @@ static void bond_info_show_master(struct seq_file *seq)
 	}
 
 	if (USES_PRIMARY(bond->params.mode)) {
-		seq_printf(seq, "Primary Slave: %s\n",
+		seq_printf(seq, "Primary Slave: %s",
 			   (bond->primary_slave) ?
 			   bond->primary_slave->dev->name : "None");
+		if (bond->primary_slave)
+			seq_printf(seq, " (primary_reselect %s)",
+		   pri_reselect_tbl[bond->params.primary_reselect].modename);
 
-		seq_printf(seq, "Currently Active Slave: %s\n",
+		seq_printf(seq, "\nCurrently Active Slave: %s\n",
 			   (curr) ? curr->dev->name : "None");
 	}
 
@@ -4643,7 +4684,7 @@ int bond_parse_parm(const char *buf, const struct bond_parm_tbl *tbl)
 
 static int bond_check_params(struct bond_params *params)
 {
-	int arp_validate_value, fail_over_mac_value;
+	int arp_validate_value, fail_over_mac_value, primary_reselect_value;
 
 	/*
 	 * Convert string parameters.
@@ -4942,6 +4983,20 @@ static int bond_check_params(struct bond_params *params)
 		primary = NULL;
 	}
 
+	if (primary && primary_reselect) {
+		primary_reselect_value = bond_parse_parm(primary_reselect,
+							 pri_reselect_tbl);
+		if (primary_reselect_value == -1) {
+			pr_err(DRV_NAME
+			       ": Error: Invalid primary_reselect \"%s\"\n",
+			       primary_reselect ==
+					NULL ? "NULL" : primary_reselect);
+			return -EINVAL;
+		}
+	} else {
+		primary_reselect_value = BOND_PRI_RESELECT_ALWAYS;
+	}
+
 	if (fail_over_mac) {
 		fail_over_mac_value = bond_parse_parm(fail_over_mac,
 						      fail_over_mac_tbl);
@@ -4973,6 +5028,7 @@ static int bond_check_params(struct bond_params *params)
 	params->use_carrier = use_carrier;
 	params->lacp_fast = lacp_fast;
 	params->primary[0] = 0;
+	params->primary_reselect = primary_reselect_value;
 	params->fail_over_mac = fail_over_mac_value;
 
 	if (primary) {
diff --git a/drivers/net/bonding/bond_main.c.rej b/drivers/net/bonding/bond_main.c.rej
new file mode 100644
index 0000000..6854718
--- /dev/null
+++ b/drivers/net/bonding/bond_main.c.rej
@@ -0,0 +1,18 @@
+*************** static struct slave *bond_find_best_slave(struct bonding *bond)
+*** 1094,1100 ****
+  	}
+  
+  	if ((bond->primary_slave) &&
+- 	    bond->primary_slave->link == BOND_LINK_UP) {
+  		new_active = bond->primary_slave;
+  	}
+  
+--- 1129,1136 ----
+  	}
+  
+  	if ((bond->primary_slave) &&
++ 	    bond->primary_slave->link == BOND_LINK_UP &&
++ 	    bond_should_change_active(bond)) {
+  		new_active = bond->primary_slave;
+  	}
+  
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 6044e12..8ee6164 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1212,6 +1212,58 @@ static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR,
 		   bonding_show_primary, bonding_store_primary);
 
 /*
+ * Show and set the primary_reselect flag.
+ */
+static ssize_t bonding_show_primary_reselect(struct device *d,
+					     struct device_attribute *attr,
+					     char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%s %d\n",
+		       pri_reselect_tbl[bond->params.primary_reselect].modename,
+		       bond->params.primary_reselect);
+}
+
+static ssize_t bonding_store_primary_reselect(struct device *d,
+					      struct device_attribute *attr,
+					      const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	new_value = bond_parse_parm(buf, pri_reselect_tbl);
+	if (new_value < 0)  {
+		pr_err(DRV_NAME
+		       ": %s: Ignoring invalid primary_reselect value %.*s.\n",
+		       bond->dev->name,
+		       (int) strlen(buf) - 1, buf);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	bond->params.primary_reselect = new_value;
+	pr_info(DRV_NAME ": %s: setting primary_reselect to %s (%d).\n",
+		bond->dev->name, pri_reselect_tbl[new_value].modename,
+		new_value);
+
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
+	bond_select_active_slave(bond);
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
+out:
+	rtnl_unlock();
+	return ret;
+}
+static DEVICE_ATTR(primary_reselect, S_IRUGO | S_IWUSR,
+		   bonding_show_primary_reselect,
+		   bonding_store_primary_reselect);
+
+/*
  * Show and set the use_carrier flag.
  */
 static ssize_t bonding_show_carrier(struct device *d,
@@ -1500,6 +1552,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_num_unsol_na.attr,
 	&dev_attr_miimon.attr,
 	&dev_attr_primary.attr,
+	&dev_attr_primary_reselect.attr,
 	&dev_attr_use_carrier.attr,
 	&dev_attr_active_slave.attr,
 	&dev_attr_mii_status.attr,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6824771..9c03c2e 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -23,8 +23,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.5.0"
-#define DRV_RELDATE	"November 4, 2008"
+#define DRV_VERSION	"3.6.0"
+#define DRV_RELDATE	"September 26, 2009"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
@@ -131,6 +131,7 @@ struct bond_params {
 	int lacp_fast;
 	int ad_select;
 	char primary[IFNAMSIZ];
+	int primary_reselect;
 	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
 };
 
@@ -190,6 +191,7 @@ struct bonding {
 	struct   slave *curr_active_slave;
 	struct   slave *current_arp_slave;
 	struct   slave *primary_slave;
+	bool     force_primary;
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
@@ -258,6 +260,10 @@ static inline bool bond_is_lb(const struct bonding *bond)
 		|| bond->params.mode == BOND_MODE_ALB;
 }
 
+#define BOND_PRI_RESELECT_ALWAYS	0
+#define BOND_PRI_RESELECT_BETTER	1
+#define BOND_PRI_RESELECT_FAILURE	2
+
 #define BOND_FOM_NONE			0
 #define BOND_FOM_ACTIVE			1
 #define BOND_FOM_FOLLOW			2
@@ -348,6 +354,7 @@ extern const struct bond_parm_tbl bond_mode_tbl[];
 extern const struct bond_parm_tbl xmit_hashtype_tbl[];
 extern const struct bond_parm_tbl arp_validate_tbl[];
 extern const struct bond_parm_tbl fail_over_mac_tbl[];
+extern const struct bond_parm_tbl pri_reselect_tbl[];
 extern struct bond_parm_tbl ad_select_tbl[];
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-- 
1.6.0.2

