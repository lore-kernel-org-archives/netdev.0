From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/5] bonding: convert netlink to use slave data info api
Date: Wed, 22 Jan 2014 09:05:56 +0100
Message-ID: <1390377957-31466-5-git-send-email-jiri@resnulli.us>
References: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:45178 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404AbaAVIGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 03:06:11 -0500
Received: by mail-ea0-f181.google.com with SMTP id m10so4340831eaj.40
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 00:06:10 -0800 (PST)
In-Reply-To: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c    |  1 -
 drivers/net/bonding/bond_netlink.c | 21 ++++++++++++++--
 drivers/net/bonding/bonding.h      |  1 -
 net/core/rtnetlink.c               | 51 --------------------------------------
 4 files changed, 19 insertions(+), 55 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3220b48..df85cec 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3883,7 +3883,6 @@ static const struct net_device_ops bond_netdev_ops = {
 #endif
 	.ndo_add_slave		= bond_enslave,
 	.ndo_del_slave		= bond_release,
-	.ndo_get_slave		= bond_get_slave,
 	.ndo_fix_features	= bond_fix_features,
 };
 
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index dd786a3..524d7ce 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -22,10 +22,23 @@
 #include <linux/reciprocal_div.h>
 #include "bonding.h"
 
-int bond_get_slave(struct net_device *slave_dev, struct sk_buff *skb)
+static size_t bond_get_slave_size(const struct net_device *bond_dev,
+				  const struct net_device *slave_dev)
+{
+	return nla_total_size(sizeof(u8)) +	/* IFLA_BOND_SLAVE_STATE */
+		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_SLAVE_MII_STATUS */
+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_SLAVE_LINK_FAILURE_COUNT */
+		nla_total_size(MAX_ADDR_LEN) +	/* IFLA_BOND_SLAVE_PERM_HWADDR */
+		nla_total_size(sizeof(u16)) +	/* IFLA_BOND_SLAVE_QUEUE_ID */
+		nla_total_size(sizeof(u16)) +	/* IFLA_BOND_SLAVE_AD_AGGREGATOR_ID */
+		0;
+}
+
+static int bond_fill_slave_info(struct sk_buff *skb,
+				const struct net_device *bond_dev,
+				const struct net_device *slave_dev)
 {
 	struct slave *slave = bond_slave_get_rtnl(slave_dev);
-	const struct aggregator *agg;
 
 	if (nla_put_u8(skb, IFLA_BOND_SLAVE_STATE, bond_slave_state(slave)))
 		goto nla_put_failure;
@@ -45,6 +58,8 @@ int bond_get_slave(struct net_device *slave_dev, struct sk_buff *skb)
 		goto nla_put_failure;
 
 	if (slave->bond->params.mode == BOND_MODE_8023AD) {
+		const struct aggregator *agg;
+
 		agg = SLAVE_AD_INFO(slave).port.aggregator;
 		if (agg)
 			if (nla_put_u16(skb, IFLA_BOND_SLAVE_AD_AGGREGATOR_ID,
@@ -518,6 +533,8 @@ struct rtnl_link_ops bond_link_ops __read_mostly = {
 	.get_num_tx_queues	= bond_get_num_tx_queues,
 	.get_num_rx_queues	= bond_get_num_tx_queues, /* Use the same number
 							     as for TX queues */
+	.get_slave_size		= bond_get_slave_size,
+	.fill_slave_info	= bond_fill_slave_info,
 };
 
 int __init bond_netlink_init(void)
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 8a935f8..5033e83 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -432,7 +432,6 @@ int bond_sysfs_slave_add(struct slave *slave);
 void bond_sysfs_slave_del(struct slave *slave);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
-int bond_get_slave(struct net_device *slave_dev, struct sk_buff *skb);
 int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int count);
 int bond_parse_parm(const char *mode_arg, const struct bond_parm_tbl *tbl);
 int bond_parm_tbl_lookup(int mode, const struct bond_parm_tbl *tbl);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a56bccf..db6a239 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -800,28 +800,6 @@ static size_t rtnl_port_size(const struct net_device *dev)
 		return port_self_size;
 }
 
-static size_t rtnl_bond_slave_size(const struct net_device *dev)
-{
-	struct net_device *bond;
-	size_t slave_size =
-		nla_total_size(sizeof(struct nlattr)) +	/* IFLA_BOND_SLAVE */
-		nla_total_size(1) +	/* IFLA_BOND_SLAVE_STATE */
-		nla_total_size(1) +	/* IFLA_BOND_SLAVE_MII_STATUS */
-		nla_total_size(4) +	/* IFLA_BOND_SLAVE_LINK_FAILURE_COUNT */
-		nla_total_size(MAX_ADDR_LEN) +	/* IFLA_BOND_SLAVE_PERM_HWADDR */
-		nla_total_size(2) +	/* IFLA_BOND_SLAVE_QUEUE_ID */
-		nla_total_size(2) +	/* IFLA_BOND_SLAVE_AD_AGGREGATOR_ID */
-		0;
-
-	if (netif_is_bond_slave((struct net_device *)dev)) {
-		bond = netdev_master_upper_dev_get((struct net_device *)dev);
-		if (bond && bond->netdev_ops->ndo_get_slave)
-			return slave_size;
-	}
-
-	return 0;
-}
-
 static noinline size_t if_nlmsg_size(const struct net_device *dev,
 				     u32 ext_filter_mask)
 {
@@ -851,7 +829,6 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
 	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
-	       + rtnl_bond_slave_size(dev) /* IFLA_SLAVE */
 	       + nla_total_size(MAX_PHYS_PORT_ID_LEN); /* IFLA_PHYS_PORT_ID */
 }
 
@@ -949,34 +926,6 @@ static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static size_t rtnl_bond_slave_fill(struct sk_buff *skb, struct net_device *dev)
-{
-	struct net_device *bond;
-	struct nlattr *nest;
-	int err;
-
-	if (!netif_is_bond_slave(dev))
-		return 0;
-
-	bond = netdev_master_upper_dev_get(dev);
-	if (!bond || !bond->netdev_ops->ndo_get_slave)
-		return 0;
-
-	nest = nla_nest_start(skb, IFLA_BOND_SLAVE);
-	if (!nest)
-		return -EMSGSIZE;
-
-	err = bond->netdev_ops->ndo_get_slave(dev, skb);
-	if (err) {
-		nla_nest_cancel(skb, nest);
-		return (err == -EMSGSIZE) ? err : 0;
-	}
-
-	nla_nest_end(skb, nest);
-
-	return 0;
-}
-
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask)
-- 
1.8.3.1
