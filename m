From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 3/9] sctp: Make the association hashtable handle multiple network namespaces
Date: Mon, 06 Aug 2012 11:41:13 -0700
Message-ID: <87ipcvq2wm.fsf_-_@xmission.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com>
	<87mx27rig7.fsf@xmission.com> <87zk67q31q.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Ariyasu <jan.ariyasu@hp.com>,
	Jan Ariyasu <jan.ariyasu@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>, Xi Wang <xi.wang@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87zk67q31q.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 06 Aug 2012 11:38:09 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- Use struct net in the hash calculation
- Use sock_net(association.base.sk) in the association lookups.
- On receive calculate the network namespace from skb->dev.
- Pass struct net from receive down to the functions that actually
  do the association lookup.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/sctp/sctp.h    |    6 ++--
 include/net/sctp/structs.h |    3 +-
 net/sctp/associola.c       |    4 ++-
 net/sctp/endpointola.c     |    6 +++-
 net/sctp/input.c           |   64 +++++++++++++++++++++++++++----------------
 net/sctp/ipv6.c            |    3 +-
 6 files changed, 54 insertions(+), 32 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 87b119f..640915a 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -156,7 +156,7 @@ void sctp_hash_established(struct sctp_association *);
 void sctp_unhash_established(struct sctp_association *);
 void sctp_hash_endpoint(struct sctp_endpoint *);
 void sctp_unhash_endpoint(struct sctp_endpoint *);
-struct sock *sctp_err_lookup(int family, struct sk_buff *,
+struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *,
 			     struct sctphdr *, struct sctp_association **,
 			     struct sctp_transport **);
 void sctp_err_finish(struct sock *, struct sctp_association *);
@@ -644,9 +644,9 @@ static inline int sctp_ep_hashfn(struct net *net, __u16 lport)
 }
 
 /* This is the hash function for the association hash table. */
-static inline int sctp_assoc_hashfn(__u16 lport, __u16 rport)
+static inline int sctp_assoc_hashfn(struct net *net, __u16 lport, __u16 rport)
 {
-	int h = (lport << 16) + rport;
+	int h = (lport << 16) + rport + net_hash_mix(net);
 	h ^= h>>8;
 	return h & (sctp_assoc_hashsize - 1);
 }
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 9f9de55..c0563d1 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1427,7 +1427,7 @@ int sctp_endpoint_is_peeled_off(struct sctp_endpoint *,
 				const union sctp_addr *);
 struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *,
 					struct net *, const union sctp_addr *);
-int sctp_has_association(const union sctp_addr *laddr,
+int sctp_has_association(struct net *net, const union sctp_addr *laddr,
 			 const union sctp_addr *paddr);
 
 int sctp_verify_init(const struct sctp_association *asoc, sctp_cid_t,
@@ -2014,6 +2014,7 @@ void sctp_assoc_control_transport(struct sctp_association *,
 				  sctp_transport_cmd_t, sctp_sn_error_t);
 struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association *, __u32);
 struct sctp_transport *sctp_assoc_is_match(struct sctp_association *,
+					   struct net *,
 					   const union sctp_addr *,
 					   const union sctp_addr *);
 void sctp_assoc_migrate(struct sctp_association *, struct sock *);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index ebaef3e..a3601f3 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1089,13 +1089,15 @@ out:
 
 /* Is this the association we are looking for? */
 struct sctp_transport *sctp_assoc_is_match(struct sctp_association *asoc,
+					   struct net *net,
 					   const union sctp_addr *laddr,
 					   const union sctp_addr *paddr)
 {
 	struct sctp_transport *transport;
 
 	if ((htons(asoc->base.bind_addr.port) == laddr->v4.sin_port) &&
-	    (htons(asoc->peer.port) == paddr->v4.sin_port)) {
+	    (htons(asoc->peer.port) == paddr->v4.sin_port) &&
+	    net_eq(sock_net(asoc->base.sk), net)) {
 		transport = sctp_assoc_lookup_paddr(asoc, paddr);
 		if (!transport)
 			goto out;
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 50c87b4..6b76393 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -345,7 +345,8 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
 
 	rport = ntohs(paddr->v4.sin_port);
 
-	hash = sctp_assoc_hashfn(ep->base.bind_addr.port, rport);
+	hash = sctp_assoc_hashfn(sock_net(ep->base.sk), ep->base.bind_addr.port,
+				 rport);
 	head = &sctp_assoc_hashtable[hash];
 	read_lock(&head->lock);
 	sctp_for_each_hentry(epb, node, &head->chain) {
@@ -388,13 +389,14 @@ int sctp_endpoint_is_peeled_off(struct sctp_endpoint *ep,
 {
 	struct sctp_sockaddr_entry *addr;
 	struct sctp_bind_addr *bp;
+	struct net *net = sock_net(ep->base.sk);
 
 	bp = &ep->base.bind_addr;
 	/* This function is called with the socket lock held,
 	 * so the address_list can not change.
 	 */
 	list_for_each_entry(addr, &bp->address_list, list) {
-		if (sctp_has_association(&addr->a, paddr))
+		if (sctp_has_association(net, &addr->a, paddr))
 			return 1;
 	}
 
diff --git a/net/sctp/input.c b/net/sctp/input.c
index c0ca893..a7e9a85 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -66,13 +66,15 @@
 
 /* Forward declarations for internal helpers. */
 static int sctp_rcv_ootb(struct sk_buff *);
-static struct sctp_association *__sctp_rcv_lookup(struct sk_buff *skb,
+static struct sctp_association *__sctp_rcv_lookup(struct net *net,
+				      struct sk_buff *skb,
 				      const union sctp_addr *laddr,
 				      const union sctp_addr *paddr,
 				      struct sctp_transport **transportp);
 static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net *net,
 						const union sctp_addr *laddr);
 static struct sctp_association *__sctp_lookup_association(
+					struct net *net,
 					const union sctp_addr *local,
 					const union sctp_addr *peer,
 					struct sctp_transport **pt);
@@ -180,7 +182,7 @@ int sctp_rcv(struct sk_buff *skb)
 	    !af->addr_valid(&dest, NULL, skb))
 		goto discard_it;
 
-	asoc = __sctp_rcv_lookup(skb, &src, &dest, &transport);
+	asoc = __sctp_rcv_lookup(net, skb, &src, &dest, &transport);
 
 	if (!asoc)
 		ep = __sctp_rcv_lookup_endpoint(net, &dest);
@@ -476,7 +478,7 @@ void sctp_icmp_proto_unreachable(struct sock *sk,
 }
 
 /* Common lookup code for icmp/icmpv6 error handler. */
-struct sock *sctp_err_lookup(int family, struct sk_buff *skb,
+struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
 			     struct sctphdr *sctphdr,
 			     struct sctp_association **app,
 			     struct sctp_transport **tpp)
@@ -505,7 +507,7 @@ struct sock *sctp_err_lookup(int family, struct sk_buff *skb,
 	/* Look for an association that matches the incoming ICMP error
 	 * packet.
 	 */
-	asoc = __sctp_lookup_association(&saddr, &daddr, &transport);
+	asoc = __sctp_lookup_association(net, &saddr, &daddr, &transport);
 	if (!asoc)
 		return NULL;
 
@@ -588,6 +590,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	struct inet_sock *inet;
 	sk_buff_data_t saveip, savesctp;
 	int err;
+	struct net *net = dev_net(skb->dev);
 
 	if (skb->len < ihlen + 8) {
 		ICMP_INC_STATS_BH(&init_net, ICMP_MIB_INERRORS);
@@ -599,7 +602,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	savesctp = skb->transport_header;
 	skb_reset_network_header(skb);
 	skb_set_transport_header(skb, ihlen);
-	sk = sctp_err_lookup(AF_INET, skb, sctp_hdr(skb), &asoc, &transport);
+	sk = sctp_err_lookup(net, AF_INET, skb, sctp_hdr(skb), &asoc, &transport);
 	/* Put back, the original values. */
 	skb->network_header = saveip;
 	skb->transport_header = savesctp;
@@ -803,13 +806,15 @@ hit:
 /* Insert association into the hash table.  */
 static void __sctp_hash_established(struct sctp_association *asoc)
 {
+	struct net *net = sock_net(asoc->base.sk);
 	struct sctp_ep_common *epb;
 	struct sctp_hashbucket *head;
 
 	epb = &asoc->base;
 
 	/* Calculate which chain this entry will belong to. */
-	epb->hashent = sctp_assoc_hashfn(epb->bind_addr.port, asoc->peer.port);
+	epb->hashent = sctp_assoc_hashfn(net, epb->bind_addr.port,
+					 asoc->peer.port);
 
 	head = &sctp_assoc_hashtable[epb->hashent];
 
@@ -832,12 +837,13 @@ void sctp_hash_established(struct sctp_association *asoc)
 /* Remove association from the hash table.  */
 static void __sctp_unhash_established(struct sctp_association *asoc)
 {
+	struct net *net = sock_net(asoc->base.sk);
 	struct sctp_hashbucket *head;
 	struct sctp_ep_common *epb;
 
 	epb = &asoc->base;
 
-	epb->hashent = sctp_assoc_hashfn(epb->bind_addr.port,
+	epb->hashent = sctp_assoc_hashfn(net, epb->bind_addr.port,
 					 asoc->peer.port);
 
 	head = &sctp_assoc_hashtable[epb->hashent];
@@ -860,6 +866,7 @@ void sctp_unhash_established(struct sctp_association *asoc)
 
 /* Look up an association. */
 static struct sctp_association *__sctp_lookup_association(
+					struct net *net,
 					const union sctp_addr *local,
 					const union sctp_addr *peer,
 					struct sctp_transport **pt)
@@ -874,12 +881,13 @@ static struct sctp_association *__sctp_lookup_association(
 	/* Optimize here for direct hit, only listening connections can
 	 * have wildcards anyways.
 	 */
-	hash = sctp_assoc_hashfn(ntohs(local->v4.sin_port), ntohs(peer->v4.sin_port));
+	hash = sctp_assoc_hashfn(net, ntohs(local->v4.sin_port),
+				 ntohs(peer->v4.sin_port));
 	head = &sctp_assoc_hashtable[hash];
 	read_lock(&head->lock);
 	sctp_for_each_hentry(epb, node, &head->chain) {
 		asoc = sctp_assoc(epb);
-		transport = sctp_assoc_is_match(asoc, local, peer);
+		transport = sctp_assoc_is_match(asoc, net, local, peer);
 		if (transport)
 			goto hit;
 	}
@@ -897,27 +905,29 @@ hit:
 
 /* Look up an association. BH-safe. */
 SCTP_STATIC
-struct sctp_association *sctp_lookup_association(const union sctp_addr *laddr,
+struct sctp_association *sctp_lookup_association(struct net *net,
+						 const union sctp_addr *laddr,
 						 const union sctp_addr *paddr,
 					    struct sctp_transport **transportp)
 {
 	struct sctp_association *asoc;
 
 	sctp_local_bh_disable();
-	asoc = __sctp_lookup_association(laddr, paddr, transportp);
+	asoc = __sctp_lookup_association(net, laddr, paddr, transportp);
 	sctp_local_bh_enable();
 
 	return asoc;
 }
 
 /* Is there an association matching the given local and peer addresses? */
-int sctp_has_association(const union sctp_addr *laddr,
+int sctp_has_association(struct net *net,
+			 const union sctp_addr *laddr,
 			 const union sctp_addr *paddr)
 {
 	struct sctp_association *asoc;
 	struct sctp_transport *transport;
 
-	if ((asoc = sctp_lookup_association(laddr, paddr, &transport))) {
+	if ((asoc = sctp_lookup_association(net, laddr, paddr, &transport))) {
 		sctp_association_put(asoc);
 		return 1;
 	}
@@ -943,7 +953,8 @@ int sctp_has_association(const union sctp_addr *laddr,
  * in certain circumstances.
  *
  */
-static struct sctp_association *__sctp_rcv_init_lookup(struct sk_buff *skb,
+static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
+	struct sk_buff *skb,
 	const union sctp_addr *laddr, struct sctp_transport **transportp)
 {
 	struct sctp_association *asoc;
@@ -983,7 +994,7 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct sk_buff *skb,
 
 		af->from_addr_param(paddr, params.addr, sh->source, 0);
 
-		asoc = __sctp_lookup_association(laddr, paddr, &transport);
+		asoc = __sctp_lookup_association(net, laddr, paddr, &transport);
 		if (asoc)
 			return asoc;
 	}
@@ -1006,6 +1017,7 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct sk_buff *skb,
  * subsequent ASCONF Chunks. If found, proceed to rule D4.
  */
 static struct sctp_association *__sctp_rcv_asconf_lookup(
+					struct net *net,
 					sctp_chunkhdr_t *ch,
 					const union sctp_addr *laddr,
 					__be16 peer_port,
@@ -1025,7 +1037,7 @@ static struct sctp_association *__sctp_rcv_asconf_lookup(
 
 	af->from_addr_param(&paddr, param, peer_port, 0);
 
-	return __sctp_lookup_association(laddr, &paddr, transportp);
+	return __sctp_lookup_association(net, laddr, &paddr, transportp);
 }
 
 
@@ -1038,7 +1050,8 @@ static struct sctp_association *__sctp_rcv_asconf_lookup(
 * This means that any chunks that can help us identify the association need
 * to be looked at to find this association.
 */
-static struct sctp_association *__sctp_rcv_walk_lookup(struct sk_buff *skb,
+static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
+				      struct sk_buff *skb,
 				      const union sctp_addr *laddr,
 				      struct sctp_transport **transportp)
 {
@@ -1080,7 +1093,8 @@ static struct sctp_association *__sctp_rcv_walk_lookup(struct sk_buff *skb,
 
 		    case SCTP_CID_ASCONF:
 			    if (have_auth || sctp_addip_noauth)
-				    asoc = __sctp_rcv_asconf_lookup(ch, laddr,
+				    asoc = __sctp_rcv_asconf_lookup(
+							net, ch, laddr,
 							sctp_hdr(skb)->source,
 							transportp);
 		    default:
@@ -1103,7 +1117,8 @@ static struct sctp_association *__sctp_rcv_walk_lookup(struct sk_buff *skb,
  * include looking inside of INIT/INIT-ACK chunks or after the AUTH
  * chunks.
  */
-static struct sctp_association *__sctp_rcv_lookup_harder(struct sk_buff *skb,
+static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
+				      struct sk_buff *skb,
 				      const union sctp_addr *laddr,
 				      struct sctp_transport **transportp)
 {
@@ -1123,11 +1138,11 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct sk_buff *skb,
 	switch (ch->type) {
 	case SCTP_CID_INIT:
 	case SCTP_CID_INIT_ACK:
-		return __sctp_rcv_init_lookup(skb, laddr, transportp);
+		return __sctp_rcv_init_lookup(net, skb, laddr, transportp);
 		break;
 
 	default:
-		return __sctp_rcv_walk_lookup(skb, laddr, transportp);
+		return __sctp_rcv_walk_lookup(net, skb, laddr, transportp);
 		break;
 	}
 
@@ -1136,21 +1151,22 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct sk_buff *skb,
 }
 
 /* Lookup an association for an inbound skb. */
-static struct sctp_association *__sctp_rcv_lookup(struct sk_buff *skb,
+static struct sctp_association *__sctp_rcv_lookup(struct net *net,
+				      struct sk_buff *skb,
 				      const union sctp_addr *paddr,
 				      const union sctp_addr *laddr,
 				      struct sctp_transport **transportp)
 {
 	struct sctp_association *asoc;
 
-	asoc = __sctp_lookup_association(laddr, paddr, transportp);
+	asoc = __sctp_lookup_association(net, laddr, paddr, transportp);
 
 	/* Further lookup for INIT/INIT-ACK packets.
 	 * SCTP Implementors Guide, 2.18 Handling of address
 	 * parameters within the INIT or INIT-ACK.
 	 */
 	if (!asoc)
-		asoc = __sctp_rcv_lookup_harder(skb, laddr, transportp);
+		asoc = __sctp_rcv_lookup_harder(net, skb, laddr, transportp);
 
 	return asoc;
 }
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index ed7139e..2165a7e 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -154,6 +154,7 @@ SCTP_STATIC void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct ipv6_pinfo *np;
 	sk_buff_data_t saveip, savesctp;
 	int err;
+	struct net *net = dev_net(skb->dev);
 
 	idev = in6_dev_get(skb->dev);
 
@@ -162,7 +163,7 @@ SCTP_STATIC void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	savesctp = skb->transport_header;
 	skb_reset_network_header(skb);
 	skb_set_transport_header(skb, offset);
-	sk = sctp_err_lookup(AF_INET6, skb, sctp_hdr(skb), &asoc, &transport);
+	sk = sctp_err_lookup(net, AF_INET6, skb, sctp_hdr(skb), &asoc, &transport);
 	/* Put back, the original pointers. */
 	skb->network_header   = saveip;
 	skb->transport_header = savesctp;
-- 
1.7.5.4
