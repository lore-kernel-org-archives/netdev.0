From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next v2 4/8] ieee802154: add header
	structs with endiannes and operations
Date: Fri, 14 Mar 2014 21:24:00 +0100
Message-ID: <1394828644-19898-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1394828644-19898-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1394828644-19898-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch provides a set of structures to represent 802.15.4 MAC
headers, and a set of operations to push/pull/peek these structs from
skbs. We cannot simply pointer-cast the skb MAC header pointer to these
structs, because 802.15.4 headers are wildly variable - depending on the
first three bytes, virtually all other fields of the header may be
present or not, and be present with different lengths.

The new header creation/parsing routines also support 802.15.4 security
headers, which are currently not supported by the mac802154
implementation of the protocol.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 include/net/ieee802154.h        |  28 +++-
 include/net/ieee802154_netdev.h |  87 ++++++++++++
 include/net/mac802154.h         |   1 +
 net/ieee802154/Makefile         |   3 +-
 net/ieee802154/header_ops.c     | 287 ++++++++++++++++++++++++++++++++++++++++
 5 files changed, 401 insertions(+), 5 deletions(-)
 create mode 100644 net/ieee802154/header_ops.c

diff --git a/include/net/ieee802154.h b/include/net/ieee802154.h
index ee59f8b..c7ae0ac 100644
--- a/include/net/ieee802154.h
+++ b/include/net/ieee802154.h
@@ -42,22 +42,42 @@
 	    (((x) << IEEE802154_FC_TYPE_SHIFT) & IEEE802154_FC_TYPE_MASK)); \
 	} while (0)
 
-#define IEEE802154_FC_SECEN		(1 << 3)
-#define IEEE802154_FC_FRPEND		(1 << 4)
-#define IEEE802154_FC_ACK_REQ		(1 << 5)
-#define IEEE802154_FC_INTRA_PAN		(1 << 6)
+#define IEEE802154_FC_SECEN_SHIFT	3
+#define IEEE802154_FC_SECEN		(1 << IEEE802154_FC_SECEN_SHIFT)
+#define IEEE802154_FC_FRPEND_SHIFT	4
+#define IEEE802154_FC_FRPEND		(1 << IEEE802154_FC_FRPEND_SHIFT)
+#define IEEE802154_FC_ACK_REQ_SHIFT	5
+#define IEEE802154_FC_ACK_REQ		(1 << IEEE802154_FC_ACK_REQ_SHIFT)
+#define IEEE802154_FC_INTRA_PAN_SHIFT	6
+#define IEEE802154_FC_INTRA_PAN		(1 << IEEE802154_FC_INTRA_PAN_SHIFT)
 
 #define IEEE802154_FC_SAMODE_SHIFT	14
 #define IEEE802154_FC_SAMODE_MASK	(3 << IEEE802154_FC_SAMODE_SHIFT)
 #define IEEE802154_FC_DAMODE_SHIFT	10
 #define IEEE802154_FC_DAMODE_MASK	(3 << IEEE802154_FC_DAMODE_SHIFT)
 
+#define IEEE802154_FC_VERSION_SHIFT	12
+#define IEEE802154_FC_VERSION_MASK	(3 << IEEE802154_FC_VERSION_SHIFT)
+#define IEEE802154_FC_VERSION(x)	((x & IEEE802154_FC_VERSION_MASK) >> IEEE802154_FC_VERSION_SHIFT)
+
 #define IEEE802154_FC_SAMODE(x)		\
 	(((x) & IEEE802154_FC_SAMODE_MASK) >> IEEE802154_FC_SAMODE_SHIFT)
 
 #define IEEE802154_FC_DAMODE(x)		\
 	(((x) & IEEE802154_FC_DAMODE_MASK) >> IEEE802154_FC_DAMODE_SHIFT)
 
+#define IEEE802154_SCF_SECLEVEL_MASK		7
+#define IEEE802154_SCF_SECLEVEL_SHIFT		0
+#define IEEE802154_SCF_SECLEVEL(x)		(x & IEEE802154_SCF_SECLEVEL_MASK)
+#define IEEE802154_SCF_KEY_ID_MODE_SHIFT	3
+#define IEEE802154_SCF_KEY_ID_MODE_MASK		(3 << IEEE802154_SCF_KEY_ID_MODE_SHIFT)
+#define IEEE802154_SCF_KEY_ID_MODE(x)		\
+	((x & IEEE802154_SCF_KEY_ID_MODE_MASK) >> IEEE802154_SCF_KEY_ID_MODE_SHIFT)
+
+#define IEEE802154_SCF_KEY_IMPLICIT		0
+#define IEEE802154_SCF_KEY_INDEX		1
+#define IEEE802154_SCF_KEY_SHORT_INDEX		2
+#define IEEE802154_SCF_KEY_HW_INDEX		3
 
 /* MAC footer size */
 #define IEEE802154_MFR_SIZE	2 /* 2 octets */
diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index e4810d5..c3fc33a 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -28,6 +28,28 @@
 #define IEEE802154_NETDEVICE_H
 
 #include <net/af_ieee802154.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+
+struct ieee802154_sechdr {
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	u8 level:3,
+	   key_id_mode:2,
+	   reserved:3;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+	u8 reserved:3,
+	   key_id_mode:2,
+	   level:3;
+#else
+#error	"Please fix <asm/byteorder.h>"
+#endif
+	u8 key_id;
+	__le32 frame_counter;
+	union {
+		__le32 short_src;
+		__le64 extended_src;
+	};
+};
 
 struct ieee802154_addr {
 	u8 mode;
@@ -38,6 +60,71 @@ struct ieee802154_addr {
 	};
 };
 
+struct ieee802154_hdr_fc {
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	u16 type:3,
+	    security_enabled:1,
+	    frame_pending:1,
+	    ack_request:1,
+	    intra_pan:1,
+	    reserved:3,
+	    dest_addr_mode:2,
+	    version:2,
+	    source_addr_mode:2;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+	u16 reserved:1,
+	    intra_pan:1,
+	    ack_request:1,
+	    frame_pending:1,
+	    security_enabled:1,
+	    type:3,
+	    source_addr_mode:2,
+	    version:2,
+	    dest_addr_mode:2,
+	    reserved2:2;
+#else
+#error	"Please fix <asm/byteorder.h>"
+#endif
+};
+
+struct ieee802154_hdr {
+	struct ieee802154_hdr_fc fc;
+	u8 seq;
+	struct ieee802154_addr source;
+	struct ieee802154_addr dest;
+	struct ieee802154_sechdr sec;
+};
+
+/* pushes hdr onto the skb. fields of hdr->fc that can be calculated from
+ * the contents of hdr will be, and the actual value of those bits in
+ * hdr->fc will be ignored. this includes the INTRA_PAN bit and the frame
+ * version, if SECEN is set.
+ */
+int ieee802154_hdr_push(struct sk_buff *skb, const struct ieee802154_hdr *hdr);
+
+/* pulls the entire 802.15.4 header off of the skb, including the security
+ * header, and performs pan id decompression
+ */
+int ieee802154_hdr_pull(struct sk_buff *skb, struct ieee802154_hdr *hdr);
+
+/* parses the frame control, sequence number of address fields in a given skb
+ * and stores them into hdr, performing pan id decompression and length checks
+ * to be suitable for use in header_ops.parse
+ */
+int ieee802154_hdr_peek_addrs(const struct sk_buff *skb,
+			      struct ieee802154_hdr *hdr);
+
+static inline int ieee802154_hdr_length(struct sk_buff *skb)
+{
+	struct ieee802154_hdr hdr;
+	int len = ieee802154_hdr_pull(skb, &hdr);
+
+	if (len > 0)
+		skb_push(skb, len);
+
+	return len;
+}
+
 static inline bool ieee802154_addr_equal(const struct ieee802154_addr *a1,
 					 const struct ieee802154_addr *a2)
 {
diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index f74b2a8..a591053 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -20,6 +20,7 @@
 #define NET_MAC802154_H
 
 #include <net/af_ieee802154.h>
+#include <linux/skbuff.h>
 
 /* General MAC frame format:
  *  2 bytes: Frame Control
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index 78b1fa2..bf1b514 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -3,7 +3,8 @@ obj-$(CONFIG_IEEE802154_6LOWPAN) += 6lowpan.o
 obj-$(CONFIG_6LOWPAN_IPHC) += 6lowpan_iphc.o
 
 6lowpan-y := 6lowpan_rtnl.o reassembly.o
-ieee802154-y := netlink.o nl-mac.o nl-phy.o nl_policy.o wpan-class.o
+ieee802154-y := netlink.o nl-mac.o nl-phy.o nl_policy.o wpan-class.o \
+                header_ops.o
 af_802154-y := af_ieee802154.o raw.o dgram.o
 
 ccflags-y += -D__CHECK_ENDIAN__
diff --git a/net/ieee802154/header_ops.c b/net/ieee802154/header_ops.c
new file mode 100644
index 0000000..bed42a4
--- /dev/null
+++ b/net/ieee802154/header_ops.c
@@ -0,0 +1,287 @@
+/*
+ * Copyright (C) 2014 Fraunhofer ITWM
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Written by:
+ * Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
+ */
+
+#include <net/mac802154.h>
+#include <net/ieee802154.h>
+#include <net/ieee802154_netdev.h>
+
+static int
+ieee802154_hdr_push_addr(u8 *buf, const struct ieee802154_addr *addr,
+			 bool omit_pan)
+{
+	int pos = 0;
+
+	if (addr->mode == IEEE802154_ADDR_NONE)
+		return 0;
+
+	if (!omit_pan) {
+		memcpy(buf + pos, &addr->pan_id, 2);
+		pos += 2;
+	}
+
+	switch (addr->mode) {
+	case IEEE802154_ADDR_SHORT:
+		memcpy(buf + pos, &addr->short_addr, 2);
+		pos += 2;
+		break;
+
+	case IEEE802154_ADDR_LONG:
+		memcpy(buf + pos, &addr->extended_addr, IEEE802154_ADDR_LEN);
+		pos += IEEE802154_ADDR_LEN;
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	return pos;
+}
+
+static int
+ieee802154_hdr_push_sechdr(u8 *buf, const struct ieee802154_sechdr *hdr)
+{
+	int pos = 5;
+
+	memcpy(buf, hdr, 1);
+	memcpy(buf + 1, &hdr->frame_counter, 4);
+
+	switch (hdr->key_id_mode) {
+	case IEEE802154_SCF_KEY_IMPLICIT:
+		return pos;
+
+	case IEEE802154_SCF_KEY_INDEX:
+		break;
+
+	case IEEE802154_SCF_KEY_SHORT_INDEX:
+		memcpy(buf + pos, &hdr->short_src, 4);
+		pos += 4;
+		break;
+
+	case IEEE802154_SCF_KEY_HW_INDEX:
+		memcpy(buf + pos, &hdr->extended_src, IEEE802154_ADDR_LEN);
+		pos += IEEE802154_ADDR_LEN;
+		break;
+	}
+
+	buf[pos++] = hdr->key_id;
+
+	return pos;
+}
+
+int
+ieee802154_hdr_push(struct sk_buff *skb, const struct ieee802154_hdr *hdr)
+{
+	u8 buf[MAC802154_FRAME_HARD_HEADER_LEN];
+	int pos = 2;
+	int rc;
+	struct ieee802154_hdr_fc fc = hdr->fc;
+
+	buf[pos++] = hdr->seq;
+
+	fc.dest_addr_mode = hdr->dest.mode;
+
+	rc = ieee802154_hdr_push_addr(buf + pos, &hdr->dest, false);
+	if (rc < 0)
+		return -EINVAL;
+	pos += rc;
+
+	fc.source_addr_mode = hdr->source.mode;
+
+	if (hdr->source.pan_id == hdr->dest.pan_id &&
+	    hdr->dest.mode != IEEE802154_ADDR_NONE)
+		fc.intra_pan = true;
+
+	rc = ieee802154_hdr_push_addr(buf + pos, &hdr->source, fc.intra_pan);
+	if (rc < 0)
+		return -EINVAL;
+	pos += rc;
+
+	if (fc.security_enabled) {
+		fc.version = 1;
+
+		rc = ieee802154_hdr_push_sechdr(buf + pos, &hdr->sec);
+		if (rc < 0)
+			return -EINVAL;
+
+		pos += rc;
+	}
+
+	memcpy(buf, &fc, 2);
+
+	memcpy(skb_push(skb, pos), buf, pos);
+
+	return pos;
+}
+EXPORT_SYMBOL_GPL(ieee802154_hdr_push);
+
+static int
+ieee802154_hdr_get_addr(const u8 *buf, int mode, bool omit_pan,
+			struct ieee802154_addr *addr)
+{
+	int pos = 0;
+
+	addr->mode = mode;
+
+	if (mode == IEEE802154_ADDR_NONE)
+		return 0;
+
+	if (!omit_pan) {
+		memcpy(&addr->pan_id, buf + pos, 2);
+		pos += 2;
+	}
+
+	if (mode == IEEE802154_ADDR_SHORT) {
+		memcpy(&addr->short_addr, buf + pos, 2);
+		return pos + 2;
+	} else {
+		memcpy(&addr->extended_addr, buf + pos, IEEE802154_ADDR_LEN);
+		return pos + IEEE802154_ADDR_LEN;
+	}
+}
+
+static int ieee802154_hdr_addr_len(int mode, bool omit_pan)
+{
+	int pan_len = omit_pan ? 0 : 2;
+
+	switch (mode) {
+	case IEEE802154_ADDR_NONE: return 0;
+	case IEEE802154_ADDR_SHORT: return 2 + pan_len;
+	case IEEE802154_ADDR_LONG: return IEEE802154_ADDR_LEN + pan_len;
+	default: return -EINVAL;
+	}
+}
+
+static int
+ieee802154_hdr_get_sechdr(const u8 *buf, struct ieee802154_sechdr *hdr)
+{
+	int pos = 5;
+
+	memcpy(hdr, buf, 1);
+	memcpy(&hdr->frame_counter, buf + 1, 4);
+
+	switch (hdr->key_id_mode) {
+	case IEEE802154_SCF_KEY_IMPLICIT:
+		return pos;
+
+	case IEEE802154_SCF_KEY_INDEX:
+		break;
+
+	case IEEE802154_SCF_KEY_SHORT_INDEX:
+		memcpy(&hdr->short_src, buf + pos, 4);
+		pos += 4;
+		break;
+
+	case IEEE802154_SCF_KEY_HW_INDEX:
+		memcpy(&hdr->extended_src, buf + pos, IEEE802154_ADDR_LEN);
+		pos += IEEE802154_ADDR_LEN;
+		break;
+	}
+
+	hdr->key_id = buf[pos++];
+
+	return pos;
+}
+
+static int ieee802154_hdr_sechdr_len(u8 sc)
+{
+	switch (IEEE802154_SCF_KEY_ID_MODE(sc)) {
+	case IEEE802154_SCF_KEY_IMPLICIT: return 5;
+	case IEEE802154_SCF_KEY_INDEX: return 6;
+	case IEEE802154_SCF_KEY_SHORT_INDEX: return 10;
+	case IEEE802154_SCF_KEY_HW_INDEX: return 14;
+	default: return -EINVAL;
+	}
+}
+
+static int ieee802154_hdr_minlen(const struct ieee802154_hdr *hdr)
+{
+	int dlen, slen;
+
+	dlen = ieee802154_hdr_addr_len(hdr->fc.dest_addr_mode, false);
+	slen = ieee802154_hdr_addr_len(hdr->fc.source_addr_mode,
+				       hdr->fc.intra_pan);
+
+	if (slen < 0 || dlen < 0)
+		return -EINVAL;
+
+	return 3 + dlen + slen + hdr->fc.security_enabled;
+}
+
+static int
+ieee802154_hdr_get_addrs(const u8 *buf, struct ieee802154_hdr *hdr)
+{
+	int pos = 0;
+
+	pos += ieee802154_hdr_get_addr(buf + pos, hdr->fc.dest_addr_mode,
+				       false, &hdr->dest);
+	pos += ieee802154_hdr_get_addr(buf + pos, hdr->fc.source_addr_mode,
+				       hdr->fc.intra_pan, &hdr->source);
+
+	if (hdr->fc.intra_pan)
+		hdr->source.pan_id = hdr->dest.pan_id;
+
+	return pos;
+}
+
+int
+ieee802154_hdr_pull(struct sk_buff *skb, struct ieee802154_hdr *hdr)
+{
+	int pos = 3, rc;
+
+	if (!pskb_may_pull(skb, 3))
+		return -EINVAL;
+
+	memcpy(hdr, skb->data, 3);
+
+	rc = ieee802154_hdr_minlen(hdr);
+	if (rc < 0 || !pskb_may_pull(skb, rc))
+		return -EINVAL;
+
+	pos += ieee802154_hdr_get_addrs(skb->data + pos, hdr);
+
+	if (hdr->fc.security_enabled) {
+		int want = pos + ieee802154_hdr_sechdr_len(skb->data[pos]);
+
+		if (!pskb_may_pull(skb, want))
+			return -EINVAL;
+
+		pos += ieee802154_hdr_get_sechdr(skb->data + pos, &hdr->sec);
+	}
+
+	skb_pull(skb, pos);
+	return pos;
+}
+EXPORT_SYMBOL_GPL(ieee802154_hdr_pull);
+
+int
+ieee802154_hdr_peek_addrs(const struct sk_buff *skb, struct ieee802154_hdr *hdr)
+{
+	const u8 *buf = skb_mac_header(skb);
+	int pos = 3, rc;
+
+	if (buf + 3 > skb_tail_pointer(skb))
+		return -EINVAL;
+
+	memcpy(hdr, buf, 3);
+
+	rc = ieee802154_hdr_minlen(hdr);
+	if (rc < 0 || buf + rc > skb_tail_pointer(skb))
+		return -EINVAL;
+
+	pos += ieee802154_hdr_get_addrs(buf + pos, hdr);
+	return pos;
+}
+EXPORT_SYMBOL_GPL(ieee802154_hdr_peek_addrs);
-- 
1.9.0


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
