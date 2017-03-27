From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 2/5] bonding: improve link-status update in mii-monitoring
Date: Mon, 27 Mar 2017 11:37:33 -0700
Message-ID: <20170327183733.30854-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33928 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751413AbdC0Shq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:37:46 -0400
Received: by mail-pg0-f68.google.com with SMTP id o123so12250965pga.1
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:37:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

The primary issue is that mii-inspect phase updates link-state and
expects changes to be committed during the mii-commit phase. After
the inspect phase if it fails to acquire rtnl-mutex, the commit
phase (bond_mii_commit) doesn't get to run. This partially updated
state stays and makes the internal-state inconsistent.

e.g. setup bond0 => slaves: eth1, eth2
eth1 goes DOWN -> UP
   mii_monitor()
	mii-inspect()
	    bond_set_slave_link_state(eth1, UP, DontNotify)
	rtnl_trylock() <- fails!

Next mii-monitor round
eth1: No change
   mii_monitor()
	mii-inspect()
	    eth1->link == current-status (ethtool_ops->get_link)
	    no-change-detected

End result:
    eth1:
      Link = BOND_LINK_UP
      Speed = 0xfffff  [SpeedUnknown]
      Duplex = 0xff    [DuplexUnknown]

This doesn't always happen but for some unlucky machines in a large set
of machines it creates problems.

The fix for this is to avoid making changes during inspect phase and
postpone them until acquiring the rtnl-mutex / invoking commit phase.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ba934020dfaa..85999e479916 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2033,8 +2033,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 			if (link_state)
 				continue;
 
-			bond_set_slave_link_state(slave, BOND_LINK_FAIL,
-						  BOND_SLAVE_NOTIFY_LATER);
+			bond_propose_link_state(slave, BOND_LINK_FAIL);
 			slave->delay = bond->params.downdelay;
 			if (slave->delay) {
 				netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
@@ -2049,8 +2048,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 		case BOND_LINK_FAIL:
 			if (link_state) {
 				/* recovered before downdelay expired */
-				bond_set_slave_link_state(slave, BOND_LINK_UP,
-							  BOND_SLAVE_NOTIFY_LATER);
+				bond_propose_link_state(slave, BOND_LINK_UP);
 				slave->last_link_up = jiffies;
 				netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
 					    (bond->params.downdelay - slave->delay) *
@@ -2072,8 +2070,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 			if (!link_state)
 				continue;
 
-			bond_set_slave_link_state(slave, BOND_LINK_BACK,
-						  BOND_SLAVE_NOTIFY_LATER);
+			bond_propose_link_state(slave, BOND_LINK_BACK);
 			slave->delay = bond->params.updelay;
 
 			if (slave->delay) {
@@ -2086,9 +2083,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 			/*FALLTHRU*/
 		case BOND_LINK_BACK:
 			if (!link_state) {
-				bond_set_slave_link_state(slave,
-							  BOND_LINK_DOWN,
-							  BOND_SLAVE_NOTIFY_LATER);
+				bond_propose_link_state(slave, BOND_LINK_DOWN);
 				netdev_info(bond->dev, "link status down again after %d ms for interface %s\n",
 					    (bond->params.updelay - slave->delay) *
 					    bond->params.miimon,
@@ -2225,6 +2220,8 @@ static void bond_mii_monitor(struct work_struct *work)
 					    mii_work.work);
 	bool should_notify_peers = false;
 	unsigned long delay;
+	struct slave *slave;
+	struct list_head *iter;
 
 	delay = msecs_to_jiffies(bond->params.miimon);
 
@@ -2245,6 +2242,9 @@ static void bond_mii_monitor(struct work_struct *work)
 			goto re_arm;
 		}
 
+		bond_for_each_slave(bond, slave, iter) {
+			bond_commit_link_state(slave, BOND_SLAVE_NOTIFY_LATER);
+		}
 		bond_miimon_commit(bond);
 
 		rtnl_unlock();	/* might sleep, hold no other locks */
-- 
2.12.1.578.ge9c3154ca4-goog
