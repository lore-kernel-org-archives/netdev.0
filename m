From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 3/9] inet: frag: move evictor calls into frag_find function
Date: Thu, 24 Jul 2014 16:50:31 +0200
Message-ID: <1406213437-6155-4-git-send-email-nikolay@redhat.com>
References: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Cc: Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13227 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933402AbaGXOwB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 10:52:01 -0400
In-Reply-To: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

First step to move eviction handling into a work queue.

We lose two spots that accounted evicted fragments in MIB counters.

Accounting will be restored since the upcoming work-queue evictor
invokes the frag queue timer callbacks instead.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/inet_frag.h                 |  1 -
 net/ieee802154/reassembly.c             |  2 --
 net/ipv4/inet_fragment.c                | 16 +++++++++-------
 net/ipv4/ip_fragment.c                  | 15 ---------------
 net/ipv6/netfilter/nf_conntrack_reasm.c |  4 ----
 net/ipv6/reassembly.c                   |  6 ------
 6 files changed, 9 insertions(+), 35 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 15033057d44e..9fe644d1a26e 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -90,7 +90,6 @@ void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f);
 void inet_frag_kill(struct inet_frag_queue *q, struct inet_frags *f);
 void inet_frag_destroy(struct inet_frag_queue *q,
 				struct inet_frags *f, int *work);
-int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force);
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
 	__releases(&f->lock);
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index a707995fd4d7..9503a48556f7 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -369,8 +369,6 @@ int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_type)
 	if (frag_info->d_size > ieee802154_lowpan->max_dsize)
 		goto err;
 
-	inet_frag_evictor(&ieee802154_lowpan->frags, &lowpan_frags, false);
-
 	fq = fq_find(net, frag_info, &source, &dest);
 	if (fq != NULL) {
 		int ret;
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 930d23870811..535636017534 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -46,6 +46,8 @@ const u8 ip_frag_ecn_table[16] = {
 };
 EXPORT_SYMBOL(ip_frag_ecn_table);
 
+static int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force);
+
 static unsigned int
 inet_frag_hashfn(const struct inet_frags *f, const struct inet_frag_queue *q)
 {
@@ -203,16 +205,11 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f,
 }
 EXPORT_SYMBOL(inet_frag_destroy);
 
-int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
+static int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 {
 	struct inet_frag_queue *q;
 	int work, evicted = 0;
 
-	if (!force) {
-		if (frag_mem_limit(nf) <= nf->high_thresh)
-			return 0;
-	}
-
 	work = frag_mem_limit(nf) - nf->low_thresh;
 	while (work > 0 || force) {
 		spin_lock(&nf->lru_lock);
@@ -242,7 +239,6 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 
 	return evicted;
 }
-EXPORT_SYMBOL(inet_frag_evictor);
 
 static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		struct inet_frag_queue *qp_in, struct inet_frags *f,
@@ -296,6 +292,9 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 {
 	struct inet_frag_queue *q;
 
+	if (frag_mem_limit(nf) > nf->high_thresh)
+		return NULL;
+
 	q = kzalloc(f->qsize, GFP_ATOMIC);
 	if (q == NULL)
 		return NULL;
@@ -332,6 +331,9 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 	struct inet_frag_queue *q;
 	int depth = 0;
 
+	if (frag_mem_limit(nf) > nf->high_thresh)
+		inet_frag_evictor(nf, f, false);
+
 	hash &= (INETFRAGS_HASHSZ - 1);
 	hb = &f->hash[hash];
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b769eb6c83c0..54988672d00d 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -177,18 +177,6 @@ static void ipq_kill(struct ipq *ipq)
 	inet_frag_kill(&ipq->q, &ip4_frags);
 }
 
-/* Memory limiting on fragments.  Evictor trashes the oldest
- * fragment queue until we are back under the threshold.
- */
-static void ip_evictor(struct net *net)
-{
-	int evicted;
-
-	evicted = inet_frag_evictor(&net->ipv4.frags, &ip4_frags, false);
-	if (evicted)
-		IP_ADD_STATS_BH(net, IPSTATS_MIB_REASMFAILS, evicted);
-}
-
 /*
  * Oops, a fragment queue timed out.  Kill it and send an ICMP reply.
  */
@@ -655,9 +643,6 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 	net = skb->dev ? dev_net(skb->dev) : dev_net(skb_dst(skb)->dev);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
 
-	/* Start by cleaning up the memory. */
-	ip_evictor(net);
-
 	/* Lookup (or create) queue header */
 	if ((qp = ip_find(net, ip_hdr(skb), user)) != NULL) {
 		int ret;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 607e4a94ef41..58e32cf91c95 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -594,10 +594,6 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	hdr = ipv6_hdr(clone);
 	fhdr = (struct frag_hdr *)skb_transport_header(clone);
 
-	local_bh_disable();
-	inet_frag_evictor(&net->nf_frag.frags, &nf_frags, false);
-	local_bh_enable();
-
 	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr,
 		     ip6_frag_ecn(hdr));
 	if (fq == NULL) {
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 2b76549a1016..97acbc490d9e 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -519,7 +519,6 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	struct frag_queue *fq;
 	const struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct net *net = dev_net(skb_dst(skb)->dev);
-	int evicted;
 
 	if (IP6CB(skb)->flags & IP6SKB_FRAGMENTED)
 		goto fail_hdr;
@@ -548,11 +547,6 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		return 1;
 	}
 
-	evicted = inet_frag_evictor(&net->ipv6.frags, &ip6_frags, false);
-	if (evicted)
-		IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-				 IPSTATS_MIB_REASMFAILS, evicted);
-
 	fq = fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr,
 		     ip6_frag_ecn(hdr));
 	if (fq != NULL) {
-- 
1.9.3
