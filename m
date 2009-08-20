From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/5] ieee802154: add support for
	channel pages from IEEE 802.15.4-2006
Date: Thu, 20 Aug 2009 20:13:06 +0400
Message-ID: <1250784787-30590-5-git-send-email-dbaryshkov@gmail.com>
References: <1250784787-30590-1-git-send-email-dbaryshkov@gmail.com>
	<1250784787-30590-2-git-send-email-dbaryshkov@gmail.com>
	<1250784787-30590-3-git-send-email-dbaryshkov@gmail.com>
	<1250784787-30590-4-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1250784787-30590-4-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

IEEE 802.15.4-2006 adds new concept: channel pages, which can contain several
channels. Add support for channel pages in the API and in the fakehard driver.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/ieee802154/fakehard.c   |   10 ++++++----
 include/linux/nl802154.h        |    2 ++
 include/net/ieee802154_netdev.h |    6 +++---
 include/net/nl802154.h          |    2 +-
 net/ieee802154/netlink.c        |   28 +++++++++++++++++++++++++---
 net/ieee802154/nl_policy.c      |    1 +
 6 files changed, 38 insertions(+), 11 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index 22a93bc..c1c9697 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -119,12 +119,13 @@ static u8 fake_get_bsn(struct net_device *dev)
  *       802.15.4-2006 document.
  */
 static int fake_assoc_req(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 channel, u8 cap)
+		struct ieee802154_addr *addr, u8 channel, u8 page, u8 cap)
 {
 	struct wpan_phy *phy = net_to_phy(dev);
 
 	mutex_lock(&phy->pib_lock);
 	phy->current_channel = channel;
+	phy->current_page = page;
 	mutex_unlock(&phy->pib_lock);
 
 	/* We simply emulate it here */
@@ -191,7 +192,7 @@ static int fake_disassoc_req(struct net_device *dev,
  * document, with 7.3.8 describing coordinator realignment.
  */
 static int fake_start_req(struct net_device *dev, struct ieee802154_addr *addr,
-				u8 channel,
+				u8 channel, u8 page,
 				u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
 				u8 coord_realign)
 {
@@ -199,6 +200,7 @@ static int fake_start_req(struct net_device *dev, struct ieee802154_addr *addr,
 
 	mutex_lock(&phy->pib_lock);
 	phy->current_channel = channel;
+	phy->current_page = page;
 	mutex_unlock(&phy->pib_lock);
 
 	/* We don't emulate beacons here at all, so START should fail */
@@ -222,11 +224,11 @@ static int fake_start_req(struct net_device *dev, struct ieee802154_addr *addr,
  * Note: This is in section 7.5.2.1 of the IEEE 802.15.4-2006 document.
  */
 static int fake_scan_req(struct net_device *dev, u8 type, u32 channels,
-		u8 duration)
+		u8 page, u8 duration)
 {
 	u8 edl[27] = {};
 	return ieee802154_nl_scan_confirm(dev, IEEE802154_SUCCESS, type,
-			channels,
+			channels, page,
 			type == IEEE802154_MAC_SCAN_ED ? edl : NULL);
 }
 
diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 9a1af5f..b7d9435 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -64,6 +64,8 @@ enum {
 	IEEE802154_ATTR_COORD_REALIGN,
 	IEEE802154_ATTR_SEC,
 
+	IEEE802154_ATTR_PAGE,
+
 	__IEEE802154_ATTR_MAX,
 };
 
diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index e2506af..5dc6a61 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -80,7 +80,7 @@ static inline int mac_cb_type(struct sk_buff *skb)
 struct ieee802154_mlme_ops {
 	int (*assoc_req)(struct net_device *dev,
 			struct ieee802154_addr *addr,
-			u8 channel, u8 cap);
+			u8 channel, u8 page, u8 cap);
 	int (*assoc_resp)(struct net_device *dev,
 			struct ieee802154_addr *addr,
 			u16 short_addr, u8 status);
@@ -89,10 +89,10 @@ struct ieee802154_mlme_ops {
 			u8 reason);
 	int (*start_req)(struct net_device *dev,
 			struct ieee802154_addr *addr,
-			u8 channel, u8 bcn_ord, u8 sf_ord,
+			u8 channel, u8 page, u8 bcn_ord, u8 sf_ord,
 			u8 pan_coord, u8 blx, u8 coord_realign);
 	int (*scan_req)(struct net_device *dev,
-			u8 type, u32 channels, u8 duration);
+			u8 type, u32 channels, u8 page, u8 duration);
 
 	/*
 	 * FIXME: these should become the part of PIB/MIB interface.
diff --git a/include/net/nl802154.h b/include/net/nl802154.h
index e554ecd..99d2ba1 100644
--- a/include/net/nl802154.h
+++ b/include/net/nl802154.h
@@ -95,7 +95,7 @@ int ieee802154_nl_disassoc_confirm(struct net_device *dev,
  * Note: This API does not permit the return of an active scan result.
  */
 int ieee802154_nl_scan_confirm(struct net_device *dev,
-		u8 status, u8 scan_type, u32 unscanned,
+		u8 status, u8 scan_type, u32 unscanned, u8 page,
 		u8 *edl/*, struct list_head *pan_desc_list */);
 
 /**
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index cd0567f..2106ecb 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -232,7 +232,7 @@ nla_put_failure:
 EXPORT_SYMBOL(ieee802154_nl_beacon_indic);
 
 int ieee802154_nl_scan_confirm(struct net_device *dev,
-		u8 status, u8 scan_type, u32 unscanned,
+		u8 status, u8 scan_type, u32 unscanned, u8 page,
 		u8 *edl/* , struct list_head *pan_desc_list */)
 {
 	struct sk_buff *msg;
@@ -251,6 +251,7 @@ int ieee802154_nl_scan_confirm(struct net_device *dev,
 	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
 	NLA_PUT_U8(msg, IEEE802154_ATTR_SCAN_TYPE, scan_type);
 	NLA_PUT_U32(msg, IEEE802154_ATTR_CHANNELS, unscanned);
+	NLA_PUT_U8(msg, IEEE802154_ATTR_PAGE, page);
 
 	if (edl)
 		NLA_PUT(msg, IEEE802154_ATTR_ED_LIST, 27, edl);
@@ -349,6 +350,7 @@ static int ieee802154_associate_req(struct sk_buff *skb,
 {
 	struct net_device *dev;
 	struct ieee802154_addr addr;
+	u8 page;
 	int ret = -EINVAL;
 
 	if (!info->attrs[IEEE802154_ATTR_CHANNEL] ||
@@ -374,8 +376,14 @@ static int ieee802154_associate_req(struct sk_buff *skb,
 	}
 	addr.pan_id = nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_PAN_ID]);
 
+	if (info->attrs[IEEE802154_ATTR_PAGE])
+		page = nla_get_u8(info->attrs[IEEE802154_ATTR_PAGE]);
+	else
+		page = 0;
+
 	ret = ieee802154_mlme_ops(dev)->assoc_req(dev, &addr,
 			nla_get_u8(info->attrs[IEEE802154_ATTR_CHANNEL]),
+			page,
 			nla_get_u8(info->attrs[IEEE802154_ATTR_CAPABILITY]));
 
 	dev_put(dev);
@@ -458,6 +466,7 @@ static int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
 	struct ieee802154_addr addr;
 
 	u8 channel, bcn_ord, sf_ord;
+	u8 page;
 	int pan_coord, blx, coord_realign;
 	int ret;
 
@@ -488,13 +497,19 @@ static int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
 	blx = nla_get_u8(info->attrs[IEEE802154_ATTR_BAT_EXT]);
 	coord_realign = nla_get_u8(info->attrs[IEEE802154_ATTR_COORD_REALIGN]);
 
+	if (info->attrs[IEEE802154_ATTR_PAGE])
+		page = nla_get_u8(info->attrs[IEEE802154_ATTR_PAGE]);
+	else
+		page = 0;
+
+
 	if (addr.short_addr == IEEE802154_ADDR_BROADCAST) {
 		ieee802154_nl_start_confirm(dev, IEEE802154_NO_SHORT_ADDRESS);
 		dev_put(dev);
 		return -EINVAL;
 	}
 
-	ret = ieee802154_mlme_ops(dev)->start_req(dev, &addr, channel,
+	ret = ieee802154_mlme_ops(dev)->start_req(dev, &addr, channel, page,
 		bcn_ord, sf_ord, pan_coord, blx, coord_realign);
 
 	dev_put(dev);
@@ -508,6 +523,7 @@ static int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info)
 	u8 type;
 	u32 channels;
 	u8 duration;
+	u8 page;
 
 	if (!info->attrs[IEEE802154_ATTR_SCAN_TYPE] ||
 	    !info->attrs[IEEE802154_ATTR_CHANNELS] ||
@@ -522,7 +538,13 @@ static int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info)
 	channels = nla_get_u32(info->attrs[IEEE802154_ATTR_CHANNELS]);
 	duration = nla_get_u8(info->attrs[IEEE802154_ATTR_DURATION]);
 
-	ret = ieee802154_mlme_ops(dev)->scan_req(dev, type, channels,
+	if (info->attrs[IEEE802154_ATTR_PAGE])
+		page = nla_get_u8(info->attrs[IEEE802154_ATTR_PAGE]);
+	else
+		page = 0;
+
+
+	ret = ieee802154_mlme_ops(dev)->scan_req(dev, type, channels, page,
 			duration);
 
 	dev_put(dev);
diff --git a/net/ieee802154/nl_policy.c b/net/ieee802154/nl_policy.c
index 83cb4cc..2363ebe 100644
--- a/net/ieee802154/nl_policy.c
+++ b/net/ieee802154/nl_policy.c
@@ -33,6 +33,7 @@ const struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
 	[IEEE802154_ATTR_HW_ADDR] = { .type = NLA_HW_ADDR, },
 	[IEEE802154_ATTR_PAN_ID] = { .type = NLA_U16, },
 	[IEEE802154_ATTR_CHANNEL] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_PAGE] = { .type = NLA_U8, },
 	[IEEE802154_ATTR_COORD_SHORT_ADDR] = { .type = NLA_U16, },
 	[IEEE802154_ATTR_COORD_HW_ADDR] = { .type = NLA_HW_ADDR, },
 	[IEEE802154_ATTR_COORD_PAN_ID] = { .type = NLA_U16, },
-- 
1.6.3.3


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
