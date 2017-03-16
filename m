From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 16/17] net: convert netlbl_lsm_cache.refcount from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:29:06 +0200
Message-ID: <1489678147-21404-17-git-send-email-elena.reshetova@intel.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/netlabel.h | 8 ++++----
 net/ipv4/cipso_ipv4.c  | 4 ++--
 net/ipv6/calipso.c     | 4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index efe9806..72d6435 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -37,7 +37,7 @@
 #include <linux/in6.h>
 #include <net/netlink.h>
 #include <net/request_sock.h>
-#include <linux/atomic.h>
+#include <linux/refcount.h>
 
 struct cipso_v4_doi;
 struct calipso_doi;
@@ -136,7 +136,7 @@ struct netlbl_audit {
  *
  */
 struct netlbl_lsm_cache {
-	atomic_t refcount;
+	refcount_t refcount;
 	void (*free) (const void *data);
 	void *data;
 };
@@ -295,7 +295,7 @@ static inline struct netlbl_lsm_cache *netlbl_secattr_cache_alloc(gfp_t flags)
 
 	cache = kzalloc(sizeof(*cache), flags);
 	if (cache)
-		atomic_set(&cache->refcount, 1);
+		refcount_set(&cache->refcount, 1);
 	return cache;
 }
 
@@ -309,7 +309,7 @@ static inline struct netlbl_lsm_cache *netlbl_secattr_cache_alloc(gfp_t flags)
  */
 static inline void netlbl_secattr_cache_free(struct netlbl_lsm_cache *cache)
 {
-	if (!atomic_dec_and_test(&cache->refcount))
+	if (!refcount_dec_and_test(&cache->refcount))
 		return;
 
 	if (cache->free)
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index ae20616..c204477 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -265,7 +265,7 @@ static int cipso_v4_cache_check(const unsigned char *key,
 		    entry->key_len == key_len &&
 		    memcmp(entry->key, key, key_len) == 0) {
 			entry->activity += 1;
-			atomic_inc(&entry->lsm_data->refcount);
+			refcount_inc(&entry->lsm_data->refcount);
 			secattr->cache = entry->lsm_data;
 			secattr->flags |= NETLBL_SECATTR_CACHE;
 			secattr->type = NETLBL_NLTYPE_CIPSOV4;
@@ -332,7 +332,7 @@ int cipso_v4_cache_add(const unsigned char *cipso_ptr,
 	}
 	entry->key_len = cipso_ptr_len;
 	entry->hash = cipso_v4_map_cache_hash(cipso_ptr, cipso_ptr_len);
-	atomic_inc(&secattr->cache->refcount);
+	refcount_inc(&secattr->cache->refcount);
 	entry->lsm_data = secattr->cache;
 
 	bkt = entry->hash & (CIPSO_V4_CACHE_BUCKETS - 1);
diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index 37ac9de..6c6ecf1 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -227,7 +227,7 @@ static int calipso_cache_check(const unsigned char *key,
 		    entry->key_len == key_len &&
 		    memcmp(entry->key, key, key_len) == 0) {
 			entry->activity += 1;
-			atomic_inc(&entry->lsm_data->refcount);
+			refcount_inc(&entry->lsm_data->refcount);
 			secattr->cache = entry->lsm_data;
 			secattr->flags |= NETLBL_SECATTR_CACHE;
 			secattr->type = NETLBL_NLTYPE_CALIPSO;
@@ -296,7 +296,7 @@ static int calipso_cache_add(const unsigned char *calipso_ptr,
 	}
 	entry->key_len = calipso_ptr_len;
 	entry->hash = calipso_map_cache_hash(calipso_ptr, calipso_ptr_len);
-	atomic_inc(&secattr->cache->refcount);
+	refcount_inc(&secattr->cache->refcount);
 	entry->lsm_data = secattr->cache;
 
 	bkt = entry->hash & (CALIPSO_CACHE_BUCKETS - 1);
-- 
2.7.4
