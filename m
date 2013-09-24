From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 20/27] bonding: remove bond_prev_slave()
Date: Tue, 24 Sep 2013 13:47:00 +0200
Message-ID: <1380023227-9576-21-git-send-email-vfalico@redhat.com>
References: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753574Ab3IXLrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 07:47:31 -0400
In-Reply-To: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't really need it, and it's really hard to RCUify the list->prev.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    New patch.

 drivers/net/bonding/bond_main.c | 9 +++------
 drivers/net/bonding/bonding.h   | 4 ----
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 06ffc8a..6aa345a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1255,7 +1255,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
-	struct slave *new_slave = NULL;
+	struct slave *new_slave = NULL, *prev_slave;
 	struct sockaddr addr;
 	int link_reporting;
 	int res = 0, i;
@@ -1472,6 +1472,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	write_lock_bh(&bond->lock);
 
+	prev_slave = bond_last_slave(bond);
 	bond_attach_slave(bond, new_slave);
 
 	new_slave->delay = 0;
@@ -1566,9 +1567,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			 */
 			bond_3ad_initialize(bond, 1000/AD_TIMER_INTERVAL);
 		} else {
-			struct slave *prev_slave;
-
-			prev_slave = bond_prev_slave(bond, new_slave);
 			SLAVE_AD_INFO(new_slave).id =
 				SLAVE_AD_INFO(prev_slave).id + 1;
 		}
@@ -3506,9 +3504,8 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 	 */
 
 	bond_for_each_slave(bond, slave, iter) {
-		pr_debug("s %p s->p %p c_m %p\n",
+		pr_debug("s %p c_m %p\n",
 			 slave,
-			 bond_prev_slave(bond, slave),
 			 slave->dev->netdev_ops->ndo_change_mtu);
 
 		res = dev_set_mtu(slave->dev, new_mtu);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 0b4c4ff..5157153 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -96,10 +96,6 @@
 	(bond_is_last_slave(bond, pos) ? bond_first_slave(bond) : \
 					 bond_to_slave((pos)->list.next))
 
-#define bond_prev_slave(bond, pos) \
-	(bond_is_first_slave(bond, pos) ? bond_last_slave(bond) : \
-					  bond_to_slave((pos)->list.prev))
-
 /**
  * bond_for_each_slave - iterate over all slaves
  * @bond:	the bond holding this list
-- 
1.8.4
