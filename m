From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 2/7 v2]IPv6:netfilter: defrag: Introduce per-netns
 to conntrack and kill nf_init_frags
Date: Sat, 27 Feb 2010 14:39:56 +0800
Message-ID: <4B88BE3C.2000901__26946.2557779208$1267252815$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.o
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51351 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753176Ab0B0Gj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 01:39:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce network name spaces to conntrack and share netns_frags with IPv6 stack.  
So kill private member of nf_init_frags in nf_conntrack_reasm.c.

v1-v2:
1. Separate sysctls handles from this patch to patch-1.
2. Separate locking changes from this patch to patch-3.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |   41 +++++++++++++-----------------
 1 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 1095676..99ec35d 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -69,7 +69,6 @@ struct nf_ct_frag6_queue
 };
 
 static struct inet_frags nf_frags;
-static struct netns_frags nf_init_frags;
 
 #ifdef CONFIG_SYSCTL
 struct ctl_table nf_ct_ipv6_sysctl_table[] = {
@@ -173,11 +172,12 @@ static void nf_skb_free(struct sk_buff *skb)
 }
 
 /* Memory Tracking Functions. */
-static inline void frag_kfree_skb(struct sk_buff *skb, unsigned int *work)
+static inline void
+frag_kfree_skb(struct netns_frags *nf, struct sk_buff *skb, unsigned int *work)
 {
 	if (work)
 		*work -= skb->truesize;
-	atomic_sub(skb->truesize, &nf_init_frags.mem);
+	atomic_sub(skb->truesize, &nf->mem);
 	nf_skb_free(skb);
 	kfree_skb(skb);
 }
@@ -197,10 +197,10 @@ static __inline__ void fq_kill(struct nf_ct_frag6_queue *fq)
 	inet_frag_kill(&fq->q, &nf_frags);
 }
 
-static void nf_ct_frag6_evictor(void)
+static void nf_ct_frag6_evictor(struct net *net)
 {
 	local_bh_disable();
-	inet_frag_evictor(&nf_init_frags, &nf_frags);
+	inet_frag_evictor(&net->ipv6.frags, &nf_frags);
 	local_bh_enable();
 }
 
@@ -226,7 +226,8 @@ out:
 /* Creation primitives. */
 
 static __inline__ struct nf_ct_frag6_queue *
-fq_find(__be32 id, u32 user, struct in6_addr *src, struct in6_addr *dst)
+fq_find(struct net *net, __be32 id, u32 user, struct in6_addr *src,
+	struct in6_addr *dst)
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
@@ -240,7 +241,7 @@ fq_find(__be32 id, u32 user, struct in6_addr *src, struct in6_addr *dst)
 	read_lock_bh(&nf_frags.lock);
 	hash = inet6_hash_frag(id, src, dst, nf_frags.rnd);
 
-	q = inet_frag_find(&nf_init_frags, &nf_frags, &arg, hash);
+	q = inet_frag_find(&net->ipv6.frags, &nf_frags, &arg, hash);
 	local_bh_enable();
 	if (q == NULL)
 		goto oom;
@@ -394,7 +395,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 				fq->q.fragments = next;
 
 			fq->q.meat -= free_it->len;
-			frag_kfree_skb(free_it, NULL);
+			frag_kfree_skb(fq->q.net, free_it, NULL);
 		}
 	}
 
@@ -410,7 +411,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 	skb->dev = NULL;
 	fq->q.stamp = skb->tstamp;
 	fq->q.meat += skb->len;
-	atomic_add(skb->truesize, &nf_init_frags.mem);
+	atomic_add(skb->truesize, &fq->q.net->mem);
 
 	/* The first fragment.
 	 * nhoffset is obtained from the first fragment, of course.
@@ -420,7 +421,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 		fq->q.last_in |= INET_FRAG_FIRST_IN;
 	}
 	write_lock(&nf_frags.lock);
-	list_move_tail(&fq->q.lru_list, &nf_init_frags.lru_list);
+	list_move_tail(&fq->q.lru_list, &fq->q.net->lru_list);
 	write_unlock(&nf_frags.lock);
 	return 0;
 
@@ -487,7 +488,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 		clone->ip_summed = head->ip_summed;
 
 		NFCT_FRAG6_CB(clone)->orig = NULL;
-		atomic_add(clone->truesize, &nf_init_frags.mem);
+		atomic_add(clone->truesize, &fq->q.net->mem);
 	}
 
 	/* We have to remove fragment header from datagram and to relocate
@@ -501,7 +502,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 	skb_shinfo(head)->frag_list = head->next;
 	skb_reset_transport_header(head);
 	skb_push(head, head->data - skb_network_header(head));
-	atomic_sub(head->truesize, &nf_init_frags.mem);
+	atomic_sub(head->truesize, &fq->q.net->mem);
 
 	for (fp=head->next; fp; fp = fp->next) {
 		head->data_len += fp->len;
@@ -511,7 +512,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
-		atomic_sub(fp->truesize, &nf_init_frags.mem);
+		atomic_sub(fp->truesize, &fq->q.net->mem);
 	}
 
 	head->next = NULL;
@@ -628,6 +629,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	int fhoff, nhoff;
 	u8 prevhdr;
 	struct sk_buff *ret_skb = NULL;
+	struct net *net = dev ? dev_net(dev) : dev_net(skb_dst(skb)->dev);
 
 	/* Jumbo payload inhibits frag. header */
 	if (ipv6_hdr(skb)->payload_len == 0) {
@@ -655,10 +657,10 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	hdr = ipv6_hdr(clone);
 	fhdr = (struct frag_hdr *)skb_transport_header(clone);
 
-	if (atomic_read(&nf_init_frags.mem) > nf_init_frags.high_thresh)
-		nf_ct_frag6_evictor();
+	if (atomic_read(&net->ipv6.frags.mem) > net->ipv6.frags.high_thresh)
+		nf_ct_frag6_evictor(net);
 
-	fq = fq_find(fhdr->identification, user, &hdr->saddr, &hdr->daddr);
+	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr);
 	if (fq == NULL) {
 		pr_debug("Can't find and can't create new queue\n");
 		goto ret_orig;
@@ -731,10 +733,6 @@ int nf_ct_frag6_init(void)
 	nf_frags.match = ip6_frag_match;
 	nf_frags.frag_expire = nf_ct_frag6_expire;
 	nf_frags.secret_interval = 10 * 60 * HZ;
-	nf_init_frags.timeout = IPV6_FRAG_TIMEOUT;
-	nf_init_frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
-	nf_init_frags.low_thresh = IPV6_FRAG_LOW_THRESH;
-	inet_frags_init_net(&nf_init_frags);
 	inet_frags_init(&nf_frags);
 
 	return 0;
@@ -743,8 +741,5 @@ int nf_ct_frag6_init(void)
 void nf_ct_frag6_cleanup(void)
 {
 	inet_frags_fini(&nf_frags);
-
-	nf_init_frags.low_thresh = 0;
-	nf_ct_frag6_evictor();
 	unregister_pernet_subsys(&ip6_nf_frags_ops);
 }
-- 
1.6.3.3
