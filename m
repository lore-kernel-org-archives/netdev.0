From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: support global vtag assochash and per endpoint s(d)port assochash table
Date: Tue,  1 Sep 2015 01:44:28 +0800
Message-ID: <6d09d44f7972c5a5e458fc0eef98aa057896403d.1441043068.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, vyasevic@redhat.com, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35029 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755AbbHaRof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 13:44:35 -0400
Received: by pacdd16 with SMTP id dd16so146053411pac.2
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 10:44:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for telecom center, the usual case is that a server is connected by thousands
of clients. but if the server with only one enpoint(udp style) use the same
sport and dport to communicate with every clients, and every assoc in server
will be hashed in the same chain of global assoc hashtable due to currently we
choose dport and sport as the hash key.

when a packet is received, sctp_rcv try to find the assoc with sport and dport,
since that chain is too long to find it fast, it make the performance turn to
very low, some test data is as follow:

in server:
$./ss [start a udp server there]
in client:
$./cc [start 2500 sockets to connect server with same port and different ip,
       and use one of them to send data to server]

*spend time is 854s, send pkt is 10000000*

in server: #perf top
  46.60%  [kernel]                      [k] sctp_assoc_is_match
   8.81%  [kernel]                      [k] sctp_v4_cmp_addr
   5.15%  [kernel]                      [k] sctp_assoc_lookup_paddr
   ...

in client: #perf top
  88.42%  [kernel]                    [k] __sctp_endpoint_lookup_assoc
   2.06%  libnl-3.so.200.16.1         [.] nl_object_identical
   1.23%  libnl-3.so.200.16.1         [.] nl_addr_cmp
   ...

we need to change the way to calculate the hash key, vtag is good value for
that, insteading the sport and dport. this way can work well for looking for
assoc in sctp_rcv.
becides,  for the clients, if we turn the dport and sport global hash to per
endpoint's, which can make sctp_sendmsg look up assoc more quickly.

after that, the data of the same test is:

*spend time is 25s, send pkt is 10000000*

in server: #perf top
   9.92%  libnl-3.so.200.16.1         [.] nl_object_identical
   6.05%  libnl-3.so.200.16.1         [.] nl_addr_cmp
   4.72%  libc-2.17.so                [.] __memcmp_sse2
   ...

in client: #perf top
   6.79%  libc-2.17.so                [.] __libc_calloc
   6.50%  [kernel]                    [k] memcpy
   6.35%  libc-2.17.so                [.] _int_free
   ...

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h    |   8 +--
 include/net/sctp/structs.h |   8 ++-
 net/sctp/endpointola.c     |  22 +++++--
 net/sctp/input.c           | 160 +++++++++++++++++++++++++++++----------------
 4 files changed, 129 insertions(+), 69 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index ce13cf2..df14452 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -524,18 +524,16 @@ static inline int sctp_assoc_hashfn(struct net *net, __u16 lport, __u16 rport)
 {
 	int h = (lport << 16) + rport + net_hash_mix(net);
 	h ^= h>>8;
-	return h & (sctp_assoc_hashsize - 1);
+	return h & (256 - 1);
 }
 
 /* This is the hash function for the association hash table.  This is
  * not used yet, but could be used as a better hash function when
  * we have a vtag.
  */
-static inline int sctp_vtag_hashfn(__u16 lport, __u16 rport, __u32 vtag)
+static inline int sctp_vtag_hashfn(struct net *net, __u32 vtag)
 {
-	int h = (lport << 16) + rport;
-	h ^= vtag;
-	return h & (sctp_assoc_hashsize - 1);
+	return vtag & (sctp_assoc_hashsize - 1);
 }
 
 #define sctp_for_each_hentry(epb, head) \
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 495c87e..e0edfed 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1150,6 +1150,9 @@ struct sctp_ep_common {
 	struct hlist_node node;
 	int hashent;
 
+	struct hlist_node node_ep;
+	int hashent_ep;
+
 	/* Runtime type information.  What kind of endpoint is this? */
 	sctp_endpoint_type_t type;
 
@@ -1210,6 +1213,8 @@ struct sctp_endpoint {
 	/* This is really a list of struct sctp_association entries. */
 	struct list_head asocs;
 
+	struct sctp_hashbucket *asocshash;
+
 	/* Secret Key: A secret key used by this endpoint to compute
 	 *	      the MAC.	This SHOULD be a cryptographic quality
 	 *	      random number with a sufficient length.
@@ -1272,7 +1277,8 @@ int sctp_endpoint_is_peeled_off(struct sctp_endpoint *,
 				const union sctp_addr *);
 struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *,
 					struct net *, const union sctp_addr *);
-int sctp_has_association(struct net *net, const union sctp_addr *laddr,
+int sctp_has_association(struct net *net, struct sctp_endpoint *ep,
+			 const union sctp_addr *laddr,
 			 const union sctp_addr *paddr);
 
 int sctp_verify_init(struct net *net, const struct sctp_endpoint *ep,
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 9da76ba..adcaded 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -62,7 +62,7 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 	struct sctp_hmac_algo_param *auth_hmacs = NULL;
 	struct sctp_chunks_param *auth_chunks = NULL;
 	struct sctp_shared_key *null_key;
-	int err;
+	int err, i;
 
 	ep->digest = kzalloc(SCTP_SIGNATURE_SIZE, gfp);
 	if (!ep->digest)
@@ -133,6 +133,16 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 	/* Create the lists of associations.  */
 	INIT_LIST_HEAD(&ep->asocs);
 
+	/* Create hash table of associations. */
+	ep->asocshash = kmalloc(256 * sizeof(struct sctp_hashbucket), gfp);
+	if (!ep->asocshash)
+		goto nomem_asocshash;
+
+	for (i = 0; i < 256; i++) {
+		rwlock_init(&ep->asocshash[i].lock);
+		INIT_HLIST_HEAD(&ep->asocshash[i].chain);
+	}
+
 	/* Use SCTP specific send buffer space queues.  */
 	ep->sndbuf_policy = net->sctp.sndbuf_policy;
 
@@ -170,12 +180,13 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 nomem_hmacs:
 	sctp_auth_destroy_keys(&ep->endpoint_shared_keys);
 nomem:
+	kfree(ep->asocshash);
+nomem_asocshash:
 	/* Free all allocations */
 	kfree(auth_hmacs);
 	kfree(auth_chunks);
 	kfree(ep->digest);
 	return NULL;
-
 }
 
 /* Create a sctp_endpoint with all that boring stuff initialized.
@@ -342,9 +353,9 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
 
 	hash = sctp_assoc_hashfn(sock_net(ep->base.sk), ep->base.bind_addr.port,
 				 rport);
-	head = &sctp_assoc_hashtable[hash];
+	head = &ep->asocshash[hash];
 	read_lock(&head->lock);
-	sctp_for_each_hentry(epb, &head->chain) {
+	hlist_for_each_entry(epb, &head->chain, node_ep) {
 		tmp = sctp_assoc(epb);
 		if (tmp->ep != ep || rport != tmp->peer.port)
 			continue;
@@ -356,6 +367,7 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
 			break;
 		}
 	}
+
 	read_unlock(&head->lock);
 out:
 	return asoc;
@@ -391,7 +403,7 @@ int sctp_endpoint_is_peeled_off(struct sctp_endpoint *ep,
 	 * so the address_list can not change.
 	 */
 	list_for_each_entry(addr, &bp->address_list, list) {
-		if (sctp_has_association(net, &addr->a, paddr))
+		if (sctp_has_association(net, ep, &addr->a, paddr))
 			return 1;
 	}
 
diff --git a/net/sctp/input.c b/net/sctp/input.c
index b6493b3..48dc724 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -59,18 +59,26 @@
 
 /* Forward declarations for internal helpers. */
 static int sctp_rcv_ootb(struct sk_buff *);
-static struct sctp_association *__sctp_rcv_lookup(struct net *net,
-				      struct sk_buff *skb,
-				      const union sctp_addr *paddr,
-				      const union sctp_addr *laddr,
-				      struct sctp_transport **transportp);
 static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net *net,
 						const union sctp_addr *laddr);
-static struct sctp_association *__sctp_lookup_association(
+static struct sctp_association *__sctp_vtag_lookup_assoc(
 					struct net *net,
+					__u32 vtag,
 					const union sctp_addr *local,
 					const union sctp_addr *peer,
 					struct sctp_transport **pt);
+static struct sctp_association *__sctp_addrep_lookup_assoc(
+					struct net *net,
+					struct sctp_endpoint *ep,
+					const union sctp_addr *local,
+					const union sctp_addr *peer,
+					struct sctp_transport **pt);
+static struct sctp_association *__sctp_rcv_lookup_harder(
+					struct net *net,
+					struct sk_buff *skb,
+					struct sctp_endpoint *ep,
+					const union sctp_addr *laddr,
+					struct sctp_transport **transportp);
 
 static int sctp_add_backlog(struct sock *sk, struct sk_buff *skb);
 
@@ -107,7 +115,7 @@ struct sctp_input_cb {
 int sctp_rcv(struct sk_buff *skb)
 {
 	struct sock *sk;
-	struct sctp_association *asoc;
+	struct sctp_association *asoc = NULL;
 	struct sctp_endpoint *ep = NULL;
 	struct sctp_ep_common *rcvr;
 	struct sctp_transport *transport = NULL;
@@ -171,11 +179,21 @@ int sctp_rcv(struct sk_buff *skb)
 	    !af->addr_valid(&dest, NULL, skb))
 		goto discard_it;
 
-	asoc = __sctp_rcv_lookup(net, skb, &src, &dest, &transport);
+	if (sh->vtag)
+		asoc = __sctp_vtag_lookup_assoc(net, ntohl(sh->vtag), &dest,
+						&src, &transport);
 
-	if (!asoc)
+	if (!asoc) {
 		ep = __sctp_rcv_lookup_endpoint(net, &dest);
 
+		asoc = __sctp_addrep_lookup_assoc(net, ep, &dest,
+						  &src, &transport);
+		if (!asoc)
+			asoc = __sctp_rcv_lookup_harder(net, skb, ep, &dest,
+							&transport);
+		if (asoc)
+			sctp_endpoint_put(ep);
+	}
 	/* Retrieve the common input handling substructure. */
 	rcvr = asoc ? &asoc->base : &ep->base;
 	sk = rcvr->sk;
@@ -476,7 +494,8 @@ struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
 	union sctp_addr daddr;
 	struct sctp_af *af;
 	struct sock *sk = NULL;
-	struct sctp_association *asoc;
+	struct sctp_association *asoc = NULL;
+	struct sctp_endpoint *ep;
 	struct sctp_transport *transport = NULL;
 	struct sctp_init_chunk *chunkhdr;
 	__u32 vtag = ntohl(sctphdr->vtag);
@@ -496,7 +515,15 @@ struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
 	/* Look for an association that matches the incoming ICMP error
 	 * packet.
 	 */
-	asoc = __sctp_lookup_association(net, &saddr, &daddr, &transport);
+	if (vtag)
+		asoc = __sctp_vtag_lookup_assoc(net, vtag, &saddr, &daddr,
+						&transport);
+	if (!asoc) {
+		ep = __sctp_rcv_lookup_endpoint(net, &saddr);
+		asoc = __sctp_addrep_lookup_assoc(net, ep, &saddr, &saddr,
+						  &transport);
+		sctp_endpoint_put(ep);
+	}
 	if (!asoc)
 		return NULL;
 
@@ -792,14 +819,22 @@ static void __sctp_hash_established(struct sctp_association *asoc)
 	epb = &asoc->base;
 
 	/* Calculate which chain this entry will belong to. */
-	epb->hashent = sctp_assoc_hashfn(net, epb->bind_addr.port,
-					 asoc->peer.port);
+	epb->hashent = sctp_vtag_hashfn(net, asoc->c.my_vtag);
 
 	head = &sctp_assoc_hashtable[epb->hashent];
 
 	write_lock(&head->lock);
 	hlist_add_head(&epb->node, &head->chain);
 	write_unlock(&head->lock);
+
+	/* add it to per endpoint hashtable*/
+	epb->hashent_ep = sctp_assoc_hashfn(net, epb->bind_addr.port,
+					       asoc->peer.port);
+	head = &asoc->ep->asocshash[epb->hashent_ep];
+
+	write_lock(&head->lock);
+	hlist_add_head(&epb->node_ep, &head->chain);
+	write_unlock(&head->lock);
 }
 
 /* Add an association to the hash. Local BH-safe. */
@@ -822,14 +857,22 @@ static void __sctp_unhash_established(struct sctp_association *asoc)
 
 	epb = &asoc->base;
 
-	epb->hashent = sctp_assoc_hashfn(net, epb->bind_addr.port,
-					 asoc->peer.port);
+	epb->hashent = sctp_vtag_hashfn(net, asoc->c.my_vtag);
 
 	head = &sctp_assoc_hashtable[epb->hashent];
 
 	write_lock(&head->lock);
 	hlist_del_init(&epb->node);
 	write_unlock(&head->lock);
+
+	/* del it from per endpoint hashtable */
+	epb->hashent_ep = sctp_assoc_hashfn(net, epb->bind_addr.port,
+					       asoc->peer.port);
+	head = &asoc->ep->asocshash[epb->hashent_ep];
+
+	write_lock(&head->lock);
+	hlist_del_init(&epb->node_ep);
+	write_unlock(&head->lock);
 }
 
 /* Remove association from the hash table.  Local BH-safe. */
@@ -843,9 +886,9 @@ void sctp_unhash_established(struct sctp_association *asoc)
 	local_bh_enable();
 }
 
-/* Look up an association. */
-static struct sctp_association *__sctp_lookup_association(
+static struct sctp_association *__sctp_vtag_lookup_assoc(
 					struct net *net,
+					__u32 vtag,
 					const union sctp_addr *local,
 					const union sctp_addr *peer,
 					struct sctp_transport **pt)
@@ -856,12 +899,9 @@ static struct sctp_association *__sctp_lookup_association(
 	struct sctp_transport *transport;
 	int hash;
 
-	/* Optimize here for direct hit, only listening connections can
-	 * have wildcards anyways.
-	 */
-	hash = sctp_assoc_hashfn(net, ntohs(local->v4.sin_port),
-				 ntohs(peer->v4.sin_port));
+	hash = sctp_vtag_hashfn(net, vtag);
 	head = &sctp_assoc_hashtable[hash];
+
 	read_lock(&head->lock);
 	sctp_for_each_hentry(epb, &head->chain) {
 		asoc = sctp_assoc(epb);
@@ -873,7 +913,6 @@ static struct sctp_association *__sctp_lookup_association(
 	read_unlock(&head->lock);
 
 	return NULL;
-
 hit:
 	*pt = transport;
 	sctp_association_hold(asoc);
@@ -881,31 +920,17 @@ hit:
 	return asoc;
 }
 
-/* Look up an association. BH-safe. */
-static
-struct sctp_association *sctp_lookup_association(struct net *net,
-						 const union sctp_addr *laddr,
-						 const union sctp_addr *paddr,
-						 struct sctp_transport **transportp)
-{
-	struct sctp_association *asoc;
-
-	local_bh_disable();
-	asoc = __sctp_lookup_association(net, laddr, paddr, transportp);
-	local_bh_enable();
-
-	return asoc;
-}
-
 /* Is there an association matching the given local and peer addresses? */
 int sctp_has_association(struct net *net,
+			 struct sctp_endpoint *ep,
 			 const union sctp_addr *laddr,
 			 const union sctp_addr *paddr)
 {
 	struct sctp_association *asoc;
 	struct sctp_transport *transport;
 
-	if ((asoc = sctp_lookup_association(net, laddr, paddr, &transport))) {
+	asoc = __sctp_addrep_lookup_assoc(net, ep, laddr, paddr, &transport);
+	if (asoc) {
 		sctp_association_put(asoc);
 		return 1;
 	}
@@ -933,6 +958,7 @@ int sctp_has_association(struct net *net,
  */
 static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
 	struct sk_buff *skb,
+	struct sctp_endpoint *ep,
 	const union sctp_addr *laddr, struct sctp_transport **transportp)
 {
 	struct sctp_association *asoc;
@@ -972,7 +998,8 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
 
 		af->from_addr_param(paddr, params.addr, sh->source, 0);
 
-		asoc = __sctp_lookup_association(net, laddr, paddr, &transport);
+		asoc = __sctp_addrep_lookup_assoc(net, ep, laddr, paddr,
+						  &transport);
 		if (asoc)
 			return asoc;
 	}
@@ -997,6 +1024,7 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
 static struct sctp_association *__sctp_rcv_asconf_lookup(
 					struct net *net,
 					sctp_chunkhdr_t *ch,
+					struct sctp_endpoint *ep,
 					const union sctp_addr *laddr,
 					__be16 peer_port,
 					struct sctp_transport **transportp)
@@ -1015,7 +1043,7 @@ static struct sctp_association *__sctp_rcv_asconf_lookup(
 
 	af->from_addr_param(&paddr, param, peer_port, 0);
 
-	return __sctp_lookup_association(net, laddr, &paddr, transportp);
+	return __sctp_addrep_lookup_assoc(net, ep, laddr, &paddr, transportp);
 }
 
 
@@ -1030,6 +1058,7 @@ static struct sctp_association *__sctp_rcv_asconf_lookup(
 */
 static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
 				      struct sk_buff *skb,
+				      struct sctp_endpoint *ep,
 				      const union sctp_addr *laddr,
 				      struct sctp_transport **transportp)
 {
@@ -1072,7 +1101,7 @@ static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
 		case SCTP_CID_ASCONF:
 			if (have_auth || net->sctp.addip_noauth)
 				asoc = __sctp_rcv_asconf_lookup(
-						net, ch, laddr,
+						net, ch, ep, laddr,
 						sctp_hdr(skb)->source,
 						transportp);
 		default:
@@ -1097,6 +1126,7 @@ static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
  */
 static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
 				      struct sk_buff *skb,
+				      struct sctp_endpoint *ep,
 				      const union sctp_addr *laddr,
 				      struct sctp_transport **transportp)
 {
@@ -1114,28 +1144,42 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
 
 	/* If this is INIT/INIT-ACK look inside the chunk too. */
 	if (ch->type == SCTP_CID_INIT || ch->type == SCTP_CID_INIT_ACK)
-		return __sctp_rcv_init_lookup(net, skb, laddr, transportp);
+		return __sctp_rcv_init_lookup(net, skb, ep, laddr, transportp);
 
-	return __sctp_rcv_walk_lookup(net, skb, laddr, transportp);
+	return __sctp_rcv_walk_lookup(net, skb, ep, laddr, transportp);
 }
 
-/* Lookup an association for an inbound skb. */
-static struct sctp_association *__sctp_rcv_lookup(struct net *net,
-				      struct sk_buff *skb,
-				      const union sctp_addr *paddr,
-				      const union sctp_addr *laddr,
-				      struct sctp_transport **transportp)
+static struct sctp_association *__sctp_addrep_lookup_assoc(
+					struct net *net,
+					struct sctp_endpoint *ep,
+					const union sctp_addr *local,
+					const union sctp_addr *peer,
+					struct sctp_transport **pt)
 {
+	struct sctp_hashbucket *head;
+	struct sctp_ep_common *epb;
 	struct sctp_association *asoc;
+	struct sctp_transport *transport;
+	int hash;
 
-	asoc = __sctp_lookup_association(net, laddr, paddr, transportp);
+	hash = sctp_assoc_hashfn(net, ntohs(local->v4.sin_port),
+				 ntohs(peer->v4.sin_port));
+	head = &ep->asocshash[hash];
 
-	/* Further lookup for INIT/INIT-ACK packets.
-	 * SCTP Implementors Guide, 2.18 Handling of address
-	 * parameters within the INIT or INIT-ACK.
-	 */
-	if (!asoc)
-		asoc = __sctp_rcv_lookup_harder(net, skb, laddr, transportp);
+	read_lock(&head->lock);
+	hlist_for_each_entry(epb, &head->chain, node_ep) {
+		asoc = sctp_assoc(epb);
+		transport = sctp_assoc_is_match(asoc, net, local, peer);
+		if (transport)
+			goto hit;
+	}
+
+	read_unlock(&head->lock);
 
+	return NULL;
+hit:
+	*pt = transport;
+	sctp_association_hold(asoc);
+	read_unlock(&head->lock);
 	return asoc;
 }
-- 
2.1.0
