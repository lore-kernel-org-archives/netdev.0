From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 3/7 v2]IPv6:netfilter: defrag: Disable button
 half when reassembling a fragment
Date: Sat, 27 Feb 2010 14:39:59 +0800
Message-ID: <4B88BE3F.5020609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.o
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59649 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753361Ab0B0Gj7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 01:39:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After doing introduction of network name spaces to conntrack,
disable button half when reassembling a fragment.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    3 +++
 net/ipv6/netfilter/nf_conntrack_reasm.c        |   11 ++++-------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 03a6b8d..f153b2c 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -221,7 +221,10 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
 	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
 		return NF_ACCEPT;
 
+	local_bh_disable();
 	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(hooknum, skb));
+	local_bh_enable();
+
 	/* queued */
 	if (reasm == NULL)
 		return NF_STOLEN;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 99ec35d..8f68373 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -199,9 +199,7 @@ static __inline__ void fq_kill(struct nf_ct_frag6_queue *fq)
 
 static void nf_ct_frag6_evictor(struct net *net)
 {
-	local_bh_disable();
 	inet_frag_evictor(&net->ipv6.frags, &nf_frags);
-	local_bh_enable();
 }
 
 static void nf_ct_frag6_expire(unsigned long data)
@@ -238,11 +236,10 @@ fq_find(struct net *net, __be32 id, u32 user, struct in6_addr *src,
 	arg.src = src;
 	arg.dst = dst;
 
-	read_lock_bh(&nf_frags.lock);
+	read_lock(&nf_frags.lock);
 	hash = inet6_hash_frag(id, src, dst, nf_frags.rnd);
 
 	q = inet_frag_find(&net->ipv6.frags, &nf_frags, &arg, hash);
-	local_bh_enable();
 	if (q == NULL)
 		goto oom;
 
@@ -666,10 +663,10 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 		goto ret_orig;
 	}
 
-	spin_lock_bh(&fq->q.lock);
+	spin_lock(&fq->q.lock);
 
 	if (nf_ct_frag6_queue(fq, clone, fhdr, nhoff) < 0) {
-		spin_unlock_bh(&fq->q.lock);
+		spin_unlock(&fq->q.lock);
 		pr_debug("Can't insert skb to queue\n");
 		fq_put(fq);
 		goto ret_orig;
@@ -681,7 +678,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 		if (ret_skb == NULL)
 			pr_debug("Can't reassemble fragmented packets\n");
 	}
-	spin_unlock_bh(&fq->q.lock);
+	spin_unlock(&fq->q.lock);
 
 	fq_put(fq);
 	return ret_skb;
-- 
1.6.3.3
