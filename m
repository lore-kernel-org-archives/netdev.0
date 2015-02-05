From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/3] net/bonding: Fix potential bad memory access during bonding events
Date: Thu,  5 Feb 2015 15:52:44 +0200
Message-ID: <1423144366-11814-2-git-send-email-ogerlitz@mellanox.com>
References: <1423144366-11814-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39711 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753253AbbBENwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 08:52:50 -0500
In-Reply-To: <1423144366-11814-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

When queuing work to send the NETDEV_BONDING_INFO netdev event, it's
possible that when the work is executed, the pointer to the slave
becomes invalid. This can happen if between queuing the event and the
execution of the work, the net-device was un-ensvaled and re-enslaved.

Fix that by queuing a work with the data of the slave instead of the
slave structure.

Fixes: 69e6113343cf ('net/bonding: Notify state change on slaves')
Reported-by: Nikolay Aleksandrov <nikolay@redhat.com>
Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/bonding/bond_main.c |   28 +++++++++++-----------------
 include/net/bonding.h           |    2 +-
 2 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 679ef00..b979c26 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1196,18 +1196,11 @@ static void bond_fill_ifslave(struct slave *slave, struct ifslave *info)
 	info->link_failure_count = slave->link_failure_count;
 }
 
-static void bond_netdev_notify(struct slave *slave, struct net_device *dev)
+static void bond_netdev_notify(struct net_device *dev,
+			       struct netdev_bonding_info *info)
 {
-	struct bonding *bond = slave->bond;
-	struct netdev_bonding_info bonding_info;
-
 	rtnl_lock();
-	/* make sure that slave is still valid */
-	if (dev->priv_flags & IFF_BONDING) {
-		bond_fill_ifslave(slave, &bonding_info.slave);
-		bond_fill_ifbond(bond, &bonding_info.master);
-		netdev_bonding_info_change(slave->dev, &bonding_info);
-	}
+	netdev_bonding_info_change(dev, info);
 	rtnl_unlock();
 }
 
@@ -1216,25 +1209,26 @@ static void bond_netdev_notify_work(struct work_struct *_work)
 	struct netdev_notify_work *w =
 		container_of(_work, struct netdev_notify_work, work.work);
 
-	bond_netdev_notify(w->slave, w->dev);
+	bond_netdev_notify(w->dev, &w->bonding_info);
 	dev_put(w->dev);
+	kfree(w);
 }
 
 void bond_queue_slave_event(struct slave *slave)
 {
+	struct bonding *bond = slave->bond;
 	struct netdev_notify_work *nnw = kzalloc(sizeof(*nnw), GFP_ATOMIC);
 
 	if (!nnw)
 		return;
 
-	INIT_DELAYED_WORK(&nnw->work, bond_netdev_notify_work);
-	nnw->slave = slave;
+	dev_hold(slave->dev);
 	nnw->dev = slave->dev;
+	bond_fill_ifslave(slave, &nnw->bonding_info.slave);
+	bond_fill_ifbond(bond, &nnw->bonding_info.master);
+	INIT_DELAYED_WORK(&nnw->work, bond_netdev_notify_work);
 
-	if (queue_delayed_work(slave->bond->wq, &nnw->work, 0))
-		dev_hold(slave->dev);
-	else
-		kfree(nnw);
+	queue_delayed_work(slave->bond->wq, &nnw->work, 0);
 }
 
 /* enslave device <slave> to bond device <master> */
diff --git a/include/net/bonding.h b/include/net/bonding.h
index 4e17095..fda6fee 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -152,8 +152,8 @@ struct bond_parm_tbl {
 
 struct netdev_notify_work {
 	struct delayed_work	work;
-	struct slave		*slave;
 	struct net_device	*dev;
+	struct netdev_bonding_info bonding_info;
 };
 
 struct slave {
-- 
1.7.1
