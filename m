From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v2 4/9] llc: convert the socket list to RCU locking
Date: Thu, 24 Dec 2009 01:45:29 +0200
Message-ID: <1261611934-24348-5-git-send-email-opurdila@ixiacom.com>
References: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:23684 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757500AbZLWXtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:49:01 -0500
In-Reply-To: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the reclamation phase we use the SLAB_DESTROY_BY_RCU mechanism,
which require some extra checks in the lookup code:

a) If the current socket was released, reallocated & inserted in
another list it will short circuit the iteration for the current list,
thus we need to restart the lookup.

b) If the current socket was released, reallocated & inserted in the
same list we just need to recheck it matches the look-up criteria and
if not we can skip to the next element.

In this case there is no need to restart the lookup, since sockets are
inserted at the start of the list and the worst that will happen is
that we will iterate throught some of the list elements more then
once.

Note that the /proc and multicast delivery was not yet converted to
RCU, it still uses spinlocks for protection.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/llc.h  |    7 ++--
 net/llc/af_llc.c   |    1 +
 net/llc/llc_conn.c |   93 ++++++++++++++++++++++++++++++++++-----------------
 net/llc/llc_core.c |    5 ++-
 net/llc/llc_proc.c |   22 ++++++------
 net/llc/llc_sap.c  |   66 ++++++++++++++++++++++++-------------
 6 files changed, 123 insertions(+), 71 deletions(-)

diff --git a/include/net/llc.h b/include/net/llc.h
index 7940da1..1559cf1 100644
--- a/include/net/llc.h
+++ b/include/net/llc.h
@@ -16,6 +16,7 @@
 #include <linux/if_ether.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
+#include <linux/rculist_nulls.h>
 
 #include <asm/atomic.h>
 
@@ -53,10 +54,8 @@ struct llc_sap {
 				     struct net_device *orig_dev);
 	struct llc_addr	 laddr;
 	struct list_head node;
-	struct {
-		rwlock_t	  lock;
-		struct hlist_head list;
-	} sk_list;
+	spinlock_t sk_lock;
+	struct hlist_nulls_head sk_list;
 };
 
 #define LLC_DEST_INVALID         0      /* Invalid LLC PDU type */
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index c4d1a1d..f49f3dd 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -140,6 +140,7 @@ static struct proto llc_proto = {
 	.name	  = "LLC",
 	.owner	  = THIS_MODULE,
 	.obj_size = sizeof(struct llc_sock),
+	.slab_flags = SLAB_DESTROY_BY_RCU,
 };
 
 /**
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index c6bab39..6e10c0d 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -468,6 +468,19 @@ static int llc_exec_conn_trans_actions(struct sock *sk,
 	return rc;
 }
 
+static inline bool llc_estab_match(const struct llc_sap *sap,
+				   const struct llc_addr *daddr,
+				   const struct llc_addr *laddr,
+				   const struct sock *sk)
+{
+	struct llc_sock *llc = llc_sk(sk);
+
+	return llc->laddr.lsap == laddr->lsap &&
+		llc->daddr.lsap == daddr->lsap &&
+		llc_mac_match(llc->laddr.mac, laddr->mac) &&
+		llc_mac_match(llc->daddr.mac, daddr->mac);
+}
+
 /**
  *	__llc_lookup_established - Finds connection for the remote/local sap/mac
  *	@sap: SAP
@@ -484,23 +497,26 @@ static struct sock *__llc_lookup_established(struct llc_sap *sap,
 					     struct llc_addr *laddr)
 {
 	struct sock *rc;
-	struct hlist_node *node;
-
-	read_lock(&sap->sk_list.lock);
-	sk_for_each(rc, node, &sap->sk_list.list) {
-		struct llc_sock *llc = llc_sk(rc);
-
-		if (llc->laddr.lsap == laddr->lsap &&
-		    llc->daddr.lsap == daddr->lsap &&
-		    llc_mac_match(llc->laddr.mac, laddr->mac) &&
-		    llc_mac_match(llc->daddr.mac, daddr->mac)) {
-			sock_hold(rc);
+	struct hlist_nulls_node *node;
+
+	rcu_read_lock();
+again:
+	sk_nulls_for_each_rcu(rc, node, &sap->sk_list) {
+		if (llc_estab_match(sap, daddr, laddr, rc)) {
+			/* Extra checks required by SLAB_DESTROY_BY_RCU */
+			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt) ||
+				     llc_sk(rc)->sap != sap))
+				goto again;
+			if (unlikely(!llc_estab_match(sap, daddr, laddr, rc))) {
+				sock_put(rc);
+				continue;
+			}
 			goto found;
 		}
 	}
 	rc = NULL;
 found:
-	read_unlock(&sap->sk_list.lock);
+	rcu_read_unlock();
 	return rc;
 }
 
@@ -516,6 +532,18 @@ struct sock *llc_lookup_established(struct llc_sap *sap,
 	return sk;
 }
 
+static inline bool llc_listener_match(const struct llc_sap *sap,
+				      const struct llc_addr *laddr,
+				      const struct sock *sk)
+{
+	struct llc_sock *llc = llc_sk(sk);
+
+	return sk->sk_type == SOCK_STREAM && sk->sk_state == TCP_LISTEN &&
+		llc->laddr.lsap == laddr->lsap &&
+		(llc_mac_match(llc->laddr.mac, laddr->mac) ||
+		 llc_mac_null(llc->laddr.mac));
+}
+
 /**
  *	llc_lookup_listener - Finds listener for local MAC + SAP
  *	@sap: SAP
@@ -530,23 +558,26 @@ static struct sock *llc_lookup_listener(struct llc_sap *sap,
 					struct llc_addr *laddr)
 {
 	struct sock *rc;
-	struct hlist_node *node;
-
-	read_lock(&sap->sk_list.lock);
-	sk_for_each(rc, node, &sap->sk_list.list) {
-		struct llc_sock *llc = llc_sk(rc);
-
-		if (rc->sk_type == SOCK_STREAM && rc->sk_state == TCP_LISTEN &&
-		    llc->laddr.lsap == laddr->lsap &&
-		    (llc_mac_match(llc->laddr.mac, laddr->mac) ||
-		     llc_mac_null(llc->laddr.mac))) {
-			sock_hold(rc);
+	struct hlist_nulls_node *node;
+
+	rcu_read_lock();
+again:
+	sk_nulls_for_each_rcu(rc, node, &sap->sk_list) {
+		if (llc_listener_match(sap, laddr, rc)) {
+			/* Extra checks required by SLAB_DESTROY_BY_RCU */
+			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt) ||
+				     llc_sk(rc)->sap != sap))
+				goto again;
+			if (unlikely(!llc_listener_match(sap, laddr, rc))) {
+				sock_put(rc);
+				continue;
+			}
 			goto found;
 		}
 	}
 	rc = NULL;
 found:
-	read_unlock(&sap->sk_list.lock);
+	rcu_read_unlock();
 	return rc;
 }
 
@@ -652,10 +683,10 @@ static int llc_find_offset(int state, int ev_type)
 void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
 {
 	llc_sap_hold(sap);
-	write_lock_bh(&sap->sk_list.lock);
+	spin_lock_bh(&sap->sk_lock);
 	llc_sk(sk)->sap = sap;
-	sk_add_node(sk, &sap->sk_list.list);
-	write_unlock_bh(&sap->sk_list.lock);
+	sk_nulls_add_node_rcu(sk, &sap->sk_list);
+	spin_unlock_bh(&sap->sk_lock);
 }
 
 /**
@@ -663,14 +694,14 @@ void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
  *	@sap: SAP
  *	@sk: socket
  *
- *	This function removes a connection from sk_list.list of a SAP if
+ *	This function removes a connection from sk_list of a SAP if
  *	the connection was in this list.
  */
 void llc_sap_remove_socket(struct llc_sap *sap, struct sock *sk)
 {
-	write_lock_bh(&sap->sk_list.lock);
-	sk_del_node_init(sk);
-	write_unlock_bh(&sap->sk_list.lock);
+	spin_lock_bh(&sap->sk_lock);
+	sk_nulls_del_node_init_rcu(sk);
+	spin_unlock_bh(&sap->sk_lock);
 	llc_sap_put(sap);
 }
 
diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
index ff4c0ab..5276b97 100644
--- a/net/llc/llc_core.c
+++ b/net/llc/llc_core.c
@@ -37,7 +37,8 @@ static struct llc_sap *llc_sap_alloc(void)
 	if (sap) {
 		/* sap->laddr.mac - leave as a null, it's filled by bind */
 		sap->state = LLC_SAP_STATE_ACTIVE;
-		rwlock_init(&sap->sk_list.lock);
+		spin_lock_init(&sap->sk_lock);
+		INIT_HLIST_NULLS_HEAD(&sap->sk_list, 0);
 		atomic_set(&sap->refcnt, 1);
 	}
 	return sap;
@@ -142,7 +143,7 @@ out:
  */
 void llc_sap_close(struct llc_sap *sap)
 {
-	WARN_ON(!hlist_empty(&sap->sk_list.list));
+	WARN_ON(!hlist_nulls_empty(&sap->sk_list));
 	llc_del_sap(sap);
 	kfree(sap);
 }
diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index be47ac4..6b3d033 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -34,19 +34,19 @@ static struct sock *llc_get_sk_idx(loff_t pos)
 {
 	struct list_head *sap_entry;
 	struct llc_sap *sap;
-	struct hlist_node *node;
+	struct hlist_nulls_node *node;
 	struct sock *sk = NULL;
 
 	list_for_each(sap_entry, &llc_sap_list) {
 		sap = list_entry(sap_entry, struct llc_sap, node);
 
-		read_lock_bh(&sap->sk_list.lock);
-		sk_for_each(sk, node, &sap->sk_list.list) {
+		spin_lock_bh(&sap->sk_lock);
+		sk_nulls_for_each(sk, node, &sap->sk_list) {
 			if (!pos)
 				goto found;
 			--pos;
 		}
-		read_unlock_bh(&sap->sk_list.lock);
+		spin_unlock_bh(&sap->sk_lock);
 	}
 	sk = NULL;
 found:
@@ -73,25 +73,25 @@ static void *llc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		goto out;
 	}
 	sk = v;
-	next = sk_next(sk);
+	next = sk_nulls_next(sk);
 	if (next) {
 		sk = next;
 		goto out;
 	}
 	llc = llc_sk(sk);
 	sap = llc->sap;
-	read_unlock_bh(&sap->sk_list.lock);
+	spin_unlock_bh(&sap->sk_lock);
 	sk = NULL;
 	for (;;) {
 		if (sap->node.next == &llc_sap_list)
 			break;
 		sap = list_entry(sap->node.next, struct llc_sap, node);
-		read_lock_bh(&sap->sk_list.lock);
-		if (!hlist_empty(&sap->sk_list.list)) {
-			sk = sk_head(&sap->sk_list.list);
+		spin_lock_bh(&sap->sk_lock);
+		if (!hlist_nulls_empty(&sap->sk_list)) {
+			sk = sk_nulls_head(&sap->sk_list);
 			break;
 		}
-		read_unlock_bh(&sap->sk_list.lock);
+		spin_unlock_bh(&sap->sk_lock);
 	}
 out:
 	return sk;
@@ -104,7 +104,7 @@ static void llc_seq_stop(struct seq_file *seq, void *v)
 		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
-		read_unlock_bh(&sap->sk_list.lock);
+		spin_unlock_bh(&sap->sk_lock);
 	}
 	read_unlock_bh(&llc_sap_list_lock);
 }
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index 008de1f..f154ab5 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -297,6 +297,17 @@ static void llc_sap_rcv(struct llc_sap *sap, struct sk_buff *skb,
 	llc_sap_state_process(sap, skb);
 }
 
+static inline bool llc_dgram_match(const struct llc_sap *sap,
+				   const struct llc_addr *laddr,
+				   const struct sock *sk)
+{
+     struct llc_sock *llc = llc_sk(sk);
+
+     return sk->sk_type == SOCK_DGRAM &&
+	  llc->laddr.lsap == laddr->lsap &&
+	  llc_mac_match(llc->laddr.mac, laddr->mac);
+}
+
 /**
  *	llc_lookup_dgram - Finds dgram socket for the local sap/mac
  *	@sap: SAP
@@ -309,25 +320,41 @@ static struct sock *llc_lookup_dgram(struct llc_sap *sap,
 				     const struct llc_addr *laddr)
 {
 	struct sock *rc;
-	struct hlist_node *node;
-
-	read_lock_bh(&sap->sk_list.lock);
-	sk_for_each(rc, node, &sap->sk_list.list) {
-		struct llc_sock *llc = llc_sk(rc);
-
-		if (rc->sk_type == SOCK_DGRAM &&
-		    llc->laddr.lsap == laddr->lsap &&
-		    llc_mac_match(llc->laddr.mac, laddr->mac)) {
-			sock_hold(rc);
+	struct hlist_nulls_node *node;
+
+	rcu_read_lock_bh();
+again:
+	sk_nulls_for_each_rcu(rc, node, &sap->sk_list) {
+		if (llc_dgram_match(sap, laddr, rc)) {
+			/* Extra checks required by SLAB_DESTROY_BY_RCU */
+			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt) ||
+				     llc_sk(rc)->sap != sap))
+				goto again;
+			if (unlikely(!llc_dgram_match(sap, laddr, rc))) {
+				sock_put(rc);
+				continue;
+			}
 			goto found;
 		}
 	}
 	rc = NULL;
 found:
-	read_unlock_bh(&sap->sk_list.lock);
+	rcu_read_unlock_bh();
 	return rc;
 }
 
+static inline bool llc_mcast_match(const struct llc_sap *sap,
+				   const struct llc_addr *laddr,
+				   const struct sk_buff *skb,
+				   const struct sock *sk)
+{
+     struct llc_sock *llc = llc_sk(sk);
+
+     return sk->sk_type == SOCK_DGRAM &&
+	  llc->laddr.lsap == laddr->lsap &&
+	  llc->dev == skb->dev;
+}
+
 /**
  * 	llc_sap_mcast - Deliver multicast PDU's to all matching datagram sockets.
  *	@sap: SAP
@@ -341,20 +368,13 @@ static void llc_sap_mcast(struct llc_sap *sap,
 			  struct sk_buff *skb)
 {
 	struct sock *sk;
-	struct hlist_node *node;
+	struct hlist_nulls_node *node;
 
-	read_lock_bh(&sap->sk_list.lock);
-	sk_for_each(sk, node, &sap->sk_list.list) {
-		struct llc_sock *llc = llc_sk(sk);
+	spin_lock_bh(&sap->sk_lock);
+	sk_nulls_for_each_rcu(sk, node, &sap->sk_list) {
 		struct sk_buff *skb1;
 
-		if (sk->sk_type != SOCK_DGRAM)
-			continue;
-
-		if (llc->laddr.lsap != laddr->lsap)
-			continue;
-
-		if (llc->dev != skb->dev)
+		if (!llc_mcast_match(sap, laddr, skb, sk))
 			continue;
 
 		skb1 = skb_clone(skb, GFP_ATOMIC);
@@ -365,7 +385,7 @@ static void llc_sap_mcast(struct llc_sap *sap,
 		llc_sap_rcv(sap, skb1, sk);
 		sock_put(sk);
 	}
-	read_unlock_bh(&sap->sk_list.lock);
+	spin_unlock_bh(&sap->sk_lock);
 }
 
 
-- 
1.5.6.5

