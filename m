From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 3/3] bonding: when cloning a MAC use NET_ADDR_STOLEN
Date: Wed, 26 Jun 2013 17:13:39 +0200
Message-ID: <1372259619-32430-4-git-send-email-nikolay@redhat.com>
References: <1372259619-32430-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751475Ab3FZPRL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 11:17:11 -0400
In-Reply-To: <1372259619-32430-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A simple semantic change, when a slave's MAC is cloned by the bond
master then set addr_assign_type to NET_ADDR_STOLEN instead of
NET_ADDR_SET. Also use bond_set_dev_addr() in BOND_FOM_ACTIVE mode
to change the bond's MAC address because the assign_type has to be
set properly.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
Shouldn't we have the pr_debugs on 1 line ? This is not called too often.

 drivers/net/bonding/bond_main.c | 33 +++++++++++++++++++--------------
 1 file changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0da3c12..ec44580b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -833,6 +833,24 @@ static void bond_hw_addr_swap(struct bonding *bond, struct slave *new_active,
 	}
 }
 
+/**
+ * bond_set_dev_addr - clone slave's address to bond
+ * @bond_dev: bond net device
+ * @slave_dev: slave net device
+ *
+ * Should be called with RTNL held.
+ */
+static void bond_set_dev_addr(struct net_device *bond_dev,
+			      struct net_device *slave_dev)
+{
+	pr_debug("bond_dev=%p\n", bond_dev);
+	pr_debug("slave_dev=%p\n", slave_dev);
+	pr_debug("slave_dev->addr_len=%d\n", slave_dev->addr_len);
+	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len);
+	bond_dev->addr_assign_type = NET_ADDR_STOLEN;
+	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
+}
+
 /*
  * bond_do_fail_over_mac
  *
@@ -855,11 +873,9 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 	switch (bond->params.fail_over_mac) {
 	case BOND_FOM_ACTIVE:
 		if (new_active) {
-			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
-			       new_active->dev->addr_len);
 			write_unlock_bh(&bond->curr_slave_lock);
 			read_unlock(&bond->lock);
-			call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
+			bond_set_dev_addr(bond->dev, new_active->dev);
 			read_lock(&bond->lock);
 			write_lock_bh(&bond->curr_slave_lock);
 		}
@@ -1290,17 +1306,6 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
 
 /*---------------------------------- IOCTL ----------------------------------*/
 
-static void bond_set_dev_addr(struct net_device *bond_dev,
-			      struct net_device *slave_dev)
-{
-	pr_debug("bond_dev=%p\n", bond_dev);
-	pr_debug("slave_dev=%p\n", slave_dev);
-	pr_debug("slave_dev->addr_len=%d\n", slave_dev->addr_len);
-	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len);
-	bond_dev->addr_assign_type = NET_ADDR_SET;
-	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
-}
-
 static netdev_features_t bond_fix_features(struct net_device *dev,
 	netdev_features_t features)
 {
-- 
1.8.1.4
