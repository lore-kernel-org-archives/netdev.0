From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 01/19] mlxsw: item: Add 8bit item helpers
Date: Fri,  3 Feb 2017 10:28:51 +0100
Message-ID: <1486114149-7941-2-git-send-email-jiri@resnulli.us>
References: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com, tom@herbertland.com,
        f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34768 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752069AbdBCJ3N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:29:13 -0500
Received: by mail-wm0-f66.google.com with SMTP id c85so3102662wmi.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 01:29:12 -0800 (PST)
In-Reply-To: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Item heplers for 8bit values are needed, let's add them.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/item.h | 79 +++++++++++++++++++++++++++++-
 1 file changed, 77 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/item.h b/drivers/net/ethernet/mellanox/mlxsw/item.h
index 3c95e3d..09f35de 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/item.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/item.h
@@ -1,7 +1,7 @@
 /*
  * drivers/net/ethernet/mellanox/mlxsw/item.h
- * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
- * Copyright (c) 2015 Jiri Pirko <jiri@mellanox.com>
+ * Copyright (c) 2015-2017 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2015-2017 Jiri Pirko <jiri@mellanox.com>
  * Copyright (c) 2015 Ido Schimmel <idosch@mellanox.com>
  *
  * Redistribution and use in source and binary forms, with or without
@@ -72,6 +72,40 @@ __mlxsw_item_offset(const struct mlxsw_item *item, unsigned short index,
 		typesize);
 }
 
+static inline u8 __mlxsw_item_get8(const char *buf,
+				   const struct mlxsw_item *item,
+				   unsigned short index)
+{
+	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(u8));
+	u8 *b = (u8 *) buf;
+	u8 tmp;
+
+	tmp = b[offset];
+	tmp >>= item->shift;
+	tmp &= GENMASK(item->size.bits - 1, 0);
+	if (item->no_real_shift)
+		tmp <<= item->shift;
+	return tmp;
+}
+
+static inline void __mlxsw_item_set8(char *buf, const struct mlxsw_item *item,
+				     unsigned short index, u8 val)
+{
+	unsigned int offset = __mlxsw_item_offset(item, index,
+						  sizeof(u8));
+	u8 *b = (u8 *) buf;
+	u8 mask = GENMASK(item->size.bits - 1, 0) << item->shift;
+	u8 tmp;
+
+	if (!item->no_real_shift)
+		val <<= item->shift;
+	val &= mask;
+	tmp = b[offset];
+	tmp &= ~mask;
+	tmp |= val;
+	b[offset] = tmp;
+}
+
 static inline u16 __mlxsw_item_get16(const char *buf,
 				     const struct mlxsw_item *item,
 				     unsigned short index)
@@ -253,6 +287,47 @@ static inline void __mlxsw_item_bit_array_set(char *buf,
  * _iname: item name within the container
  */
 
+#define MLXSW_ITEM8(_type, _cname, _iname, _offset, _shift, _sizebits)		\
+static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
+	.offset = _offset,							\
+	.shift = _shift,							\
+	.size = {.bits = _sizebits,},						\
+	.name = #_type "_" #_cname "_" #_iname,					\
+};										\
+static inline u8 mlxsw_##_type##_##_cname##_##_iname##_get(const char *buf)	\
+{										\
+	return __mlxsw_item_get8(buf, &__ITEM_NAME(_type, _cname, _iname), 0);	\
+}										\
+static inline void mlxsw_##_type##_##_cname##_##_iname##_set(char *buf, u8 val)\
+{										\
+	__mlxsw_item_set8(buf, &__ITEM_NAME(_type, _cname, _iname), 0, val);	\
+}
+
+#define MLXSW_ITEM8_INDEXED(_type, _cname, _iname, _offset, _shift, _sizebits,	\
+			    _step, _instepoffset, _norealshift)			\
+static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
+	.offset = _offset,							\
+	.step = _step,								\
+	.in_step_offset = _instepoffset,					\
+	.shift = _shift,							\
+	.no_real_shift = _norealshift,						\
+	.size = {.bits = _sizebits,},						\
+	.name = #_type "_" #_cname "_" #_iname,					\
+};										\
+static inline u8								\
+mlxsw_##_type##_##_cname##_##_iname##_get(const char *buf, unsigned short index)\
+{										\
+	return __mlxsw_item_get8(buf, &__ITEM_NAME(_type, _cname, _iname),	\
+				 index);					\
+}										\
+static inline void								\
+mlxsw_##_type##_##_cname##_##_iname##_set(char *buf, unsigned short index,	\
+					  u8 val)				\
+{										\
+	__mlxsw_item_set8(buf, &__ITEM_NAME(_type, _cname, _iname),		\
+			  index, val);						\
+}
+
 #define MLXSW_ITEM16(_type, _cname, _iname, _offset, _shift, _sizebits)		\
 static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
 	.offset = _offset,							\
-- 
2.7.4
