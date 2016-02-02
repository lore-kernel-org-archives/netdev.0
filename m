From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 3/6] vxlan: restructure vxlan.h definitions
Date: Tue,  2 Feb 2016 18:09:13 +0100
Message-ID: <34c99b6f5011958ab361a1761973a693cd869934.1454432731.git.jbenc@redhat.com>
References: <cover.1454432731.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932970AbcBBRJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 12:09:27 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 43D925A57
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 17:09:27 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-49.brq.redhat.com [10.40.204.49])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u12H9NSo003510
	for <netdev@vger.kernel.org>; Tue, 2 Feb 2016 12:09:26 -0500
In-Reply-To: <cover.1454432731.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RCO and GBP are VXLAN extensions, not specified in RFC 7348. Because of
that, they need to be explicitly enabled when creating vxlan interface. By
default, those extensions are not used and plain VXLAN header is sent and
received.

Reflect this in vxlan.h: first, the plain VXLAN header is defined. Following
it, RCO is documented and defined, and likewise for GBP.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/vxlan.h | 104 +++++++++++++++++++++++++++++++---------------------
 1 file changed, 63 insertions(+), 41 deletions(-)

diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 234bf1ef2737..25bd919c9ef0 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -9,14 +9,71 @@
 #include <linux/udp.h>
 #include <net/dst_metadata.h>
 
+/* VXLAN protocol (RFC 7348) header:
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |R|R|R|R|I|R|R|R|               Reserved                        |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                VXLAN Network Identifier (VNI) |   Reserved    |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * I = VXLAN Network Identifier (VNI) present.
+ */
+struct vxlanhdr {
+	__be32 vx_flags;
+	__be32 vx_vni;
+};
+
+/* VXLAN header flags. */
+#define VXLAN_HF_VNI BIT(27)
+
+#define VXLAN_N_VID     (1u << 24)
+#define VXLAN_VID_MASK  (VXLAN_N_VID - 1)
+#define VXLAN_VNI_MASK  (VXLAN_VID_MASK << 8)
+#define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
+
+#define VNI_HASH_BITS	10
+#define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
+#define FDB_HASH_BITS	8
+#define FDB_HASH_SIZE	(1<<FDB_HASH_BITS)
+
+/* Remote checksum offload for VXLAN (VXLAN_F_REMCSUM_[RT]X):
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |R|R|R|R|I|R|R|R|R|R|C|              Reserved                   |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |           VXLAN Network Identifier (VNI)      |O| Csum start  |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * C = Remote checksum offload bit. When set indicates that the
+ *     remote checksum offload data is present.
+ *
+ * O = Offset bit. Indicates the checksum offset relative to
+ *     checksum start.
+ *
+ * Csum start = Checksum start divided by two.
+ *
+ * http://tools.ietf.org/html/draft-herbert-vxlan-rco
+ */
+
+/* VXLAN-RCO header flags. */
+#define VXLAN_HF_RCO BIT(21)
+
+/* Remote checksum offload header option */
+#define VXLAN_RCO_MASK  0x7f    /* Last byte of vni field */
+#define VXLAN_RCO_UDP   0x80    /* Indicate UDP RCO (TCP when not set *) */
+#define VXLAN_RCO_SHIFT 1       /* Left shift of start */
+#define VXLAN_RCO_SHIFT_MASK ((1 << VXLAN_RCO_SHIFT) - 1)
+#define VXLAN_MAX_REMCSUM_START (VXLAN_RCO_MASK << VXLAN_RCO_SHIFT)
+
 /*
- * VXLAN Group Based Policy Extension:
+ * VXLAN Group Based Policy Extension (VXLAN_F_GBP):
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * |1|-|-|-|1|-|-|-|R|D|R|R|A|R|R|R|        Group Policy ID        |
+ * |G|R|R|R|I|R|R|R|R|D|R|R|A|R|R|R|        Group Policy ID        |
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  * |                VXLAN Network Identifier (VNI) |   Reserved    |
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  *
+ * G = Group Policy ID present.
+ *
  * D = Don't Learn bit. When set, this bit indicates that the egress
  *     VTEP MUST NOT learn the source address of the encapsulated frame.
  *
@@ -24,7 +81,7 @@
  *     this packet. Policies MUST NOT be applied by devices when the
  *     A bit is set.
  *
- * [0] https://tools.ietf.org/html/draft-smith-vxlan-group-policy
+ * https://tools.ietf.org/html/draft-smith-vxlan-group-policy
  */
 struct vxlanhdr_gbp {
 	u8	vx_flags;
@@ -47,6 +104,9 @@ struct vxlanhdr_gbp {
 	__be32	vx_vni;
 };
 
+/* VXLAN-GBP header flags. */
+#define VXLAN_HF_GBP BIT(31)
+
 #define VXLAN_GBP_USED_BITS (VXLAN_HF_GBP | 0xFFFFFF)
 
 /* skb->mark mapping
@@ -59,44 +119,6 @@ struct vxlanhdr_gbp {
 #define VXLAN_GBP_POLICY_APPLIED	(BIT(3) << 16)
 #define VXLAN_GBP_ID_MASK		(0xFFFF)
 
-/* VXLAN protocol header:
- * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * |G|R|R|R|I|R|R|C|               Reserved                        |
- * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * |                VXLAN Network Identifier (VNI) |   Reserved    |
- * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- *
- * G = 1	Group Policy (VXLAN-GBP)
- * I = 1	VXLAN Network Identifier (VNI) present
- * C = 1	Remote checksum offload (RCO)
- */
-struct vxlanhdr {
-	__be32 vx_flags;
-	__be32 vx_vni;
-};
-
-/* VXLAN header flags. */
-#define VXLAN_HF_RCO BIT(21)
-#define VXLAN_HF_VNI BIT(27)
-#define VXLAN_HF_GBP BIT(31)
-
-/* Remote checksum offload header option */
-#define VXLAN_RCO_MASK  0x7f    /* Last byte of vni field */
-#define VXLAN_RCO_UDP   0x80    /* Indicate UDP RCO (TCP when not set *) */
-#define VXLAN_RCO_SHIFT 1       /* Left shift of start */
-#define VXLAN_RCO_SHIFT_MASK ((1 << VXLAN_RCO_SHIFT) - 1)
-#define VXLAN_MAX_REMCSUM_START (VXLAN_RCO_MASK << VXLAN_RCO_SHIFT)
-
-#define VXLAN_N_VID     (1u << 24)
-#define VXLAN_VID_MASK  (VXLAN_N_VID - 1)
-#define VXLAN_VNI_MASK  (VXLAN_VID_MASK << 8)
-#define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
-
-#define VNI_HASH_BITS	10
-#define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
-#define FDB_HASH_BITS	8
-#define FDB_HASH_SIZE	(1<<FDB_HASH_BITS)
-
 struct vxlan_metadata {
 	u32		gbp;
 };
-- 
1.8.3.1
