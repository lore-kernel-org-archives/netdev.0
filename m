From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2] net: core: set and refine qdisc pkt len before tc_classify
Date: Wed, 13 May 2015 22:50:09 +0200
Message-ID: <1431550209-3498-1-git-send-email-daniel@iogearbox.net>
Cc: fw@strlen.de, ast@plumgrid.com, jhs@mojatatu.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50791 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965239AbbEMUu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 16:50:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Commit d2788d34885d4ce5ba ("net: sched: further simplify handle_ing")
removed the call to qdisc_enqueue_root(). However, after this removal
we no longer set qdisc pkt length, which this patch fixes. We make use
of qdisc_pkt_len_init() from 1def9238d4aa ("net_sched: more precise
pkt_len computation"), which was suggested as the current approach so
far does not take into account when GRO builds up GSO packets.

Fixes: d2788d34885d ("net: sched: further simplify handle_ing")
Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 v1->v2:
  - use qdisc_pkt_len_init() as suggested, thanks!

 net/core/dev.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 15e51a9..6e19521 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2787,8 +2787,8 @@ static void qdisc_pkt_len_init(struct sk_buff *skb)
 
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
 
-	/* To get more precise estimation of bytes sent on wire,
-	 * we add to pkt_len the headers size of all segments
+	/* To get more precise estimation of bytes sent/received on
+	 * wire, we add to pkt_len the headers size of all segments.
 	 */
 	if (shinfo->gso_size)  {
 		unsigned int hdr_len;
@@ -3541,9 +3541,11 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		*pt_prev = NULL;
 	}
 
-	qdisc_bstats_update_cpu(cl->q, skb);
+	qdisc_pkt_len_init(skb);
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
 
+	qdisc_bstats_update_cpu(cl->q, skb);
+
 	switch (tc_classify(skb, cl, &cl_res)) {
 	case TC_ACT_OK:
 	case TC_ACT_RECLASSIFY:
-- 
1.9.3
