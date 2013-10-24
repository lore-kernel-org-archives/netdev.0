From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 4/5] bonding: remove bond read lock for bond_activebackup_arp_mon()
Date: Thu, 24 Oct 2013 11:09:25 +0800
Message-ID: <52688F65.3080507@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:38980 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045Ab3JXDLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 23:11:19 -0400
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
 drivers/net/bonding/bond_main.c | 46 ++++++++++++-----------------------------
 1 file changed, 13 insertions(+), 33 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 149f4b9..f3df532 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2763,51 +2763,31 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 	struct bonding *bond = container_of(work, struct bonding,
 					    arp_work.work);
 	bool should_notify_peers = false;
-	int delta_in_ticks;
 
-	read_lock(&bond->lock);
-
-	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
+	if (!rtnl_trylock())
+		goto re_arm;
 
-	if (!bond_has_slaves(bond))
+	if (!bond_has_slaves(bond)) {
+		rtnl_unlock();
 		goto re_arm;
+	}
 
 	should_notify_peers = bond_should_notify_peers(bond);
 
-	if (bond_ab_arp_inspect(bond)) {
-		read_unlock(&bond->lock);
-
-		/* Race avoidance with bond_close flush of workqueue */
-		if (!rtnl_trylock()) {
-			read_lock(&bond->lock);
-			delta_in_ticks = 1;
-			should_notify_peers = false;
-			goto re_arm;
-		}
-
-		read_lock(&bond->lock);
-
+	if (bond_ab_arp_inspect(bond))
 		bond_ab_arp_commit(bond);
 
-		read_unlock(&bond->lock);
-		rtnl_unlock();
-		read_lock(&bond->lock);
-	}
-
 	bond_ab_arp_probe(bond);
 
-re_arm:
-	if (bond->params.arp_interval)
-		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
+	if (should_notify_peers)
+		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
 
-	read_unlock(&bond->lock);
+	rtnl_unlock();
 
-	if (should_notify_peers) {
-		if (!rtnl_trylock())
-			return;
-		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
-		rtnl_unlock();
-	}
+re_arm:
+	if (bond->params.arp_interval)
+		queue_delayed_work(bond->wq, &bond->arp_work,
+				msecs_to_jiffies(bond->params.arp_interval));
 }
 
 /*-------------------------- netdev event handling --------------------------*/
-- 
1.8.2.1
