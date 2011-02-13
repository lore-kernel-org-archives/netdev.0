From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 1/4] rtnetlink: implement setting of master
 device
Date: Sun, 13 Feb 2011 20:31:06 +0100
Message-ID: <20110213193105.GD2740@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50205 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754818Ab1BMTbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 14:31:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows userspace to enslave/release slave devices via netlink
interface using IFLA_MASTER. This introduces generic way to add/remove
underling devices.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/netdevice.h |   12 ++++++++++++
 net/core/rtnetlink.c      |   42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5a42b10..d08ef65 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -783,6 +783,14 @@ struct netdev_tc_txq {
  *	Set hardware filter for RFS.  rxq_index is the target queue index;
  *	flow_id is a flow ID to be passed to rps_may_expire_flow() later.
  *	Return the filter ID on success, or a negative error code.
+ *
+ *	Slave management functions (for bridge, bonding, etc). User should
+ *	call netdev_set_master() to set dev->master properly.
+ * int (*ndo_add_slave)(struct net_device *dev, struct net_device *slave_dev);
+ *	Called to make another netdev an underling.
+ *
+ * int (*ndo_del_slave)(struct net_device *dev, struct net_device *slave_dev);
+ *	Called to release previously enslaved netdev.
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -862,6 +870,10 @@ struct net_device_ops {
 						     u16 rxq_index,
 						     u32 flow_id);
 #endif
+	int			(*ndo_add_slave)(struct net_device *dev,
+						 struct net_device *slave_dev);
+	int			(*ndo_del_slave)(struct net_device *dev,
+						 struct net_device *slave_dev);
 };
 
 /*
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index da0fe45..20d067a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1036,6 +1036,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_MAP]		= { .len = sizeof(struct rtnl_link_ifmap) },
 	[IFLA_MTU]		= { .type = NLA_U32 },
 	[IFLA_LINK]		= { .type = NLA_U32 },
+	[IFLA_MASTER]		= { .type = NLA_U32 },
 	[IFLA_TXQLEN]		= { .type = NLA_U32 },
 	[IFLA_WEIGHT]		= { .type = NLA_U32 },
 	[IFLA_OPERSTATE]	= { .type = NLA_U8 },
@@ -1178,6 +1179,41 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 	return err;
 }
 
+static int do_set_master(struct net_device *dev, int ifindex)
+{
+	struct net_device *master_dev;
+	const struct net_device_ops *ops;
+	int err;
+
+	if (dev->master) {
+		if (dev->master->ifindex == ifindex)
+			return 0;
+		ops = dev->master->netdev_ops;
+		if (ops->ndo_del_slave) {
+			err = ops->ndo_del_slave(dev->master, dev);
+			if (err)
+				return err;
+		} else {
+			return -EOPNOTSUPP;
+		}
+	}
+
+	if (ifindex) {
+		master_dev = __dev_get_by_index(dev_net(dev), ifindex);
+		if (!master_dev)
+			return -EINVAL;
+		ops = master_dev->netdev_ops;
+		if (ops->ndo_add_slave) {
+			err = ops->ndo_add_slave(master_dev, dev);
+			if (err)
+				return err;
+		} else {
+			return -EOPNOTSUPP;
+		}
+	}
+	return 0;
+}
+
 static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		      struct nlattr **tb, char *ifname, int modified)
 {
@@ -1301,6 +1337,12 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 			goto errout;
 	}
 
+	if (tb[IFLA_MASTER]) {
+		err = do_set_master(dev, nla_get_u32(tb[IFLA_MASTER]));
+		if (err)
+			goto errout;
+	}
+
 	if (tb[IFLA_TXQLEN])
 		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
 
-- 
1.7.3.4

