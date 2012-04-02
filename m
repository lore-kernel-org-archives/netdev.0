From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 44/51] bridge: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:34 -0400
Message-ID: <1333335521-1348-45-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568Ab2DBDAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:36 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/bridge/br_fdb.c     |    8 ++++----
 net/bridge/br_netlink.c |   25 +++++++++++--------------
 2 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 5ba0c84..80dbce4 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -487,14 +487,14 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 	ndm->ndm_ifindex = fdb->dst ? fdb->dst->dev->ifindex : br->dev->ifindex;
 	ndm->ndm_state   = fdb_to_nud(fdb);
 
-	NLA_PUT(skb, NDA_LLADDR, ETH_ALEN, &fdb->addr);
-
+	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->addr))
+		goto nla_put_failure;
 	ci.ndm_used	 = jiffies_to_clock_t(now - fdb->used);
 	ci.ndm_confirmed = 0;
 	ci.ndm_updated	 = jiffies_to_clock_t(now - fdb->updated);
 	ci.ndm_refcnt	 = 0;
-	NLA_PUT(skb, NDA_CACHEINFO, sizeof(ci), &ci);
-
+	if (nla_put(skb, NDA_CACHEINFO, sizeof(ci), &ci))
+		goto nla_put_failure;
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index a1daf82..346b368 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -60,20 +60,17 @@ static int br_fill_ifinfo(struct sk_buff *skb, const struct net_bridge_port *por
 	hdr->ifi_flags = dev_get_flags(dev);
 	hdr->ifi_change = 0;
 
-	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
-	NLA_PUT_U32(skb, IFLA_MASTER, br->dev->ifindex);
-	NLA_PUT_U32(skb, IFLA_MTU, dev->mtu);
-	NLA_PUT_U8(skb, IFLA_OPERSTATE, operstate);
-
-	if (dev->addr_len)
-		NLA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
-
-	if (dev->ifindex != dev->iflink)
-		NLA_PUT_U32(skb, IFLA_LINK, dev->iflink);
-
-	if (event == RTM_NEWLINK)
-		NLA_PUT_U8(skb, IFLA_PROTINFO, port->state);
-
+	if (nla_put_string(skb, IFLA_IFNAME, dev->name) ||
+	    nla_put_u32(skb, IFLA_MASTER, br->dev->ifindex) ||
+	    nla_put_u32(skb, IFLA_MTU, dev->mtu) ||
+	    nla_put_u8(skb, IFLA_OPERSTATE, operstate) ||
+	    (dev->addr_len &&
+	     nla_put(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr)) ||
+	    (dev->ifindex != dev->iflink &&
+	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
+	    (event == RTM_NEWLINK &&
+	     nla_put_u8(skb, IFLA_PROTINFO, port->state)))
+		goto nla_put_failure;
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-- 
1.7.7.6
