From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH 4/4] llc: replace the socket list with a local address based hash
Date: Fri,  4 Dec 2009 00:31:38 +0200
Message-ID: <1259879498-27860-5-git-send-email-opurdila@ixiacom.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: opurdila@ixiacom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:20102 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753088AbZLCWeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 17:34:50 -0500
In-Reply-To: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com>
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

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/llc.h  |   21 +++++++++++++++-
 net/llc/llc_conn.c |   64 ++++++++++++++++++++++++++++++-------------------
 net/llc/llc_core.c |    4 +-
 net/llc/llc_proc.c |   67 +++++++++++++++++++++++++++++++++------------------
 net/llc/llc_sap.c  |    7 +++--
 5 files changed, 108 insertions(+), 55 deletions(-)

diff --git a/include/net/llc.h b/include/net/llc.h
index 31e9902..51cb761 100644
--- a/include/net/llc.h
+++ b/include/net/llc.h
@@ -16,6 +16,8 @@
 #include <linux/if_ether.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
+#include <linux/hash.h>
+#include <linux/jhash.h>
 
 #include <asm/atomic.h>
 
@@ -34,6 +36,9 @@ struct llc_addr {
 #define LLC_SK_DEV_HASH_BITS 10
 #define LLC_SK_DEV_HASH_ENTRIES (1<<LLC_SK_DEV_HASH_BITS)
 
+#define LLC_SK_LADDR_HASH_BITS 10
+#define LLC_SK_LADDR_HASH_ENTRIES (1<<LLC_SK_LADDR_HASH_BITS)
+
 struct llc_sk_list {
 	rwlock_t lock;
 	struct hlist_head list;
@@ -61,7 +66,7 @@ struct llc_sap {
 				     struct net_device *orig_dev);
 	struct llc_addr	 laddr;
 	struct list_head node;
-	struct llc_sk_list sk_list;
+	struct llc_sk_list sk_laddr_hash[LLC_SK_LADDR_HASH_ENTRIES];
 	struct llc_sk_list sk_dev_hash[LLC_SK_DEV_HASH_ENTRIES];
 };
 
@@ -71,6 +76,20 @@ struct llc_sk_list *llc_sk_dev_hash(struct llc_sap *sap, int ifindex)
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
+struct llc_sk_list *llc_sk_laddr_hash(struct llc_sap *sap,
+				      const struct llc_addr *laddr)
+{
+	return &sap->sk_laddr_hash[llc_sk_laddr_hashfn(sap, laddr)];
+}
+
 #define LLC_DEST_INVALID         0      /* Invalid LLC PDU type */
 #define LLC_DEST_SAP             1      /* Type 1 goes here */
 #define LLC_DEST_CONN            2      /* Type 2 goes here */
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index c3f47ec..14a2f34 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -485,9 +485,10 @@ static struct sock *__llc_lookup_established(struct llc_sap *sap,
 {
 	struct sock *rc;
 	struct hlist_node *node;
+	struct llc_sk_list *laddr_hb = llc_sk_laddr_hash(sap, laddr);
 
-	read_lock(&sap->sk_list.lock);
-	sk_for_each(rc, node, &sap->sk_list.list) {
+	read_lock(&laddr_hb->lock);
+	sk_for_each(rc, node, &laddr_hb->list) {
 		struct llc_sock *llc = llc_sk(rc);
 
 		if (llc->laddr.lsap == laddr->lsap &&
@@ -500,7 +501,7 @@ static struct sock *__llc_lookup_established(struct llc_sap *sap,
 	}
 	rc = NULL;
 found:
-	read_unlock(&sap->sk_list.lock);
+	read_unlock(&laddr_hb->lock);
 	return rc;
 }
 
@@ -516,6 +517,28 @@ struct sock *llc_lookup_established(struct llc_sap *sap,
 	return sk;
 }
 
+static struct sock *__llc_lookup_listener(struct llc_sap *sap,
+					  struct llc_addr *laddr)
+{
+	struct sock *rc = NULL;
+	struct hlist_node *node;
+	struct llc_sk_list *laddr_hb = llc_sk_laddr_hash(sap, laddr);
+
+	read_lock(&laddr_hb->lock);
+	sk_for_each(rc, node, &laddr_hb->list) {
+		struct llc_sock *llc = llc_sk(rc);
+
+		if (rc->sk_type == SOCK_STREAM && rc->sk_state == TCP_LISTEN &&
+		    llc->laddr.lsap == laddr->lsap &&
+		    llc_mac_match(llc->laddr.mac, laddr->mac))
+			goto found;
+	}
+
+found:
+	read_unlock(&laddr_hb->lock);
+	return rc;
+}
+
 /**
  *	llc_lookup_listener - Finds listener for local MAC + SAP
  *	@sap: SAP
@@ -529,24 +552,13 @@ struct sock *llc_lookup_established(struct llc_sap *sap,
 static struct sock *llc_lookup_listener(struct llc_sap *sap,
 					struct llc_addr *laddr)
 {
+	static struct llc_addr null_addr;
 	struct sock *rc;
-	struct hlist_node *node;
 
-	read_lock(&sap->sk_list.lock);
-	sk_for_each(rc, node, &sap->sk_list.list) {
-		struct llc_sock *llc = llc_sk(rc);
+	rc = __llc_lookup_listener(sap, laddr);
+	if (!rc)
+		rc = __llc_lookup_listener(sap, &null_addr);
 
-		if (rc->sk_type == SOCK_STREAM && rc->sk_state == TCP_LISTEN &&
-		    llc->laddr.lsap == laddr->lsap &&
-		    (llc_mac_match(llc->laddr.mac, laddr->mac) ||
-		     llc_mac_null(llc->laddr.mac))) {
-			sock_hold(rc);
-			goto found;
-		}
-	}
-	rc = NULL;
-found:
-	read_unlock(&sap->sk_list.lock);
 	return rc;
 }
 
@@ -647,19 +659,20 @@ static int llc_find_offset(int state, int ev_type)
  *	@sap: SAP
  *	@sk: socket
  *
- *	This function adds a socket to sk_list of a SAP.
+ *	This function adds a socket to the hash tables of a SAP.
  */
 void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
 {
 	struct llc_sock *llc = llc_sk(sk);
 	struct llc_sk_list *dev_hb = llc_sk_dev_hash(sap, llc->dev->ifindex);
+	struct llc_sk_list *laddr_hb = llc_sk_laddr_hash(sap, &llc->laddr);
 
 	llc_sap_hold(sap);
 	llc->sap = sap;
 
-	write_lock_bh(&sap->sk_list.lock);
-	sk_add_node(sk, &sap->sk_list.list);
-	write_unlock_bh(&sap->sk_list.lock);
+	write_lock_bh(&laddr_hb->lock);
+	sk_add_node(sk, &laddr_hb->list);
+	write_unlock_bh(&laddr_hb->lock);
 
 	write_lock_bh(&dev_hb->lock);
 	hlist_add_head(&llc->dev_hash_node, &dev_hb->list);
@@ -671,17 +684,18 @@ void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
  *	@sap: SAP
  *	@sk: socket
  *
- *	This function removes a connection from sk_list.list of a SAP if
+ *	This function removes a connection from the hash tables of a SAP if
  *	the connection was in this list.
  */
 void llc_sap_remove_socket(struct llc_sap *sap, struct sock *sk)
 {
 	struct llc_sock *llc = llc_sk(sk);
 	struct llc_sk_list *dev_hb = llc_sk_dev_hash(sap, llc->dev->ifindex);
+	struct llc_sk_list *laddr_hb = llc_sk_laddr_hash(sap, &llc->laddr);
 
-	write_lock_bh(&sap->sk_list.lock);
+	write_lock_bh(&laddr_hb->lock);
 	sk_del_node_init(sk);
-	write_unlock_bh(&sap->sk_list.lock);
+	write_unlock_bh(&laddr_hb->lock);
 
 	write_lock_bh(&dev_hb->lock);
 	hlist_del(&llc->dev_hash_node);
diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
index 1d79cda..dccc5e6 100644
--- a/net/llc/llc_core.c
+++ b/net/llc/llc_core.c
@@ -38,10 +38,11 @@ static struct llc_sap *llc_sap_alloc(void)
 	if (sap) {
 		/* sap->laddr.mac - leave as a null, it's filled by bind */
 		sap->state = LLC_SAP_STATE_ACTIVE;
-		rwlock_init(&sap->sk_list.lock);
 		atomic_set(&sap->refcnt, 1);
 		for (i = 0; i < LLC_SK_DEV_HASH_ENTRIES; i++)
 			rwlock_init(&sap->sk_dev_hash[i].lock);
+		for (i = 0; i < LLC_SK_LADDR_HASH_ENTRIES; i++)
+			rwlock_init(&sap->sk_laddr_hash[i].lock);
 	}
 	return sap;
 }
@@ -145,7 +146,6 @@ out:
  */
 void llc_sap_close(struct llc_sap *sap)
 {
-	WARN_ON(!hlist_empty(&sap->sk_list.list));
 	llc_del_sap(sap);
 	kfree(sap);
 }
diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index be47ac4..58613c6 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -32,21 +32,23 @@ static void llc_ui_format_mac(struct seq_file *seq, u8 *addr)
 
 static struct sock *llc_get_sk_idx(loff_t pos)
 {
-	struct list_head *sap_entry;
 	struct llc_sap *sap;
-	struct hlist_node *node;
 	struct sock *sk = NULL;
-
-	list_for_each(sap_entry, &llc_sap_list) {
-		sap = list_entry(sap_entry, struct llc_sap, node);
-
-		read_lock_bh(&sap->sk_list.lock);
-		sk_for_each(sk, node, &sap->sk_list.list) {
-			if (!pos)
-				goto found;
-			--pos;
+	int i;
+
+	list_for_each_entry(sap, &llc_sap_list, node) {
+		for (i = 0; i < LLC_SK_LADDR_HASH_ENTRIES; i++) {
+			struct llc_sk_list *laddr_hb = &sap->sk_laddr_hash[i];
+			struct hlist_node *node;
+
+			read_lock_bh(&laddr_hb->lock);
+			sk_for_each(sk, node, &laddr_hb->list) {
+				if (!pos)
+					goto found; /* keep the lock */
+				--pos;
+			}
+			read_unlock_bh(&laddr_hb->lock);
 		}
-		read_unlock_bh(&sap->sk_list.lock);
 	}
 	sk = NULL;
 found:
@@ -61,6 +63,28 @@ static void *llc_seq_start(struct seq_file *seq, loff_t *pos)
 	return l ? llc_get_sk_idx(--l) : SEQ_START_TOKEN;
 }
 
+static struct sock *laddr_hash_next(struct llc_sap *sap, int bucket)
+{
+	struct llc_sk_list *laddr_hb;
+	struct hlist_node *node;
+	struct sock *sk = NULL;
+
+	/* release the lock previously taken below or in llc_get_sk_idx */
+	if (bucket >= 0)
+		read_unlock_bh(&sap->sk_laddr_hash[bucket].lock);
+
+	while (++bucket < LLC_SK_LADDR_HASH_ENTRIES) {
+		laddr_hb = &sap->sk_laddr_hash[bucket];
+		read_lock_bh(&laddr_hb->lock);
+		sk_for_each(sk, node, &laddr_hb->list)
+			goto out; /* keep the lock */
+		read_unlock_bh(&laddr_hb->lock);
+	}
+
+out:
+	return sk;
+}
+
 static void *llc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct sock* sk, *next;
@@ -80,18 +104,13 @@ static void *llc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	}
 	llc = llc_sk(sk);
 	sap = llc->sap;
-	read_unlock_bh(&sap->sk_list.lock);
-	sk = NULL;
-	for (;;) {
-		if (sap->node.next == &llc_sap_list)
-			break;
-		sap = list_entry(sap->node.next, struct llc_sap, node);
-		read_lock_bh(&sap->sk_list.lock);
-		if (!hlist_empty(&sap->sk_list.list)) {
-			sk = sk_head(&sap->sk_list.list);
+	sk = laddr_hash_next(sap, llc_sk_laddr_hashfn(sap, &llc->laddr));
+	if (sk)
+		goto out;
+	list_for_each_entry_continue(sap, &llc_sap_list, node) {
+		sk = laddr_hash_next(sap, -1);
+		if (sk)
 			break;
-		}
-		read_unlock_bh(&sap->sk_list.lock);
 	}
 out:
 	return sk;
@@ -104,7 +123,7 @@ static void llc_seq_stop(struct seq_file *seq, void *v)
 		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
-		read_unlock_bh(&sap->sk_list.lock);
+		read_unlock_bh(&llc_sk_laddr_hash(sap, &llc->laddr)->lock);
 	}
 	read_unlock_bh(&llc_sap_list_lock);
 }
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index 11bad55..2622c3f 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -310,9 +310,10 @@ static struct sock *llc_lookup_dgram(struct llc_sap *sap,
 {
 	struct sock *rc;
 	struct hlist_node *node;
+	struct llc_sk_list *laddr_hb = llc_sk_laddr_hash(sap, laddr);
 
-	read_lock_bh(&sap->sk_list.lock);
-	sk_for_each(rc, node, &sap->sk_list.list) {
+	read_lock_bh(&laddr_hb->lock);
+	sk_for_each(rc, node, &laddr_hb->list) {
 		struct llc_sock *llc = llc_sk(rc);
 
 		if (rc->sk_type == SOCK_DGRAM &&
@@ -324,7 +325,7 @@ static struct sock *llc_lookup_dgram(struct llc_sap *sap,
 	}
 	rc = NULL;
 found:
-	read_unlock_bh(&sap->sk_list.lock);
+	read_unlock_bh(&laddr_hb->lock);
 	return rc;
 }
 
-- 
1.5.6.5

