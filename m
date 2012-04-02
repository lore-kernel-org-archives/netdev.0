From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 27/51] rtnetlink: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:17 -0400
Message-ID: <1333335521-1348-28-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292Ab2DBC74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:56 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/rtnetlink.c |   67 ++++++++++++++++++++++++++------------------------
 1 files changed, 35 insertions(+), 32 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1a63c6e..71a1920 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -608,7 +608,8 @@ int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics)
 	for (i = 0; i < RTAX_MAX; i++) {
 		if (metrics[i]) {
 			valid++;
-			NLA_PUT_U32(skb, i+1, metrics[i]);
+			if (nla_put_u32(skb, i+1, metrics[i]))
+				goto nla_put_failure;
 		}
 	}
 
@@ -808,7 +809,8 @@ static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
 		vf_port = nla_nest_start(skb, IFLA_VF_PORT);
 		if (!vf_port)
 			goto nla_put_failure;
-		NLA_PUT_U32(skb, IFLA_PORT_VF, vf);
+		if (nla_put_u32(skb, IFLA_PORT_VF, vf))
+			goto nla_put_failure;
 		err = dev->netdev_ops->ndo_get_vf_port(dev, vf, skb);
 		if (err == -EMSGSIZE)
 			goto nla_put_failure;
@@ -892,25 +894,22 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	ifm->ifi_flags = dev_get_flags(dev);
 	ifm->ifi_change = change;
 
-	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
-	NLA_PUT_U32(skb, IFLA_TXQLEN, dev->tx_queue_len);
-	NLA_PUT_U8(skb, IFLA_OPERSTATE,
-		   netif_running(dev) ? dev->operstate : IF_OPER_DOWN);
-	NLA_PUT_U8(skb, IFLA_LINKMODE, dev->link_mode);
-	NLA_PUT_U32(skb, IFLA_MTU, dev->mtu);
-	NLA_PUT_U32(skb, IFLA_GROUP, dev->group);
-
-	if (dev->ifindex != dev->iflink)
-		NLA_PUT_U32(skb, IFLA_LINK, dev->iflink);
-
-	if (dev->master)
-		NLA_PUT_U32(skb, IFLA_MASTER, dev->master->ifindex);
-
-	if (dev->qdisc)
-		NLA_PUT_STRING(skb, IFLA_QDISC, dev->qdisc->ops->id);
-
-	if (dev->ifalias)
-		NLA_PUT_STRING(skb, IFLA_IFALIAS, dev->ifalias);
+	if (nla_put_string(skb, IFLA_IFNAME, dev->name) ||
+	    nla_put_u32(skb, IFLA_TXQLEN, dev->tx_queue_len) ||
+	    nla_put_u8(skb, IFLA_OPERSTATE,
+		       netif_running(dev) ? dev->operstate : IF_OPER_DOWN) ||
+	    nla_put_u8(skb, IFLA_LINKMODE, dev->link_mode) ||
+	    nla_put_u32(skb, IFLA_MTU, dev->mtu) ||
+	    nla_put_u32(skb, IFLA_GROUP, dev->group) ||
+	    (dev->ifindex != dev->iflink &&
+	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
+	    (dev->master &&
+	     nla_put_u32(skb, IFLA_MASTER, dev->master->ifindex)) ||
+	    (dev->qdisc &&
+	     nla_put_string(skb, IFLA_QDISC, dev->qdisc->ops->id)) ||
+	    (dev->ifalias &&
+	     nla_put_string(skb, IFLA_IFALIAS, dev->ifalias)))
+		goto nla_put_failure;
 
 	if (1) {
 		struct rtnl_link_ifmap map = {
@@ -921,12 +920,14 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			.dma         = dev->dma,
 			.port        = dev->if_port,
 		};
-		NLA_PUT(skb, IFLA_MAP, sizeof(map), &map);
+		if (nla_put(skb, IFLA_MAP, sizeof(map), &map))
+			goto nla_put_failure;
 	}
 
 	if (dev->addr_len) {
-		NLA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
-		NLA_PUT(skb, IFLA_BROADCAST, dev->addr_len, dev->broadcast);
+		if (nla_put(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr) ||
+		    nla_put(skb, IFLA_BROADCAST, dev->addr_len, dev->broadcast))
+			goto nla_put_failure;
 	}
 
 	attr = nla_reserve(skb, IFLA_STATS,
@@ -943,8 +944,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		goto nla_put_failure;
 	copy_rtnl_link_stats64(nla_data(attr), stats);
 
-	if (dev->dev.parent && (ext_filter_mask & RTEXT_FILTER_VF))
-		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
+	if (dev->dev.parent && (ext_filter_mask & RTEXT_FILTER_VF) &&
+	    nla_put_u32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent)))
+		goto nla_put_failure;
 
 	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent
 	    && (ext_filter_mask & RTEXT_FILTER_VF)) {
@@ -987,12 +989,13 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				nla_nest_cancel(skb, vfinfo);
 				goto nla_put_failure;
 			}
-			NLA_PUT(skb, IFLA_VF_MAC, sizeof(vf_mac), &vf_mac);
-			NLA_PUT(skb, IFLA_VF_VLAN, sizeof(vf_vlan), &vf_vlan);
-			NLA_PUT(skb, IFLA_VF_TX_RATE, sizeof(vf_tx_rate),
-				&vf_tx_rate);
-			NLA_PUT(skb, IFLA_VF_SPOOFCHK, sizeof(vf_spoofchk),
-				&vf_spoofchk);
+			if (nla_put(skb, IFLA_VF_MAC, sizeof(vf_mac), &vf_mac) ||
+			    nla_put(skb, IFLA_VF_VLAN, sizeof(vf_vlan), &vf_vlan) ||
+			    nla_put(skb, IFLA_VF_TX_RATE, sizeof(vf_tx_rate),
+				    &vf_tx_rate) ||
+			    nla_put(skb, IFLA_VF_SPOOFCHK, sizeof(vf_spoofchk),
+				    &vf_spoofchk))
+				goto nla_put_failure;
 			nla_nest_end(skb, vf);
 		}
 		nla_nest_end(skb, vfinfo);
-- 
1.7.7.6
