From: Huw Davies <huw@codeweavers.com>
Subject: [PATCH v4 09/19] netlabel: Move bitmap manipulation functions to the NetLabel core.
Date: Mon, 20 Jun 2016 14:36:49 +0100
Message-ID: <1466429819-12707-10-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is to allow the CALIPSO labelling engine to use these.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 include/net/netlabel.h       |  6 +++
 net/ipv4/cipso_ipv4.c        | 88 +++++---------------------------------------
 net/netlabel/netlabel_kapi.c | 70 +++++++++++++++++++++++++++++++++++
 3 files changed, 85 insertions(+), 79 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 2c0513b..9fc2cab 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -434,6 +434,12 @@ int netlbl_catmap_setlong(struct netlbl_lsm_catmap **catmap,
 			  unsigned long bitmap,
 			  gfp_t flags);
 
+/* Bitmap functions
+ */
+int netlbl_bitmap_walk(const unsigned char *bitmap, u32 bitmap_len,
+		       u32 offset, u8 state);
+void netlbl_bitmap_setbit(unsigned char *bitmap, u32 bit, u8 state);
+
 /*
  * LSM protocol operations (NetLabel LSM/kernel API)
  */
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index bdb2a07..d710d4e 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -135,76 +135,6 @@ int cipso_v4_rbm_strictvalid = 1;
  */
 
 /**
- * cipso_v4_bitmap_walk - Walk a bitmap looking for a bit
- * @bitmap: the bitmap
- * @bitmap_len: length in bits
- * @offset: starting offset
- * @state: if non-zero, look for a set (1) bit else look for a cleared (0) bit
- *
- * Description:
- * Starting at @offset, walk the bitmap from left to right until either the
- * desired bit is found or we reach the end.  Return the bit offset, -1 if
- * not found, or -2 if error.
- */
-static int cipso_v4_bitmap_walk(const unsigned char *bitmap,
-				u32 bitmap_len,
-				u32 offset,
-				u8 state)
-{
-	u32 bit_spot;
-	u32 byte_offset;
-	unsigned char bitmask;
-	unsigned char byte;
-
-	/* gcc always rounds to zero when doing integer division */
-	byte_offset = offset / 8;
-	byte = bitmap[byte_offset];
-	bit_spot = offset;
-	bitmask = 0x80 >> (offset % 8);
-
-	while (bit_spot < bitmap_len) {
-		if ((state && (byte & bitmask) == bitmask) ||
-		    (state == 0 && (byte & bitmask) == 0))
-			return bit_spot;
-
-		bit_spot++;
-		bitmask >>= 1;
-		if (bitmask == 0) {
-			byte = bitmap[++byte_offset];
-			bitmask = 0x80;
-		}
-	}
-
-	return -1;
-}
-
-/**
- * cipso_v4_bitmap_setbit - Sets a single bit in a bitmap
- * @bitmap: the bitmap
- * @bit: the bit
- * @state: if non-zero, set the bit (1) else clear the bit (0)
- *
- * Description:
- * Set a single bit in the bitmask.  Returns zero on success, negative values
- * on error.
- */
-static void cipso_v4_bitmap_setbit(unsigned char *bitmap,
-				   u32 bit,
-				   u8 state)
-{
-	u32 byte_spot;
-	u8 bitmask;
-
-	/* gcc always rounds to zero when doing integer division */
-	byte_spot = bit / 8;
-	bitmask = 0x80 >> (bit % 8);
-	if (state)
-		bitmap[byte_spot] |= bitmask;
-	else
-		bitmap[byte_spot] &= ~bitmask;
-}
-
-/**
  * cipso_v4_cache_entry_free - Frees a cache entry
  * @entry: the entry to free
  *
@@ -840,10 +770,10 @@ static int cipso_v4_map_cat_rbm_valid(const struct cipso_v4_doi *doi_def,
 		cipso_cat_size = doi_def->map.std->cat.cipso_size;
 		cipso_array = doi_def->map.std->cat.cipso;
 		for (;;) {
-			cat = cipso_v4_bitmap_walk(bitmap,
-						   bitmap_len_bits,
-						   cat + 1,
-						   1);
+			cat = netlbl_bitmap_walk(bitmap,
+						 bitmap_len_bits,
+						 cat + 1,
+						 1);
 			if (cat < 0)
 				break;
 			if (cat >= cipso_cat_size ||
@@ -909,7 +839,7 @@ static int cipso_v4_map_cat_rbm_hton(const struct cipso_v4_doi *doi_def,
 		}
 		if (net_spot >= net_clen_bits)
 			return -ENOSPC;
-		cipso_v4_bitmap_setbit(net_cat, net_spot, 1);
+		netlbl_bitmap_setbit(net_cat, net_spot, 1);
 
 		if (net_spot > net_spot_max)
 			net_spot_max = net_spot;
@@ -951,10 +881,10 @@ static int cipso_v4_map_cat_rbm_ntoh(const struct cipso_v4_doi *doi_def,
 	}
 
 	for (;;) {
-		net_spot = cipso_v4_bitmap_walk(net_cat,
-						net_clen_bits,
-						net_spot + 1,
-						1);
+		net_spot = netlbl_bitmap_walk(net_cat,
+					      net_clen_bits,
+					      net_spot + 1,
+					      1);
 		if (net_spot < 0) {
 			if (net_spot == -2)
 				return -EFAULT;
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 55c59a0..609c853 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -729,6 +729,76 @@ int netlbl_catmap_setlong(struct netlbl_lsm_catmap **catmap,
 	return 0;
 }
 
+/* Bitmap functions
+ */
+
+/**
+ * netlbl_bitmap_walk - Walk a bitmap looking for a bit
+ * @bitmap: the bitmap
+ * @bitmap_len: length in bits
+ * @offset: starting offset
+ * @state: if non-zero, look for a set (1) bit else look for a cleared (0) bit
+ *
+ * Description:
+ * Starting at @offset, walk the bitmap from left to right until either the
+ * desired bit is found or we reach the end.  Return the bit offset, -1 if
+ * not found, or -2 if error.
+ */
+int netlbl_bitmap_walk(const unsigned char *bitmap, u32 bitmap_len,
+		       u32 offset, u8 state)
+{
+	u32 bit_spot;
+	u32 byte_offset;
+	unsigned char bitmask;
+	unsigned char byte;
+
+	byte_offset = offset / 8;
+	byte = bitmap[byte_offset];
+	bit_spot = offset;
+	bitmask = 0x80 >> (offset % 8);
+
+	while (bit_spot < bitmap_len) {
+		if ((state && (byte & bitmask) == bitmask) ||
+		    (state == 0 && (byte & bitmask) == 0))
+			return bit_spot;
+
+		bit_spot++;
+		bitmask >>= 1;
+		if (bitmask == 0) {
+			byte = bitmap[++byte_offset];
+			bitmask = 0x80;
+		}
+	}
+
+	return -1;
+}
+EXPORT_SYMBOL(netlbl_bitmap_walk);
+
+/**
+ * netlbl_bitmap_setbit - Sets a single bit in a bitmap
+ * @bitmap: the bitmap
+ * @bit: the bit
+ * @state: if non-zero, set the bit (1) else clear the bit (0)
+ *
+ * Description:
+ * Set a single bit in the bitmask.  Returns zero on success, negative values
+ * on error.
+ */
+void netlbl_bitmap_setbit(unsigned char *bitmap, u32 bit, u8 state)
+{
+	u32 byte_spot;
+	u8 bitmask;
+
+	/* gcc always rounds to zero when doing integer division */
+	byte_spot = bit / 8;
+	bitmask = 0x80 >> (bit % 8);
+	if (state)
+		bitmap[byte_spot] |= bitmask;
+	else
+		bitmap[byte_spot] &= ~bitmask;
+}
+EXPORT_SYMBOL(netlbl_bitmap_setbit);
+
 /*
  * LSM Functions
  */
-- 
2.7.4

