From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 2/2] net: remove netdev_bonding_change()
Date: Fri, 10 Aug 2012 16:14:57 +0800
Message-ID: <1344586497-2702-2-git-send-email-amwang@redhat.com>
References: <1344586497-2702-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23666 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757391Ab2HJIPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 04:15:18 -0400
In-Reply-To: <1344586497-2702-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't see any benifits to use netdev_bonding_change() than
using call_netdevice_notifiers() directly.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/bonding/bond_main.c |   20 ++++++++++----------
 include/linux/netdevice.h       |    2 --
 net/core/dev.c                  |    6 ------
 3 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6fae5f3..d95fbc3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1120,10 +1120,10 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			write_unlock_bh(&bond->curr_slave_lock);
 			read_unlock(&bond->lock);
 
-			netdev_bonding_change(bond->dev, NETDEV_BONDING_FAILOVER);
+			call_netdevice_notifiers(NETDEV_BONDING_FAILOVER, bond->dev);
 			if (should_notify_peers)
-				netdev_bonding_change(bond->dev,
-						      NETDEV_NOTIFY_PEERS);
+				call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
+							 bond->dev);
 
 			read_lock(&bond->lock);
 			write_lock_bh(&bond->curr_slave_lock);
@@ -1560,8 +1560,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 				 bond_dev->name,
 				 bond_dev->type, slave_dev->type);
 
-			res = netdev_bonding_change(bond_dev,
-						    NETDEV_PRE_TYPE_CHANGE);
+			res = call_netdevice_notifiers(NETDEV_PRE_TYPE_CHANGE,
+						       bond_dev);
 			res = notifier_to_errno(res);
 			if (res) {
 				pr_err("%s: refused to change device type\n",
@@ -1581,8 +1581,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 				bond_dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 			}
 
-			netdev_bonding_change(bond_dev,
-					      NETDEV_POST_TYPE_CHANGE);
+			call_netdevice_notifiers(NETDEV_POST_TYPE_CHANGE,
+						 bond_dev);
 		}
 	} else if (bond_dev->type != slave_dev->type) {
 		pr_err("%s ether type (%d) is different from other slaves (%d), can not enslave it.\n",
@@ -1943,7 +1943,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	block_netpoll_tx();
-	netdev_bonding_change(bond_dev, NETDEV_RELEASE);
+	call_netdevice_notifiers(NETDEV_RELEASE, bond_dev);
 	write_lock_bh(&bond->lock);
 
 	slave = bond_get_slave_by_dev(bond, slave_dev);
@@ -2586,7 +2586,7 @@ re_arm:
 			read_unlock(&bond->lock);
 			return;
 		}
-		netdev_bonding_change(bond->dev, NETDEV_NOTIFY_PEERS);
+		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
 		rtnl_unlock();
 	}
 }
@@ -3205,7 +3205,7 @@ re_arm:
 			read_unlock(&bond->lock);
 			return;
 		}
-		netdev_bonding_change(bond->dev, NETDEV_NOTIFY_PEERS);
+		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
 		rtnl_unlock();
 	}
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8d4b731..1d6ab69 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2595,8 +2595,6 @@ extern int		dev_set_promiscuity(struct net_device *dev, int inc);
 extern int		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
 extern void		netdev_notify_peers(struct net_device *dev);
-extern int		netdev_bonding_change(struct net_device *dev,
-					      unsigned long event);
 extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
diff --git a/net/core/dev.c b/net/core/dev.c
index 1eb9636..8e480eb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1127,12 +1127,6 @@ void netdev_notify_peers(struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_notify_peers);
 
-int netdev_bonding_change(struct net_device *dev, unsigned long event)
-{
-	return call_netdevice_notifiers(event, dev);
-}
-EXPORT_SYMBOL(netdev_bonding_change);
-
 /**
  *	dev_load 	- load a network module
  *	@net: the applicable net namespace
-- 
1.7.7.6
