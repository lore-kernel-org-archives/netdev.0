From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 08/28] net: propagate upper priv via netdev_master_upper_dev_link
Date: Wed,  2 Dec 2015 21:07:31 +0100
Message-ID: <1449086871-19911-9-git-send-email-jiri@resnulli.us>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:33427 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbbLBUIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:08:05 -0500
Received: by wmec201 with SMTP id c201so270751103wme.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:08:04 -0800 (PST)
In-Reply-To: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Eliminate netdev_master_upper_dev_link_private and pass priv directly as
a parameter of netdev_master_upper_dev_link.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/bonding/bond_main.c |  2 +-
 drivers/net/team/team.c         |  2 +-
 drivers/net/vrf.c               |  2 +-
 include/linux/netdevice.h       |  6 ++----
 net/batman-adv/hard-interface.c |  3 ++-
 net/bridge/br_if.c              |  2 +-
 net/core/dev.c                  | 18 ++++++------------
 net/openvswitch/vport-netdev.c  |  2 +-
 8 files changed, 15 insertions(+), 22 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9e0f8a7..9240157 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1204,7 +1204,7 @@ static int bond_master_upper_dev_link(struct net_device *bond_dev,
 {
 	int err;
 
-	err = netdev_master_upper_dev_link_private(slave_dev, bond_dev, slave);
+	err = netdev_master_upper_dev_link(slave_dev, bond_dev, slave);
 	if (err)
 		return err;
 	slave_dev->flags |= IFF_SLAVE;
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index d2f3ee8..b37f8d1 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1083,7 +1083,7 @@ static int team_upper_dev_link(struct net_device *dev,
 {
 	int err;
 
-	err = netdev_master_upper_dev_link(port_dev, dev);
+	err = netdev_master_upper_dev_link(port_dev, dev, NULL);
 	if (err)
 		return err;
 	port_dev->priv_flags |= IFF_TEAM_PORT;
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index c2d54c4..59c5bdd 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -624,7 +624,7 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 		goto out_fail;
 	}
 
-	ret = netdev_master_upper_dev_link(port_dev, dev);
+	ret = netdev_master_upper_dev_link(port_dev, dev, NULL);
 	if (ret < 0)
 		goto out_unregister;
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 85bcd9b..cca4111 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3617,10 +3617,8 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
 struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
 int netdev_upper_dev_link(struct net_device *dev, struct net_device *upper_dev);
 int netdev_master_upper_dev_link(struct net_device *dev,
-				 struct net_device *upper_dev);
-int netdev_master_upper_dev_link_private(struct net_device *dev,
-					 struct net_device *upper_dev,
-					 void *private);
+				 struct net_device *upper_dev,
+				 void *upper_priv);
 void netdev_upper_dev_unlink(struct net_device *dev,
 			     struct net_device *upper_dev);
 void netdev_adjacent_rename_links(struct net_device *dev, char *oldname);
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index f11345e..a7f4f10 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -464,7 +464,8 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 	hard_iface->soft_iface = soft_iface;
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
-	ret = netdev_master_upper_dev_link(hard_iface->net_dev, soft_iface);
+	ret = netdev_master_upper_dev_link(hard_iface->net_dev,
+					   soft_iface, NULL);
 	if (ret)
 		goto err_dev;
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index ec02f58..781abc34 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -493,7 +493,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	dev->priv_flags |= IFF_BRIDGE_PORT;
 
-	err = netdev_master_upper_dev_link(dev, br->dev);
+	err = netdev_master_upper_dev_link(dev, br->dev, NULL);
 	if (err)
 		goto err5;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index df33f82..27a6c5a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5421,7 +5421,7 @@ static void __netdev_adjacent_dev_unlink_neighbour(struct net_device *dev,
 
 static int __netdev_upper_dev_link(struct net_device *dev,
 				   struct net_device *upper_dev, bool master,
-				   void *private)
+				   void *upper_priv)
 {
 	struct netdev_notifier_changeupper_info changeupper_info;
 	struct netdev_adjacent *i, *j, *to_i, *to_j;
@@ -5452,7 +5452,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	if (ret)
 		return ret;
 
-	ret = __netdev_adjacent_dev_link_neighbour(dev, upper_dev, private,
+	ret = __netdev_adjacent_dev_link_neighbour(dev, upper_dev, upper_priv,
 						   master);
 	if (ret)
 		return ret;
@@ -5556,6 +5556,7 @@ EXPORT_SYMBOL(netdev_upper_dev_link);
  * netdev_master_upper_dev_link - Add a master link to the upper device
  * @dev: device
  * @upper_dev: new upper device
+ * @upper_priv: upper device private
  *
  * Adds a link to device which is upper to this one. In this case, only
  * one master upper device can be linked, although other non-master devices
@@ -5564,20 +5565,13 @@ EXPORT_SYMBOL(netdev_upper_dev_link);
  * counts are adjusted and the function returns zero.
  */
 int netdev_master_upper_dev_link(struct net_device *dev,
-				 struct net_device *upper_dev)
+				 struct net_device *upper_dev,
+				 void *upper_priv)
 {
-	return __netdev_upper_dev_link(dev, upper_dev, true, NULL);
+	return __netdev_upper_dev_link(dev, upper_dev, true, upper_priv);
 }
 EXPORT_SYMBOL(netdev_master_upper_dev_link);
 
-int netdev_master_upper_dev_link_private(struct net_device *dev,
-					 struct net_device *upper_dev,
-					 void *private)
-{
-	return __netdev_upper_dev_link(dev, upper_dev, true, private);
-}
-EXPORT_SYMBOL(netdev_master_upper_dev_link_private);
-
 /**
  * netdev_upper_dev_unlink - Removes a link to upper device
  * @dev: device
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index b327368..3ee3df1 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -105,7 +105,7 @@ struct vport *ovs_netdev_link(struct vport *vport, const char *name)
 
 	rtnl_lock();
 	err = netdev_master_upper_dev_link(vport->dev,
-					   get_dpdev(vport->dp));
+					   get_dpdev(vport->dp), NULL);
 	if (err)
 		goto error_unlock;
 
-- 
1.9.3
