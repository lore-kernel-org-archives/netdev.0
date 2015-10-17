From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 4/4] netfilter: ipv6: avoid nf_iterate recursion
Date: Sat, 17 Oct 2015 22:14:25 +0200
Message-ID: <1445112865-31523-5-git-send-email-fw@strlen.de>
References: <1445112865-31523-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, azhou@nicira.com, joestringer@nicira.com,
	Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59659 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751753AbbJQUOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 16:14:44 -0400
In-Reply-To: <1445112865-31523-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous patch changed nf_ct_frag6_gather() to morph reassembled skb
with the previous one.

This means that the return value is always NULL or the skb argument.
So change it to an err value.

Instead of invoking NF_HOOK recursively with threshold to skip already-called hooks
we can now just return NF_ACCEPT to move on to the next hook except for
-EINPROGRESS (which means skb has been queued for reassembly), in which case we
return NF_STOLEN.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/netfilter/ipv6/nf_defrag_ipv6.h |  2 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c     | 68 ++++++++++++++---------------
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c   | 14 +++---
 net/openvswitch/conntrack.c                 | 11 +++--
 4 files changed, 43 insertions(+), 52 deletions(-)

diff --git a/include/net/netfilter/ipv6/nf_defrag_ipv6.h b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
index fcd20cf..ddf162f 100644
--- a/include/net/netfilter/ipv6/nf_defrag_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
@@ -5,7 +5,7 @@ void nf_defrag_ipv6_enable(void);
 
 int nf_ct_frag6_init(void);
 void nf_ct_frag6_cleanup(void);
-struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 user);
+int nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 user);
 
 struct inet_frags_ctl;
 
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 72ac916..b87dd75 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -361,14 +361,18 @@ err:
 
 /*
  *	Check if this packet is complete.
- *	Returns NULL on failure by any reason, and pointer
- *	to current nexthdr field in reassembled frame.
  *
  *	It is called with locked fq, and caller must check that
  *	queue is eligible for reassembly i.e. it is not COMPLETE,
  *	the last and the first frames arrived and all the bits are here.
+ *
+ *	returns true if *prev skb has been transformed into the reassembled
+ *	skb, false otherwise.
+ *
+ *	Note: If false is returned, *prev is still on the fragment queue, freeing
+ *	the queue is enough to discard *prev, too.
  */
-static struct sk_buff *
+static bool
 nf_ct_frag6_reasm(struct frag_queue *fq, struct sk_buff *prev,  struct net_device *dev)
 {
 	struct sk_buff *fp, *head = fq->q.fragments;
@@ -382,22 +386,21 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct sk_buff *prev,  struct net_devic
 
 	ecn = ip_frag_ecn_table[fq->ecn];
 	if (unlikely(ecn == 0xff))
-		goto out_fail;
+		return false;
 
 	/* Unfragmented part is taken from the first segment. */
 	payload_len = ((head->data - skb_network_header(head)) -
 		       sizeof(struct ipv6hdr) + fq->q.len -
 		       sizeof(struct frag_hdr));
 	if (payload_len > IPV6_MAXPLEN) {
-		pr_debug("payload len is too large.\n");
-		goto out_oversize;
+		net_dbg_ratelimited("nf_ct_frag6_reasm: payload len = %d\n",
+				    payload_len);
+		return false;
 	}
 
 	/* Head of list must not be cloned. */
-	if (skb_unclone(head, GFP_ATOMIC)) {
-		pr_debug("skb is cloned but can't expand head");
-		goto out_oom;
-	}
+	if (skb_unclone(head, GFP_ATOMIC))
+		return false;
 
 	/* If the first fragment is fragmented itself, we split
 	 * it to two chunks: the first with data and paged part
@@ -408,7 +411,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct sk_buff *prev,  struct net_devic
 
 		clone = alloc_skb(0, GFP_ATOMIC);
 		if (clone == NULL)
-			goto out_oom;
+			return false;
 
 		clone->next = head->next;
 		head->next = clone;
@@ -438,7 +441,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct sk_buff *prev,  struct net_devic
 
 		fp = skb_clone(prev, GFP_ATOMIC);
 		if (!fp)
-			goto out_oom;
+			return false;
 
 		fp->next = prev->next;
 		skb_queue_walk(head, iter) {
@@ -494,16 +497,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct sk_buff *prev,  struct net_devic
 	fq->q.fragments = NULL;
 	fq->q.fragments_tail = NULL;
 
-	return head;
-
-out_oversize:
-	net_dbg_ratelimited("nf_ct_frag6_reasm: payload len = %d\n",
-			    payload_len);
-	goto out_fail;
-out_oom:
-	net_dbg_ratelimited("nf_ct_frag6_reasm: no memory for reassembly\n");
-out_fail:
-	return NULL;
+	return true;
 }
 
 /*
@@ -569,27 +563,26 @@ find_prev_fhdr(struct sk_buff *skb, u8 *prevhdrp, int *prevhoff, int *fhoff)
 	return 0;
 }
 
-struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 user)
+int nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 user)
 {
 	struct net_device *dev = skb->dev;
+	int fhoff, nhoff, ret;
 	struct frag_hdr *fhdr;
 	struct frag_queue *fq;
 	struct ipv6hdr *hdr;
-	int fhoff, nhoff;
 	u8 prevhdr;
-	struct sk_buff *ret_skb = NULL;
 
 	/* Jumbo payload inhibits frag. header */
 	if (ipv6_hdr(skb)->payload_len == 0) {
 		pr_debug("payload len = 0\n");
-		return skb;
+		return -EINVAL;
 	}
 
 	if (find_prev_fhdr(skb, &prevhdr, &nhoff, &fhoff) < 0)
-		return skb;
+		return -EINVAL;
 
 	if (!pskb_may_pull(skb, fhoff + sizeof(*fhdr)))
-		return skb;
+		return -ENOMEM;
 
 	skb_set_transport_header(skb, fhoff);
 	hdr = ipv6_hdr(skb);
@@ -598,7 +591,7 @@ struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 use
 	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr,
 		     ip6_frag_ecn(hdr));
 	if (fq == NULL)
-		return skb;
+		return -ENOMEM;
 
 	spin_lock_bh(&fq->q.lock);
 
@@ -606,19 +599,22 @@ struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 use
 		spin_unlock_bh(&fq->q.lock);
 		pr_debug("Can't insert skb to queue\n");
 		inet_frag_put(&fq->q, &nf_frags);
-		return skb;
+		return -EINVAL;
 	}
 
+	/* after queue has assumed skb ownership, only 0 or -EINPROGRESS
+	 * must be returned.
+	 */
+	ret = -EINPROGRESS;
 	if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
-	    fq->q.meat == fq->q.len) {
-		ret_skb = nf_ct_frag6_reasm(fq, skb, dev);
-		if (ret_skb == NULL)
-			pr_debug("Can't reassemble fragmented packets\n");
-	}
+	    fq->q.meat == fq->q.len &&
+	    nf_ct_frag6_reasm(fq, skb, dev))
+		ret = 0;
+
 	spin_unlock_bh(&fq->q.lock);
 
 	inet_frag_put(&fq->q, &nf_frags);
-	return ret_skb;
+	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_ct_frag6_gather);
 
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index fb96b10..f7aab5a 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -55,7 +55,7 @@ static unsigned int ipv6_defrag(void *priv,
 				struct sk_buff *skb,
 				const struct nf_hook_state *state)
 {
-	struct sk_buff *reasm;
+	int err;
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	/* Previously seen (loopback)?	*/
@@ -63,17 +63,13 @@ static unsigned int ipv6_defrag(void *priv,
 		return NF_ACCEPT;
 #endif
 
-	reasm = nf_ct_frag6_gather(state->net, skb,
-				   nf_ct6_defrag_user(state->hook, skb));
+	err = nf_ct_frag6_gather(state->net, skb,
+				 nf_ct6_defrag_user(state->hook, skb));
 	/* queued */
-	if (reasm == NULL)
+	if (err == -EINPROGRESS)
 		return NF_STOLEN;
 
-	NF_HOOK_THRESH(NFPROTO_IPV6, state->hook, state->net, state->sk, reasm,
-		       state->in, state->out,
-		       state->okfn, NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
-
-	return NF_STOLEN;
+	return NF_ACCEPT;
 }
 
 static struct nf_hook_ops ipv6_defrag_ops[] = {
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 30ece1d..b42630d 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -298,10 +298,10 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
 			    u16 zone, struct sk_buff *skb)
 {
 	struct ovs_skb_cb ovs_cb = *OVS_CB(skb);
+	int err;
 
 	if (key->eth.type == htons(ETH_P_IP)) {
 		enum ip_defrag_users user = IP_DEFRAG_CONNTRACK_IN + zone;
-		int err;
 
 		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
 		err = ip_defrag(net, skb, user);
@@ -312,14 +312,13 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
 	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
 		enum ip6_defrag_users user = IP6_DEFRAG_CONNTRACK_IN + zone;
-		struct sk_buff *reasm;
 
 		memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
-		reasm = nf_ct_frag6_gather(net, skb, user);
-		if (!reasm)
-			return -EINPROGRESS;
+		err = nf_ct_frag6_gather(net, skb, user);
+		if (err)
+			return err;
 
-		key->ip.proto = ipv6_hdr(reasm)->nexthdr;
+		key->ip.proto = ipv6_hdr(skb)->nexthdr;
 		ovs_cb.mru = IP6CB(skb)->frag_max_size;
 #else
 		return -EPFNOSUPPORT;
-- 
2.0.5
