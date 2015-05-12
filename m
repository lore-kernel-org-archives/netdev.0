From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] net: core: set qdisc pkt len before tc_classify
Date: Tue, 12 May 2015 15:37:18 +0200
Message-ID: <1431437838-5478-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40087 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932641AbbELNh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 09:37:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d2788d34885d4ce5ba ("net: sched: further simplify handle_ing")
removed the call to qdisc_enqueue_root().

However, after this removal we no longer set qdisc pkt length.
This breaks traffic policing on ingress.

Daniel re-ran his test with this patch applied and reports that
while there is a small performance hit the total gain vs. before
d2788d34885d4ce5ba is still consistently higher than 1Mpps.

Fixes: d2788d34885d ("net: sched: further simplify handle_ing")
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/dev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index e5f77c4..871181a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3540,8 +3540,9 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		*pt_prev = NULL;
 	}
 
-	qdisc_bstats_update_cpu(cl->q, skb);
+	qdisc_skb_cb(skb)->pkt_len = skb->len;
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
+	qdisc_bstats_update_cpu(cl->q, skb);
 
 	switch (tc_classify(skb, cl, &cl_res)) {
 	case TC_ACT_OK:
-- 
2.0.5
