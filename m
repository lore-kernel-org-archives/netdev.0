From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 3/7] net: Add extack to upper device linking
Date: Tue,  3 Oct 2017 21:58:50 -0700
Message-ID: <1507093134-20406-4-git-send-email-dsahern@gmail.com>
References: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jiri@mellanox.com, idosch@mellanox.com, davem@davemloft.net,
        bridge@lists.linux-foundation.org, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33107 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbdJDE7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:59:04 -0400
Received: by mail-pf0-f195.google.com with SMTP id m28so11147806pfi.0
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 21:59:04 -0700 (PDT)
In-Reply-To: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add extack arg to netdev_upper_dev_link and netdev_master_upper_dev_link

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 drivers/net/bonding/bond_main.c                    |  7 ++++---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c |  2 +-
 drivers/net/hyperv/netvsc_drv.c                    |  2 +-
 drivers/net/ipvlan/ipvlan_main.c                   |  2 +-
 drivers/net/macsec.c                               |  2 +-
 drivers/net/macvlan.c                              |  7 ++++---
 drivers/net/macvtap.c                              |  2 +-
 drivers/net/team/team.c                            |  2 +-
 drivers/net/usb/qmi_wwan.c                         |  2 +-
 drivers/net/vrf.c                                  |  7 ++++---
 include/linux/if_macvlan.h                         |  3 ++-
 include/linux/netdevice.h                          |  6 ++++--
 net/8021q/vlan.c                                   |  6 +++---
 net/8021q/vlan.h                                   |  2 +-
 net/8021q/vlan_netlink.c                           |  2 +-
 net/batman-adv/hard-interface.c                    |  2 +-
 net/bridge/br_if.c                                 |  2 +-
 net/core/dev.c                                     | 15 ++++++++++-----
 net/openvswitch/vport-netdev.c                     |  3 ++-
 19 files changed, 44 insertions(+), 32 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 78feb94a36db..bc92307c2082 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1217,14 +1217,15 @@ static enum netdev_lag_tx_type bond_lag_tx_type(struct bonding *bond)
 	}
 }
 
-static int bond_master_upper_dev_link(struct bonding *bond, struct slave *slave)
+static int bond_master_upper_dev_link(struct bonding *bond, struct slave *slave,
+				      struct netlink_ext_ack *extack)
 {
 	struct netdev_lag_upper_info lag_upper_info;
 	int err;
 
 	lag_upper_info.tx_type = bond_lag_tx_type(bond);
 	err = netdev_master_upper_dev_link(slave->dev, bond->dev, slave,
-					   &lag_upper_info);
+					   &lag_upper_info, extack);
 	if (err)
 		return err;
 	rtmsg_ifinfo(RTM_NEWLINK, slave->dev, IFF_SLAVE, GFP_KERNEL);
@@ -1710,7 +1711,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev,
 		goto err_detach;
 	}
 
-	res = bond_master_upper_dev_link(bond, new_slave);
+	res = bond_master_upper_dev_link(bond, new_slave, extack);
 	if (res) {
 		netdev_dbg(bond_dev, "Error %d calling bond_master_upper_dev_link\n", res);
 		goto err_unregister;
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
index 98f22551eb45..1af326a60cbb 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
@@ -178,7 +178,7 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 	if (err)
 		goto err1;
 
-	err = netdev_master_upper_dev_link(dev, real_dev, NULL, NULL);
+	err = netdev_master_upper_dev_link(dev, real_dev, NULL, NULL, extack);
 	if (err)
 		goto err2;
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f300ae61c6c6..dfb986421ec6 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1748,7 +1748,7 @@ static int netvsc_vf_join(struct net_device *vf_netdev,
 		goto rx_handler_failed;
 	}
 
-	ret = netdev_upper_dev_link(vf_netdev, ndev);
+	ret = netdev_upper_dev_link(vf_netdev, ndev, NULL);
 	if (ret != 0) {
 		netdev_err(vf_netdev,
 			   "can not set master device %s (err = %d)\n",
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index c74893c1e620..57c3856bab05 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -584,7 +584,7 @@ int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	if (err < 0)
 		goto remove_ida;
 
-	err = netdev_upper_dev_link(phy_dev, dev);
+	err = netdev_upper_dev_link(phy_dev, dev, extack);
 	if (err) {
 		goto unregister_netdev;
 	}
diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 98e4deaa3a6a..ccbe4eaffe4d 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -3244,7 +3244,7 @@ static int macsec_newlink(struct net *net, struct net_device *dev,
 				       &macsec_netdev_addr_lock_key,
 				       macsec_get_nest_level(dev));
 
-	err = netdev_upper_dev_link(real_dev, dev);
+	err = netdev_upper_dev_link(real_dev, dev, extack);
 	if (err < 0)
 		goto unregister;
 
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 1ffe77e95d46..858bd66511a2 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1344,7 +1344,8 @@ static int macvlan_changelink_sources(struct macvlan_dev *vlan, u32 mode,
 }
 
 int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
-			   struct nlattr *tb[], struct nlattr *data[])
+			   struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvlan_port *port;
@@ -1433,7 +1434,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		goto destroy_macvlan_port;
 
 	dev->priv_flags |= IFF_MACVLAN;
-	err = netdev_upper_dev_link(lowerdev, dev);
+	err = netdev_upper_dev_link(lowerdev, dev, extack);
 	if (err)
 		goto unregister_netdev;
 
@@ -1456,7 +1457,7 @@ static int macvlan_newlink(struct net *src_net, struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[],
 			   struct netlink_ext_ack *extack)
 {
-	return macvlan_common_newlink(src_net, dev, tb, data);
+	return macvlan_common_newlink(src_net, dev, tb, data, extack);
 }
 
 void macvlan_dellink(struct net_device *dev, struct list_head *head)
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index c2d0ea2fb019..f62aea2fcfa9 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -105,7 +105,7 @@ static int macvtap_newlink(struct net *src_net, struct net_device *dev,
 	/* Don't put anything that may fail after macvlan_common_newlink
 	 * because we can't undo what it does.
 	 */
-	err = macvlan_common_newlink(src_net, dev, tb, data);
+	err = macvlan_common_newlink(src_net, dev, tb, data, extack);
 	if (err) {
 		netdev_rx_handler_unregister(dev);
 		return err;
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 4359d45aa131..a468439969df 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1112,7 +1112,7 @@ static int team_upper_dev_link(struct team *team, struct team_port *port)
 
 	lag_upper_info.tx_type = team->mode->lag_tx_type;
 	err = netdev_master_upper_dev_link(port->dev, team->dev, NULL,
-					   &lag_upper_info);
+					   &lag_upper_info, NULL);
 	if (err)
 		return err;
 	port->dev->priv_flags |= IFF_TEAM_PORT;
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 8c3733608271..db7279d5b250 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -221,7 +221,7 @@ static int qmimux_register_device(struct net_device *real_dev, u8 mux_id)
 	/* Account for reference in struct qmimux_priv_priv */
 	dev_hold(real_dev);
 
-	err = netdev_upper_dev_link(real_dev, new_dev);
+	err = netdev_upper_dev_link(real_dev, new_dev, NULL);
 	if (err)
 		goto out_unregister_netdev;
 
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 4a082ef53533..77d0655a0250 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -764,7 +764,8 @@ static void cycle_netdev(struct net_device *dev)
 	}
 }
 
-static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
+static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev,
+			    struct netlink_ext_ack *extack)
 {
 	int ret;
 
@@ -775,7 +776,7 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 		return -EOPNOTSUPP;
 
 	port_dev->priv_flags |= IFF_L3MDEV_SLAVE;
-	ret = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL);
+	ret = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL, extack);
 	if (ret < 0)
 		goto err;
 
@@ -794,7 +795,7 @@ static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev,
 	if (netif_is_l3_master(port_dev) || netif_is_l3_slave(port_dev))
 		return -EINVAL;
 
-	return do_vrf_add_slave(dev, port_dev);
+	return do_vrf_add_slave(dev, port_dev, extack);
 }
 
 /* inverse of do_vrf_add_slave */
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index c9ec1343d187..10e319f41fb1 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -72,7 +72,8 @@ static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
 extern void macvlan_common_setup(struct net_device *dev);
 
 extern int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
-				  struct nlattr *tb[], struct nlattr *data[]);
+				  struct nlattr *tb[], struct nlattr *data[],
+				  struct netlink_ext_ack *extack);
 
 extern void macvlan_count_rx(const struct macvlan_dev *vlan,
 			     unsigned int len, bool success,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 368a5064a487..31bb3010c69b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3919,10 +3919,12 @@ void *netdev_adjacent_get_private(struct list_head *adj_list);
 void *netdev_lower_get_first_private_rcu(struct net_device *dev);
 struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
 struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
-int netdev_upper_dev_link(struct net_device *dev, struct net_device *upper_dev);
+int netdev_upper_dev_link(struct net_device *dev, struct net_device *upper_dev,
+			  struct netlink_ext_ack *extack);
 int netdev_master_upper_dev_link(struct net_device *dev,
 				 struct net_device *upper_dev,
-				 void *upper_priv, void *upper_info);
+				 void *upper_priv, void *upper_info,
+				 struct netlink_ext_ack *extack);
 void netdev_upper_dev_unlink(struct net_device *dev,
 			     struct net_device *upper_dev);
 void netdev_adjacent_rename_links(struct net_device *dev, char *oldname);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 9649579b5b9f..71c3e045505b 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -138,7 +138,7 @@ int vlan_check_real_dev(struct net_device *real_dev,
 	return 0;
 }
 
-int register_vlan_dev(struct net_device *dev)
+int register_vlan_dev(struct net_device *dev, struct netlink_ext_ack *extack)
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev = vlan->real_dev;
@@ -174,7 +174,7 @@ int register_vlan_dev(struct net_device *dev)
 	if (err < 0)
 		goto out_uninit_mvrp;
 
-	err = netdev_upper_dev_link(real_dev, dev);
+	err = netdev_upper_dev_link(real_dev, dev, extack);
 	if (err)
 		goto out_unregister_netdev;
 
@@ -270,7 +270,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	vlan->flags = VLAN_FLAG_REORDER_HDR;
 
 	new_dev->rtnl_link_ops = &vlan_link_ops;
-	err = register_vlan_dev(new_dev);
+	err = register_vlan_dev(new_dev, NULL);
 	if (err < 0)
 		goto out_free_newdev;
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index df8bd65dd370..94f8eed9f9b3 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -107,7 +107,7 @@ void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 int vlan_check_real_dev(struct net_device *real_dev,
 			__be16 protocol, u16 vlan_id);
 void vlan_setup(struct net_device *dev);
-int register_vlan_dev(struct net_device *dev);
+int register_vlan_dev(struct net_device *dev, struct netlink_ext_ack *extack);
 void unregister_vlan_dev(struct net_device *dev, struct list_head *head);
 bool vlan_dev_inherit_address(struct net_device *dev,
 			      struct net_device *real_dev);
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 5e831de3103e..6e7c5a6a7930 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -160,7 +160,7 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 	if (err < 0)
 		return err;
 
-	return register_vlan_dev(dev);
+	return register_vlan_dev(dev, extack);
 }
 
 static inline size_t vlan_qos_map_size(unsigned int n)
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index e348f76ea8c1..f7b413b9297e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -738,7 +738,7 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
 	ret = netdev_master_upper_dev_link(hard_iface->net_dev,
-					   soft_iface, NULL, NULL);
+					   soft_iface, NULL, NULL, NULL);
 	if (ret)
 		goto err_dev;
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f3aef22931ab..0a3fd727048d 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -540,7 +540,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	dev->priv_flags |= IFF_BRIDGE_PORT;
 
-	err = netdev_master_upper_dev_link(dev, br->dev, NULL, NULL);
+	err = netdev_master_upper_dev_link(dev, br->dev, NULL, NULL, NULL);
 	if (err)
 		goto err5;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index dbeeefebfbb7..b417b76ff8fc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6276,11 +6276,13 @@ static void __netdev_adjacent_dev_unlink_neighbour(struct net_device *dev,
 
 static int __netdev_upper_dev_link(struct net_device *dev,
 				   struct net_device *upper_dev, bool master,
-				   void *upper_priv, void *upper_info)
+				   void *upper_priv, void *upper_info,
+				   struct netlink_ext_ack *extack)
 {
 	struct netdev_notifier_changeupper_info changeupper_info = {
 		.info = {
 			.dev = dev,
+			.extack = extack,
 		},
 		.upper_dev = upper_dev,
 		.master = master,
@@ -6340,9 +6342,11 @@ static int __netdev_upper_dev_link(struct net_device *dev,
  * returns zero.
  */
 int netdev_upper_dev_link(struct net_device *dev,
-			  struct net_device *upper_dev)
+			  struct net_device *upper_dev,
+			  struct netlink_ext_ack *extack)
 {
-	return __netdev_upper_dev_link(dev, upper_dev, false, NULL, NULL);
+	return __netdev_upper_dev_link(dev, upper_dev, false,
+				       NULL, NULL, extack);
 }
 EXPORT_SYMBOL(netdev_upper_dev_link);
 
@@ -6361,10 +6365,11 @@ EXPORT_SYMBOL(netdev_upper_dev_link);
  */
 int netdev_master_upper_dev_link(struct net_device *dev,
 				 struct net_device *upper_dev,
-				 void *upper_priv, void *upper_info)
+				 void *upper_priv, void *upper_info,
+				 struct netlink_ext_ack *extack)
 {
 	return __netdev_upper_dev_link(dev, upper_dev, true,
-				       upper_priv, upper_info);
+				       upper_priv, upper_info, extack);
 }
 EXPORT_SYMBOL(netdev_master_upper_dev_link);
 
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 0389398fa4ab..2e5e7a41d8ef 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -108,7 +108,8 @@ struct vport *ovs_netdev_link(struct vport *vport, const char *name)
 
 	rtnl_lock();
 	err = netdev_master_upper_dev_link(vport->dev,
-					   get_dpdev(vport->dp), NULL, NULL);
+					   get_dpdev(vport->dp),
+					   NULL, NULL, NULL);
 	if (err)
 		goto error_unlock;
 
-- 
2.1.4
