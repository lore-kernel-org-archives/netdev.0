From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 2/10] bonding: rebuild the lock use for bond_mii_monitor()
Date: Mon, 11 Nov 2013 20:36:26 +0800
Message-ID: <5280CF4A.2090103@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:55124 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768Ab3KKMhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 07:37:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_mii_monitor() still use bond lock to protect bond slave list,
it is no effect, I have 2 way to fix the problem, move the RTNL to the
top of the function, or add RCU to protect the bond slave list,
according to the Jay Vosburgh's opinion, 10 times one second is a
truely big performance loss if use RTNL to protect the whole monitor,
so I would take the advice and use RCU to protect the bond slave list.

The bond_has_slave() will not protect by anything, there will no things
happen if the slave list is be changed, unless the bond was free, but
it will not happened before the monitor, the bond will closed before
be freed.

The peers notify for the bond will calling curr_active_slave, so
derefence the slave to make sure we will accessing the same slave
if the curr_active_slave changed.

I move the peer notify before the queue_delayed_work(), and obviously
it is no need to lock the RTNL twice if call bond_miimon_commit() and
peer notify together, other path is no logic change, I think the
performance is better than before.

Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 38 ++++++++++++++++++--------------------
 1 file changed, 18 insertions(+), 20 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f5145ea..ccec68f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -815,7 +815,7 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
 
 static bool bond_should_notify_peers(struct bonding *bond)
 {
-	struct slave *slave = bond->curr_active_slave;
+	struct slave *slave = rcu_dereference(bond->curr_active_slave);
 
 	pr_debug("bond_should_notify_peers: bond %s slave %s\n",
 		 bond->dev->name, slave ? slave->dev->name : "NULL");
@@ -1919,7 +1919,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 
 	ignore_updelay = !bond->curr_active_slave ? true : false;
 
-	bond_for_each_slave(bond, slave, iter) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		slave->new_link = BOND_LINK_NOCHANGE;
 
 		link_state = bond_check_dev_link(bond, slave->dev, 0);
@@ -2117,47 +2117,45 @@ void bond_mii_monitor(struct work_struct *work)
 	bool should_notify_peers = false;
 	unsigned long delay;
 
-	read_lock(&bond->lock);
-
 	delay = msecs_to_jiffies(bond->params.miimon);
 
 	if (!bond_has_slaves(bond))
 		goto re_arm;
 
+	rcu_read_lock();
+
 	should_notify_peers = bond_should_notify_peers(bond);
 
 	if (bond_miimon_inspect(bond)) {
-		read_unlock(&bond->lock);
+		rcu_read_unlock();
 
 		/* Race avoidance with bond_close cancel of workqueue */
 		if (!rtnl_trylock()) {
-			read_lock(&bond->lock);
 			delay = 1;
-			should_notify_peers = false;
 			goto re_arm;
 		}
 
-		read_lock(&bond->lock);
-
 		bond_miimon_commit(bond);
 
-		read_unlock(&bond->lock);
+		if (should_notify_peers)
+			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
+					bond->dev);
+
 		rtnl_unlock();	/* might sleep, hold no other locks */
-		read_lock(&bond->lock);
+	} else {
+		rcu_read_unlock();
+		if (should_notify_peers) {
+			if (!rtnl_trylock())
+				goto re_arm;
+			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
+					bond->dev);
+			rtnl_unlock();
+		}
 	}
 
 re_arm:
 	if (bond->params.miimon)
 		queue_delayed_work(bond->wq, &bond->mii_work, delay);
-
-	read_unlock(&bond->lock);
-
-	if (should_notify_peers) {
-		if (!rtnl_trylock())
-			return;
-		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
-		rtnl_unlock();
-	}
 }
 
 static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
-- 
1.8.2.1
