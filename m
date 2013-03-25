From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] netfilter: implement RFC3168 5.3 (ecn protection) for ipv6 fragmentation handling
Date: Mon, 25 Mar 2013 02:20:51 +0100
Message-ID: <20130325012051.GF12968@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, jbrouer@redhat.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55725 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756358Ab3CYBUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 21:20:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change brings netfilter reassembly logic on par with
reassembly.c. The corresponding change in net-next is
eec2e6185ff6eab18c2cae9b01a9fbc5c33248fc.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
I duplicated ip6_frag_ecn here again because I could not find a good header to
stick it in. There is a recursive header inclusion if I include inet_ecn.h
from inet_frag.h. I hope this is ok for the time being.

 net/ipv6/netfilter/nf_conntrack_reasm.c | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 6700069..dffdc1a 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -41,6 +41,7 @@
 #include <net/rawv6.h>
 #include <net/ndisc.h>
 #include <net/addrconf.h>
+#include <net/inet_ecn.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
 #include <linux/sysctl.h>
 #include <linux/netfilter.h>
@@ -138,6 +139,11 @@ static void __net_exit nf_ct_frags6_sysctl_unregister(struct net *net)
 }
 #endif
 
+static inline u8 ip6_frag_ecn(const struct ipv6hdr *ipv6h)
+{
+	return 1 << (ipv6_get_dsfield(ipv6h) & INET_ECN_MASK);
+}
+
 static unsigned int nf_hashfn(struct inet_frag_queue *q)
 {
 	const struct frag_queue *nq;
@@ -166,7 +172,7 @@ static void nf_ct_frag6_expire(unsigned long data)
 /* Creation primitives. */
 static inline struct frag_queue *fq_find(struct net *net, __be32 id,
 					 u32 user, struct in6_addr *src,
-					 struct in6_addr *dst)
+					 struct in6_addr *dst, u8 ecn)
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
@@ -176,6 +182,7 @@ static inline struct frag_queue *fq_find(struct net *net, __be32 id,
 	arg.user = user;
 	arg.src = src;
 	arg.dst = dst;
+	arg.ecn = ecn;
 
 	read_lock_bh(&nf_frags.lock);
 	hash = inet6_hash_frag(id, src, dst, nf_frags.rnd);
@@ -196,6 +203,7 @@ static int nf_ct_frag6_queue(struct frag_queue *fq, struct sk_buff *skb,
 	struct sk_buff *prev, *next;
 	unsigned int payload_len;
 	int offset, end;
+	u8 ecn;
 
 	if (fq->q.last_in & INET_FRAG_COMPLETE) {
 		pr_debug("Already completed\n");
@@ -213,6 +221,8 @@ static int nf_ct_frag6_queue(struct frag_queue *fq, struct sk_buff *skb,
 		return -1;
 	}
 
+	ecn = ip6_frag_ecn(ipv6_hdr(skb));
+
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		const unsigned char *nh = skb_network_header(skb);
 		skb->csum = csum_sub(skb->csum,
@@ -317,6 +327,7 @@ found:
 	}
 	fq->q.stamp = skb->tstamp;
 	fq->q.meat += skb->len;
+	fq->ecn |= ecn;
 	if (payload_len > fq->q.max_size)
 		fq->q.max_size = payload_len;
 	add_frag_mem_limit(&fq->q, skb->truesize);
@@ -352,12 +363,17 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 {
 	struct sk_buff *fp, *op, *head = fq->q.fragments;
 	int    payload_len;
+	u8 ecn;
 
 	inet_frag_kill(&fq->q, &nf_frags);
 
 	WARN_ON(head == NULL);
 	WARN_ON(NFCT_FRAG6_CB(head)->offset != 0);
 
+	ecn = ip_frag_ecn_table[fq->ecn];
+	if (unlikely(ecn == 0xff))
+		goto out_fail;
+
 	/* Unfragmented part is taken from the first segment. */
 	payload_len = ((head->data - skb_network_header(head)) -
 		       sizeof(struct ipv6hdr) + fq->q.len -
@@ -428,6 +444,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 	head->dev = dev;
 	head->tstamp = fq->q.stamp;
 	ipv6_hdr(head)->payload_len = htons(payload_len);
+	ipv6_change_dsfield(ipv6_hdr(head), 0xff, ecn);
 	IP6CB(head)->frag_max_size = sizeof(struct ipv6hdr) + fq->q.max_size;
 
 	/* Yes, and fold redundant checksum back. 8) */
@@ -572,7 +589,8 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	inet_frag_evictor(&net->nf_frag.frags, &nf_frags, false);
 	local_bh_enable();
 
-	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr);
+	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr,
+		     ip6_frag_ecn(hdr));
 	if (fq == NULL) {
 		pr_debug("Can't find and can't create new queue\n");
 		goto ret_orig;
-- 
1.8.1.4
