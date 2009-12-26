From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v3 06/10] llc: use a device based hash table to speed up multicast delivery
Date: Sat, 26 Dec 2009 23:51:04 +0200
Message-ID: <1261864268-10460-7-git-send-email-opurdila@ixiacom.com>
References: <1261864268-10460-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:19502 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753544AbZLZVyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 16:54:43 -0500
In-Reply-To: <1261864268-10460-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a per SAP device based hash table to solve the
multicast delivery scalability issue when we have large number of
interfaces and a large number of sockets bound to the same SAP.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/llc.h      |   11 +++++++++++
 include/net/llc_conn.h |    1 +
 net/llc/llc_conn.c     |   10 +++++++++-
 net/llc/llc_sap.c      |    8 ++++++--
 4 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/include/net/llc.h b/include/net/llc.h
index 1559cf1..dbef591 100644
--- a/include/net/llc.h
+++ b/include/net/llc.h
@@ -32,6 +32,9 @@ struct llc_addr {
 #define LLC_SAP_STATE_INACTIVE	1
 #define LLC_SAP_STATE_ACTIVE	2
 
+#define LLC_SK_DEV_HASH_BITS 6
+#define LLC_SK_DEV_HASH_ENTRIES (1<<LLC_SK_DEV_HASH_BITS)
+
 /**
  * struct llc_sap - Defines the SAP component
  *
@@ -56,8 +59,16 @@ struct llc_sap {
 	struct list_head node;
 	spinlock_t sk_lock;
 	struct hlist_nulls_head sk_list;
+	struct hlist_head sk_dev_hash[LLC_SK_DEV_HASH_ENTRIES];
 };
 
+static inline
+struct hlist_head *llc_sk_dev_hash(struct llc_sap *sap, int ifindex)
+{
+	return &sap->sk_dev_hash[ifindex % LLC_SK_DEV_HASH_ENTRIES];
+}
+
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
index 77bb381..10cdfe2 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -682,10 +682,15 @@ static int llc_find_offset(int state, int ev_type)
  */
 void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
 {
+	struct llc_sock *llc = llc_sk(sk);
+	struct hlist_head *dev_hb = llc_sk_dev_hash(sap, llc->dev->ifindex);
+
 	llc_sap_hold(sap);
-	spin_lock_bh(&sap->sk_lock);
 	llc_sk(sk)->sap = sap;
+
+	spin_lock_bh(&sap->sk_lock);
 	sk_nulls_add_node_rcu(sk, &sap->sk_list);
+	hlist_add_head(&llc->dev_hash_node, dev_hb);
 	spin_unlock_bh(&sap->sk_lock);
 }
 
@@ -699,8 +704,11 @@ void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
  */
 void llc_sap_remove_socket(struct llc_sap *sap, struct sock *sk)
 {
+	struct llc_sock *llc = llc_sk(sk);
+
 	spin_lock_bh(&sap->sk_lock);
 	sk_nulls_del_node_init_rcu(sk);
+	hlist_del(&llc->dev_hash_node);
 	spin_unlock_bh(&sap->sk_lock);
 	llc_sap_put(sap);
 }
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index 94790e6..94cb706 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -387,10 +387,14 @@ static void llc_sap_mcast(struct llc_sap *sap,
 {
 	int i = 0, count = 256 / sizeof(struct sock *);
 	struct sock *sk, *stack[count];
-	struct hlist_nulls_node *node;
+	struct hlist_node *node;
+	struct llc_sock *llc;
+	struct hlist_head *dev_hb = llc_sk_dev_hash(sap, skb->dev->ifindex);
 
 	spin_lock_bh(&sap->sk_lock);
-	sk_nulls_for_each_rcu(sk, node, &sap->sk_list) {
+	hlist_for_each_entry(llc, node, dev_hb, dev_hash_node) {
+
+		sk = &llc->sk;
 
 		if (!llc_mcast_match(sap, laddr, skb, sk))
 			continue;
-- 
1.5.6.5

