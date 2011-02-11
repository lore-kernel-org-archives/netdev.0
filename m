From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 1/4] net: extend netlink interface to handle
 generic slave management
Date: Fri, 11 Feb 2011 16:21:26 +0100
Message-ID: <20110211152125.GA2763@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32066 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754346Ab1BKPVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 10:21:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers like bridge and bonding uses their own way to manipulate with
underlink devices. This is an attempt to introduce common interface using
netlink.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_link.h   |   13 +++++++
 include/linux/netdevice.h |   22 ++++++++++++
 net/core/rtnetlink.c      |   81 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 116 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f4a2e6b..48a5f95 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -136,6 +136,9 @@ enum {
 	IFLA_PORT_SELF,
 	IFLA_AF_SPEC,
 	IFLA_GROUP,		/* Group the device belongs to */
+	IFLA_SLAVE_LIST,
+	IFLA_SLAVE_ADD,
+	IFLA_SLAVE_DEL,
 	__IFLA_MAX
 };
 
@@ -379,4 +382,14 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+/* Slave devices management section */
+
+enum {
+	IFLA_SLAVE_UNSPEC,
+	IFLA_SLAVE_DEV,
+	__IFLA_SLAVE_MAX,
+};
+
+#define IFLA_SLAVE_MAX (__IFLA_SLAVE_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c7d7074..844cb85 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -783,6 +783,21 @@ struct netdev_tc_txq {
  *	Set hardware filter for RFS.  rxq_index is the target queue index;
  *	flow_id is a flow ID to be passed to rps_may_expire_flow() later.
  *	Return the filter ID on success, or a negative error code.
+ *
+ *	Slave management functions (for bridge, bonding, etc). User should
+ *	make sure that slave list doesn't change within rtnl_lock.
+ * int (*ndo_add_slave)(struct net_device *dev, struct net_device *slave_dev);
+ *	Called to make another netdev an underlink.
+ *
+ * int (*ndo_del_slave)(struct net_device *dev, struct net_device *slave_dev);
+ *	Called to release previously enslaved netdev.
+ *
+ * int (*ndo_get_slave_count)(const struct net_device *dev);
+ *	Called to get number of enslaved devices.
+ *
+ * struct net_device * (*ndo_get_slave)(const struct net_device *dev,
+ *					int slave_index);
+ *	Called to get slave device by it's index.
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -862,6 +877,13 @@ struct net_device_ops {
 						     u16 rxq_index,
 						     u32 flow_id);
 #endif
+	int			(*ndo_add_slave)(struct net_device *dev,
+						 struct net_device *slave_dev);
+	int			(*ndo_del_slave)(struct net_device *dev,
+						 struct net_device *slave_dev);
+	int			(*ndo_get_slave_count)(const struct net_device *dev);
+	struct net_device *	(*ndo_get_slave)(const struct net_device *dev,
+						 int slave_index);
 };
 
 /*
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index da0fe45..1402a3f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -739,6 +739,20 @@ static size_t rtnl_port_size(const struct net_device *dev)
 		return port_self_size;
 }
 
+static size_t rtnl_slave_list_size(const struct net_device *dev)
+{
+	size_t slave_size = nla_total_size(sizeof(struct nlattr)) +
+			    nla_total_size(4);
+	size_t slave_list_size = nla_total_size(sizeof(struct nlattr));
+	int slave_count;
+
+	if (!dev->netdev_ops->ndo_get_slave_count ||
+	    !dev->netdev_ops->ndo_get_slave)
+		return 0;
+	slave_count = dev->netdev_ops->ndo_get_slave_count(dev);
+	return slave_list_size + slave_count * slave_size;
+}
+
 static noinline size_t if_nlmsg_size(const struct net_device *dev)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
@@ -760,6 +774,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(4) /* IFLA_NUM_VF */
 	       + rtnl_vfinfo_size(dev) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
+	       + rtnl_slave_list_size(dev) /* IFLA_SLAVE_LIST */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
 	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
 }
@@ -839,6 +854,39 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int rtnl_slave_list_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	int slave_count;
+	int i;
+	struct nlattr *slave_list;
+
+	if (!dev->netdev_ops->ndo_get_slave_count ||
+	    !dev->netdev_ops->ndo_get_slave)
+		return 0;
+	slave_count = dev->netdev_ops->ndo_get_slave_count(dev);
+	slave_list = nla_nest_start(skb, IFLA_SLAVE_LIST);
+	if (!slave_list)
+		return -EMSGSIZE;
+	for (i = 0; i < slave_count; i++) {
+		struct net_device *slave_dev;
+
+		slave_dev = dev->netdev_ops->ndo_get_slave(dev, i);
+		if (!slave_dev) {
+			nla_nest_cancel(skb, slave_list);
+			goto nla_put_failure;
+		}
+		NLA_PUT_U32(skb, IFLA_SLAVE_DEV, slave_dev->ifindex);
+	}
+	nla_nest_end(skb, slave_list);
+
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, slave_list);
+	return -EMSGSIZE;
+
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags)
@@ -953,6 +1001,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (rtnl_port_fill(skb, dev))
 		goto nla_put_failure;
 
+	if (rtnl_slave_list_fill(skb, dev))
+		goto nla_put_failure;
+
 	if (dev->rtnl_link_ops) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
@@ -1047,6 +1098,8 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_VF_PORTS]		= { .type = NLA_NESTED },
 	[IFLA_PORT_SELF]	= { .type = NLA_NESTED },
 	[IFLA_AF_SPEC]		= { .type = NLA_NESTED },
+	[IFLA_SLAVE_ADD]	= { .type = NLA_U32 },
+	[IFLA_SLAVE_DEL]	= { .type = NLA_U32 },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1392,6 +1445,34 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 			modified = 1;
 		}
 	}
+
+	if (tb[IFLA_SLAVE_ADD]) {
+		int ifindex = nla_get_u32(tb[IFLA_SLAVE_ADD]);
+		struct net_device *slave_dev;
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_add_slave) {
+			slave_dev = __dev_get_by_index(dev_net(dev), ifindex);
+			err = ops->ndo_add_slave(dev, slave_dev);
+		}
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
+
+	if (tb[IFLA_SLAVE_DEL]) {
+		int ifindex = nla_get_u32(tb[IFLA_SLAVE_DEL]);
+		struct net_device *slave_dev;
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_del_slave) {
+			slave_dev = __dev_get_by_index(dev_net(dev), ifindex);
+			err = ops->ndo_del_slave(dev, slave_dev);
+		}
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
 	err = 0;
 
 errout:
-- 
1.7.3.4

