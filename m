From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] bonding: fix a div error caused by the slave release path
Date: Wed, 26 Feb 2014 14:20:30 +0100
Message-ID: <1393420830-20932-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49087 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbaBZNVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Feb 2014 08:21:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a bug in the slave release function which leads the transmit
functions which use the bond->slave_cnt to a div by 0 because we might
just have released our last slave and made slave_cnt == 0 but at the same
time we may have a transmitter after the check for an empty list which will
fetch it and use it in the slave id calculation.
Fix it by moving the slave_cnt after synchronize_rcu so if this was our
last slave any new transmitters will see an empty slave list which is
checked after rcu lock but before calling the mode transmit functions
which rely on bond->slave_cnt.

Fixes: 278b208375 ("bonding: initial RCU conversion")

CC: Veaceslav Falico <vfalico@redhat.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: David S. Miller <davem@davemloft.net>

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1c6104d..5a66094 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1654,9 +1654,6 @@ static int __bond_release_one(struct net_device *bond_dev,
 		return -EINVAL;
 	}
 
-	/* release the slave from its bond */
-	bond->slave_cnt--;
-
 	bond_sysfs_slave_del(slave);
 
 	bond_upper_dev_unlink(bond_dev, slave_dev);
@@ -1738,6 +1735,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 
 	unblock_netpoll_tx();
 	synchronize_rcu();
+	bond->slave_cnt--;
 
 	if (!bond_has_slaves(bond)) {
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
-- 
1.8.4.2
