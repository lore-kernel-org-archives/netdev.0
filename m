From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 5/3] pkt_sched: sch_htb: Replace HTB_ACCNT() macro with
	inlines
Date: Wed, 3 Dec 2008 10:07:38 +0000
Message-ID: <20081203100738.GA16755@ff.dom.local>
References: <20081202085648.GC10412@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:55907 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbYLCKHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 05:07:44 -0500
Received: by ey-out-2122.google.com with SMTP id 6so1464940eyi.37
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2008 02:07:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081202085648.GC10412@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace HTB_ACCNT() macro with inlines to make it more readable.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_htb.c |   38 +++++++++++++++++++++++++++++---------
 1 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index fcd06e2..f89fd71 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -577,6 +577,32 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 }
 
+static inline void htb_accnt_tokens(struct htb_class *cl, int bytes, long diff)
+{
+	long toks = diff + cl->tokens;
+
+	if (toks > cl->buffer)
+		toks = cl->buffer;
+	toks -= (long) qdisc_l2t(cl->rate, bytes);
+	if (toks <= -cl->mbuffer)
+		toks = 1 - cl->mbuffer;
+
+	cl->tokens = toks;
+}
+
+static inline void htb_accnt_ctokens(struct htb_class *cl, int bytes, long diff)
+{
+	long toks = diff + cl->ctokens;
+
+	if (toks > cl->cbuffer)
+		toks = cl->cbuffer;
+	toks -= (long) qdisc_l2t(cl->ceil, bytes);
+	if (toks <= -cl->mbuffer)
+		toks = 1 - cl->mbuffer;
+
+	cl->ctokens = toks;
+}
+
 /**
  * htb_charge_class - charges amount "bytes" to leaf and ancestors
  *
@@ -592,26 +618,20 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 			     int level, struct sk_buff *skb)
 {
 	int bytes = qdisc_pkt_len(skb);
-	long toks, diff;
 	enum htb_cmode old_mode;
-
-#define HTB_ACCNT(T,B,R) toks = diff + cl->T; \
-	if (toks > cl->B) toks = cl->B; \
-	toks -= (long) qdisc_l2t(cl->R, bytes); \
-	if (toks <= -cl->mbuffer) toks = 1-cl->mbuffer; \
-	cl->T = toks
+	long diff;
 
 	while (cl) {
 		diff = psched_tdiff_bounded(q->now, cl->t_c, cl->mbuffer);
 		if (cl->level >= level) {
 			if (cl->level == level)
 				cl->xstats.lends++;
-			HTB_ACCNT(tokens, buffer, rate);
+			htb_accnt_tokens(cl, bytes, diff);
 		} else {
 			cl->xstats.borrows++;
 			cl->tokens += diff;	/* we moved t_c; update tokens */
 		}
-		HTB_ACCNT(ctokens, cbuffer, ceil);
+		htb_accnt_ctokens(cl, bytes, diff);
 		cl->t_c = q->now;
 
 		old_mode = cl->cmode;
