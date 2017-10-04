From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 2/7] net: Add extack to ndo_add_slave
Date: Tue,  3 Oct 2017 21:58:49 -0700
Message-ID: <1507093134-20406-3-git-send-email-dsahern@gmail.com>
References: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jiri@mellanox.com, idosch@mellanox.com, davem@davemloft.net,
        bridge@lists.linux-foundation.org, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36297 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdJDE7D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:59:03 -0400
Received: by mail-pg0-f66.google.com with SMTP id i195so3711915pgd.3
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 21:59:03 -0700 (PDT)
In-Reply-To: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass extack to do_set_master and down to ndo_add_slave

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 drivers/net/bonding/bond_main.c    |  5 +++--
 drivers/net/bonding/bond_options.c |  2 +-
 drivers/net/team/team.c            |  3 ++-
 drivers/net/vrf.c                  |  3 ++-
 include/linux/netdevice.h          |  3 ++-
 include/net/bonding.h              |  3 ++-
 net/batman-adv/soft-interface.c    |  3 ++-
 net/bridge/br_device.c             |  3 ++-
 net/core/rtnetlink.c               | 10 ++++++----
 9 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b19dc033fb36..78feb94a36db 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1328,7 +1328,8 @@ void bond_lower_state_changed(struct slave *slave)
 }
 
 /* enslave device <slave> to bond device <master> */
-int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
+int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev,
+		 struct netlink_ext_ack *extack)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
@@ -3492,7 +3493,7 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 	switch (cmd) {
 	case BOND_ENSLAVE_OLD:
 	case SIOCBONDENSLAVE:
-		res = bond_enslave(bond_dev, slave_dev);
+		res = bond_enslave(bond_dev, slave_dev, NULL);
 		break;
 	case BOND_RELEASE_OLD:
 	case SIOCBONDRELEASE:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 5931aa2fe997..8a9b085c2a98 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -1383,7 +1383,7 @@ static int bond_option_slaves_set(struct bonding *bond,
 	switch (command[0]) {
 	case '+':
 		netdev_dbg(bond->dev, "Adding slave %s\n", dev->name);
-		ret = bond_enslave(bond->dev, dev);
+		ret = bond_enslave(bond->dev, dev, NULL);
 		break;
 
 	case '-':
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index ae53e899259f..4359d45aa131 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1914,7 +1914,8 @@ static int team_netpoll_setup(struct net_device *dev,
 }
 #endif
 
-static int team_add_slave(struct net_device *dev, struct net_device *port_dev)
+static int team_add_slave(struct net_device *dev, struct net_device *port_dev,
+			  struct netlink_ext_ack *extack)
 {
 	struct team *team = netdev_priv(dev);
 	int err;
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index cc18b7b11612..4a082ef53533 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -788,7 +788,8 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 	return ret;
 }
 
-static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
+static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev,
+			 struct netlink_ext_ack *extack)
 {
 	if (netif_is_l3_master(port_dev) || netif_is_l3_slave(port_dev))
 		return -EINVAL;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 05fcaba4b0d9..368a5064a487 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1246,7 +1246,8 @@ struct net_device_ops {
 						     u32 flow_id);
 #endif
 	int			(*ndo_add_slave)(struct net_device *dev,
-						 struct net_device *slave_dev);
+						 struct net_device *slave_dev,
+						 struct netlink_ext_ack *extack);
 	int			(*ndo_del_slave)(struct net_device *dev,
 						 struct net_device *slave_dev);
 	netdev_features_t	(*ndo_fix_features)(struct net_device *dev,
diff --git a/include/net/bonding.h b/include/net/bonding.h
index b2e68657a216..2860cc66c2bb 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -596,7 +596,8 @@ void bond_destroy_sysfs(struct bond_net *net);
 void bond_prepare_sysfs_group(struct bonding *bond);
 int bond_sysfs_slave_add(struct slave *slave);
 void bond_sysfs_slave_del(struct slave *slave);
-int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
+int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev,
+		 struct netlink_ext_ack *extack);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
 u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb);
 int bond_set_carrier(struct bonding *bond);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index c2c986746d0b..e7d5fbb6ad53 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -867,7 +867,8 @@ static int batadv_softif_init_late(struct net_device *dev)
  * Return: 0 if successful or error otherwise.
  */
 static int batadv_softif_slave_add(struct net_device *dev,
-				   struct net_device *slave_dev)
+				   struct net_device *slave_dev,
+				   struct netlink_ext_ack *extack)
 {
 	struct batadv_hard_iface *hard_iface;
 	struct net *net = dev_net(dev);
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index f6b6a92f1c48..cb0131d70ab1 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -320,7 +320,8 @@ void br_netpoll_disable(struct net_bridge_port *p)
 
 #endif
 
-static int br_add_slave(struct net_device *dev, struct net_device *slave_dev)
+static int br_add_slave(struct net_device *dev, struct net_device *slave_dev,
+			struct netlink_ext_ack *extack)
 
 {
 	struct net_bridge *br = netdev_priv(dev);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 3961f87cdc76..1b355219e520 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1964,7 +1964,8 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
 	return err;
 }
 
-static int do_set_master(struct net_device *dev, int ifindex)
+static int do_set_master(struct net_device *dev, int ifindex,
+			 struct netlink_ext_ack *extack)
 {
 	struct net_device *upper_dev = netdev_master_upper_dev_get(dev);
 	const struct net_device_ops *ops;
@@ -1989,7 +1990,7 @@ static int do_set_master(struct net_device *dev, int ifindex)
 			return -EINVAL;
 		ops = upper_dev->netdev_ops;
 		if (ops->ndo_add_slave) {
-			err = ops->ndo_add_slave(upper_dev, dev);
+			err = ops->ndo_add_slave(upper_dev, dev, extack);
 			if (err)
 				return err;
 		} else {
@@ -2122,7 +2123,7 @@ static int do_setlink(const struct sk_buff *skb,
 	}
 
 	if (tb[IFLA_MASTER]) {
-		err = do_set_master(dev, nla_get_u32(tb[IFLA_MASTER]));
+		err = do_set_master(dev, nla_get_u32(tb[IFLA_MASTER]), extack);
 		if (err)
 			goto errout;
 		status |= DO_SETLINK_MODIFIED;
@@ -2766,7 +2767,8 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 				goto out_unregister;
 		}
 		if (tb[IFLA_MASTER]) {
-			err = do_set_master(dev, nla_get_u32(tb[IFLA_MASTER]));
+			err = do_set_master(dev, nla_get_u32(tb[IFLA_MASTER]),
+					    extack);
 			if (err)
 				goto out_unregister;
 		}
-- 
2.1.4
