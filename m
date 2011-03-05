From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 2/8] bonding: register slave pointer for rx_handler
Date: Sat,  5 Mar 2011 09:29:48 +0100
Message-ID: <1299313794-5218-3-git-send-email-jpirko@redhat.com>
References: <1299313794-5218-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458Ab1CEIaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 03:30:22 -0500
In-Reply-To: <1299313794-5218-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |   17 +++++++++++------
 drivers/net/bonding/bonding.h   |    3 +++
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0592e6d..1c19368 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1495,21 +1495,22 @@ static bool bond_should_deliver_exact_match(struct sk_buff *skb,
 
 static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
 {
-	struct net_device *slave_dev;
+	struct slave *slave;
 	struct net_device *bond_dev;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(!skb))
 		return NULL;
-	slave_dev = skb->dev;
-	bond_dev = ACCESS_ONCE(slave_dev->master);
+
+	slave = bond_slave_get_rcu(skb->dev);
+	bond_dev = ACCESS_ONCE(slave->dev->master);
 	if (unlikely(!bond_dev))
 		return skb;
 
 	if (bond_dev->priv_flags & IFF_MASTER_ARPMON)
-		slave_dev->last_rx = jiffies;
+		slave->dev->last_rx = jiffies;
 
-	if (bond_should_deliver_exact_match(skb, slave_dev, bond_dev)) {
+	if (bond_should_deliver_exact_match(skb, slave->dev, bond_dev)) {
 		skb->deliver_no_wcard = 1;
 		return skb;
 	}
@@ -1703,7 +1704,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		pr_debug("Error %d calling netdev_set_bond_master\n", res);
 		goto err_restore_mac;
 	}
-	res = netdev_rx_handler_register(slave_dev, bond_handle_frame, NULL);
+	res = netdev_rx_handler_register(slave_dev, bond_handle_frame,
+					 new_slave);
 	if (res) {
 		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
 		goto err_unset_master;
@@ -1925,6 +1927,7 @@ err_close:
 
 err_unreg_rxhandler:
 	netdev_rx_handler_unregister(slave_dev);
+	synchronize_net();
 
 err_unset_master:
 	netdev_set_bond_master(slave_dev, NULL);
@@ -2108,6 +2111,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	netdev_rx_handler_unregister(slave_dev);
+	synchronize_net();
 	netdev_set_bond_master(slave_dev, NULL);
 
 	slave_disable_netpoll(slave);
@@ -2222,6 +2226,7 @@ static int bond_release_all(struct net_device *bond_dev)
 		}
 
 		netdev_rx_handler_unregister(slave_dev);
+		synchronize_net();
 		netdev_set_bond_master(slave_dev, NULL);
 
 		slave_disable_netpoll(slave);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ff4e269..1aac5cd 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -264,6 +264,9 @@ struct bonding {
 #endif /* CONFIG_DEBUG_FS */
 };
 
+#define bond_slave_get_rcu(dev) \
+	((struct slave *) rcu_dereference(dev->rx_handler_data))
+
 /**
  * Returns NULL if the net_device does not belong to any of the bond's slaves
  *
-- 
1.7.4

