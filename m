From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 1/5] bonding: remove bond read lock for bond_mii_monitor()
Date: Thu, 24 Oct 2013 11:09:03 +0800
Message-ID: <52688F4F.2080204@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:6024 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041Ab3JXDJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 23:09:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond slave list may change when the monitor is running, the slave list is no longer
protected by bond->lock, only protected by rtnl lock(), so we has 3 way to modify it:
1.add bond_master_upper_dev_link() and bond_upper_dev_unlink() in bond->lock, but it is unsafe
to call call_netdevice_notifiers() in write lock.
2.remove unused bond->lock for monitor function, only use the exist rtnl lock().
3.use rcu_read_lock() to protect it, of course, it will transform bond_for_each_slave to
bond_for_each_slave_rcu() and performance is better, but in slow path, it is ignored.
so I remove the bond->lock and move the rtnl lock to protect the whole monitor function.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 44 +++++++++++------------------------------
 1 file changed, 12 insertions(+), 32 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d90734f..ba90f45 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2155,49 +2155,29 @@ void bond_mii_monitor(struct work_struct *work)
 	struct bonding *bond = container_of(work, struct bonding,
 					    mii_work.work);
 	bool should_notify_peers = false;
-	unsigned long delay;
 
-	read_lock(&bond->lock);
-
-	delay = msecs_to_jiffies(bond->params.miimon);
+	if (!rtnl_trylock())
+		goto re_arm;
 
-	if (!bond_has_slaves(bond))
+	if (!bond_has_slaves(bond)) {
+		rtnl_unlock();
 		goto re_arm;
+	}
 
 	should_notify_peers = bond_should_notify_peers(bond);
 
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
-
-		read_lock(&bond->lock);
-
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
-		queue_delayed_work(bond->wq, &bond->mii_work, delay);
-
-	read_unlock(&bond->lock);
-
-	if (should_notify_peers) {
-		if (!rtnl_trylock())
-			return;
-		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
-		rtnl_unlock();
-	}
+		queue_delayed_work(bond->wq, &bond->mii_work,
+				msecs_to_jiffies(bond->params.miimon));
 }
 
 static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
-- 
1.8.2.1
