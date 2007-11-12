From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 09/14] SCTP: Convert custom hash lists to use hlist.
Date: Mon, 12 Nov 2007 11:38:24 -0500
Message-ID: <11948855161852-git-send-email-vladislav.yasevich@hp.com>
References: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:35609 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754277AbXKLQih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 11:38:37 -0500
In-Reply-To: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the custom hash list traversals to use hlist functions.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/sctp.h    |    3 +++
 include/net/sctp/structs.h |   10 ++++------
 net/sctp/endpointola.c     |    3 ++-
 net/sctp/input.c           |   43 +++++++++++--------------------------------
 net/sctp/proc.c            |    6 ++++--
 net/sctp/protocol.c        |    6 +++---
 net/sctp/socket.c          |   14 +++++---------
 7 files changed, 32 insertions(+), 53 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 7082730..67c997c 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -665,6 +665,9 @@ static inline int sctp_vtag_hashfn(__u16 lport, __u16 rport, __u32 vtag)
 	return (h & (sctp_assoc_hashsize-1));
 }
 
+#define sctp_for_each_hentry(epb, node, head) \
+	hlist_for_each_entry(epb, node, head, node)
+
 /* Is a socket of this style? */
 #define sctp_style(sk, style) __sctp_style((sk), (SCTP_SOCKET_##style))
 static inline int __sctp_style(const struct sock *sk, sctp_socket_type_t style)
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 44f2672..eb3113c 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -100,20 +100,19 @@ struct crypto_hash;
 struct sctp_bind_bucket {
 	unsigned short	port;
 	unsigned short	fastreuse;
-	struct sctp_bind_bucket *next;
-	struct sctp_bind_bucket **pprev;
+	struct hlist_node	node;
 	struct hlist_head	owner;
 };
 
 struct sctp_bind_hashbucket {
 	spinlock_t	lock;
-	struct sctp_bind_bucket	*chain;
+	struct hlist_head	chain;
 };
 
 /* Used for hashing all associations.  */
 struct sctp_hashbucket {
 	rwlock_t	lock;
-	struct sctp_ep_common  *chain;
+	struct hlist_head	chain;
 } __attribute__((__aligned__(8)));
 
 
@@ -1230,8 +1229,7 @@ typedef enum {
 
 struct sctp_ep_common {
 	/* Fields to help us manage our entries in the hash tables. */
-	struct sctp_ep_common *next;
-	struct sctp_ep_common **pprev;
+	struct hlist_node node;
 	int hashent;
 
 	/* Runtime type information.  What kind of endpoint is this? */
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 68f0556..de6f505 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -332,6 +332,7 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
 	struct sctp_transport *t = NULL;
 	struct sctp_hashbucket *head;
 	struct sctp_ep_common *epb;
+	struct hlist_node *node;
 	int hash;
 	int rport;
 
@@ -341,7 +342,7 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
 	hash = sctp_assoc_hashfn(ep->base.bind_addr.port, rport);
 	head = &sctp_assoc_hashtable[hash];
 	read_lock(&head->lock);
-	for (epb = head->chain; epb; epb = epb->next) {
+	sctp_for_each_hentry(epb, node, &head->chain) {
 		asoc = sctp_assoc(epb);
 		if (asoc->ep != ep || rport != asoc->peer.port)
 			goto next;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 86503e7..91ae463 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -656,7 +656,6 @@ discard:
 /* Insert endpoint into the hash table.  */
 static void __sctp_hash_endpoint(struct sctp_endpoint *ep)
 {
-	struct sctp_ep_common **epp;
 	struct sctp_ep_common *epb;
 	struct sctp_hashbucket *head;
 
@@ -666,12 +665,7 @@ static void __sctp_hash_endpoint(struct sctp_endpoint *ep)
 	head = &sctp_ep_hashtable[epb->hashent];
 
 	sctp_write_lock(&head->lock);
-	epp = &head->chain;
-	epb->next = *epp;
-	if (epb->next)
-		(*epp)->pprev = &epb->next;
-	*epp = epb;
-	epb->pprev = epp;
+	hlist_add_head(&epb->node, &head->chain);
 	sctp_write_unlock(&head->lock);
 }
 
@@ -691,19 +685,15 @@ static void __sctp_unhash_endpoint(struct sctp_endpoint *ep)
 
 	epb = &ep->base;
 
+	if (hlist_unhashed(&epb->node))
+		return;
+
 	epb->hashent = sctp_ep_hashfn(epb->bind_addr.port);
 
 	head = &sctp_ep_hashtable[epb->hashent];
 
 	sctp_write_lock(&head->lock);
-
-	if (epb->pprev) {
-		if (epb->next)
-			epb->next->pprev = epb->pprev;
-		*epb->pprev = epb->next;
-		epb->pprev = NULL;
-	}
-
+	__hlist_del(&epb->node);
 	sctp_write_unlock(&head->lock);
 }
 
@@ -721,12 +711,13 @@ static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(const union sctp_addr *l
 	struct sctp_hashbucket *head;
 	struct sctp_ep_common *epb;
 	struct sctp_endpoint *ep;
+	struct hlist_node *node;
 	int hash;
 
 	hash = sctp_ep_hashfn(ntohs(laddr->v4.sin_port));
 	head = &sctp_ep_hashtable[hash];
 	read_lock(&head->lock);
-	for (epb = head->chain; epb; epb = epb->next) {
+	sctp_for_each_hentry(epb, node, &head->chain) {
 		ep = sctp_ep(epb);
 		if (sctp_endpoint_is_match(ep, laddr))
 			goto hit;
@@ -744,7 +735,6 @@ hit:
 /* Insert association into the hash table.  */
 static void __sctp_hash_established(struct sctp_association *asoc)
 {
-	struct sctp_ep_common **epp;
 	struct sctp_ep_common *epb;
 	struct sctp_hashbucket *head;
 
@@ -756,12 +746,7 @@ static void __sctp_hash_established(struct sctp_association *asoc)
 	head = &sctp_assoc_hashtable[epb->hashent];
 
 	sctp_write_lock(&head->lock);
-	epp = &head->chain;
-	epb->next = *epp;
-	if (epb->next)
-		(*epp)->pprev = &epb->next;
-	*epp = epb;
-	epb->pprev = epp;
+	hlist_add_head(&epb->node, &head->chain);
 	sctp_write_unlock(&head->lock);
 }
 
@@ -790,14 +775,7 @@ static void __sctp_unhash_established(struct sctp_association *asoc)
 	head = &sctp_assoc_hashtable[epb->hashent];
 
 	sctp_write_lock(&head->lock);
-
-	if (epb->pprev) {
-		if (epb->next)
-			epb->next->pprev = epb->pprev;
-		*epb->pprev = epb->next;
-		epb->pprev = NULL;
-	}
-
+	__hlist_del(&epb->node);
 	sctp_write_unlock(&head->lock);
 }
 
@@ -822,6 +800,7 @@ static struct sctp_association *__sctp_lookup_association(
 	struct sctp_ep_common *epb;
 	struct sctp_association *asoc;
 	struct sctp_transport *transport;
+	struct hlist_node *node;
 	int hash;
 
 	/* Optimize here for direct hit, only listening connections can
@@ -830,7 +809,7 @@ static struct sctp_association *__sctp_lookup_association(
 	hash = sctp_assoc_hashfn(ntohs(local->v4.sin_port), ntohs(peer->v4.sin_port));
 	head = &sctp_assoc_hashtable[hash];
 	read_lock(&head->lock);
-	for (epb = head->chain; epb; epb = epb->next) {
+	sctp_for_each_hentry(epb, node, &head->chain) {
 		asoc = sctp_assoc(epb);
 		transport = sctp_assoc_is_match(asoc, local, peer);
 		if (transport)
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index e4cd841..2499732 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -225,6 +225,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 	struct sctp_ep_common *epb;
 	struct sctp_endpoint *ep;
 	struct sock *sk;
+	struct hlist_node *node;
 	int    hash = *(loff_t *)v;
 
 	if (hash >= sctp_ep_hashsize)
@@ -233,7 +234,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 	head = &sctp_ep_hashtable[hash];
 	sctp_local_bh_disable();
 	read_lock(&head->lock);
-	for (epb = head->chain; epb; epb = epb->next) {
+	sctp_for_each_hentry(epb, node, &head->chain) {
 		ep = sctp_ep(epb);
 		sk = epb->sk;
 		seq_printf(seq, "%8p %8p %-3d %-3d %-4d %-5d %5d %5lu ", ep, sk,
@@ -328,6 +329,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 	struct sctp_ep_common *epb;
 	struct sctp_association *assoc;
 	struct sock *sk;
+	struct hlist_node *node;
 	int    hash = *(loff_t *)v;
 
 	if (hash >= sctp_assoc_hashsize)
@@ -336,7 +338,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 	head = &sctp_assoc_hashtable[hash];
 	sctp_local_bh_disable();
 	read_lock(&head->lock);
-	for (epb = head->chain; epb; epb = epb->next) {
+	sctp_for_each_hentry(epb, node, &head->chain) {
 		assoc = sctp_assoc(epb);
 		sk = epb->sk;
 		seq_printf(seq,
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index ecfab03..d50f610 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1137,7 +1137,7 @@ SCTP_STATIC __init int sctp_init(void)
 	}
 	for (i = 0; i < sctp_assoc_hashsize; i++) {
 		rwlock_init(&sctp_assoc_hashtable[i].lock);
-		sctp_assoc_hashtable[i].chain = NULL;
+		INIT_HLIST_HEAD(&sctp_assoc_hashtable[i].chain);
 	}
 
 	/* Allocate and initialize the endpoint hash table.  */
@@ -1151,7 +1151,7 @@ SCTP_STATIC __init int sctp_init(void)
 	}
 	for (i = 0; i < sctp_ep_hashsize; i++) {
 		rwlock_init(&sctp_ep_hashtable[i].lock);
-		sctp_ep_hashtable[i].chain = NULL;
+		INIT_HLIST_HEAD(&sctp_ep_hashtable[i].chain);
 	}
 
 	/* Allocate and initialize the SCTP port hash table.  */
@@ -1170,7 +1170,7 @@ SCTP_STATIC __init int sctp_init(void)
 	}
 	for (i = 0; i < sctp_port_hashsize; i++) {
 		spin_lock_init(&sctp_port_hashtable[i].lock);
-		sctp_port_hashtable[i].chain = NULL;
+		INIT_HLIST_HEAD(&sctp_port_hashtable[i].chain);
 	}
 
 	printk(KERN_INFO "SCTP: Hash tables configured "
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 6ce9b49..ff8bc95 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5307,6 +5307,7 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 {
 	struct sctp_bind_hashbucket *head; /* hash list */
 	struct sctp_bind_bucket *pp; /* hash list port iterator */
+	struct hlist_node *node;
 	unsigned short snum;
 	int ret;
 
@@ -5331,7 +5332,7 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 			index = sctp_phashfn(rover);
 			head = &sctp_port_hashtable[index];
 			sctp_spin_lock(&head->lock);
-			for (pp = head->chain; pp; pp = pp->next)
+			sctp_for_each_hentry(pp, node, &head->chain)
 				if (pp->port == rover)
 					goto next;
 			break;
@@ -5358,7 +5359,7 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 		 */
 		head = &sctp_port_hashtable[sctp_phashfn(snum)];
 		sctp_spin_lock(&head->lock);
-		for (pp = head->chain; pp; pp = pp->next) {
+		sctp_for_each_hentry(pp, node, &head->chain) {
 			if (pp->port == snum)
 				goto pp_found;
 		}
@@ -5702,10 +5703,7 @@ static struct sctp_bind_bucket *sctp_bucket_create(
 		pp->port = snum;
 		pp->fastreuse = 0;
 		INIT_HLIST_HEAD(&pp->owner);
-		if ((pp->next = head->chain) != NULL)
-			pp->next->pprev = &pp->next;
-		head->chain = pp;
-		pp->pprev = &head->chain;
+		hlist_add_head(&pp->node, &head->chain);
 	}
 	return pp;
 }
@@ -5714,9 +5712,7 @@ static struct sctp_bind_bucket *sctp_bucket_create(
 static void sctp_bucket_destroy(struct sctp_bind_bucket *pp)
 {
 	if (pp && hlist_empty(&pp->owner)) {
-		if (pp->next)
-			pp->next->pprev = pp->pprev;
-		*(pp->pprev) = pp->next;
+		__hlist_del(&pp->node);
 		kmem_cache_free(sctp_bucket_cachep, pp);
 		SCTP_DBG_OBJCNT_DEC(bind_bucket);
 	}
-- 
1.5.2.4

