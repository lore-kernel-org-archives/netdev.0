From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/16] mlxsw: item: Add MLXSW_ITEM_BUF_INDEXED helper
Date: Fri, 16 Oct 2015 14:01:27 +0200
Message-ID: <1444996897-2708-7-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36983 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990AbbJPMBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:50 -0400
Received: by wijq8 with SMTP id q8so7281394wij.0
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:48 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add missing item helper which allows to access char bufs on multiple
offsets. This is needed by SFD and SFN register definitions.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/item.h | 46 ++++++++++++++++++++++++++----
 1 file changed, 40 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/item.h b/drivers/net/ethernet/mellanox/mlxsw/item.h
index b6ee807..a94dbda6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/item.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/item.h
@@ -171,15 +171,21 @@ static inline void __mlxsw_item_set64(char *buf, struct mlxsw_item *item,
 }
 
 static inline void __mlxsw_item_memcpy_from(char *buf, char *dst,
-					    struct mlxsw_item *item)
+					    struct mlxsw_item *item,
+					    unsigned short index)
 {
-	memcpy(dst, &buf[item->offset], item->size.bytes);
+	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(char));
+
+	memcpy(dst, &buf[offset], item->size.bytes);
 }
 
 static inline void __mlxsw_item_memcpy_to(char *buf, const char *src,
-					  struct mlxsw_item *item)
+					  struct mlxsw_item *item,
+					  unsigned short index)
 {
-	memcpy(&buf[item->offset], src, item->size.bytes);
+	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(char));
+
+	memcpy(&buf[offset], src, item->size.bytes);
 }
 
 static inline u16
@@ -373,12 +379,40 @@ static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
 static inline void								\
 mlxsw_##_type##_##_cname##_##_iname##_memcpy_from(char *buf, char *dst)		\
 {										\
-	__mlxsw_item_memcpy_from(buf, dst, &__ITEM_NAME(_type, _cname, _iname));\
+	__mlxsw_item_memcpy_from(buf, dst,					\
+				 &__ITEM_NAME(_type, _cname, _iname), 0);	\
 }										\
 static inline void								\
 mlxsw_##_type##_##_cname##_##_iname##_memcpy_to(char *buf, const char *src)	\
 {										\
-	__mlxsw_item_memcpy_to(buf, src, &__ITEM_NAME(_type, _cname, _iname));	\
+	__mlxsw_item_memcpy_to(buf, src,					\
+			       &__ITEM_NAME(_type, _cname, _iname), 0);		\
+}
+
+#define MLXSW_ITEM_BUF_INDEXED(_type, _cname, _iname, _offset, _sizebytes,	\
+			       _step, _instepoffset)				\
+static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
+	.offset = _offset,							\
+	.step = _step,								\
+	.in_step_offset = _instepoffset,					\
+	.size = {.bytes = _sizebytes,},						\
+	.name = #_type "_" #_cname "_" #_iname,					\
+};										\
+static inline void								\
+mlxsw_##_type##_##_cname##_##_iname##_memcpy_from(char *buf,			\
+						  unsigned short index,		\
+						  char *dst)			\
+{										\
+	__mlxsw_item_memcpy_from(buf, dst,					\
+				 &__ITEM_NAME(_type, _cname, _iname), index);	\
+}										\
+static inline void								\
+mlxsw_##_type##_##_cname##_##_iname##_memcpy_to(char *buf,			\
+						unsigned short index,		\
+						const char *src)		\
+{										\
+	__mlxsw_item_memcpy_to(buf, src,					\
+			       &__ITEM_NAME(_type, _cname, _iname), index);	\
 }
 
 #define MLXSW_ITEM_BIT_ARRAY(_type, _cname, _iname, _offset, _sizebytes,	\
-- 
1.9.3
