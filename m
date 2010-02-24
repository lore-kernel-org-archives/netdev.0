From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 1/5]IPv6:netfilter: defrag:Introduce net namespace
 to conntrack and share netns_frags with IPv6 stack
Date: Wed, 24 Feb 2010 14:07:49 +0800
Message-ID: <4B84C235.4070601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, Shan Wei <shanwei@cn.fujitsu.com>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51081 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752191Ab0BXGHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 01:07:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce net namespace to conntrack and share netns_frags with IPv6 stack.  

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    7 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c        |   79 +++++++-----------------
 2 files changed, 25 insertions(+), 61 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 996c3f4..f153b2c 100644
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
@@ -387,10 +390,6 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv6 __read_mostly = {
 	.nlattr_to_tuple	= ipv6_nlattr_to_tuple,
 	.nla_policy		= ipv6_nla_policy,
 #endif
-#ifdef CONFIG_SYSCTL
-	.ctl_table_path		= nf_net_netfilter_sysctl_path,
-	.ctl_table		= nf_ct_ipv6_sysctl_table,
-#endif
 	.me			= THIS_MODULE,
 };
 
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index ad1fcda..b53083f 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -69,34 +69,6 @@ struct nf_ct_frag6_queue
 };
 
 static struct inet_frags nf_frags;
-static struct netns_frags nf_init_frags;
-
-#ifdef CONFIG_SYSCTL
-struct ctl_table nf_ct_ipv6_sysctl_table[] = {
-	{
-		.procname	= "nf_conntrack_frag6_timeout",
-		.data		= &nf_init_frags.timeout,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "nf_conntrack_frag6_low_thresh",
-		.data		= &nf_init_frags.low_thresh,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "nf_conntrack_frag6_high_thresh",
-		.data		= &nf_init_frags.high_thresh,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{ }
-};
-#endif
 
 static unsigned int nf_hashfn(struct inet_frag_queue *q)
 {
@@ -113,11 +85,12 @@ static void nf_skb_free(struct sk_buff *skb)
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
@@ -137,11 +110,9 @@ static __inline__ void fq_kill(struct nf_ct_frag6_queue *fq)
 	inet_frag_kill(&fq->q, &nf_frags);
 }
 
-static void nf_ct_frag6_evictor(void)
+static void nf_ct_frag6_evictor(struct net *net)
 {
-	local_bh_disable();
-	inet_frag_evictor(&nf_init_frags, &nf_frags);
-	local_bh_enable();
+	inet_frag_evictor(&net->ipv6.frags, &nf_frags);
 }
 
 static void nf_ct_frag6_expire(unsigned long data)
@@ -166,7 +137,8 @@ out:
 /* Creation primitives. */
 
 static __inline__ struct nf_ct_frag6_queue *
-fq_find(__be32 id, u32 user, struct in6_addr *src, struct in6_addr *dst)
+fq_find(struct net *net, __be32 id, u32 user, struct in6_addr *src,
+	struct in6_addr *dst)
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
@@ -177,11 +149,10 @@ fq_find(__be32 id, u32 user, struct in6_addr *src, struct in6_addr *dst)
 	arg.src = src;
 	arg.dst = dst;
 
-	read_lock_bh(&nf_frags.lock);
+	read_lock(&nf_frags.lock);
 	hash = inet6_hash_frag(id, src, dst, nf_frags.rnd);
 
-	q = inet_frag_find(&nf_init_frags, &nf_frags, &arg, hash);
-	local_bh_enable();
+	q = inet_frag_find(&net->ipv6.frags, &nf_frags, &arg, hash);
 	if (q == NULL)
 		goto oom;
 
@@ -334,7 +305,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 				fq->q.fragments = next;
 
 			fq->q.meat -= free_it->len;
-			frag_kfree_skb(free_it, NULL);
+			frag_kfree_skb(fq->q.net, free_it, NULL);
 		}
 	}
 
@@ -350,7 +321,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 	skb->dev = NULL;
 	fq->q.stamp = skb->tstamp;
 	fq->q.meat += skb->len;
-	atomic_add(skb->truesize, &nf_init_frags.mem);
+	atomic_add(skb->truesize, &fq->q.net->mem);
 
 	/* The first fragment.
 	 * nhoffset is obtained from the first fragment, of course.
@@ -360,7 +331,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 		fq->q.last_in |= INET_FRAG_FIRST_IN;
 	}
 	write_lock(&nf_frags.lock);
-	list_move_tail(&fq->q.lru_list, &nf_init_frags.lru_list);
+	list_move_tail(&fq->q.lru_list, &fq->q.net->lru_list);
 	write_unlock(&nf_frags.lock);
 	return 0;
 
@@ -427,7 +398,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 		clone->ip_summed = head->ip_summed;
 
 		NFCT_FRAG6_CB(clone)->orig = NULL;
-		atomic_add(clone->truesize, &nf_init_frags.mem);
+		atomic_add(clone->truesize, &fq->q.net->mem);
 	}
 
 	/* We have to remove fragment header from datagram and to relocate
@@ -441,7 +412,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 	skb_shinfo(head)->frag_list = head->next;
 	skb_reset_transport_header(head);
 	skb_push(head, head->data - skb_network_header(head));
-	atomic_sub(head->truesize, &nf_init_frags.mem);
+	atomic_sub(head->truesize, &fq->q.net->mem);
 
 	for (fp=head->next; fp; fp = fp->next) {
 		head->data_len += fp->len;
@@ -451,7 +422,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
-		atomic_sub(fp->truesize, &nf_init_frags.mem);
+		atomic_sub(fp->truesize, &fq->q.net->mem);
 	}
 
 	head->next = NULL;
@@ -568,6 +539,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	int fhoff, nhoff;
 	u8 prevhdr;
 	struct sk_buff *ret_skb = NULL;
+	struct net *net = dev ? dev_net(dev) : dev_net(skb_dst(skb)->dev);
 
 	/* Jumbo payload inhibits frag. header */
 	if (ipv6_hdr(skb)->payload_len == 0) {
@@ -601,19 +573,19 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 		goto ret_orig;
 	}
 
-	if (atomic_read(&nf_init_frags.mem) > nf_init_frags.high_thresh)
-		nf_ct_frag6_evictor();
+	if (atomic_read(&net->ipv6.frags.mem) > net->ipv6.frags.high_thresh)
+		nf_ct_frag6_evictor(net);
 
-	fq = fq_find(fhdr->identification, user, &hdr->saddr, &hdr->daddr);
+	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr);
 	if (fq == NULL) {
 		pr_debug("Can't find and can't create new queue\n");
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
@@ -625,7 +597,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 		if (ret_skb == NULL)
 			pr_debug("Can't reassemble fragmented packets\n");
 	}
-	spin_unlock_bh(&fq->q.lock);
+	spin_unlock(&fq->q.lock);
 
 	fq_put(fq);
 	return ret_skb;
@@ -666,10 +638,6 @@ int nf_ct_frag6_init(void)
 	nf_frags.match = ip6_frag_match;
 	nf_frags.frag_expire = nf_ct_frag6_expire;
 	nf_frags.secret_interval = 10 * 60 * HZ;
-	nf_init_frags.timeout = IPV6_FRAG_TIMEOUT;
-	nf_init_frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
-	nf_init_frags.low_thresh = IPV6_FRAG_LOW_THRESH;
-	inet_frags_init_net(&nf_init_frags);
 	inet_frags_init(&nf_frags);
 
 	return 0;
@@ -678,7 +646,4 @@ int nf_ct_frag6_init(void)
 void nf_ct_frag6_cleanup(void)
 {
 	inet_frags_fini(&nf_frags);
-
-	nf_init_frags.low_thresh = 0;
-	nf_ct_frag6_evictor();
 }
-- 
1.6.3.3 

