From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH 1/4] netlabel: fix a problem when setting bits below the
 previously lowest bit
Date: Thu, 31 Jul 2014 17:44:26 -0400
Message-ID: <20140731214426.4991.90097.stgit@localhost>
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

The NetLabel category (catmap) functions have a problem in that they
assume categories will be set in an increasing manner, e.g. the next
category set will always be larger than the last.  Unfortunately, this
is not a valid assumption and could result in problems when attempting
to set categories less than the startbit in the lowest catmap node.
In some cases kernel panics and other nasties can result.

This patch corrects the problem by checking for this and allocating a
new catmap node instance and placing it at the front of the list.

Cc: stable@vger.kernel.org
Reported-by: Christian Evans <frodox@zoho.com>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 include/net/netlabel.h        |    8 ++++----
 net/ipv4/cipso_ipv4.c         |    6 +++---
 net/netlabel/netlabel_kapi.c  |   26 ++++++++++++++++++--------
 security/smack/smack_access.c |    2 +-
 4 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 4fe018c..1c40d65 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -394,10 +394,10 @@ int netlbl_secattr_catmap_walk(struct netlbl_lsm_secattr_catmap *catmap,
 			       u32 offset);
 int netlbl_secattr_catmap_walk_rng(struct netlbl_lsm_secattr_catmap *catmap,
 				   u32 offset);
-int netlbl_secattr_catmap_setbit(struct netlbl_lsm_secattr_catmap *catmap,
+int netlbl_secattr_catmap_setbit(struct netlbl_lsm_secattr_catmap **catmap,
 				 u32 bit,
 				 gfp_t flags);
-int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap *catmap,
+int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap **catmap,
 				 u32 start,
 				 u32 end,
 				 gfp_t flags);
@@ -505,14 +505,14 @@ static inline int netlbl_secattr_catmap_walk_rng(
 	return -ENOENT;
 }
 static inline int netlbl_secattr_catmap_setbit(
-	                              struct netlbl_lsm_secattr_catmap *catmap,
+				      struct netlbl_lsm_secattr_catmap **catmap,
 				      u32 bit,
 				      gfp_t flags)
 {
 	return 0;
 }
 static inline int netlbl_secattr_catmap_setrng(
-	                              struct netlbl_lsm_secattr_catmap *catmap,
+				      struct netlbl_lsm_secattr_catmap **catmap,
 				      u32 start,
 				      u32 end,
 				      gfp_t flags)
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 69e77c8..dd433c9 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -973,7 +973,7 @@ static int cipso_v4_map_cat_rbm_ntoh(const struct cipso_v4_doi *doi_def,
 				return -EPERM;
 			break;
 		}
-		ret_val = netlbl_secattr_catmap_setbit(secattr->attr.mls.cat,
+		ret_val = netlbl_secattr_catmap_setbit(&secattr->attr.mls.cat,
 						       host_spot,
 						       GFP_ATOMIC);
 		if (ret_val != 0)
@@ -1075,7 +1075,7 @@ static int cipso_v4_map_cat_enum_ntoh(const struct cipso_v4_doi *doi_def,
 	u32 iter;
 
 	for (iter = 0; iter < net_cat_len; iter += 2) {
-		ret_val = netlbl_secattr_catmap_setbit(secattr->attr.mls.cat,
+		ret_val = netlbl_secattr_catmap_setbit(&secattr->attr.mls.cat,
 				get_unaligned_be16(&net_cat[iter]),
 				GFP_ATOMIC);
 		if (ret_val != 0)
@@ -1217,7 +1217,7 @@ static int cipso_v4_map_cat_rng_ntoh(const struct cipso_v4_doi *doi_def,
 		else
 			cat_low = 0;
 
-		ret_val = netlbl_secattr_catmap_setrng(secattr->attr.mls.cat,
+		ret_val = netlbl_secattr_catmap_setrng(&secattr->attr.mls.cat,
 						       cat_low,
 						       cat_high,
 						       GFP_ATOMIC);
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 3045a96..84e810b 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -522,7 +522,7 @@ int netlbl_secattr_catmap_walk_rng(struct netlbl_lsm_secattr_catmap *catmap,
 
 /**
  * netlbl_secattr_catmap_setbit - Set a bit in a LSM secattr catmap
- * @catmap: the category bitmap
+ * @catmap: pointer to the category bitmap
  * @bit: the bit to set
  * @flags: memory allocation flags
  *
@@ -531,18 +531,25 @@ int netlbl_secattr_catmap_walk_rng(struct netlbl_lsm_secattr_catmap *catmap,
  * negative values on failure.
  *
  */
-int netlbl_secattr_catmap_setbit(struct netlbl_lsm_secattr_catmap *catmap,
+int netlbl_secattr_catmap_setbit(struct netlbl_lsm_secattr_catmap **catmap,
 				 u32 bit,
 				 gfp_t flags)
 {
-	struct netlbl_lsm_secattr_catmap *iter = catmap;
+	struct netlbl_lsm_secattr_catmap *iter = *catmap;
 	u32 node_bit;
 	u32 node_idx;
 
 	while (iter->next != NULL &&
 	       bit >= (iter->startbit + NETLBL_CATMAP_SIZE))
 		iter = iter->next;
-	if (bit >= (iter->startbit + NETLBL_CATMAP_SIZE)) {
+	if (bit < iter->startbit) {
+		iter = netlbl_secattr_catmap_alloc(flags);
+		if (iter == NULL)
+			return -ENOMEM;
+		iter->next = *catmap;
+		iter->startbit = bit & ~(NETLBL_CATMAP_SIZE - 1);
+		*catmap = iter;
+	} else if (bit >= (iter->startbit + NETLBL_CATMAP_SIZE)) {
 		iter->next = netlbl_secattr_catmap_alloc(flags);
 		if (iter->next == NULL)
 			return -ENOMEM;
@@ -560,7 +567,7 @@ int netlbl_secattr_catmap_setbit(struct netlbl_lsm_secattr_catmap *catmap,
 
 /**
  * netlbl_secattr_catmap_setrng - Set a range of bits in a LSM secattr catmap
- * @catmap: the category bitmap
+ * @catmap: pointer to the category bitmap
  * @start: the starting bit
  * @end: the last bit in the string
  * @flags: memory allocation flags
@@ -570,15 +577,16 @@ int netlbl_secattr_catmap_setbit(struct netlbl_lsm_secattr_catmap *catmap,
  * on success, negative values on failure.
  *
  */
-int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap *catmap,
+int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap **catmap,
 				 u32 start,
 				 u32 end,
 				 gfp_t flags)
 {
 	int ret_val = 0;
-	struct netlbl_lsm_secattr_catmap *iter = catmap;
+	struct netlbl_lsm_secattr_catmap *iter = *catmap;
 	u32 iter_max_spot;
 	u32 spot;
+	u32 orig_spot = iter->startbit;
 
 	/* XXX - This could probably be made a bit faster by combining writes
 	 * to the catmap instead of setting a single bit each time, but for
@@ -596,7 +604,9 @@ int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap *catmap,
 			iter = iter->next;
 			iter_max_spot = iter->startbit + NETLBL_CATMAP_SIZE;
 		}
-		ret_val = netlbl_secattr_catmap_setbit(iter, spot, flags);
+		ret_val = netlbl_secattr_catmap_setbit(&iter, spot, flags);
+		if (iter->startbit < orig_spot)
+			*catmap = iter;
 	}
 
 	return ret_val;
diff --git a/security/smack/smack_access.c b/security/smack/smack_access.c
index 14293cd..9ecf4f4 100644
--- a/security/smack/smack_access.c
+++ b/security/smack/smack_access.c
@@ -444,7 +444,7 @@ int smk_netlbl_mls(int level, char *catset, struct netlbl_lsm_secattr *sap,
 		for (m = 0x80; m != 0; m >>= 1, cat++) {
 			if ((m & *cp) == 0)
 				continue;
-			rc = netlbl_secattr_catmap_setbit(sap->attr.mls.cat,
+			rc = netlbl_secattr_catmap_setbit(&sap->attr.mls.cat,
 							  cat, GFP_ATOMIC);
 			if (rc < 0) {
 				netlbl_secattr_catmap_free(sap->attr.mls.cat);

