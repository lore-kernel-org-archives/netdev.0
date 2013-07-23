From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 1/4 v2] bonding: don't call slave_xxx_netpoll under spinlocks
Date: Tue, 23 Jul 2013 15:25:27 +0800
Message-ID: <51EE2FE7.4040605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:36218 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632Ab3GWH0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 03:26:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The slave_xxx_netpoll will call synchronize_rcu_bh(),
so the function may schedule and sleep, it should't be
called under spinlocks.

bond_netpoll_setup() and bond_netpoll_cleanup() are always
protected by rtnl lock, it is no need to take the read lock,
as the slave list couldn't be changed outside rtnl lock.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/bonding/bond_main.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 07f257d4..5eb75ef 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1249,8 +1249,9 @@ static void bond_poll_controller(struct net_device *bond_dev)
 {
 }
 
-static void __bond_netpoll_cleanup(struct bonding *bond)
+static void bond_netpoll_cleanup(struct net_device *bond_dev)
 {
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 	int i;
 
@@ -1258,14 +1259,6 @@ static void __bond_netpoll_cleanup(struct bonding *bond)
 		if (IS_UP(slave->dev))
 			slave_disable_netpoll(slave);
 }
-static void bond_netpoll_cleanup(struct net_device *bond_dev)
-{
-	struct bonding *bond = netdev_priv(bond_dev);
-
-	read_lock(&bond->lock);
-	__bond_netpoll_cleanup(bond);
-	read_unlock(&bond->lock);
-}
 
 static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, gfp_t gfp)
 {
@@ -1273,15 +1266,13 @@ static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, g
 	struct slave *slave;
 	int i, err = 0;
 
-	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, i) {
 		err = slave_enable_netpoll(slave);
 		if (err) {
-			__bond_netpoll_cleanup(bond);
+			bond_netpoll_cleanup(dev);
 			break;
 		}
 	}
-	read_unlock(&bond->lock);
 	return err;
 }
 
-- 
1.8.0
