From: Paul Moore <paul.moore@hp.com>
Subject: [RFC 3/4] NetLabel
Date: Thu, 25 May 2006 16:06:40 -0400
Message-ID: <44760E50.7050604@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:53953 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1030388AbWEYUGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 16:06:43 -0400
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds IPv4 CIPSO support to NetLabel subsystem.  It includes hooks
into the core network stack as well as the required NetLabel components.

 include/linux/ip.h               |    1
 include/net/cipso_ipv4.h         |  179 +++
 include/net/inet_sock.h          |    2
 net/ipv4/cipso_ipv4.c            | 1568 +++++++++++++++++++++++++++++++
 net/ipv4/ip_fragment.c           |   38
 net/ipv4/ip_options.c            |   19
 net/netlabel/netlabel_cipso_v4.c |  519 ++++++++++
 net/netlabel/netlabel_cipso_v4.h |  185 +++
 8 files changed, 2510 insertions(+), 1 deletion(-)

--- linux-2.6.16.i686/include/linux/ip.h	2006-03-20 00:53:29.000000000 -0500
+++ linux-2.6.16.i686-cipso/include/linux/ip.h	2006-05-23 15:48:59.000000000 -0400
@@ -57,6 +57,7 @@
 #define IPOPT_SEC	(2 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_LSRR	(3 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_TIMESTAMP	(4 |IPOPT_MEASUREMENT)
+#define IPOPT_CIPSO	(6 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_RR	(7 |IPOPT_CONTROL)
 #define IPOPT_SID	(8 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_SSRR	(9 |IPOPT_CONTROL|IPOPT_COPY)
--- linux-2.6.16.i686/include/net/cipso_ipv4.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/include/net/cipso_ipv4.h	2006-05-17 13:40:39.000000000 -0400
@@ -0,0 +1,179 @@
+/*
+ * CIPSO - Commercial IP Security Option
+ *
+ * This is an implementation of the CIPSO 2.2 protocol as specified in
+ * draft-ietf-cipso-ipsecurity-01.txt with additional tag types as found in
+ * FIPS-188, copies of both documents can be found in the Documentation
+ * directory.  While CIPSO never became a full IETF RFC standard many vendors
+ * have chosen to adopt the protocol and over the years it has become a
+ * de-facto standard for labeled networking.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#ifndef _CIPSO_IPV4_H
+#define _CIPSO_IPV4_H
+
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/list.h>
+#include <net/netlabel.h>
+
+/* mapping cache */
+#define CIPSO_V4_CACHE_BUCKETBITS     7
+#define CIPSO_V4_CACHE_BUCKETS        (1 << CIPSO_V4_CACHE_BUCKETBITS)
+
+/* known doi values */
+#define CIPSO_V4_DOI_UNKNOWN          0x00000000
+
+/* tag types */
+#define CIPSO_V4_TAG_INVALID          0
+#define CIPSO_V4_TAG_RBITMAP          1
+#define CIPSO_V4_TAG_ENUM             2
+#define CIPSO_V4_TAG_RANGE            5
+#define CIPSO_V4_TAG_PBITMAP          6
+#define CIPSO_V4_TAG_FREEFORM         7
+
+/* doi mapping types */
+#define CIPSO_V4_MAP_UNKNOWN          0
+#define CIPSO_V4_MAP_STD              1
+#define CIPSO_V4_MAP_SELOPT           2
+
+/* limits */
+#define CIPSO_V4_MAX_REM_LVLS         256
+#define CIPSO_V4_INV_LVL              0x80000000
+#define CIPSO_V4_MAX_LOC_LVLS         (CIPSO_V4_INV_LVL - 1)
+#define CIPSO_V4_MAX_REM_CATS         65535
+#define CIPSO_V4_INV_CAT              0x80000000
+#define CIPSO_V4_MAX_LOC_CATS         (CIPSO_V4_INV_CAT - 1)
+
+/* 
+ * CIPSO DOI definitions
+ */
+
+/* DOI definition struct */
+#define CIPSO_V4_TAG_MAXCNT           5
+struct cipso_v4_doi {
+	u32 doi;
+	u32 type;
+	union {
+		struct cipso_v4_std_map_tbl *std;
+	} map;
+	u8 tags[CIPSO_V4_TAG_MAXCNT];
+
+	u32 valid;
+	struct list_head list;
+	struct rcu_head rcu;
+	struct list_head dom_list;
+};
+
+/* Standard CIPSO mapping table */
+/* NOTE: the highest order bit (i.e. 0x80000000) is an 'invalid' flag, if the
+ *       bit is set then consider that value as unspecified, meaning the
+ *       mapping for that particular level/category is invalid */
+struct cipso_v4_std_map_tbl {
+	struct {
+		u32 *cipso;
+		u32 *local;
+		u32 cipso_size;
+		u32 local_size;
+	} lvl;
+	struct {
+		u32 *cipso;
+		u32 *local;
+		u32 cipso_size;
+		u32 local_size;
+	} cat;
+};
+
+/*
+ * Helper Functions
+ */
+
+#define CIPSO_V4_OPTEXIST(x) (IPCB(x)->opt.cipso != 0)
+#define CIPSO_V4_OPTPTR(x) ((x)->nh.raw + IPCB(x)->opt.cipso)
+
+/*
+ * DOI List Functions
+ */
+
+int cipso_v4_doi_add(struct cipso_v4_doi *doi_def);
+int cipso_v4_doi_remove(const u32 doi,
+			void (*callback) (struct rcu_head * head));
+struct cipso_v4_doi *cipso_v4_doi_getdef(const u32 doi);
+
+struct sk_buff *cipso_v4_doi_dump(const u32 doi, const u32 headroom);
+
+int cipso_v4_doi_domhsh_add(struct cipso_v4_doi *doi_def, const char *domain);
+int cipso_v4_doi_domhsh_remove(struct cipso_v4_doi *doi_def,
+			       const char *domain);
+
+/*
+ * DOI Mapping Functions
+ */
+
+int cipso_v4_map_lvl_valid(const struct cipso_v4_doi *doi_def, const u8 level);
+int cipso_v4_map_lvl_hton(const struct cipso_v4_doi *doi_def,
+			  const u32 host_lvl, 
+			  u32 *net_lvl);
+int cipso_v4_map_lvl_ntoh(const struct cipso_v4_doi *doi_def,
+			  const u32 net_lvl, 
+			  u32 *host_lvl);
+
+int cipso_v4_map_cat_rbm_valid(const struct cipso_v4_doi *doi_def,
+			       const unsigned char *bitmap, 
+			       const u32 bitmap_len);
+int cipso_v4_map_cat_rbm_hton(const struct cipso_v4_doi *doi_def,
+			      const unsigned char *host_cat,
+			      const u32 host_cat_len,
+			      unsigned char *net_cat, 
+			      const u32 net_cat_len);
+int cipso_v4_map_cat_rbm_ntoh(const struct cipso_v4_doi *doi_def,
+			      const unsigned char *net_cat,
+			      const u32 net_cat_len,
+			      unsigned char *host_cat, 
+			      const u32 host_cat_len);
+
+/*
+ * Label Mapping Cache Functions
+ */
+
+int cipso_v4_cache_invalidate(void);
+int cipso_v4_cache_add(const struct sk_buff *skb, 
+		       const struct netlbl_lsm_secattr *secattr);
+
+/*
+ * Protocol Handling Functions
+ */
+
+int cipso_v4_validate(unsigned char **option);
+int cipso_v4_error(struct sk_buff *skb,
+		   const int error,
+		   const u32 gateway);
+int cipso_v4_setopt(const struct socket *sock,
+		    const struct cipso_v4_doi *doi_def,
+		    const struct netlbl_lsm_secattr *secattr);
+int cipso_v4_getopt(const struct sk_buff *skb,
+		    struct netlbl_lsm_secattr *secattr);
+
+#endif /* _CIPSO_IPV4_H */
--- linux-2.6.16.i686/include/net/inet_sock.h	2006-03-20 00:53:29.000000000 -0500
+++ linux-2.6.16.i686-cipso/include/net/inet_sock.h	2006-05-23 15:50:18.000000000 -0400
@@ -52,7 +52,7 @@ struct ip_options {
 			ts_needtime:1,
 			ts_needaddr:1;
 	unsigned char	router_alert;
-	unsigned char	__pad1;
+	unsigned char	cipso;
 	unsigned char	__pad2;
 	unsigned char	__data[0];
 };
--- linux-2.6.16.i686/net/ipv4/cipso_ipv4.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/ipv4/cipso_ipv4.c	2006-05-17 18:21:13.000000000 -0400
@@ -0,0 +1,1568 @@
+/*
+ * CIPSO - Commercial IP Security Option
+ *
+ * This is an implementation of the CIPSO 2.2 protocol as specified in
+ * draft-ietf-cipso-ipsecurity-01.txt with additional tag types as found in
+ * FIPS-188, copies of both documents can be found in the Documentation
+ * directory.  While CIPSO never became a full IETF RFC standard many vendors
+ * have chosen to adopt the protocol and over the years it has become a
+ * de-facto standard for labeled networking.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include <linux/module.h>
+#include <net/ip.h>
+#include <net/icmp.h>
+#include <net/tcp.h>
+#include <net/netlabel.h>
+#include <net/cipso_ipv4.h>
+#include <asm/bug.h>
+
+struct cipso_v4_domhsh_entry {
+	char *domain;
+	u32 valid;
+	struct list_head list;
+	struct rcu_head rcu;
+};
+
+/* List of available DOI definitions */
+/* XXX - Updates should be minimal so having a single lock for the
+   cipso_v4_doi_list and the cipso_v4_doi_list->dom_list should be
+   okay. */
+/* XXX - This currently assumes a minimal number of different DOIs in use,
+   if in practice there are a lot of different DOIs this list should
+   probably be turned into a hash table or something similar so we
+   can do quick lookups. */
+DEFINE_SPINLOCK(cipso_v4_doi_list_lock);
+static struct list_head cipso_v4_doi_list = LIST_HEAD_INIT(cipso_v4_doi_list);
+
+/* Label mapping cache */
+#define CIPSO_V4_CACHE_BUCKETSIZE     10
+#define CIPSO_V4_CACHE_REORDERLIMIT   10
+/* PM - the number of cache buckets should probably be a compile time option */
+struct cipso_v4_map_cache_bkt {
+	spinlock_t lock;
+	u32 size;
+	struct list_head list;
+};
+struct cipso_v4_map_cache_entry {
+	u32 hash;
+	unsigned char *key;
+	u32 key_len;
+
+	struct netlbl_lsm_cache lsm_data;
+
+	u32 activity;
+	struct list_head list;
+};
+static u32 cipso_v4_cache_size = 0;
+static struct cipso_v4_map_cache_bkt *cipso_v4_cache = NULL;
+#define CIPSO_V4_CACHE_ENABLED (cipso_v4_cache_size > 0)
+
+/*
+ * Helper Functions
+ */
+
+/**
+ * cipso_v4_bitmap_walk - Walk a bitmap looking for a bit
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
+static inline int cipso_v4_bitmap_walk(const unsigned char *bitmap,
+				       const u32 bitmap_len,
+				       const u32 offset,
+				       const u8 state)
+{
+	u32 byte_spot;
+	u32 byte_spot_rem;
+	unsigned char bitmask;
+
+	/* gcc always rounds to zero when doing integer division */
+	byte_spot = offset / 8;
+	byte_spot_rem = offset % 8;
+	bitmask = 0x80 >> byte_spot_rem;
+
+	/* XXX - probably should use include/asm/bitops.h if we can */
+	do {
+		if ((state && (bitmap[byte_spot] & bitmask) == bitmask) ||
+		    (state == 0 && (bitmap[byte_spot] & bitmask) == 0))
+			return byte_spot * 8 + byte_spot_rem;
+
+		if (++byte_spot_rem == 8) {
+			byte_spot++;
+			byte_spot_rem = 0;
+			bitmask = 0x80;
+		} else
+			bitmask = bitmask >> 1;
+	} while ((byte_spot * 8 + byte_spot_rem) < bitmap_len);
+
+	return -1;
+}
+
+/**
+ * cipso_v4_bitmap_setbit - Sets a single bit in a bitmap
+ * @bitmap: the bitmap
+ * @bit: the bit
+ * @state: if non-zero, set the bit (1) else clear the bit (0)
+ *
+ * Description:
+ * Set a single bit in the bitmask.  Returns zero on success, negative values
+ * on error.
+ */
+static inline int cipso_v4_bitmap_setbit(unsigned char *bitmap,
+					 const u32 bit,
+					 const u8 state)
+{
+	u32 byte_spot;
+	u8 bitmask;
+
+	/* gcc always rounds to zero when doing integer division */
+	byte_spot = bit / 8;
+	bitmask = 0x80 >> bit % 8;
+	if (state)
+		bitmap[byte_spot] |= bitmask;
+	else
+		bitmap[byte_spot] &= ~bitmask;
+
+	return 0;
+}
+
+/**
+ * cipso_v4_doi_domhsh_free - Frees a domain list entry
+ * @entry: the entry's RCU field
+ *
+ * Description:
+ * This function is designed to be used as a callback to the call_rcu()
+ * function so that the memory allocated to a domain list entry can be released
+ * safely.
+ *
+ */
+static void cipso_v4_doi_domhsh_free(struct rcu_head *entry)
+{
+	struct cipso_v4_domhsh_entry *ptr;
+
+	ptr = container_of(entry, struct cipso_v4_domhsh_entry, rcu);
+	if (ptr->domain)
+		kfree(ptr->domain);
+	kfree(ptr);
+}
+
+/**
+ * cipso_v4_cache_entry_free - Frees a cache entry
+ * @entry: the entry to free
+ *
+ * Description:
+ * This function frees the memory associated with a cache entry.
+ *
+ */
+static inline void cipso_v4_cache_entry_free(
+	struct cipso_v4_map_cache_entry *entry)
+{
+	BUG_ON(entry == NULL);
+
+	if (entry->lsm_data.free)
+		entry->lsm_data.free(entry->lsm_data.data);
+	if (entry->key)
+		kfree(entry->key);
+	kfree(entry);
+}
+
+/**
+ * cipso_v4_map_cache_hash - Hashing function for the CIPSO cache
+ * @key: the hash key
+ * @key_len: the length of the key in bytes
+ *
+ * Description:
+ * The CIPSO tag hashing function.  Returns a 32-bit hash value.
+ *
+ */
+static inline u32 cipso_v4_map_cache_hash(const unsigned char *key,
+					  const u32 key_len)
+{
+	unsigned char *p;
+	unsigned char *keyp = (char *)key;
+	u32 val = 0;
+
+	/* This is taken (with slight modification) from 
+	   security/selinux/ss/symtab.c:symhash(), we probably need to find
+	   a better hash for dealing with bitmaps */
+
+	for (p = keyp; (p - keyp) < key_len; p++)
+		val = (val << 4 | (val >> (8 * sizeof(u32) - 4))) ^ (*p);
+	return val;
+}
+
+/*
+ * Label Mapping Cache Functions
+ */
+
+/**
+ * cipso_v4_cache_init - Initialize the CIPSO cache
+ * @bkt_size: the number of cache buckets
+ *
+ * Description:
+ * Initializes the CIPSO label mapping cache, this function should be called
+ * before any of the other functions defined in this file.  Returns zero on
+ * success, negative values on error.
+ *
+ */
+static int cipso_v4_cache_init(const u32 bkt_size)
+{
+	struct cipso_v4_map_cache_bkt *cache;
+	u32 iter;
+
+	BUG_ON(cipso_v4_cache != NULL);
+
+	if (bkt_size == 0)
+		return -EINVAL;
+
+	cache = kcalloc(bkt_size,
+			sizeof(struct cipso_v4_map_cache_bkt), GFP_KERNEL);
+	if (cache == NULL)
+		return -ENOMEM;
+
+	for (iter = 0; iter < bkt_size; iter++) {
+		cache[iter].lock = SPIN_LOCK_UNLOCKED;
+		cache[iter].size = 0;
+		INIT_LIST_HEAD(&cache[iter].list);
+	}
+	cipso_v4_cache = cache;
+	cipso_v4_cache_size = bkt_size;
+
+	return 0;
+}
+
+/**
+ * cipso_v4_cache_destroy - Destroy the CIPSO cache
+ *
+ * Description:
+ * Clears the CIPSO cache and frees all the memory.  This function does not
+ * hold any locks and should only be called when the module is being unloaded.
+ *
+ */
+static int cipso_v4_cache_destroy(void)
+{
+	struct cipso_v4_map_cache_bkt *cache;
+	struct cipso_v4_map_cache_entry *entry;
+	u32 cache_size;
+	u32 iter;
+
+	BUG_ON(cipso_v4_cache == NULL);
+
+	cache = cipso_v4_cache;
+	cache_size = cipso_v4_cache_size;
+	cipso_v4_cache_size = 0;
+	cipso_v4_cache = NULL;
+
+	for (iter = 0; iter < cache_size; iter++)
+		list_for_each_entry(entry, &cache[iter].list, list) {
+			list_del(&entry->list);
+			cipso_v4_cache_entry_free(entry);
+		}
+
+	return 0;
+}
+
+/**
+ * cipso_v4_cache_invalidate - Invalidates the current CIPSO cache
+ *
+ * Description:
+ * Invalidates and frees any entries in the CIPSO cache.  Returns zero on
+ * success and negative values on failure.
+ * 
+ */
+int cipso_v4_cache_invalidate(void)
+{
+	struct cipso_v4_map_cache_entry *entry, *tmp_entry;
+	u32 iter;
+
+	if (!CIPSO_V4_CACHE_ENABLED)
+		return 0;
+
+	for (iter = 0; iter < cipso_v4_cache_size; iter++) {
+		spin_lock(&cipso_v4_cache[iter].lock);
+		list_for_each_entry_safe(entry,
+					 tmp_entry,
+					 &cipso_v4_cache[iter].list, list) {
+			list_del(&entry->list);
+			cipso_v4_cache_entry_free(entry);
+		}
+		cipso_v4_cache[iter].size = 0;
+		spin_unlock(&cipso_v4_cache[iter].lock);
+	}
+
+	return 0;
+}
+
+/**
+ * cipso_v4_cache_check - Check the CIPSO cache for a label mapping
+ * @skb: the packet
+ * @secattr: the security attribute struct to use
+ *
+ * Description:
+ * This function checks the cache to see if a label mapping already exists for
+ * the CIPSO tags in the packet.  If there is a match then the cache is
+ * adjusted and the @secattr struct is populated with the correct LSM security
+ * attributes.  The cache is adjusted in the following manner if the entry is
+ * not already the first in the cache bucket:
+ * 
+ *  1. The cache entry's activity counter is incremented
+ *  2. The previous (higher ranking) entry's activity counter is decremented
+ *  3. If the difference between the two activity counters is geater than
+ *     CIPSO_V4_CACHE_REORDERLIMIT the two entries are swapped
+ *
+ * Returns zero on success, -ENOENT for a cache miss, and other negative values
+ * on error.
+ *
+ */
+static int cipso_v4_cache_check(const struct sk_buff *skb,
+				struct netlbl_lsm_secattr *secattr)
+{
+	u32 bkt;
+	struct cipso_v4_map_cache_entry *entry;
+	struct cipso_v4_map_cache_entry *prev_entry = NULL;
+	unsigned char *cipso_ptr;
+	u32 cipso_ptr_len;
+	u32 hash;
+
+	if (!CIPSO_V4_CACHE_ENABLED)
+		return -ENOENT;
+
+	cipso_ptr = CIPSO_V4_OPTPTR(skb);
+	cipso_ptr_len = cipso_ptr[1];
+	hash = cipso_v4_map_cache_hash(cipso_ptr, cipso_ptr_len);
+
+	bkt = hash & (CIPSO_V4_CACHE_BUCKETBITS - 1);
+	spin_lock(&cipso_v4_cache[bkt].lock);
+	list_for_each_entry(entry, &cipso_v4_cache[bkt].list, list) {
+		if (entry->hash == hash &&
+		    entry->key_len == cipso_ptr_len &&
+		    memcmp(entry->key, cipso_ptr, cipso_ptr_len) == 0) {
+			entry->activity += 1;
+			if (prev_entry != NULL) {
+				if (prev_entry->activity > 0)
+					prev_entry->activity -= 1;
+				if (entry->activity > prev_entry->activity &&
+				    entry->activity - prev_entry->activity >
+				    CIPSO_V4_CACHE_REORDERLIMIT) {
+					__list_del(entry->list.prev,
+						   entry->list.next);
+					__list_add(&entry->list,
+						   prev_entry->list.prev,
+						   &prev_entry->list);
+				}
+			}
+			secattr->cache.free = entry->lsm_data.free;
+			secattr->cache.data = entry->lsm_data.data;
+			spin_unlock(&cipso_v4_cache[bkt].lock);
+			secattr->set_cache = 1;
+			return 0;
+		}
+		prev_entry = entry;
+	}
+	spin_unlock(&cipso_v4_cache[bkt].lock);
+
+	return -ENOENT;
+}
+
+/**
+ * cipso_v4_cache_add - Add an entry to the CIPSO cache
+ * @skb: the packet
+ * @secattr: the packet's security attributes
+ *
+ * Description:
+ * Add a new entry into the CIPSO label mapping cache.  Add the new entry to
+ * head of the cache bucket's list, if the cache bucket is out of room remove
+ * the last entry in the list first.  It is important to note that there is
+ * currently no checking for duplicate keys.  Returns zero on success,
+ * negative values on failure.
+ *
+ */
+int cipso_v4_cache_add(const struct sk_buff *skb, 
+		       const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -EPERM;
+	u32 bkt;
+	struct cipso_v4_map_cache_entry *entry = NULL;
+	struct cipso_v4_map_cache_entry *old_entry = NULL;
+	unsigned char *cipso_ptr;
+	u32 cipso_ptr_len;
+
+	BUG_ON(skb == NULL || secattr == NULL);
+
+	if (!CIPSO_V4_CACHE_ENABLED)
+		return 0;
+
+	cipso_ptr = CIPSO_V4_OPTPTR(skb);
+	BUG_ON(cipso_ptr == NULL);
+	cipso_ptr_len = cipso_ptr[1];
+
+	entry = kzalloc(sizeof(struct cipso_v4_map_cache_entry), GFP_ATOMIC);
+	if (entry == NULL)
+		return -ENOMEM;
+	entry->key = kmalloc(cipso_ptr_len, GFP_ATOMIC);
+	if (entry->key == NULL) {
+		ret_val = -ENOMEM;
+		goto cache_add_failure;
+	}
+
+	entry->hash = cipso_v4_map_cache_hash(cipso_ptr, cipso_ptr_len);
+	memcpy(entry->key, cipso_ptr, cipso_ptr_len);
+	entry->key_len = cipso_ptr_len;
+	entry->lsm_data.free = secattr->cache.free;
+	entry->lsm_data.data = secattr->cache.data;
+
+	bkt = entry->hash & (CIPSO_V4_CACHE_BUCKETBITS - 1);
+	spin_lock(&cipso_v4_cache[bkt].lock);
+	if (cipso_v4_cache[bkt].size < CIPSO_V4_CACHE_BUCKETSIZE) {
+		list_add(&entry->list, &cipso_v4_cache[bkt].list);
+		cipso_v4_cache[bkt].size += 1;
+	} else {
+		old_entry = list_entry(cipso_v4_cache[bkt].list.prev,
+				       struct cipso_v4_map_cache_entry, list);
+		list_del(&old_entry->list);
+		list_add(&entry->list, &cipso_v4_cache[bkt].list);
+	}
+	spin_unlock(&cipso_v4_cache[bkt].lock);
+
+	if (old_entry)
+		cipso_v4_cache_entry_free(old_entry);
+
+	return 0;
+
+cache_add_failure:
+	if (entry)
+		cipso_v4_cache_entry_free(entry);
+	return ret_val;
+}
+
+/*
+ * DOI List Functions
+ */
+
+/**
+ * cipso_v4_doi_search - Searches for a DOI definition
+ * @doi: the DOI to search for
+ *
+ * Description:
+ * Search the DOI definition list for a DOI definition with a DOI value that
+ * matches @doi.  The caller is responsibile for calling rcu_read_[un]lock().
+ * Returns a pointer to the DOI definition on success and NULL on failure.
+ */
+static struct cipso_v4_doi *cipso_v4_doi_search(const u32 doi)
+{
+	struct cipso_v4_doi *iter;
+
+	list_for_each_entry_rcu(iter, &cipso_v4_doi_list, list)
+		if (iter->doi == doi && iter->valid)
+			return iter;
+	return NULL;
+}
+
+/**
+ * cipso_v4_doi_add - Add a new DOI to the CIPSO protocol engine
+ * @doi_def: the DOI structure
+ *
+ * Description:
+ * The caller defines a new DOI for use by the CIPSO engine and calls this
+ * function to add it to the list of acceptable domains.  The caller must
+ * ensure that the mapping table specified in @doi_def->map meets all of the
+ * requirements of the mapping type (see cipso_ipv4.h for details).  Returns
+ * zero on success and non-zero on failure.
+ *
+ */
+int cipso_v4_doi_add(struct cipso_v4_doi *doi_def)
+{
+	if (doi_def == NULL || doi_def->doi == CIPSO_V4_DOI_UNKNOWN)
+		return -EINVAL;
+
+	doi_def->valid = 1;
+	INIT_RCU_HEAD(&doi_def->rcu);
+	INIT_LIST_HEAD(&doi_def->dom_list);
+
+	rcu_read_lock();
+	if (cipso_v4_doi_search(doi_def->doi) != NULL) {
+		rcu_read_unlock();
+		return -EEXIST;
+	}
+	spin_lock(&cipso_v4_doi_list_lock);
+	list_add_tail_rcu(&doi_def->list, &cipso_v4_doi_list);
+	spin_unlock(&cipso_v4_doi_list_lock);
+	rcu_read_unlock();
+
+	return 0;
+}
+
+/**
+ * cipso_v4_doi_remove - Remove an existing DOI from the CIPSO protocol engine
+ * @doi: the DOI value
+ * @callback: the DOI cleanup/free callback
+ *
+ * Description:
+ * Removes a DOI definition from the CIPSO engine, @callback is called to
+ * free any memory.  The NetLabel routines will be called to release their own
+ * LSM domain mappings as well as our own domain list.  Returns zero on
+ * success and negative values on failure.
+ *
+ */
+int cipso_v4_doi_remove(const u32 doi,
+			void (*callback) (struct rcu_head * head))
+{
+	struct cipso_v4_doi *doi_def;
+	struct cipso_v4_domhsh_entry *dom_iter;
+
+	if (doi == CIPSO_V4_DOI_UNKNOWN || callback == NULL)
+		return -EINVAL;
+
+	rcu_read_lock();
+	doi_def = cipso_v4_doi_search(doi);
+	if (doi_def != NULL) {
+		spin_lock(&cipso_v4_doi_list_lock);
+		doi_def->valid = 0;
+		list_del_rcu(&doi_def->list);
+		spin_unlock(&cipso_v4_doi_list_lock);
+		list_for_each_entry_rcu(dom_iter, &doi_def->dom_list, list)
+			if (dom_iter->valid)
+				netlbl_domhsh_remove(dom_iter->domain);
+		rcu_read_unlock();
+		/* PM - should we invalidate the cache before we drop the
+		        lock? */
+		cipso_v4_cache_invalidate();
+
+		call_rcu(&doi_def->rcu, callback);
+		return 0;
+	}
+	rcu_read_unlock();
+
+	return -ENOENT;
+}
+
+/**
+ * cipso_v4_doi_getdef - Returns a pointer to a valid DOI definition
+ * @doi: the DOI value
+ *
+ * Description:
+ * Searches for a valid DOI definition and if one is found it is returned to
+ * the caller.  Otherwise NULL is returned.  The caller must ensure that
+ * rcu_read_lock() is held while accessing the returned definition.
+ *
+ */
+struct cipso_v4_doi *cipso_v4_doi_getdef(const u32 doi)
+{
+	struct cipso_v4_doi *doi_def;
+
+	if (doi == CIPSO_V4_DOI_UNKNOWN)
+		return NULL;
+
+	doi_def = cipso_v4_doi_search(doi);
+
+	return doi_def;
+}
+
+/**
+ * cipso_v4_doi_dump - Dump the CIPSO DOI definitions into a sk_buff
+ * @doi: the DOI value
+ * @headroom: the amount of headroom to allocate for the sk_buff 
+ *
+ * Description:
+ * If the @doi value is zero then dump a list of all the configured DOI values
+ * into a sk_buff.  If the @doi value is non-zero, lookup the match DOI
+ * definition and dump it's contents into a sk_buff.  The returned sk_buff has
+ * room at the front of the sk_buff for a nlmsghdr struct and a @headroom
+ * bytes.  See netlabel_cipso_v4.h for the LIST message format.  This function
+ * may fail if another process is changing the DOI list at the same time.
+ * Returns a pointer to a sk_buff on success, NULL on error.
+ *
+ */
+struct sk_buff *cipso_v4_doi_dump(const u32 doi, const u32 headroom)
+{
+	struct sk_buff *skb;
+	unsigned char *buf;
+	struct cipso_v4_doi *iter;
+	u32 doi_cnt = 0;
+	u32 tag_cnt = 0;
+	u32 lvl_cnt = 0;
+	u32 cat_cnt = 0;
+	u32 buf_len;
+	u32 tmp_len;
+
+	/* XXX - In both cases, this is kinda ugly as we have to go through
+	   the list once to determine how large of a buffer we need,
+	   drop the locks, allocate the buffer, grab the locks, and
+	   finally fill the buffer.  The problem is that there is that
+	   open window where the table could grow and we will end up
+	   short on space. */
+
+	if (doi == 0) {
+		buf_len = 4;
+		rcu_read_lock();
+		list_for_each_entry_rcu(iter, &cipso_v4_doi_list, list)
+			if (iter->valid) {
+				doi_cnt += 1;
+				buf_len += 8;
+			}
+		rcu_read_unlock();
+
+		skb = alloc_skb(NLMSG_SPACE(headroom + buf_len), GFP_KERNEL);
+		if (skb == NULL)
+			return NULL;
+		skb_reserve(skb, NLMSG_SPACE(headroom));
+		tmp_len = skb_tailroom(skb);
+		if (tmp_len < buf_len)
+			goto doi_dump_failure;
+		buf = skb_put(skb, buf_len);
+		buf_len -= 4;
+		netlbl_putinc_u32(&buf, doi_cnt);
+
+		rcu_read_lock();
+		list_for_each_entry_rcu(iter, &cipso_v4_doi_list, list)
+			if (iter->valid) {
+				if (buf_len < 8) {
+					rcu_read_unlock();
+					goto doi_dump_failure;
+				}
+				buf_len -= 8;
+				netlbl_putinc_u32(&buf, iter->doi);
+				netlbl_putinc_u32(&buf, iter->type);
+			}
+		rcu_read_unlock();
+	} else {
+		buf_len = 12;
+		rcu_read_lock();
+		iter = cipso_v4_doi_getdef(doi);
+		if (iter == NULL || iter->type != CIPSO_V4_MAP_STD) {
+			rcu_read_unlock();
+			return NULL;
+		}
+		while (tag_cnt < CIPSO_V4_TAG_MAXCNT &&
+		       iter->tags[tag_cnt] != CIPSO_V4_TAG_INVALID) {
+			tag_cnt += 1;
+			buf_len += 1;
+		}
+		tmp_len = 0;
+		while (tmp_len < iter->map.std->lvl.local_size)
+			if (iter->map.std->lvl.local[tmp_len++] !=
+			    CIPSO_V4_INV_LVL) {
+				lvl_cnt += 1;
+				buf_len += 8;
+			}
+		tmp_len = 0;
+		while (tmp_len < iter->map.std->cat.local_size)
+			if (iter->map.std->cat.local[tmp_len++] !=
+			    CIPSO_V4_INV_CAT) {
+				cat_cnt += 1;
+				buf_len += 8;
+			}
+		rcu_read_unlock();
+
+		skb = alloc_skb(NLMSG_SPACE(sizeof(headroom) + buf_len),
+				GFP_KERNEL);
+		if (skb == NULL)
+			return NULL;
+		skb_reserve(skb, NLMSG_SPACE(headroom));
+		tmp_len = skb_tailroom(skb);
+		if (tmp_len < buf_len)
+			goto doi_dump_failure;
+		buf = skb_put(skb, buf_len);
+		buf_len -= 12;
+		netlbl_putinc_u32(&buf, tag_cnt);
+		netlbl_putinc_u32(&buf, lvl_cnt);
+		netlbl_putinc_u32(&buf, cat_cnt);
+
+		rcu_read_lock();
+		if (iter != cipso_v4_doi_getdef(doi)) {
+			rcu_read_unlock();
+			goto doi_dump_failure;
+		}
+		tmp_len = 0;
+		while (tmp_len < CIPSO_V4_TAG_MAXCNT &&
+		       iter->tags[tmp_len] != CIPSO_V4_TAG_INVALID) {
+			if (buf_len < 1) {
+				rcu_read_unlock();
+				goto doi_dump_failure;
+			}
+			buf_len -= 1;
+			netlbl_putinc_u8(&buf, iter->tags[tmp_len++]);
+		}
+		tmp_len = 0;
+		while (tmp_len < iter->map.std->lvl.local_size) {
+			if (iter->map.std->lvl.local[tmp_len] !=
+			    CIPSO_V4_INV_LVL) {
+				if (buf_len < 8) {
+					rcu_read_unlock();
+					goto doi_dump_failure;
+				}
+				buf_len -= 8;
+				netlbl_putinc_u32(&buf, tmp_len);
+				netlbl_putinc_u32(&buf,
+						  iter->map.std->lvl.
+						  local[tmp_len]);
+			}
+			tmp_len += 1;
+		}
+		tmp_len = 0;
+		while (tmp_len < iter->map.std->cat.local_size) {
+			if (iter->map.std->cat.local[tmp_len] !=
+			    CIPSO_V4_INV_CAT) {
+				if (buf_len < 8) {
+					rcu_read_unlock();
+					goto doi_dump_failure;
+				}
+				buf_len -= 8;
+				netlbl_putinc_u32(&buf, tmp_len);
+				netlbl_putinc_u32(&buf,
+						  iter->map.std->cat.
+						  local[tmp_len]);
+			}
+			tmp_len += 1;
+		}
+		rcu_read_unlock();
+	}
+
+	return skb;
+
+doi_dump_failure:
+	kfree(skb);
+	return NULL;
+}
+
+/**
+ * cipso_v4_doi_domhsh_add - Adds a domain entry to a DOI definition
+ * @doi_def: the DOI definition
+ * @domain: the domain to add
+ *
+ * Description:
+ * Adds the @domain to the the DOI specified by @doi_def, this function
+ * should only be called by external functions (i.e. NetLabel).  This function
+ * does allocate memory.  Returns zero on success, negative values on failure.
+ *
+ */
+int cipso_v4_doi_domhsh_add(struct cipso_v4_doi *doi_def, const char *domain)
+{
+	struct cipso_v4_domhsh_entry *iter;
+	struct cipso_v4_domhsh_entry *new_dom;
+
+	BUG_ON(doi_def == NULL);
+
+	new_dom = kmalloc(sizeof(struct cipso_v4_domhsh_entry), GFP_KERNEL);
+	if (new_dom == NULL)
+		return -ENOMEM;
+	if (domain) {
+		new_dom->domain = kstrdup(domain, GFP_KERNEL);
+		if (new_dom->domain == NULL) {
+			kfree(new_dom);
+			return -ENOMEM;
+		}
+	} else
+		new_dom->domain = NULL;
+	new_dom->valid = 1;
+	INIT_RCU_HEAD(&new_dom->rcu);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(iter, &doi_def->dom_list, list)
+		if (((domain != NULL && strcmp(iter->domain, domain) == 0) ||
+		     (domain == NULL && iter->domain == NULL)) && 
+		    iter->valid) {
+			rcu_read_unlock();
+			kfree(new_dom->domain);
+			kfree(new_dom);
+			return -EEXIST;
+		}
+	spin_lock(&cipso_v4_doi_list_lock);
+	list_add_tail_rcu(&new_dom->list, &doi_def->dom_list);
+	spin_unlock(&cipso_v4_doi_list_lock);
+	rcu_read_unlock();
+	return 0;
+}
+
+/**
+ * cipso_v4_doi_domhsh_remove - Removes a domain entry from a DOI definition
+ * @doi_def: the DOI definition
+ * @domain: the domain to remove
+ *
+ * Description:
+ * Removes the @domain from the DOI specified by @doi_def, this function
+ * should only be called by external functions (i.e. NetLabel).   Returns zero
+ * on success and negative values on error.
+ *
+ */
+int cipso_v4_doi_domhsh_remove(struct cipso_v4_doi *doi_def, 
+			       const char *domain)
+{
+	struct cipso_v4_domhsh_entry *iter;
+
+	BUG_ON(doi_def == NULL);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(iter, &doi_def->dom_list, list)
+		if (((domain != NULL && strcmp(iter->domain, domain) == 0) ||
+		     (domain == NULL && iter->domain == NULL)) && 
+		    iter->valid) {
+			spin_lock(&cipso_v4_doi_list_lock);
+			iter->valid = 0;
+			list_del_rcu(&iter->list);
+			spin_unlock(&cipso_v4_doi_list_lock);
+			rcu_read_unlock();
+
+			call_rcu(&iter->rcu, cipso_v4_doi_domhsh_free);
+			return 0;
+		}
+	rcu_read_unlock();
+
+	return -ENOENT;
+}
+
+/*
+ * Label Mapping Functions
+ */
+
+/**
+ * cipso_v4_map_lvl_valid - Checks to see if the given level is understood
+ * @doi_def: the DOI definition
+ * @level: the level to check
+ *
+ * Description:
+ * Checks the given level against the given DOI definition and returns a
+ * negative value if the level does not have a valid mapping and a zero value
+ * if the level is defined by the DOI.
+ *
+ */
+int cipso_v4_map_lvl_valid(const struct cipso_v4_doi *doi_def, const u8 level)
+{
+	BUG_ON(doi_def == NULL || doi_def->type != CIPSO_V4_MAP_STD);
+
+	if (doi_def->map.std->lvl.cipso[level] < CIPSO_V4_INV_LVL)
+		return 0;
+
+	return -EFAULT;
+}
+
+/**
+ * cipso_v4_map_lvl_hton - Perform a level mapping from the host to the network
+ * @doi_def: the DOI definition
+ * @host_lvl: the host MLS level
+ * @net_lvl: the network/CIPSO MLS level
+ *
+ * Description:
+ * Perform a label mapping to translate a local MLS level to the correct
+ * CIPSO level using the given DOI definition.  Returns zero on success,
+ * negative values otherwise.
+ *
+ */
+int cipso_v4_map_lvl_hton(const struct cipso_v4_doi *doi_def,
+			  const u32 host_lvl,
+			  u32 *net_lvl)
+{
+	BUG_ON(doi_def == NULL || net_lvl == NULL ||
+	       doi_def->type != CIPSO_V4_MAP_STD);
+
+	if (host_lvl < doi_def->map.std->lvl.local_size) {
+		*net_lvl = doi_def->map.std->lvl.local[host_lvl];
+		return 0;
+	}
+
+	return -EINVAL;
+}
+
+/**
+ * cipso_v4_map_lvl_ntoh - Perform a level mapping from the network to the host
+ * @doi_def: the DOI definition
+ * @net_lvl: the network/CIPSO MLS level
+ * @host_lvl: the host MLS level
+ *
+ * Description:
+ * Perform a label mapping to translate a CIPSO level to the correct local MLS
+ * level using the given DOI definition.  Returns zero on success, negative
+ * values otherwise.
+ *
+ */
+int cipso_v4_map_lvl_ntoh(const struct cipso_v4_doi *doi_def,
+			  const u32 net_lvl,
+			  u32 *host_lvl)
+{
+	BUG_ON(doi_def == NULL || host_lvl == NULL ||
+	       doi_def->type != CIPSO_V4_MAP_STD);
+
+	if (net_lvl < doi_def->map.std->lvl.cipso_size) {
+		*host_lvl = doi_def->map.std->lvl.cipso[net_lvl];
+		return 0;
+	}
+
+	return -EINVAL;
+}
+
+/**
+ * cipso_v4_map_cat_rbm_valid - Checks to see if the category bitmap is valid
+ * @doi_def: the DOI definition
+ * @bitmap: category bitmap
+ * @bitmap_len: bitmap length in bytes
+ *
+ * Description:
+ * Checks the given category bitmap against the given DOI definition and
+ * returns a negative value if any of the categories in the bitmap do not have
+ * a valid mapping and a zero value if all of the categories are valid.
+ *
+ */
+int cipso_v4_map_cat_rbm_valid(const struct cipso_v4_doi *doi_def,
+			       const unsigned char *bitmap, 
+			       const u32 bitmap_len)
+{
+	u32 offset = 0;
+	int cat;
+	u32 bitmap_len_bits = bitmap_len * 8;
+
+	BUG_ON(doi_def == NULL || doi_def->type != CIPSO_V4_MAP_STD ||
+	       bitmap_len >= CIPSO_V4_MAX_REM_CATS);
+
+	do {
+		cat = cipso_v4_bitmap_walk(bitmap, bitmap_len_bits, offset, 1);
+		offset = cat + 1;
+		if (cat >= 0 &&
+		    doi_def->map.std->cat.cipso[cat] >= CIPSO_V4_INV_CAT)
+			return -EFAULT;
+	} while (cat >= 0 && offset <= bitmap_len_bits);
+
+	if (cat == -1)
+		return 0;
+	return -EFAULT;
+}
+
+/**
+ * cipso_v4_map_cat_rbm_hton - Perform a category mapping from host to network
+ * @doi_def: the DOI definition
+ * @host_cat: the category bitmap in host format
+ * @host_cat_len: the length of the host's category bitmap in bytes
+ * @net_cat: the zero'd out category bitmap in network/CIPSO format
+ * @net_cat_len: the length of the CIPSO bitmap in bytes
+ *
+ * Description:
+ * Perform a label mapping to translate a local MLS category bitmap to the
+ * correct CIPSO bitmap using the given DOI definition.  Returns the minimum
+ * size in bytes of the network bitmap on success, negative values otherwise.
+ *
+ */
+int cipso_v4_map_cat_rbm_hton(const struct cipso_v4_doi *doi_def,
+			      const unsigned char *host_cat,
+			      const u32 host_cat_len,
+			      unsigned char *net_cat,
+			      const u32 net_cat_len)
+{
+	int ret_val;
+	int offset = 0;
+	int host_spot;
+	u32 net_spot;
+	u32 net_spot_max = 0;
+	u32 host_clen_bits = host_cat_len * 8;
+
+	BUG_ON(doi_def == NULL || host_cat == NULL || net_cat == NULL ||
+	       host_cat_len == 0);
+
+	do {
+		host_spot = cipso_v4_bitmap_walk(host_cat,
+						 host_clen_bits, offset, 1);
+		offset = host_spot + 1;
+		if (host_spot >= 0 &&
+		    host_spot < doi_def->map.std->cat.local_size) {
+			net_spot = doi_def->map.std->cat.local[host_spot];
+			if (net_spot / 8 >= net_cat_len)
+				return -ENOSPC;
+			ret_val = cipso_v4_bitmap_setbit(net_cat, net_spot, 1);
+			if (ret_val != 0)
+				return ret_val;
+			if (net_spot > net_spot_max)
+				net_spot_max = net_spot;
+		}
+	} while (host_spot >= 0 && offset <= host_clen_bits);
+
+	if (host_spot == -2)
+		return -EFAULT;
+
+	if (++net_spot_max % 8)
+		return net_spot_max / 8 + 1;
+	return net_spot_max / 8;
+}
+
+/**
+ * cipso_v4_map_cat_rbm_ntoh - Perform a category mapping from network to host
+ * @doi_def: the DOI definition
+ * @net_cat: the category bitmap in network/CIPSO format
+ * @net_cat_len: the length of the CIPSO bitmap in bytes
+ * @host_cat: the zero'd out category bitmap in host format
+ * @host_cat_len: the length of the host's category bitmap in bytes
+ *
+ * Description:
+ * Perform a label mapping to translate a CIPSO bitmap to the correct local 
+ * MLS category bitmap using the given DOI definition.  Returns the minimum
+ * size in bytes of the host bitmap on success, negative values otherwise.
+ *
+ */
+int cipso_v4_map_cat_rbm_ntoh(const struct cipso_v4_doi *doi_def,
+			      const unsigned char *net_cat,
+			      const u32 net_cat_len,
+			      unsigned char *host_cat, 
+			      const u32 host_cat_len)
+{
+	int ret_val;
+	u32 offset = 0;
+	u32 host_spot;
+	u32 host_spot_max = 0;
+	int net_spot;
+	u32 net_clen_bits = net_cat_len * 8;
+
+	BUG_ON(doi_def == NULL || host_cat == NULL || net_cat == NULL ||
+	       net_cat_len == 0);
+
+	do {
+		net_spot = cipso_v4_bitmap_walk(net_cat,
+						net_clen_bits, offset, 1);
+		offset = net_spot + 1;
+		if (net_spot >= 0 &&
+		    net_spot < doi_def->map.std->cat.cipso_size) {
+			host_spot = doi_def->map.std->cat.cipso[net_spot];
+			if (host_spot / 8 >= host_cat_len)
+				return -ENOSPC;
+			ret_val = cipso_v4_bitmap_setbit(host_cat,
+							 host_spot, 1);
+			if (ret_val != 0)
+				return ret_val;
+			if (host_spot > host_spot_max)
+				host_spot_max = host_spot;
+		}
+	} while (net_spot >= 0 && offset <= net_clen_bits);
+
+	if (net_spot == -2)
+		return -EFAULT;
+
+	if (++host_spot_max % 8)
+		return host_spot_max / 8 + 1;
+	return host_spot_max / 8;
+}
+
+/*
+ * Protocol Handling Functions
+ */
+
+#define CIPSO_V4_HDR_LEN              6
+
+/**
+ * cipso_v4_gentag_hdr - Generate a CIPSO option header
+ * @doi_def: the DOI definition
+ * @len: the total tag length in bytes
+ * @buf: the CIPSO option buffer
+ *
+ * Description:
+ * Write a CIPSO header into the beginning of @buffer.  Return zero on success,
+ * negative values on failure.
+ *
+ */
+static inline int cipso_v4_gentag_hdr(const struct cipso_v4_doi *doi_def,
+				      const u32 len, 
+				      unsigned char *buf)
+{
+	if (CIPSO_V4_HDR_LEN + len > 40)
+		return -ENOSPC;
+
+	buf[0] = IPOPT_CIPSO;
+	buf[1] = CIPSO_V4_HDR_LEN + len;
+	*(u32 *)&buf[2] = htonl(doi_def->doi);
+
+	return 0;
+}
+
+#define CIPSO_V4_TAG1_CAT_LEN         28
+
+/**
+ * cipso_v4_gentag_rbm - Generate a CIPSO restricted bitmap tag (type #1)
+ * @doi_def: the DOI definition
+ * @secattr: the security attributes
+ * @buffer: the option buffer
+ * @buffer_len: length of buffer in bytes
+ *
+ * Description:
+ * Generate a CIPSO option using the restricted bitmap tag, tag type #1.  The
+ * actual buffer length may be larger than the indicated size due to
+ * translation between host and network category bitmaps.  Returns zero on
+ * success, negative values on failure.
+ *
+ */
+static inline int cipso_v4_gentag_rbm(const struct cipso_v4_doi *doi_def,
+				      const struct netlbl_lsm_secattr *secattr,
+				      unsigned char **buffer,
+				      u32 *buffer_len)
+{
+	int ret_val = -EPERM;
+	unsigned char *buf = NULL;
+	u32 buf_len;
+	int cat_len = 0;
+	u32 level;
+
+	*buffer = NULL;
+	*buffer_len = 0;
+
+	buf_len = 4;
+	if (secattr->set_mls_cat)
+		buf_len += CIPSO_V4_TAG1_CAT_LEN;
+
+	buf = kzalloc(CIPSO_V4_HDR_LEN + buf_len, GFP_ATOMIC);
+	if (buf == NULL)
+		return -ENOMEM;
+
+	if (secattr->set_mls_cat) {
+		cat_len = cipso_v4_map_cat_rbm_hton(doi_def,
+						    secattr->mls_cat,
+						    secattr->mls_cat_len,
+						    &buf[CIPSO_V4_HDR_LEN + 4],
+						    secattr->mls_cat_len);
+		if (cat_len < 0) {
+			ret_val = cat_len;
+			goto gentag_failure;
+		}
+		/* PM - make this a sysctl adjustable value? */
+#if 0
+		/* XXX - this will send packets using the "optimized" format 
+		   when possibile as specified in  section 3.4.2.6 of the 
+		   CIPSO draft */
+		if (cat_len > 0 && cat_len < 10)
+			cat_len = 10;
+#endif
+	}
+	buf_len = 4 + cat_len;
+
+	ret_val = cipso_v4_map_lvl_hton(doi_def, secattr->mls_lvl, &level);
+	if (ret_val != 0)
+		goto gentag_failure;
+
+	ret_val = cipso_v4_gentag_hdr(doi_def, buf_len, buf);
+	if (ret_val != 0)
+		goto gentag_failure;
+
+	buf[CIPSO_V4_HDR_LEN + 0] = 0x01;
+	buf[CIPSO_V4_HDR_LEN + 1] = buf_len;
+	buf[CIPSO_V4_HDR_LEN + 3] = level;
+
+	*buffer = buf;
+	*buffer_len = CIPSO_V4_HDR_LEN + 4 + cat_len;
+
+	return 0;
+
+gentag_failure:
+	if (buf)
+		kfree(buf);
+	return ret_val;
+}
+
+/**
+ * cipso_v4_parsetag_rbm - Parse a CIPSO restricted bitmap tag
+ * @doi_def: the DOI definition
+ * @tag: the CIPSO tag
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Parse a CIPSO restricted bitmap tag (tag type #1) and return the security
+ * attributes in @secattr.  Return zero on success, negatives values on
+ * failure.
+ *
+ */
+static inline int cipso_v4_parsetag_rbm(const struct cipso_v4_doi *doi_def,
+					const unsigned char *tag,
+					struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	u8 tag_len = tag[1];
+	u32 level;
+
+	BUG_ON(doi_def->type != CIPSO_V4_MAP_STD);
+
+	ret_val = cipso_v4_map_lvl_ntoh(doi_def, tag[3], &level);
+	if (ret_val != 0)
+		return ret_val;
+	secattr->mls_lvl = level;
+	secattr->set_mls_lvl = 1;
+
+	if (tag_len > 4) {
+		secattr->mls_cat_len = doi_def->map.std->cat.local_size;
+		secattr->mls_cat = kzalloc(secattr->mls_cat_len, GFP_ATOMIC);
+		if (secattr->mls_cat == NULL)
+			return -ENOMEM;
+
+		ret_val = cipso_v4_map_cat_rbm_ntoh(doi_def,
+						    &tag[4],
+						    tag[1] - 4,
+						    secattr->mls_cat,
+						    secattr->mls_cat_len);
+		if (ret_val < 0) {
+			kfree(secattr->mls_cat);
+			return ret_val;
+		}
+		secattr->mls_cat_len = ret_val;
+		secattr->set_mls_cat = 1;
+	}
+
+	return 0;
+}
+
+/** 
+ * cipso_v4_validate - Validate a CIPSO option
+ * @option: the start of the option, on error it is set to point to the error
+ *
+ * Description:
+ * This routine is called to validate a CIPSO option, it checks all of the
+ * fields to ensure that they are at least valid, see the draft snippet below
+ * for details.  If the option is valid then a zero value is returned and
+ * the value of @option is unchanged.  If the option is invalid then a
+ * non-zero value is returned and @option is adjusted to point to the
+ * offending portion of the option.  From the IETF draft ...
+ *
+ *  "If any field within the CIPSO options, such as the DOI identifier, is not
+ *   recognized the IP datagram is discarded and an ICMP 'parameter problem'
+ *   (type 12) is generated and returned.  The ICMP code field is set to 'bad
+ *   parameter' (code 0) and the pointer is set to the start of the CIPSO field
+ *   that is unrecognized."
+ *
+ */
+int cipso_v4_validate(unsigned char **option)
+{
+	unsigned char *opt = *option;
+	unsigned char *tag;
+	unsigned char opt_iter;
+	unsigned char err_offset = 0;
+	unsigned char locked = 0;
+	u8 opt_len;
+	u8 tag_len;
+	struct cipso_v4_doi *doi_def = NULL;
+	u32 tag_iter;
+
+	/* XXX: caller already checks for length values that are too large */
+	opt_len = opt[1];
+	if (opt_len < 9) {
+		err_offset = 1;
+		goto validate_return;
+	}
+
+	rcu_read_lock();
+	locked = 1;
+	doi_def = cipso_v4_doi_getdef(ntohl(*((u32 *) & opt[2])));
+	if (doi_def == NULL) {
+		err_offset = 2;
+		goto validate_return;
+	}
+
+	opt_iter = 6;
+	tag = opt + opt_iter;
+	while (opt_iter < opt_len) {
+		for (tag_iter = 0; doi_def->tags[tag_iter] != tag[0];)
+			if (doi_def->tags[tag_iter] == CIPSO_V4_TAG_INVALID ||
+			    ++tag_iter == CIPSO_V4_TAG_MAXCNT) {
+				err_offset = opt_iter;
+				goto validate_return;
+			}
+
+		tag_len = tag[1];
+		if (tag_len > (opt_len - opt_iter)) {
+			err_offset = opt_iter + 1;
+			goto validate_return;
+		}
+
+		switch (tag[0]) {
+		case CIPSO_V4_TAG_RBITMAP:
+			if (tag_len < 4) {
+				err_offset = opt_iter + 1;
+				goto validate_return;
+			}
+			if (tag[2] != 0) {
+				err_offset = opt_iter + 2;
+				goto validate_return;
+			}
+			/* PM - how detailed a check do we need to make, are
+			   these last two checks (level and category)
+			   neccessary at this level?  would our decoding
+			   at the upper levels fail if we don't check the
+			   values here?  need input from interop testing */
+			if (cipso_v4_map_lvl_valid(doi_def, tag[3]) < 0) {
+				err_offset = opt_iter + 3;
+				goto validate_return;
+			}
+			if (tag_len > 4 &&
+			    cipso_v4_map_cat_rbm_valid(doi_def,
+						       &tag[4],
+						       tag_len - 4) < 0) {
+				err_offset = opt_iter + 4;
+				goto validate_return;
+			}
+			break;
+		case CIPSO_V4_TAG_ENUM:
+		case CIPSO_V4_TAG_RANGE:
+		case CIPSO_V4_TAG_PBITMAP:
+		case CIPSO_V4_TAG_FREEFORM:
+		default:
+			err_offset = opt_iter;
+			goto validate_return;
+		}
+
+		tag += tag_len;
+		opt_iter += tag_len;
+	}
+
+validate_return:
+	if (locked)
+		rcu_read_unlock();
+	*option = opt + err_offset;
+	return err_offset;
+}
+
+/**
+ * cipso_v4_error - Send the correct reponse for a bad packet
+ * @skb: the packet
+ * @error: the error code
+ * @gateway: CIPSO gateway flag
+ *
+ * Description:
+ * Based on the error code given in @error, send an ICMP error message back to
+ * the originating host.  Returns zero on success, negative values on failure.
+ * From the IETF draft ...
+ *
+ *  "If the contents of the CIPSO [option] are valid but the security label is
+ *   outside of the configured host or port label range, the datagram is 
+ *   discarded and an ICMP 'destination unreachable' (type 3) is generated and
+ *   returned.  The code field of the ICMP is set to 'communication with
+ *   destination network administratively prohibited' (code 9) or to
+ *   'communication with destination host administratively prohibited' 
+ *   (code 10).  The value of the code is dependent on whether the originator
+ *   of the ICMP message is acting as a CIPSO host or a CIPSO gateway.  The
+ *   recipient of the ICMP message MUST be able to handle either value.  The
+ *   same procedure is performed if a CIPSO [option] can not be added to an
+ *   IP packet because it is too large to fit in the IP options area."
+ *
+ *  "If the error is triggered by receipt of an ICMP message, the message is
+ *   discarded and no response is permitted (consistent with general ICMP
+ *   processing rules)." 
+ *
+ */
+int cipso_v4_error(struct sk_buff *skb, 
+		   const int error, 
+		   const u32 gateway)
+{
+	BUG_ON(skb == NULL);
+
+	switch (error) {
+	case -EACCES:
+		break;
+	default:
+		return 0;
+	}
+
+	if (skb->nh.iph->protocol == IPPROTO_ICMP)
+		return 0;
+
+	if (gateway)
+		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_NET_ANO, 0);
+	else
+		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_HOST_ANO, 0);
+
+	return 0;
+}
+
+/**
+ * cipso_v4_setopt - Add a CIPSO option to a socket
+ * @sock: the socket
+ * @doi_def: the CIPSO DOI to use
+ * @secattr: the specific security attributes of the socket
+ *
+ * Description:
+ * Set the CIPSO option on the given socket using the DOI definition and
+ * security attributes passed to the function.  Returns zero on success and
+ * negative values on failure.
+ *
+ */
+int cipso_v4_setopt(const struct socket *sock,
+		    const struct cipso_v4_doi *doi_def,
+		    const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -EPERM;
+	u32 iter;
+	unsigned char *buf = NULL;
+	u32 buf_len;
+	struct ip_options *opt = NULL;
+	struct sock *sk;
+	struct inet_sock *sk_inet;
+	struct inet_connection_sock *sk_conn;
+
+	BUG_ON(sock == NULL || doi_def == NULL || secattr == NULL);
+
+	/* XXX - this code assumes only one tag per CIPSO option which is
+	   technically against the IETF draft but since we only recognize
+	   the MAC tags right now it's okay */
+	iter = 0;
+	do {
+		switch (doi_def->tags[iter]) {
+		case CIPSO_V4_TAG_RBITMAP:
+			cipso_v4_gentag_rbm(doi_def, secattr, &buf, &buf_len);
+			break;
+		case CIPSO_V4_TAG_ENUM:
+		case CIPSO_V4_TAG_RANGE:
+		case CIPSO_V4_TAG_PBITMAP:
+		case CIPSO_V4_TAG_FREEFORM:
+		default:
+			ret_val = -EPERM;
+			goto set_option_failure;
+		}
+
+		iter++;
+	} while (buf == NULL &&
+		 iter < CIPSO_V4_TAG_MAXCNT &&
+		 doi_def->tags[iter] != CIPSO_V4_TAG_INVALID);
+
+	if (buf == NULL)
+		goto set_option_failure;
+
+	ret_val = ip_options_get(&opt, buf, buf_len);
+	if (ret_val != 0)
+		goto set_option_failure;
+#if 1
+	/* PM - ip_options_get() sets this, should we clear it?  i say lets
+	 try it as it just makes sense and i'm not sure anyone pays attention
+	 to this flag anyway, if it causes problems we can always remove it */
+	opt->is_setbyuser = 0;
+#endif
+	kfree(buf);
+	buf = NULL;
+
+	sk = sock->sk;
+	lock_sock(sk);
+	sk_inet = inet_sk(sk);
+	if (sk_inet->is_icsk) {
+		sk_conn = inet_csk(sk);
+		if (sk_inet->opt)
+			sk_conn->icsk_ext_hdr_len -= sk_inet->opt->optlen;
+		sk_conn->icsk_ext_hdr_len += opt->optlen;
+		sk_conn->icsk_sync_mss(sk, sk_conn->icsk_pmtu_cookie);
+	}
+	opt = xchg(&sk_inet->opt, opt);
+	release_sock(sk);
+	if (opt)
+		kfree(opt);
+
+	return 0;
+
+set_option_failure:
+	if (buf)
+		kfree(buf);
+	if (opt)
+		kfree(opt);
+	return ret_val;
+}
+
+/**
+ * cipso_v4_getopt - Get the security attributes from the CIPSO option
+ * @skb: the packet
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Parse the given packet's CIPSO option and return the security attributes.
+ * Returns zero on success and negative values on failure.
+ *
+ */
+int cipso_v4_getopt(const struct sk_buff *skb, 
+		    struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	unsigned char *cipso_ptr;
+	u32 doi;
+	struct cipso_v4_doi *doi_def;
+
+	BUG_ON(skb == NULL || secattr == NULL);
+
+	if (cipso_v4_cache_check(skb, secattr) == 0)
+		return 0;
+
+	cipso_ptr = CIPSO_V4_OPTPTR(skb);
+	doi = ntohl(*(u32 *) & cipso_ptr[2]);
+	rcu_read_lock();
+	doi_def = cipso_v4_doi_getdef(doi);
+	if (doi_def == NULL) {
+		rcu_read_unlock();
+		return -ENOMSG;
+	}
+	/* XXX - this code assumes only one tag per CIPSO option, the draft is
+	   a little unclear about supporting multiple tags per option
+	   but this seems safe for now */
+	switch (cipso_ptr[6]) {
+	case CIPSO_V4_TAG_RBITMAP:
+		ret_val = cipso_v4_parsetag_rbm(doi_def,
+						&cipso_ptr[6],
+						secattr);
+		break;
+	default:
+		ret_val = -ENOMSG;
+	}
+	rcu_read_unlock();
+
+	return ret_val;
+}
+
+/*
+ * Modules Functions
+ */
+
+/**
+ * cipso_v4_init - Initialize the CIPSO module
+ *
+ * Description:
+ * Initialize the CIPSO module and prepare it for use.  Returns zero on success
+ * and negative values on failure.
+ *
+ */
+static int __init cipso_v4_init(void)
+{
+	return cipso_v4_cache_init(CIPSO_V4_CACHE_BUCKETS);
+}
+
+/**
+ * cipso_v4_exit - Cleanup after the CIPSO module
+ *
+ * Description:
+ * Perform any necessary cleanup tasks before the CIPSO module goes away.
+ *
+ */
+static void __exit cipso_v4_exit(void)
+{
+	cipso_v4_cache_destroy();
+}
+
+module_init(cipso_v4_init);
+module_exit(cipso_v4_exit);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Paul Moore <paul.moore@hp.com>");
--- linux-2.6.16.i686/net/ipv4/ip_fragment.c	2006-05-23 11:34:55.000000000 -0400
+++ linux-2.6.16.i686-cipso/net/ipv4/ip_fragment.c	2006-05-24 12:48:12.000000000 -0400
@@ -73,6 +73,11 @@ struct ipfrag_skb_cb
 
 #define FRAG_CB(skb)	((struct ipfrag_skb_cb*)((skb)->cb))
 
+/* Track critical IP options that must be the same in each fragment. */
+struct ipq_opts {
+	unsigned char *cipso;
+};
+
 /* Describe an entry in the "incomplete datagrams" queue. */
 struct ipq {
 	struct hlist_node list;
@@ -97,6 +102,7 @@ struct ipq {
 	int             iif;
 	unsigned int    rid;
 	struct inet_peer *peer;
+	struct ipq_opts opt;
 };
 
 /* Hash table. */
@@ -177,6 +183,8 @@ static __inline__ void frag_free_queue(s
 	if (work)
 		*work -= sizeof(struct ipq);
 	atomic_sub(sizeof(struct ipq), &ip_frag_mem);
+	if (qp->opt.cipso)
+		kfree(qp->opt.cipso);
 	kfree(qp);
 }
 
@@ -368,6 +376,8 @@ static struct ipq *ip_frag_create(struct
 	qp->iif = 0;
 	qp->peer = sysctl_ipfrag_max_dist ? inet_getpeer(iph->saddr, 1) : NULL;
 
+        qp->opt.cipso = NULL;
+
 	/* Initialize a timer for this entry. */
 	init_timer(&qp->timer);
 	qp->timer.data = (unsigned long) qp;	/* pointer to queue	*/
@@ -514,6 +524,34 @@ static void ip_frag_queue(struct ipq *qp
 	if (end == offset)
 		goto err;
 
+	/* If this is the first packet fragment we have seen then
+	 * record any _critical_ options in qp->opt.  Otherwise,
+	 * verify that the _critical_ options in the current fragment
+	 * match with what is stored in qp->opt.
+	 */
+	if (qp->fragments != NULL) {
+		if (qp->opt.cipso) {
+			char cipso_len;
+			cipso_len = skb->nh.raw[FRAG_CB(skb)->h.opt.cipso + 1];
+			if (cipso_len != qp->opt.cipso[1] ||
+			    memcmp(qp->opt.cipso, 
+				   skb->nh.raw + FRAG_CB(skb)->h.opt.cipso,
+				   cipso_len) != 0)
+				goto err;
+		}
+	} else if (qp->fragments == NULL && ihl > 20) {
+		if (FRAG_CB(skb)->h.opt.cipso) {
+			char cipso_len;
+			cipso_len = skb->nh.raw[FRAG_CB(skb)->h.opt.cipso + 1];
+			qp->opt.cipso = kmalloc(cipso_len, GFP_ATOMIC);
+			if (qp->opt.cipso == NULL)
+				goto err;
+			memcpy(qp->opt.cipso,
+			       skb->nh.raw + FRAG_CB(skb)->h.opt.cipso,
+			       cipso_len);
+		}
+	}
+
 	if (pskb_pull(skb, ihl) == NULL)
 		goto err;
 	if (pskb_trim_rcsum(skb, end-offset))
--- linux-2.6.16.i686/net/ipv4/ip_options.c	2006-05-23 11:34:55.000000000 -0400
+++ linux-2.6.16.i686-cipso/net/ipv4/ip_options.c	2006-05-23 16:00:09.000000000 -0400
@@ -24,6 +24,7 @@
 #include <net/ip.h>
 #include <net/icmp.h>
 #include <net/route.h>
+#include <net/cipso_ipv4.h>
 
 /* 
  * Write options to IP header, record destination address to
@@ -194,6 +195,15 @@ int ip_options_echo(struct ip_options * 
 			dopt->is_strictroute = sopt->is_strictroute;
 		}
 	}
+#ifdef CONFIG_NETLABEL_CIPSOV4
+	if (sopt->cipso) {
+		optlen  = sptr[sopt->cipso+1];
+		dopt->cipso = dopt->optlen+sizeof(struct iphdr);
+		memcpy(dptr, sptr+sopt->cipso, optlen);
+		dptr += optlen;
+		dopt->optlen += optlen;
+	}
+#endif /* CONFIG_NETLABEL_CIPSOV4 */
 	while (dopt->optlen & 3) {
 		*dptr++ = IPOPT_END;
 		dopt->optlen++;
@@ -435,6 +445,15 @@ int ip_options_compile(struct ip_options
 			if (optptr[2] == 0 && optptr[3] == 0)
 				opt->router_alert = optptr - iph;
 			break;
+#ifdef CONFIG_NETLABEL_CIPSOV4
+		      case IPOPT_CIPSO:
+		        if (opt->cipso || cipso_v4_validate(&optptr)) {
+				pp_ptr = optptr;
+				goto error;
+			}
+			opt->cipso = optptr - iph;
+			break;
+#endif /* CONFIG_NETLABEL_CIPSOV4 */
 		      case IPOPT_SEC:
 		      case IPOPT_SID:
 		      default:
--- linux-2.6.16.i686/net/netlabel/netlabel_cipso_v4.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/netlabel_cipso_v4.c	2006-05-17 13:41:54.000000000 -0400
@@ -0,0 +1,519 @@
+/*
+ * NetLabel CIPSO/IPv4 Support
+ *
+ * This file defines the CIPSO/IPv4 functions for the NetLabel system.  The
+ * NetLabel system manages static and dynamic label mappings for network 
+ * protocols such as CIPSO and RIPSO.
+ * 
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/netlink.h>
+#include <net/netlabel.h>
+#include <net/cipso_ipv4.h>
+
+#include "netlabel_user.h"
+#include "netlabel_cipso_v4.h"
+
+/* PM - for debugging only, remove before release */
+#define NETLBL_PRINT(msg) printk msg
+
+/*
+ * Local Prototypes
+ */
+
+static int netlbl_cipsov4_send_ack(const struct nlmsghdr *nl_hdr,
+				   const u32 ret_code);
+
+/*
+ * Helper Functions
+ */
+
+/**
+ * netlbl_cipsov4_put_hdr - Write a CIPSO NetLabel header into a buffer
+ * @buffer: the buffer
+ * @opcode: the NetLabel CIPSOv4 opcode
+ * @doi: the CIPSO DOI value
+ *
+ * Description:
+ * Use the given values to write a NetLabel CIPSOv4 header into the given
+ * buffer.
+ *
+ */
+static inline void netlbl_cipsov4_put_hdr(unsigned char *buffer,
+					  const u32 opcode, 
+					  const u32 doi)
+{
+	struct netlbl_cipsov4_msghdr *hdr =
+		(struct netlbl_cipsov4_msghdr *)buffer;
+	hdr->opcode = opcode;
+	hdr->doi = doi;
+}
+
+/**
+ * netlbl_cipsov4_putinc_hdr - Write a CIPSO NetLabel header into a buffer
+ * @buffer: the buffer
+ * @opcode: the NetLabel CIPSOv4 opcode
+ * @doi: the CIPSO DOI value
+ *
+ * Description:
+ * Use the given values to write a NetLabel CIPSOv4 header into the given
+ * buffer and increment the buffer pointer past the header.
+ *
+ */
+static inline void netlbl_cipsov4_putinc_hdr(unsigned char **buffer,
+					     const u32 opcode, 
+					     const u32 doi)
+{
+	netlbl_cipsov4_put_hdr(*buffer, opcode, doi);
+	*buffer += sizeof(struct netlbl_cipsov4_msghdr);
+}
+
+/**
+ * netlbl_cipsov4_payload_len - Return the length of the payload
+ * @nl_hdr: NETLINK message header
+ *
+ * Description:
+ * This function returns the length of the CIPSO V4 NetLabel payload.
+ *
+ */
+static inline u32 netlbl_cipsov4_payload_len(const struct nlmsghdr *nl_hdr)
+{
+	if (nlmsg_len(nl_hdr) <= sizeof(struct netlbl_cipsov4_msghdr))
+		return 0;
+	return nlmsg_len(nl_hdr) - sizeof(struct netlbl_cipsov4_msghdr);
+}
+
+/**
+ * netlbl_cipsov4_payload_data - Returns a pointer to the start of the data
+ * @nl_hdr: NETLINK message header
+ *
+ * Description:
+ * This function returns a pointer to the start of the CIPSO V4 NetLabel
+ * payload.
+ *
+ */
+static inline unsigned char *netlbl_cipsov4_payload_data(
+	const struct nlmsghdr *nl_hdr)
+{
+	return nlmsg_data(nl_hdr) + sizeof(struct netlbl_cipsov4_msghdr);
+}
+
+/**
+ * netlbl_cipsov4_doi_free - Frees a CIPSO V4 DOI definition
+ * @entry: the entry's RCU field
+ *
+ * Description:
+ * This function is designed to be used as a callback to the call_rcu()
+ * function so that the memory allocated to the DOI definition can be released
+ * safely.
+ *
+ */
+static void netlbl_cipsov4_doi_free(struct rcu_head *entry)
+{
+	struct cipso_v4_doi *ptr;
+
+	ptr = container_of(entry, struct cipso_v4_doi, rcu);
+	switch (ptr->type) {
+	case CIPSO_V4_MAP_STD:
+		if (ptr->map.std->lvl.cipso_size > 0)
+			kfree(ptr->map.std->lvl.cipso);
+		if (ptr->map.std->lvl.local_size > 0)
+			kfree(ptr->map.std->lvl.local);
+		if (ptr->map.std->cat.cipso_size > 0)
+			kfree(ptr->map.std->cat.cipso);
+		if (ptr->map.std->cat.local_size > 0)
+			kfree(ptr->map.std->cat.local);
+		break;
+	}
+	kfree(ptr);
+}
+
+/*
+ * Label Mapping Functions
+ */
+
+/**
+ * netlbl_cipsov4_add_std - Adds a CIPSO V4 DOI definition
+ * @doi: the DOI value
+ * @msg: the ADD message data
+ * @msg_size: the size of the ADD message buffer
+ *
+ * Description:
+ * Create a new CIPSO_V4_MAP_STD DOI definition based on the given ADD message
+ * and add it to the CIPSO V4 engine.  Return zero on success and non-zero on
+ * error.
+ *
+ */
+static int netlbl_cipsov4_add_std(const u32 doi,
+				  const unsigned char *msg,
+				  const u32 msg_size)
+{
+	int ret_val = -EPERM;
+	unsigned char *msg_ptr = (unsigned char *)msg;
+	u32 msg_len = msg_size;
+	u32 num_tags;
+	u32 num_lvls;
+	u32 num_cats;
+	struct cipso_v4_doi *doi_def = NULL;
+	u32 iter;
+	u32 tmp_val_a;
+	u32 tmp_val_b;
+
+	if (msg_len < 4)
+		goto add_std_failure;
+	num_tags = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (num_tags == 0 || num_tags > CIPSO_V4_TAG_MAXCNT)
+		goto add_std_failure;
+
+	doi_def = kmalloc(sizeof(struct cipso_v4_doi), GFP_KERNEL);
+	if (doi_def == NULL) {
+		ret_val = -ENOMEM;
+		goto add_std_failure;
+	}
+	doi_def->map.std = kzalloc(sizeof(struct cipso_v4_std_map_tbl),
+				   GFP_KERNEL);
+	if (doi_def->map.std == NULL) {
+		ret_val = -ENOMEM;
+		goto add_std_failure;
+	}
+	doi_def->type = CIPSO_V4_MAP_STD;
+
+	if (msg_len < num_tags)
+		goto add_std_failure;
+	msg_len -= num_tags;
+	for (iter = 0; iter < num_tags; iter++) {
+		doi_def->tags[iter] = netlbl_getinc_u8(&msg_ptr);
+		switch (doi_def->tags[iter]) {
+		case CIPSO_V4_TAG_RBITMAP:
+			break;
+		default:
+			goto add_std_failure;
+		}
+	}
+	if (iter < CIPSO_V4_TAG_MAXCNT)
+		doi_def->tags[iter] = CIPSO_V4_TAG_INVALID;
+
+	if (msg_len < 24)
+		goto add_std_failure;
+
+	num_lvls = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (num_lvls == 0)
+		goto add_std_failure;
+	doi_def->map.std->lvl.local_size = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (doi_def->map.std->lvl.local_size > CIPSO_V4_MAX_LOC_LVLS)
+		goto add_std_failure;
+	doi_def->map.std->lvl.local = kcalloc(doi_def->map.std->lvl.local_size,
+					      sizeof(u32), GFP_KERNEL);
+	if (doi_def->map.std->lvl.local == NULL) {
+		ret_val = -ENOMEM;
+		goto add_std_failure;
+	}
+	doi_def->map.std->lvl.cipso_size = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (doi_def->map.std->lvl.cipso_size > CIPSO_V4_MAX_REM_LVLS)
+		goto add_std_failure;
+	doi_def->map.std->lvl.cipso = kcalloc(doi_def->map.std->lvl.cipso_size,
+					      sizeof(u32), GFP_KERNEL);
+	if (doi_def->map.std->lvl.cipso == NULL) {
+		ret_val = -ENOMEM;
+		goto add_std_failure;
+	}
+
+	num_cats = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	doi_def->map.std->cat.local_size = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (doi_def->map.std->cat.local_size > CIPSO_V4_MAX_LOC_CATS)
+		goto add_std_failure;
+	doi_def->map.std->cat.local = kcalloc(doi_def->map.std->cat.local_size,
+					      sizeof(u32), GFP_KERNEL);
+	if (doi_def->map.std->cat.local == NULL) {
+		ret_val = -ENOMEM;
+		goto add_std_failure;
+	}
+	doi_def->map.std->cat.cipso_size = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (doi_def->map.std->cat.cipso_size > CIPSO_V4_MAX_REM_CATS)
+		goto add_std_failure;
+	doi_def->map.std->cat.cipso = kcalloc(doi_def->map.std->cat.cipso_size,
+					      sizeof(u32), GFP_KERNEL);
+	if (doi_def->map.std->cat.cipso == NULL) {
+		ret_val = -ENOMEM;
+		goto add_std_failure;
+	}
+
+	if (msg_len < num_lvls * 8 + num_cats * 8)
+		goto add_std_failure;
+	msg_len -= num_lvls * 8 + num_cats * 8;
+
+	for (iter = 0; iter < doi_def->map.std->lvl.cipso_size; iter++)
+		doi_def->map.std->lvl.cipso[iter] = CIPSO_V4_INV_LVL;
+	for (iter = 0; iter < doi_def->map.std->lvl.local_size; iter++)
+		doi_def->map.std->lvl.local[iter] = CIPSO_V4_INV_LVL;
+	for (iter = 0; iter < doi_def->map.std->cat.cipso_size; iter++)
+		doi_def->map.std->cat.cipso[iter] = CIPSO_V4_INV_CAT;
+	for (iter = 0; iter < doi_def->map.std->cat.local_size; iter++)
+		doi_def->map.std->cat.local[iter] = CIPSO_V4_INV_CAT;
+
+	for (iter = 0; iter < num_lvls; iter++) {
+		tmp_val_a = netlbl_getinc_u32(&msg_ptr);
+		tmp_val_b = netlbl_getinc_u32(&msg_ptr);
+
+		if (tmp_val_a >= doi_def->map.std->lvl.local_size ||
+		    tmp_val_b >= doi_def->map.std->lvl.cipso_size)
+			goto add_std_failure;
+
+		doi_def->map.std->lvl.cipso[tmp_val_b] = tmp_val_a;
+		doi_def->map.std->lvl.local[tmp_val_a] = tmp_val_b;
+	}
+
+	for (iter = 0; iter < num_cats; iter++) {
+		tmp_val_a = netlbl_getinc_u32(&msg_ptr);
+		tmp_val_b = netlbl_getinc_u32(&msg_ptr);
+
+		if (tmp_val_a >= doi_def->map.std->cat.local_size ||
+		    tmp_val_b >= doi_def->map.std->cat.cipso_size)
+			goto add_std_failure;
+
+		doi_def->map.std->cat.cipso[tmp_val_b] = tmp_val_a;
+		doi_def->map.std->cat.local[tmp_val_a] = tmp_val_b;
+	}
+
+	doi_def->doi = doi;
+	ret_val = cipso_v4_doi_add(doi_def);
+	if (ret_val != 0)
+		goto add_std_failure;
+	return 0;
+
+add_std_failure:
+	if (doi_def)
+		netlbl_cipsov4_doi_free(&doi_def->rcu);
+	return ret_val;
+}
+
+/**
+ * netlbl_cipsov4_add - Handle an ADD message
+ * @nl_hdr: NETLINK message header
+ * @doi: the DOI
+ * @msg: the NetLabel CIPSO V4 message
+ *
+ * Description:
+ * Create a new DOI definition based on the given ADD message and add it to the
+ * CIPSO V4 engine.  Return zero on success and non-zero on error.
+ *
+ */
+static int netlbl_cipsov4_add(const struct nlmsghdr *nl_hdr,
+			      const u32 doi, 
+			      const unsigned char *msg)
+{
+	int ret_val = -EINVAL;
+	u32 map_type;
+	u32 msg_len = netlbl_cipsov4_payload_len(nl_hdr);
+
+	if (msg_len < 4)
+		return -EINVAL;
+
+	map_type = netlbl_get_u32(msg);
+	switch (map_type) {
+	case CIPSO_V4_MAP_STD:
+		ret_val = netlbl_cipsov4_add_std(doi, msg + 4, msg_len - 4);
+		break;
+	}
+
+	if (ret_val == 0)
+		netlbl_cipsov4_send_ack(nl_hdr, NETLBL_CIPSOV4_E_OK);
+	else
+		netlbl_cipsov4_send_ack(nl_hdr, NETLBL_CIPSOV4_E_ERR);
+
+	return ret_val;
+}
+
+/**
+ * netlbl_cipsov4_list - Handle a LIST message
+ * @nl_hdr: NETLINK message header
+ * @doi: the DOI
+ * @msg: the NetLabel CIPSO V4 message
+ *
+ * Description:
+ * Process a user generated LIST message and respond accordingly.  Returns zero
+ * on success and non-zero on failure.
+ *
+ */
+static int netlbl_cipsov4_list(const struct nlmsghdr *nl_hdr,
+			       const u32 doi, 
+			       const unsigned char *msg)
+{
+	int ret_val = -ENOMEM;
+	struct sk_buff *skb;
+	unsigned char *buf_ptr;
+
+	skb = cipso_v4_doi_dump(doi, sizeof(struct netlbl_cipsov4_msghdr));
+	if (skb == NULL)
+		goto list_return;
+	buf_ptr = skb_push(skb,
+			   NLMSG_SPACE(sizeof(struct netlbl_cipsov4_msghdr)));
+	if (buf_ptr == NULL) {
+		kfree(skb);
+		ret_val = -EAGAIN;
+		goto list_return;
+	}
+	netlbl_putinc_hdr(&buf_ptr,
+			  NETLBL_NLTYPE_CIPSOV4,
+			  skb->len,
+			  0,
+			  nl_hdr->nlmsg_pid,
+			  0);
+	netlbl_cipsov4_putinc_hdr(&buf_ptr, NL_CV4_LIST, 0);
+
+	ret_val = netlbl_netlink_snd(skb, nl_hdr->nlmsg_pid);
+
+list_return:
+	if (ret_val != 0)
+		netlbl_cipsov4_send_ack(nl_hdr, NETLBL_CIPSOV4_E_ERR);
+	return ret_val;
+}
+
+/**
+ * netlbl_cipsov4_remove - Handle a REMOVE message
+ * @nl_hdr: NETLINK message header
+ * @doi: the DOI
+ * @msg: the NetLabel CIPSO V4 message
+ *
+ * Description:
+ * Process a user generated REMOVE message and respond accordingly.  Returns
+ * zero on success and non-zero on error.
+ *
+ */
+static int netlbl_cipsov4_remove(const struct nlmsghdr *nl_hdr,
+				 const u32 doi, 
+				 const unsigned char *msg)
+{
+	int ret_val;
+
+	ret_val = cipso_v4_doi_remove(doi, netlbl_cipsov4_doi_free);
+	if (ret_val == 0)
+		netlbl_cipsov4_send_ack(nl_hdr, NETLBL_CIPSOV4_E_OK);
+	else
+		netlbl_cipsov4_send_ack(nl_hdr, NETLBL_CIPSOV4_E_ERR);
+
+	return ret_val;
+}
+
+/*
+ * NetLabel Protocol Handlers
+ */
+
+/**
+ * netlbl_cipsov4_send_ack - Send an ACK message
+ * @nl_hdr: NETLINK message header
+ * @ret_code: return code to use
+ *
+ * Description:
+ * This function sends an ACK message to the sender of the NETLINK message
+ * specified by @nl_hdr.  Returns negative values on error. 
+ *
+ */
+static int netlbl_cipsov4_send_ack(const struct nlmsghdr *nl_hdr,
+				   const u32 ret_code)
+{
+	size_t msg_size;
+	size_t data_size;
+	struct sk_buff *skb;
+	struct nlmsghdr *nl_ack_hdr;
+	unsigned char *data;
+
+	data_size = sizeof(struct netlbl_cipsov4_msghdr) + 8;
+	msg_size = NLMSG_SPACE(data_size);
+
+	skb = alloc_skb(msg_size, GFP_KERNEL);
+	if (skb == NULL)
+		return -ENOMEM;
+
+	nl_ack_hdr = NLMSG_PUT(skb,
+			       nl_hdr->nlmsg_pid,
+			       0, NETLBL_NLTYPE_CIPSOV4, data_size);
+	nl_ack_hdr->nlmsg_len = msg_size;
+
+	data = NLMSG_DATA(nl_ack_hdr);
+	netlbl_cipsov4_putinc_hdr(&data, NL_CV4_ACK, 0);
+	netlbl_putinc_u32(&data, nl_hdr->nlmsg_seq);
+	netlbl_putinc_u32(&data, ret_code);
+
+	return netlbl_netlink_snd(skb, nl_hdr->nlmsg_pid);
+
+nlmsg_failure:
+	kfree_skb(skb);
+	return -EPERM;
+}
+
+/**
+ * netlbl_cipsov4_rcv - Process incoming NetLabel packets
+ * @nl_hdr: NETLINK message header
+ * @msg: pointer to the start of the NetLabel data
+ *
+ * Description:
+ * This function is reponsibile for reading all of the incoming CIPSO V4
+ * NetLabel traffic and dispatching it to the correct CIPSO V4 functions.
+ *
+ */
+void netlbl_cipsov4_rcv(const struct nlmsghdr *nl_hdr, 
+			const unsigned char *msg)
+{
+	struct netlbl_cipsov4_msghdr *nl_cv4_hdr;
+
+	if (nl_hdr == NULL ||
+	    msg == NULL ||
+	    nlmsg_len(nl_hdr) < sizeof(struct netlbl_cipsov4_msghdr))
+		return;
+
+	nl_cv4_hdr = (struct netlbl_cipsov4_msghdr *)msg;
+	switch (nl_cv4_hdr->opcode) {
+	case NL_CV4_ADD:
+		netlbl_cipsov4_add(nl_hdr,
+				   nl_cv4_hdr->doi,
+				   netlbl_cipsov4_payload_data(nl_hdr));
+		break;
+	case NL_CV4_REMOVE:
+		netlbl_cipsov4_remove(nl_hdr,
+				      nl_cv4_hdr->doi,
+				      netlbl_cipsov4_payload_data(nl_hdr));
+		break;
+	case NL_CV4_LIST:
+		netlbl_cipsov4_list(nl_hdr,
+				    nl_cv4_hdr->doi,
+				    netlbl_cipsov4_payload_data(nl_hdr));
+		break;
+	default:
+		netlbl_cipsov4_send_ack(nl_hdr, NETLBL_CIPSOV4_E_BADCMD);
+		return;
+	}
+}
--- linux-2.6.16.i686/net/netlabel/netlabel_cipso_v4.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/netlabel_cipso_v4.h	2006-05-16 12:17:32.000000000 -0400
@@ -0,0 +1,185 @@
+/*
+ * NetLabel CIPSO/IPv4 Support
+ *
+ * This file defines the CIPSO/IPv4 functions for the NetLabel system.  The
+ * NetLabel system manages static and dynamic label mappings for network 
+ * protocols such as CIPSO and RIPSO.
+ * 
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#ifndef _NETLABEL_CIPSO_V4
+#define _NETLABEL_CIPSO_V4
+
+#include <net/netlabel.h>
+
+/*
+ * The following NetLabel payloads are supported by the CIPSO subsystem, all
+ * of which are preceeded by the nlmsghdr struct.
+ *
+ * o ACK:
+ *   Sent by the kernel in response to an applications message, applications
+ *   should never send this message.
+ *
+ *   +----------------------+-----------------------+
+ *   | seq number (32 bits) | return code (32 bits) |
+ *   +----------------------+-----------------------+
+ *
+ *     seq number:  the sequence number of the original message, taken from the
+ *                  nlmsghdr structure
+ *     return code: values specified in NETLBL_CIPSOV4_E_*
+ *
+ * o ADD:
+ *   Sent by an application to add a new DOI mapping table, after completion
+ *   of the task the kernel should ACK this message.
+ *
+ *   +--------------------+---------------------+
+ *   | map type (32 bits) | tag count (32 bits) | ...
+ *   +--------------------+---------------------+
+ *
+ *   +-----------------+
+ *   | tag #X (8 bits) | ... repeated
+ *   +-----------------+
+ *
+ *   +-------------- ---- --- -- -
+ *   | mapping data
+ *   +-------------- ---- --- -- -
+ *
+ *     map type:     the mapping table type (defined in the cipso_ipv4.h header
+ *                   as CIPSO_V4_MAP_*)
+ *     tag count:    the number of tags, must be greater than zero
+ *     tag:          the CIPSO tag for the DOI, tags listed first are given
+ *                   higher priorirty when sending packets
+ *     mapping data: specific to the map type (see below)
+ *
+ *   CIPSO_V4_MAP_STD
+ *
+ *   +------------------+-----------------------+-----------------------+
+ *   | levels (32 bits) | max l level (32 bits) | max r level (32 bits) | ...
+ *   +------------------+-----------------------+-----------------------+
+ *
+ *   +----------------------+---------------------+---------------------+
+ *   | categories (32 bits) | max l cat (32 bits) | max r cat (32 bits) | ...
+ *   +----------------------+---------------------+---------------------+
+ *
+ *   +--------------------------+--------------------------+
+ *   | local level #X (32 bits) | CIPSO level #X (32 bits) | ... repeated
+ *   +--------------------------+--------------------------+
+ *
+ *   +-----------------------------+-----------------------------+
+ *   | local category #X (32 bits) | CIPSO category #X (32 bits) | ... repeated
+ *   +-----------------------------+-----------------------------+
+ *
+ *     levels:         the number of level mappings
+ *     max l level:    the highest local level
+ *     max r level:    the highest remote/CIPSO level
+ *     categories:     the number of category mappings
+ *     max l cat:      the highest local category
+ *     max r cat:      the highest remote/CIPSO category
+ *     local level:    the local part of a level mapping
+ *     CIPSO level:    the remote/CIPSO part of a level mapping
+ *     local category: the local part of a category mapping
+ *     CIPSO category: the remote/CIPSO part of a category mapping
+ *
+ * o REMOVE:
+ *   Sent by an application to remove a specific DOI mapping table from the
+ *   CIPSO V4 system.  This message does not contain a payload.  The kernel
+ *   should ACK this message.
+ *
+ * o LIST:
+ *   This message can be sent either from an application or by the kernel in
+ *   response to an application generated LIST message.  When sent by an
+ *   application there is no payload.  If the application sets the DOI field
+ *   to zero in the CIPSO V4 message header then the kernel should respond
+ *   with a list of valid DOIs.  If the application sets the DOI field equal to
+ *   a non-zero value then the kernel should respond with the matching mapping
+ *   table.  In the case of an error the kernel should respond with an ACK
+ *   message.
+ *
+ *   DOI Listing (DOI == 0)
+ *
+ *   +---------------------+------------------+-----------------------+
+ *   | DOI count (32 bits) | DOI #X (32 bits) | map type #X (32 bits) | ... 
+ *   +---------------------+------------------+-----------------------+
+ *
+ *     DOI count:      the number of DOIs
+ *     DOI:            the DOI value
+ *     map type:       the DOI mapping table type (defined in the cipso_ipv4.h
+ *                     header as CIPSO_V4_MAP_*)
+ *
+ *   DOI Mapping Table (DOI != 0 && map type == CIPSO_V4_MAP_STD)
+ *
+ *   +----------------+------------------+----------------------+
+ *   | tags (32 bits) | levels (32 bits) | categories (32 bits) | ...
+ *   +----------------+------------------+----------------------+
+ *
+ *   +-----------------+
+ *   | tag #X (8 bits) | ... repeated
+ *   +-----------------+
+ *
+ *   +--------------------------+--------------------------+
+ *   | local level #X (32 bits) | CIPSO level #X (32 bits) | ... repeated
+ *   +--------------------------+--------------------------+
+ *
+ *   +-----------------------------+-----------------------------+
+ *   | local category #X (32 bits) | CIPSO category #X (32 bits) | ... repeated
+ *   +-----------------------------+-----------------------------+
+ *
+ *     tags:           the number of CIPSO tag types
+ *     levels:         the number of level mappings
+ *     categories:     the number of category mappings
+ *     tag:            the tag number, tags listed first are given higher
+ *                     priority when sending packets
+ *     local level:    the local part of a level mapping
+ *     CIPSO level:    the remote/CIPSO part of a level mapping
+ *     local category: the local part of a category mapping
+ *     CIPSO category: the remote/CIPSO part of a category mapping
+ *
+ */
+
+/* CIPSO V4 message header */
+struct netlbl_cipsov4_msghdr {
+	enum { NL_CV4_NOOP,
+	       NL_CV4_ACK,
+	       NL_CV4_ADD,
+	       NL_CV4_REMOVE,
+	       NL_CV4_LIST
+	} opcode;
+	u32 doi;
+};
+
+/* CIPSO V4 ACK return codes */
+#define NETLBL_CIPSOV4_E_OK         NETLBL_E_OK
+#define NETLBL_CIPSOV4_E_ERR        NETLBL_E_ERR
+#define NETLBL_CIPSOV4_E_BADCMD     NETLBL_E_BADCMD
+#define NETLBL_CIPSOV4_E_BADDOI     32
+#define NETLBL_CIPSOV4_E_DUPDOI     33
+#define NETLBL_CIPSOV4_E_BADLVL     48
+#define NETLBL_CIPSOV4_E_BADCAT     64
+#define NETLBL_CIPSOV4_E_BADDOM     80
+
+/* Process CIPSO V4 NetLabel messages */
+void netlbl_cipsov4_rcv(const struct nlmsghdr *nl_hdr, 
+			const unsigned char *msg);
+
+#endif
