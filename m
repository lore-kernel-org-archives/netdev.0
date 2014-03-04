From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next v4 1/4] ieee802154: add
	generic header handling routines
Date: Tue,  4 Mar 2014 15:34:45 +0100
Message-ID: <1393943688-24221-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1393943688-24221-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1393943688-24221-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a generic set of 802.15.4 header operations on sk_buffs: push header
onto skb, pull header from skb, and peek address fields from the mac_hdr
part of an skb.

These routines support the full 802.15.4 header as described in the
standard, including the security header. They are useful for everything
that must create, modify or read 802.15.4 headers, which of course
includes the wpan rx/tx path, but also 6lowpan. In the future,
link-layer security will also require means to modify packet headers.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Tested-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/ieee802154.h        |   15 ++
 include/net/ieee802154_netdev.h |   43 +++++
 include/net/mac802154.h         |    1 +
 net/ieee802154/Makefile         |    3 +-
 net/ieee802154/header_ops.c     |  328 +++++++++++++++++++++++++++++++++++++++
 5 files changed, 389 insertions(+), 1 deletion(-)
 create mode 100644 net/ieee802154/header_ops.c

diff --git a/include/net/ieee802154.h b/include/net/ieee802154.h
index ee59f8b..b968a19 100644
--- a/include/net/ieee802154.h
+++ b/include/net/ieee802154.h
@@ -52,12 +52,27 @@
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
index 97b2e34..c18a4f0 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -28,6 +28,49 @@
 #define IEEE802154_NETDEVICE_H
 
 #include <net/af_ieee802154.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+
+struct ieee802154_sechdr {
+	u8 sc;
+	u32 frame_ctr;
+	union {
+		struct {
+			u16 pan_id;
+			u16 short_addr;
+		} pan;
+		u8 hw[IEEE802154_ADDR_LEN];
+	} key_source;
+	u8 key_id;
+};
+
+struct ieee802154_hdr {
+	u16 fc;
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
+/* parses the address fields in a given skb and stores them into hdr,
+ * performing pan id decompression and length checks to be suitable for use in
+ * header_ops.parse
+ */
+int ieee802154_hdr_peek_addrs(const struct sk_buff *skb,
+			      struct ieee802154_hdr *hdr);
+
 
 struct ieee802154_frag_info {
 	__be16 d_tag;
diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index 8ca3d04..ceee5ea 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -20,6 +20,7 @@
 #define NET_MAC802154_H
 
 #include <net/af_ieee802154.h>
+#include <linux/skbuff.h>
 
 /* General MAC frame format:
  *  2 bytes: Frame Control
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index b113fc4..5db61ba 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -3,5 +3,6 @@ obj-$(CONFIG_IEEE802154_6LOWPAN) += 6lowpan.o
 obj-$(CONFIG_6LOWPAN_IPHC) += 6lowpan_iphc.o
 
 6lowpan-y := 6lowpan_rtnl.o reassembly.o
-ieee802154-y := netlink.o nl-mac.o nl-phy.o nl_policy.o wpan-class.o
+ieee802154-y := netlink.o nl-mac.o nl-phy.o nl_policy.o wpan-class.o \
+                header_ops.o
 af_802154-y := af_ieee802154.o raw.o dgram.o
diff --git a/net/ieee802154/header_ops.c b/net/ieee802154/header_ops.c
new file mode 100644
index 0000000..557fd24
--- /dev/null
+++ b/net/ieee802154/header_ops.c
@@ -0,0 +1,328 @@
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
+static void ieee802154_haddr_copy_swap(u8 *dest, const u8 *src)
+{
+	int i;
+
+	for (i = 0; i < IEEE802154_ADDR_LEN; i++)
+		dest[IEEE802154_ADDR_LEN - i - 1] = src[i];
+}
+
+static int
+ieee802154_hdr_push_addr(u8 *buf, const struct ieee802154_addr *addr,
+			 bool omit_pan)
+{
+	int pos = 0;
+
+	if (addr->addr_type == IEEE802154_ADDR_NONE)
+		return 0;
+
+	if (!omit_pan) {
+		buf[pos++] = addr->pan_id & 0xFF;
+		buf[pos++] = addr->pan_id >> 8;
+	}
+
+	switch (addr->addr_type) {
+	case IEEE802154_ADDR_SHORT:
+		buf[pos++] = addr->short_addr & 0xFF;
+		buf[pos++] = addr->short_addr >> 8;
+		break;
+
+	case IEEE802154_ADDR_LONG:
+		ieee802154_haddr_copy_swap(buf + pos, addr->hwaddr);
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
+	int pos = 0;
+
+	buf[pos++] = hdr->sc;
+	buf[pos++] = (hdr->frame_ctr >>  0) & 0xFF;
+	buf[pos++] = (hdr->frame_ctr >>  8) & 0xFF;
+	buf[pos++] = (hdr->frame_ctr >> 16) & 0xFF;
+	buf[pos++] = (hdr->frame_ctr >> 24) & 0xFF;
+
+	switch (IEEE802154_SCF_KEY_ID_MODE(hdr->sc)) {
+	case IEEE802154_SCF_KEY_IMPLICIT:
+		return pos;
+
+	case IEEE802154_SCF_KEY_INDEX:
+		break;
+
+	case IEEE802154_SCF_KEY_SHORT_INDEX:
+		buf[pos++] = hdr->key_source.pan.short_addr & 0xFF;
+		buf[pos++] = hdr->key_source.pan.short_addr >> 8;
+		buf[pos++] = hdr->key_source.pan.pan_id & 0xFF;
+		buf[pos++] = hdr->key_source.pan.pan_id >> 8;
+		break;
+
+	case IEEE802154_SCF_KEY_HW_INDEX:
+		ieee802154_haddr_copy_swap(buf + pos, hdr->key_source.hw);
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
+	u16 fc = hdr->fc;
+	int rc;
+
+	buf[pos++] = hdr->seq;
+
+	fc &= ~IEEE802154_FC_DAMODE_MASK;
+	fc |= (hdr->dest.addr_type << IEEE802154_FC_DAMODE_SHIFT)
+		& IEEE802154_FC_DAMODE_MASK;
+
+	rc = ieee802154_hdr_push_addr(buf + pos, &hdr->dest, false);
+	if (rc < 0)
+		return -EINVAL;
+	pos += rc;
+
+	fc &= ~IEEE802154_FC_SAMODE_MASK | ~IEEE802154_FC_INTRA_PAN;
+	fc |= (hdr->source.addr_type << IEEE802154_FC_SAMODE_SHIFT)
+		& IEEE802154_FC_SAMODE_MASK;
+
+	if (hdr->source.pan_id == hdr->dest.pan_id &&
+	    hdr->dest.addr_type != IEEE802154_ADDR_NONE)
+		fc |= IEEE802154_FC_INTRA_PAN;
+
+	rc = ieee802154_hdr_push_addr(buf + pos, &hdr->source,
+				      fc & IEEE802154_FC_INTRA_PAN);
+	if (rc < 0)
+		return -EINVAL;
+	pos += rc;
+
+	if (fc & IEEE802154_FC_SECEN) {
+		fc &= ~IEEE802154_FC_VERSION_MASK;
+		fc |= (1 << IEEE802154_FC_VERSION_SHIFT)
+			& IEEE802154_FC_VERSION_MASK;
+
+		rc = ieee802154_hdr_push_sechdr(buf + pos, &hdr->sec);
+		if (rc < 0)
+			return -EINVAL;
+
+		pos += rc;
+	}
+
+	buf[0] = fc & 0xFF;
+	buf[1] = fc >> 8;
+
+	memcpy(skb_push(skb, pos), buf, pos);
+
+	return pos;
+}
+EXPORT_SYMBOL_GPL(ieee802154_hdr_push);
+
+static u16 ieee802154_hdr_get_u16(const u8 *buf)
+{
+	return buf[0] | (buf[1] << 8);
+}
+
+static u32 ieee802154_hdr_get_u32(const u8 *buf)
+{
+	return buf[0] | (buf[1] << 8) | (buf[2] << 16) | (buf[3] << 24);
+}
+
+static int
+ieee802154_hdr_get_addr(const u8 *buf, int mode, bool omit_pan,
+			struct ieee802154_addr *addr)
+{
+	int pos = 0;
+
+	addr->addr_type = mode;
+
+	if (mode == IEEE802154_ADDR_NONE)
+		return 0;
+
+	if (!omit_pan) {
+		addr->pan_id = ieee802154_hdr_get_u16(buf + pos);
+		pos += 2;
+	}
+
+	if (mode == IEEE802154_ADDR_SHORT) {
+		addr->short_addr = ieee802154_hdr_get_u16(buf + pos);
+		return pos + 2;
+	} else {
+		ieee802154_haddr_copy_swap(addr->hwaddr, buf + pos);
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
+	int pos = 0;
+	u32 short_index;
+
+	hdr->sc = buf[pos++];
+	hdr->frame_ctr = ieee802154_hdr_get_u32(buf + pos);
+	pos += 4;
+
+	switch (IEEE802154_SCF_KEY_ID_MODE(hdr->sc)) {
+	case IEEE802154_SCF_KEY_IMPLICIT:
+		return pos;
+
+	case IEEE802154_SCF_KEY_INDEX:
+		break;
+
+	case IEEE802154_SCF_KEY_SHORT_INDEX:
+		short_index = ieee802154_hdr_get_u32(buf + pos);
+		pos += 4;
+		hdr->key_source.pan.pan_id = short_index >> 16;
+		hdr->key_source.pan.short_addr = short_index & 0xFFFF;
+		break;
+
+	case IEEE802154_SCF_KEY_HW_INDEX:
+		ieee802154_haddr_copy_swap(hdr->key_source.hw,
+					   buf + pos);
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
+static int ieee802154_hdr_minlen(u16 fc)
+{
+	int dlen, slen;
+
+	dlen = ieee802154_hdr_addr_len(IEEE802154_FC_DAMODE(fc), false);
+	slen = ieee802154_hdr_addr_len(IEEE802154_FC_SAMODE(fc),
+				       fc & IEEE802154_FC_INTRA_PAN);
+
+	if (slen < 0 || dlen < 0)
+		return -EINVAL;
+
+	return 3 + dlen + slen + (fc & IEEE802154_FC_SECEN ? 1 : 0);
+}
+
+static int
+ieee802154_hdr_get_addrs(const u8 *buf, struct ieee802154_hdr *hdr)
+{
+	int pos = 0;
+
+	pos += ieee802154_hdr_get_addr(buf + pos,
+				       IEEE802154_FC_DAMODE(hdr->fc),
+				       false, &hdr->dest);
+	pos += ieee802154_hdr_get_addr(buf + pos,
+				       IEEE802154_FC_SAMODE(hdr->fc),
+				       hdr->fc & IEEE802154_FC_INTRA_PAN,
+				       &hdr->source);
+
+	if (hdr->fc & IEEE802154_FC_INTRA_PAN)
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
+	hdr->fc = ieee802154_hdr_get_u16(skb->data);
+	hdr->seq = skb->data[2];
+
+	rc = ieee802154_hdr_minlen(hdr->fc);
+	if (rc < 0 || !pskb_may_pull(skb, rc))
+		return -EINVAL;
+
+	pos += ieee802154_hdr_get_addrs(skb->data + pos, hdr);
+
+	if (hdr->fc & IEEE802154_FC_SECEN) {
+		int want = pos + ieee802154_hdr_sechdr_len(hdr->sec.sc);
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
+	if (buf + 3 > skb->tail)
+		return -EINVAL;
+
+	hdr->fc = ieee802154_hdr_get_u16(buf);
+	hdr->seq = buf[2];
+
+	rc = ieee802154_hdr_minlen(hdr->fc);
+	if (rc < 0 || buf + rc > skb->tail)
+		return -EINVAL;
+
+	pos += ieee802154_hdr_get_addrs(buf + pos, hdr);
+	return pos;
+}
+EXPORT_SYMBOL_GPL(ieee802154_hdr_peek_addrs);
-- 
1.7.9.5


------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
