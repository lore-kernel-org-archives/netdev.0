From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next v3] net: core: set qdisc pkt len before tc_classify
Date: Thu, 14 May 2015 00:36:28 +0200
Message-ID: <1431556588-4859-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44704 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965319AbbEMWgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 18:36:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d2788d34885d4ce5ba ("net: sched: further simplify handle_ing")
removed the call to qdisc_enqueue_root().

However, after this removal we no longer set qdisc pkt length.
This breaks traffic policing on ingress.

This is the minimum fix: set qdisc pkt length before tc_classify.

Only setting the length does remove support for 'stab' on ingress, but
as Alexei pointed out:
 "Though it was allowed to add qdisc_size_table to ingress, it's useless.
  Nothing takes advantage of recomputed qdisc_pkt_len".

Jamal suggested to use qdisc_pkt_len_init(), but as Eric mentioned that
would result in qdisc_pkt_len_init to no longer get inlined due to the
additional 2nd call site.

ingress policing is rare and GRO doesn't really work that well with police
on ingress, as we see packets > mtu and drop skbs that  -- without
aggregation -- would still have fitted the policier budget.
Thus to have reliable/smooth ingress policing GRO has to be turned off.

Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Fixes: d2788d34885d ("net: sched: further simplify handle_ing")
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
Changes since v2: identical to v1: just use skb->len
Changes since v1: use qdisc_pkt_len_init instead of simply using skb->len

diff --git a/net/core/dev.c b/net/core/dev.c
index af54906..b3a92d6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3646,8 +3646,9 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
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
