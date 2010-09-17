From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 1/2] net: add IFLA_NUM_TXQ attribute
Date: Fri, 17 Sep 2010 10:31:28 +0200
Message-ID: <1284712288.3391.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49979 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091Ab0IQIim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 04:38:42 -0400
Received: by wyf22 with SMTP id 22so2149592wyf.19
        for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 01:38:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to enable multiqueue support on some devices,
add IFLA_NUM_TXQ attribute, number of transmit queues, that "ip link"
can use, at creation and show time :

# ip link add gre34 txqueues 8 type gre remote 192.168.20.80

# ip link sho dev gre34
8: gre34: <POINTOPOINT,NOARP> mtu 1476 qdisc noop state DOWN txqueues 8 
    link/gre 0.0.0.0 peer 192.168.20.80

Drivers not yet multiqueue aware are supported, because core network
temporary sets real_num_tx_queues to one.

Multiqueue enabled drivers must then sets real_num_tx_queues to
num_tx_queues in their newlink() method.

Limits number of queues to 256 for the moment.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/if_link.h |    1 +
 net/core/rtnetlink.c    |   17 +++++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 2fc66dd..87dca81 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -116,6 +116,7 @@ enum {
 	IFLA_STATS64,
 	IFLA_VF_PORTS,
 	IFLA_PORT_SELF,
+	IFLA_NUM_TXQ,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b2a718d..1b9af34 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -676,6 +676,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(4) /* IFLA_NUM_VF */
+	       + nla_total_size(4) /* IFLA_NUM_TXQ */
 	       + rtnl_vfinfo_size(dev) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev); /* IFLA_LINKINFO */
@@ -791,6 +792,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (dev->master)
 		NLA_PUT_U32(skb, IFLA_MASTER, dev->master->ifindex);
 
+	if (dev->real_num_tx_queues > 1)
+		NLA_PUT_U32(skb, IFLA_NUM_TXQ, dev->real_num_tx_queues);
+
 	if (dev->qdisc)
 		NLA_PUT_STRING(skb, IFLA_QDISC, dev->qdisc->ops->id);
 
@@ -922,6 +926,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_MTU]		= { .type = NLA_U32 },
 	[IFLA_LINK]		= { .type = NLA_U32 },
 	[IFLA_TXQLEN]		= { .type = NLA_U32 },
+	[IFLA_NUM_TXQ]		= { .type = NLA_U32 },
 	[IFLA_WEIGHT]		= { .type = NLA_U32 },
 	[IFLA_OPERSTATE]	= { .type = NLA_U8 },
 	[IFLA_LINKMODE]		= { .type = NLA_U8 },
@@ -1357,6 +1362,18 @@ struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
 		if (err)
 			goto err;
 	}
+	if (tb[IFLA_NUM_TXQ]) {
+		err = -EINVAL;
+		num_queues = nla_get_u32(tb[IFLA_NUM_TXQ]);
+		if (num_queues < 1 || num_queues > 256)
+			goto err;
+		/* multiqueue drivers have to set
+		 * dev->real_num_tx_queues = dev->num_tx_queues;
+		 * in their ->newlink() method. We force a temporary
+		 * single queue to be compatable with old drivers.
+		 */
+		real_num_queues = 1;
+	}
 	err = -ENOMEM;
 	dev = alloc_netdev_mq(ops->priv_size, ifname, ops->setup, num_queues);
 	if (!dev)


