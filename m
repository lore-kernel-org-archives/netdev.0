From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 11/12] bonding: convert bond_options.c to use netdev_printk instead of pr_
Date: Tue, 15 Jul 2014 19:36:08 +0200
Message-ID: <1405445769-15394-12-git-send-email-vfalico@gmail.com>
References: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757613AbaGORkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 13:40:53 -0400
In-Reply-To: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_options.c | 216 +++++++++++++++++--------------------
 1 file changed, 101 insertions(+), 115 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 540e016..e86d1eb 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -544,9 +544,8 @@ static void bond_opt_dep_print(struct bonding *bond,
 	params = &bond->params;
 	modeval = bond_opt_get_val(BOND_OPT_MODE, params->mode);
 	if (test_bit(params->mode, &opt->unsuppmodes))
-		pr_err("%s: option %s: mode dependency failed, not supported in mode %s(%llu)\n",
-		       bond->dev->name, opt->name,
-		       modeval->string, modeval->value);
+		netdev_err(bond->dev, "option %s: mode dependency failed, not supported in mode %s(%llu)\n",
+			   opt->name, modeval->string, modeval->value);
 }
 
 static void bond_opt_error_interpret(struct bonding *bond,
@@ -564,31 +563,30 @@ static void bond_opt_error_interpret(struct bonding *bond,
 				p = strchr(val->string, '\n');
 				if (p)
 					*p = '\0';
-				pr_err("%s: option %s: invalid value (%s)\n",
-				       bond->dev->name, opt->name, val->string);
+				netdev_err(bond->dev, "option %s: invalid value (%s)\n",
+					   opt->name, val->string);
 			} else {
-				pr_err("%s: option %s: invalid value (%llu)\n",
-				       bond->dev->name, opt->name, val->value);
+				netdev_err(bond->dev, "option %s: invalid value (%llu)\n",
+					   opt->name, val->value);
 			}
 		}
 		minval = bond_opt_get_flags(opt, BOND_VALFLAG_MIN);
 		maxval = bond_opt_get_flags(opt, BOND_VALFLAG_MAX);
 		if (!maxval)
 			break;
-		pr_err("%s: option %s: allowed values %llu - %llu\n",
-		       bond->dev->name, opt->name, minval ? minval->value : 0,
-		       maxval->value);
+		netdev_err(bond->dev, "option %s: allowed values %llu - %llu\n",
+			   opt->name, minval ? minval->value : 0, maxval->value);
 		break;
 	case -EACCES:
 		bond_opt_dep_print(bond, opt);
 		break;
 	case -ENOTEMPTY:
-		pr_err("%s: option %s: unable to set because the bond device has slaves\n",
-		       bond->dev->name, opt->name);
+		netdev_err(bond->dev, "option %s: unable to set because the bond device has slaves\n",
+			   opt->name);
 		break;
 	case -EBUSY:
-		pr_err("%s: option %s: unable to set because the bond device is up\n",
-		       bond->dev->name, opt->name);
+		netdev_err(bond->dev, "option %s: unable to set because the bond device is up\n",
+			   opt->name);
 		break;
 	default:
 		break;
@@ -674,14 +672,14 @@ const struct bond_option *bond_opt_get(unsigned int option)
 int bond_option_mode_set(struct bonding *bond, const struct bond_opt_value *newval)
 {
 	if (!bond_mode_uses_arp(newval->value) && bond->params.arp_interval) {
-		pr_info("%s: %s mode is incompatible with arp monitoring, start mii monitoring\n",
-			bond->dev->name, newval->string);
+		netdev_info(bond->dev, "%s mode is incompatible with arp monitoring, start mii monitoring\n",
+			    newval->string);
 		/* disable arp monitoring */
 		bond->params.arp_interval = 0;
 		/* set miimon to default value */
 		bond->params.miimon = BOND_DEFAULT_MIIMON;
-		pr_info("%s: Setting MII monitoring interval to %d\n",
-			bond->dev->name, bond->params.miimon);
+		netdev_info(bond->dev, "Setting MII monitoring interval to %d\n",
+			    bond->params.miimon);
 	}
 
 	/* don't cache arp_validate between modes */
@@ -727,14 +725,14 @@ static int bond_option_active_slave_set(struct bonding *bond,
 
 	if (slave_dev) {
 		if (!netif_is_bond_slave(slave_dev)) {
-			pr_err("Device %s is not bonding slave\n",
-			       slave_dev->name);
+			netdev_err(bond->dev, "Device %s is not bonding slave\n",
+				   slave_dev->name);
 			return -EINVAL;
 		}
 
 		if (bond->dev != netdev_master_upper_dev_get(slave_dev)) {
-			pr_err("%s: Device %s is not our slave\n",
-			       bond->dev->name, slave_dev->name);
+			netdev_err(bond->dev, "Device %s is not our slave\n",
+				   slave_dev->name);
 			return -EINVAL;
 		}
 	}
@@ -744,7 +742,7 @@ static int bond_option_active_slave_set(struct bonding *bond,
 
 	/* check to see if we are clearing active */
 	if (!slave_dev) {
-		pr_info("%s: Clearing current active slave\n", bond->dev->name);
+		netdev_info(bond->dev, "Clearing current active slave\n");
 		RCU_INIT_POINTER(bond->curr_active_slave, NULL);
 		bond_select_active_slave(bond);
 	} else {
@@ -755,18 +753,18 @@ static int bond_option_active_slave_set(struct bonding *bond,
 
 		if (new_active == old_active) {
 			/* do nothing */
-			pr_info("%s: %s is already the current active slave\n",
-				bond->dev->name, new_active->dev->name);
+			netdev_info(bond->dev, "%s is already the current active slave\n",
+				    new_active->dev->name);
 		} else {
 			if (old_active && (new_active->link == BOND_LINK_UP) &&
 			    bond_slave_is_up(new_active)) {
-				pr_info("%s: Setting %s as active slave\n",
-					bond->dev->name, new_active->dev->name);
+				netdev_info(bond->dev, "Setting %s as active slave\n",
+					    new_active->dev->name);
 				bond_change_active_slave(bond, new_active);
 			} else {
-				pr_err("%s: Could not set %s as active slave; either %s is down or the link is down\n",
-				       bond->dev->name, new_active->dev->name,
-				       new_active->dev->name);
+				netdev_err(bond->dev, "Could not set %s as active slave; either %s is down or the link is down\n",
+					   new_active->dev->name,
+					   new_active->dev->name);
 				ret = -EINVAL;
 			}
 		}
@@ -785,20 +783,17 @@ static int bond_option_active_slave_set(struct bonding *bond,
 static int bond_option_miimon_set(struct bonding *bond,
 				  const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting MII monitoring interval to %llu\n",
-		bond->dev->name, newval->value);
+	netdev_info(bond->dev, "Setting MII monitoring interval to %llu\n",
+		    newval->value);
 	bond->params.miimon = newval->value;
 	if (bond->params.updelay)
-		pr_info("%s: Note: Updating updelay (to %d) since it is a multiple of the miimon value\n",
-			bond->dev->name,
+		netdev_info(bond->dev, "Note: Updating updelay (to %d) since it is a multiple of the miimon value\n",
 			bond->params.updelay * bond->params.miimon);
 	if (bond->params.downdelay)
-		pr_info("%s: Note: Updating downdelay (to %d) since it is a multiple of the miimon value\n",
-			bond->dev->name,
-			bond->params.downdelay * bond->params.miimon);
+		netdev_info(bond->dev, "Note: Updating downdelay (to %d) since it is a multiple of the miimon value\n",
+			    bond->params.downdelay * bond->params.miimon);
 	if (newval->value && bond->params.arp_interval) {
-		pr_info("%s: MII monitoring cannot be used with ARP monitoring - disabling ARP monitoring...\n",
-			bond->dev->name);
+		netdev_info(bond->dev, "MII monitoring cannot be used with ARP monitoring - disabling ARP monitoring...\n");
 		bond->params.arp_interval = 0;
 		if (bond->params.arp_validate)
 			bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
@@ -830,20 +825,18 @@ static int bond_option_updelay_set(struct bonding *bond,
 	int value = newval->value;
 
 	if (!bond->params.miimon) {
-		pr_err("%s: Unable to set up delay as MII monitoring is disabled\n",
-		       bond->dev->name);
+		netdev_err(bond->dev, "Unable to set up delay as MII monitoring is disabled\n");
 		return -EPERM;
 	}
 	if ((value % bond->params.miimon) != 0) {
-		pr_warn("%s: Warning: up delay (%d) is not a multiple of miimon (%d), updelay rounded to %d ms\n",
-			bond->dev->name, value,
-			bond->params.miimon,
-			(value / bond->params.miimon) *
-			bond->params.miimon);
+		netdev_warn(bond->dev, "up delay (%d) is not a multiple of miimon (%d), updelay rounded to %d ms\n",
+			    value, bond->params.miimon,
+			    (value / bond->params.miimon) *
+			    bond->params.miimon);
 	}
 	bond->params.updelay = value / bond->params.miimon;
-	pr_info("%s: Setting up delay to %d\n",
-		bond->dev->name, bond->params.updelay * bond->params.miimon);
+	netdev_info(bond->dev, "Setting up delay to %d\n",
+		    bond->params.updelay * bond->params.miimon);
 
 	return 0;
 }
@@ -854,20 +847,18 @@ static int bond_option_downdelay_set(struct bonding *bond,
 	int value = newval->value;
 
 	if (!bond->params.miimon) {
-		pr_err("%s: Unable to set down delay as MII monitoring is disabled\n",
-		       bond->dev->name);
+		netdev_err(bond->dev, "Unable to set down delay as MII monitoring is disabled\n");
 		return -EPERM;
 	}
 	if ((value % bond->params.miimon) != 0) {
-		pr_warn("%s: Warning: down delay (%d) is not a multiple of miimon (%d), delay rounded to %d ms\n",
-			bond->dev->name, value,
-			bond->params.miimon,
-			(value / bond->params.miimon) *
-			bond->params.miimon);
+		netdev_warn(bond->dev, "down delay (%d) is not a multiple of miimon (%d), delay rounded to %d ms\n",
+			    value, bond->params.miimon,
+			    (value / bond->params.miimon) *
+			    bond->params.miimon);
 	}
 	bond->params.downdelay = value / bond->params.miimon;
-	pr_info("%s: Setting down delay to %d\n",
-		bond->dev->name, bond->params.downdelay * bond->params.miimon);
+	netdev_info(bond->dev, "Setting down delay to %d\n",
+		    bond->params.downdelay * bond->params.miimon);
 
 	return 0;
 }
@@ -875,8 +866,8 @@ static int bond_option_downdelay_set(struct bonding *bond,
 static int bond_option_use_carrier_set(struct bonding *bond,
 				       const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting use_carrier to %llu\n",
-		bond->dev->name, newval->value);
+	netdev_info(bond->dev, "Setting use_carrier to %llu\n",
+		    newval->value);
 	bond->params.use_carrier = newval->value;
 
 	return 0;
@@ -889,18 +880,16 @@ static int bond_option_use_carrier_set(struct bonding *bond,
 static int bond_option_arp_interval_set(struct bonding *bond,
 					const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting ARP monitoring interval to %llu\n",
-		bond->dev->name, newval->value);
+	netdev_info(bond->dev, "Setting ARP monitoring interval to %llu\n",
+		    newval->value);
 	bond->params.arp_interval = newval->value;
 	if (newval->value) {
 		if (bond->params.miimon) {
-			pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s Disabling MII monitoring\n",
-				bond->dev->name, bond->dev->name);
+			netdev_info(bond->dev, "ARP monitoring cannot be used with MII monitoring. Disabling MII monitoring\n");
 			bond->params.miimon = 0;
 		}
 		if (!bond->params.arp_targets[0])
-			pr_info("%s: ARP monitoring has been set up, but no ARP targets have been specified\n",
-				bond->dev->name);
+			netdev_info(bond->dev, "ARP monitoring has been set up, but no ARP targets have been specified\n");
 	}
 	if (bond->dev->flags & IFF_UP) {
 		/* If the interface is up, we may need to fire off
@@ -944,24 +933,24 @@ static int _bond_option_arp_ip_target_add(struct bonding *bond, __be32 target)
 	int ind;
 
 	if (!bond_is_ip_target_ok(target)) {
-		pr_err("%s: invalid ARP target %pI4 specified for addition\n",
-		       bond->dev->name, &target);
+		netdev_err(bond->dev, "invalid ARP target %pI4 specified for addition\n",
+			   &target);
 		return -EINVAL;
 	}
 
 	if (bond_get_targets_ip(targets, target) != -1) { /* dup */
-		pr_err("%s: ARP target %pI4 is already present\n",
-		       bond->dev->name, &target);
+		netdev_err(bond->dev, "ARP target %pI4 is already present\n",
+			   &target);
 		return -EINVAL;
 	}
 
 	ind = bond_get_targets_ip(targets, 0); /* first free slot */
 	if (ind == -1) {
-		pr_err("%s: ARP target table is full!\n", bond->dev->name);
+		netdev_err(bond->dev, "ARP target table is full!\n");
 		return -EINVAL;
 	}
 
-	pr_info("%s: Adding ARP target %pI4\n", bond->dev->name, &target);
+	netdev_info(bond->dev, "Adding ARP target %pI4\n", &target);
 
 	_bond_options_arp_ip_target_set(bond, ind, target, jiffies);
 
@@ -989,23 +978,22 @@ static int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target)
 	int ind, i;
 
 	if (!bond_is_ip_target_ok(target)) {
-		pr_err("%s: invalid ARP target %pI4 specified for removal\n",
-		       bond->dev->name, &target);
+		netdev_err(bond->dev, "invalid ARP target %pI4 specified for removal\n",
+			   &target);
 		return -EINVAL;
 	}
 
 	ind = bond_get_targets_ip(targets, target);
 	if (ind == -1) {
-		pr_err("%s: unable to remove nonexistent ARP target %pI4\n",
-		       bond->dev->name, &target);
+		netdev_err(bond->dev, "unable to remove nonexistent ARP target %pI4\n",
+			   &target);
 		return -EINVAL;
 	}
 
 	if (ind == 0 && !targets[1] && bond->params.arp_interval)
-		pr_warn("%s: Removing last arp target with arp_interval on\n",
-			bond->dev->name);
+		netdev_warn(bond->dev, "Removing last arp target with arp_interval on\n");
 
-	pr_info("%s: Removing ARP target %pI4\n", bond->dev->name, &target);
+	netdev_info(bond->dev, "Removing ARP target %pI4\n", &target);
 
 	/* not to race with bond_arp_rcv */
 	write_lock_bh(&bond->lock);
@@ -1044,8 +1032,8 @@ static int bond_option_arp_ip_targets_set(struct bonding *bond,
 
 	if (newval->string) {
 		if (!in4_pton(newval->string+1, -1, (u8 *)&target, -1, NULL)) {
-			pr_err("%s: invalid ARP target %pI4 specified\n",
-			       bond->dev->name, &target);
+			netdev_err(bond->dev, "invalid ARP target %pI4 specified\n",
+				   &target);
 			return ret;
 		}
 		if (newval->string[0] == '+')
@@ -1053,8 +1041,7 @@ static int bond_option_arp_ip_targets_set(struct bonding *bond,
 		else if (newval->string[0] == '-')
 			ret = bond_option_arp_ip_target_rem(bond, target);
 		else
-			pr_err("no command found in arp_ip_targets file for bond %s - use +<addr> or -<addr>\n",
-			       bond->dev->name);
+			netdev_err(bond->dev, "no command found in arp_ip_targets file - use +<addr> or -<addr>\n");
 	} else {
 		target = newval->value;
 		ret = bond_option_arp_ip_target_add(bond, target);
@@ -1066,8 +1053,8 @@ static int bond_option_arp_ip_targets_set(struct bonding *bond,
 static int bond_option_arp_validate_set(struct bonding *bond,
 					const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting arp_validate to %s (%llu)\n",
-		bond->dev->name, newval->string, newval->value);
+	netdev_info(bond->dev, "Setting arp_validate to %s (%llu)\n",
+		    newval->string, newval->value);
 
 	if (bond->dev->flags & IFF_UP) {
 		if (!newval->value)
@@ -1083,8 +1070,8 @@ static int bond_option_arp_validate_set(struct bonding *bond,
 static int bond_option_arp_all_targets_set(struct bonding *bond,
 					   const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting arp_all_targets to %s (%llu)\n",
-		bond->dev->name, newval->string, newval->value);
+	netdev_info(bond->dev, "Setting arp_all_targets to %s (%llu)\n",
+		    newval->string, newval->value);
 	bond->params.arp_all_targets = newval->value;
 
 	return 0;
@@ -1106,7 +1093,7 @@ static int bond_option_primary_set(struct bonding *bond,
 		*p = '\0';
 	/* check to see if we are clearing primary */
 	if (!strlen(primary)) {
-		pr_info("%s: Setting primary slave to None\n", bond->dev->name);
+		netdev_info(bond->dev, "Setting primary slave to None\n");
 		bond->primary_slave = NULL;
 		memset(bond->params.primary, 0, sizeof(bond->params.primary));
 		bond_select_active_slave(bond);
@@ -1115,8 +1102,8 @@ static int bond_option_primary_set(struct bonding *bond,
 
 	bond_for_each_slave(bond, slave, iter) {
 		if (strncmp(slave->dev->name, primary, IFNAMSIZ) == 0) {
-			pr_info("%s: Setting %s as primary slave\n",
-				bond->dev->name, slave->dev->name);
+			netdev_info(bond->dev, "Setting %s as primary slave\n",
+				    slave->dev->name);
 			bond->primary_slave = slave;
 			strcpy(bond->params.primary, slave->dev->name);
 			bond_select_active_slave(bond);
@@ -1125,15 +1112,15 @@ static int bond_option_primary_set(struct bonding *bond,
 	}
 
 	if (bond->primary_slave) {
-		pr_info("%s: Setting primary slave to None\n", bond->dev->name);
+		netdev_info(bond->dev, "Setting primary slave to None\n");
 		bond->primary_slave = NULL;
 		bond_select_active_slave(bond);
 	}
 	strncpy(bond->params.primary, primary, IFNAMSIZ);
 	bond->params.primary[IFNAMSIZ - 1] = 0;
 
-	pr_info("%s: Recording %s as primary, but it has not been enslaved to %s yet\n",
-		bond->dev->name, primary, bond->dev->name);
+	netdev_info(bond->dev, "Recording %s as primary, but it has not been enslaved to %s yet\n",
+		    primary, bond->dev->name);
 
 out:
 	write_unlock_bh(&bond->curr_slave_lock);
@@ -1146,8 +1133,8 @@ out:
 static int bond_option_primary_reselect_set(struct bonding *bond,
 					    const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting primary_reselect to %s (%llu)\n",
-		bond->dev->name, newval->string, newval->value);
+	netdev_info(bond->dev, "Setting primary_reselect to %s (%llu)\n",
+		    newval->string, newval->value);
 	bond->params.primary_reselect = newval->value;
 
 	block_netpoll_tx();
@@ -1162,8 +1149,8 @@ static int bond_option_primary_reselect_set(struct bonding *bond,
 static int bond_option_fail_over_mac_set(struct bonding *bond,
 					 const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting fail_over_mac to %s (%llu)\n",
-		bond->dev->name, newval->string, newval->value);
+	netdev_info(bond->dev, "Setting fail_over_mac to %s (%llu)\n",
+		    newval->string, newval->value);
 	bond->params.fail_over_mac = newval->value;
 
 	return 0;
@@ -1172,8 +1159,8 @@ static int bond_option_fail_over_mac_set(struct bonding *bond,
 static int bond_option_xmit_hash_policy_set(struct bonding *bond,
 					    const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting xmit hash policy to %s (%llu)\n",
-		bond->dev->name, newval->string, newval->value);
+	netdev_info(bond->dev, "Setting xmit hash policy to %s (%llu)\n",
+		    newval->string, newval->value);
 	bond->params.xmit_policy = newval->value;
 
 	return 0;
@@ -1182,8 +1169,8 @@ static int bond_option_xmit_hash_policy_set(struct bonding *bond,
 static int bond_option_resend_igmp_set(struct bonding *bond,
 				       const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting resend_igmp to %llu\n",
-		bond->dev->name, newval->value);
+	netdev_info(bond->dev, "Setting resend_igmp to %llu\n",
+		    newval->value);
 	bond->params.resend_igmp = newval->value;
 
 	return 0;
@@ -1221,8 +1208,8 @@ static int bond_option_all_slaves_active_set(struct bonding *bond,
 static int bond_option_min_links_set(struct bonding *bond,
 				     const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting min links value to %llu\n",
-		bond->dev->name, newval->value);
+	netdev_info(bond->dev, "Setting min links value to %llu\n",
+		    newval->value);
 	bond->params.min_links = newval->value;
 
 	return 0;
@@ -1257,8 +1244,8 @@ static int bond_option_pps_set(struct bonding *bond,
 static int bond_option_lacp_rate_set(struct bonding *bond,
 				     const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting LACP rate to %s (%llu)\n",
-		bond->dev->name, newval->string, newval->value);
+	netdev_info(bond->dev, "Setting LACP rate to %s (%llu)\n",
+		    newval->string, newval->value);
 	bond->params.lacp_fast = newval->value;
 	bond_3ad_update_lacp_rate(bond);
 
@@ -1268,8 +1255,8 @@ static int bond_option_lacp_rate_set(struct bonding *bond,
 static int bond_option_ad_select_set(struct bonding *bond,
 				     const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting ad_select to %s (%llu)\n",
-		bond->dev->name, newval->string, newval->value);
+	netdev_info(bond->dev, "Setting ad_select to %s (%llu)\n",
+		    newval->string, newval->value);
 	bond->params.ad_select = newval->value;
 
 	return 0;
@@ -1330,7 +1317,7 @@ out:
 	return ret;
 
 err_no_cmd:
-	pr_info("invalid input for queue_id set for %s\n", bond->dev->name);
+	netdev_info(bond->dev, "invalid input for queue_id set\n");
 	ret = -EPERM;
 	goto out;
 
@@ -1352,20 +1339,20 @@ static int bond_option_slaves_set(struct bonding *bond,
 
 	dev = __dev_get_by_name(dev_net(bond->dev), ifname);
 	if (!dev) {
-		pr_info("%s: interface %s does not exist!\n",
-			bond->dev->name, ifname);
+		netdev_info(bond->dev, "interface %s does not exist!\n",
+			    ifname);
 		ret = -ENODEV;
 		goto out;
 	}
 
 	switch (command[0]) {
 	case '+':
-		pr_info("%s: Adding slave %s\n", bond->dev->name, dev->name);
+		netdev_info(bond->dev, "Adding slave %s\n", dev->name);
 		ret = bond_enslave(bond->dev, dev);
 		break;
 
 	case '-':
-		pr_info("%s: Removing slave %s\n", bond->dev->name, dev->name);
+		netdev_info(bond->dev, "Removing slave %s\n", dev->name);
 		ret = bond_release(bond->dev, dev);
 		break;
 
@@ -1377,8 +1364,7 @@ out:
 	return ret;
 
 err_no_cmd:
-	pr_err("no command found in slaves file for bond %s - use +ifname or -ifname\n",
-	       bond->dev->name);
+	netdev_err(bond->dev, "no command found in slaves file - use +ifname or -ifname\n");
 	ret = -EPERM;
 	goto out;
 }
@@ -1386,8 +1372,8 @@ err_no_cmd:
 static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
 					  const struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting dynamic-lb to %s (%llu)\n",
-		bond->dev->name, newval->string, newval->value);
+	netdev_info(bond->dev, "Setting dynamic-lb to %s (%llu)\n",
+		    newval->string, newval->value);
 	bond->params.tlb_dynamic_lb = newval->value;
 
 	return 0;
-- 
1.8.4
