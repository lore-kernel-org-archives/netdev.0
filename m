From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/1] netfilter: nf_queue: fix queueing of bridged gro skbs
Date: Thu, 9 Feb 2012 17:37:01 +0100
Message-ID: <20120209163701.GB14772@Chamillionaire.breakpoint.cc>
References: <1328530990-6782-1-git-send-email-fw@strlen.de>
 <20120209154421.GA5865@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120209154421.GA5865@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:

[ CC'd Herbert ]

> On Mon, Feb 06, 2012 at 01:23:10PM +0100, Florian Westphal wrote:
> > When trying to nf_queue GRO/GSO skbs, nf_queue uses skb_gso_segment
> > to split the skb.
> > 
> > However, if nf_queue is called via bridge netfilter, the mac header
> > won't be preserved -- packets will thus contain a bogus mac header.
> > 
> > Fix this by setting skb->data to the mac header when skb->nf_bridge
> > is set and restoring skb->data afterwards for all segments.
> 
> Better fix skb_gso_segment to handle this case?

I don't see how -- is skb_gso_segment broken?

It treats skb->data as the starting point of the
segmentation, so I think its the callers job to make skb->data
point at the right place (network header, mac header, ...)

How would skb_gso_segment know where it should start?
Changing skb_gso_segment to use skb_mac_header() as starting
point doesn't really help: What if you don't want to copy the mac header/no
mac header exists (yet)?

Also, br_netfilter skb_pull()s the MAC header (and also the vlan header if
brnf_filter_vlan_tagged sysctl is on), so skb->len has been reduced.

Herbert, dou you have any opionion on this?

The only other alternative that I see is to declare
'GRO + bridge + NF_QUEUE as unsupported' and just tell people to
turn GRO off (ie., add a printk_once warning in nf_queue).

For reference, the discussed patch is below:

index b3a7db6..ce60cf0 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -203,6 +203,27 @@ err:
 	return status;
 }
 
+#ifdef CONFIG_BRIDGE_NETFILTER
+/* When called from bridge netfilter, skb->data must point to MAC header
+ * before calling skb_gso_segment(). Else, original MAC header is lost
+ * and segmented skbs will be sent to wrong destination.
+ */
+static void nf_bridge_adjust_skb_data(struct sk_buff *skb)
+{
+	if (skb->nf_bridge)
+		__skb_push(skb, skb->network_header - skb->mac_header);
+}
+
+static void nf_bridge_adjust_segmented_data(struct sk_buff *skb)
+{
+	if (skb->nf_bridge)
+		__skb_pull(skb, skb->network_header - skb->mac_header);
+}
+#else
+#define nf_bridge_adjust_skb_data(s) do {} while (0)
+#define nf_bridge_adjust_segmented_data(s) do {} while (0)
+#endif
+
 int nf_queue(struct sk_buff *skb,
 	     struct list_head *elem,
 	     u_int8_t pf, unsigned int hook,
@@ -212,7 +233,7 @@ int nf_queue(struct sk_buff *skb,
 	     unsigned int queuenum)
 {
 	struct sk_buff *segs;
-	int err;
+	int err = -EINVAL;
 	unsigned int queued;
 
 	if (!skb_is_gso(skb))
@@ -228,23 +249,25 @@ int nf_queue(struct sk_buff *skb,
 		break;
 	}
 
+	nf_bridge_adjust_skb_data(skb);
 	segs = skb_gso_segment(skb, 0);
 	/* Does not use PTR_ERR to limit the number of error codes that can be
 	 * returned by nf_queue.  For instance, callers rely on -ECANCELED to mean
 	 * 'ignore this hook'.
 	 */
 	if (IS_ERR(segs))
-		return -EINVAL;
-
+		goto out_err;
 	queued = 0;
 	err = 0;
 	do {
 		struct sk_buff *nskb = segs->next;
 
 		segs->next = NULL;
-		if (err == 0)
+		if (err == 0) {
+			nf_bridge_adjust_segmented_data(segs);
 			err = __nf_queue(segs, elem, pf, hook, indev,
 					   outdev, okfn, queuenum);
+		}
 		if (err == 0)
 			queued++;
 		else
@@ -252,11 +275,12 @@ int nf_queue(struct sk_buff *skb,
 		segs = nskb;
 	} while (segs);
 
-	/* also free orig skb if only some segments were queued */
-	if (unlikely(err && queued))
-		err = 0;
-	if (err == 0)
+	if (queued) {
 		kfree_skb(skb);
+		return 0;
+	}
+  out_err:
+	nf_bridge_adjust_segmented_data(skb);
 	return err;
 }
 
