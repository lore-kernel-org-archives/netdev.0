From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: [PATCH v4 18/19] calipso: Add a label cache.
Date: Mon, 20 Jun 2016 14:36:58 +0100
Message-ID: <1466429819-12707-19-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

This works in exactly the same way as the CIPSO label cache.
The idea is to allow the lsm to cache the result of a secattr
lookup so that it doesn't need to perform the lookup for
every skbuff.

It introduces two sysctl controls:
 calipso_cache_enable - enables/disables the cache.
 calipso_cache_bucket_size - sets the size of a cache bucket.

Signed-off-by: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
---
 include/net/calipso.h           |   6 +
 include/net/netlabel.h          |   9 +-
 net/ipv6/calipso.c              | 264 +++++++++++++++++++++++++++++++++++++++-
 net/ipv6/sysctl_net_ipv6.c      |  19 +++
 net/netlabel/netlabel_calipso.c |  38 ++++++
 net/netlabel/netlabel_calipso.h |   3 +
 net/netlabel/netlabel_kapi.c    |  24 +++-
 security/selinux/netlabel.c     |   9 +-
 8 files changed, 360 insertions(+), 12 deletions(-)

diff --git a/include/net/calipso.h b/include/net/calipso.h
index 85404e2..b1b30cd 100644
--- a/include/net/calipso.h
+++ b/include/net/calipso.h
@@ -62,6 +62,12 @@ struct calipso_doi {
 	struct rcu_head rcu;
 };
 
+/*
+ * Sysctl Variables
+ */
+extern int calipso_cache_enabled;
+extern int calipso_cache_bucketsize;
+
 #ifdef CONFIG_NETLABEL
 int __init calipso_init(void);
 void calipso_exit(void);
diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index d8a46a8..a306bc7 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -235,6 +235,8 @@ struct netlbl_lsm_secattr {
  * @skbuff_optptr: find option in packet
  * @skbuff_setattr: set the skbuff's attr
  * @skbuff_delattr: remove the skbuff's attr
+ * @cache_invalidate: invalidate cache
+ * @cache_add: add cache entry
  *
  * Description:
  * This structure is filled out by the CALIPSO engine and passed
@@ -269,6 +271,9 @@ struct netlbl_calipso_ops {
 			      const struct calipso_doi *doi_def,
 			      const struct netlbl_lsm_secattr *secattr);
 	int (*skbuff_delattr)(struct sk_buff *skb);
+	void (*cache_invalidate)(void);
+	int (*cache_add)(const unsigned char *calipso_ptr,
+			 const struct netlbl_lsm_secattr *secattr);
 };
 
 /*
@@ -494,7 +499,7 @@ void netlbl_skbuff_err(struct sk_buff *skb, u16 family, int error, int gateway);
  * LSM label mapping cache operations
  */
 void netlbl_cache_invalidate(void);
-int netlbl_cache_add(const struct sk_buff *skb,
+int netlbl_cache_add(const struct sk_buff *skb, u16 family,
 		     const struct netlbl_lsm_secattr *secattr);
 
 /*
@@ -647,7 +652,7 @@ static inline void netlbl_cache_invalidate(void)
 {
 	return;
 }
-static inline int netlbl_cache_add(const struct sk_buff *skb,
+static inline int netlbl_cache_add(const struct sk_buff *skb, u16 family,
 				   const struct netlbl_lsm_secattr *secattr)
 {
 	return 0;
diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index ea80450..c53b92c 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -72,6 +72,255 @@
 static DEFINE_SPINLOCK(calipso_doi_list_lock);
 static LIST_HEAD(calipso_doi_list);
 
+/* Label mapping cache */
+int calipso_cache_enabled = 1;
+int calipso_cache_bucketsize = 10;
+#define CALIPSO_CACHE_BUCKETBITS     7
+#define CALIPSO_CACHE_BUCKETS        BIT(CALIPSO_CACHE_BUCKETBITS)
+#define CALIPSO_CACHE_REORDERLIMIT   10
+struct calipso_map_cache_bkt {
+	spinlock_t lock;
+	u32 size;
+	struct list_head list;
+};
+
+struct calipso_map_cache_entry {
+	u32 hash;
+	unsigned char *key;
+	size_t key_len;
+
+	struct netlbl_lsm_cache *lsm_data;
+
+	u32 activity;
+	struct list_head list;
+};
+
+static struct calipso_map_cache_bkt *calipso_cache;
+
+/* Label Mapping Cache Functions
+ */
+
+/**
+ * calipso_cache_entry_free - Frees a cache entry
+ * @entry: the entry to free
+ *
+ * Description:
+ * This function frees the memory associated with a cache entry including the
+ * LSM cache data if there are no longer any users, i.e. reference count == 0.
+ *
+ */
+static void calipso_cache_entry_free(struct calipso_map_cache_entry *entry)
+{
+	if (entry->lsm_data)
+		netlbl_secattr_cache_free(entry->lsm_data);
+	kfree(entry->key);
+	kfree(entry);
+}
+
+/**
+ * calipso_map_cache_hash - Hashing function for the CALIPSO cache
+ * @key: the hash key
+ * @key_len: the length of the key in bytes
+ *
+ * Description:
+ * The CALIPSO tag hashing function.  Returns a 32-bit hash value.
+ *
+ */
+static u32 calipso_map_cache_hash(const unsigned char *key, u32 key_len)
+{
+	return jhash(key, key_len, 0);
+}
+
+/**
+ * calipso_cache_init - Initialize the CALIPSO cache
+ *
+ * Description:
+ * Initializes the CALIPSO label mapping cache, this function should be called
+ * before any of the other functions defined in this file.  Returns zero on
+ * success, negative values on error.
+ *
+ */
+static int __init calipso_cache_init(void)
+{
+	u32 iter;
+
+	calipso_cache = kcalloc(CALIPSO_CACHE_BUCKETS,
+				sizeof(struct calipso_map_cache_bkt),
+				GFP_KERNEL);
+	if (!calipso_cache)
+		return -ENOMEM;
+
+	for (iter = 0; iter < CALIPSO_CACHE_BUCKETS; iter++) {
+		spin_lock_init(&calipso_cache[iter].lock);
+		calipso_cache[iter].size = 0;
+		INIT_LIST_HEAD(&calipso_cache[iter].list);
+	}
+
+	return 0;
+}
+
+/**
+ * calipso_cache_invalidate - Invalidates the current CALIPSO cache
+ *
+ * Description:
+ * Invalidates and frees any entries in the CALIPSO cache.  Returns zero on
+ * success and negative values on failure.
+ *
+ */
+static void calipso_cache_invalidate(void)
+{
+	struct calipso_map_cache_entry *entry, *tmp_entry;
+	u32 iter;
+
+	for (iter = 0; iter < CALIPSO_CACHE_BUCKETS; iter++) {
+		spin_lock_bh(&calipso_cache[iter].lock);
+		list_for_each_entry_safe(entry,
+					 tmp_entry,
+					 &calipso_cache[iter].list, list) {
+			list_del(&entry->list);
+			calipso_cache_entry_free(entry);
+		}
+		calipso_cache[iter].size = 0;
+		spin_unlock_bh(&calipso_cache[iter].lock);
+	}
+}
+
+/**
+ * calipso_cache_check - Check the CALIPSO cache for a label mapping
+ * @key: the buffer to check
+ * @key_len: buffer length in bytes
+ * @secattr: the security attribute struct to use
+ *
+ * Description:
+ * This function checks the cache to see if a label mapping already exists for
+ * the given key.  If there is a match then the cache is adjusted and the
+ * @secattr struct is populated with the correct LSM security attributes.  The
+ * cache is adjusted in the following manner if the entry is not already the
+ * first in the cache bucket:
+ *
+ *  1. The cache entry's activity counter is incremented
+ *  2. The previous (higher ranking) entry's activity counter is decremented
+ *  3. If the difference between the two activity counters is geater than
+ *     CALIPSO_CACHE_REORDERLIMIT the two entries are swapped
+ *
+ * Returns zero on success, -ENOENT for a cache miss, and other negative values
+ * on error.
+ *
+ */
+static int calipso_cache_check(const unsigned char *key,
+			       u32 key_len,
+			       struct netlbl_lsm_secattr *secattr)
+{
+	u32 bkt;
+	struct calipso_map_cache_entry *entry;
+	struct calipso_map_cache_entry *prev_entry = NULL;
+	u32 hash;
+
+	if (!calipso_cache_enabled)
+		return -ENOENT;
+
+	hash = calipso_map_cache_hash(key, key_len);
+	bkt = hash & (CALIPSO_CACHE_BUCKETS - 1);
+	spin_lock_bh(&calipso_cache[bkt].lock);
+	list_for_each_entry(entry, &calipso_cache[bkt].list, list) {
+		if (entry->hash == hash &&
+		    entry->key_len == key_len &&
+		    memcmp(entry->key, key, key_len) == 0) {
+			entry->activity += 1;
+			atomic_inc(&entry->lsm_data->refcount);
+			secattr->cache = entry->lsm_data;
+			secattr->flags |= NETLBL_SECATTR_CACHE;
+			secattr->type = NETLBL_NLTYPE_CALIPSO;
+			if (!prev_entry) {
+				spin_unlock_bh(&calipso_cache[bkt].lock);
+				return 0;
+			}
+
+			if (prev_entry->activity > 0)
+				prev_entry->activity -= 1;
+			if (entry->activity > prev_entry->activity &&
+			    entry->activity - prev_entry->activity >
+			    CALIPSO_CACHE_REORDERLIMIT) {
+				__list_del(entry->list.prev, entry->list.next);
+				__list_add(&entry->list,
+					   prev_entry->list.prev,
+					   &prev_entry->list);
+			}
+
+			spin_unlock_bh(&calipso_cache[bkt].lock);
+			return 0;
+		}
+		prev_entry = entry;
+	}
+	spin_unlock_bh(&calipso_cache[bkt].lock);
+
+	return -ENOENT;
+}
+
+/**
+ * calipso_cache_add - Add an entry to the CALIPSO cache
+ * @calipso_ptr: the CALIPSO option
+ * @secattr: the packet's security attributes
+ *
+ * Description:
+ * Add a new entry into the CALIPSO label mapping cache.  Add the new entry to
+ * head of the cache bucket's list, if the cache bucket is out of room remove
+ * the last entry in the list first.  It is important to note that there is
+ * currently no checking for duplicate keys.  Returns zero on success,
+ * negative values on failure.  The key stored starts at calipso_ptr + 2,
+ * i.e. the type and length bytes are not stored, this corresponds to
+ * calipso_ptr[1] bytes of data.
+ *
+ */
+static int calipso_cache_add(const unsigned char *calipso_ptr,
+			     const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -EPERM;
+	u32 bkt;
+	struct calipso_map_cache_entry *entry = NULL;
+	struct calipso_map_cache_entry *old_entry = NULL;
+	u32 calipso_ptr_len;
+
+	if (!calipso_cache_enabled || calipso_cache_bucketsize <= 0)
+		return 0;
+
+	calipso_ptr_len = calipso_ptr[1];
+
+	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
+	if (!entry)
+		return -ENOMEM;
+	entry->key = kmemdup(calipso_ptr + 2, calipso_ptr_len, GFP_ATOMIC);
+	if (!entry->key) {
+		ret_val = -ENOMEM;
+		goto cache_add_failure;
+	}
+	entry->key_len = calipso_ptr_len;
+	entry->hash = calipso_map_cache_hash(calipso_ptr, calipso_ptr_len);
+	atomic_inc(&secattr->cache->refcount);
+	entry->lsm_data = secattr->cache;
+
+	bkt = entry->hash & (CALIPSO_CACHE_BUCKETS - 1);
+	spin_lock_bh(&calipso_cache[bkt].lock);
+	if (calipso_cache[bkt].size < calipso_cache_bucketsize) {
+		list_add(&entry->list, &calipso_cache[bkt].list);
+		calipso_cache[bkt].size += 1;
+	} else {
+		old_entry = list_entry(calipso_cache[bkt].list.prev,
+				       struct calipso_map_cache_entry, list);
+		list_del(&old_entry->list);
+		list_add(&entry->list, &calipso_cache[bkt].list);
+		calipso_cache_entry_free(old_entry);
+	}
+	spin_unlock_bh(&calipso_cache[bkt].lock);
+
+	return 0;
+
+cache_add_failure:
+	if (entry)
+		calipso_cache_entry_free(entry);
+	return ret_val;
+}
+
 /* DOI List Functions
  */
 
@@ -789,6 +1038,9 @@ static int calipso_opt_getattr(const unsigned char *calipso,
 	if (cat_len + 8 > len)
 		return -EINVAL;
 
+	if (calipso_cache_check(calipso + 2, calipso[1], secattr) == 0)
+		return 0;
+
 	doi = get_unaligned_be32(calipso + 2);
 	rcu_read_lock();
 	doi_def = calipso_doi_search(doi);
@@ -1191,6 +1443,8 @@ static const struct netlbl_calipso_ops ops = {
 	.skbuff_optptr    = calipso_skbuff_optptr,
 	.skbuff_setattr   = calipso_skbuff_setattr,
 	.skbuff_delattr   = calipso_skbuff_delattr,
+	.cache_invalidate = calipso_cache_invalidate,
+	.cache_add        = calipso_cache_add
 };
 
 /**
@@ -1203,11 +1457,17 @@ static const struct netlbl_calipso_ops ops = {
  */
 int __init calipso_init(void)
 {
-	netlbl_calipso_ops_register(&ops);
-	return 0;
+	int ret_val;
+
+	ret_val = calipso_cache_init();
+	if (!ret_val)
+		netlbl_calipso_ops_register(&ops);
+	return ret_val;
 }
 
 void calipso_exit(void)
 {
 	netlbl_calipso_ops_register(NULL);
+	calipso_cache_invalidate();
+	kfree(calipso_cache);
 }
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 45243bb..69c50e7 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -15,6 +15,9 @@
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
+#ifdef CONFIG_NETLABEL
+#include <net/calipso.h>
+#endif
 
 static int one = 1;
 static int auto_flowlabels_min;
@@ -106,6 +109,22 @@ static struct ctl_table ipv6_rotable[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &one
 	},
+#ifdef CONFIG_NETLABEL
+	{
+		.procname	= "calipso_cache_enable",
+		.data		= &calipso_cache_enabled,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "calipso_cache_bucket_size",
+		.data		= &calipso_cache_bucketsize,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif /* CONFIG_NETLABEL */
 	{ }
 };
 
diff --git a/net/netlabel/netlabel_calipso.c b/net/netlabel/netlabel_calipso.c
index 0d02c26..2ec93c5 100644
--- a/net/netlabel/netlabel_calipso.c
+++ b/net/netlabel/netlabel_calipso.c
@@ -700,3 +700,41 @@ int calipso_skbuff_delattr(struct sk_buff *skb)
 		ret_val = ops->skbuff_delattr(skb);
 	return ret_val;
 }
+
+/**
+ * calipso_cache_invalidate - Invalidates the current CALIPSO cache
+ *
+ * Description:
+ * Invalidates and frees any entries in the CALIPSO cache.  Returns zero on
+ * success and negative values on failure.
+ *
+ */
+void calipso_cache_invalidate(void)
+{
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ops->cache_invalidate();
+}
+
+/**
+ * calipso_cache_add - Add an entry to the CALIPSO cache
+ * @calipso_ptr: the CALIPSO option
+ * @secattr: the packet's security attributes
+ *
+ * Description:
+ * Add a new entry into the CALIPSO label mapping cache.
+ * Returns zero on success, negative values on failure.
+ *
+ */
+int calipso_cache_add(const unsigned char *calipso_ptr,
+		      const struct netlbl_lsm_secattr *secattr)
+
+{
+	int ret_val = -ENOMSG;
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ret_val = ops->cache_add(calipso_ptr, secattr);
+	return ret_val;
+}
diff --git a/net/netlabel/netlabel_calipso.h b/net/netlabel/netlabel_calipso.h
index 66ba92e..9fd291c 100644
--- a/net/netlabel/netlabel_calipso.h
+++ b/net/netlabel/netlabel_calipso.h
@@ -144,5 +144,8 @@ int calipso_skbuff_setattr(struct sk_buff *skb,
 			   const struct calipso_doi *doi_def,
 			   const struct netlbl_lsm_secattr *secattr);
 int calipso_skbuff_delattr(struct sk_buff *skb);
+void calipso_cache_invalidate(void);
+int calipso_cache_add(const unsigned char *calipso_ptr,
+		      const struct netlbl_lsm_secattr *secattr);
 
 #endif
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 35df8f5..d534731 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -1282,11 +1282,15 @@ void netlbl_skbuff_err(struct sk_buff *skb, u16 family, int error, int gateway)
 void netlbl_cache_invalidate(void)
 {
 	cipso_v4_cache_invalidate();
+#if IS_ENABLED(CONFIG_IPV6)
+	calipso_cache_invalidate();
+#endif /* IPv6 */
 }
 
 /**
  * netlbl_cache_add - Add an entry to a NetLabel protocol cache
  * @skb: the packet
+ * @family: the family
  * @secattr: the packet's security attributes
  *
  * Description:
@@ -1295,7 +1299,7 @@ void netlbl_cache_invalidate(void)
  * values on error.
  *
  */
-int netlbl_cache_add(const struct sk_buff *skb,
+int netlbl_cache_add(const struct sk_buff *skb, u16 family,
 		     const struct netlbl_lsm_secattr *secattr)
 {
 	unsigned char *ptr;
@@ -1303,10 +1307,20 @@ int netlbl_cache_add(const struct sk_buff *skb,
 	if ((secattr->flags & NETLBL_SECATTR_CACHE) == 0)
 		return -ENOMSG;
 
-	ptr = cipso_v4_optptr(skb);
-	if (ptr)
-		return cipso_v4_cache_add(ptr, secattr);
-
+	switch (family) {
+	case AF_INET:
+		ptr = cipso_v4_optptr(skb);
+		if (ptr)
+			return cipso_v4_cache_add(ptr, secattr);
+		break;
+#if IS_ENABLED(CONFIG_IPV6)
+	case AF_INET6:
+		ptr = calipso_optptr(skb);
+		if (ptr)
+			return calipso_cache_add(ptr, secattr);
+		break;
+#endif /* IPv6 */
+	}
 	return -ENOMSG;
 }
 
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index dfca50d..aaba667 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -54,6 +54,7 @@
  *
  */
 static int selinux_netlbl_sidlookup_cached(struct sk_buff *skb,
+					   u16 family,
 					   struct netlbl_lsm_secattr *secattr,
 					   u32 *sid)
 {
@@ -63,7 +64,7 @@ static int selinux_netlbl_sidlookup_cached(struct sk_buff *skb,
 	if (rc == 0 &&
 	    (secattr->flags & NETLBL_SECATTR_CACHEABLE) &&
 	    (secattr->flags & NETLBL_SECATTR_CACHE))
-		netlbl_cache_add(skb, secattr);
+		netlbl_cache_add(skb, family, secattr);
 
 	return rc;
 }
@@ -214,7 +215,8 @@ int selinux_netlbl_skbuff_getsid(struct sk_buff *skb,
 	netlbl_secattr_init(&secattr);
 	rc = netlbl_skbuff_getattr(skb, family, &secattr);
 	if (rc == 0 && secattr.flags != NETLBL_SECATTR_NONE)
-		rc = selinux_netlbl_sidlookup_cached(skb, &secattr, sid);
+		rc = selinux_netlbl_sidlookup_cached(skb, family,
+						     &secattr, sid);
 	else
 		*sid = SECSID_NULL;
 	*type = secattr.type;
@@ -382,7 +384,8 @@ int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
 	netlbl_secattr_init(&secattr);
 	rc = netlbl_skbuff_getattr(skb, family, &secattr);
 	if (rc == 0 && secattr.flags != NETLBL_SECATTR_NONE)
-		rc = selinux_netlbl_sidlookup_cached(skb, &secattr, &nlbl_sid);
+		rc = selinux_netlbl_sidlookup_cached(skb, family,
+						     &secattr, &nlbl_sid);
 	else
 		nlbl_sid = SECINITSID_UNLABELED;
 	netlbl_secattr_destroy(&secattr);
-- 
2.7.4

_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
