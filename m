From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 2/3] net: make skb_gso_segment error handling more robust
Date: Mon, 20 Oct 2014 13:49:17 +0200
Message-ID: <1413805758-30026-3-git-send-email-fw@strlen.de>
References: <1413805758-30026-1-git-send-email-fw@strlen.de>
Cc: edumazet@google.com, therbert@google.com,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42246 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751238AbaJTLuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 07:50:21 -0400
In-Reply-To: <1413805758-30026-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_gso_segment has three possible return values:
1. a pointer to the first segmented skb
2. an errno value (IS_ERR())
3. NULL.  This can happen when GSO is used for header verification.

However, several callers currently test IS_ERR instead of IS_ERR_OR_NULL
and would oops when NULL is returned.

Note that these call sites should never actually see such a NULL return
value; all callers mask out the GSO bits in the feature argument.

However, there have been issues with some protocol handlers erronously not
respecting the specified feature mask in some cases.

It is preferable to get 'have to turn off hw offloading, else slow' reports
rather than 'kernel crashes'.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since v1:
  - don't return PTR_ERR(NULL).
  - update changelog to clarify that segs == NULL 'should not happen'.

 net/ipv4/ip_output.c                 | 2 +-
 net/netfilter/nfnetlink_queue_core.c | 2 +-
 net/openvswitch/datapath.c           | 2 ++
 net/xfrm/xfrm_output.c               | 2 ++
 4 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 88e5ef2..bc6471d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -231,7 +231,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 	 */
 	features = netif_skb_features(skb);
 	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
-	if (IS_ERR(segs)) {
+	if (IS_ERR_OR_NULL(segs)) {
 		kfree_skb(skb);
 		return -ENOMEM;
 	}
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index a82077d..7c60ccd 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -665,7 +665,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	 * returned by nf_queue.  For instance, callers rely on -ECANCELED to
 	 * mean 'ignore this hook'.
 	 */
-	if (IS_ERR(segs))
+	if (IS_ERR_OR_NULL(segs))
 		goto out_err;
 	queued = 0;
 	err = 0;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 2e31d9e..e6d7255 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -324,6 +324,8 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 	segs = __skb_gso_segment(skb, NETIF_F_SG, false);
 	if (IS_ERR(segs))
 		return PTR_ERR(segs);
+	if (segs == NULL)
+		return -EINVAL;
 
 	/* Queue all of the segments. */
 	skb = segs;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 499d6c1..7c53285 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -157,6 +157,8 @@ static int xfrm_output_gso(struct sk_buff *skb)
 	kfree_skb(skb);
 	if (IS_ERR(segs))
 		return PTR_ERR(segs);
+	if (segs == NULL)
+		return -EINVAL;
 
 	do {
 		struct sk_buff *nskb = segs->next;
-- 
2.0.4
