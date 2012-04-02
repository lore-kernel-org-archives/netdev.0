From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 40/51] ieee802154: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:30 -0400
Message-ID: <1333335521-1348-41-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46792 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473Ab2DBDAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:30 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ieee802154/nl-mac.c |  146 +++++++++++++++++++++++------------------------
 net/ieee802154/nl-phy.c |   29 +++++-----
 2 files changed, 85 insertions(+), 90 deletions(-)

diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index adaf462..ca92587 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -63,15 +63,14 @@ int ieee802154_nl_assoc_indic(struct net_device *dev,
 	if (!msg)
 		return -ENOBUFS;
 
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-
-	NLA_PUT(msg, IEEE802154_ATTR_SRC_HW_ADDR, IEEE802154_ADDR_LEN,
-			addr->hwaddr);
-
-	NLA_PUT_U8(msg, IEEE802154_ATTR_CAPABILITY, cap);
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
+		    dev->dev_addr) ||
+	    nla_put(msg, IEEE802154_ATTR_SRC_HW_ADDR, IEEE802154_ADDR_LEN,
+		    addr->hwaddr) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_CAPABILITY, cap))
+		goto nla_put_failure;
 
 	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
@@ -92,14 +91,13 @@ int ieee802154_nl_assoc_confirm(struct net_device *dev, u16 short_addr,
 	if (!msg)
 		return -ENOBUFS;
 
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-
-	NLA_PUT_U16(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr);
-	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
-
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
+		    dev->dev_addr) ||
+	    nla_put_u16(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_STATUS, status))
+		goto nla_put_failure;
 	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
@@ -119,20 +117,22 @@ int ieee802154_nl_disassoc_indic(struct net_device *dev,
 	if (!msg)
 		return -ENOBUFS;
 
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-
-	if (addr->addr_type == IEEE802154_ADDR_LONG)
-		NLA_PUT(msg, IEEE802154_ATTR_SRC_HW_ADDR, IEEE802154_ADDR_LEN,
-				addr->hwaddr);
-	else
-		NLA_PUT_U16(msg, IEEE802154_ATTR_SRC_SHORT_ADDR,
-				addr->short_addr);
-
-	NLA_PUT_U8(msg, IEEE802154_ATTR_REASON, reason);
-
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
+		    dev->dev_addr))
+		goto nla_put_failure;
+	if (addr->addr_type == IEEE802154_ADDR_LONG) {
+		if (nla_put(msg, IEEE802154_ATTR_SRC_HW_ADDR, IEEE802154_ADDR_LEN,
+			    addr->hwaddr))
+			goto nla_put_failure;
+	} else {
+		if (nla_put_u16(msg, IEEE802154_ATTR_SRC_SHORT_ADDR,
+				addr->short_addr))
+			goto nla_put_failure;
+	}
+	if (nla_put_u8(msg, IEEE802154_ATTR_REASON, reason))
+		goto nla_put_failure;
 	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
@@ -151,13 +151,12 @@ int ieee802154_nl_disassoc_confirm(struct net_device *dev, u8 status)
 	if (!msg)
 		return -ENOBUFS;
 
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-
-	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
-
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
+		    dev->dev_addr) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_STATUS, status))
+		goto nla_put_failure;
 	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
@@ -177,13 +176,13 @@ int ieee802154_nl_beacon_indic(struct net_device *dev,
 	if (!msg)
 		return -ENOBUFS;
 
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-	NLA_PUT_U16(msg, IEEE802154_ATTR_COORD_SHORT_ADDR, coord_addr);
-	NLA_PUT_U16(msg, IEEE802154_ATTR_COORD_PAN_ID, panid);
-
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
+		    dev->dev_addr) ||
+	    nla_put_u16(msg, IEEE802154_ATTR_COORD_SHORT_ADDR, coord_addr) ||
+	    nla_put_u16(msg, IEEE802154_ATTR_COORD_PAN_ID, panid))
+		goto nla_put_failure;
 	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
@@ -204,19 +203,17 @@ int ieee802154_nl_scan_confirm(struct net_device *dev,
 	if (!msg)
 		return -ENOBUFS;
 
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-
-	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
-	NLA_PUT_U8(msg, IEEE802154_ATTR_SCAN_TYPE, scan_type);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_CHANNELS, unscanned);
-	NLA_PUT_U8(msg, IEEE802154_ATTR_PAGE, page);
-
-	if (edl)
-		NLA_PUT(msg, IEEE802154_ATTR_ED_LIST, 27, edl);
-
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
+		    dev->dev_addr) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_STATUS, status) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_SCAN_TYPE, scan_type) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_CHANNELS, unscanned) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_PAGE, page) ||
+	    (edl &&
+	     nla_put(msg, IEEE802154_ATTR_ED_LIST, 27, edl)))
+		goto nla_put_failure;
 	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
@@ -235,13 +232,12 @@ int ieee802154_nl_start_confirm(struct net_device *dev, u8 status)
 	if (!msg)
 		return -ENOBUFS;
 
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-
-	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
-
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
+		    dev->dev_addr) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_STATUS, status))
+		goto nla_put_failure;
 	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
@@ -266,16 +262,16 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 pid,
 	phy = ieee802154_mlme_ops(dev)->get_phy(dev);
 	BUG_ON(!phy);
 
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy));
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-		dev->dev_addr);
-	NLA_PUT_U16(msg, IEEE802154_ATTR_SHORT_ADDR,
-		ieee802154_mlme_ops(dev)->get_short_addr(dev));
-	NLA_PUT_U16(msg, IEEE802154_ATTR_PAN_ID,
-		ieee802154_mlme_ops(dev)->get_pan_id(dev));
+	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
+	    nla_put_string(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy)) ||
+	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
+	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
+		    dev->dev_addr) ||
+	    nla_put_u16(msg, IEEE802154_ATTR_SHORT_ADDR,
+			ieee802154_mlme_ops(dev)->get_short_addr(dev)) ||
+	    nla_put_u16(msg, IEEE802154_ATTR_PAN_ID,
+			ieee802154_mlme_ops(dev)->get_pan_id(dev)))
+		goto nla_put_failure;
 	wpan_phy_put(phy);
 	return genlmsg_end(msg, hdr);
 
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index c64a38d..3bdc430 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -53,18 +53,18 @@ static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 pid,
 		goto out;
 
 	mutex_lock(&phy->pib_lock);
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy));
-
-	NLA_PUT_U8(msg, IEEE802154_ATTR_PAGE, phy->current_page);
-	NLA_PUT_U8(msg, IEEE802154_ATTR_CHANNEL, phy->current_channel);
+	if (nla_put_string(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy)) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_PAGE, phy->current_page) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_CHANNEL, phy->current_channel))
+		goto nla_put_failure;
 	for (i = 0; i < 32; i++) {
 		if (phy->channels_supported[i])
 			buf[pages++] = phy->channels_supported[i] | (i << 27);
 	}
-	if (pages)
-		NLA_PUT(msg, IEEE802154_ATTR_CHANNEL_PAGE_LIST,
-				pages * sizeof(uint32_t), buf);
-
+	if (pages &&
+	    nla_put(msg, IEEE802154_ATTR_CHANNEL_PAGE_LIST,
+		    pages * sizeof(uint32_t), buf))
+		goto nla_put_failure;
 	mutex_unlock(&phy->pib_lock);
 	kfree(buf);
 	return genlmsg_end(msg, hdr);
@@ -245,9 +245,9 @@ static int ieee802154_add_iface(struct sk_buff *skb,
 			goto dev_unregister;
 	}
 
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy));
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-
+	if (nla_put_string(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy)) ||
+	    nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name))
+		goto nla_put_failure;
 	dev_put(dev);
 
 	wpan_phy_put(phy);
@@ -333,10 +333,9 @@ static int ieee802154_del_iface(struct sk_buff *skb,
 
 	rtnl_unlock();
 
-
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy));
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, name);
-
+	if (nla_put_string(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy)) ||
+	    nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, name))
+		goto nla_put_failure;
 	wpan_phy_put(phy);
 
 	return ieee802154_nl_reply(msg, info);
-- 
1.7.7.6
