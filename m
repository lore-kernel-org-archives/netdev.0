From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 2/2] net: remove type_check from dev_get_nest_level()
Date: Fri, 12 Aug 2016 16:10:33 +0200
Message-ID: <6dfc4b9a52ee8113e8843db32917b9e09c4d1fc4.1470951139.git.sd@queasysnail.net>
References: <4c1a6a53725cc0ec023f92dae1165f3ade1e7862.1470951139.git.sd@queasysnail.net>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596AbcHLOLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 10:11:16 -0400
In-Reply-To: <4c1a6a53725cc0ec023f92dae1165f3ade1e7862.1470951139.git.sd@queasysnail.net>
In-Reply-To: <4c1a6a53725cc0ec023f92dae1165f3ade1e7862.1470951139.git.sd@queasysnail.net>
References: <4c1a6a53725cc0ec023f92dae1165f3ade1e7862.1470951139.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The idea for type_check in dev_get_nest_level() was to count the number
of nested devices of the same type (currently, only macvlan or vlan
devices).
This prevented the false positive lockdep warning on configurations such
as:

eth0 <--- macvlan0 <--- vlan0 <--- macvlan1

However, this doesn't prevent a warning on a configuration such as:

eth0 <--- macvlan0 <--- vlan0
eth1 <--- vlan1 <--- macvlan1

In this case, all the locks end up with a nesting subclass of 1, so
lockdep thinks that there is still a deadlock:

- in the first case we have (macvlan_netdev_addr_lock_key, 1) and then
  take (vlan_netdev_xmit_lock_key, 1)
- in the second case, we have (vlan_netdev_xmit_lock_key, 1) and then
  take (macvlan_netdev_addr_lock_key, 1)

By removing the linktype check in dev_get_nest_level() and always
incrementing the nesting depth, lockdep considers this configuration
valid.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c      |  2 +-
 drivers/net/macvlan.c     |  2 +-
 include/linux/netdevice.h |  3 +--
 net/8021q/vlan.c          |  2 +-
 net/core/dev.c            | 10 +++-------
 5 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 2043e8c97a81..351e701eb043 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -3201,7 +3201,7 @@ static int macsec_newlink(struct net *net, struct net_device *dev,
 
 	dev_hold(real_dev);
 
-	macsec->nest_level = dev_get_nest_level(real_dev, netif_is_macsec) + 1;
+	macsec->nest_level = dev_get_nest_level(real_dev) + 1;
 	netdev_lockdep_set_classes(dev);
 	lockdep_set_class_and_subclass(&dev->addr_list_lock,
 				       &macsec_netdev_addr_lock_key,
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index cd9b53834bf6..3234fcdea317 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1315,7 +1315,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	vlan->dev      = dev;
 	vlan->port     = port;
 	vlan->set_features = MACVLAN_FEATURES;
-	vlan->nest_level = dev_get_nest_level(lowerdev, netif_is_macvlan) + 1;
+	vlan->nest_level = dev_get_nest_level(lowerdev) + 1;
 
 	vlan->mode     = MACVLAN_MODE_VEPA;
 	if (data && data[IFLA_MACVLAN_MODE])
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 076df5360ba5..3a788bf0affd 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3891,8 +3891,7 @@ void netdev_default_l2upper_neigh_destroy(struct net_device *dev,
 extern u8 netdev_rss_key[NETDEV_RSS_KEY_LEN] __read_mostly;
 void netdev_rss_key_fill(void *buffer, size_t len);
 
-int dev_get_nest_level(struct net_device *dev,
-		       bool (*type_check)(const struct net_device *dev));
+int dev_get_nest_level(struct net_device *dev);
 int skb_checksum_help(struct sk_buff *skb);
 struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 				  netdev_features_t features, bool tx_path);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 82a116ba590e..8de138d3306b 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -169,7 +169,7 @@ int register_vlan_dev(struct net_device *dev)
 	if (err < 0)
 		goto out_uninit_mvrp;
 
-	vlan->nest_level = dev_get_nest_level(real_dev, is_vlan_dev) + 1;
+	vlan->nest_level = dev_get_nest_level(real_dev) + 1;
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto out_uninit_mvrp;
diff --git a/net/core/dev.c b/net/core/dev.c
index 4ce07dc25573..dd6ce598de89 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6045,8 +6045,7 @@ void *netdev_lower_dev_get_private(struct net_device *dev,
 EXPORT_SYMBOL(netdev_lower_dev_get_private);
 
 
-int dev_get_nest_level(struct net_device *dev,
-		       bool (*type_check)(const struct net_device *dev))
+int dev_get_nest_level(struct net_device *dev)
 {
 	struct net_device *lower = NULL;
 	struct list_head *iter;
@@ -6056,15 +6055,12 @@ int dev_get_nest_level(struct net_device *dev,
 	ASSERT_RTNL();
 
 	netdev_for_each_lower_dev(dev, lower, iter) {
-		nest = dev_get_nest_level(lower, type_check);
+		nest = dev_get_nest_level(lower);
 		if (max_nest < nest)
 			max_nest = nest;
 	}
 
-	if (type_check(dev))
-		max_nest++;
-
-	return max_nest;
+	return max_nest + 1;
 }
 EXPORT_SYMBOL(dev_get_nest_level);
 
-- 
2.9.2
