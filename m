From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Add printk for bonding module packets_per_slave
 parameter
Date: Tue, 13 Jun 2017 09:21:03 -0700
Message-ID: <1497370863.18751.15.camel@perches.com>
References: <20170613134246.6407-1-michael.j.dilmore@gmail.com>
         <20170613.113411.506760268959654820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, michael.j.dilmore@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0162.hostedemail.com ([216.40.44.162]:34620 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752520AbdFMQVI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 12:21:08 -0400
In-Reply-To: <20170613.113411.506760268959654820.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-06-13 at 11:34 -0400, David Miller wrote:
> From: Michael Dilmore <michael.j.dilmore@gmail.com>
> Date: Tue, 13 Jun 2017 14:42:46 +0100
> 
> > The packets per slave parameter used by round robin mode does not have a printk debug
> > message in its set function in bond_options.c. Adding such a function would aid debugging
> > of round-robin mode and allow the user to more easily verify that the parameter has been
> > set correctly. I should add that I'm motivated by my own experience here - it's not
> > obvious from output of tools such as wireshark and ifstat that the parameter is working
> > correctly, and with the differences in bonding configuration across different distributions,
> > it would have been comforting to see this output.
> > 
> > Signed-off-by: Michael Dilmore <michael.j.dilmore@gmail.com>
> > 
> > cc: Veaceslav Falico <vfalico@gmail.com>,Andy Gospodarek <andy@greyhouse.net>,netdev@vger.kernel.org,linux-kernel@vger.kernel.org
> 
> You can verify things by simplying reading the value back.
> 
> If every parameter emitted a kernel log message, it would be
> unreadable.
> 
> I'm not applying this, sorry.

I agree.  Noisy logging output is not good.

Perhaps a general conversion of the dozens
of existing netdev_info uses in this file to
netdev_dbg and adding this at netdev_dbg is
appropriate.

Something like:
---
 drivers/net/bonding/bond_options.c | 119 +++++++++++++++++++------------------
 1 file changed, 60 insertions(+), 59 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 8ca683396fcc..9dec49b1b8ae 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -750,8 +750,8 @@ static int bond_option_mode_set(struct bonding *bond,
 		bond->params.arp_interval = 0;
 		/* set miimon to default value */
 		bond->params.miimon = BOND_DEFAULT_MIIMON;
-		netdev_info(bond->dev, "Setting MII monitoring interval to %d\n",
-			    bond->params.miimon);
+		netdev_dbg(bond->dev, "Setting MII monitoring interval to %d\n",
+			   bond->params.miimon);
 	}
 
 	/* don't cache arp_validate between modes */
@@ -794,7 +794,7 @@ static int bond_option_active_slave_set(struct bonding *bond,
 	block_netpoll_tx();
 	/* check to see if we are clearing active */
 	if (!slave_dev) {
-		netdev_info(bond->dev, "Clearing current active slave\n");
+		netdev_dbg(bond->dev, "Clearing current active slave\n");
 		RCU_INIT_POINTER(bond->curr_active_slave, NULL);
 		bond_select_active_slave(bond);
 	} else {
@@ -805,13 +805,13 @@ static int bond_option_active_slave_set(struct bonding *bond,
 
 		if (new_active == old_active) {
 			/* do nothing */
-			netdev_info(bond->dev, "%s is already the current active slave\n",
-				    new_active->dev->name);
+			netdev_dbg(bond->dev, "%s is already the current active slave\n",
+				   new_active->dev->name);
 		} else {
 			if (old_active && (new_active->link == BOND_LINK_UP) &&
 			    bond_slave_is_up(new_active)) {
-				netdev_info(bond->dev, "Setting %s as active slave\n",
-					    new_active->dev->name);
+				netdev_dbg(bond->dev, "Setting %s as active slave\n",
+					   new_active->dev->name);
 				bond_change_active_slave(bond, new_active);
 			} else {
 				netdev_err(bond->dev, "Could not set %s as active slave; either %s is down or the link is down\n",
@@ -833,17 +833,17 @@ static int bond_option_active_slave_set(struct bonding *bond,
 static int bond_option_miimon_set(struct bonding *bond,
 				  const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting MII monitoring interval to %llu\n",
-		    newval->value);
+	netdev_dbg(bond->dev, "Setting MII monitoring interval to %llu\n",
+		   newval->value);
 	bond->params.miimon = newval->value;
 	if (bond->params.updelay)
-		netdev_info(bond->dev, "Note: Updating updelay (to %d) since it is a multiple of the miimon value\n",
-			bond->params.updelay * bond->params.miimon);
+		netdev_dbg(bond->dev, "Note: Updating updelay (to %d) since it is a multiple of the miimon value\n",
+			   bond->params.updelay * bond->params.miimon);
 	if (bond->params.downdelay)
-		netdev_info(bond->dev, "Note: Updating downdelay (to %d) since it is a multiple of the miimon value\n",
-			    bond->params.downdelay * bond->params.miimon);
+		netdev_dbg(bond->dev, "Note: Updating downdelay (to %d) since it is a multiple of the miimon value\n",
+			   bond->params.downdelay * bond->params.miimon);
 	if (newval->value && bond->params.arp_interval) {
-		netdev_info(bond->dev, "MII monitoring cannot be used with ARP monitoring - disabling ARP monitoring...\n");
+		netdev_dbg(bond->dev, "MII monitoring cannot be used with ARP monitoring - disabling ARP monitoring...\n");
 		bond->params.arp_interval = 0;
 		if (bond->params.arp_validate)
 			bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
@@ -885,8 +885,8 @@ static int bond_option_updelay_set(struct bonding *bond,
 			    bond->params.miimon);
 	}
 	bond->params.updelay = value / bond->params.miimon;
-	netdev_info(bond->dev, "Setting up delay to %d\n",
-		    bond->params.updelay * bond->params.miimon);
+	netdev_dbg(bond->dev, "Setting up delay to %d\n",
+		   bond->params.updelay * bond->params.miimon);
 
 	return 0;
 }
@@ -907,8 +907,8 @@ static int bond_option_downdelay_set(struct bonding *bond,
 			    bond->params.miimon);
 	}
 	bond->params.downdelay = value / bond->params.miimon;
-	netdev_info(bond->dev, "Setting down delay to %d\n",
-		    bond->params.downdelay * bond->params.miimon);
+	netdev_dbg(bond->dev, "Setting down delay to %d\n",
+		   bond->params.downdelay * bond->params.miimon);
 
 	return 0;
 }
@@ -916,8 +916,7 @@ static int bond_option_downdelay_set(struct bonding *bond,
 static int bond_option_use_carrier_set(struct bonding *bond,
 				       const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting use_carrier to %llu\n",
-		    newval->value);
+	netdev_dbg(bond->dev, "Setting use_carrier to %llu\n", newval->value);
 	bond->params.use_carrier = newval->value;
 
 	return 0;
@@ -930,16 +929,16 @@ static int bond_option_use_carrier_set(struct bonding *bond,
 static int bond_option_arp_interval_set(struct bonding *bond,
 					const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting ARP monitoring interval to %llu\n",
-		    newval->value);
+	netdev_dbg(bond->dev, "Setting ARP monitoring interval to %llu\n",
+		   newval->value);
 	bond->params.arp_interval = newval->value;
 	if (newval->value) {
 		if (bond->params.miimon) {
-			netdev_info(bond->dev, "ARP monitoring cannot be used with MII monitoring. Disabling MII monitoring\n");
+			netdev_dbg(bond->dev, "ARP monitoring cannot be used with MII monitoring. Disabling MII monitoring\n");
 			bond->params.miimon = 0;
 		}
 		if (!bond->params.arp_targets[0])
-			netdev_info(bond->dev, "ARP monitoring has been set up, but no ARP targets have been specified\n");
+			netdev_dbg(bond->dev, "ARP monitoring has been set up, but no ARP targets have been specified\n");
 	}
 	if (bond->dev->flags & IFF_UP) {
 		/* If the interface is up, we may need to fire off
@@ -1000,7 +999,7 @@ static int _bond_option_arp_ip_target_add(struct bonding *bond, __be32 target)
 		return -EINVAL;
 	}
 
-	netdev_info(bond->dev, "Adding ARP target %pI4\n", &target);
+	netdev_dbg(bond->dev, "Adding ARP target %pI4\n", &target);
 
 	_bond_options_arp_ip_target_set(bond, ind, target, jiffies);
 
@@ -1036,7 +1035,7 @@ static int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target)
 	if (ind == 0 && !targets[1] && bond->params.arp_interval)
 		netdev_warn(bond->dev, "Removing last arp target with arp_interval on\n");
 
-	netdev_info(bond->dev, "Removing ARP target %pI4\n", &target);
+	netdev_dbg(bond->dev, "Removing ARP target %pI4\n", &target);
 
 	bond_for_each_slave(bond, slave, iter) {
 		targets_rx = slave->target_last_arp_rx;
@@ -1088,8 +1087,8 @@ static int bond_option_arp_ip_targets_set(struct bonding *bond,
 static int bond_option_arp_validate_set(struct bonding *bond,
 					const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting arp_validate to %s (%llu)\n",
-		    newval->string, newval->value);
+	netdev_dbg(bond->dev, "Setting arp_validate to %s (%llu)\n",
+		   newval->string, newval->value);
 
 	if (bond->dev->flags & IFF_UP) {
 		if (!newval->value)
@@ -1105,8 +1104,8 @@ static int bond_option_arp_validate_set(struct bonding *bond,
 static int bond_option_arp_all_targets_set(struct bonding *bond,
 					   const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting arp_all_targets to %s (%llu)\n",
-		    newval->string, newval->value);
+	netdev_dbg(bond->dev, "Setting arp_all_targets to %s (%llu)\n",
+		   newval->string, newval->value);
 	bond->params.arp_all_targets = newval->value;
 
 	return 0;
@@ -1126,7 +1125,7 @@ static int bond_option_primary_set(struct bonding *bond,
 		*p = '\0';
 	/* check to see if we are clearing primary */
 	if (!strlen(primary)) {
-		netdev_info(bond->dev, "Setting primary slave to None\n");
+		netdev_dbg(bond->dev, "Setting primary slave to None\n");
 		RCU_INIT_POINTER(bond->primary_slave, NULL);
 		memset(bond->params.primary, 0, sizeof(bond->params.primary));
 		bond_select_active_slave(bond);
@@ -1135,8 +1134,8 @@ static int bond_option_primary_set(struct bonding *bond,
 
 	bond_for_each_slave(bond, slave, iter) {
 		if (strncmp(slave->dev->name, primary, IFNAMSIZ) == 0) {
-			netdev_info(bond->dev, "Setting %s as primary slave\n",
-				    slave->dev->name);
+			netdev_dbg(bond->dev, "Setting %s as primary slave\n",
+				   slave->dev->name);
 			rcu_assign_pointer(bond->primary_slave, slave);
 			strcpy(bond->params.primary, slave->dev->name);
 			bond_select_active_slave(bond);
@@ -1145,15 +1144,15 @@ static int bond_option_primary_set(struct bonding *bond,
 	}
 
 	if (rtnl_dereference(bond->primary_slave)) {
-		netdev_info(bond->dev, "Setting primary slave to None\n");
+		netdev_dbg(bond->dev, "Setting primary slave to None\n");
 		RCU_INIT_POINTER(bond->primary_slave, NULL);
 		bond_select_active_slave(bond);
 	}
 	strncpy(bond->params.primary, primary, IFNAMSIZ);
 	bond->params.primary[IFNAMSIZ - 1] = 0;
 
-	netdev_info(bond->dev, "Recording %s as primary, but it has not been enslaved to %s yet\n",
-		    primary, bond->dev->name);
+	netdev_dbg(bond->dev, "Recording %s as primary, but it has not been enslaved to %s yet\n",
+		   primary, bond->dev->name);
 
 out:
 	unblock_netpoll_tx();
@@ -1164,8 +1163,8 @@ static int bond_option_primary_set(struct bonding *bond,
 static int bond_option_primary_reselect_set(struct bonding *bond,
 					    const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting primary_reselect to %s (%llu)\n",
-		    newval->string, newval->value);
+	netdev_dbg(bond->dev, "Setting primary_reselect to %s (%llu)\n",
+		   newval->string, newval->value);
 	bond->params.primary_reselect = newval->value;
 
 	block_netpoll_tx();
@@ -1178,8 +1177,8 @@ static int bond_option_primary_reselect_set(struct bonding *bond,
 static int bond_option_fail_over_mac_set(struct bonding *bond,
 					 const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting fail_over_mac to %s (%llu)\n",
-		    newval->string, newval->value);
+	netdev_dbg(bond->dev, "Setting fail_over_mac to %s (%llu)\n",
+		   newval->string, newval->value);
 	bond->params.fail_over_mac = newval->value;
 
 	return 0;
@@ -1188,8 +1187,8 @@ static int bond_option_fail_over_mac_set(struct bonding *bond,
 static int bond_option_xmit_hash_policy_set(struct bonding *bond,
 					    const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting xmit hash policy to %s (%llu)\n",
-		    newval->string, newval->value);
+	netdev_dbg(bond->dev, "Setting xmit hash policy to %s (%llu)\n",
+		   newval->string, newval->value);
 	bond->params.xmit_policy = newval->value;
 
 	return 0;
@@ -1198,8 +1197,8 @@ static int bond_option_xmit_hash_policy_set(struct bonding *bond,
 static int bond_option_resend_igmp_set(struct bonding *bond,
 				       const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting resend_igmp to %llu\n",
-		    newval->value);
+	netdev_dbg(bond->dev, "Setting resend_igmp to %llu\n",
+		   newval->value);
 	bond->params.resend_igmp = newval->value;
 
 	return 0;
@@ -1237,8 +1236,8 @@ static int bond_option_all_slaves_active_set(struct bonding *bond,
 static int bond_option_min_links_set(struct bonding *bond,
 				     const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting min links value to %llu\n",
-		    newval->value);
+	netdev_dbg(bond->dev, "Setting min links value to %llu\n",
+		   newval->value);
 	bond->params.min_links = newval->value;
 	bond_set_carrier(bond);
 
@@ -1256,6 +1255,8 @@ static int bond_option_lp_interval_set(struct bonding *bond,
 static int bond_option_pps_set(struct bonding *bond,
 			       const struct bond_opt_value *newval)
 {
+	netdev_dbg(bond->dev, "Setting packets per slave to %d\n",
+		   newval->value);
 	bond->params.packets_per_slave = newval->value;
 	if (newval->value > 0) {
 		bond->params.reciprocal_packets_per_slave =
@@ -1274,8 +1275,8 @@ static int bond_option_pps_set(struct bonding *bond,
 static int bond_option_lacp_rate_set(struct bonding *bond,
 				     const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting LACP rate to %s (%llu)\n",
-		    newval->string, newval->value);
+	netdev_dbg(bond->dev, "Setting LACP rate to %s (%llu)\n",
+		   newval->string, newval->value);
 	bond->params.lacp_fast = newval->value;
 	bond_3ad_update_lacp_rate(bond);
 
@@ -1285,8 +1286,8 @@ static int bond_option_lacp_rate_set(struct bonding *bond,
 static int bond_option_ad_select_set(struct bonding *bond,
 				     const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting ad_select to %s (%llu)\n",
-		    newval->string, newval->value);
+	netdev_dbg(bond->dev, "Setting ad_select to %s (%llu)\n",
+		   newval->string, newval->value);
 	bond->params.ad_select = newval->value;
 
 	return 0;
@@ -1377,12 +1378,12 @@ static int bond_option_slaves_set(struct bonding *bond,
 
 	switch (command[0]) {
 	case '+':
-		netdev_info(bond->dev, "Adding slave %s\n", dev->name);
+		netdev_dbg(bond->dev, "Adding slave %s\n", dev->name);
 		ret = bond_enslave(bond->dev, dev);
 		break;
 
 	case '-':
-		netdev_info(bond->dev, "Removing slave %s\n", dev->name);
+		netdev_dbg(bond->dev, "Removing slave %s\n", dev->name);
 		ret = bond_release(bond->dev, dev);
 		break;
 
@@ -1402,8 +1403,8 @@ static int bond_option_slaves_set(struct bonding *bond,
 static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
 					  const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting dynamic-lb to %s (%llu)\n",
-		    newval->string, newval->value);
+	netdev_dbg(bond->dev, "Setting dynamic-lb to %s (%llu)\n",
+		   newval->string, newval->value);
 	bond->params.tlb_dynamic_lb = newval->value;
 
 	return 0;
@@ -1412,8 +1413,8 @@ static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
 static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
 					     const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting ad_actor_sys_prio to %llu\n",
-		    newval->value);
+	netdev_dbg(bond->dev, "Setting ad_actor_sys_prio to %llu\n",
+		   newval->value);
 
 	bond->params.ad_actor_sys_prio = newval->value;
 	bond_3ad_update_ad_actor_settings(bond);
@@ -1442,7 +1443,7 @@ static int bond_option_ad_actor_system_set(struct bonding *bond,
 	if (!is_valid_ether_addr(mac))
 		goto err;
 
-	netdev_info(bond->dev, "Setting ad_actor_system to %pM\n", mac);
+	netdev_dbg(bond->dev, "Setting ad_actor_system to %pM\n", mac);
 	ether_addr_copy(bond->params.ad_actor_system, mac);
 	bond_3ad_update_ad_actor_settings(bond);
 
@@ -1456,8 +1457,8 @@ static int bond_option_ad_actor_system_set(struct bonding *bond,
 static int bond_option_ad_user_port_key_set(struct bonding *bond,
 					    const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting ad_user_port_key to %llu\n",
-		    newval->value);
+	netdev_dbg(bond->dev, "Setting ad_user_port_key to %llu\n",
+		   newval->value);
 
 	bond->params.ad_user_port_key = newval->value;
 	return 0;
