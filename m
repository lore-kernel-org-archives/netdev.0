From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] netlabel: Fix several rcu_dereference() calls used without
	RCU read locks
Date: Thu, 01 Apr 2010 16:43:57 -0400
Message-ID: <20100401204357.9795.80383.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:24100 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab0DAUoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 16:44:06 -0400
Received: from g5t0029.atlanta.hp.com (g5t0029.atlanta.hp.com [16.228.8.141])
	by g5t0008.atlanta.hp.com (Postfix) with ESMTP id EAF4F24177
	for <netdev@vger.kernel.org>; Thu,  1 Apr 2010 20:44:03 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent changes to add RCU lock verification to rcu_dereference() calls
caught out a problem with netlbl_unlhsh_hash(), see below.

 ===================================================
 [ INFO: suspicious rcu_dereference_check() usage. ]
 ---------------------------------------------------
 net/netlabel/netlabel_unlabeled.c:246 invoked rcu_dereference_check()
 without protection!

This patch fixes this problem as well as others like it in the NetLabel
code.  Also included in this patch is the identification of future work
to eliminate the RCU read lock in netlbl_domhsh_add(), but in the interest
of getting this patch out quickly that work will happen in another patch
to be finished later.

Thanks to Eric Dumazet and Paul McKenney for their help in understanding
the recent RCU changes.

Signed-off-by: Paul Moore <paul.moore@hp.com>
Reported-by: David Howells <dhowells@redhat.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---
 net/netlabel/netlabel_domainhash.c |   28 ++++++++++-----
 net/netlabel/netlabel_unlabeled.c  |   66 ++++++++++--------------------------
 2 files changed, 37 insertions(+), 57 deletions(-)

diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index 0bfeaab..06ab41b 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -50,9 +50,12 @@ struct netlbl_domhsh_tbl {
 };
 
 /* Domain hash table */
-/* XXX - updates should be so rare that having one spinlock for the entire
- * hash table should be okay */
+/* updates should be so rare that having one spinlock for the entire hash table
+ * should be okay */
 static DEFINE_SPINLOCK(netlbl_domhsh_lock);
+#define netlbl_domhsh_rcu_deref(p) \
+	rcu_dereference_check(p, rcu_read_lock_held() || \
+				 lockdep_is_held(&netlbl_domhsh_lock))
 static struct netlbl_domhsh_tbl *netlbl_domhsh = NULL;
 static struct netlbl_dom_map *netlbl_domhsh_def = NULL;
 
@@ -106,7 +109,8 @@ static void netlbl_domhsh_free_entry(struct rcu_head *entry)
  * Description:
  * This is the hashing function for the domain hash table, it returns the
  * correct bucket number for the domain.  The caller is responsibile for
- * calling the rcu_read_[un]lock() functions.
+ * ensuring that the hash table is protected with either a RCU read lock or the
+ * hash table lock.
  *
  */
 static u32 netlbl_domhsh_hash(const char *key)
@@ -120,7 +124,7 @@ static u32 netlbl_domhsh_hash(const char *key)
 
 	for (iter = 0, val = 0, len = strlen(key); iter < len; iter++)
 		val = (val << 4 | (val >> (8 * sizeof(u32) - 4))) ^ key[iter];
-	return val & (rcu_dereference(netlbl_domhsh)->size - 1);
+	return val & (netlbl_domhsh_rcu_deref(netlbl_domhsh)->size - 1);
 }
 
 /**
@@ -130,7 +134,8 @@ static u32 netlbl_domhsh_hash(const char *key)
  * Description:
  * Searches the domain hash table and returns a pointer to the hash table
  * entry if found, otherwise NULL is returned.  The caller is responsibile for
- * the rcu hash table locks (i.e. the caller much call rcu_read_[un]lock()).
+ * ensuring that the hash table is protected with either a RCU read lock or the
+ * hash table lock.
  *
  */
 static struct netlbl_dom_map *netlbl_domhsh_search(const char *domain)
@@ -141,7 +146,7 @@ static struct netlbl_dom_map *netlbl_domhsh_search(const char *domain)
 
 	if (domain != NULL) {
 		bkt = netlbl_domhsh_hash(domain);
-		bkt_list = &rcu_dereference(netlbl_domhsh)->tbl[bkt];
+		bkt_list = &netlbl_domhsh_rcu_deref(netlbl_domhsh)->tbl[bkt];
 		list_for_each_entry_rcu(iter, bkt_list, list)
 			if (iter->valid && strcmp(iter->domain, domain) == 0)
 				return iter;
@@ -159,8 +164,8 @@ static struct netlbl_dom_map *netlbl_domhsh_search(const char *domain)
  * Searches the domain hash table and returns a pointer to the hash table
  * entry if an exact match is found, if an exact match is not present in the
  * hash table then the default entry is returned if valid otherwise NULL is
- * returned.  The caller is responsibile for the rcu hash table locks
- * (i.e. the caller much call rcu_read_[un]lock()).
+ * returned.  The caller is responsibile ensuring that the hash table is
+ * protected with either a RCU read lock or the hash table lock.
  *
  */
 static struct netlbl_dom_map *netlbl_domhsh_search_def(const char *domain)
@@ -169,7 +174,7 @@ static struct netlbl_dom_map *netlbl_domhsh_search_def(const char *domain)
 
 	entry = netlbl_domhsh_search(domain);
 	if (entry == NULL) {
-		entry = rcu_dereference(netlbl_domhsh_def);
+		entry = netlbl_domhsh_rcu_deref(netlbl_domhsh_def);
 		if (entry != NULL && !entry->valid)
 			entry = NULL;
 	}
@@ -306,8 +311,11 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 	struct netlbl_af6list *tmp6;
 #endif /* IPv6 */
 
+	/* XXX - we can remove this RCU read lock as the spinlock protects the
+	 *       entire function, but before we do we need to fixup the
+	 *       netlbl_af[4,6]list RCU functions to do "the right thing" with
+	 *       respect to rcu_dereference() when only a spinlock is held. */
 	rcu_read_lock();
-
 	spin_lock(&netlbl_domhsh_lock);
 	if (entry->domain != NULL)
 		entry_old = netlbl_domhsh_search(entry->domain);
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 852d9d7..3b4fde7 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -114,6 +114,9 @@ struct netlbl_unlhsh_walk_arg {
 /* updates should be so rare that having one spinlock for the entire
  * hash table should be okay */
 static DEFINE_SPINLOCK(netlbl_unlhsh_lock);
+#define netlbl_unlhsh_rcu_deref(p) \
+	rcu_dereference_check(p, rcu_read_lock_held() || \
+				 lockdep_is_held(&netlbl_unlhsh_lock))
 static struct netlbl_unlhsh_tbl *netlbl_unlhsh = NULL;
 static struct netlbl_unlhsh_iface *netlbl_unlhsh_def = NULL;
 
@@ -235,15 +238,13 @@ static void netlbl_unlhsh_free_iface(struct rcu_head *entry)
  * Description:
  * This is the hashing function for the unlabeled hash table, it returns the
  * bucket number for the given device/interface.  The caller is responsible for
- * calling the rcu_read_[un]lock() functions.
+ * ensuring that the hash table is protected with either a RCU read lock or
+ * the hash table lock.
  *
  */
 static u32 netlbl_unlhsh_hash(int ifindex)
 {
-	/* this is taken _almost_ directly from
-	 * security/selinux/netif.c:sel_netif_hasfn() as they do pretty much
-	 * the same thing */
-	return ifindex & (rcu_dereference(netlbl_unlhsh)->size - 1);
+	return ifindex & (netlbl_unlhsh_rcu_deref(netlbl_unlhsh)->size - 1);
 }
 
 /**
@@ -253,7 +254,8 @@ static u32 netlbl_unlhsh_hash(int ifindex)
  * Description:
  * Searches the unlabeled connection hash table and returns a pointer to the
  * interface entry which matches @ifindex, otherwise NULL is returned.  The
- * caller is responsible for calling the rcu_read_[un]lock() functions.
+ * caller is responsible for ensuring that the hash table is protected with
+ * either a RCU read lock or the hash table lock.
  *
  */
 static struct netlbl_unlhsh_iface *netlbl_unlhsh_search_iface(int ifindex)
@@ -263,7 +265,7 @@ static struct netlbl_unlhsh_iface *netlbl_unlhsh_search_iface(int ifindex)
 	struct netlbl_unlhsh_iface *iter;
 
 	bkt = netlbl_unlhsh_hash(ifindex);
-	bkt_list = &rcu_dereference(netlbl_unlhsh)->tbl[bkt];
+	bkt_list = &netlbl_unlhsh_rcu_deref(netlbl_unlhsh)->tbl[bkt];
 	list_for_each_entry_rcu(iter, bkt_list, list)
 		if (iter->valid && iter->ifindex == ifindex)
 			return iter;
@@ -272,33 +274,6 @@ static struct netlbl_unlhsh_iface *netlbl_unlhsh_search_iface(int ifindex)
 }
 
 /**
- * netlbl_unlhsh_search_iface_def - Search for a matching interface entry
- * @ifindex: the network interface
- *
- * Description:
- * Searches the unlabeled connection hash table and returns a pointer to the
- * interface entry which matches @ifindex.  If an exact match can not be found
- * and there is a valid default entry, the default entry is returned, otherwise
- * NULL is returned.  The caller is responsible for calling the
- * rcu_read_[un]lock() functions.
- *
- */
-static struct netlbl_unlhsh_iface *netlbl_unlhsh_search_iface_def(int ifindex)
-{
-	struct netlbl_unlhsh_iface *entry;
-
-	entry = netlbl_unlhsh_search_iface(ifindex);
-	if (entry != NULL)
-		return entry;
-
-	entry = rcu_dereference(netlbl_unlhsh_def);
-	if (entry != NULL && entry->valid)
-		return entry;
-
-	return NULL;
-}
-
-/**
  * netlbl_unlhsh_add_addr4 - Add a new IPv4 address entry to the hash table
  * @iface: the associated interface entry
  * @addr: IPv4 address in network byte order
@@ -308,8 +283,7 @@ static struct netlbl_unlhsh_iface *netlbl_unlhsh_search_iface_def(int ifindex)
  * Description:
  * Add a new address entry into the unlabeled connection hash table using the
  * interface entry specified by @iface.  On success zero is returned, otherwise
- * a negative value is returned.  The caller is responsible for calling the
- * rcu_read_[un]lock() functions.
+ * a negative value is returned.
  *
  */
 static int netlbl_unlhsh_add_addr4(struct netlbl_unlhsh_iface *iface,
@@ -349,8 +323,7 @@ static int netlbl_unlhsh_add_addr4(struct netlbl_unlhsh_iface *iface,
  * Description:
  * Add a new address entry into the unlabeled connection hash table using the
  * interface entry specified by @iface.  On success zero is returned, otherwise
- * a negative value is returned.  The caller is responsible for calling the
- * rcu_read_[un]lock() functions.
+ * a negative value is returned.
  *
  */
 static int netlbl_unlhsh_add_addr6(struct netlbl_unlhsh_iface *iface,
@@ -391,8 +364,7 @@ static int netlbl_unlhsh_add_addr6(struct netlbl_unlhsh_iface *iface,
  * Description:
  * Add a new, empty, interface entry into the unlabeled connection hash table.
  * On success a pointer to the new interface entry is returned, on failure NULL
- * is returned.  The caller is responsible for calling the rcu_read_[un]lock()
- * functions.
+ * is returned.
  *
  */
 static struct netlbl_unlhsh_iface *netlbl_unlhsh_add_iface(int ifindex)
@@ -415,10 +387,10 @@ static struct netlbl_unlhsh_iface *netlbl_unlhsh_add_iface(int ifindex)
 		if (netlbl_unlhsh_search_iface(ifindex) != NULL)
 			goto add_iface_failure;
 		list_add_tail_rcu(&iface->list,
-				  &rcu_dereference(netlbl_unlhsh)->tbl[bkt]);
+			     &netlbl_unlhsh_rcu_deref(netlbl_unlhsh)->tbl[bkt]);
 	} else {
 		INIT_LIST_HEAD(&iface->list);
-		if (rcu_dereference(netlbl_unlhsh_def) != NULL)
+		if (netlbl_unlhsh_rcu_deref(netlbl_unlhsh_def) != NULL)
 			goto add_iface_failure;
 		rcu_assign_pointer(netlbl_unlhsh_def, iface);
 	}
@@ -548,8 +520,7 @@ unlhsh_add_return:
  *
  * Description:
  * Remove an IP address entry from the unlabeled connection hash table.
- * Returns zero on success, negative values on failure.  The caller is
- * responsible for calling the rcu_read_[un]lock() functions.
+ * Returns zero on success, negative values on failure.
  *
  */
 static int netlbl_unlhsh_remove_addr4(struct net *net,
@@ -611,8 +582,7 @@ static int netlbl_unlhsh_remove_addr4(struct net *net,
  *
  * Description:
  * Remove an IP address entry from the unlabeled connection hash table.
- * Returns zero on success, negative values on failure.  The caller is
- * responsible for calling the rcu_read_[un]lock() functions.
+ * Returns zero on success, negative values on failure.
  *
  */
 static int netlbl_unlhsh_remove_addr6(struct net *net,
@@ -1547,8 +1517,10 @@ int netlbl_unlabel_getattr(const struct sk_buff *skb,
 	struct netlbl_unlhsh_iface *iface;
 
 	rcu_read_lock();
-	iface = netlbl_unlhsh_search_iface_def(skb->skb_iif);
+	iface = netlbl_unlhsh_search_iface(skb->skb_iif);
 	if (iface == NULL)
+		iface = rcu_dereference(netlbl_unlhsh_def);
+	if (iface == NULL || !iface->valid)
 		goto unlabel_getattr_nolabel;
 	switch (family) {
 	case PF_INET: {

