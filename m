From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: [RFC PATCH net-next] bonding: Use notifiers for slave link state detection
Date: Thu, 07 Jan 2016 17:28:35 -0800
Message-ID: <27321.1452216515@famine>
References: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com> <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com> <16587.1452148421@famine>
Cc: mkubecek@suse.cz, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, boris.shteinbock@windriver.com
To: zyjzyj2000@gmail.com, emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46880 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682AbcAHB2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 20:28:43 -0500
In-reply-to: <16587.1452148421@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	TEST PATCH

	This patch modifies bonding to utilize notifier callbacks to
detect slave link state changes.  It is intended to be used with miimon
set to zero, and does not support the updelay or downdelay options to
bonding.  It's not as complicated as it looks; most of the change set is
to break out the inner loop of bond_miimon_inspect into its own
function.

	Yanjun, can you test this with miimon=0 and see if it changes
the behavior you're seeing?

	Thanks,

	-J


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index cab99fd..6fe68b1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2012,104 +2012,103 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 /*-------------------------------- Monitoring -------------------------------*/
 
 /* called with rcu_read_lock() */
-static int bond_miimon_inspect(struct bonding *bond)
+static int bond_miimon_inspect_slave(struct bonding *bond, struct slave *slave)
 {
-	int link_state, commit = 0;
-	struct list_head *iter;
-	struct slave *slave;
+	int link_state;
 	bool ignore_updelay;
 
 	ignore_updelay = !rcu_dereference(bond->curr_active_slave);
 
-	bond_for_each_slave_rcu(bond, slave, iter) {
-		slave->new_link = BOND_LINK_NOCHANGE;
+	slave->new_link = BOND_LINK_NOCHANGE;
 
-		link_state = bond_check_dev_link(bond, slave->dev, 0);
+	link_state = bond_check_dev_link(bond, slave->dev, 0);
 
-		switch (slave->link) {
-		case BOND_LINK_UP:
-			if (link_state)
-				continue;
+	switch (slave->link) {
+	case BOND_LINK_UP:
+		if (link_state)
+			return 0;
 
-			bond_set_slave_link_state(slave, BOND_LINK_FAIL,
+		bond_set_slave_link_state(slave, BOND_LINK_FAIL,
+					  BOND_SLAVE_NOTIFY_LATER);
+		slave->delay = bond->params.downdelay;
+		if (slave->delay) {
+			netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
+				    (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP) ?
+				    (bond_is_active_slave(slave) ?
+				     "active " : "backup ") : "",
+				    slave->dev->name,
+				    bond->params.downdelay * bond->params.miimon);
+		}
+		/*FALLTHRU*/
+	case BOND_LINK_FAIL:
+		if (link_state) {
+			/* recovered before downdelay expired */
+			bond_set_slave_link_state(slave, BOND_LINK_UP,
 						  BOND_SLAVE_NOTIFY_LATER);
-			slave->delay = bond->params.downdelay;
-			if (slave->delay) {
-				netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
-					    (BOND_MODE(bond) ==
-					     BOND_MODE_ACTIVEBACKUP) ?
-					     (bond_is_active_slave(slave) ?
-					      "active " : "backup ") : "",
-					    slave->dev->name,
-					    bond->params.downdelay * bond->params.miimon);
-			}
-			/*FALLTHRU*/
-		case BOND_LINK_FAIL:
-			if (link_state) {
-				/* recovered before downdelay expired */
-				bond_set_slave_link_state(slave, BOND_LINK_UP,
-							  BOND_SLAVE_NOTIFY_LATER);
-				slave->last_link_up = jiffies;
-				netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
-					    (bond->params.downdelay - slave->delay) *
-					    bond->params.miimon,
-					    slave->dev->name);
-				continue;
-			}
+			slave->last_link_up = jiffies;
+			netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
+				    (bond->params.downdelay - slave->delay) *
+				    bond->params.miimon, slave->dev->name);
+			return 0;
+		}
 
-			if (slave->delay <= 0) {
-				slave->new_link = BOND_LINK_DOWN;
-				commit++;
-				continue;
-			}
+		if (slave->delay <= 0) {
+			slave->new_link = BOND_LINK_DOWN;
+			return 1;
+		}
 
-			slave->delay--;
-			break;
+		slave->delay--;
+		break;
 
-		case BOND_LINK_DOWN:
-			if (!link_state)
-				continue;
+	case BOND_LINK_DOWN:
+		if (!link_state)
+			return 0;
 
-			bond_set_slave_link_state(slave, BOND_LINK_BACK,
-						  BOND_SLAVE_NOTIFY_LATER);
-			slave->delay = bond->params.updelay;
-
-			if (slave->delay) {
-				netdev_info(bond->dev, "link status up for interface %s, enabling it in %d ms\n",
-					    slave->dev->name,
-					    ignore_updelay ? 0 :
-					    bond->params.updelay *
-					    bond->params.miimon);
-			}
-			/*FALLTHRU*/
-		case BOND_LINK_BACK:
-			if (!link_state) {
-				bond_set_slave_link_state(slave,
-							  BOND_LINK_DOWN,
-							  BOND_SLAVE_NOTIFY_LATER);
-				netdev_info(bond->dev, "link status down again after %d ms for interface %s\n",
-					    (bond->params.updelay - slave->delay) *
-					    bond->params.miimon,
-					    slave->dev->name);
+		bond_set_slave_link_state(slave, BOND_LINK_BACK,
+					  BOND_SLAVE_NOTIFY_LATER);
+		slave->delay = bond->params.updelay;
 
-				continue;
-			}
+		if (slave->delay) {
+			netdev_info(bond->dev, "link status up for interface %s, enabling it in %d ms\n",
+				    slave->dev->name, ignore_updelay ? 0 :
+				    bond->params.updelay * bond->params.miimon);
+		}
+		/*FALLTHRU*/
+	case BOND_LINK_BACK:
+		if (!link_state) {
+			bond_set_slave_link_state(slave, BOND_LINK_DOWN,
+						  BOND_SLAVE_NOTIFY_LATER);
+			netdev_info(bond->dev, "link status down again after %d ms for interface %s\n",
+				    (bond->params.updelay - slave->delay) *
+				    bond->params.miimon, slave->dev->name);
 
-			if (ignore_updelay)
-				slave->delay = 0;
+			return 0;
+		}
 
-			if (slave->delay <= 0) {
-				slave->new_link = BOND_LINK_UP;
-				commit++;
-				ignore_updelay = false;
-				continue;
-			}
+		if (ignore_updelay)
+			slave->delay = 0;
 
-			slave->delay--;
-			break;
+		if (slave->delay <= 0) {
+			slave->new_link = BOND_LINK_UP;
+			return 1;
 		}
+
+		slave->delay--;
+		break;
 	}
 
+	return 0;
+}
+
+static int bond_miimon_inspect(struct bonding *bond)
+{
+	struct list_head *iter;
+	struct slave *slave;
+	int commit = 0;
+
+	bond_for_each_slave_rcu(bond, slave, iter)
+		commit += bond_miimon_inspect_slave(bond, slave);
+
 	return commit;
 }
 
@@ -3016,6 +3015,9 @@ static int bond_slave_netdev_event(unsigned long event,
 			bond_3ad_adapter_speed_duplex_changed(slave);
 		/* Fallthrough */
 	case NETDEV_DOWN:
+		if (bond_miimon_inspect_slave(bond, slave))
+			bond_miimon_commit(bond);
+
 		/* Refresh slave-array if applicable!
 		 * If the setup does not use miimon or arpmon (mode-specific!),
 		 * then these events will not cause the slave-array to be


---
	-Jay Vosburgh, jay.vosburgh@canonical.com
