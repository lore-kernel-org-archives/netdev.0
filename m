From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH 2/2] tbf scheduler: TSO support (update 3)
Date: Wed, 23 May 2007 20:49:27 +0900 (JST)
Message-ID: <20070523.204927.82096100.taka@valinux.co.jp>
References: <20070517135530.GA4381@gondor.apana.org.au>
	<20070518.113507.41839122.taka@valinux.co.jp>
	<20070523.204707.130275215.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, linux-net@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from fms-01.valinux.co.jp ([210.128.90.1]:46920 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759712AbXEWLt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 07:49:29 -0400
In-Reply-To: <20070523.204707.130275215.taka@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch is as same as the previous one.
I just cleaned up some code.

Thanks,
Hirokazu Takahashi.

Signed-off-by: Hirokazu Takahashi <taka@valinux.co.jp>

--- linux-2.6.21/net/sched/sch_tbf.c.ORG	2007-05-08 20:59:28.000000000 +0900
+++ linux-2.6.21/net/sched/sch_tbf.c	2007-05-21 21:05:18.000000000 +0900
@@ -9,7 +9,8 @@
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
  *		Dmitry Torokhov <dtor@mail.ru> - allow attaching inner qdiscs -
  *						 original idea by Martin Devera
- *
+ * Fixes:
+ * 		Hirokazu Takahashi <taka@valinux.co.jp> : TSO support
  */
 
 #include <linux/module.h>
@@ -138,8 +139,11 @@ static int tbf_enqueue(struct sk_buff *s
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
+	unsigned int segs = skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs ? :
+		skb->len/skb_shinfo(skb)->gso_size + 1 : 1;
+	unsigned int len = (skb->len - 1)/segs + 1;
 
-	if (skb->len > q->max_size) {
+	if (len > q->max_size) {
 		sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_POLICE
 		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
@@ -204,22 +208,40 @@ static struct sk_buff *tbf_dequeue(struc
 		psched_time_t now;
 		long toks, delay;
 		long ptoks = 0;
-		unsigned int len = skb->len;
+		/*
+		 * Note: TSO packets will be larger than its actual mtu.
+		 * These packets should be treated as packets including
+		 * several ordinary ones. In this case, tokens should
+		 * be held until it reaches the length of them.
+		 *
+		 * To simplify, we assume each segment in a TSO packet
+		 * has the same length though it may probably not be true.
+		 * And ignore the length of headers which will be applied
+		 * to each segment when splitting TSO packets.
+		 * 
+		 * The number of segments are calculated from the segment
+		 * size of TSO packets temporarily if it isn't set.
+		 */
+		unsigned int segs = skb_shinfo(skb)->gso_segs ? :
+		  skb_is_gso(skb) ? skb->len/skb_shinfo(skb)->gso_size + 1 : 1;
+		unsigned int len = (skb->len - 1)/segs + 1;
+		unsigned int expect = L2T(q, len) * segs;
+		long max_toks = max(expect, q->buffer);
 
 		PSCHED_GET_TIME(now);
 
-		toks = PSCHED_TDIFF_SAFE(now, q->t_c, q->buffer);
+		toks = PSCHED_TDIFF_SAFE(now, q->t_c, max_toks);
 
 		if (q->P_tab) {
 			ptoks = toks + q->ptokens;
-			if (ptoks > (long)q->mtu)
-				ptoks = q->mtu;
-			ptoks -= L2T_P(q, len);
+			if (ptoks > (long)(q->mtu * segs))
+				ptoks = q->mtu * segs;
+			ptoks -= L2T_P(q, len) * segs;
 		}
 		toks += q->tokens;
-		if (toks > (long)q->buffer)
-			toks = q->buffer;
-		toks -= L2T(q, len);
+		if (toks > max_toks)
+			toks = max_toks;
+		toks -= expect;
 
 		if ((toks|ptoks) >= 0) {
 			q->t_c = now;

