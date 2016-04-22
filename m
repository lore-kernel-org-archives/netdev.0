From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/9] libnl: nla_put_le64(): align on a 64-bit area
Date: Fri, 22 Apr 2016 17:31:17 +0200
Message-ID: <1461339084-3849-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	linux-wpan@vger.kernel.org, aar@pengutronix.de,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, bsingharora@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:53562 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847AbcDVPcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 11:32:03 -0400
In-Reply-To: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nla_data() is now aligned on a 64-bit area.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/netlink.h     |  8 +++++---
 include/net/nl802154.h    |  6 ++++++
 net/ieee802154/nl802154.c | 13 ++++++++-----
 3 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 6f51a8a06498..7f6b99483ab7 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -878,14 +878,16 @@ static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value)
 }
 
 /**
- * nla_put_le64 - Add a __le64 netlink attribute to a socket buffer
+ * nla_put_le64 - Add a __le64 netlink attribute to a socket buffer and align it
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
  * @value: numeric value
+ * @padattr: attribute type for the padding
  */
-static inline int nla_put_le64(struct sk_buff *skb, int attrtype, __le64 value)
+static inline int nla_put_le64(struct sk_buff *skb, int attrtype, __le64 value,
+			       int padattr)
 {
-	return nla_put(skb, attrtype, sizeof(__le64), &value);
+	return nla_put_64bit(skb, attrtype, sizeof(__le64), &value, padattr);
 }
 
 /**
diff --git a/include/net/nl802154.h b/include/net/nl802154.h
index 32cb3e591e07..fcab4de49951 100644
--- a/include/net/nl802154.h
+++ b/include/net/nl802154.h
@@ -138,6 +138,8 @@ enum nl802154_attrs {
 	NL802154_ATTR_SEC_KEY,
 #endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
 
+	NL802154_ATTR_PAD,
+
 	__NL802154_ATTR_AFTER_LAST,
 	NL802154_ATTR_MAX = __NL802154_ATTR_AFTER_LAST - 1
 };
@@ -295,6 +297,7 @@ enum nl802154_dev_addr_attrs {
 	NL802154_DEV_ADDR_ATTR_MODE,
 	NL802154_DEV_ADDR_ATTR_SHORT,
 	NL802154_DEV_ADDR_ATTR_EXTENDED,
+	NL802154_DEV_ADDR_ATTR_PAD,
 
 	/* keep last */
 	__NL802154_DEV_ADDR_ATTR_AFTER_LAST,
@@ -320,6 +323,7 @@ enum nl802154_key_id_attrs {
 	NL802154_KEY_ID_ATTR_IMPLICIT,
 	NL802154_KEY_ID_ATTR_SOURCE_SHORT,
 	NL802154_KEY_ID_ATTR_SOURCE_EXTENDED,
+	NL802154_KEY_ID_ATTR_PAD,
 
 	/* keep last */
 	__NL802154_KEY_ID_ATTR_AFTER_LAST,
@@ -402,6 +406,7 @@ enum nl802154_dev {
 	NL802154_DEV_ATTR_EXTENDED_ADDR,
 	NL802154_DEV_ATTR_SECLEVEL_EXEMPT,
 	NL802154_DEV_ATTR_KEY_MODE,
+	NL802154_DEV_ATTR_PAD,
 
 	/* keep last */
 	__NL802154_DEV_ATTR_AFTER_LAST,
@@ -414,6 +419,7 @@ enum nl802154_devkey {
 	NL802154_DEVKEY_ATTR_FRAME_COUNTER,
 	NL802154_DEVKEY_ATTR_EXTENDED_ADDR,
 	NL802154_DEVKEY_ATTR_ID,
+	NL802154_DEVKEY_ATTR_PAD,
 
 	/* keep last */
 	__NL802154_DEVKEY_ATTR_AFTER_LAST,
diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index 16ef0d9f566e..614072064d03 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -722,7 +722,8 @@ ieee802154_llsec_send_key_id(struct sk_buff *msg,
 			break;
 		case NL802154_DEV_ADDR_EXTENDED:
 			if (nla_put_le64(msg, NL802154_DEV_ADDR_ATTR_EXTENDED,
-					 desc->device_addr.extended_addr))
+					 desc->device_addr.extended_addr,
+					 NL802154_DEV_ADDR_ATTR_PAD))
 				return -ENOBUFS;
 			break;
 		default:
@@ -742,7 +743,8 @@ ieee802154_llsec_send_key_id(struct sk_buff *msg,
 		break;
 	case NL802154_KEY_ID_MODE_INDEX_EXTENDED:
 		if (nla_put_le64(msg, NL802154_KEY_ID_ATTR_SOURCE_EXTENDED,
-				 desc->extended_source))
+				 desc->extended_source,
+				 NL802154_KEY_ID_ATTR_PAD))
 			return -ENOBUFS;
 		break;
 	default:
@@ -819,7 +821,8 @@ nl802154_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flags,
 
 	/* address settings */
 	if (nla_put_le64(msg, NL802154_ATTR_EXTENDED_ADDR,
-			 wpan_dev->extended_addr) ||
+			 wpan_dev->extended_addr,
+			 NL802154_ATTR_PAD) ||
 	    nla_put_le16(msg, NL802154_ATTR_SHORT_ADDR,
 			 wpan_dev->short_addr) ||
 	    nla_put_le16(msg, NL802154_ATTR_PAN_ID, wpan_dev->pan_id))
@@ -1614,7 +1617,7 @@ static int nl802154_send_device(struct sk_buff *msg, u32 cmd, u32 portid,
 	    nla_put_le16(msg, NL802154_DEV_ATTR_SHORT_ADDR,
 			 dev_desc->short_addr) ||
 	    nla_put_le64(msg, NL802154_DEV_ATTR_EXTENDED_ADDR,
-			 dev_desc->hwaddr) ||
+			 dev_desc->hwaddr, NL802154_DEV_ATTR_PAD) ||
 	    nla_put_u8(msg, NL802154_DEV_ATTR_SECLEVEL_EXEMPT,
 		       dev_desc->seclevel_exempt) ||
 	    nla_put_u32(msg, NL802154_DEV_ATTR_KEY_MODE, dev_desc->key_mode))
@@ -1778,7 +1781,7 @@ static int nl802154_send_devkey(struct sk_buff *msg, u32 cmd, u32 portid,
 		goto nla_put_failure;
 
 	if (nla_put_le64(msg, NL802154_DEVKEY_ATTR_EXTENDED_ADDR,
-			 extended_addr) ||
+			 extended_addr, NL802154_DEVKEY_ATTR_PAD) ||
 	    nla_put_u32(msg, NL802154_DEVKEY_ATTR_FRAME_COUNTER,
 			devkey->frame_counter))
 		goto nla_put_failure;
-- 
2.8.1
