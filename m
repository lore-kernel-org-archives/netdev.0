From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC PATCH] llc: convert the socket list to RCU locking (was Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast delivery)
Date: Tue, 8 Dec 2009 23:10:45 +0200
Message-ID: <200912082310.45846.opurdila@ixiacom.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <200912040130.54966.opurdila@ixiacom.com> <4B184F4C.3060407@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:8503 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S966180AbZLHVNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 16:13:54 -0500
In-Reply-To: <4B184F4C.3060407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 December 2009 01:52:44 you wrote:

> > Since at this point we are using UP ports contention is not really an
> > issue for us. I've extrapolated this (lock per hash bucket) based on how
> > locking is done in other places, like UDP.
> 
> Yes but you know we want to remove those locks per UDP hash bucket, since
>  we dont really need them anymore. ;)
> 
> 
> If you remember, we had in the past one rwlock for the whole UDP table.
> 
> Then this was converted to one spinlock per hash slot (128 slots) + RCU
>  lookups for unicast RX
> 
> Then we dynamically sized udp table at boot (up to 65536 slots)
> 
> multicast optimization (holding lock for small duration + double hashing)
> 
> bind optimization (thanks to double hashing)
> 
> To be done :
> 
> 1) multicast RX can be done without taking any lock, and RCU lookups
> 2) zap all locks and use one lock, or a small array of hashed spinlocks
> 

OK, here is my first try at llc RCU-fication. 

One doubt before pasting the code: In slab.h comment and in udp.c I see the lookup is restarted if an improper object is returned. Is that really required?

Thanks!
tavi
 
[RFC PATCH] llc: convert the socket list to RCU locking
    
For the reclamation phase we use the SLAB_DESTROY_BY_RCU mechanism,
which require some extra checks in the lookup code:
    
a) Since socket can be free while looking it up, or getting a
reference to it, we need to check the socket reference counter to make
sure the reference we got points to a live socket
    
b) It can also happen that the reference we got during lookup will be
freed and the memory reused by another socket. Thus, after getting the
reference, we must check again that we got the right socket.
    
Note that the /proc code was not yet converted to RCU, it still uses
spinlocks for protection.
    
Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/llc.h  |    7 ++--
 net/llc/af_llc.c   |    1 +
 net/llc/llc_conn.c |   89 ++++++++++++++++++++++++++++++++++------------------
 net/llc/llc_core.c |    5 ++-
 net/llc/llc_proc.c |   20 ++++++------
 net/llc/llc_sap.c  |   72 ++++++++++++++++++++++++++++-------------
 6 files changed, 124 insertions(+), 70 deletions(-)

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
index ffc96d3..baefb4f 100644
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
index c6bab39..8331fc8 100644
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
@@ -484,23 +497,24 @@ static struct sock *__llc_lookup_established(struct llc_sap *sap,
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
+	sk_nulls_for_each_rcu(rc, node, &sap->sk_list) {
+		if (llc_estab_match(sap, daddr, laddr, rc)) {
+			/* Extra checks required by SLAB_DESTROY_BY_RCU */
+			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
+				continue;
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
 
@@ -516,6 +530,18 @@ struct sock *llc_lookup_established(struct llc_sap *sap,
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
@@ -530,23 +556,24 @@ static struct sock *llc_lookup_listener(struct llc_sap *sap,
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
+	sk_nulls_for_each_rcu(rc, node, &sap->sk_list) {
+		if (llc_listener_match(sap, laddr, rc)) {
+			/* Extra checks required by SLAB_DESTROY_BY_RCU */
+			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
+				continue;
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
 
@@ -652,10 +679,10 @@ static int llc_find_offset(int state, int ev_type)
 void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
 {
 	llc_sap_hold(sap);
-	write_lock_bh(&sap->sk_list.lock);
+	spin_lock_bh(&sap->sk_lock);
 	llc_sk(sk)->sap = sap;
-	sk_add_node(sk, &sap->sk_list.list);
-	write_unlock_bh(&sap->sk_list.lock);
+	sk_nulls_add_node_rcu(sk, &sap->sk_list);
+	spin_lock_bh(&sap->sk_lock);
 }
 
 /**
@@ -663,14 +690,14 @@ void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
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
index be47ac4..6546093 100644
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
@@ -80,18 +80,18 @@ static void *llc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
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
index 008de1f..655bbf8 100644
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
@@ -309,25 +320,39 @@ static struct sock *llc_lookup_dgram(struct llc_sap *sap,
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
+	sk_nulls_for_each_rcu(rc, node, &sap->sk_list) {
+		if (llc_dgram_match(sap, laddr, rc)) {
+			/* Extra checks required by SLAB_DESTROY_BY_RCU */
+			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
+				continue;
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
@@ -341,31 +366,32 @@ static void llc_sap_mcast(struct llc_sap *sap,
 			  struct sk_buff *skb)
 {
 	struct sock *sk;
-	struct hlist_node *node;
+	struct hlist_nulls_node *node;
 
-	read_lock_bh(&sap->sk_list.lock);
-	sk_for_each(sk, node, &sap->sk_list.list) {
-		struct llc_sock *llc = llc_sk(sk);
+	rcu_read_lock_bh();
+	sk_nulls_for_each_rcu(sk, node, &sap->sk_list) {
 		struct sk_buff *skb1;
 
-		if (sk->sk_type != SOCK_DGRAM)
+		if (!llc_mcast_match(sap, laddr, skb, sk))
 			continue;
-
-		if (llc->laddr.lsap != laddr->lsap)
+		/* Extra checks required by SLAB_DESTROY_BY_RCU */
+		if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
 			continue;
-
-		if (llc->dev != skb->dev)
+		if (unlikely(!llc_mcast_match(sap, laddr, skb, sk))) {
+			sock_put(sk);
 			continue;
+		}
 
 		skb1 = skb_clone(skb, GFP_ATOMIC);
-		if (!skb1)
+		if (!skb1) {
+			sock_put(sk);
 			break;
+		}
 
-		sock_hold(sk);
 		llc_sap_rcv(sap, skb1, sk);
 		sock_put(sk);
 	}
-	read_unlock_bh(&sap->sk_list.lock);
+	rcu_read_unlock_bh();
 }
 
 

