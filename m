From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v3 07/10] llc: replace the socket list with a local address based hash
Date: Sat, 26 Dec 2009 23:51:05 +0200
Message-ID: <1261864268-10460-8-git-send-email-opurdila@ixiacom.com>
References: <1261864268-10460-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:19502 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753976AbZLZVyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 16:54:46 -0500
In-Reply-To: <1261864268-10460-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the cases where a lot of interfaces are used in conjunction with a
lot of LLC sockets bound to the same SAP, the iteration of the socket
list becomes prohibitively expensive.

Replacing the list with a a local address based hash significantly
improves the bind and listener lookup operations as well as the
datagram delivery.

Connected sockets delivery is also improved, but this patch does not
address the case where we have lots of sockets with the same local
address connected to different remote addresses.

In order to keep the socket sanity checks alive and fast a socket
counter was added to the SAP structure.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/llc.h  |   21 +++++++++++++++-
 net/llc/llc_conn.c |   70 +++++++++++++++++++++++++++++++++++++--------------
 net/llc/llc_core.c |    6 +++-
 net/llc/llc_proc.c |   44 ++++++++++++++++++++++----------
 net/llc/llc_sap.c  |   11 +++++++-
 5 files changed, 115 insertions(+), 37 deletions(-)

diff --git a/include/net/llc.h b/include/net/llc.h
index dbef591..709a9b3 100644
--- a/include/net/llc.h
+++ b/include/net/llc.h
@@ -17,6 +17,8 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/rculist_nulls.h>
+#include <linux/hash.h>
+#include <linux/jhash.h>
 
 #include <asm/atomic.h>
 
@@ -35,6 +37,9 @@ struct llc_addr {
 #define LLC_SK_DEV_HASH_BITS 6
 #define LLC_SK_DEV_HASH_ENTRIES (1<<LLC_SK_DEV_HASH_BITS)
 
+#define LLC_SK_LADDR_HASH_BITS 6
+#define LLC_SK_LADDR_HASH_ENTRIES (1<<LLC_SK_LADDR_HASH_BITS)
+
 /**
  * struct llc_sap - Defines the SAP component
  *
@@ -58,7 +63,8 @@ struct llc_sap {
 	struct llc_addr	 laddr;
 	struct list_head node;
 	spinlock_t sk_lock;
-	struct hlist_nulls_head sk_list;
+	int sk_count;
+	struct hlist_nulls_head sk_laddr_hash[LLC_SK_LADDR_HASH_ENTRIES];
 	struct hlist_head sk_dev_hash[LLC_SK_DEV_HASH_ENTRIES];
 };
 
@@ -68,6 +74,19 @@ struct hlist_head *llc_sk_dev_hash(struct llc_sap *sap, int ifindex)
 	return &sap->sk_dev_hash[ifindex % LLC_SK_DEV_HASH_ENTRIES];
 }
 
+static inline
+u32 llc_sk_laddr_hashfn(struct llc_sap *sap, const struct llc_addr *laddr)
+{
+	return hash_32(jhash(laddr->mac, sizeof(laddr->mac), 0),
+		       LLC_SK_LADDR_HASH_BITS);
+}
+
+static inline
+struct hlist_nulls_head *llc_sk_laddr_hash(struct llc_sap *sap,
+					   const struct llc_addr *laddr)
+{
+	return &sap->sk_laddr_hash[llc_sk_laddr_hashfn(sap, laddr)];
+}
 
 #define LLC_DEST_INVALID         0      /* Invalid LLC PDU type */
 #define LLC_DEST_SAP             1      /* Type 1 goes here */
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 10cdfe2..a8dde9b 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -498,10 +498,12 @@ static struct sock *__llc_lookup_established(struct llc_sap *sap,
 {
 	struct sock *rc;
 	struct hlist_nulls_node *node;
+	int slot = llc_sk_laddr_hashfn(sap, laddr);
+	struct hlist_nulls_head *laddr_hb = &sap->sk_laddr_hash[slot];
 
 	rcu_read_lock();
 again:
-	sk_nulls_for_each_rcu(rc, node, &sap->sk_list) {
+	sk_nulls_for_each_rcu(rc, node, laddr_hb) {
 		if (llc_estab_match(sap, daddr, laddr, rc)) {
 			/* Extra checks required by SLAB_DESTROY_BY_RCU */
 			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
@@ -515,6 +517,13 @@ again:
 		}
 	}
 	rc = NULL;
+	/*
+	 * if the nulls value we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 * We probably met an item that was moved to another chain.
+	 */
+	if (unlikely(get_nulls_value(node) != slot))
+		goto again;
 found:
 	rcu_read_unlock();
 	return rc;
@@ -540,29 +549,20 @@ static inline bool llc_listener_match(const struct llc_sap *sap,
 
 	return sk->sk_type == SOCK_STREAM && sk->sk_state == TCP_LISTEN &&
 		llc->laddr.lsap == laddr->lsap &&
-		(llc_mac_match(llc->laddr.mac, laddr->mac) ||
-		 llc_mac_null(llc->laddr.mac));
+		llc_mac_match(llc->laddr.mac, laddr->mac);
 }
 
-/**
- *	llc_lookup_listener - Finds listener for local MAC + SAP
- *	@sap: SAP
- *	@laddr: address of local LLC (MAC + SAP)
- *
- *	Search connection list of the SAP and finds connection listening on
- *	local mac, and local sap. Returns pointer for parent socket found,
- *	%NULL otherwise.
- *	Caller has to make sure local_bh is disabled.
- */
-static struct sock *llc_lookup_listener(struct llc_sap *sap,
-					struct llc_addr *laddr)
+static struct sock *__llc_lookup_listener(struct llc_sap *sap,
+					  struct llc_addr *laddr)
 {
 	struct sock *rc;
 	struct hlist_nulls_node *node;
+	int slot = llc_sk_laddr_hashfn(sap, laddr);
+	struct hlist_nulls_head *laddr_hb = &sap->sk_laddr_hash[slot];
 
 	rcu_read_lock();
 again:
-	sk_nulls_for_each_rcu(rc, node, &sap->sk_list) {
+	sk_nulls_for_each_rcu(rc, node, laddr_hb) {
 		if (llc_listener_match(sap, laddr, rc)) {
 			/* Extra checks required by SLAB_DESTROY_BY_RCU */
 			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
@@ -576,11 +576,40 @@ again:
 		}
 	}
 	rc = NULL;
+	/*
+	 * if the nulls value we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 * We probably met an item that was moved to another chain.
+	 */
+	if (unlikely(get_nulls_value(node) != slot))
+		goto again;
 found:
 	rcu_read_unlock();
 	return rc;
 }
 
+/**
+ *	llc_lookup_listener - Finds listener for local MAC + SAP
+ *	@sap: SAP
+ *	@laddr: address of local LLC (MAC + SAP)
+ *
+ *	Search connection list of the SAP and finds connection listening on
+ *	local mac, and local sap. Returns pointer for parent socket found,
+ *	%NULL otherwise.
+ *	Caller has to make sure local_bh is disabled.
+ */
+static struct sock *llc_lookup_listener(struct llc_sap *sap,
+					struct llc_addr *laddr)
+{
+	static struct llc_addr null_addr;
+	struct sock *rc = __llc_lookup_listener(sap, laddr);
+
+	if (!rc)
+		rc = __llc_lookup_listener(sap, &null_addr);
+
+	return rc;
+}
+
 static struct sock *__llc_lookup(struct llc_sap *sap,
 				 struct llc_addr *daddr,
 				 struct llc_addr *laddr)
@@ -678,18 +707,20 @@ static int llc_find_offset(int state, int ev_type)
  *	@sap: SAP
  *	@sk: socket
  *
- *	This function adds a socket to sk_list of a SAP.
+ *	This function adds a socket to the hash tables of a SAP.
  */
 void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
 {
 	struct llc_sock *llc = llc_sk(sk);
 	struct hlist_head *dev_hb = llc_sk_dev_hash(sap, llc->dev->ifindex);
+	struct hlist_nulls_head *laddr_hb = llc_sk_laddr_hash(sap, &llc->laddr);
 
 	llc_sap_hold(sap);
 	llc_sk(sk)->sap = sap;
 
 	spin_lock_bh(&sap->sk_lock);
-	sk_nulls_add_node_rcu(sk, &sap->sk_list);
+	sap->sk_count++;
+	sk_nulls_add_node_rcu(sk, laddr_hb);
 	hlist_add_head(&llc->dev_hash_node, dev_hb);
 	spin_unlock_bh(&sap->sk_lock);
 }
@@ -699,7 +730,7 @@ void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
  *	@sap: SAP
  *	@sk: socket
  *
- *	This function removes a connection from sk_list of a SAP if
+ *	This function removes a connection from the hash tables of a SAP if
  *	the connection was in this list.
  */
 void llc_sap_remove_socket(struct llc_sap *sap, struct sock *sk)
@@ -709,6 +740,7 @@ void llc_sap_remove_socket(struct llc_sap *sap, struct sock *sk)
 	spin_lock_bh(&sap->sk_lock);
 	sk_nulls_del_node_init_rcu(sk);
 	hlist_del(&llc->dev_hash_node);
+	sap->sk_count--;
 	spin_unlock_bh(&sap->sk_lock);
 	llc_sap_put(sap);
 }
diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
index 5276b97..0c9ef8b 100644
--- a/net/llc/llc_core.c
+++ b/net/llc/llc_core.c
@@ -33,12 +33,14 @@ DEFINE_RWLOCK(llc_sap_list_lock);
 static struct llc_sap *llc_sap_alloc(void)
 {
 	struct llc_sap *sap = kzalloc(sizeof(*sap), GFP_ATOMIC);
+	int i;
 
 	if (sap) {
 		/* sap->laddr.mac - leave as a null, it's filled by bind */
 		sap->state = LLC_SAP_STATE_ACTIVE;
 		spin_lock_init(&sap->sk_lock);
-		INIT_HLIST_NULLS_HEAD(&sap->sk_list, 0);
+		for (i = 0; i < LLC_SK_LADDR_HASH_ENTRIES; i++)
+			INIT_HLIST_NULLS_HEAD(&sap->sk_laddr_hash[i], i);
 		atomic_set(&sap->refcnt, 1);
 	}
 	return sap;
@@ -143,7 +145,7 @@ out:
  */
 void llc_sap_close(struct llc_sap *sap)
 {
-	WARN_ON(!hlist_nulls_empty(&sap->sk_list));
+	WARN_ON(sap->sk_count);
 	llc_del_sap(sap);
 	kfree(sap);
 }
diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index 6b3d033..09dec63 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -34,17 +34,22 @@ static struct sock *llc_get_sk_idx(loff_t pos)
 {
 	struct list_head *sap_entry;
 	struct llc_sap *sap;
-	struct hlist_nulls_node *node;
 	struct sock *sk = NULL;
+	int i;
 
 	list_for_each(sap_entry, &llc_sap_list) {
 		sap = list_entry(sap_entry, struct llc_sap, node);
 
 		spin_lock_bh(&sap->sk_lock);
-		sk_nulls_for_each(sk, node, &sap->sk_list) {
-			if (!pos)
-				goto found;
-			--pos;
+		for (i = 0; i < LLC_SK_LADDR_HASH_ENTRIES; i++) {
+			struct hlist_nulls_head *head = &sap->sk_laddr_hash[i];
+			struct hlist_nulls_node *node;
+
+			sk_nulls_for_each(sk, node, head) {
+				if (!pos)
+					goto found; /* keep the lock */
+				--pos;
+			}
 		}
 		spin_unlock_bh(&sap->sk_lock);
 	}
@@ -61,6 +66,19 @@ static void *llc_seq_start(struct seq_file *seq, loff_t *pos)
 	return l ? llc_get_sk_idx(--l) : SEQ_START_TOKEN;
 }
 
+static struct sock *laddr_hash_next(struct llc_sap *sap, int bucket)
+{
+	struct hlist_nulls_node *node;
+	struct sock *sk = NULL;
+
+	while (++bucket < LLC_SK_LADDR_HASH_ENTRIES)
+		sk_nulls_for_each(sk, node, &sap->sk_laddr_hash[bucket])
+			goto out;
+
+out:
+	return sk;
+}
+
 static void *llc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct sock* sk, *next;
@@ -80,17 +98,15 @@ static void *llc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	}
 	llc = llc_sk(sk);
 	sap = llc->sap;
+	sk = laddr_hash_next(sap, llc_sk_laddr_hashfn(sap, &llc->laddr));
+	if (sk)
+		goto out;
 	spin_unlock_bh(&sap->sk_lock);
-	sk = NULL;
-	for (;;) {
-		if (sap->node.next == &llc_sap_list)
-			break;
-		sap = list_entry(sap->node.next, struct llc_sap, node);
+	list_for_each_entry_continue(sap, &llc_sap_list, node) {
 		spin_lock_bh(&sap->sk_lock);
-		if (!hlist_nulls_empty(&sap->sk_list)) {
-			sk = sk_nulls_head(&sap->sk_list);
-			break;
-		}
+		sk = laddr_hash_next(sap, -1);
+		if (sk)
+			break; /* keep the lock */
 		spin_unlock_bh(&sap->sk_lock);
 	}
 out:
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index 94cb706..ad6e6e1 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -321,10 +321,12 @@ static struct sock *llc_lookup_dgram(struct llc_sap *sap,
 {
 	struct sock *rc;
 	struct hlist_nulls_node *node;
+	int slot = llc_sk_laddr_hashfn(sap, laddr);
+	struct hlist_nulls_head *laddr_hb = &sap->sk_laddr_hash[slot];
 
 	rcu_read_lock_bh();
 again:
-	sk_nulls_for_each_rcu(rc, node, &sap->sk_list) {
+	sk_nulls_for_each_rcu(rc, node, laddr_hb) {
 		if (llc_dgram_match(sap, laddr, rc)) {
 			/* Extra checks required by SLAB_DESTROY_BY_RCU */
 			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
@@ -338,6 +340,13 @@ again:
 		}
 	}
 	rc = NULL;
+	/*
+	 * if the nulls value we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 * We probably met an item that was moved to another chain.
+	 */
+	if (unlikely(get_nulls_value(node) != slot))
+		goto again;
 found:
 	rcu_read_unlock_bh();
 	return rc;
-- 
1.5.6.5

