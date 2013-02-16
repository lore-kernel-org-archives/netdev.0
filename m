From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH net-next (V2, RESENT)] ipv6: Queue fragments per interface
 for multicast/link-local addresses.
Date: Sun, 17 Feb 2013 01:44:38 +0900
Message-ID: <511FB776.8000901@linux-ipv6.org>
References: <511F1E03.9010205@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <511F1E03.9010205@linux-ipv6.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should queue fragments for the same link-local address on
different interfaces (e.g. fe80::1%eth0 and fe80::1%eth1) to the
different queue, because of nature of addressing architecture.

Similarly, we should queue fragments for multicast on different
interface to the different queue.  This is okay because
application joins group on speicific interface, and multicast
traffic is expected only on that interface.

CC: Ben Greear <greearb@candelatech.com>
CC: Vlad Yasevich <vyasevic@redhat.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h                      |    1 +
 net/ipv6/netfilter/nf_conntrack_reasm.c |    9 +++++++--
 net/ipv6/reassembly.c                   |   10 ++++++++--
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 851d541..1af98aa 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -463,6 +463,7 @@ enum ip6_defrag_users {
 struct ip6_create_arg {
 	__be32 id;
 	u32 user;
+	int ifindex;
 	const struct in6_addr *src;
 	const struct in6_addr *dst;
 };
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index c674f15..acd1820 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -163,7 +163,8 @@ static void nf_ct_frag6_expire(unsigned long data)
 
 /* Creation primitives. */
 static inline struct frag_queue *fq_find(struct net *net, __be32 id,
-					 u32 user, struct in6_addr *src,
+					 u32 user, int ifindex,
+					 struct in6_addr *src,
 					 struct in6_addr *dst)
 {
 	struct inet_frag_queue *q;
@@ -171,6 +172,10 @@ static inline struct frag_queue *fq_find(struct net *net, __be32 id,
 	unsigned int hash;
 
 	arg.id = id;
+	if (ipv6_addr_type(dst) & (IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL))
+		arg.ifindex = ifindex;
+	else
+		arg.ifindex = 0;
 	arg.user = user;
 	arg.src = src;
 	arg.dst = dst;
@@ -572,7 +577,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	inet_frag_evictor(&net->nf_frag.frags, &nf_frags, false);
 	local_bh_enable();
 
-	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr);
+	fq = fq_find(net, fhdr->identification, user, dev->ifindex, &hdr->saddr, &hdr->daddr);
 	if (fq == NULL) {
 		pr_debug("Can't find and can't create new queue\n");
 		goto ret_orig;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index bab2c27..18c5e3c 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -113,6 +113,7 @@ bool ip6_frag_match(struct inet_frag_queue *q, void *a)
 
 	fq = container_of(q, struct frag_queue, q);
 	return	fq->id == arg->id &&
+		(!arg->ifindex || fq->iif == arg->ifindex) &&
 		fq->user == arg->user &&
 		ipv6_addr_equal(&fq->saddr, arg->src) &&
 		ipv6_addr_equal(&fq->daddr, arg->dst);
@@ -182,13 +183,17 @@ static void ip6_frag_expire(unsigned long data)
 }
 
 static __inline__ struct frag_queue *
-fq_find(struct net *net, __be32 id, const struct in6_addr *src, const struct in6_addr *dst)
+fq_find(struct net *net, __be32 id, int ifindex, const struct in6_addr *src, const struct in6_addr *dst)
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
 	unsigned int hash;
 
 	arg.id = id;
+	if (ipv6_addr_type(dst) & (IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL))
+		arg.ifindex = ifindex;
+	else
+		arg.ifindex = 0;
 	arg.user = IP6_DEFRAG_LOCAL_DELIVER;
 	arg.src = src;
 	arg.dst = dst;
@@ -534,7 +539,8 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 				 IPSTATS_MIB_REASMFAILS, evicted);
 
-	fq = fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr);
+	fq = fq_find(net, fhdr->identification, skb->dev->ifindex,
+		     &hdr->saddr, &hdr->daddr);
 	if (fq != NULL) {
 		int ret;
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


