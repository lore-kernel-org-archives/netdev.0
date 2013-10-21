From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 4/5] bonding: remove bond read lock for bond_activebackup_arp_mon()
Date: Mon, 21 Oct 2013 16:59:09 +0800
Message-ID: <5264ECDD.1030600@huawei.com>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:41603 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661Ab3JUJG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 05:06:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond now only attach and detach slave in rtnl lock,
so read_lock for bond could not protect slave list,
replace bond read lock with rtnl lock for bond_activebackup_arp_mon().

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
