From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 1/4] netfilter: ipv6: remove extra clone/free operations
Date: Sat, 17 Oct 2015 22:14:22 +0200
Message-ID: <1445112865-31523-2-git-send-email-fw@strlen.de>
References: <1445112865-31523-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, azhou@nicira.com, joestringer@nicira.com,
	Florian Westphal <fw@strlen.de>, Jiri Pirko <jiri@resnulli.us>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445112865-31523-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 6aafeef03b9d9ecf
("netfilter: push reasm skb through instead of original frag skbs")
changed ipv6 defrag to not use the original skbs anymore.

So rather than keeping the original skbs around just to discard them
afterwards just use the original skbs directly for the fraglist of
the newly assemled skb.

Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/netfilter/ipv6/nf_defrag_ipv6.h |  1 -
 net/ipv6/netfilter/nf_conntrack_reasm.c     | 71 ++++-------------------------
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c   |  2 -
 3 files changed, 9 insertions(+), 65 deletions(-)

diff --git a/include/net/netfilter/ipv6/nf_defrag_ipv6.h b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
index fb7da5b..fcd20cf 100644
--- a/include/net/netfilter/ipv6/nf_defrag_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
@@ -6,7 +6,6 @@ void nf_defrag_ipv6_enable(void);
 int nf_ct_frag6_init(void);
 void nf_ct_frag6_cleanup(void);
 struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 user);
-void nf_ct_frag6_consume_orig(struct sk_buff *skb);
 
 struct inet_frags_ctl;
 
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 056f5d4..1b1a851 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -56,7 +56,6 @@ struct nf_ct_frag6_skb_cb
 {
 	struct inet6_skb_parm	h;
 	int			offset;
-	struct sk_buff		*orig;
 };
 
 #define NFCT_FRAG6_CB(skb)	((struct nf_ct_frag6_skb_cb *)((skb)->cb))
@@ -170,12 +169,6 @@ static unsigned int nf_hashfn(const struct inet_frag_queue *q)
 	return nf_hash_frag(nq->id, &nq->saddr, &nq->daddr);
 }
 
-static void nf_skb_free(struct sk_buff *skb)
-{
-	if (NFCT_FRAG6_CB(skb)->orig)
-		kfree_skb(NFCT_FRAG6_CB(skb)->orig);
-}
-
 static void nf_ct_frag6_expire(unsigned long data)
 {
 	struct frag_queue *fq;
@@ -378,7 +371,7 @@ err:
 static struct sk_buff *
 nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 {
-	struct sk_buff *fp, *op, *head = fq->q.fragments;
+	struct sk_buff *fp, *head = fq->q.fragments;
 	int    payload_len;
 	u8 ecn;
 
@@ -429,7 +422,6 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 		clone->csum = 0;
 		clone->ip_summed = head->ip_summed;
 
-		NFCT_FRAG6_CB(clone)->orig = NULL;
 		add_frag_mem_limit(fq->q.net, clone->truesize);
 	}
 
@@ -473,21 +465,6 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 	fq->q.fragments = NULL;
 	fq->q.fragments_tail = NULL;
 
-	/* all original skbs are linked into the NFCT_FRAG6_CB(head).orig */
-	fp = skb_shinfo(head)->frag_list;
-	if (fp && NFCT_FRAG6_CB(fp)->orig == NULL)
-		/* at above code, head skb is divided into two skbs. */
-		fp = fp->next;
-
-	op = NFCT_FRAG6_CB(head)->orig;
-	for (; fp; fp = fp->next) {
-		struct sk_buff *orig = NFCT_FRAG6_CB(fp)->orig;
-
-		op->next = orig;
-		op = orig;
-		NFCT_FRAG6_CB(fp)->orig = NULL;
-	}
-
 	return head;
 
 out_oversize:
@@ -565,7 +542,6 @@ find_prev_fhdr(struct sk_buff *skb, u8 *prevhdrp, int *prevhoff, int *fhoff)
 
 struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 user)
 {
-	struct sk_buff *clone;
 	struct net_device *dev = skb->dev;
 	struct frag_hdr *fhdr;
 	struct frag_queue *fq;
@@ -583,37 +559,25 @@ struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 use
 	if (find_prev_fhdr(skb, &prevhdr, &nhoff, &fhoff) < 0)
 		return skb;
 
-	clone = skb_clone(skb, GFP_ATOMIC);
-	if (clone == NULL) {
-		pr_debug("Can't clone skb\n");
+	if (!pskb_may_pull(skb, fhoff + sizeof(*fhdr)))
 		return skb;
-	}
-
-	NFCT_FRAG6_CB(clone)->orig = skb;
-
-	if (!pskb_may_pull(clone, fhoff + sizeof(*fhdr))) {
-		pr_debug("message is too short.\n");
-		goto ret_orig;
-	}
 
-	skb_set_transport_header(clone, fhoff);
-	hdr = ipv6_hdr(clone);
-	fhdr = (struct frag_hdr *)skb_transport_header(clone);
+	skb_set_transport_header(skb, fhoff);
+	hdr = ipv6_hdr(skb);
+	fhdr = (struct frag_hdr *)skb_transport_header(skb);
 
 	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr,
 		     ip6_frag_ecn(hdr));
-	if (fq == NULL) {
-		pr_debug("Can't find and can't create new queue\n");
-		goto ret_orig;
-	}
+	if (fq == NULL)
+		return skb;
 
 	spin_lock_bh(&fq->q.lock);
 
-	if (nf_ct_frag6_queue(fq, clone, fhdr, nhoff) < 0) {
+	if (nf_ct_frag6_queue(fq, skb, fhdr, nhoff) < 0) {
 		spin_unlock_bh(&fq->q.lock);
 		pr_debug("Can't insert skb to queue\n");
 		inet_frag_put(&fq->q, &nf_frags);
-		goto ret_orig;
+		return skb;
 	}
 
 	if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
@@ -626,25 +590,9 @@ struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 use
 
 	inet_frag_put(&fq->q, &nf_frags);
 	return ret_skb;
-
-ret_orig:
-	kfree_skb(clone);
-	return skb;
 }
 EXPORT_SYMBOL_GPL(nf_ct_frag6_gather);
 
-void nf_ct_frag6_consume_orig(struct sk_buff *skb)
-{
-	struct sk_buff *s, *s2;
-
-	for (s = NFCT_FRAG6_CB(skb)->orig; s;) {
-		s2 = s->next;
-		s->next = NULL;
-		consume_skb(s);
-		s = s2;
-	}
-}
-
 static int nf_ct_net_init(struct net *net)
 {
 	net->nf_frag.frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
@@ -673,7 +621,6 @@ int nf_ct_frag6_init(void)
 	nf_frags.hashfn = nf_hashfn;
 	nf_frags.constructor = ip6_frag_init;
 	nf_frags.destructor = NULL;
-	nf_frags.skb_free = nf_skb_free;
 	nf_frags.qsize = sizeof(struct frag_queue);
 	nf_frags.match = ip6_frag_match;
 	nf_frags.frag_expire = nf_ct_frag6_expire;
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 4fdbed5e..313c1d0 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -73,8 +73,6 @@ static unsigned int ipv6_defrag(void *priv,
 	if (reasm == skb)
 		return NF_ACCEPT;
 
-	nf_ct_frag6_consume_orig(reasm);
-
 	NF_HOOK_THRESH(NFPROTO_IPV6, state->hook, state->net, state->sk, reasm,
 		       state->in, state->out,
 		       state->okfn, NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
-- 
2.0.5

