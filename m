From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH] tbf scheduler: TSO support
Date: Fri, 11 May 2007 01:00:30 +0900 (JST)
Message-ID: <20070511.010030.06784245.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fms-01.valinux.co.jp ([210.128.90.1]:41287 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753043AbXEJQAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 12:00:32 -0400
Received: from localhost (vagw.valinux.co.jp [210.128.90.14])
	by mail.valinux.co.jp (Postfix) with ESMTP id C39182DC82E
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 01:00:30 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

TBF --- Simple Token Bucket Filter --- packet scheduler doesn't
work correctly with TSO on that it slows down to send out packets.
TSO packets will be discarded since the size can be larger than
the scheduler expects. But it won't cause serious problems
because the retransmitted packets can be passed.

So I made the scheduler allow to pass TSO packets:

 - tbf_enqueue() accepts packets with any size if the netdevice
   has TSO ability.

 - tbf_dequeue() can handle the packets whose size is larger than
   the bucket, which keeps tokens.
   Any packet, which may be TSO packet, can be sent if the bucket is
   full of tokens. this may lead that the number of tokens in
   the bucket turns into negative value, which means kind of debt.
   But we don't have to mind it because this will be filled up
   with tokens in a short time and it will turns into positive value
   again.

I'm not sure if this approach is the best. I appreciate any comments.
Thank you.


Signed-off-by: Hirokazu Takahashi <taka@valinux.co.jp>

--- linux-2.6.21/net/sched/sch_tbf.c.ORG	2007-05-08 20:59:28.000000000 +0900
+++ linux-2.6.21/net/sched/sch_tbf.c	2007-05-10 16:12:54.000000000 +0900
@@ -139,7 +139,7 @@ static int tbf_enqueue(struct sk_buff *s
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if (skb->len > q->max_size) {
+	if (skb->len > q->max_size && !(sch->dev->features & NETIF_F_GSO_MASK)) {
 		sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_POLICE
 		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
@@ -197,6 +197,7 @@ static struct sk_buff *tbf_dequeue(struc
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
+	int full = 0;
 
 	skb = q->qdisc->dequeue(q->qdisc);
 
@@ -204,7 +205,8 @@ static struct sk_buff *tbf_dequeue(struc
 		psched_time_t now;
 		long toks, delay;
 		long ptoks = 0;
-		unsigned int len = skb->len;
+		unsigned int len;
+		int n;
 
 		PSCHED_GET_TIME(now);
 
@@ -212,16 +214,26 @@ static struct sk_buff *tbf_dequeue(struc
 
 		if (q->P_tab) {
 			ptoks = toks + q->ptokens;
-			if (ptoks > (long)q->mtu)
+			if (ptoks >= (long)q->mtu) {
 				ptoks = q->mtu;
-			ptoks -= L2T_P(q, len);
+				full = 1;
+			}
+			for (len = skb->len; len > 0; len -= n) {
+				n = min(q->max_size, len);
+				ptoks -= L2T_P(q, n);
+			}
 		}
 		toks += q->tokens;
-		if (toks > (long)q->buffer)
+		if (toks >= (long)q->buffer) {
 			toks = q->buffer;
-		toks -= L2T(q, len);
+			full = 1;
+		}
+		for (len = skb->len; len > 0; len -= n) {
+			n = min(q->max_size, len);
+			toks -= L2T(q, n);
+		}
 
-		if ((toks|ptoks) >= 0) {
+		if ((toks|ptoks) >= 0 || full) {
 			q->t_c = now;
 			q->tokens = toks;
 			q->ptokens = ptoks;
