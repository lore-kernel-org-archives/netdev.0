From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 09/28] net: add possibility to pass information about upper device via notifier
Date: Wed,  2 Dec 2015 21:07:32 +0100
Message-ID: <1449086871-19911-10-git-send-email-jiri@resnulli.us>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35431 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755059AbbLBUIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:08:06 -0500
Received: by wmuu63 with SMTP id u63so230295305wmu.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:08:05 -0800 (PST)
In-Reply-To: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Sometimes the drivers and other code would find it handy to know some
internal information about upper device being changed. So allow upper-code
to pass information down to notifier listeners during linking.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
- change "is upper info" to "upper into" in comment suggested by Or
---
 drivers/net/bonding/bond_main.c |  2 +-
 drivers/net/team/team.c         |  2 +-
 drivers/net/vrf.c               |  2 +-
 include/linux/netdevice.h       |  3 ++-
 net/batman-adv/hard-interface.c |  2 +-
 net/bridge/br_if.c              |  2 +-
 net/core/dev.c                  | 11 +++++++----
 net/openvswitch/vport-netdev.c  |  2 +-
 8 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9240157..fa3ed1d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1204,7 +1204,7 @@ static int bond_master_upper_dev_link(struct net_device *bond_dev,
 {
 	int err;
 
-	err = netdev_master_upper_dev_link(slave_dev, bond_dev, slave);
+	err = netdev_master_upper_dev_link(slave_dev, bond_dev, slave, NULL);
 	if (err)
 		return err;
 	slave_dev->flags |= IFF_SLAVE;
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index b37f8d1..f7b6ff7 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1083,7 +1083,7 @@ static int team_upper_dev_link(struct net_device *dev,
 {
 	int err;
 
-	err = netdev_master_upper_dev_link(port_dev, dev, NULL);
+	err = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL);
 	if (err)
 		return err;
 	port_dev->priv_flags |= IFF_TEAM_PORT;
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 59c5bdd..8944a49 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -624,7 +624,7 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 		goto out_fail;
 	}
 
-	ret = netdev_master_upper_dev_link(port_dev, dev, NULL);
+	ret = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL);
 	if (ret < 0)
 		goto out_unregister;
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cca4111..42b2279 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2161,6 +2161,7 @@ struct netdev_notifier_changeupper_info {
 	struct net_device *upper_dev; /* new upper dev */
 	bool master; /* is upper dev master */
 	bool linking; /* is the nofication for link or unlink */
+	void *upper_info; /* upper dev info */
 };
 
 static inline void netdev_notifier_info_init(struct netdev_notifier_info *info,
@@ -3618,7 +3619,7 @@ struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
 int netdev_upper_dev_link(struct net_device *dev, struct net_device *upper_dev);
 int netdev_master_upper_dev_link(struct net_device *dev,
 				 struct net_device *upper_dev,
-				 void *upper_priv);
+				 void *upper_priv, void *upper_info);
 void netdev_upper_dev_unlink(struct net_device *dev,
 			     struct net_device *upper_dev);
 void netdev_adjacent_rename_links(struct net_device *dev, char *oldname);
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index a7f4f10..aa8867e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -465,7 +465,7 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
 	ret = netdev_master_upper_dev_link(hard_iface->net_dev,
-					   soft_iface, NULL);
+					   soft_iface, NULL, NULL);
 	if (ret)
 		goto err_dev;
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 781abc34..8d1d4a2 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -493,7 +493,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	dev->priv_flags |= IFF_BRIDGE_PORT;
 
-	err = netdev_master_upper_dev_link(dev, br->dev, NULL);
+	err = netdev_master_upper_dev_link(dev, br->dev, NULL, NULL);
 	if (err)
 		goto err5;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 27a6c5a..ffd0f35 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5421,7 +5421,7 @@ static void __netdev_adjacent_dev_unlink_neighbour(struct net_device *dev,
 
 static int __netdev_upper_dev_link(struct net_device *dev,
 				   struct net_device *upper_dev, bool master,
-				   void *upper_priv)
+				   void *upper_priv, void *upper_info)
 {
 	struct netdev_notifier_changeupper_info changeupper_info;
 	struct netdev_adjacent *i, *j, *to_i, *to_j;
@@ -5445,6 +5445,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	changeupper_info.upper_dev = upper_dev;
 	changeupper_info.master = master;
 	changeupper_info.linking = true;
+	changeupper_info.upper_info = upper_info;
 
 	ret = call_netdevice_notifiers_info(NETDEV_PRECHANGEUPPER, dev,
 					    &changeupper_info.info);
@@ -5548,7 +5549,7 @@ rollback_mesh:
 int netdev_upper_dev_link(struct net_device *dev,
 			  struct net_device *upper_dev)
 {
-	return __netdev_upper_dev_link(dev, upper_dev, false, NULL);
+	return __netdev_upper_dev_link(dev, upper_dev, false, NULL, NULL);
 }
 EXPORT_SYMBOL(netdev_upper_dev_link);
 
@@ -5557,6 +5558,7 @@ EXPORT_SYMBOL(netdev_upper_dev_link);
  * @dev: device
  * @upper_dev: new upper device
  * @upper_priv: upper device private
+ * @upper_info: upper info to be passed down via notifier
  *
  * Adds a link to device which is upper to this one. In this case, only
  * one master upper device can be linked, although other non-master devices
@@ -5566,9 +5568,10 @@ EXPORT_SYMBOL(netdev_upper_dev_link);
  */
 int netdev_master_upper_dev_link(struct net_device *dev,
 				 struct net_device *upper_dev,
-				 void *upper_priv)
+				 void *upper_priv, void *upper_info)
 {
-	return __netdev_upper_dev_link(dev, upper_dev, true, upper_priv);
+	return __netdev_upper_dev_link(dev, upper_dev, true,
+				       upper_priv, upper_info);
 }
 EXPORT_SYMBOL(netdev_master_upper_dev_link);
 
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 3ee3df1..8f4dd4c 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -105,7 +105,7 @@ struct vport *ovs_netdev_link(struct vport *vport, const char *name)
 
 	rtnl_lock();
 	err = netdev_master_upper_dev_link(vport->dev,
-					   get_dpdev(vport->dp), NULL);
+					   get_dpdev(vport->dp), NULL, NULL);
 	if (err)
 		goto error_unlock;
 
-- 
1.9.3
