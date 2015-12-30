From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 4/5] sctp: drop the old assoc hashtable of sctp
Date: Wed, 30 Dec 2015 23:50:49 +0800
Message-ID: <85d66441be7419a830ad75a5334d2c3b31c0bda6.1451490447.git.lucien.xin@gmail.com>
References: <cover.1451490447.git.lucien.xin@gmail.com>
 <2c413161eb3a2c74453bd8dc11815af7e237515e.1451490447.git.lucien.xin@gmail.com>
 <8d89800920719b527dbd6e36dbbcf3c0804fbd7c.1451490447.git.lucien.xin@gmail.com>
 <8694e8698924a89a1dad097a3f1120d4b24443a1.1451490447.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, vyasevic@redhat.com, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33795 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbbL3PvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 10:51:15 -0500
In-Reply-To: <8694e8698924a89a1dad097a3f1120d4b24443a1.1451490447.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1451490447.git.lucien.xin@gmail.com>
References: <cover.1451490447.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

transport hashtable will replace the association hashtable,
so association hashtable is not used in sctp any more, so
drop the codes about that.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/sctp.h    | 21 ----------------
 include/net/sctp/structs.h |  5 ----
 net/sctp/input.c           | 61 ----------------------------------------------
 net/sctp/protocol.c        | 30 ++---------------------
 net/sctp/sm_sideeffect.c   |  2 --
 net/sctp/socket.c          |  6 +----
 6 files changed, 3 insertions(+), 122 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 7bbdfba..835aa2e 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -126,8 +126,6 @@ int sctp_primitive_ASCONF(struct net *, struct sctp_association *, void *arg);
  */
 int sctp_rcv(struct sk_buff *skb);
 void sctp_v4_err(struct sk_buff *skb, u32 info);
-void sctp_hash_established(struct sctp_association *);
-void sctp_unhash_established(struct sctp_association *);
 void sctp_hash_endpoint(struct sctp_endpoint *);
 void sctp_unhash_endpoint(struct sctp_endpoint *);
 struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *,
@@ -530,25 +528,6 @@ static inline int sctp_ep_hashfn(struct net *net, __u16 lport)
 	return (net_hash_mix(net) + lport) & (sctp_ep_hashsize - 1);
 }
 
-/* This is the hash function for the association hash table. */
-static inline int sctp_assoc_hashfn(struct net *net, __u16 lport, __u16 rport)
-{
-	int h = (lport << 16) + rport + net_hash_mix(net);
-	h ^= h>>8;
-	return h & (sctp_assoc_hashsize - 1);
-}
-
-/* This is the hash function for the association hash table.  This is
- * not used yet, but could be used as a better hash function when
- * we have a vtag.
- */
-static inline int sctp_vtag_hashfn(__u16 lport, __u16 rport, __u32 vtag)
-{
-	int h = (lport << 16) + rport;
-	h ^= vtag;
-	return h & (sctp_assoc_hashsize - 1);
-}
-
 #define sctp_for_each_hentry(epb, head) \
 	hlist_for_each_entry(epb, head, node)
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 4ab87d0..20e7212 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -120,8 +120,6 @@ extern struct sctp_globals {
 
 	/* This is the hash of all endpoints. */
 	struct sctp_hashbucket *ep_hashtable;
-	/* This is the hash of all associations. */
-	struct sctp_hashbucket *assoc_hashtable;
 	/* This is the sctp port control hash.	*/
 	struct sctp_bind_hashbucket *port_hashtable;
 	/* This is the hash of all transports. */
@@ -129,7 +127,6 @@ extern struct sctp_globals {
 
 	/* Sizes of above hashtables. */
 	int ep_hashsize;
-	int assoc_hashsize;
 	int port_hashsize;
 
 	/* Default initialization values to be applied to new associations. */
@@ -146,8 +143,6 @@ extern struct sctp_globals {
 #define sctp_address_families		(sctp_globals.address_families)
 #define sctp_ep_hashsize		(sctp_globals.ep_hashsize)
 #define sctp_ep_hashtable		(sctp_globals.ep_hashtable)
-#define sctp_assoc_hashsize		(sctp_globals.assoc_hashsize)
-#define sctp_assoc_hashtable		(sctp_globals.assoc_hashtable)
 #define sctp_port_hashsize		(sctp_globals.port_hashsize)
 #define sctp_port_hashtable		(sctp_globals.port_hashtable)
 #define sctp_transport_hashtable	(sctp_globals.transport_hashtable)
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 6f075d8..d9a6e66 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -913,67 +913,6 @@ struct sctp_transport *sctp_epaddr_lookup_transport(
 	return sctp_addrs_lookup_transport(net, &addr->a, paddr);
 }
 
-/* Insert association into the hash table.  */
-static void __sctp_hash_established(struct sctp_association *asoc)
-{
-	struct net *net = sock_net(asoc->base.sk);
-	struct sctp_ep_common *epb;
-	struct sctp_hashbucket *head;
-
-	epb = &asoc->base;
-
-	/* Calculate which chain this entry will belong to. */
-	epb->hashent = sctp_assoc_hashfn(net, epb->bind_addr.port,
-					 asoc->peer.port);
-
-	head = &sctp_assoc_hashtable[epb->hashent];
-
-	write_lock(&head->lock);
-	hlist_add_head(&epb->node, &head->chain);
-	write_unlock(&head->lock);
-}
-
-/* Add an association to the hash. Local BH-safe. */
-void sctp_hash_established(struct sctp_association *asoc)
-{
-	if (asoc->temp)
-		return;
-
-	local_bh_disable();
-	__sctp_hash_established(asoc);
-	local_bh_enable();
-}
-
-/* Remove association from the hash table.  */
-static void __sctp_unhash_established(struct sctp_association *asoc)
-{
-	struct net *net = sock_net(asoc->base.sk);
-	struct sctp_hashbucket *head;
-	struct sctp_ep_common *epb;
-
-	epb = &asoc->base;
-
-	epb->hashent = sctp_assoc_hashfn(net, epb->bind_addr.port,
-					 asoc->peer.port);
-
-	head = &sctp_assoc_hashtable[epb->hashent];
-
-	write_lock(&head->lock);
-	hlist_del_init(&epb->node);
-	write_unlock(&head->lock);
-}
-
-/* Remove association from the hash table.  Local BH-safe. */
-void sctp_unhash_established(struct sctp_association *asoc)
-{
-	if (asoc->temp)
-		return;
-
-	local_bh_disable();
-	__sctp_unhash_established(asoc);
-	local_bh_enable();
-}
-
 /* Look up an association. */
 static struct sctp_association *__sctp_lookup_association(
 					struct net *net,
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 631cfb3..ab0d538 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1416,24 +1416,6 @@ static __init int sctp_init(void)
 	for (order = 0; (1UL << order) < goal; order++)
 		;
 
-	do {
-		sctp_assoc_hashsize = (1UL << order) * PAGE_SIZE /
-					sizeof(struct sctp_hashbucket);
-		if ((sctp_assoc_hashsize > (64 * 1024)) && order > 0)
-			continue;
-		sctp_assoc_hashtable = (struct sctp_hashbucket *)
-			__get_free_pages(GFP_KERNEL | __GFP_NOWARN, order);
-	} while (!sctp_assoc_hashtable && --order > 0);
-	if (!sctp_assoc_hashtable) {
-		pr_err("Failed association hash alloc\n");
-		status = -ENOMEM;
-		goto err_ahash_alloc;
-	}
-	for (i = 0; i < sctp_assoc_hashsize; i++) {
-		rwlock_init(&sctp_assoc_hashtable[i].lock);
-		INIT_HLIST_HEAD(&sctp_assoc_hashtable[i].chain);
-	}
-
 	/* Allocate and initialize the endpoint hash table.  */
 	sctp_ep_hashsize = 64;
 	sctp_ep_hashtable =
@@ -1470,8 +1452,7 @@ static __init int sctp_init(void)
 	if (sctp_transport_hashtable_init())
 		goto err_thash_alloc;
 
-	pr_info("Hash tables configured (established %d bind %d)\n",
-		sctp_assoc_hashsize, sctp_port_hashsize);
+	pr_info("Hash tables configured (bind %d)\n", sctp_port_hashsize);
 
 	sctp_sysctl_register();
 
@@ -1528,10 +1509,6 @@ err_bhash_alloc:
 err_thash_alloc:
 	kfree(sctp_ep_hashtable);
 err_ehash_alloc:
-	free_pages((unsigned long)sctp_assoc_hashtable,
-		   get_order(sctp_assoc_hashsize *
-			     sizeof(struct sctp_hashbucket)));
-err_ahash_alloc:
 	percpu_counter_destroy(&sctp_sockets_allocated);
 err_percpu_counter_init:
 	kmem_cache_destroy(sctp_chunk_cachep);
@@ -1565,13 +1542,10 @@ static __exit void sctp_exit(void)
 
 	sctp_sysctl_unregister();
 
-	free_pages((unsigned long)sctp_assoc_hashtable,
-		   get_order(sctp_assoc_hashsize *
-			     sizeof(struct sctp_hashbucket)));
-	kfree(sctp_ep_hashtable);
 	free_pages((unsigned long)sctp_port_hashtable,
 		   get_order(sctp_port_hashsize *
 			     sizeof(struct sctp_bind_hashbucket)));
+	kfree(sctp_ep_hashtable);
 	sctp_transport_hashtable_destroy();
 
 	percpu_counter_destroy(&sctp_sockets_allocated);
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 05cd164..4f170ad 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -866,7 +866,6 @@ static void sctp_cmd_delete_tcb(sctp_cmd_seq_t *cmds,
 	    (!asoc->temp) && (sk->sk_shutdown != SHUTDOWN_MASK))
 		return;
 
-	sctp_unhash_established(asoc);
 	sctp_association_free(asoc);
 }
 
@@ -1269,7 +1268,6 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 			asoc = cmd->obj.asoc;
 			BUG_ON(asoc->peer.primary_path == NULL);
 			sctp_endpoint_add_asoc(ep, asoc);
-			sctp_hash_established(asoc);
 			break;
 
 		case SCTP_CMD_UPDATE_ASSOC:
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 2a1e8ba..523b9fa 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1228,7 +1228,6 @@ out_free:
 		 * To the hash table, try to unhash it, just in case, its a noop
 		 * if it wasn't hashed so we're safe
 		 */
-		sctp_unhash_established(asoc);
 		sctp_association_free(asoc);
 	}
 	return err;
@@ -1501,7 +1500,6 @@ static void sctp_close(struct sock *sk, long timeout)
 			 * ABORT or SHUTDOWN based on the linger options.
 			 */
 			if (sctp_state(asoc, CLOSED)) {
-				sctp_unhash_established(asoc);
 				sctp_association_free(asoc);
 				continue;
 			}
@@ -1984,10 +1982,8 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 	goto out_unlock;
 
 out_free:
-	if (new_asoc) {
-		sctp_unhash_established(asoc);
+	if (new_asoc)
 		sctp_association_free(asoc);
-	}
 out_unlock:
 	release_sock(sk);
 
-- 
2.1.0
