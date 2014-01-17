From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/2] bonding: add netlink attributes to slave link
 dev
Date: Thu, 16 Jan 2014 22:57:56 -0800
Message-ID: <20140117065756.3194.70179.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, dingtianhong@huawei.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36405 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbaAQG6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 01:58:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If link is IFF_SLAVE, extend link dev netlink attributes to include
slave attributes with new IFLA_SLAVE nest.  Add netlink notification
(RTM_NEWLINK) when slave status changes from backup to active, or
visa-versa.

Adds new ndo_get_slave op to net_device_ops to fill skb with IFLA_SLAVE
attributes.  Currently only used by bonding driver, but could be
used by other aggregating devices with slaves.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c    |    1 +
 drivers/net/bonding/bond_netlink.c |   36 ++++++++++++++++++++++++
 drivers/net/bonding/bonding.h      |   11 ++++++-
 include/linux/netdevice.h          |    5 +++
 include/uapi/linux/if_link.h       |   13 +++++++++
 net/core/rtnetlink.c               |   54 ++++++++++++++++++++++++++++++++++++
 6 files changed, 118 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index df85cec..3220b48 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3883,6 +3883,7 @@ static const struct net_device_ops bond_netdev_ops = {
 #endif
 	.ndo_add_slave		= bond_enslave,
 	.ndo_del_slave		= bond_release,
+	.ndo_get_slave		= bond_get_slave,
 	.ndo_fix_features	= bond_fix_features,
 };
 
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 555c783..21c6488 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -22,6 +22,42 @@
 #include <linux/reciprocal_div.h>
 #include "bonding.h"
 
+int bond_get_slave(struct net_device *slave_dev, struct sk_buff *skb)
+{
+	struct slave *slave = bond_slave_get_rtnl(slave_dev);
+	const struct aggregator *agg;
+
+	if (nla_put_u8(skb, IFLA_SLAVE_STATE, bond_slave_state(slave)))
+		goto nla_put_failure;
+
+	if (nla_put_u8(skb, IFLA_SLAVE_MII_STATUS, slave->link))
+		goto nla_put_failure;
+
+	if (nla_put_u32(skb, IFLA_SLAVE_LINK_FAILURE_COUNT,
+			slave->link_failure_count))
+		goto nla_put_failure;
+
+	if (nla_put(skb, IFLA_SLAVE_PERM_HWADDR,
+		    slave_dev->addr_len, slave->perm_hwaddr))
+		goto nla_put_failure;
+
+	if (nla_put_u16(skb, IFLA_SLAVE_QUEUE_ID, slave->queue_id))
+		goto nla_put_failure;
+
+	if (slave->bond->params.mode == BOND_MODE_8023AD) {
+		agg = SLAVE_AD_INFO(slave).port.aggregator;
+		if (agg)
+			if (nla_put_u16(skb, IFLA_SLAVE_AD_AGGREGATOR_ID,
+					agg->aggregator_identifier))
+				goto nla_put_failure;
+	}
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
 static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_MODE]		= { .type = NLA_U8 },
 	[IFLA_BOND_ACTIVE_SLAVE]	= { .type = NLA_U32 },
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 309757d..8a935f8 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -285,12 +285,18 @@ static inline bool bond_is_lb(const struct bonding *bond)
 
 static inline void bond_set_active_slave(struct slave *slave)
 {
-	slave->backup = 0;
+	if (slave->backup) {
+		slave->backup = 0;
+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
+	}
 }
 
 static inline void bond_set_backup_slave(struct slave *slave)
 {
-	slave->backup = 1;
+	if (!slave->backup) {
+		slave->backup = 1;
+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
+	}
 }
 
 static inline int bond_slave_state(struct slave *slave)
@@ -426,6 +432,7 @@ int bond_sysfs_slave_add(struct slave *slave);
 void bond_sysfs_slave_del(struct slave *slave);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
+int bond_get_slave(struct net_device *slave_dev, struct sk_buff *skb);
 int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int count);
 int bond_parse_parm(const char *mode_arg, const struct bond_parm_tbl *tbl);
 int bond_parm_tbl_lookup(int mode, const struct bond_parm_tbl *tbl);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d7668b88..22c8698 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -908,6 +908,9 @@ struct netdev_phys_port_id {
  * int (*ndo_del_slave)(struct net_device *dev, struct net_device *slave_dev);
  *	Called to release previously enslaved netdev.
  *
+ * int (*ndo_get_slave)(struct net_device *slave_dev, struct sk_buff *skb);
+ *	Called to fill netlink skb with slave info.
+ *
  *      Feature/offload setting functions.
  * netdev_features_t (*ndo_fix_features)(struct net_device *dev,
  *		netdev_features_t features);
@@ -1080,6 +1083,8 @@ struct net_device_ops {
 						 struct net_device *slave_dev);
 	int			(*ndo_del_slave)(struct net_device *dev,
 						 struct net_device *slave_dev);
+	int			(*ndo_get_slave)(struct net_device *slave_dev,
+						 struct sk_buff *skb);
 	netdev_features_t	(*ndo_fix_features)(struct net_device *dev,
 						    netdev_features_t features);
 	int			(*ndo_set_features)(struct net_device *dev,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 3e6bd3c..ba2f3bf 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -144,6 +144,7 @@ enum {
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
 	IFLA_PHYS_PORT_ID,
+	IFLA_SLAVE,
 	__IFLA_MAX
 };
 
@@ -368,6 +369,18 @@ enum {
 
 #define IFLA_BOND_AD_INFO_MAX	(__IFLA_BOND_AD_INFO_MAX - 1)
 
+enum {
+	IFLA_SLAVE_STATE,
+	IFLA_SLAVE_MII_STATUS,
+	IFLA_SLAVE_LINK_FAILURE_COUNT,
+	IFLA_SLAVE_PERM_HWADDR,
+	IFLA_SLAVE_QUEUE_ID,
+	IFLA_SLAVE_AD_AGGREGATOR_ID,
+	__IFLA_SLAVE_MAX,
+};
+
+#define IFLA_SLAVE_MAX	(__IFLA_SLAVE_MAX - 1)
+
 /* SR-IOV virtual function management section */
 
 enum {
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e6e7d58..4f85de7 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -721,6 +721,28 @@ static size_t rtnl_port_size(const struct net_device *dev)
 		return port_self_size;
 }
 
+static size_t rtnl_bond_slave_size(const struct net_device *dev)
+{
+	struct net_device *bond;
+	size_t slave_size =
+		nla_total_size(sizeof(struct nlattr)) +	/* IFLA_SLAVE */
+		nla_total_size(1) +	/* IFLA_SLAVE_STATE */
+		nla_total_size(1) +	/* IFLA_SLAVE_MII_STATUS */
+		nla_total_size(4) +	/* IFLA_SLAVE_LINK_FAILURE_COUNT */
+		nla_total_size(MAX_ADDR_LEN) +	/* IFLA_SLAVE_PERM_HWADDR */
+		nla_total_size(2) +	/* IFLA_SLAVE_QUEUE_ID */
+		nla_total_size(2) +	/* IFLA_SLAVE_AD_AGGREGATOR_ID */
+		0;
+
+	if (netif_is_bond_slave((struct net_device *)dev)) {
+		bond = netdev_master_upper_dev_get((struct net_device *)dev);
+		if (bond && bond->netdev_ops->ndo_get_slave)
+			return slave_size;
+	}
+
+	return 0;
+}
+
 static noinline size_t if_nlmsg_size(const struct net_device *dev,
 				     u32 ext_filter_mask)
 {
@@ -750,6 +772,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
 	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
+	       + rtnl_bond_slave_size(dev) /* IFLA_SLAVE */
 	       + nla_total_size(MAX_PHYS_PORT_ID_LEN); /* IFLA_PHYS_PORT_ID */
 }
 
@@ -847,6 +870,34 @@ static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static size_t rtnl_bond_slave_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_device *bond;
+	struct nlattr *nest;
+	int err;
+
+	if (!netif_is_bond_slave(dev))
+		return 0;
+
+	bond = netdev_master_upper_dev_get(dev);
+	if (!bond || !bond->netdev_ops->ndo_get_slave)
+		return 0;
+
+	nest = nla_nest_start(skb, IFLA_SLAVE);
+	if (!nest)
+		return -EMSGSIZE;
+
+	err = bond->netdev_ops->ndo_get_slave(dev, skb);
+	if (err) {
+		nla_nest_cancel(skb, nest);
+		return (err == -EMSGSIZE) ? err : 0;
+	}
+
+	nla_nest_end(skb, nest);
+
+	return 0;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask)
@@ -1001,6 +1052,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (rtnl_port_fill(skb, dev))
 		goto nla_put_failure;
 
+	if (rtnl_bond_slave_fill(skb, dev))
+		goto nla_put_failure;
+
 	if (dev->rtnl_link_ops) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
