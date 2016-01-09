From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [RFC PATCH net-next] bonding: Use notifiers for slave link state detection
Date: Fri, 08 Jan 2016 18:19:38 -0800
Message-ID: <11809.1452305978@famine>
References: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com> <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com> <16587.1452148421@famine> <27321.1452216515@famine> <87618083B2453E4A8714035B62D6799250505491@FMSMSX105.amr.corp.intel.com>
Cc: "zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>,
	"mkubecek@suse.cz" <mkubecek@suse.cz>,
	"vfalico@gmail.com" <vfalico@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:59907 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753646AbcAICTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 21:19:47 -0500
In-reply-to: <87618083B2453E4A8714035B62D6799250505491@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tantilov, Emil S <emil.s.tantilov@intel.com> wrote:

>>-----Original Message-----
>From: Jay Vosburgh [mailto:jay.vosburgh@canonical.com]
>>Sent: Thursday, January 07, 2016 5:29 PM
>>Subject: [RFC PATCH net-next] bonding: Use notifiers for slave link state
>>detection
>>
>>
>>	TEST PATCH
>>
>>	This patch modifies bonding to utilize notifier callbacks to
>>detect slave link state changes.  It is intended to be used with miimon
>>set to zero, and does not support the updelay or downdelay options to
>>bonding.  It's not as complicated as it looks; most of the change set is
>>to break out the inner loop of bond_miimon_inspect into its own
>>function.
>
>Jay,
> 
>I managed to do a quick test with this patch and occasionally there is
>a case where I see the bonding driver reporting link up for an
>interface (eth1) that is not up just yet:
[...]
>[12985.213752] ixgbe 0000:01:00.0 eth0: NIC Link is Up 10 Gbps, Flow Control: RX/TX
>[12985.213970] bond0: link status definitely up for interface eth0, 10000 Mbps full duplex
>[12985.213975] bond0: link status definitely up for interface eth1, 0 Mbps full duplex

	Thanks for testing; the misbehavior is because I cheaped out and
didn't break out the commit function into a "single slave" version.  The
below patch (against net-next, replacing the original patch) shouldn't
generate the erroneous additional link messages any more.

	This does generate an RCU warning, although the code actually is
safe (since the notifier callback holds RTNL); I'll sort that out next
week.

	-J


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index cab99fd..12dd533 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2012,203 +2012,206 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
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
 
-	return commit;
+	return 0;
 }
 
-static void bond_miimon_commit(struct bonding *bond)
+static int bond_miimon_inspect(struct bonding *bond)
 {
 	struct list_head *iter;
-	struct slave *slave, *primary;
+	struct slave *slave;
+	int commit = 0;
 
-	bond_for_each_slave(bond, slave, iter) {
-		switch (slave->new_link) {
-		case BOND_LINK_NOCHANGE:
-			continue;
+	bond_for_each_slave_rcu(bond, slave, iter)
+		commit += bond_miimon_inspect_slave(bond, slave);
 
-		case BOND_LINK_UP:
-			bond_set_slave_link_state(slave, BOND_LINK_UP,
-						  BOND_SLAVE_NOTIFY_NOW);
-			slave->last_link_up = jiffies;
+	return commit;
+}
 
-			primary = rtnl_dereference(bond->primary_slave);
-			if (BOND_MODE(bond) == BOND_MODE_8023AD) {
-				/* prevent it from being the active one */
-				bond_set_backup_slave(slave);
-			} else if (BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
-				/* make it immediately active */
-				bond_set_active_slave(slave);
-			} else if (slave != primary) {
-				/* prevent it from being the active one */
-				bond_set_backup_slave(slave);
-			}
+static void bond_miimon_commit_slave(struct bonding *bond, struct slave *slave)
+{
+	struct slave *primary;
 
-			netdev_info(bond->dev, "link status definitely up for interface %s, %u Mbps %s duplex\n",
-				    slave->dev->name,
-				    slave->speed == SPEED_UNKNOWN ? 0 : slave->speed,
-				    slave->duplex ? "full" : "half");
+	switch (slave->new_link) {
+	case BOND_LINK_NOCHANGE:
+		return;
 
-			/* notify ad that the link status has changed */
-			if (BOND_MODE(bond) == BOND_MODE_8023AD)
-				bond_3ad_handle_link_change(slave, BOND_LINK_UP);
+	case BOND_LINK_UP:
+		bond_set_slave_link_state(slave, BOND_LINK_UP,
+					  BOND_SLAVE_NOTIFY_NOW);
+		slave->last_link_up = jiffies;
 
-			if (bond_is_lb(bond))
-				bond_alb_handle_link_change(bond, slave,
-							    BOND_LINK_UP);
+		primary = rtnl_dereference(bond->primary_slave);
+		if (BOND_MODE(bond) == BOND_MODE_8023AD) {
+			/* prevent it from being the active one */
+			bond_set_backup_slave(slave);
+		} else if (BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
+			/* make it immediately active */
+			bond_set_active_slave(slave);
+		} else if (slave != primary) {
+			/* prevent it from being the active one */
+			bond_set_backup_slave(slave);
+		}
 
-			if (BOND_MODE(bond) == BOND_MODE_XOR)
-				bond_update_slave_arr(bond, NULL);
+		netdev_info(bond->dev, "link status definitely up for interface %s, %u Mbps %s duplex\n",
+			    slave->dev->name,
+			    slave->speed == SPEED_UNKNOWN ? 0 : slave->speed,
+			    slave->duplex ? "full" : "half");
 
-			if (!bond->curr_active_slave || slave == primary)
-				goto do_failover;
+		/* notify ad that the link status has changed */
+		if (BOND_MODE(bond) == BOND_MODE_8023AD)
+			bond_3ad_handle_link_change(slave, BOND_LINK_UP);
 
-			continue;
+		if (bond_is_lb(bond))
+			bond_alb_handle_link_change(bond, slave, BOND_LINK_UP);
 
-		case BOND_LINK_DOWN:
-			if (slave->link_failure_count < UINT_MAX)
-				slave->link_failure_count++;
+		if (BOND_MODE(bond) == BOND_MODE_XOR)
+			bond_update_slave_arr(bond, NULL);
 
-			bond_set_slave_link_state(slave, BOND_LINK_DOWN,
-						  BOND_SLAVE_NOTIFY_NOW);
+		if (!bond->curr_active_slave || slave == primary)
+			goto do_failover;
 
-			if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP ||
-			    BOND_MODE(bond) == BOND_MODE_8023AD)
-				bond_set_slave_inactive_flags(slave,
-							      BOND_SLAVE_NOTIFY_NOW);
+		goto out;
 
-			netdev_info(bond->dev, "link status definitely down for interface %s, disabling it\n",
-				    slave->dev->name);
+	case BOND_LINK_DOWN:
+		if (slave->link_failure_count < UINT_MAX)
+			slave->link_failure_count++;
 
-			if (BOND_MODE(bond) == BOND_MODE_8023AD)
-				bond_3ad_handle_link_change(slave,
-							    BOND_LINK_DOWN);
+		bond_set_slave_link_state(slave, BOND_LINK_DOWN,
+					  BOND_SLAVE_NOTIFY_NOW);
 
-			if (bond_is_lb(bond))
-				bond_alb_handle_link_change(bond, slave,
-							    BOND_LINK_DOWN);
+		if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP ||
+		    BOND_MODE(bond) == BOND_MODE_8023AD)
+			bond_set_slave_inactive_flags(slave,
+						      BOND_SLAVE_NOTIFY_NOW);
 
-			if (BOND_MODE(bond) == BOND_MODE_XOR)
-				bond_update_slave_arr(bond, NULL);
+		netdev_info(bond->dev, "link status definitely down for interface %s, disabling it\n",
+			    slave->dev->name);
 
-			if (slave == rcu_access_pointer(bond->curr_active_slave))
-				goto do_failover;
+		if (BOND_MODE(bond) == BOND_MODE_8023AD)
+			bond_3ad_handle_link_change(slave, BOND_LINK_DOWN);
 
-			continue;
+		if (bond_is_lb(bond))
+			bond_alb_handle_link_change(bond, slave, BOND_LINK_DOWN);
 
-		default:
-			netdev_err(bond->dev, "invalid new link %d on slave %s\n",
-				   slave->new_link, slave->dev->name);
-			slave->new_link = BOND_LINK_NOCHANGE;
+		if (BOND_MODE(bond) == BOND_MODE_XOR)
+			bond_update_slave_arr(bond, NULL);
 
-			continue;
-		}
+		if (slave == rcu_access_pointer(bond->curr_active_slave))
+			goto do_failover;
 
-do_failover:
-		block_netpoll_tx();
-		bond_select_active_slave(bond);
-		unblock_netpoll_tx();
+		goto out;
+
+	default:
+		netdev_err(bond->dev, "invalid new link %d on slave %s\n",
+			   slave->new_link, slave->dev->name);
+		slave->new_link = BOND_LINK_NOCHANGE;
+
+		goto out;
 	}
 
+do_failover:
+	block_netpoll_tx();
+	bond_select_active_slave(bond);
+	unblock_netpoll_tx();
+
+out:
 	bond_set_carrier(bond);
 }
 
+static void bond_miimon_commit(struct bonding *bond)
+{
+	struct list_head *iter;
+	struct slave *slave;
+
+	bond_for_each_slave(bond, slave, iter)
+		bond_miimon_commit_slave(bond, slave);
+}
+
 /* bond_mii_monitor
  *
  * Really a wrapper that splits the mii monitor into two phases: an
@@ -3016,6 +3019,9 @@ static int bond_slave_netdev_event(unsigned long event,
 			bond_3ad_adapter_speed_duplex_changed(slave);
 		/* Fallthrough */
 	case NETDEV_DOWN:
+		if (bond_miimon_inspect_slave(bond, slave))
+			bond_miimon_commit_slave(bond, slave);
+
 		/* Refresh slave-array if applicable!
 		 * If the setup does not use miimon or arpmon (mode-specific!),
 		 * then these events will not cause the slave-array to be


---
	-Jay Vosburgh, jay.vosburgh@canonical.com
