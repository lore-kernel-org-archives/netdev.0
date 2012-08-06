From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 2/9] sctp: Make the endpoint hashtable handle multiple network namespaces
Date: Mon, 06 Aug 2012 11:40:21 -0700
Message-ID: <87obmnq2y2.fsf_-_@xmission.com>
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
- Use sock_net(endpoint.base.sk) in the endpoint lookups.
- On receive calculate the network namespace from skb->dev.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/sctp/sctp.h    |    4 ++--
 include/net/sctp/structs.h |    2 +-
 net/sctp/endpointola.c     |    4 +++-
 net/sctp/input.c           |   19 ++++++++++++-------
 4 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 7c05040..87b119f 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -638,9 +638,9 @@ static inline int sctp_phashfn(struct net *net, __u16 lport)
 }
 
 /* This is the hash function for the endpoint hash table. */
-static inline int sctp_ep_hashfn(__u16 lport)
+static inline int sctp_ep_hashfn(struct net *net, __u16 lport)
 {
-	return lport & (sctp_ep_hashsize - 1);
+	return (net_hash_mix(net) + lport) & (sctp_ep_hashsize - 1);
 }
 
 /* This is the hash function for the association hash table. */
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index c089bb1..9f9de55 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1426,7 +1426,7 @@ struct sctp_association *sctp_endpoint_lookup_assoc(
 int sctp_endpoint_is_peeled_off(struct sctp_endpoint *,
 				const union sctp_addr *);
 struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *,
-					const union sctp_addr *);
+					struct net *, const union sctp_addr *);
 int sctp_has_association(const union sctp_addr *laddr,
 			 const union sctp_addr *paddr);
 
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 68a385d..50c87b4 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -302,11 +302,13 @@ void sctp_endpoint_put(struct sctp_endpoint *ep)
 
 /* Is this the endpoint we are looking for?  */
 struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *ep,
+					       struct net *net,
 					       const union sctp_addr *laddr)
 {
 	struct sctp_endpoint *retval = NULL;
 
-	if (htons(ep->base.bind_addr.port) == laddr->v4.sin_port) {
+	if ((htons(ep->base.bind_addr.port) == laddr->v4.sin_port) &&
+	    net_eq(sock_net(ep->base.sk), net)) {
 		if (sctp_bind_addr_match(&ep->base.bind_addr, laddr,
 					 sctp_sk(ep->base.sk)))
 			retval = ep;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index e64d521..c0ca893 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -70,7 +70,8 @@ static struct sctp_association *__sctp_rcv_lookup(struct sk_buff *skb,
 				      const union sctp_addr *laddr,
 				      const union sctp_addr *paddr,
 				      struct sctp_transport **transportp);
-static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(const union sctp_addr *laddr);
+static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net *net,
+						const union sctp_addr *laddr);
 static struct sctp_association *__sctp_lookup_association(
 					const union sctp_addr *local,
 					const union sctp_addr *peer,
@@ -129,6 +130,7 @@ int sctp_rcv(struct sk_buff *skb)
 	union sctp_addr dest;
 	int family;
 	struct sctp_af *af;
+	struct net *net = dev_net(skb->dev);
 
 	if (skb->pkt_type!=PACKET_HOST)
 		goto discard_it;
@@ -181,7 +183,7 @@ int sctp_rcv(struct sk_buff *skb)
 	asoc = __sctp_rcv_lookup(skb, &src, &dest, &transport);
 
 	if (!asoc)
-		ep = __sctp_rcv_lookup_endpoint(&dest);
+		ep = __sctp_rcv_lookup_endpoint(net, &dest);
 
 	/* Retrieve the common input handling substructure. */
 	rcvr = asoc ? &asoc->base : &ep->base;
@@ -723,12 +725,13 @@ discard:
 /* Insert endpoint into the hash table.  */
 static void __sctp_hash_endpoint(struct sctp_endpoint *ep)
 {
+	struct net *net = sock_net(ep->base.sk);
 	struct sctp_ep_common *epb;
 	struct sctp_hashbucket *head;
 
 	epb = &ep->base;
 
-	epb->hashent = sctp_ep_hashfn(epb->bind_addr.port);
+	epb->hashent = sctp_ep_hashfn(net, epb->bind_addr.port);
 	head = &sctp_ep_hashtable[epb->hashent];
 
 	sctp_write_lock(&head->lock);
@@ -747,12 +750,13 @@ void sctp_hash_endpoint(struct sctp_endpoint *ep)
 /* Remove endpoint from the hash table.  */
 static void __sctp_unhash_endpoint(struct sctp_endpoint *ep)
 {
+	struct net *net = sock_net(ep->base.sk);
 	struct sctp_hashbucket *head;
 	struct sctp_ep_common *epb;
 
 	epb = &ep->base;
 
-	epb->hashent = sctp_ep_hashfn(epb->bind_addr.port);
+	epb->hashent = sctp_ep_hashfn(net, epb->bind_addr.port);
 
 	head = &sctp_ep_hashtable[epb->hashent];
 
@@ -770,7 +774,8 @@ void sctp_unhash_endpoint(struct sctp_endpoint *ep)
 }
 
 /* Look up an endpoint. */
-static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(const union sctp_addr *laddr)
+static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net *net,
+						const union sctp_addr *laddr)
 {
 	struct sctp_hashbucket *head;
 	struct sctp_ep_common *epb;
@@ -778,12 +783,12 @@ static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(const union sctp_addr *l
 	struct hlist_node *node;
 	int hash;
 
-	hash = sctp_ep_hashfn(ntohs(laddr->v4.sin_port));
+	hash = sctp_ep_hashfn(net, ntohs(laddr->v4.sin_port));
 	head = &sctp_ep_hashtable[hash];
 	read_lock(&head->lock);
 	sctp_for_each_hentry(epb, node, &head->chain) {
 		ep = sctp_ep(epb);
-		if (sctp_endpoint_is_match(ep, laddr))
+		if (sctp_endpoint_is_match(ep, net, laddr))
 			goto hit;
 	}
 
-- 
1.7.5.4
