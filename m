From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH]IPv6: Delete redundant counter of IPSTATS_MIB_REASMFAILS
Date: Thu, 11 Feb 2010 18:12:45 +0800
Message-ID: <4B73D81D.1000601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	Patrick McHardy <kaber@trash.net>, eric.dumazet@gmail.com,
	ado
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64370 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750857Ab0BKKMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2010 05:12:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When no more memory can be allocated, fq_find() will return NULL and 
increase the value of IPSTATS_MIB_REASMFAILS. In this case,
ipv6_frag_rcv() also increase the value of IPSTATS_MIB_REASMFAILS.

So, the patch deletes redundant counter of IPSTATS_MIB_REASMFAILS in fq_find().
and deletes the unused parameter of idev.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/reassembly.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 2cddea3..01a996f 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -237,8 +237,7 @@ out:
 }
 
 static __inline__ struct frag_queue *
-fq_find(struct net *net, __be32 id, struct in6_addr *src, struct in6_addr *dst,
-	struct inet6_dev *idev)
+fq_find(struct net *net, __be32 id, struct in6_addr *src, struct in6_addr *dst)
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
@@ -254,13 +253,9 @@ fq_find(struct net *net, __be32 id, struct in6_addr *src, struct in6_addr *dst,
 
 	q = inet_frag_find(&net->ipv6.frags, &ip6_frags, &arg, hash);
 	if (q == NULL)
-		goto oom;
+		return NULL;
 
 	return container_of(q, struct frag_queue, q);
-
-oom:
-	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_REASMFAILS);
-	return NULL;
 }
 
 static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
@@ -606,8 +601,8 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	if (atomic_read(&net->ipv6.frags.mem) > net->ipv6.frags.high_thresh)
 		ip6_evictor(net, ip6_dst_idev(skb_dst(skb)));
 
-	if ((fq = fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr,
-			  ip6_dst_idev(skb_dst(skb)))) != NULL) {
+	fq = fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr);
+	if (fq != NULL) {
 		int ret;
 
 		spin_lock(&fq->q.lock);
-- 
1.6.3.3

