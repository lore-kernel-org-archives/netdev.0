From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH 3/4] llc: use a device based hash table to speed up multicast delivery
Date: Fri,  4 Dec 2009 00:31:37 +0200
Message-ID: <1259879498-27860-4-git-send-email-opurdila@ixiacom.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: opurdila@ixiacom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:1340 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751575AbZLCWex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 17:34:53 -0500
In-Reply-To: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a per SAP device based hash table to solve the
multicast delivery scalability issues for the case where the are a
large number of interfaces and a large number of sockets (bound to the
same SAP) are used.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/llc.h      |   20 ++++++++++++++++----
 include/net/llc_conn.h |    1 +
 net/llc/llc_conn.c     |   18 +++++++++++++++++-
 net/llc/llc_core.c     |    3 +++
 net/llc/llc_sap.c      |   11 ++++++-----
 5 files changed, 43 insertions(+), 10 deletions(-)

diff --git a/include/net/llc.h b/include/net/llc.h
index 7940da1..31e9902 100644
--- a/include/net/llc.h
+++ b/include/net/llc.h
@@ -31,6 +31,14 @@ struct llc_addr {
 #define LLC_SAP_STATE_INACTIVE	1
 #define LLC_SAP_STATE_ACTIVE	2
 
+#define LLC_SK_DEV_HASH_BITS 10
+#define LLC_SK_DEV_HASH_ENTRIES (1<<LLC_SK_DEV_HASH_BITS)
+
+struct llc_sk_list {
+	rwlock_t lock;
+	struct hlist_head list;
+};
+
 /**
  * struct llc_sap - Defines the SAP component
  *
@@ -53,12 +61,16 @@ struct llc_sap {
 				     struct net_device *orig_dev);
 	struct llc_addr	 laddr;
 	struct list_head node;
-	struct {
-		rwlock_t	  lock;
-		struct hlist_head list;
-	} sk_list;
+	struct llc_sk_list sk_list;
+	struct llc_sk_list sk_dev_hash[LLC_SK_DEV_HASH_ENTRIES];
 };
 
+static inline
+struct llc_sk_list *llc_sk_dev_hash(struct llc_sap *sap, int ifindex)
+{
+	return &sap->sk_dev_hash[ifindex % LLC_SK_DEV_HASH_ENTRIES];
+}
+
 #define LLC_DEST_INVALID         0      /* Invalid LLC PDU type */
 #define LLC_DEST_SAP             1      /* Type 1 goes here */
 #define LLC_DEST_CONN            2      /* Type 2 goes here */
diff --git a/include/net/llc_conn.h b/include/net/llc_conn.h
index fe982fd..2f97d8d 100644
--- a/include/net/llc_conn.h
+++ b/include/net/llc_conn.h
@@ -77,6 +77,7 @@ struct llc_sock {
 					      received and caused sending FRMR.
 					      Used for resending FRMR */
 	u32		    cmsg_flags;
+	struct hlist_node   dev_hash_node;
 };
 
 static inline struct llc_sock *llc_sk(const struct sock *sk)
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index c6bab39..c3f47ec 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -651,11 +651,19 @@ static int llc_find_offset(int state, int ev_type)
  */
 void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
 {
+	struct llc_sock *llc = llc_sk(sk);
+	struct llc_sk_list *dev_hb = llc_sk_dev_hash(sap, llc->dev->ifindex);
+
 	llc_sap_hold(sap);
+	llc->sap = sap;
+
 	write_lock_bh(&sap->sk_list.lock);
-	llc_sk(sk)->sap = sap;
 	sk_add_node(sk, &sap->sk_list.list);
 	write_unlock_bh(&sap->sk_list.lock);
+
+	write_lock_bh(&dev_hb->lock);
+	hlist_add_head(&llc->dev_hash_node, &dev_hb->list);
+	write_unlock_bh(&dev_hb->lock);
 }
 
 /**
@@ -668,9 +676,17 @@ void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
  */
 void llc_sap_remove_socket(struct llc_sap *sap, struct sock *sk)
 {
+	struct llc_sock *llc = llc_sk(sk);
+	struct llc_sk_list *dev_hb = llc_sk_dev_hash(sap, llc->dev->ifindex);
+
 	write_lock_bh(&sap->sk_list.lock);
 	sk_del_node_init(sk);
 	write_unlock_bh(&sap->sk_list.lock);
+
+	write_lock_bh(&dev_hb->lock);
+	hlist_del(&llc->dev_hash_node);
+	write_unlock_bh(&dev_hb->lock);
+
 	llc_sap_put(sap);
 }
 
diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
index ff4c0ab..1d79cda 100644
--- a/net/llc/llc_core.c
+++ b/net/llc/llc_core.c
@@ -33,12 +33,15 @@ DEFINE_RWLOCK(llc_sap_list_lock);
 static struct llc_sap *llc_sap_alloc(void)
 {
 	struct llc_sap *sap = kzalloc(sizeof(*sap), GFP_ATOMIC);
+	int i;
 
 	if (sap) {
 		/* sap->laddr.mac - leave as a null, it's filled by bind */
 		sap->state = LLC_SAP_STATE_ACTIVE;
 		rwlock_init(&sap->sk_list.lock);
 		atomic_set(&sap->refcnt, 1);
+		for (i = 0; i < LLC_SK_DEV_HASH_ENTRIES; i++)
+			rwlock_init(&sap->sk_dev_hash[i].lock);
 	}
 	return sap;
 }
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index 008de1f..11bad55 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -340,12 +340,13 @@ static void llc_sap_mcast(struct llc_sap *sap,
 			  const struct llc_addr *laddr,
 			  struct sk_buff *skb)
 {
-	struct sock *sk;
+	struct llc_sock *llc;
 	struct hlist_node *node;
+	struct llc_sk_list *dev_hb = llc_sk_dev_hash(sap, skb->dev->ifindex);
 
-	read_lock_bh(&sap->sk_list.lock);
-	sk_for_each(sk, node, &sap->sk_list.list) {
-		struct llc_sock *llc = llc_sk(sk);
+	read_lock_bh(&dev_hb->lock);
+	hlist_for_each_entry(llc, node, &dev_hb->list, dev_hash_node) {
+		struct sock *sk = &llc->sk;
 		struct sk_buff *skb1;
 
 		if (sk->sk_type != SOCK_DGRAM)
@@ -365,7 +366,7 @@ static void llc_sap_mcast(struct llc_sap *sap,
 		llc_sap_rcv(sap, skb1, sk);
 		sock_put(sk);
 	}
-	read_unlock_bh(&sap->sk_list.lock);
+	read_unlock_bh(&dev_hb->lock);
 }
 
 
-- 
1.5.6.5

