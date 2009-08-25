From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 / tbf with large burst seems broken again
Date: Tue, 25 Aug 2009 09:41:20 +0000
Message-ID: <20090825094120.GA11478@ff.dom.local>
References: <20090825062203.GA5381@ff.dom.local> <200908251034.09581.denys@visp.net.lb> <20090825084306.GA7879@ff.dom.local> <20090825090035.GB7879@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:51273 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbZHYJlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 05:41:25 -0400
Received: by fxm17 with SMTP id 17so1943313fxm.37
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 02:41:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090825090035.GB7879@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2009 at 09:00:35AM +0000, Jarek Poplawski wrote:
> On Tue, Aug 25, 2009 at 08:43:06AM +0000, Jarek Poplawski wrote:
> ...
> > since these 64 bits will be needed soon for higher rates anyway, I
> > guess we could try some change like the patch below, if you find it
> > works for you (I didn't test it yet.)

I hope this time it works...

Jarek P.

--- (take 2)

 net/sched/sch_tbf.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index e22dfe8..7d0fe69 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -108,8 +108,8 @@ struct tbf_sched_data
 	struct qdisc_rate_table	*P_tab;
 
 /* Variables */
-	long	tokens;			/* Current number of B tokens */
-	long	ptokens;		/* Current number of P tokens */
+	u32	tokens;			/* Current number of B tokens */
+	u32	ptokens;		/* Current number of P tokens */
 	psched_time_t	t_c;		/* Time check-point */
 	struct Qdisc	*qdisc;		/* Inner qdisc, default - bfifo queue */
 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
@@ -160,21 +160,21 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 
 	if (skb) {
 		psched_time_t now;
-		long toks;
-		long ptoks = 0;
+		long long toks;
+		long long ptoks = 0;
 		unsigned int len = qdisc_pkt_len(skb);
 
 		now = psched_get_time();
-		toks = psched_tdiff_bounded(now, q->t_c, q->buffer);
+		toks = min_t(u32, now - q->t_c, q->buffer);
 
 		if (q->P_tab) {
 			ptoks = toks + q->ptokens;
-			if (ptoks > (long)q->mtu)
+			if (ptoks > q->mtu)
 				ptoks = q->mtu;
 			ptoks -= L2T_P(q, len);
 		}
 		toks += q->tokens;
-		if (toks > (long)q->buffer)
+		if (toks > q->buffer)
 			toks = q->buffer;
 		toks -= L2T(q, len);
 
