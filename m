From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 04/13] rocker: push tlv processing into separate files
Date: Mon,  5 Oct 2015 19:43:57 +0200
Message-ID: <1444067046-27825-5-git-send-email-jiri@resnulli.us>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:38442 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbJERoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:44:15 -0400
Received: by wiclk2 with SMTP id lk2so125613376wic.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:44:13 -0700 (PDT)
In-Reply-To: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Carve out TLV processing helpers into separate files.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/Makefile      |   2 +-
 drivers/net/ethernet/rocker/rocker.h      |  27 ++++
 drivers/net/ethernet/rocker/rocker_main.c | 222 +-----------------------------
 drivers/net/ethernet/rocker/rocker_tlv.c  |  54 ++++++++
 drivers/net/ethernet/rocker/rocker_tlv.h  | 202 +++++++++++++++++++++++++++
 5 files changed, 286 insertions(+), 221 deletions(-)
 create mode 100644 drivers/net/ethernet/rocker/rocker.h
 create mode 100644 drivers/net/ethernet/rocker/rocker_tlv.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_tlv.h

diff --git a/drivers/net/ethernet/rocker/Makefile b/drivers/net/ethernet/rocker/Makefile
index 2bed423..47f3492 100644
--- a/drivers/net/ethernet/rocker/Makefile
+++ b/drivers/net/ethernet/rocker/Makefile
@@ -3,4 +3,4 @@
 #
 
 obj-$(CONFIG_ROCKER) += rocker.o
-rocker-y := rocker_main.o
+rocker-y := rocker_main.o rocker_tlv.o
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
new file mode 100644
index 0000000..650caa0
--- /dev/null
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -0,0 +1,27 @@
+/*
+ * drivers/net/ethernet/rocker/rocker.h - Rocker switch device driver
+ * Copyright (c) 2014-2015 Jiri Pirko <jiri@resnulli.us>
+ * Copyright (c) 2014 Scott Feldman <sfeldma@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _ROCKER_H
+#define _ROCKER_H
+
+#include <linux/types.h>
+
+#include "rocker_hw.h"
+
+struct rocker_desc_info {
+	char *data; /* mapped */
+	size_t data_size;
+	size_t tlv_size;
+	struct rocker_desc *desc;
+	dma_addr_t mapaddr;
+};
+
+#endif
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index b555926..c698653 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -40,6 +40,8 @@
 #include <generated/utsrelease.h>
 
 #include "rocker_hw.h"
+#include "rocker.h"
+#include "rocker_tlv.h"
 
 static const char rocker_driver_name[] = "rocker";
 
@@ -177,14 +179,6 @@ struct rocker_neigh_tbl_entry {
 	bool ttl_check;
 };
 
-struct rocker_desc_info {
-	char *data; /* mapped */
-	size_t data_size;
-	size_t tlv_size;
-	struct rocker_desc *desc;
-	dma_addr_t mapaddr;
-};
-
 struct rocker_dma_ring_info {
 	size_t size;
 	u32 head;
@@ -661,218 +655,6 @@ free_irq:
 	return err;
 }
 
-/******
- * TLV
- ******/
-
-#define ROCKER_TLV_ALIGNTO 8U
-#define ROCKER_TLV_ALIGN(len) \
-	(((len) + ROCKER_TLV_ALIGNTO - 1) & ~(ROCKER_TLV_ALIGNTO - 1))
-#define ROCKER_TLV_HDRLEN ROCKER_TLV_ALIGN(sizeof(struct rocker_tlv))
-
-/*  <------- ROCKER_TLV_HDRLEN -------> <--- ROCKER_TLV_ALIGN(payload) --->
- * +-----------------------------+- - -+- - - - - - - - - - - - - - -+- - -+
- * |             Header          | Pad |           Payload           | Pad |
- * |      (struct rocker_tlv)    | ing |                             | ing |
- * +-----------------------------+- - -+- - - - - - - - - - - - - - -+- - -+
- *  <--------------------------- tlv->len -------------------------->
- */
-
-static struct rocker_tlv *rocker_tlv_next(const struct rocker_tlv *tlv,
-					  int *remaining)
-{
-	int totlen = ROCKER_TLV_ALIGN(tlv->len);
-
-	*remaining -= totlen;
-	return (struct rocker_tlv *) ((char *) tlv + totlen);
-}
-
-static int rocker_tlv_ok(const struct rocker_tlv *tlv, int remaining)
-{
-	return remaining >= (int) ROCKER_TLV_HDRLEN &&
-	       tlv->len >= ROCKER_TLV_HDRLEN &&
-	       tlv->len <= remaining;
-}
-
-#define rocker_tlv_for_each(pos, head, len, rem)	\
-	for (pos = head, rem = len;			\
-	     rocker_tlv_ok(pos, rem);			\
-	     pos = rocker_tlv_next(pos, &(rem)))
-
-#define rocker_tlv_for_each_nested(pos, tlv, rem)	\
-	rocker_tlv_for_each(pos, rocker_tlv_data(tlv),	\
-			    rocker_tlv_len(tlv), rem)
-
-static int rocker_tlv_attr_size(int payload)
-{
-	return ROCKER_TLV_HDRLEN + payload;
-}
-
-static int rocker_tlv_total_size(int payload)
-{
-	return ROCKER_TLV_ALIGN(rocker_tlv_attr_size(payload));
-}
-
-static int rocker_tlv_padlen(int payload)
-{
-	return rocker_tlv_total_size(payload) - rocker_tlv_attr_size(payload);
-}
-
-static int rocker_tlv_type(const struct rocker_tlv *tlv)
-{
-	return tlv->type;
-}
-
-static void *rocker_tlv_data(const struct rocker_tlv *tlv)
-{
-	return (char *) tlv + ROCKER_TLV_HDRLEN;
-}
-
-static int rocker_tlv_len(const struct rocker_tlv *tlv)
-{
-	return tlv->len - ROCKER_TLV_HDRLEN;
-}
-
-static u8 rocker_tlv_get_u8(const struct rocker_tlv *tlv)
-{
-	return *(u8 *) rocker_tlv_data(tlv);
-}
-
-static u16 rocker_tlv_get_u16(const struct rocker_tlv *tlv)
-{
-	return *(u16 *) rocker_tlv_data(tlv);
-}
-
-static __be16 rocker_tlv_get_be16(const struct rocker_tlv *tlv)
-{
-	return *(__be16 *) rocker_tlv_data(tlv);
-}
-
-static u32 rocker_tlv_get_u32(const struct rocker_tlv *tlv)
-{
-	return *(u32 *) rocker_tlv_data(tlv);
-}
-
-static u64 rocker_tlv_get_u64(const struct rocker_tlv *tlv)
-{
-	return *(u64 *) rocker_tlv_data(tlv);
-}
-
-static void rocker_tlv_parse(const struct rocker_tlv **tb, int maxtype,
-			     const char *buf, int buf_len)
-{
-	const struct rocker_tlv *tlv;
-	const struct rocker_tlv *head = (const struct rocker_tlv *) buf;
-	int rem;
-
-	memset(tb, 0, sizeof(struct rocker_tlv *) * (maxtype + 1));
-
-	rocker_tlv_for_each(tlv, head, buf_len, rem) {
-		u32 type = rocker_tlv_type(tlv);
-
-		if (type > 0 && type <= maxtype)
-			tb[type] = tlv;
-	}
-}
-
-static void rocker_tlv_parse_nested(const struct rocker_tlv **tb, int maxtype,
-				    const struct rocker_tlv *tlv)
-{
-	rocker_tlv_parse(tb, maxtype, rocker_tlv_data(tlv),
-			 rocker_tlv_len(tlv));
-}
-
-static void rocker_tlv_parse_desc(const struct rocker_tlv **tb, int maxtype,
-				  const struct rocker_desc_info *desc_info)
-{
-	rocker_tlv_parse(tb, maxtype, desc_info->data,
-			 desc_info->desc->tlv_size);
-}
-
-static struct rocker_tlv *rocker_tlv_start(struct rocker_desc_info *desc_info)
-{
-	return (struct rocker_tlv *) ((char *) desc_info->data +
-					       desc_info->tlv_size);
-}
-
-static int rocker_tlv_put(struct rocker_desc_info *desc_info,
-			  int attrtype, int attrlen, const void *data)
-{
-	int tail_room = desc_info->data_size - desc_info->tlv_size;
-	int total_size = rocker_tlv_total_size(attrlen);
-	struct rocker_tlv *tlv;
-
-	if (unlikely(tail_room < total_size))
-		return -EMSGSIZE;
-
-	tlv = rocker_tlv_start(desc_info);
-	desc_info->tlv_size += total_size;
-	tlv->type = attrtype;
-	tlv->len = rocker_tlv_attr_size(attrlen);
-	memcpy(rocker_tlv_data(tlv), data, attrlen);
-	memset((char *) tlv + tlv->len, 0, rocker_tlv_padlen(attrlen));
-	return 0;
-}
-
-static int rocker_tlv_put_u8(struct rocker_desc_info *desc_info,
-			     int attrtype, u8 value)
-{
-	return rocker_tlv_put(desc_info, attrtype, sizeof(u8), &value);
-}
-
-static int rocker_tlv_put_u16(struct rocker_desc_info *desc_info,
-			      int attrtype, u16 value)
-{
-	return rocker_tlv_put(desc_info, attrtype, sizeof(u16), &value);
-}
-
-static int rocker_tlv_put_be16(struct rocker_desc_info *desc_info,
-			       int attrtype, __be16 value)
-{
-	return rocker_tlv_put(desc_info, attrtype, sizeof(__be16), &value);
-}
-
-static int rocker_tlv_put_u32(struct rocker_desc_info *desc_info,
-			      int attrtype, u32 value)
-{
-	return rocker_tlv_put(desc_info, attrtype, sizeof(u32), &value);
-}
-
-static int rocker_tlv_put_be32(struct rocker_desc_info *desc_info,
-			       int attrtype, __be32 value)
-{
-	return rocker_tlv_put(desc_info, attrtype, sizeof(__be32), &value);
-}
-
-static int rocker_tlv_put_u64(struct rocker_desc_info *desc_info,
-			      int attrtype, u64 value)
-{
-	return rocker_tlv_put(desc_info, attrtype, sizeof(u64), &value);
-}
-
-static struct rocker_tlv *
-rocker_tlv_nest_start(struct rocker_desc_info *desc_info, int attrtype)
-{
-	struct rocker_tlv *start = rocker_tlv_start(desc_info);
-
-	if (rocker_tlv_put(desc_info, attrtype, 0, NULL) < 0)
-		return NULL;
-
-	return start;
-}
-
-static void rocker_tlv_nest_end(struct rocker_desc_info *desc_info,
-				struct rocker_tlv *start)
-{
-	start->len = (char *) rocker_tlv_start(desc_info) - (char *) start;
-}
-
-static void rocker_tlv_nest_cancel(struct rocker_desc_info *desc_info,
-				   const struct rocker_tlv *start)
-{
-	desc_info->tlv_size = (const char *) start - desc_info->data;
-}
-
 /******************************************
  * DMA rings and descriptors manipulations
  ******************************************/
diff --git a/drivers/net/ethernet/rocker/rocker_tlv.c b/drivers/net/ethernet/rocker/rocker_tlv.c
new file mode 100644
index 0000000..5b94d93
--- /dev/null
+++ b/drivers/net/ethernet/rocker/rocker_tlv.c
@@ -0,0 +1,54 @@
+/*
+ * drivers/net/ethernet/rocker/rocker_tvl.c - Rocker switch device driver
+ * Copyright (c) 2014-2015 Jiri Pirko <jiri@resnulli.us>
+ * Copyright (c) 2014 Scott Feldman <sfeldma@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+
+#include "rocker_hw.h"
+#include "rocker_tlv.h"
+
+void rocker_tlv_parse(const struct rocker_tlv **tb, int maxtype,
+		      const char *buf, int buf_len)
+{
+	const struct rocker_tlv *tlv;
+	const struct rocker_tlv *head = (const struct rocker_tlv *) buf;
+	int rem;
+
+	memset(tb, 0, sizeof(struct rocker_tlv *) * (maxtype + 1));
+
+	rocker_tlv_for_each(tlv, head, buf_len, rem) {
+		u32 type = rocker_tlv_type(tlv);
+
+		if (type > 0 && type <= maxtype)
+			tb[type] = tlv;
+	}
+}
+
+int rocker_tlv_put(struct rocker_desc_info *desc_info,
+		   int attrtype, int attrlen, const void *data)
+{
+	int tail_room = desc_info->data_size - desc_info->tlv_size;
+	int total_size = rocker_tlv_total_size(attrlen);
+	struct rocker_tlv *tlv;
+
+	if (unlikely(tail_room < total_size))
+		return -EMSGSIZE;
+
+	tlv = rocker_tlv_start(desc_info);
+	desc_info->tlv_size += total_size;
+	tlv->type = attrtype;
+	tlv->len = rocker_tlv_attr_size(attrlen);
+	memcpy(rocker_tlv_data(tlv), data, attrlen);
+	memset((char *) tlv + tlv->len, 0, rocker_tlv_padlen(attrlen));
+	return 0;
+}
+
diff --git a/drivers/net/ethernet/rocker/rocker_tlv.h b/drivers/net/ethernet/rocker/rocker_tlv.h
new file mode 100644
index 0000000..a161b6e
--- /dev/null
+++ b/drivers/net/ethernet/rocker/rocker_tlv.h
@@ -0,0 +1,202 @@
+/*
+ * drivers/net/ethernet/rocker/rocker_tlv.h - Rocker switch device driver
+ * Copyright (c) 2014-2015 Jiri Pirko <jiri@resnulli.us>
+ * Copyright (c) 2014 Scott Feldman <sfeldma@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _ROCKER_TLV_H
+#define _ROCKER_TLV_H
+
+#include <linux/types.h>
+
+#include "rocker_hw.h"
+#include "rocker.h"
+
+
+#define ROCKER_TLV_ALIGNTO 8U
+#define ROCKER_TLV_ALIGN(len) \
+	(((len) + ROCKER_TLV_ALIGNTO - 1) & ~(ROCKER_TLV_ALIGNTO - 1))
+#define ROCKER_TLV_HDRLEN ROCKER_TLV_ALIGN(sizeof(struct rocker_tlv))
+
+/*  <------- ROCKER_TLV_HDRLEN -------> <--- ROCKER_TLV_ALIGN(payload) --->
+ * +-----------------------------+- - -+- - - - - - - - - - - - - - -+- - -+
+ * |             Header          | Pad |           Payload           | Pad |
+ * |      (struct rocker_tlv)    | ing |                             | ing |
+ * +-----------------------------+- - -+- - - - - - - - - - - - - - -+- - -+
+ *  <--------------------------- tlv->len -------------------------->
+ */
+
+static inline struct rocker_tlv *rocker_tlv_next(const struct rocker_tlv *tlv,
+						 int *remaining)
+{
+	int totlen = ROCKER_TLV_ALIGN(tlv->len);
+
+	*remaining -= totlen;
+	return (struct rocker_tlv *) ((char *) tlv + totlen);
+}
+
+static inline int rocker_tlv_ok(const struct rocker_tlv *tlv, int remaining)
+{
+	return remaining >= (int) ROCKER_TLV_HDRLEN &&
+	       tlv->len >= ROCKER_TLV_HDRLEN &&
+	       tlv->len <= remaining;
+}
+
+#define rocker_tlv_for_each(pos, head, len, rem)	\
+	for (pos = head, rem = len;			\
+	     rocker_tlv_ok(pos, rem);			\
+	     pos = rocker_tlv_next(pos, &(rem)))
+
+#define rocker_tlv_for_each_nested(pos, tlv, rem)	\
+	rocker_tlv_for_each(pos, rocker_tlv_data(tlv),	\
+			    rocker_tlv_len(tlv), rem)
+
+static inline int rocker_tlv_attr_size(int payload)
+{
+	return ROCKER_TLV_HDRLEN + payload;
+}
+
+static inline int rocker_tlv_total_size(int payload)
+{
+	return ROCKER_TLV_ALIGN(rocker_tlv_attr_size(payload));
+}
+
+static inline int rocker_tlv_padlen(int payload)
+{
+	return rocker_tlv_total_size(payload) - rocker_tlv_attr_size(payload);
+}
+
+static inline int rocker_tlv_type(const struct rocker_tlv *tlv)
+{
+	return tlv->type;
+}
+
+static inline void *rocker_tlv_data(const struct rocker_tlv *tlv)
+{
+	return (char *) tlv + ROCKER_TLV_HDRLEN;
+}
+
+static inline int rocker_tlv_len(const struct rocker_tlv *tlv)
+{
+	return tlv->len - ROCKER_TLV_HDRLEN;
+}
+
+static inline u8 rocker_tlv_get_u8(const struct rocker_tlv *tlv)
+{
+	return *(u8 *) rocker_tlv_data(tlv);
+}
+
+static inline u16 rocker_tlv_get_u16(const struct rocker_tlv *tlv)
+{
+	return *(u16 *) rocker_tlv_data(tlv);
+}
+
+static inline __be16 rocker_tlv_get_be16(const struct rocker_tlv *tlv)
+{
+	return *(__be16 *) rocker_tlv_data(tlv);
+}
+
+static inline u32 rocker_tlv_get_u32(const struct rocker_tlv *tlv)
+{
+	return *(u32 *) rocker_tlv_data(tlv);
+}
+
+static inline u64 rocker_tlv_get_u64(const struct rocker_tlv *tlv)
+{
+	return *(u64 *) rocker_tlv_data(tlv);
+}
+
+void rocker_tlv_parse(const struct rocker_tlv **tb, int maxtype,
+		      const char *buf, int buf_len);
+
+static inline void rocker_tlv_parse_nested(const struct rocker_tlv **tb,
+					   int maxtype,
+					   const struct rocker_tlv *tlv)
+{
+	rocker_tlv_parse(tb, maxtype, rocker_tlv_data(tlv),
+			 rocker_tlv_len(tlv));
+}
+
+static inline void
+rocker_tlv_parse_desc(const struct rocker_tlv **tb, int maxtype,
+		      const struct rocker_desc_info *desc_info)
+{
+	rocker_tlv_parse(tb, maxtype, desc_info->data,
+			 desc_info->desc->tlv_size);
+}
+
+static inline struct rocker_tlv *
+rocker_tlv_start(struct rocker_desc_info *desc_info)
+{
+	return (struct rocker_tlv *) ((char *) desc_info->data +
+					       desc_info->tlv_size);
+}
+
+int rocker_tlv_put(struct rocker_desc_info *desc_info,
+		   int attrtype, int attrlen, const void *data);
+
+static inline int rocker_tlv_put_u8(struct rocker_desc_info *desc_info,
+				    int attrtype, u8 value)
+{
+	return rocker_tlv_put(desc_info, attrtype, sizeof(u8), &value);
+}
+
+static inline int rocker_tlv_put_u16(struct rocker_desc_info *desc_info,
+				     int attrtype, u16 value)
+{
+	return rocker_tlv_put(desc_info, attrtype, sizeof(u16), &value);
+}
+
+static inline int rocker_tlv_put_be16(struct rocker_desc_info *desc_info,
+				      int attrtype, __be16 value)
+{
+	return rocker_tlv_put(desc_info, attrtype, sizeof(__be16), &value);
+}
+
+static inline int rocker_tlv_put_u32(struct rocker_desc_info *desc_info,
+				     int attrtype, u32 value)
+{
+	return rocker_tlv_put(desc_info, attrtype, sizeof(u32), &value);
+}
+
+static inline int rocker_tlv_put_be32(struct rocker_desc_info *desc_info,
+				      int attrtype, __be32 value)
+{
+	return rocker_tlv_put(desc_info, attrtype, sizeof(__be32), &value);
+}
+
+static inline int rocker_tlv_put_u64(struct rocker_desc_info *desc_info,
+				     int attrtype, u64 value)
+{
+	return rocker_tlv_put(desc_info, attrtype, sizeof(u64), &value);
+}
+
+static inline struct rocker_tlv *
+rocker_tlv_nest_start(struct rocker_desc_info *desc_info, int attrtype)
+{
+	struct rocker_tlv *start = rocker_tlv_start(desc_info);
+
+	if (rocker_tlv_put(desc_info, attrtype, 0, NULL) < 0)
+		return NULL;
+
+	return start;
+}
+
+static inline void rocker_tlv_nest_end(struct rocker_desc_info *desc_info,
+				       struct rocker_tlv *start)
+{
+	start->len = (char *) rocker_tlv_start(desc_info) - (char *) start;
+}
+
+static inline void rocker_tlv_nest_cancel(struct rocker_desc_info *desc_info,
+					  const struct rocker_tlv *start)
+{
+	desc_info->tlv_size = (const char *) start - desc_info->data;
+}
+
+#endif
-- 
1.9.3
