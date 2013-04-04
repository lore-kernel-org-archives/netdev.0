From: Werner Almesberger <werner@almesberger.net>
Subject: [PATCH net-next 2/2] ieee802154/nl-mac.c: make some MLME operations
 optional
Date: Thu, 4 Apr 2013 13:32:35 -0300
Message-ID: <1f81253db3f5f1fc8783bb9fd3304ea8e76faaaf.1365092820.git.werner@almesberger.net>
References: <cover.1365092820.git.werner@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.openmoko.org ([88.198.124.205]:38758 "EHLO
	mail.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763239Ab3DDQdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 12:33:35 -0400
Content-Disposition: inline
In-Reply-To: <cover.1365092820.git.werner@almesberger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for NULL before calling the following operations from "struct
ieee802154_mlme_ops": assoc_req, assoc_resp, disassoc_req, start_req,
and scan_req.

This fixes a current oops where those functions are called but not
implemented. It also updates the documentation to clarify that they
are now optional by design. If a call to an unimplemented function
is attempted, the kernel returns EOPNOTSUPP via netlink.

The following operations are still required: get_phy, get_pan_id,
get_short_addr, and get_dsn.

Note that the places where this patch changes the initialization
of "ret" should not affect the rest of the code since "ret" was
always set (again) before returning its value.

Signed-off-by: Werner Almesberger <werner@almesberger.net>
---
 Documentation/networking/ieee802154.txt |    5 +++--
 include/net/ieee802154_netdev.h         |    4 ++++
 net/ieee802154/nl-mac.c                 |   25 ++++++++++++++++++++-----
 3 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/ieee802154.txt b/Documentation/networking/ieee802154.txt
index 703cf43..67a9cb2 100644
--- a/Documentation/networking/ieee802154.txt
+++ b/Documentation/networking/ieee802154.txt
@@ -71,8 +71,9 @@ submits skb to qdisc), so if you need something from that cb later, you should
 store info in the skb->data on your own.
 
 To hook the MLME interface you have to populate the ml_priv field of your
-net_device with a pointer to struct ieee802154_mlme_ops instance. All fields are
-required.
+net_device with a pointer to struct ieee802154_mlme_ops instance. The fields
+assoc_req, assoc_resp, disassoc_req, start_req, and scan_req are optional.
+All other fields are required.
 
 We provide an example of simple HardMAC driver at drivers/ieee802154/fakehard.c
 
diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 642f94c..8196d5d 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -85,6 +85,8 @@ struct wpan_phy;
  * Use wpan_wpy_put to put that reference.
  */
 struct ieee802154_mlme_ops {
+	/* The following fields are optional (can be NULL). */
+
 	int (*assoc_req)(struct net_device *dev,
 			struct ieee802154_addr *addr,
 			u8 channel, u8 page, u8 cap);
@@ -101,6 +103,8 @@ struct ieee802154_mlme_ops {
 	int (*scan_req)(struct net_device *dev,
 			u8 type, u32 channels, u8 page, u8 duration);
 
+	/* The fields below are required. */
+
 	struct wpan_phy *(*get_phy)(const struct net_device *dev);
 
 	/*
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index 96bb08a..b0bdd8c 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -315,7 +315,7 @@ static int ieee802154_associate_req(struct sk_buff *skb,
 	struct net_device *dev;
 	struct ieee802154_addr addr;
 	u8 page;
-	int ret = -EINVAL;
+	int ret = -EOPNOTSUPP;
 
 	if (!info->attrs[IEEE802154_ATTR_CHANNEL] ||
 	    !info->attrs[IEEE802154_ATTR_COORD_PAN_ID] ||
@@ -327,6 +327,8 @@ static int ieee802154_associate_req(struct sk_buff *skb,
 	dev = ieee802154_nl_get_dev(info);
 	if (!dev)
 		return -ENODEV;
+	if (!ieee802154_mlme_ops(dev)->assoc_req)
+		goto out;
 
 	if (info->attrs[IEEE802154_ATTR_COORD_HW_ADDR]) {
 		addr.addr_type = IEEE802154_ADDR_LONG;
@@ -350,6 +352,7 @@ static int ieee802154_associate_req(struct sk_buff *skb,
 			page,
 			nla_get_u8(info->attrs[IEEE802154_ATTR_CAPABILITY]));
 
+out:
 	dev_put(dev);
 	return ret;
 }
@@ -359,7 +362,7 @@ static int ieee802154_associate_resp(struct sk_buff *skb,
 {
 	struct net_device *dev;
 	struct ieee802154_addr addr;
-	int ret = -EINVAL;
+	int ret = -EOPNOTSUPP;
 
 	if (!info->attrs[IEEE802154_ATTR_STATUS] ||
 	    !info->attrs[IEEE802154_ATTR_DEST_HW_ADDR] ||
@@ -369,6 +372,8 @@ static int ieee802154_associate_resp(struct sk_buff *skb,
 	dev = ieee802154_nl_get_dev(info);
 	if (!dev)
 		return -ENODEV;
+	if (!ieee802154_mlme_ops(dev)->assoc_resp)
+		goto out;
 
 	addr.addr_type = IEEE802154_ADDR_LONG;
 	nla_memcpy(addr.hwaddr, info->attrs[IEEE802154_ATTR_DEST_HW_ADDR],
@@ -380,6 +385,7 @@ static int ieee802154_associate_resp(struct sk_buff *skb,
 		nla_get_u16(info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]),
 		nla_get_u8(info->attrs[IEEE802154_ATTR_STATUS]));
 
+out:
 	dev_put(dev);
 	return ret;
 }
@@ -389,7 +395,7 @@ static int ieee802154_disassociate_req(struct sk_buff *skb,
 {
 	struct net_device *dev;
 	struct ieee802154_addr addr;
-	int ret = -EINVAL;
+	int ret = -EOPNOTSUPP;
 
 	if ((!info->attrs[IEEE802154_ATTR_DEST_HW_ADDR] &&
 		!info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]) ||
@@ -399,6 +405,8 @@ static int ieee802154_disassociate_req(struct sk_buff *skb,
 	dev = ieee802154_nl_get_dev(info);
 	if (!dev)
 		return -ENODEV;
+	if (!ieee802154_mlme_ops(dev)->disassoc_req)
+		goto out;
 
 	if (info->attrs[IEEE802154_ATTR_DEST_HW_ADDR]) {
 		addr.addr_type = IEEE802154_ADDR_LONG;
@@ -415,6 +423,7 @@ static int ieee802154_disassociate_req(struct sk_buff *skb,
 	ret = ieee802154_mlme_ops(dev)->disassoc_req(dev, &addr,
 			nla_get_u8(info->attrs[IEEE802154_ATTR_REASON]));
 
+out:
 	dev_put(dev);
 	return ret;
 }
@@ -432,7 +441,7 @@ static int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
 	u8 channel, bcn_ord, sf_ord;
 	u8 page;
 	int pan_coord, blx, coord_realign;
-	int ret;
+	int ret = -EOPNOTSUPP;
 
 	if (!info->attrs[IEEE802154_ATTR_COORD_PAN_ID] ||
 	    !info->attrs[IEEE802154_ATTR_COORD_SHORT_ADDR] ||
@@ -448,6 +457,8 @@ static int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
 	dev = ieee802154_nl_get_dev(info);
 	if (!dev)
 		return -ENODEV;
+	if (!ieee802154_mlme_ops(dev)->start_req)
+		goto out;
 
 	addr.addr_type = IEEE802154_ADDR_SHORT;
 	addr.short_addr = nla_get_u16(
@@ -476,6 +487,7 @@ static int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
 	ret = ieee802154_mlme_ops(dev)->start_req(dev, &addr, channel, page,
 		bcn_ord, sf_ord, pan_coord, blx, coord_realign);
 
+out:
 	dev_put(dev);
 	return ret;
 }
@@ -483,7 +495,7 @@ static int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
 static int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
-	int ret;
+	int ret = -EOPNOTSUPP;
 	u8 type;
 	u32 channels;
 	u8 duration;
@@ -497,6 +509,8 @@ static int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info)
 	dev = ieee802154_nl_get_dev(info);
 	if (!dev)
 		return -ENODEV;
+	if (!ieee802154_mlme_ops(dev)->scan_req)
+		goto out;
 
 	type = nla_get_u8(info->attrs[IEEE802154_ATTR_SCAN_TYPE]);
 	channels = nla_get_u32(info->attrs[IEEE802154_ATTR_CHANNELS]);
@@ -511,6 +525,7 @@ static int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info)
 	ret = ieee802154_mlme_ops(dev)->scan_req(dev, type, channels, page,
 			duration);
 
+out:
 	dev_put(dev);
 	return ret;
 }
-- 
1.7.10.4
