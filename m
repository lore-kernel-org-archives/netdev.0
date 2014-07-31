From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH 4/4] netlabel: shorter names for the NetLabel catmap
 funcs/structs
Date: Thu, 31 Jul 2014 17:44:46 -0400
Message-ID: <20140731214446.4991.92488.stgit@localhost>
References: <20140731212856.4991.49396.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Christian Evans <frodox@zoho.com>,
	Casey Schaufler <casey@schaufler-ca.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20140731212856.4991.49396.stgit@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Historically the NetLabel LSM secattr catmap functions and data
structures have had very long names which makes a mess of the NetLabel
code and anyone who uses NetLabel.  This patch renames the catmap
functions and structures from "*_secattr_catmap_*" to just "*_catmap_*"
which improves things greatly.

There are no substantial code or logic changes in this patch.

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 include/net/netlabel.h        |  100 +++++++++++++++++---------------------
 net/ipv4/cipso_ipv4.c         |   35 ++++++-------
 net/netlabel/netlabel_kapi.c  |  109 ++++++++++++++++++++---------------------
 security/selinux/ss/ebitmap.c |   18 +++----
 security/selinux/ss/ebitmap.h |    8 ++-
 security/smack/smack_access.c |    6 +-
 security/smack/smack_lsm.c    |    6 +-
 security/smack/smackfs.c      |   14 +++--
 8 files changed, 139 insertions(+), 157 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index bda7a12..a4fc39b 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -139,7 +139,7 @@ struct netlbl_lsm_cache {
 };
 
 /**
- * struct netlbl_lsm_secattr_catmap - NetLabel LSM secattr category bitmap
+ * struct netlbl_lsm_catmap - NetLabel LSM secattr category bitmap
  * @startbit: the value of the lowest order bit in the bitmap
  * @bitmap: the category bitmap
  * @next: pointer to the next bitmap "node" or NULL
@@ -162,10 +162,10 @@ struct netlbl_lsm_cache {
 #define NETLBL_CATMAP_SIZE              (NETLBL_CATMAP_MAPSIZE * \
 					 NETLBL_CATMAP_MAPCNT)
 #define NETLBL_CATMAP_BIT               (NETLBL_CATMAP_MAPTYPE)0x01
-struct netlbl_lsm_secattr_catmap {
+struct netlbl_lsm_catmap {
 	u32 startbit;
 	NETLBL_CATMAP_MAPTYPE bitmap[NETLBL_CATMAP_MAPCNT];
-	struct netlbl_lsm_secattr_catmap *next;
+	struct netlbl_lsm_catmap *next;
 };
 
 /**
@@ -209,7 +209,7 @@ struct netlbl_lsm_secattr {
 	struct netlbl_lsm_cache *cache;
 	struct {
 		struct {
-			struct netlbl_lsm_secattr_catmap *cat;
+			struct netlbl_lsm_catmap *cat;
 			u32 lvl;
 		} mls;
 		u32 secid;
@@ -258,7 +258,7 @@ static inline void netlbl_secattr_cache_free(struct netlbl_lsm_cache *cache)
 }
 
 /**
- * netlbl_secattr_catmap_alloc - Allocate a LSM secattr catmap
+ * netlbl_catmap_alloc - Allocate a LSM secattr catmap
  * @flags: memory allocation flags
  *
  * Description:
@@ -266,24 +266,22 @@ static inline void netlbl_secattr_cache_free(struct netlbl_lsm_cache *cache)
  * on failure.
  *
  */
-static inline struct netlbl_lsm_secattr_catmap *netlbl_secattr_catmap_alloc(
-	                                                           gfp_t flags)
+static inline struct netlbl_lsm_catmap *netlbl_catmap_alloc(gfp_t flags)
 {
-	return kzalloc(sizeof(struct netlbl_lsm_secattr_catmap), flags);
+	return kzalloc(sizeof(struct netlbl_lsm_catmap), flags);
 }
 
 /**
- * netlbl_secattr_catmap_free - Free a LSM secattr catmap
+ * netlbl_catmap_free - Free a LSM secattr catmap
  * @catmap: the category bitmap
  *
  * Description:
  * Free a LSM secattr catmap.
  *
  */
-static inline void netlbl_secattr_catmap_free(
-	                              struct netlbl_lsm_secattr_catmap *catmap)
+static inline void netlbl_catmap_free(struct netlbl_lsm_catmap *catmap)
 {
-	struct netlbl_lsm_secattr_catmap *iter;
+	struct netlbl_lsm_catmap *iter;
 
 	while (catmap) {
 		iter = catmap;
@@ -321,7 +319,7 @@ static inline void netlbl_secattr_destroy(struct netlbl_lsm_secattr *secattr)
 	if (secattr->flags & NETLBL_SECATTR_CACHE)
 		netlbl_secattr_cache_free(secattr->cache);
 	if (secattr->flags & NETLBL_SECATTR_MLS_CAT)
-		netlbl_secattr_catmap_free(secattr->attr.mls.cat);
+		netlbl_catmap_free(secattr->attr.mls.cat);
 }
 
 /**
@@ -390,24 +388,22 @@ int netlbl_cfg_cipsov4_map_add(u32 doi,
 /*
  * LSM security attribute operations
  */
-int netlbl_secattr_catmap_walk(struct netlbl_lsm_secattr_catmap *catmap,
-			       u32 offset);
-int netlbl_secattr_catmap_walk_rng(struct netlbl_lsm_secattr_catmap *catmap,
-				   u32 offset);
-int netlbl_secattr_catmap_getlong(struct netlbl_lsm_secattr_catmap *catmap,
-				  u32 *offset,
-				  unsigned long *bitmap);
-int netlbl_secattr_catmap_setbit(struct netlbl_lsm_secattr_catmap **catmap,
-				 u32 bit,
-				 gfp_t flags);
-int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap **catmap,
-				 u32 start,
-				 u32 end,
-				 gfp_t flags);
-int netlbl_secattr_catmap_setlong(struct netlbl_lsm_secattr_catmap **catmap,
-				  u32 offset,
-				  unsigned long bitmap,
-				  gfp_t flags);
+int netlbl_catmap_walk(struct netlbl_lsm_catmap *catmap, u32 offset);
+int netlbl_catmap_walkrng(struct netlbl_lsm_catmap *catmap, u32 offset);
+int netlbl_catmap_getlong(struct netlbl_lsm_catmap *catmap,
+			  u32 *offset,
+			  unsigned long *bitmap);
+int netlbl_catmap_setbit(struct netlbl_lsm_catmap **catmap,
+			 u32 bit,
+			 gfp_t flags);
+int netlbl_catmap_setrng(struct netlbl_lsm_catmap **catmap,
+			 u32 start,
+			 u32 end,
+			 gfp_t flags);
+int netlbl_catmap_setlong(struct netlbl_lsm_catmap **catmap,
+			  u32 offset,
+			  unsigned long bitmap,
+			  gfp_t flags);
 
 /*
  * LSM protocol operations (NetLabel LSM/kernel API)
@@ -499,45 +495,39 @@ static inline int netlbl_cfg_cipsov4_map_add(u32 doi,
 {
 	return -ENOSYS;
 }
-static inline int netlbl_secattr_catmap_walk(
-	                              struct netlbl_lsm_secattr_catmap *catmap,
-				      u32 offset)
+static inline int netlbl_catmap_walk(struct netlbl_lsm_catmap *catmap,
+				     u32 offset)
 {
 	return -ENOENT;
 }
-static inline int netlbl_secattr_catmap_walk_rng(
-				      struct netlbl_lsm_secattr_catmap *catmap,
-				      u32 offset)
+static inline int netlbl_catmap_walkrng(struct netlbl_lsm_catmap *catmap,
+					u32 offset)
 {
 	return -ENOENT;
 }
-static inline int netlbl_secattr_catmap_getlong(
-				      struct netlbl_lsm_secattr_catmap *catmap,
-				      u32 *offset,
-				      unsigned long *bitmap)
+static inline int netlbl_catmap_getlong(struct netlbl_lsm_catmap *catmap,
+					u32 *offset,
+					unsigned long *bitmap)
 {
 	return 0;
 }
-static inline int netlbl_secattr_catmap_setbit(
-				      struct netlbl_lsm_secattr_catmap **catmap,
-				      u32 bit,
-				      gfp_t flags)
+static inline int netlbl_catmap_setbit(struct netlbl_lsm_catmap **catmap,
+				       u32 bit,
+				       gfp_t flags)
 {
 	return 0;
 }
-static inline int netlbl_secattr_catmap_setrng(
-				      struct netlbl_lsm_secattr_catmap **catmap,
-				      u32 start,
-				      u32 end,
-				      gfp_t flags)
+static inline int netlbl_catmap_setrng(struct netlbl_lsm_catmap **catmap,
+				       u32 start,
+				       u32 end,
+				       gfp_t flags)
 {
 	return 0;
 }
-static int netlbl_secattr_catmap_setlong(
-				      struct netlbl_lsm_secattr_catmap **catmap,
-				      u32 offset,
-				      unsigned long bitmap,
-				      gfp_t flags)
+static int netlbl_catmap_setlong(struct netlbl_lsm_catmap **catmap,
+				 u32 offset,
+				 unsigned long bitmap,
+				 gfp_t flags)
 {
 	return 0;
 }
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 8a0c7bd..05b708b 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -890,8 +890,8 @@ static int cipso_v4_map_cat_rbm_hton(const struct cipso_v4_doi *doi_def,
 	}
 
 	for (;;) {
-		host_spot = netlbl_secattr_catmap_walk(secattr->attr.mls.cat,
-						       host_spot + 1);
+		host_spot = netlbl_catmap_walk(secattr->attr.mls.cat,
+					       host_spot + 1);
 		if (host_spot < 0)
 			break;
 
@@ -973,7 +973,7 @@ static int cipso_v4_map_cat_rbm_ntoh(const struct cipso_v4_doi *doi_def,
 				return -EPERM;
 			break;
 		}
-		ret_val = netlbl_secattr_catmap_setbit(&secattr->attr.mls.cat,
+		ret_val = netlbl_catmap_setbit(&secattr->attr.mls.cat,
 						       host_spot,
 						       GFP_ATOMIC);
 		if (ret_val != 0)
@@ -1039,8 +1039,7 @@ static int cipso_v4_map_cat_enum_hton(const struct cipso_v4_doi *doi_def,
 	u32 cat_iter = 0;
 
 	for (;;) {
-		cat = netlbl_secattr_catmap_walk(secattr->attr.mls.cat,
-						 cat + 1);
+		cat = netlbl_catmap_walk(secattr->attr.mls.cat, cat + 1);
 		if (cat < 0)
 			break;
 		if ((cat_iter + 2) > net_cat_len)
@@ -1075,9 +1074,9 @@ static int cipso_v4_map_cat_enum_ntoh(const struct cipso_v4_doi *doi_def,
 	u32 iter;
 
 	for (iter = 0; iter < net_cat_len; iter += 2) {
-		ret_val = netlbl_secattr_catmap_setbit(&secattr->attr.mls.cat,
-				get_unaligned_be16(&net_cat[iter]),
-				GFP_ATOMIC);
+		ret_val = netlbl_catmap_setbit(&secattr->attr.mls.cat,
+					     get_unaligned_be16(&net_cat[iter]),
+					     GFP_ATOMIC);
 		if (ret_val != 0)
 			return ret_val;
 	}
@@ -1155,8 +1154,7 @@ static int cipso_v4_map_cat_rng_hton(const struct cipso_v4_doi *doi_def,
 		return -ENOSPC;
 
 	for (;;) {
-		iter = netlbl_secattr_catmap_walk(secattr->attr.mls.cat,
-						  iter + 1);
+		iter = netlbl_catmap_walk(secattr->attr.mls.cat, iter + 1);
 		if (iter < 0)
 			break;
 		cat_size += (iter == 0 ? 0 : sizeof(u16));
@@ -1164,8 +1162,7 @@ static int cipso_v4_map_cat_rng_hton(const struct cipso_v4_doi *doi_def,
 			return -ENOSPC;
 		array[array_cnt++] = iter;
 
-		iter = netlbl_secattr_catmap_walk_rng(secattr->attr.mls.cat,
-						      iter);
+		iter = netlbl_catmap_walkrng(secattr->attr.mls.cat, iter);
 		if (iter < 0)
 			return -EFAULT;
 		cat_size += sizeof(u16);
@@ -1217,10 +1214,10 @@ static int cipso_v4_map_cat_rng_ntoh(const struct cipso_v4_doi *doi_def,
 		else
 			cat_low = 0;
 
-		ret_val = netlbl_secattr_catmap_setrng(&secattr->attr.mls.cat,
-						       cat_low,
-						       cat_high,
-						       GFP_ATOMIC);
+		ret_val = netlbl_catmap_setrng(&secattr->attr.mls.cat,
+					       cat_low,
+					       cat_high,
+					       GFP_ATOMIC);
 		if (ret_val != 0)
 			return ret_val;
 	}
@@ -1340,7 +1337,7 @@ static int cipso_v4_parsetag_rbm(const struct cipso_v4_doi *doi_def,
 						    tag_len - 4,
 						    secattr);
 		if (ret_val != 0) {
-			netlbl_secattr_catmap_free(secattr->attr.mls.cat);
+			netlbl_catmap_free(secattr->attr.mls.cat);
 			return ret_val;
 		}
 
@@ -1431,7 +1428,7 @@ static int cipso_v4_parsetag_enum(const struct cipso_v4_doi *doi_def,
 						     tag_len - 4,
 						     secattr);
 		if (ret_val != 0) {
-			netlbl_secattr_catmap_free(secattr->attr.mls.cat);
+			netlbl_catmap_free(secattr->attr.mls.cat);
 			return ret_val;
 		}
 
@@ -1521,7 +1518,7 @@ static int cipso_v4_parsetag_rng(const struct cipso_v4_doi *doi_def,
 						    tag_len - 4,
 						    secattr);
 		if (ret_val != 0) {
-			netlbl_secattr_catmap_free(secattr->attr.mls.cat);
+			netlbl_catmap_free(secattr->attr.mls.cat);
 			return ret_val;
 		}
 
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index bc38838..05ea4a4 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -410,7 +410,7 @@ out_entry:
 #define _CM_F_WALK	0x00000002
 
 /**
- * _netlbl_secattr_catmap_getnode - Get a individual node from a catmap
+ * _netlbl_catmap_getnode - Get a individual node from a catmap
  * @catmap: pointer to the category bitmap
  * @offset: the requested offset
  * @cm_flags: catmap flags, see _CM_F_*
@@ -424,36 +424,36 @@ out_entry:
  * be returned.  Returns a pointer to the node on success, NULL on failure.
  *
  */
-static struct netlbl_lsm_secattr_catmap *_netlbl_secattr_catmap_getnode(
-				struct netlbl_lsm_secattr_catmap **catmap,
-				u32 offset,
-				unsigned int cm_flags,
-				gfp_t gfp_flags)
+static struct netlbl_lsm_catmap *_netlbl_catmap_getnode(
+					     struct netlbl_lsm_catmap **catmap,
+					     u32 offset,
+					     unsigned int cm_flags,
+					     gfp_t gfp_flags)
 {
-	struct netlbl_lsm_secattr_catmap *iter = *catmap;
-	struct netlbl_lsm_secattr_catmap *prev = NULL;
+	struct netlbl_lsm_catmap *iter = *catmap;
+	struct netlbl_lsm_catmap *prev = NULL;
 
 	if (iter == NULL)
-		goto secattr_catmap_getnode_alloc;
+		goto catmap_getnode_alloc;
 	if (offset < iter->startbit)
-		goto secattr_catmap_getnode_walk;
+		goto catmap_getnode_walk;
 	while (iter && offset >= (iter->startbit + NETLBL_CATMAP_SIZE)) {
 		prev = iter;
 		iter = iter->next;
 	}
 	if (iter == NULL || offset < iter->startbit)
-		goto secattr_catmap_getnode_walk;
+		goto catmap_getnode_walk;
 
 	return iter;
 
-secattr_catmap_getnode_walk:
+catmap_getnode_walk:
 	if (cm_flags & _CM_F_WALK)
 		return iter;
-secattr_catmap_getnode_alloc:
+catmap_getnode_alloc:
 	if (!(cm_flags & _CM_F_ALLOC))
 		return NULL;
 
-	iter = netlbl_secattr_catmap_alloc(gfp_flags);
+	iter = netlbl_catmap_alloc(gfp_flags);
 	if (iter == NULL)
 		return NULL;
 	iter->startbit = offset & ~(NETLBL_CATMAP_SIZE - 1);
@@ -470,7 +470,7 @@ secattr_catmap_getnode_alloc:
 }
 
 /**
- * netlbl_secattr_catmap_walk - Walk a LSM secattr catmap looking for a bit
+ * netlbl_catmap_walk - Walk a LSM secattr catmap looking for a bit
  * @catmap: the category bitmap
  * @offset: the offset to start searching at, in bits
  *
@@ -479,15 +479,14 @@ secattr_catmap_getnode_alloc:
  * returns the spot of the first set bit or -ENOENT if no bits are set.
  *
  */
-int netlbl_secattr_catmap_walk(struct netlbl_lsm_secattr_catmap *catmap,
-			       u32 offset)
+int netlbl_catmap_walk(struct netlbl_lsm_catmap *catmap, u32 offset)
 {
-	struct netlbl_lsm_secattr_catmap *iter = catmap;
+	struct netlbl_lsm_catmap *iter = catmap;
 	u32 idx;
 	u32 bit;
 	NETLBL_CATMAP_MAPTYPE bitmap;
 
-	iter = _netlbl_secattr_catmap_getnode(&catmap, offset, _CM_F_WALK, 0);
+	iter = _netlbl_catmap_getnode(&catmap, offset, _CM_F_WALK, 0);
 	if (iter == NULL)
 		return -ENOENT;
 	if (offset > iter->startbit) {
@@ -524,7 +523,7 @@ int netlbl_secattr_catmap_walk(struct netlbl_lsm_secattr_catmap *catmap,
 }
 
 /**
- * netlbl_secattr_catmap_walk_rng - Find the end of a string of set bits
+ * netlbl_catmap_walkrng - Find the end of a string of set bits
  * @catmap: the category bitmap
  * @offset: the offset to start searching at, in bits
  *
@@ -534,17 +533,16 @@ int netlbl_secattr_catmap_walk(struct netlbl_lsm_secattr_catmap *catmap,
  * the end of the bitmap.
  *
  */
-int netlbl_secattr_catmap_walk_rng(struct netlbl_lsm_secattr_catmap *catmap,
-				   u32 offset)
+int netlbl_catmap_walkrng(struct netlbl_lsm_catmap *catmap, u32 offset)
 {
-	struct netlbl_lsm_secattr_catmap *iter;
-	struct netlbl_lsm_secattr_catmap *prev = NULL;
+	struct netlbl_lsm_catmap *iter;
+	struct netlbl_lsm_catmap *prev = NULL;
 	u32 idx;
 	u32 bit;
 	NETLBL_CATMAP_MAPTYPE bitmask;
 	NETLBL_CATMAP_MAPTYPE bitmap;
 
-	iter = _netlbl_secattr_catmap_getnode(&catmap, offset, _CM_F_WALK, 0);
+	iter = _netlbl_catmap_getnode(&catmap, offset, _CM_F_WALK, 0);
 	if (iter == NULL)
 		return -ENOENT;
 	if (offset > iter->startbit) {
@@ -584,7 +582,7 @@ int netlbl_secattr_catmap_walk_rng(struct netlbl_lsm_secattr_catmap *catmap,
 }
 
 /**
- * netlbl_secattr_catmap_getlong - Export an unsigned long bitmap
+ * netlbl_catmap_getlong - Export an unsigned long bitmap
  * @catmap: pointer to the category bitmap
  * @offset: pointer to the requested offset
  * @bitmap: the exported bitmap
@@ -597,11 +595,11 @@ int netlbl_secattr_catmap_walk_rng(struct netlbl_lsm_secattr_catmap *catmap,
  * Returns zero on sucess, negative values on failure.
  *
  */
-int netlbl_secattr_catmap_getlong(struct netlbl_lsm_secattr_catmap *catmap,
-				  u32 *offset,
-				  unsigned long *bitmap)
+int netlbl_catmap_getlong(struct netlbl_lsm_catmap *catmap,
+			  u32 *offset,
+			  unsigned long *bitmap)
 {
-	struct netlbl_lsm_secattr_catmap *iter;
+	struct netlbl_lsm_catmap *iter;
 	u32 off = *offset;
 	u32 idx;
 
@@ -613,7 +611,7 @@ int netlbl_secattr_catmap_getlong(struct netlbl_lsm_secattr_catmap *catmap,
 		off = catmap->startbit;
 		*offset = off;
 	}
-	iter = _netlbl_secattr_catmap_getnode(&catmap, off, _CM_F_NONE, 0);
+	iter = _netlbl_catmap_getnode(&catmap, off, _CM_F_NONE, 0);
 	if (iter == NULL) {
 		*offset = (u32)-1;
 		return 0;
@@ -632,7 +630,7 @@ int netlbl_secattr_catmap_getlong(struct netlbl_lsm_secattr_catmap *catmap,
 }
 
 /**
- * netlbl_secattr_catmap_setbit - Set a bit in a LSM secattr catmap
+ * netlbl_catmap_setbit - Set a bit in a LSM secattr catmap
  * @catmap: pointer to the category bitmap
  * @bit: the bit to set
  * @flags: memory allocation flags
@@ -642,14 +640,14 @@ int netlbl_secattr_catmap_getlong(struct netlbl_lsm_secattr_catmap *catmap,
  * negative values on failure.
  *
  */
-int netlbl_secattr_catmap_setbit(struct netlbl_lsm_secattr_catmap **catmap,
-				 u32 bit,
-				 gfp_t flags)
+int netlbl_catmap_setbit(struct netlbl_lsm_catmap **catmap,
+			 u32 bit,
+			 gfp_t flags)
 {
-	struct netlbl_lsm_secattr_catmap *iter;
+	struct netlbl_lsm_catmap *iter;
 	u32 idx;
 
-	iter = _netlbl_secattr_catmap_getnode(catmap, bit, _CM_F_ALLOC, flags);
+	iter = _netlbl_catmap_getnode(catmap, bit, _CM_F_ALLOC, flags);
 	if (iter == NULL)
 		return -ENOMEM;
 
@@ -661,7 +659,7 @@ int netlbl_secattr_catmap_setbit(struct netlbl_lsm_secattr_catmap **catmap,
 }
 
 /**
- * netlbl_secattr_catmap_setrng - Set a range of bits in a LSM secattr catmap
+ * netlbl_catmap_setrng - Set a range of bits in a LSM secattr catmap
  * @catmap: pointer to the category bitmap
  * @start: the starting bit
  * @end: the last bit in the string
@@ -672,10 +670,10 @@ int netlbl_secattr_catmap_setbit(struct netlbl_lsm_secattr_catmap **catmap,
  * on success, negative values on failure.
  *
  */
-int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap **catmap,
-				 u32 start,
-				 u32 end,
-				 gfp_t flags)
+int netlbl_catmap_setrng(struct netlbl_lsm_catmap **catmap,
+			 u32 start,
+			 u32 end,
+			 gfp_t flags)
 {
 	int rc = 0;
 	u32 spot = start;
@@ -683,22 +681,20 @@ int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap **catmap,
 	while (rc == 0 && spot <= end) {
 		if (((spot & (BITS_PER_LONG - 1)) != 0) &&
 		    ((end - spot) > BITS_PER_LONG)) {
-			rc = netlbl_secattr_catmap_setlong(catmap,
-							   spot,
-							   (unsigned long)-1,
-							   flags);
+			rc = netlbl_catmap_setlong(catmap,
+						   spot,
+						   (unsigned long)-1,
+						   flags);
 			spot += BITS_PER_LONG;
 		} else
-			rc = netlbl_secattr_catmap_setbit(catmap,
-							  spot++,
-							  flags);
+			rc = netlbl_catmap_setbit(catmap, spot++, flags);
 	}
 
 	return rc;
 }
 
 /**
- * netlbl_secattr_catmap_setlong - Import an unsigned long bitmap
+ * netlbl_catmap_setlong - Import an unsigned long bitmap
  * @catmap: pointer to the category bitmap
  * @offset: offset to the start of the imported bitmap
  * @bitmap: the bitmap to import
@@ -710,20 +706,19 @@ int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap **catmap,
  * on success, negative values on failure.
  *
  */
-int netlbl_secattr_catmap_setlong(struct netlbl_lsm_secattr_catmap **catmap,
-				  u32 offset,
-				  unsigned long bitmap,
-				  gfp_t flags)
+int netlbl_catmap_setlong(struct netlbl_lsm_catmap **catmap,
+			  u32 offset,
+			  unsigned long bitmap,
+			  gfp_t flags)
 {
-	struct netlbl_lsm_secattr_catmap *iter;
+	struct netlbl_lsm_catmap *iter;
 	u32 idx;
 
 	/* only allow aligned offsets */
 	if ((offset & (BITS_PER_LONG - 1)) != 0)
 		return -EINVAL;
 
-	iter = _netlbl_secattr_catmap_getnode(catmap,
-					      offset, _CM_F_ALLOC, flags);
+	iter = _netlbl_catmap_getnode(catmap, offset, _CM_F_ALLOC, flags);
 	if (iter == NULL)
 		return -ENOMEM;
 
diff --git a/security/selinux/ss/ebitmap.c b/security/selinux/ss/ebitmap.c
index 842deca..afe6a26 100644
--- a/security/selinux/ss/ebitmap.c
+++ b/security/selinux/ss/ebitmap.c
@@ -86,7 +86,7 @@ int ebitmap_cpy(struct ebitmap *dst, struct ebitmap *src)
  *
  */
 int ebitmap_netlbl_export(struct ebitmap *ebmap,
-			  struct netlbl_lsm_secattr_catmap **catmap)
+			  struct netlbl_lsm_catmap **catmap)
 {
 	struct ebitmap_node *e_iter = ebmap->node;
 	unsigned long e_map;
@@ -100,7 +100,7 @@ int ebitmap_netlbl_export(struct ebitmap *ebmap,
 	}
 
 	if (*catmap != NULL)
-		netlbl_secattr_catmap_free(*catmap);
+		netlbl_catmap_free(*catmap);
 	*catmap = NULL;
 
 	while (e_iter) {
@@ -108,10 +108,10 @@ int ebitmap_netlbl_export(struct ebitmap *ebmap,
 		for (iter = 0; iter < EBITMAP_UNIT_NUMS; iter++) {
 			e_map = e_iter->maps[iter];
 			if (e_map != 0) {
-				rc = netlbl_secattr_catmap_setlong(catmap,
-								   offset,
-								   e_map,
-								   GFP_ATOMIC);
+				rc = netlbl_catmap_setlong(catmap,
+							   offset,
+							   e_map,
+							   GFP_ATOMIC);
 				if (rc != 0)
 					goto netlbl_export_failure;
 			}
@@ -123,7 +123,7 @@ int ebitmap_netlbl_export(struct ebitmap *ebmap,
 	return 0;
 
 netlbl_export_failure:
-	netlbl_secattr_catmap_free(*catmap);
+	netlbl_catmap_free(*catmap);
 	return -ENOMEM;
 }
 
@@ -138,7 +138,7 @@ netlbl_export_failure:
  *
  */
 int ebitmap_netlbl_import(struct ebitmap *ebmap,
-			  struct netlbl_lsm_secattr_catmap *catmap)
+			  struct netlbl_lsm_catmap *catmap)
 {
 	int rc;
 	struct ebitmap_node *e_iter = NULL;
@@ -147,7 +147,7 @@ int ebitmap_netlbl_import(struct ebitmap *ebmap,
 	unsigned long bitmap;
 
 	for (;;) {
-		rc = netlbl_secattr_catmap_getlong(catmap, &offset, &bitmap);
+		rc = netlbl_catmap_getlong(catmap, &offset, &bitmap);
 		if (rc < 0)
 			goto netlbl_import_failure;
 		if (offset == (u32)-1)
diff --git a/security/selinux/ss/ebitmap.h b/security/selinux/ss/ebitmap.h
index 712c8a7..9637b8c 100644
--- a/security/selinux/ss/ebitmap.h
+++ b/security/selinux/ss/ebitmap.h
@@ -132,17 +132,17 @@ int ebitmap_write(struct ebitmap *e, void *fp);
 
 #ifdef CONFIG_NETLABEL
 int ebitmap_netlbl_export(struct ebitmap *ebmap,
-			  struct netlbl_lsm_secattr_catmap **catmap);
+			  struct netlbl_lsm_catmap **catmap);
 int ebitmap_netlbl_import(struct ebitmap *ebmap,
-			  struct netlbl_lsm_secattr_catmap *catmap);
+			  struct netlbl_lsm_catmap *catmap);
 #else
 static inline int ebitmap_netlbl_export(struct ebitmap *ebmap,
-				struct netlbl_lsm_secattr_catmap **catmap)
+					struct netlbl_lsm_catmap **catmap)
 {
 	return -ENOMEM;
 }
 static inline int ebitmap_netlbl_import(struct ebitmap *ebmap,
-				struct netlbl_lsm_secattr_catmap *catmap)
+					struct netlbl_lsm_catmap *catmap)
 {
 	return -ENOMEM;
 }
diff --git a/security/smack/smack_access.c b/security/smack/smack_access.c
index ea1bc50..732df7b9 100644
--- a/security/smack/smack_access.c
+++ b/security/smack/smack_access.c
@@ -441,10 +441,10 @@ int smk_netlbl_mls(int level, char *catset, struct netlbl_lsm_secattr *sap,
 		for (m = 0x80; m != 0; m >>= 1, cat++) {
 			if ((m & *cp) == 0)
 				continue;
-			rc = netlbl_secattr_catmap_setbit(&sap->attr.mls.cat,
-							  cat, GFP_ATOMIC);
+			rc = netlbl_catmap_setbit(&sap->attr.mls.cat,
+						  cat, GFP_ATOMIC);
 			if (rc < 0) {
-				netlbl_secattr_catmap_free(sap->attr.mls.cat);
+				netlbl_catmap_free(sap->attr.mls.cat);
 				return rc;
 			}
 		}
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 14f52be..c32bba5 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -3091,9 +3091,9 @@ static struct smack_known *smack_from_secattr(struct netlbl_lsm_secattr *sap,
 				break;
 			}
 			for (acat = -1, kcat = -1; acat == kcat; ) {
-				acat = netlbl_secattr_catmap_walk(
-					sap->attr.mls.cat, acat + 1);
-				kcat = netlbl_secattr_catmap_walk(
+				acat = netlbl_catmap_walk(sap->attr.mls.cat,
+							  acat + 1);
+				kcat = netlbl_catmap_walk(
 					skp->smk_netlabel.attr.mls.cat,
 					kcat + 1);
 				if (acat < 0 || kcat < 0)
diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index 3198cfe..893b06b 100644
--- a/security/smack/smackfs.c
+++ b/security/smack/smackfs.c
@@ -777,7 +777,7 @@ static int cipso_seq_show(struct seq_file *s, void *v)
 	struct list_head  *list = v;
 	struct smack_known *skp =
 		 list_entry(list, struct smack_known, list);
-	struct netlbl_lsm_secattr_catmap *cmp = skp->smk_netlabel.attr.mls.cat;
+	struct netlbl_lsm_catmap *cmp = skp->smk_netlabel.attr.mls.cat;
 	char sep = '/';
 	int i;
 
@@ -794,8 +794,8 @@ static int cipso_seq_show(struct seq_file *s, void *v)
 
 	seq_printf(s, "%s %3d", skp->smk_known, skp->smk_netlabel.attr.mls.lvl);
 
-	for (i = netlbl_secattr_catmap_walk(cmp, 0); i >= 0;
-	     i = netlbl_secattr_catmap_walk(cmp, i + 1)) {
+	for (i = netlbl_catmap_walk(cmp, 0); i >= 0;
+	     i = netlbl_catmap_walk(cmp, i + 1)) {
 		seq_printf(s, "%c%d", sep, i);
 		sep = ',';
 	}
@@ -916,7 +916,7 @@ static ssize_t smk_set_cipso(struct file *file, const char __user *buf,
 
 	rc = smk_netlbl_mls(maplevel, mapcatset, &ncats, SMK_CIPSOLEN);
 	if (rc >= 0) {
-		netlbl_secattr_catmap_free(skp->smk_netlabel.attr.mls.cat);
+		netlbl_catmap_free(skp->smk_netlabel.attr.mls.cat);
 		skp->smk_netlabel.attr.mls.cat = ncats.attr.mls.cat;
 		skp->smk_netlabel.attr.mls.lvl = ncats.attr.mls.lvl;
 		rc = count;
@@ -966,14 +966,14 @@ static int cipso2_seq_show(struct seq_file *s, void *v)
 	struct list_head  *list = v;
 	struct smack_known *skp =
 		 list_entry(list, struct smack_known, list);
-	struct netlbl_lsm_secattr_catmap *cmp = skp->smk_netlabel.attr.mls.cat;
+	struct netlbl_lsm_catmap *cmp = skp->smk_netlabel.attr.mls.cat;
 	char sep = '/';
 	int i;
 
 	seq_printf(s, "%s %3d", skp->smk_known, skp->smk_netlabel.attr.mls.lvl);
 
-	for (i = netlbl_secattr_catmap_walk(cmp, 0); i >= 0;
-	     i = netlbl_secattr_catmap_walk(cmp, i + 1)) {
+	for (i = netlbl_catmap_walk(cmp, 0); i >= 0;
+	     i = netlbl_catmap_walk(cmp, i + 1)) {
 		seq_printf(s, "%c%d", sep, i);
 		sep = ',';
 	}

