From: paul.moore@hp.com
Subject: [PATCH 1/3] NetLabel: convert to an extensibile/sparse category bitmap
Date: Wed, 29 Nov 2006 13:18:18 -0500
Message-ID: <20061129182853.429830000@hp.com>
References: <20061129181817.505281000@hp.com>
Cc: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:37542 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S967520AbWK2S25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 13:28:57 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-cat_expansion
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

The original NetLabel category bitmap was a straight char bitmap which worked
fine for the initial release as it only supported 240 bits due to limitations
in the CIPSO restricted bitmap tag (tag type 0x01).  This patch converts that
straight char bitmap into an extensibile/sparse bitmap in order to lay the
foundation for other CIPSO tag types and protocols.

This patch also has a nice side effect in that all of the security attributes
passed by NetLabel into the LSM are now in a format which is in the host's
native byte/bit ordering which makes the LSM specific code much simpler; look
at the changes in security/selinux/ss/ebitmap.c as an example.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/net/netlabel.h         |  102 ++++++++++++++++++++
 net/ipv4/cipso_ipv4.c          |  170 ++++++++++++++--------------------
 net/netlabel/netlabel_kapi.c   |  201 +++++++++++++++++++++++++++++++++++++++++
 security/selinux/ss/ebitmap.c  |  196 +++++++++++++++++----------------------
 security/selinux/ss/ebitmap.h  |   26 ++++-
 security/selinux/ss/mls.c      |  156 ++++++++++---------------------
 security/selinux/ss/mls.h      |   46 ++++++---
 security/selinux/ss/services.c |   23 +---
 8 files changed, 568 insertions(+), 352 deletions(-)

Index: net-2.6.20_netlabel-cats/include/net/netlabel.h
===================================================================
--- net-2.6.20_netlabel-cats.orig/include/net/netlabel.h
+++ net-2.6.20_netlabel-cats/include/net/netlabel.h
@@ -111,6 +111,22 @@ struct netlbl_lsm_cache {
 	void (*free) (const void *data);
 	void *data;
 };
+/* The catmap bitmap field MUST be a power of two in length and large
+ * enough to hold at least 240 bits.  Special care (i.e. check the code!)
+ * should be used when changing these values as the LSM implementation
+ * probably has functions which rely on the sizes of these types to speed
+ * processing. */
+#define NETLBL_CATMAP_MAPTYPE           u64
+#define NETLBL_CATMAP_MAPCNT            4
+#define NETLBL_CATMAP_MAPSIZE           (sizeof(NETLBL_CATMAP_MAPTYPE) * 8)
+#define NETLBL_CATMAP_SIZE              (NETLBL_CATMAP_MAPSIZE * \
+					 NETLBL_CATMAP_MAPCNT)
+#define NETLBL_CATMAP_BIT               (NETLBL_CATMAP_MAPTYPE)0x01
+struct netlbl_lsm_secattr_catmap {
+	u32 startbit;
+	NETLBL_CATMAP_MAPTYPE bitmap[NETLBL_CATMAP_MAPCNT];
+	struct netlbl_lsm_secattr_catmap *next;
+};
 #define NETLBL_SECATTR_NONE             0x00000000
 #define NETLBL_SECATTR_DOMAIN           0x00000001
 #define NETLBL_SECATTR_CACHE            0x00000002
@@ -122,8 +138,7 @@ struct netlbl_lsm_secattr {
 	char *domain;
 
 	u32 mls_lvl;
-	unsigned char *mls_cat;
-	size_t mls_cat_len;
+	struct netlbl_lsm_secattr_catmap *mls_cat;
 
 	struct netlbl_lsm_cache *cache;
 };
@@ -171,6 +186,41 @@ static inline void netlbl_secattr_cache_
 }
 
 /**
+ * netlbl_secattr_catmap_alloc - Allocate a LSM secattr catmap
+ * @flags: memory allocation flags
+ *
+ * Description:
+ * Allocate memory for a LSM secattr catmap, returns a pointer on success, NULL
+ * on failure.
+ *
+ */
+static inline struct netlbl_lsm_secattr_catmap *netlbl_secattr_catmap_alloc(
+	                                                           gfp_t flags)
+{
+	return kzalloc(sizeof(struct netlbl_lsm_secattr_catmap), flags);
+}
+
+/**
+ * netlbl_secattr_catmap_free - Free a LSM secattr catmap
+ * @catmap: the category bitmap
+ *
+ * Description:
+ * Free a LSM secattr catmap.
+ *
+ */
+static inline void netlbl_secattr_catmap_free(
+	                              struct netlbl_lsm_secattr_catmap *catmap)
+{
+	struct netlbl_lsm_secattr_catmap *iter;
+
+	do {
+		iter = catmap;
+		catmap = catmap->next;
+		kfree(iter);
+	} while (catmap);
+}
+
+/**
  * netlbl_secattr_init - Initialize a netlbl_lsm_secattr struct
  * @secattr: the struct to initialize
  *
@@ -200,7 +250,8 @@ static inline void netlbl_secattr_destro
 	if (secattr->cache)
 		netlbl_secattr_cache_free(secattr->cache);
 	kfree(secattr->domain);
-	kfree(secattr->mls_cat);
+	if (secattr->mls_cat)
+		netlbl_secattr_catmap_free(secattr->mls_cat);
 }
 
 /**
@@ -231,6 +282,51 @@ static inline void netlbl_secattr_free(s
 	kfree(secattr);
 }
 
+#ifdef CONFIG_NETLABEL
+int netlbl_secattr_catmap_walk(struct netlbl_lsm_secattr_catmap *catmap,
+			       u32 offset);
+int netlbl_secattr_catmap_walk_rng(struct netlbl_lsm_secattr_catmap *catmap,
+				   u32 offset);
+int netlbl_secattr_catmap_setbit(struct netlbl_lsm_secattr_catmap *catmap,
+				 u32 bit,
+				 gfp_t flags);
+int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap *catmap,
+				 u32 start,
+				 u32 end,
+				 gfp_t flags);
+#else
+static inline int netlbl_secattr_catmap_walk(
+	                              struct netlbl_lsm_secattr_catmap *catmap,
+				      u32 offset)
+{
+	return -ENOENT;
+}
+
+static inline int netlbl_secattr_catmap_walk_rng(
+				      struct netlbl_lsm_secattr_catmap *catmap,
+				      u32 offset)
+{
+	return -ENOENT;
+}
+
+static inline int netlbl_secattr_catmap_setbit(
+	                              struct netlbl_lsm_secattr_catmap *catmap,
+				      u32 bit,
+				      gfp_t flags)
+{
+	return 0;
+}
+
+static inline int netlbl_secattr_catmap_setrng(
+	                              struct netlbl_lsm_secattr_catmap *catmap,
+				      u32 start,
+				      u32 end,
+				      gfp_t flags)
+{
+	return 0;
+}
+#endif
+
 /*
  * LSM protocol operations
  */
Index: net-2.6.20_netlabel-cats/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6.20_netlabel-cats.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6.20_netlabel-cats/net/ipv4/cipso_ipv4.c
@@ -819,8 +819,7 @@ static int cipso_v4_map_cat_rbm_valid(co
 /**
  * cipso_v4_map_cat_rbm_hton - Perform a category mapping from host to network
  * @doi_def: the DOI definition
- * @host_cat: the category bitmap in host format
- * @host_cat_len: the length of the host's category bitmap in bytes
+ * @secattr: the security attributes
  * @net_cat: the zero'd out category bitmap in network/CIPSO format
  * @net_cat_len: the length of the CIPSO bitmap in bytes
  *
@@ -831,61 +830,51 @@ static int cipso_v4_map_cat_rbm_valid(co
  *
  */
 static int cipso_v4_map_cat_rbm_hton(const struct cipso_v4_doi *doi_def,
-				     const unsigned char *host_cat,
-				     u32 host_cat_len,
+				     const struct netlbl_lsm_secattr *secattr,
 				     unsigned char *net_cat,
 				     u32 net_cat_len)
 {
 	int host_spot = -1;
-	u32 net_spot;
+	u32 net_spot = CIPSO_V4_INV_CAT;
 	u32 net_spot_max = 0;
-	u32 host_clen_bits = host_cat_len * 8;
 	u32 net_clen_bits = net_cat_len * 8;
-	u32 host_cat_size;
-	u32 *host_cat_array;
+	u32 host_cat_size = 0;
+	u32 *host_cat_array = NULL;
 
-	switch (doi_def->type) {
-	case CIPSO_V4_MAP_PASS:
-		net_spot_max = host_cat_len;
-		while (net_spot_max > 0 && host_cat[net_spot_max - 1] == 0)
-			net_spot_max--;
-		if (net_spot_max > net_cat_len)
-			return -EINVAL;
-		memcpy(net_cat, host_cat, net_spot_max);
-		return net_spot_max;
-	case CIPSO_V4_MAP_STD:
+	if (doi_def->type == CIPSO_V4_MAP_STD) {
 		host_cat_size = doi_def->map.std->cat.local_size;
 		host_cat_array = doi_def->map.std->cat.local;
-		for (;;) {
-			host_spot = cipso_v4_bitmap_walk(host_cat,
-							 host_clen_bits,
-							 host_spot + 1,
-							 1);
-			if (host_spot < 0)
-				break;
+	}
+
+	for (;;) {
+		host_spot = netlbl_secattr_catmap_walk(secattr->mls_cat,
+						       host_spot + 1);
+		if (host_spot < 0)
+			break;
+
+		switch (doi_def->type) {
+		case CIPSO_V4_MAP_PASS:
+			net_spot = host_spot;
+			break;
+		case CIPSO_V4_MAP_STD:
 			if (host_spot >= host_cat_size)
 				return -EPERM;
-
 			net_spot = host_cat_array[host_spot];
 			if (net_spot >= CIPSO_V4_INV_CAT)
 				return -EPERM;
-			if (net_spot >= net_clen_bits)
-				return -ENOSPC;
-			cipso_v4_bitmap_setbit(net_cat, net_spot, 1);
-
-			if (net_spot > net_spot_max)
-				net_spot_max = net_spot;
+			break;
 		}
+		if (net_spot >= net_clen_bits)
+			return -ENOSPC;
+		cipso_v4_bitmap_setbit(net_cat, net_spot, 1);
 
-		if (host_spot == -2)
-			return -EFAULT;
-
-		if (++net_spot_max % 8)
-			return net_spot_max / 8 + 1;
-		return net_spot_max / 8;
+		if (net_spot > net_spot_max)
+			net_spot_max = net_spot;
 	}
 
-	return -EINVAL;
+	if (++net_spot_max % 8)
+		return net_spot_max / 8 + 1;
+	return net_spot_max / 8;
 }
 
 /**
@@ -893,66 +882,59 @@ static int cipso_v4_map_cat_rbm_hton(con
  * @doi_def: the DOI definition
  * @net_cat: the category bitmap in network/CIPSO format
  * @net_cat_len: the length of the CIPSO bitmap in bytes
- * @host_cat: the zero'd out category bitmap in host format
- * @host_cat_len: the length of the host's category bitmap in bytes
+ * @secattr: the security attributes
  *
  * Description:
  * Perform a label mapping to translate a CIPSO bitmap to the correct local
- * MLS category bitmap using the given DOI definition.  Returns the minimum
- * size in bytes of the host bitmap on success, negative values otherwise.
+ * MLS category bitmap using the given DOI definition.  Returns zero on
+ * success, negative values on failure.
  *
  */
 static int cipso_v4_map_cat_rbm_ntoh(const struct cipso_v4_doi *doi_def,
 				     const unsigned char *net_cat,
 				     u32 net_cat_len,
-				     unsigned char *host_cat,
-				     u32 host_cat_len)
+				     struct netlbl_lsm_secattr *secattr)
 {
-	u32 host_spot;
-	u32 host_spot_max = 0;
+	int ret_val;
 	int net_spot = -1;
+	u32 host_spot = CIPSO_V4_INV_CAT;
 	u32 net_clen_bits = net_cat_len * 8;
-	u32 host_clen_bits = host_cat_len * 8;
-	u32 net_cat_size;
-	u32 *net_cat_array;
-
-	switch (doi_def->type) {
-	case CIPSO_V4_MAP_PASS:
-		if (net_cat_len > host_cat_len)
-			return -EINVAL;
-		memcpy(host_cat, net_cat, net_cat_len);
-		return net_cat_len;
-	case CIPSO_V4_MAP_STD:
+	u32 net_cat_size = 0;
+	u32 *net_cat_array = NULL;
+
+	if (doi_def->type == CIPSO_V4_MAP_STD) {
 		net_cat_size = doi_def->map.std->cat.cipso_size;
 		net_cat_array = doi_def->map.std->cat.cipso;
-		for (;;) {
-			net_spot = cipso_v4_bitmap_walk(net_cat,
-							net_clen_bits,
-							net_spot + 1,
-							1);
-			if (net_spot < 0)
-				break;
-			if (net_spot >= net_cat_size ||
-			    net_cat_array[net_spot] >= CIPSO_V4_INV_CAT)
-				return -EPERM;
+	}
 
+	for (;;) {
+		net_spot = cipso_v4_bitmap_walk(net_cat,
+						net_clen_bits,
+						net_spot + 1,
+						1);
+		if (net_spot < 0) {
+			if (net_spot == -2)
+				return -EFAULT;
+			return 0;
+		}
+
+		switch (doi_def->type) {
+		case CIPSO_V4_MAP_PASS:
+			host_spot = net_spot;
+			break;
+		case CIPSO_V4_MAP_STD:
+			if (net_spot >= net_cat_size)
+				return -EPERM;
 			host_spot = net_cat_array[net_spot];
 			if (host_spot >= CIPSO_V4_INV_CAT)
 				return -EPERM;
-			if (host_spot >= host_clen_bits)
-				return -ENOSPC;
-			cipso_v4_bitmap_setbit(host_cat, host_spot, 1);
-
-			if (host_spot > host_spot_max)
-				host_spot_max = host_spot;
+			break;
 		}
-
-		if (net_spot == -2)
-			return -EFAULT;
-
-		if (++host_spot_max % 8)
-			return host_spot_max / 8 + 1;
-		return host_spot_max / 8;
+		ret_val = netlbl_secattr_catmap_setbit(secattr->mls_cat,
+						       host_spot,
+						       GFP_ATOMIC);
+		if (ret_val != 0)
+			return ret_val;
 	}
 
 	return -EINVAL;
@@ -1016,8 +998,7 @@ static int cipso_v4_gentag_rbm(const str
 
 	if (secattr->flags & NETLBL_SECATTR_MLS_CAT) {
 		ret_val = cipso_v4_map_cat_rbm_hton(doi_def,
-						    secattr->mls_cat,
-						    secattr->mls_cat_len,
+						    secattr,
 						    &buffer[4],
 						    buffer_len - 4);
 		if (ret_val < 0)
@@ -1067,31 +1048,20 @@ static int cipso_v4_parsetag_rbm(const s
 	secattr->flags |= NETLBL_SECATTR_MLS_LVL;
 
 	if (tag_len > 4) {
-		switch (doi_def->type) {
-		case CIPSO_V4_MAP_PASS:
-			secattr->mls_cat_len = tag_len - 4;
-			break;
-		case CIPSO_V4_MAP_STD:
-			secattr->mls_cat_len =
-				doi_def->map.std->cat.local_size;
-			break;
-		}
-		secattr->mls_cat = kzalloc(secattr->mls_cat_len, GFP_ATOMIC);
+		secattr->mls_cat = netlbl_secattr_catmap_alloc(GFP_ATOMIC);
 		if (secattr->mls_cat == NULL)
 			return -ENOMEM;
 
 		ret_val = cipso_v4_map_cat_rbm_ntoh(doi_def,
 						    &tag[4],
 						    tag_len - 4,
-						    secattr->mls_cat,
-						    secattr->mls_cat_len);
-		if (ret_val < 0) {
-			kfree(secattr->mls_cat);
+						    secattr);
+		if (ret_val != 0) {
+			netlbl_secattr_catmap_free(secattr->mls_cat);
 			return ret_val;
-		} else if (ret_val > 0) {
-			secattr->mls_cat_len = ret_val;
-			secattr->flags |= NETLBL_SECATTR_MLS_CAT;
 		}
+
+		secattr->flags |= NETLBL_SECATTR_MLS_CAT;
 	}
 
 	return 0;
Index: net-2.6.20_netlabel-cats/net/netlabel/netlabel_kapi.c
===================================================================
--- net-2.6.20_netlabel-cats.orig/net/netlabel/netlabel_kapi.c
+++ net-2.6.20_netlabel-cats/net/netlabel/netlabel_kapi.c
@@ -40,6 +40,207 @@
 #include "netlabel_user.h"
 
 /*
+ * Security Attribute Functions
+ */
+
+/**
+ * netlbl_secattr_catmap_walk - Walk a LSM secattr catmap looking for a bit
+ * @catmap: the category bitmap
+ * @offset: the offset to start searching at, in bits
+ *
+ * Description:
+ * This function walks a LSM secattr category bitmap starting at @offset and
+ * returns the spot of the first set bit or -ENOENT if no bits are set.
+ *
+ */
+int netlbl_secattr_catmap_walk(struct netlbl_lsm_secattr_catmap *catmap,
+			       u32 offset)
+{
+	struct netlbl_lsm_secattr_catmap *iter = catmap;
+	u32 node_idx;
+	u32 node_bit;
+	NETLBL_CATMAP_MAPTYPE bitmap;
+
+	if (offset > iter->startbit) {
+		while (offset >= (iter->startbit + NETLBL_CATMAP_SIZE)) {
+			iter = iter->next;
+			if (iter == NULL)
+				return -ENOENT;
+		}
+		node_idx = (offset - iter->startbit) / NETLBL_CATMAP_MAPSIZE;
+		node_bit = offset - iter->startbit -
+			   (NETLBL_CATMAP_MAPSIZE * node_idx);
+	} else {
+		node_idx = 0;
+		node_bit = 0;
+	}
+	bitmap = iter->bitmap[node_idx] >> node_bit;
+
+	for (;;) {
+		if (bitmap != 0) {
+			while ((bitmap & NETLBL_CATMAP_BIT) == 0) {
+				bitmap >>= 1;
+				node_bit++;
+			}
+			return iter->startbit +
+				(NETLBL_CATMAP_MAPSIZE * node_idx) + node_bit;
+		}
+		if (++node_idx >= NETLBL_CATMAP_MAPCNT) {
+			if (iter->next != NULL) {
+				iter = iter->next;
+				node_idx = 0;
+			} else
+				return -ENOENT;
+		}
+		bitmap = iter->bitmap[node_idx];
+		node_bit = 0;
+	}
+
+	return -ENOENT;
+}
+
+/**
+ * netlbl_secattr_catmap_walk_rng - Find the end of a string of set bits
+ * @catmap: the category bitmap
+ * @offset: the offset to start searching at, in bits
+ *
+ * Description:
+ * This function walks a LSM secattr category bitmap starting at @offset and
+ * returns the spot of the first cleared bit or -ENOENT if the offset is past
+ * the end of the bitmap.
+ *
+ */
+int netlbl_secattr_catmap_walk_rng(struct netlbl_lsm_secattr_catmap *catmap,
+				   u32 offset)
+{
+	struct netlbl_lsm_secattr_catmap *iter = catmap;
+	u32 node_idx;
+	u32 node_bit;
+	NETLBL_CATMAP_MAPTYPE bitmask;
+	NETLBL_CATMAP_MAPTYPE bitmap;
+
+	if (offset > iter->startbit) {
+		while (offset >= (iter->startbit + NETLBL_CATMAP_SIZE)) {
+			iter = iter->next;
+			if (iter == NULL)
+				return -ENOENT;
+		}
+		node_idx = (offset - iter->startbit) / NETLBL_CATMAP_MAPSIZE;
+		node_bit = offset - iter->startbit -
+			   (NETLBL_CATMAP_MAPSIZE * node_idx);
+	} else {
+		node_idx = 0;
+		node_bit = 0;
+	}
+	bitmask = NETLBL_CATMAP_BIT << node_bit;
+
+	for (;;) {
+		bitmap = iter->bitmap[node_idx];
+		while (bitmask != 0 && (bitmap & bitmask) != 0) {
+			bitmask <<= 1;
+			node_bit++;
+		}
+
+		if (bitmask != 0)
+			return iter->startbit +
+				(NETLBL_CATMAP_MAPSIZE * node_idx) +
+				node_bit - 1;
+		else if (++node_idx >= NETLBL_CATMAP_MAPCNT) {
+			if (iter->next == NULL)
+				return iter->startbit +	NETLBL_CATMAP_SIZE - 1;
+			iter = iter->next;
+			node_idx = 0;
+		}
+		bitmask = NETLBL_CATMAP_BIT;
+		node_bit = 0;
+	}
+
+	return -ENOENT;
+}
+
+/**
+ * netlbl_secattr_catmap_setbit - Set a bit in a LSM secattr catmap
+ * @catmap: the category bitmap
+ * @bit: the bit to set
+ * @flags: memory allocation flags
+ *
+ * Description:
+ * Set the bit specified by @bit in @catmap.  Returns zero on success,
+ * negative values on failure.
+ *
+ */
+int netlbl_secattr_catmap_setbit(struct netlbl_lsm_secattr_catmap *catmap,
+				 u32 bit,
+				 gfp_t flags)
+{
+	struct netlbl_lsm_secattr_catmap *iter = catmap;
+	u32 node_bit;
+	u32 node_idx;
+
+	while (iter->next != NULL &&
+	       bit >= (iter->startbit + NETLBL_CATMAP_SIZE))
+		iter = iter->next;
+	if (bit >= (iter->startbit + NETLBL_CATMAP_SIZE)) {
+		iter->next = netlbl_secattr_catmap_alloc(flags);
+		if (iter->next == NULL)
+			return -ENOMEM;
+		iter = iter->next;
+		iter->startbit = bit & ~(NETLBL_CATMAP_SIZE - 1);
+	}
+
+	/* gcc always rounds to zero when doing integer division */
+	node_idx = (bit - iter->startbit) / NETLBL_CATMAP_MAPSIZE;
+	node_bit = bit - iter->startbit - (NETLBL_CATMAP_MAPSIZE * node_idx);
+	iter->bitmap[node_idx] |= NETLBL_CATMAP_BIT << node_bit;
+
+	return 0;
+}
+
+/**
+ * netlbl_secattr_catmap_setrng - Set a range of bits in a LSM secattr catmap
+ * @catmap: the category bitmap
+ * @start: the starting bit
+ * @end: the last bit in the string
+ * @flags: memory allocation flags
+ *
+ * Description:
+ * Set a range of bits, starting at @start and ending with @end.  Returns zero
+ * on success, negative values on failure.
+ *
+ */
+int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap *catmap,
+				 u32 start,
+				 u32 end,
+				 gfp_t flags)
+{
+	int ret_val = 0;
+	struct netlbl_lsm_secattr_catmap *iter = catmap;
+	u32 iter_max_spot;
+	u32 spot;
+
+	/* XXX - This could probably be made a bit faster by combining writes
+	 * to the catmap instead of setting a single bit each time, but for
+	 * right now skipping to the start of the range in the catmap should
+	 * be a nice improvement over calling the individual setbit function
+	 * repeatedly from a loop. */
+
+	while (iter->next != NULL &&
+	       start >= (iter->startbit + NETLBL_CATMAP_SIZE))
+		iter = iter->next;
+	iter_max_spot = iter->startbit + NETLBL_CATMAP_SIZE;
+
+	for (spot = start; spot <= end && ret_val == 0; spot++) {
+		if (spot >= iter_max_spot && iter->next != NULL) {
+			iter = iter->next;
+			iter_max_spot = iter->startbit + NETLBL_CATMAP_SIZE;
+		}
+		ret_val = netlbl_secattr_catmap_setbit(iter, spot, GFP_ATOMIC);
+	}
+
+	return ret_val;
+}
+
+/*
  * LSM Functions
  */
 
Index: net-2.6.20_netlabel-cats/security/selinux/ss/ebitmap.c
===================================================================
--- net-2.6.20_netlabel-cats.orig/security/selinux/ss/ebitmap.c
+++ net-2.6.20_netlabel-cats/security/selinux/ss/ebitmap.c
@@ -6,7 +6,7 @@
 /*
  * Updated: Hewlett-Packard <paul.moore@hp.com>
  *
- *      Added ebitmap_export() and ebitmap_import()
+ *      Added support to import/export the NetLabel category bitmap
  *
  * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
  */
@@ -14,6 +14,7 @@
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/errno.h>
+#include <net/netlabel.h>
 #include "ebitmap.h"
 #include "policydb.h"
 
@@ -67,141 +68,120 @@ int ebitmap_cpy(struct ebitmap *dst, str
 	return 0;
 }
 
+#ifdef CONFIG_NETLABEL
 /**
- * ebitmap_export - Export an ebitmap to a unsigned char bitmap string
- * @src: the ebitmap to export
- * @dst: the resulting bitmap string
- * @dst_len: length of dst in bytes
+ * ebitmap_netlbl_export - Export an ebitmap into a NetLabel category bitmap
+ * @ebmap: the ebitmap to export
+ * @catmap: the NetLabel category bitmap
  *
  * Description:
- * Allocate a buffer at least src->highbit bits long and export the extensible
- * bitmap into the buffer.  The bitmap string will be in little endian format,
- * i.e. LSB first.  The value returned in dst_len may not the true size of the
- * buffer as the length of the buffer is rounded up to a multiple of MAPTYPE.
- * The caller must free the buffer when finished. Returns zero on success,
- * negative values on failure.
+ * Export a SELinux extensibile bitmap into a NetLabel category bitmap.
+ * Returns zero on success, negative values on error.
  *
  */
-int ebitmap_export(const struct ebitmap *src,
-		   unsigned char **dst,
-		   size_t *dst_len)
+int ebitmap_netlbl_export(struct ebitmap *ebmap,
+			  struct netlbl_lsm_secattr_catmap **catmap)
 {
-	size_t bitmap_len;
-	unsigned char *bitmap;
-	struct ebitmap_node *iter_node;
-	MAPTYPE node_val;
-	size_t bitmap_byte;
-	unsigned char bitmask;
-
-	if (src->highbit == 0) {
-		*dst = NULL;
-		*dst_len = 0;
+	struct ebitmap_node *e_iter = ebmap->node;
+	struct netlbl_lsm_secattr_catmap *c_iter;
+	u32 cmap_idx;
+
+	/* This function is a much simpler because SELinux's MAPTYPE happens
+	 * to be the same as NetLabel's NETLBL_CATMAP_MAPTYPE, if MAPTYPE is
+	 * changed from a u64 this function will most likely need to be changed
+	 * as well.  It's not ideal but I think the tradeoff in terms of
+	 * neatness and speed is worth it. */
+
+	if (e_iter == NULL) {
+		*catmap = NULL;
 		return 0;
 	}
 
-	bitmap_len = src->highbit / 8;
-	if (src->highbit % 7)
-		bitmap_len += 1;
-
-	bitmap = kzalloc((bitmap_len & ~(sizeof(MAPTYPE) - 1)) +
-			 sizeof(MAPTYPE),
-			 GFP_ATOMIC);
-	if (bitmap == NULL)
+	c_iter = netlbl_secattr_catmap_alloc(GFP_ATOMIC);
+	if (c_iter == NULL)
 		return -ENOMEM;
+	*catmap = c_iter;
+	c_iter->startbit = e_iter->startbit & ~(NETLBL_CATMAP_SIZE - 1);
 
-	iter_node = src->node;
-	do {
-		bitmap_byte = iter_node->startbit / 8;
-		bitmask = 0x80;
-		node_val = iter_node->map;
-		do {
-			if (bitmask == 0) {
-				bitmap_byte++;
-				bitmask = 0x80;
-			}
-			if (node_val & (MAPTYPE)0x01)
-				bitmap[bitmap_byte] |= bitmask;
-			node_val >>= 1;
-			bitmask >>= 1;
-		} while (node_val > 0);
-		iter_node = iter_node->next;
-	} while (iter_node);
+	while (e_iter != NULL) {
+		if (e_iter->startbit >=
+		    (c_iter->startbit + NETLBL_CATMAP_SIZE)) {
+			c_iter->next = netlbl_secattr_catmap_alloc(GFP_ATOMIC);
+			if (c_iter->next == NULL)
+				goto netlbl_export_failure;
+			c_iter = c_iter->next;
+			c_iter->startbit = e_iter->startbit &
+				           ~(NETLBL_CATMAP_SIZE - 1);
+		}
+		cmap_idx = (e_iter->startbit - c_iter->startbit) /
+			   NETLBL_CATMAP_MAPSIZE;
+		c_iter->bitmap[cmap_idx] = e_iter->map;
+		e_iter = e_iter->next;
+	}
 
-	*dst = bitmap;
-	*dst_len = bitmap_len;
 	return 0;
+
+netlbl_export_failure:
+	netlbl_secattr_catmap_free(*catmap);
+	return -ENOMEM;
 }
 
 /**
- * ebitmap_import - Import an unsigned char bitmap string into an ebitmap
- * @src: the bitmap string
- * @src_len: the bitmap length in bytes
- * @dst: the empty ebitmap
+ * ebitmap_netlbl_import - Import a NetLabel category bitmap into an ebitmap
+ * @ebmap: the ebitmap to export
+ * @catmap: the NetLabel category bitmap
  *
  * Description:
- * This function takes a little endian bitmap string in src and imports it into
- * the ebitmap pointed to by dst.  Returns zero on success, negative values on
- * failure.
+ * Import a NetLabel category bitmap into a SELinux extensibile bitmap.
+ * Returns zero on success, negative values on error.
  *
  */
-int ebitmap_import(const unsigned char *src,
-		   size_t src_len,
-		   struct ebitmap *dst)
+int ebitmap_netlbl_import(struct ebitmap *ebmap,
+			  struct netlbl_lsm_secattr_catmap *catmap)
 {
-	size_t src_off = 0;
-	size_t node_limit;
-	struct ebitmap_node *node_new;
-	struct ebitmap_node *node_last = NULL;
-	u32 i_byte;
-	u32 i_bit;
-	unsigned char src_byte;
-
-	while (src_off < src_len) {
-		if (src_len - src_off >= sizeof(MAPTYPE)) {
-			if (*(MAPTYPE *)&src[src_off] == 0) {
-				src_off += sizeof(MAPTYPE);
-				continue;
-			}
-			node_limit = sizeof(MAPTYPE);
-		} else {
-			for (src_byte = 0, i_byte = src_off;
-			     i_byte < src_len && src_byte == 0;
-			     i_byte++)
-				src_byte |= src[i_byte];
-			if (src_byte == 0)
-				break;
-			node_limit = src_len - src_off;
-		}
+	struct ebitmap_node *e_iter = NULL;
+	struct ebitmap_node *emap_prev = NULL;
+	struct netlbl_lsm_secattr_catmap *c_iter = catmap;
+	u32 c_idx;
+
+	/* This function is a much simpler because SELinux's MAPTYPE happens
+	 * to be the same as NetLabel's NETLBL_CATMAP_MAPTYPE, if MAPTYPE is
+	 * changed from a u64 this function will most likely need to be changed
+	 * as well.  It's not ideal but I think the tradeoff in terms of
+	 * neatness and speed is worth it. */
 
-		node_new = kzalloc(sizeof(*node_new), GFP_ATOMIC);
-		if (unlikely(node_new == NULL)) {
-			ebitmap_destroy(dst);
-			return -ENOMEM;
-		}
-		node_new->startbit = src_off * 8;
-		for (i_byte = 0; i_byte < node_limit; i_byte++) {
-			src_byte = src[src_off++];
-			for (i_bit = i_byte * 8; src_byte != 0; i_bit++) {
-				if (src_byte & 0x80)
-					node_new->map |= MAPBIT << i_bit;
-				src_byte <<= 1;
-			}
-		}
+	do {
+		for (c_idx = 0; c_idx < NETLBL_CATMAP_MAPCNT; c_idx++) {
+			if (c_iter->bitmap[c_idx] == 0)
+				continue;
 
-		if (node_last != NULL)
-			node_last->next = node_new;
-		else
-			dst->node = node_new;
-		node_last = node_new;
-	}
+			e_iter = kzalloc(sizeof(*e_iter), GFP_ATOMIC);
+			if (e_iter == NULL)
+				goto netlbl_import_failure;
+			if (emap_prev == NULL)
+				ebmap->node = e_iter;
+			else
+				emap_prev->next = e_iter;
+			emap_prev = e_iter;
 
-	if (likely(node_last != NULL))
-		dst->highbit = node_last->startbit + MAPSIZE;
+			e_iter->startbit = c_iter->startbit +
+				           NETLBL_CATMAP_MAPSIZE * c_idx;
+			e_iter->map = c_iter->bitmap[c_idx];
+		}
+		c_iter = c_iter->next;
+	} while (c_iter != NULL);
+	if (e_iter != NULL)
+		ebmap->highbit = e_iter->startbit + MAPSIZE;
 	else
-		ebitmap_init(dst);
+		ebitmap_destroy(ebmap);
 
 	return 0;
+
+netlbl_import_failure:
+	ebitmap_destroy(ebmap);
+	return -ENOMEM;
 }
+#endif /* CONFIG_NETLABEL */
 
 int ebitmap_contains(struct ebitmap *e1, struct ebitmap *e2)
 {
Index: net-2.6.20_netlabel-cats/security/selinux/ss/ebitmap.h
===================================================================
--- net-2.6.20_netlabel-cats.orig/security/selinux/ss/ebitmap.h
+++ net-2.6.20_netlabel-cats/security/selinux/ss/ebitmap.h
@@ -14,6 +14,8 @@
 #ifndef _SS_EBITMAP_H_
 #define _SS_EBITMAP_H_
 
+#include <net/netlabel.h>
+
 #define MAPTYPE u64			/* portion of bitmap in each node */
 #define MAPSIZE (sizeof(MAPTYPE) * 8)	/* number of bits in node bitmap */
 #define MAPBIT  1ULL			/* a bit in the node bitmap */
@@ -69,16 +71,28 @@ static inline int ebitmap_node_get_bit(s
 
 int ebitmap_cmp(struct ebitmap *e1, struct ebitmap *e2);
 int ebitmap_cpy(struct ebitmap *dst, struct ebitmap *src);
-int ebitmap_export(const struct ebitmap *src,
-		   unsigned char **dst,
-		   size_t *dst_len);
-int ebitmap_import(const unsigned char *src,
-		   size_t src_len,
-		   struct ebitmap *dst);
 int ebitmap_contains(struct ebitmap *e1, struct ebitmap *e2);
 int ebitmap_get_bit(struct ebitmap *e, unsigned long bit);
 int ebitmap_set_bit(struct ebitmap *e, unsigned long bit, int value);
 void ebitmap_destroy(struct ebitmap *e);
 int ebitmap_read(struct ebitmap *e, void *fp);
 
+#ifdef CONFIG_NETLABEL
+int ebitmap_netlbl_export(struct ebitmap *ebmap,
+			  struct netlbl_lsm_secattr_catmap **catmap);
+int ebitmap_netlbl_import(struct ebitmap *ebmap,
+			  struct netlbl_lsm_secattr_catmap *catmap);
+#else
+static inline int ebitmap_netlbl_export(struct ebitmap *ebmap,
+				struct netlbl_lsm_secattr_catmap **catmap)
+{
+	return -ENOMEM;
+}
+static inline int ebitmap_netlbl_import(struct ebitmap *ebmap,
+				struct netlbl_lsm_secattr_catmap *catmap)
+{
+	return -ENOMEM;
+}
+#endif
+
 #endif	/* _SS_EBITMAP_H_ */
Index: net-2.6.20_netlabel-cats/security/selinux/ss/mls.c
===================================================================
--- net-2.6.20_netlabel-cats.orig/security/selinux/ss/mls.c
+++ net-2.6.20_netlabel-cats/security/selinux/ss/mls.c
@@ -13,7 +13,7 @@
 /*
  * Updated: Hewlett-Packard <paul.moore@hp.com>
  *
- *      Added support to import/export the MLS label
+ *      Added support to import/export the MLS label from NetLabel
  *
  * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
  */
@@ -22,6 +22,7 @@
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/errno.h>
+#include <net/netlabel.h>
 #include "sidtab.h"
 #include "mls.h"
 #include "policydb.h"
@@ -571,163 +572,108 @@ int mls_compute_sid(struct context *scon
 	return -EINVAL;
 }
 
+#ifdef CONFIG_NETLABEL
 /**
- * mls_export_lvl - Export the MLS sensitivity levels
+ * mls_export_netlbl_lvl - Export the MLS sensitivity levels to NetLabel
  * @context: the security context
- * @low: the low sensitivity level
- * @high: the high sensitivity level
+ * @secattr: the NetLabel security attributes
  *
  * Description:
- * Given the security context copy the low MLS sensitivity level into lvl_low
- * and the high sensitivity level in lvl_high.  The MLS levels are only
- * exported if the pointers are not NULL, if they are NULL then that level is
- * not exported.
+ * Given the security context copy the low MLS sensitivity level into the
+ * NetLabel MLS sensitivity level field.
  *
  */
-void mls_export_lvl(const struct context *context, u32 *low, u32 *high)
+void mls_export_netlbl_lvl(struct context *context,
+			   struct netlbl_lsm_secattr *secattr)
 {
 	if (!selinux_mls_enabled)
 		return;
 
-	if (low != NULL)
-		*low = context->range.level[0].sens - 1;
-	if (high != NULL)
-		*high = context->range.level[1].sens - 1;
+	secattr->mls_lvl = context->range.level[0].sens - 1;
+	secattr->flags |= NETLBL_SECATTR_MLS_LVL;
 }
 
 /**
- * mls_import_lvl - Import the MLS sensitivity levels
+ * mls_import_netlbl_lvl - Import the NetLabel MLS sensitivity levels
  * @context: the security context
- * @low: the low sensitivity level
- * @high: the high sensitivity level
+ * @secattr: the NetLabel security attributes
  *
  * Description:
- * Given the security context and the two sensitivty levels, set the MLS levels
- * in the context according the two given as parameters.  Returns zero on
- * success, negative values on failure.
+ * Given the security context and the NetLabel security attributes, copy the
+ * NetLabel MLS sensitivity level into the context.
  *
  */
-void mls_import_lvl(struct context *context, u32 low, u32 high)
+void mls_import_netlbl_lvl(struct context *context,
+			   struct netlbl_lsm_secattr *secattr)
 {
 	if (!selinux_mls_enabled)
 		return;
 
-	context->range.level[0].sens = low + 1;
-	context->range.level[1].sens = high + 1;
+	context->range.level[0].sens = secattr->mls_lvl + 1;
+	context->range.level[1].sens = context->range.level[0].sens;
 }
 
 /**
- * mls_export_cat - Export the MLS categories
+ * mls_export_netlbl_cat - Export the MLS categories to NetLabel
  * @context: the security context
- * @low: the low category
- * @low_len: length of the cat_low bitmap in bytes
- * @high: the high category
- * @high_len: length of the cat_high bitmap in bytes
+ * @secattr: the NetLabel security attributes
  *
  * Description:
- * Given the security context export the low MLS category bitmap into cat_low
- * and the high category bitmap into cat_high.  The MLS categories are only
- * exported if the pointers are not NULL, if they are NULL then that level is
- * not exported.  The caller is responsibile for freeing the memory when
- * finished.  Returns zero on success, negative values on failure.
+ * Given the security context copy the low MLS categories into the NetLabel
+ * MLS category field.  Returns zero on success, negative values on failure.
  *
  */
-int mls_export_cat(const struct context *context,
-		   unsigned char **low,
-		   size_t *low_len,
-		   unsigned char **high,
-		   size_t *high_len)
+int mls_export_netlbl_cat(struct context *context,
+			  struct netlbl_lsm_secattr *secattr)
 {
-	int rc = -EPERM;
+	int rc;
 
-	if (!selinux_mls_enabled) {
-		*low = NULL;
-		*low_len = 0;
-		*high = NULL;
-		*high_len = 0;
+	if (!selinux_mls_enabled)
 		return 0;
-	}
 
-	if (low != NULL) {
-		rc = ebitmap_export(&context->range.level[0].cat,
-				    low,
-				    low_len);
-		if (rc != 0)
-			goto export_cat_failure;
-	}
-	if (high != NULL) {
-		rc = ebitmap_export(&context->range.level[1].cat,
-				    high,
-				    high_len);
-		if (rc != 0)
-			goto export_cat_failure;
-	}
+	rc = ebitmap_netlbl_export(&context->range.level[0].cat,
+				   &secattr->mls_cat);
+	if (rc == 0 && secattr->mls_cat != NULL)
+		secattr->flags |= NETLBL_SECATTR_MLS_CAT;
 
-	return 0;
-
-export_cat_failure:
-	if (low != NULL) {
-		kfree(*low);
-		*low = NULL;
-		*low_len = 0;
-	}
-	if (high != NULL) {
-		kfree(*high);
-		*high = NULL;
-		*high_len = 0;
-	}
 	return rc;
 }
 
 /**
- * mls_import_cat - Import the MLS categories
+ * mls_import_netlbl_cat - Import the MLS categories from NetLabel
  * @context: the security context
- * @low: the low category
- * @low_len: length of the cat_low bitmap in bytes
- * @high: the high category
- * @high_len: length of the cat_high bitmap in bytes
+ * @secattr: the NetLabel security attributes
  *
  * Description:
- * Given the security context and the two category bitmap strings import the
- * categories into the security context.  The MLS categories are only imported
- * if the pointers are not NULL, if they are NULL they are skipped.  Returns
- * zero on success, negative values on failure.
+ * Copy the NetLabel security attributes into the SELinux context; since the
+ * NetLabel security attribute only contains a single MLS category use it for
+ * both the low and high categories of the context.  Returns zero on success,
+ * negative values on failure.
  *
  */
-int mls_import_cat(struct context *context,
-		   const unsigned char *low,
-		   size_t low_len,
-		   const unsigned char *high,
-		   size_t high_len)
+int mls_import_netlbl_cat(struct context *context,
+			  struct netlbl_lsm_secattr *secattr)
 {
-	int rc = -EPERM;
+	int rc;
 
 	if (!selinux_mls_enabled)
 		return 0;
 
-	if (low != NULL) {
-		rc = ebitmap_import(low,
-				    low_len,
-				    &context->range.level[0].cat);
-		if (rc != 0)
-			goto import_cat_failure;
-	}
-	if (high != NULL) {
-		if (high == low)
-			rc = ebitmap_cpy(&context->range.level[1].cat,
-					 &context->range.level[0].cat);
-		else
-			rc = ebitmap_import(high,
-					    high_len,
-					    &context->range.level[1].cat);
-		if (rc != 0)
-			goto import_cat_failure;
-	}
+	rc = ebitmap_netlbl_import(&context->range.level[0].cat,
+				   secattr->mls_cat);
+	if (rc != 0)
+		goto import_netlbl_cat_failure;
+
+	rc = ebitmap_cpy(&context->range.level[1].cat,
+			 &context->range.level[0].cat);
+	if (rc != 0)
+		goto import_netlbl_cat_failure;
 
 	return 0;
 
-import_cat_failure:
+import_netlbl_cat_failure:
 	ebitmap_destroy(&context->range.level[0].cat);
 	ebitmap_destroy(&context->range.level[1].cat);
 	return rc;
 }
+#endif /* CONFIG_NETLABEL */
Index: net-2.6.20_netlabel-cats/security/selinux/ss/mls.h
===================================================================
--- net-2.6.20_netlabel-cats.orig/security/selinux/ss/mls.h
+++ net-2.6.20_netlabel-cats/security/selinux/ss/mls.h
@@ -13,7 +13,7 @@
 /*
  * Updated: Hewlett-Packard <paul.moore@hp.com>
  *
- *      Added support to import/export the MLS label
+ *      Added support to import/export the MLS label from NetLabel
  *
  * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
  */
@@ -69,19 +69,37 @@ int mls_compute_sid(struct context *scon
 int mls_setup_user_range(struct context *fromcon, struct user_datum *user,
                          struct context *usercon);
 
-void mls_export_lvl(const struct context *context, u32 *low, u32 *high);
-void mls_import_lvl(struct context *context, u32 low, u32 high);
-
-int mls_export_cat(const struct context *context,
-		   unsigned char **low,
-		   size_t *low_len,
-		   unsigned char **high,
-		   size_t *high_len);
-int mls_import_cat(struct context *context,
-		   const unsigned char *low,
-		   size_t low_len,
-		   const unsigned char *high,
-		   size_t high_len);
+#ifdef CONFIG_NETLABEL
+void mls_export_netlbl_lvl(struct context *context,
+			   struct netlbl_lsm_secattr *secattr);
+void mls_import_netlbl_lvl(struct context *context,
+			   struct netlbl_lsm_secattr *secattr);
+int mls_export_netlbl_cat(struct context *context,
+			  struct netlbl_lsm_secattr *secattr);
+int mls_import_netlbl_cat(struct context *context,
+			  struct netlbl_lsm_secattr *secattr);
+#else
+static inline void mls_export_netlbl_lvl(struct context *context,
+					 struct netlbl_lsm_secattr *secattr)
+{
+	return;
+}
+static inline void mls_import_netlbl_lvl(struct context *context,
+					 struct netlbl_lsm_secattr *secattr)
+{
+	return;
+}
+static inline int mls_export_netlbl_cat(struct context *context,
+					struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOMEM;
+}
+static inline int mls_import_netlbl_cat(struct context *context,
+					struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOMEM;
+}
+#endif
 
 #endif	/* _SS_MLS_H */
 
Index: net-2.6.20_netlabel-cats/security/selinux/ss/services.c
===================================================================
--- net-2.6.20_netlabel-cats.orig/security/selinux/ss/services.c
+++ net-2.6.20_netlabel-cats/security/selinux/ss/services.c
@@ -51,6 +51,7 @@
 #include "objsec.h"
 #include "selinux_netlabel.h"
 #include "xfrm.h"
+#include "ebitmap.h"
 
 extern void selnl_notify_policyload(u32 seqno);
 unsigned int policydb_loaded_version;
@@ -2339,13 +2340,10 @@ static int selinux_netlbl_secattr_to_sid
 		ctx_new.user = ctx->user;
 		ctx_new.role = ctx->role;
 		ctx_new.type = ctx->type;
-		mls_import_lvl(&ctx_new, secattr->mls_lvl, secattr->mls_lvl);
+		mls_import_netlbl_lvl(&ctx_new, secattr);
 		if (secattr->flags & NETLBL_SECATTR_MLS_CAT) {
-			if (mls_import_cat(&ctx_new,
-					   secattr->mls_cat,
-					   secattr->mls_cat_len,
-					   NULL,
-					   0) != 0)
+			if (ebitmap_netlbl_import(&ctx_new.range.level[0].cat,
+						  secattr->mls_cat) != 0)
 				goto netlbl_secattr_to_sid_return;
 			ctx_new.range.level[1].cat.highbit =
 				ctx_new.range.level[0].cat.highbit;
@@ -2441,19 +2439,12 @@ static int selinux_netlbl_socket_setsid(
 
 	secattr.domain = kstrdup(policydb.p_type_val_to_name[ctx->type - 1],
 				 GFP_ATOMIC);
-	mls_export_lvl(ctx, &secattr.mls_lvl, NULL);
-	rc = mls_export_cat(ctx,
-			    &secattr.mls_cat,
-			    &secattr.mls_cat_len,
-			    NULL,
-			    NULL);
+	secattr.flags |= NETLBL_SECATTR_DOMAIN;
+	mls_export_netlbl_lvl(ctx, &secattr);
+	rc = mls_export_netlbl_cat(ctx, &secattr);
 	if (rc != 0)
 		goto netlbl_socket_setsid_return;
 
-	secattr.flags |= NETLBL_SECATTR_DOMAIN | NETLBL_SECATTR_MLS_LVL;
-	if (secattr.mls_cat)
-		secattr.flags |= NETLBL_SECATTR_MLS_CAT;
-
 	rc = netlbl_socket_setattr(sock, &secattr);
 	if (rc == 0) {
 		spin_lock(&sksec->nlbl_lock);

--
paul moore
linux security @ hp
