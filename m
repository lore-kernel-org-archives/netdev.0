From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v5 2/11] bonding: rebuild the lock use for bond_mii_monitor()
Date: Wed, 11 Dec 2013 13:00:34 +0800
Message-ID: <52A7F172.5010004@huawei.com>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:34271 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265Ab3LKFFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 00:05:35 -0500
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
if the curr_active_slave changed, as the rcu dereference need in
read-side critical sector and bond_change_active_slave() will call
it with no RCU hold,  so add peer notify in rcu_read_lock which
will be nested in monitor.

Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7d007d1..93b6eaa 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -815,7 +815,11 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
 
 static bool bond_should_notify_peers(struct bonding *bond)
 {
-	struct slave *slave = bond->curr_active_slave;
+	struct slave *slave;
+
+	rcu_read_lock();
+	slave = rcu_dereference(bond->curr_active_slave);
+	rcu_read_unlock();
 
 	pr_debug("bond_should_notify_peers: bond %s slave %s\n",
 		 bond->dev->name, slave ? slave->dev->name : "NULL");
@@ -1919,7 +1923,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 
 	ignore_updelay = !bond->curr_active_slave ? true : false;
 
-	bond_for_each_slave(bond, slave, iter) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		slave->new_link = BOND_LINK_NOCHANGE;
 
 		link_state = bond_check_dev_link(bond, slave->dev, 0);
@@ -2117,41 +2121,35 @@ void bond_mii_monitor(struct work_struct *work)
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
 			should_notify_peers = false;
 			goto re_arm;
 		}
 
-		read_lock(&bond->lock);
-
 		bond_miimon_commit(bond);
 
-		read_unlock(&bond->lock);
 		rtnl_unlock();	/* might sleep, hold no other locks */
-		read_lock(&bond->lock);
-	}
+	} else
+		rcu_read_unlock();
 
 re_arm:
 	if (bond->params.miimon)
 		queue_delayed_work(bond->wq, &bond->mii_work, delay);
 
-	read_unlock(&bond->lock);
-
 	if (should_notify_peers) {
 		if (!rtnl_trylock())
 			return;
-- 
1.8.0
