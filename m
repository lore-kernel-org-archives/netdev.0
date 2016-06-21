From: Thomas Rowland <trowland2000@gmail.com>
Subject: [PATCH] include: net: cfg802154: rename ieee802154_llsec_device.hwaddr to extended_addr
Date: Tue, 21 Jun 2016 03:22:28 -0700
Message-ID: <1466504548-2958-1-git-send-email-trowland2000@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Rowland <trowland2000@gmail.com>
To: aar@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33302 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648AbcFUKXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 06:23:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Renamed the ieee802154_llsec_device member 'hwaddr' to 'extended_addr'

Signed-off-by: Thomas Rowland <trowland2000@gmail.com>
---
 include/net/cfg802154.h   |  2 +-
 net/ieee802154/nl802154.c | 15 +++++----------
 net/mac802154/llsec.c     |  4 ++--
 3 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/include/net/cfg802154.h b/include/net/cfg802154.h
index 171cd76..1b5bb10 100644
--- a/include/net/cfg802154.h
+++ b/include/net/cfg802154.h
@@ -292,7 +292,7 @@ struct ieee802154_llsec_device {
 
 	__le16 pan_id;
 	__le16 short_addr;
-	__le64 hwaddr;
+	__le64 extended_addr;
 	u32 frame_counter;
 	bool seclevel_exempt;
 
diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index 116187b..f0cb080 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -1628,7 +1628,7 @@ static int nl802154_send_device(struct sk_buff *msg, u32 cmd, u32 portid,
 	    nla_put_le16(msg, NL802154_DEV_ATTR_SHORT_ADDR,
 			 dev_desc->short_addr) ||
 	    nla_put_le64(msg, NL802154_DEV_ATTR_EXTENDED_ADDR,
-			 dev_desc->hwaddr, NL802154_DEV_ATTR_PAD) ||
+			 dev_desc->extended_addr, NL802154_DEV_ATTR_PAD) ||
 	    nla_put_u8(msg, NL802154_DEV_ATTR_SECLEVEL_EXEMPT,
 		       dev_desc->seclevel_exempt) ||
 	    nla_put_u32(msg, NL802154_DEV_ATTR_KEY_MODE, dev_desc->key_mode))
@@ -1725,8 +1725,7 @@ ieee802154_llsec_parse_device(struct nlattr *nla,
 	dev->frame_counter = nla_get_u32(attrs[NL802154_DEV_ATTR_FRAME_COUNTER]);
 	dev->pan_id = nla_get_le16(attrs[NL802154_DEV_ATTR_PAN_ID]);
 	dev->short_addr = nla_get_le16(attrs[NL802154_DEV_ATTR_SHORT_ADDR]);
-	/* TODO rename hwaddr to extended_addr */
-	dev->hwaddr = nla_get_le64(attrs[NL802154_DEV_ATTR_EXTENDED_ADDR]);
+	dev->extended_addr = nla_get_le64(attrs[NL802154_DEV_ATTR_EXTENDED_ADDR]);
 	dev->seclevel_exempt = nla_get_u8(attrs[NL802154_DEV_ATTR_SECLEVEL_EXEMPT]);
 	dev->key_mode = nla_get_u32(attrs[NL802154_DEV_ATTR_KEY_MODE]);
 
@@ -1850,7 +1849,7 @@ nl802154_dump_llsec_devkey(struct sk_buff *skb, struct netlink_callback *cb)
 						 cb->nlh->nlmsg_seq,
 						 NLM_F_MULTI, rdev,
 						 wpan_dev->netdev,
-						 dpos->hwaddr,
+						 dpos->extended_addr,
 						 kpos) < 0) {
 				/* TODO */
 				err = -EIO;
@@ -1903,9 +1902,7 @@ static int nl802154_add_llsec_devkey(struct sk_buff *skb, struct genl_info *info
 
 	/* TODO be32 */
 	key.frame_counter = nla_get_u32(attrs[NL802154_DEVKEY_ATTR_FRAME_COUNTER]);
-	/* TODO change naming hwaddr -> extended_addr
-	 * check unique identifier short+pan OR extended_addr
-	 */
+	/* TODO check unique identifier short+pan OR extended_addr */
 	extended_addr = nla_get_le64(attrs[NL802154_DEVKEY_ATTR_EXTENDED_ADDR]);
 	return rdev_add_devkey(rdev, wpan_dev, extended_addr, &key);
 }
@@ -1932,9 +1929,7 @@ static int nl802154_del_llsec_devkey(struct sk_buff *skb, struct genl_info *info
 					  &key.key_id) < 0)
 		return -ENOBUFS;
 
-	/* TODO change naming hwaddr -> extended_addr
-	 * check unique identifier short+pan OR extended_addr
-	 */
+	/* TODO check unique identifier short+pan OR extended_addr */
 	extended_addr = nla_get_le64(attrs[NL802154_DEVKEY_ATTR_EXTENDED_ADDR]);
 	return rdev_del_devkey(rdev, wpan_dev, extended_addr, &key);
 }
diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
index 6a3e1c2..e8a1f76 100644
--- a/net/mac802154/llsec.c
+++ b/net/mac802154/llsec.c
@@ -358,13 +358,13 @@ int mac802154_llsec_dev_add(struct mac802154_llsec *sec,
 {
 	struct mac802154_llsec_device *entry;
 	u32 skey = llsec_dev_hash_short(dev->short_addr, dev->pan_id);
-	u64 hwkey = llsec_dev_hash_long(dev->hwaddr);
+	u64 hwkey = llsec_dev_hash_long(dev->extended_addr);
 
 	BUILD_BUG_ON(sizeof(hwkey) != IEEE802154_ADDR_LEN);
 
 	if ((llsec_dev_use_shortaddr(dev->short_addr) &&
 	     llsec_dev_find_short(sec, dev->short_addr, dev->pan_id)) ||
-	     llsec_dev_find_long(sec, dev->hwaddr))
+	     llsec_dev_find_long(sec, dev->extended_addr))
 		return -EEXIST;
 
 	entry = kmalloc(sizeof(*entry), GFP_KERNEL);
-- 
2.1.4
