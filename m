From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/9] bonding: remove bond read lock for bond_mii_monitor()
Date: Wed, 6 Nov 2013 14:52:40 +0800
Message-ID: <5279E738.4040102@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:13175 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916Ab3KFGyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 01:54:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_mii_monitor() still use bond lock read to protect
bond_has_slaves() and bond_miimon_inspect(), it is no effect,
so I move the RTNL to the top of the function to protect the
whole monitor, of course, if the bond state did not changed,
the monitor still calling RTNL, it may bring more performance
loss, but as a slow path, it is negligible.

also in bond_miimon_commit(), I remove the unwanted curr_slave_lock
when calling the bond_select_active_slave(), the RTNL is enough.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 44 ++++++++++++-----------------------------
 1 file changed, 13 insertions(+), 31 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9c9803c..98171eb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2074,9 +2074,7 @@ static void bond_miimon_commit(struct bonding *bond)
 do_failover:
 		ASSERT_RTNL();
 		block_netpoll_tx();
-		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
-		write_unlock_bh(&bond->curr_slave_lock);
 		unblock_netpoll_tx();
 	}
 
@@ -2098,47 +2096,31 @@ void bond_mii_monitor(struct work_struct *work)
 	bool should_notify_peers = false;
 	unsigned long delay;
 
-	read_lock(&bond->lock);
-
 	delay = msecs_to_jiffies(bond->params.miimon);
 
-	if (!bond_has_slaves(bond))
+	if (!rtnl_trylock()) {
+		delay = 1;
 		goto re_arm;
+	}
 
-	should_notify_peers = bond_should_notify_peers(bond);
-
-	if (bond_miimon_inspect(bond)) {
-		read_unlock(&bond->lock);
-
-		/* Race avoidance with bond_close cancel of workqueue */
-		if (!rtnl_trylock()) {
-			read_lock(&bond->lock);
-			delay = 1;
-			should_notify_peers = false;
-			goto re_arm;
-		}
+	if (!bond_has_slaves(bond)) {
+		rtnl_unlock();
+		goto re_arm;
+	}
 
-		read_lock(&bond->lock);
+	should_notify_peers = bond_should_notify_peers(bond);
 
+	if (bond_miimon_inspect(bond))
 		bond_miimon_commit(bond);
 
-		read_unlock(&bond->lock);
-		rtnl_unlock();	/* might sleep, hold no other locks */
-		read_lock(&bond->lock);
-	}
+	if (should_notify_peers)
+		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
+
+	rtnl_unlock();
 
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
