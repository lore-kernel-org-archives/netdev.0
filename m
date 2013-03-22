From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 2/2] ipv6: implement RFC3168 5.3 (ecn protection) for ipv6 fragmentation handling
Date: Fri, 22 Mar 2013 19:24:44 +0100
Message-ID: <20130322182444.GA939@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, jbrouer@redhat.com, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52606 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422877Ab3CVSYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 14:24:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

After patch 1 got accepted to net-next I will also send a patch to
netfilter-devel to make the corresponding changes to the netfilter
reassembly logic.

Thanks,

  Hannes

-- >8 --
[PATCH 2/2] ipv6: implement RFC3168 5.3 (ecn protection) for ipv6 fragmentation handling

This patch also ensures that INET_ECN_CE is propagated if one fragment
had the codepoint set.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ipv6.h    |  2 ++
 net/ipv6/reassembly.c | 23 +++++++++++++++++++++--
 2 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 42ef6ab..0810aa5 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -478,6 +478,7 @@ struct ip6_create_arg {
 	u32 user;
 	const struct in6_addr *src;
 	const struct in6_addr *dst;
+	u8 ecn;
 };
 
 void ip6_frag_init(struct inet_frag_queue *q, void *a);
@@ -497,6 +498,7 @@ struct frag_queue {
 	int			iif;
 	unsigned int		csum;
 	__u16			nhoffset;
+	u8			ecn;
 };
 
 void ip6_expire_frag_queue(struct net *net, struct frag_queue *fq,
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 196ab93..e6e44ce 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -58,6 +58,7 @@
 #include <net/ndisc.h>
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
+#include <net/inet_ecn.h>
 
 struct ip6frag_skb_cb
 {
@@ -67,6 +68,10 @@ struct ip6frag_skb_cb
 
 #define FRAG6_CB(skb)	((struct ip6frag_skb_cb*)((skb)->cb))
 
+static inline u8 ip6_frag_ecn(const struct ipv6hdr *ipv6h)
+{
+	return 1 << (ipv6_get_dsfield(ipv6h) & INET_ECN_MASK);
+}
 
 static struct inet_frags ip6_frags;
 
@@ -119,6 +124,7 @@ void ip6_frag_init(struct inet_frag_queue *q, void *a)
 	fq->user = arg->user;
 	fq->saddr = *arg->src;
 	fq->daddr = *arg->dst;
+	fq->ecn = arg->ecn;
 }
 EXPORT_SYMBOL(ip6_frag_init);
 
@@ -173,7 +179,8 @@ static void ip6_frag_expire(unsigned long data)
 }
 
 static __inline__ struct frag_queue *
-fq_find(struct net *net, __be32 id, const struct in6_addr *src, const struct in6_addr *dst)
+fq_find(struct net *net, __be32 id, const struct in6_addr *src,
+	const struct in6_addr *dst, u8 ecn)
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
@@ -183,6 +190,7 @@ fq_find(struct net *net, __be32 id, const struct in6_addr *src, const struct in6
 	arg.user = IP6_DEFRAG_LOCAL_DELIVER;
 	arg.src = src;
 	arg.dst = dst;
+	arg.ecn = ecn;
 
 	read_lock(&ip6_frags.lock);
 	hash = inet6_hash_frag(id, src, dst, ip6_frags.rnd);
@@ -202,6 +210,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	struct net_device *dev;
 	int offset, end;
 	struct net *net = dev_net(skb_dst(skb)->dev);
+	u8 ecn;
 
 	if (fq->q.last_in & INET_FRAG_COMPLETE)
 		goto err;
@@ -219,6 +228,8 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 		return -1;
 	}
 
+	ecn = ip6_frag_ecn(ipv6_hdr(skb));
+
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		const unsigned char *nh = skb_network_header(skb);
 		skb->csum = csum_sub(skb->csum,
@@ -319,6 +330,7 @@ found:
 	}
 	fq->q.stamp = skb->tstamp;
 	fq->q.meat += skb->len;
+	fq->ecn |= ecn;
 	add_frag_mem_limit(&fq->q, skb->truesize);
 
 	/* The first fragment.
@@ -362,9 +374,14 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	int    payload_len;
 	unsigned int nhoff;
 	int sum_truesize;
+	u8 ecn;
 
 	inet_frag_kill(&fq->q, &ip6_frags);
 
+	ecn = ip_frag_ecn_table[fq->ecn];
+	if (unlikely(ecn == 0xff))
+		goto out_fail;
+
 	/* Make the one we just received the head. */
 	if (prev) {
 		head = prev->next;
@@ -463,6 +480,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	head->dev = dev;
 	head->tstamp = fq->q.stamp;
 	ipv6_hdr(head)->payload_len = htons(payload_len);
+	ipv6_change_dsfield(ipv6_hdr(head), 0xff, ecn);
 	IP6CB(head)->nhoff = nhoff;
 
 	/* Yes, and fold redundant checksum back. 8) */
@@ -526,7 +544,8 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 				 IPSTATS_MIB_REASMFAILS, evicted);
 
-	fq = fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr);
+	fq = fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr,
+		     ip6_frag_ecn(hdr));
 	if (fq != NULL) {
 		int ret;
 
-- 
1.8.1.4
