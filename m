From: Steve Chen <schen@mvista.com>
Subject: [PATCH] Multicast packet reassembly can fail
Date: Tue, 27 Oct 2009 17:46:23 -0500
Message-ID: <1256683583.3153.389.camel@linux-1lbu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu47.mvista.com ([206.112.117.47]:41960 "HELO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1754107AbZJ0W6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 18:58:24 -0400
Received: from [127.0.0.1] (scjump.mvista.com [10.0.0.76])
	by hermes.mvista.com (Postfix) with ESMTP id DE0731C785
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2009 15:38:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multicast packet reassembly can fail

When multicast connections with multiple fragments are received by the same
node from more than one Ethernet ports, race condition between fragments
from each Ethernet port can cause fragment reassembly to fail leading to
packet drop.  This is because packets from each Ethernet port appears identical
to the the code that reassembles the Ethernet packet.

The solution is evaluate the Ethernet interface number in addition to all other
parameters so that every packet can be uniquely identified.  The existing
iif field in struct ipq is now used to generate the hash key, and iif is also
used for comparison in case of hash collision.

Please note that q->saddr ^ (q->iif << 5) is now being passed into
ipqhashfn to generate the hash key.  This is borrowed from the routing
code.

Signed-off-by: Steve Chen <schen@mvista.com>
Signed-off-by: Mark Huth <mhuth@mvista.com>

---

 net/ipv4/ip_fragment.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 575f9bd..2de0035 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -90,6 +90,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 struct ip4_create_arg {
 	struct iphdr *iph;
 	u32 user;
+	int iif;
 };
 
 static unsigned int ipqhashfn(__be16 id, __be32 saddr, __be32 daddr, u8 prot)
@@ -104,7 +105,8 @@ static unsigned int ip4_hashfn(struct inet_frag_queue *q)
 	struct ipq *ipq;
 
 	ipq = container_of(q, struct ipq, q);
-	return ipqhashfn(ipq->id, ipq->saddr, ipq->daddr, ipq->protocol);
+	return ipqhashfn(ipq->id, ipq->saddr ^ (ipq->iif << 5), ipq->daddr,
+			 ipq->protocol);
 }
 
 static int ip4_frag_match(struct inet_frag_queue *q, void *a)
@@ -117,6 +119,7 @@ static int ip4_frag_match(struct inet_frag_queue *q, void *a)
 			qp->saddr == arg->iph->saddr &&
 			qp->daddr == arg->iph->daddr &&
 			qp->protocol == arg->iph->protocol &&
+			qp->iif == arg->iif &&
 			qp->user == arg->user);
 }
 
@@ -140,6 +143,7 @@ static void ip4_frag_init(struct inet_frag_queue *q, void *a)
 	qp->saddr = arg->iph->saddr;
 	qp->daddr = arg->iph->daddr;
 	qp->user = arg->user;
+	qp->iif = arg->iif;
 	qp->peer = sysctl_ipfrag_max_dist ?
 		inet_getpeer(arg->iph->saddr, 1) : NULL;
 }
@@ -219,7 +223,8 @@ out:
 /* Find the correct entry in the "incomplete datagrams" queue for
  * this IP datagram, and create new one, if nothing is found.
  */
-static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
+static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user,
+				  int iif)
 {
 	struct inet_frag_queue *q;
 	struct ip4_create_arg arg;
@@ -227,9 +232,11 @@ static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 
 	arg.iph = iph;
 	arg.user = user;
+	arg.iif = iif;
 
 	read_lock(&ip4_frags.lock);
-	hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
+	hash = ipqhashfn(iph->id, iph->saddr & (iif << 5), iph->daddr,
+			 iph->protocol);
 
 	q = inet_frag_find(&net->ipv4.frags, &ip4_frags, &arg, hash);
 	if (q == NULL)
@@ -433,10 +440,9 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 		qp->q.fragments = skb;
 
 	dev = skb->dev;
-	if (dev) {
-		qp->iif = dev->ifindex;
+	if (dev)
 		skb->dev = NULL;
-	}
+
 	qp->q.stamp = skb->tstamp;
 	qp->q.meat += skb->len;
 	atomic_add(skb->truesize, &qp->q.net->mem);
@@ -572,6 +578,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 {
 	struct ipq *qp;
 	struct net *net;
+	int iif  = 0;
 
 	net = skb->dev ? dev_net(skb->dev) : dev_net(skb_dst(skb)->dev);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
@@ -580,8 +587,12 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 	if (atomic_read(&net->ipv4.frags.mem) > net->ipv4.frags.high_thresh)
 		ip_evictor(net);
 
+	if (skb->dev)
+		iif = skb->dev->ifindex;
+
 	/* Lookup (or create) queue header */
-	if ((qp = ip_find(net, ip_hdr(skb), user)) != NULL) {
+	qp = ip_find(net, ip_hdr(skb), user, iif);
+	if (qp != NULL) {
 		int ret;
 
 		spin_lock(&qp->q.lock);


