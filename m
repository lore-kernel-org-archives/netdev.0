From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/4] net: make skb_gso_segment error handling more robust
Date: Sun, 19 Oct 2014 22:42:19 +0200
Message-ID: <1413751340-19621-3-git-send-email-fw@strlen.de>
References: <1413751340-19621-1-git-send-email-fw@strlen.de>
Cc: edumazet@google.com, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41335 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751672AbaJSUmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 16:42:37 -0400
In-Reply-To: <1413751340-19621-1-git-send-email-fw@strlen.de>
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

However, in the past, there have been issues with some protocol handlers
erronously not respecting the specified feature mask in some cases.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/ip_output.c                 | 2 +-
 net/netfilter/nfnetlink_queue_core.c | 2 +-
 net/openvswitch/datapath.c           | 2 +-
 net/xfrm/xfrm_output.c               | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e35b712..88a0ee3 100644
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
index 2e31d9e..f98f708 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -322,7 +322,7 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 	int err;
 
 	segs = __skb_gso_segment(skb, NETIF_F_SG, false);
-	if (IS_ERR(segs))
+	if (IS_ERR_OR_NULL(segs))
 		return PTR_ERR(segs);
 
 	/* Queue all of the segments. */
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 499d6c1..eef4334 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -155,7 +155,7 @@ static int xfrm_output_gso(struct sk_buff *skb)
 
 	segs = skb_gso_segment(skb, 0);
 	kfree_skb(skb);
-	if (IS_ERR(segs))
+	if (IS_ERR_OR_NULL(segs))
 		return PTR_ERR(segs);
 
 	do {
-- 
2.0.4
