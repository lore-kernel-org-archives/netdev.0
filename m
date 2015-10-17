From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 3/4] netfilter: ipv6: in-place replacement of last skb
Date: Sat, 17 Oct 2015 22:14:24 +0200
Message-ID: <1445112865-31523-4-git-send-email-fw@strlen.de>
References: <1445112865-31523-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, azhou@nicira.com, joestringer@nicira.com,
	Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59657 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751600AbbJQUOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 16:14:43 -0400
In-Reply-To: <1445112865-31523-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

openvswitch attempts to morph the reassembled skb with the currently
processed one.  But this looks broken -- the currently processed skb
is part of the reassembled skbs frag_list.

IOW, we morph an element of reasms frag_list into reasm itself, then
free said frag_list element.

This allows callers to process skb as intended by openvswitch: we either
return NULL (skb queued for reassembly), or turn the provided skb into
a reassembled one.

A followup patch will change nf_defrag to avoid the NF_HOOK recursion
which is now no longer needed.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c   | 33 +++++++++++++++++++++++++++++--
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c |  4 ----
 net/openvswitch/conntrack.c               |  5 -----
 3 files changed, 31 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 1b1a851..72ac916 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -369,7 +369,7 @@ err:
  *	the last and the first frames arrived and all the bits are here.
  */
 static struct sk_buff *
-nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
+nf_ct_frag6_reasm(struct frag_queue *fq, struct sk_buff *prev,  struct net_device *dev)
 {
 	struct sk_buff *fp, *head = fq->q.fragments;
 	int    payload_len;
@@ -425,6 +425,35 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 		add_frag_mem_limit(fq->q.net, clone->truesize);
 	}
 
+	/* morph head into last received skb: prev.
+	 *
+	 * This allows callers of ipv6 conntrack defrag to continue
+	 * to use the last skb(frag) passed into the reasm engine.
+	 * The last skb frag 'silently' turns into the full reassembled skb.
+	 *
+	 * Since prev is also part of q->fragments we have to clone it first.
+	 */
+	if (head != prev) {
+		struct sk_buff *iter;
+
+		fp = skb_clone(prev, GFP_ATOMIC);
+		if (!fp)
+			goto out_oom;
+
+		fp->next = prev->next;
+		skb_queue_walk(head, iter) {
+			if (iter->next != prev)
+				continue;
+			iter->next = fp;
+			break;
+		}
+
+		skb_morph(prev, head);
+		prev->next = head->next;
+		consume_skb(head);
+		head = prev;
+	}
+
 	/* We have to remove fragment header from datagram and to relocate
 	 * header in order to calculate ICV correctly. */
 	skb_network_header(head)[fq->nhoffset] = skb_transport_header(head)[0];
@@ -582,7 +611,7 @@ struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 use
 
 	if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    fq->q.meat == fq->q.len) {
-		ret_skb = nf_ct_frag6_reasm(fq, dev);
+		ret_skb = nf_ct_frag6_reasm(fq, skb, dev);
 		if (ret_skb == NULL)
 			pr_debug("Can't reassemble fragmented packets\n");
 	}
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 313c1d0..fb96b10 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -69,10 +69,6 @@ static unsigned int ipv6_defrag(void *priv,
 	if (reasm == NULL)
 		return NF_STOLEN;
 
-	/* error occurred or not fragmented */
-	if (reasm == skb)
-		return NF_ACCEPT;
-
 	NF_HOOK_THRESH(NFPROTO_IPV6, state->hook, state->net, state->sk, reasm,
 		       state->in, state->out,
 		       state->okfn, NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index ad61426..30ece1d 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -319,12 +319,7 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
 		if (!reasm)
 			return -EINPROGRESS;
 
-		if (skb == reasm)
-			return -EINVAL;
-
 		key->ip.proto = ipv6_hdr(reasm)->nexthdr;
-		skb_morph(skb, reasm);
-		consume_skb(reasm);
 		ovs_cb.mru = IP6CB(skb)->frag_max_size;
 #else
 		return -EPFNOSUPPORT;
-- 
2.0.5
