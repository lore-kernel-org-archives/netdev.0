From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] bonding: introduce primary_passive option
Date: Tue, 1 Sep 2009 19:42:35 +0200
Message-ID: <20090901174234.GA3209@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, nicolas.2p.debian@free.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62436 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754644AbZIARm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 13:42:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(updated)

In some cases there is not desirable to switch back to primary interface when
it's link recovers and rather stay with currently active one. We need to avoid
packetloss as much as we can in some cases. This is solved by introducing
primary_passive option. Note that enslaved primary slave is set as current
active no matter what.

This patch depends on the following one:
[net-next-2.6] bonding: make ab_arp select active slaves as other modes
http://patchwork.ozlabs.org/patch/32684/

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index d5181ce..e70fa8e 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -614,6 +614,17 @@ primary
 
 	The primary option is only valid for active-backup mode.
 
+primary_passive
+
+	Specifies the behaviour of the primary slave in case of
+	it's link recovery has been detected. By default (value 0) the
+	primary slave is set as active slave immediately after the link
+	recovery. If the value is 1 or 2 then current active slave doesn't
+	change as long as it's link status doesn't change. This prevents
+	the bonding device from flip-flopping. Plus if the value is 1 this
+	behaviour happens only if the speed and duplex of primary slave is
+	higher. It the value is 2 then it happens everytime.
+
 updelay
 
 	Specifies the time, in milliseconds, to wait before enabling a
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 699bfdd..65066c1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -94,6 +94,7 @@ static int downdelay;
 static int use_carrier	= 1;
 static char *mode;
 static char *primary;
+static int primary_passive;
 static char *lacp_rate;
 static char *ad_select;
 static char *xmit_hash_policy;
@@ -126,6 +127,9 @@ MODULE_PARM_DESC(mode, "Mode of operation : 0 for balance-rr, "
 		       "6 for balance-alb");
 module_param(primary, charp, 0);
 MODULE_PARM_DESC(primary, "Primary network device to use");
+module_param(primary_passive, int, 0);
+MODULE_PARM_DESC(primary_passive, "Do not set primary slave active once it comes up; "
+			       "0 for off (default), 1 for on only if speed of primary is not higher, 2 for on");
 module_param(lacp_rate, charp, 0);
 MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner "
 			    "(slow/fast)");
@@ -1070,6 +1074,25 @@ out:
 
 }
 
+static bool bond_should_loose_active(struct bonding *bond)
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
+	if (bond->params.primary_passive == 1 &&
+	    (prim->speed < curr->speed ||
+	     (prim->speed == curr->speed && prim->duplex <= curr->duplex)))
+		return false;
+	if (bond->params.primary_passive == 2)
+		return false;
+	return true;
+}
 
 /**
  * find_best_interface - select the best available slave to be the active one
@@ -1094,7 +1117,8 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
 	}
 
 	if ((bond->primary_slave) &&
-	    bond->primary_slave->link == BOND_LINK_UP) {
+	    bond->primary_slave->link == BOND_LINK_UP &&
+	    bond_should_loose_active(bond)) {
 		new_active = bond->primary_slave;
 	}
 
@@ -1675,8 +1699,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
 		/* if there is a primary slave, remember it */
-		if (strcmp(bond->params.primary, new_slave->dev->name) == 0)
+		if (strcmp(bond->params.primary, new_slave->dev->name) == 0) {
 			bond->primary_slave = new_slave;
+			bond->force_primary = true;
+		}
 	}
 
 	write_lock_bh(&bond->curr_slave_lock);
@@ -4942,6 +4968,18 @@ static int bond_check_params(struct bond_params *params)
 		primary = NULL;
 	}
 
+	if (primary) {
+		if ((primary_passive != 0) && (primary_passive != 1) &&
+		    (primary_passive != 2)) {
+			pr_warning(DRV_NAME
+				   ": Warning: primary_passive module parameter "
+				   "(%d), not of valid value (0/1/2), so it was "
+				   "set to 0\n",
+				   primary_passive);
+			primary_passive = 0;
+		}
+	}
+
 	if (fail_over_mac) {
 		fail_over_mac_value = bond_parse_parm(fail_over_mac,
 						      fail_over_mac_tbl);
@@ -4973,6 +5011,7 @@ static int bond_check_params(struct bond_params *params)
 	params->use_carrier = use_carrier;
 	params->lacp_fast = lacp_fast;
 	params->primary[0] = 0;
+	params->primary_passive = primary_passive;
 	params->fail_over_mac = fail_over_mac_value;
 
 	if (primary) {
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 6044e12..e813d48 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1212,6 +1212,59 @@ static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR,
 		   bonding_show_primary, bonding_store_primary);
 
 /*
+ * Show and set the primary_passive flag.
+ */
+static ssize_t bonding_show_primary_passive(struct device *d,
+					    struct device_attribute *attr,
+					    char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.primary_passive);
+}
+
+static ssize_t bonding_store_primary_passive(struct device *d,
+					     struct device_attribute *attr,
+					     const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		pr_err(DRV_NAME
+		       ": %s: no primary_passive value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+	if (new_value == 0 || new_value == 1 || new_value == 2) {
+		bond->params.primary_passive = new_value;
+		pr_info(DRV_NAME ": %s: Setting primary_passive to %d.\n",
+		       bond->dev->name, new_value);
+		if (new_value == 0 || new_value == 1) {
+			bond->force_primary = true;
+			read_lock(&bond->lock);
+			write_lock_bh(&bond->curr_slave_lock);
+			bond_select_active_slave(bond);
+			write_unlock_bh(&bond->curr_slave_lock);
+			read_unlock(&bond->lock);
+		}
+	} else {
+		pr_info(DRV_NAME
+		       ": %s: Ignoring invalid primary_passive value %d.\n",
+		       bond->dev->name, new_value);
+	}
+out:
+	rtnl_unlock();
+	return count;
+}
+static DEVICE_ATTR(primary_passive, S_IRUGO | S_IWUSR,
+		   bonding_show_primary_passive, bonding_store_primary_passive);
+
+/*
  * Show and set the use_carrier flag.
  */
 static ssize_t bonding_show_carrier(struct device *d,
@@ -1500,6 +1553,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_num_unsol_na.attr,
 	&dev_attr_miimon.attr,
 	&dev_attr_primary.attr,
+	&dev_attr_primary_passive.attr,
 	&dev_attr_use_carrier.attr,
 	&dev_attr_active_slave.attr,
 	&dev_attr_mii_status.attr,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6290a50..b6287e0 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -131,6 +131,7 @@ struct bond_params {
 	int lacp_fast;
 	int ad_select;
 	char primary[IFNAMSIZ];
+	int primary_passive;
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
