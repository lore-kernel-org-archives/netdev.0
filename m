From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH] tbf scheduler: TSO support (updated)
Date: Sun, 13 May 2007 21:42:36 +0900 (JST)
Message-ID: <20070513.214236.130588832.taka@valinux.co.jp>
References: <20070511.130142.16832866.taka@valinux.co.jp>
	<4644B259.5060400@trash.net>
	<20070512.174930.80276554.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net, linux-net@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fms-01.valinux.co.jp ([210.128.90.1]:38183 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757026AbXEMMml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2007 08:42:41 -0400
In-Reply-To: <20070512.174930.80276554.taka@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> I'm now thinking I can make it just hold a TSO packet until p->tokens
> reaches the size of the packet. I think it is straightforward
> implementation. I'll try this.

I re-implemented the patch, which is simpler than the previous one.

sch->dev->mtu is used to determine how many segments are included
in a TSO packet. The point is that the value of sch->dev->mtu has to
be treated possibly broken because it is set by administrators.

Thanks,
Hirokazu Takahashi.


Signed-off-by: Hirokazu Takahashi <taka@valinux.co.jp>

--- linux-2.6.21/net/sched/sch_tbf.c.ORG	2007-05-08 20:59:28.000000000 +0900
+++ linux-2.6.21/net/sched/sch_tbf.c	2007-05-13 14:22:39.000000000 +0900
@@ -9,7 +9,8 @@
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
  *		Dmitry Torokhov <dtor@mail.ru> - allow attaching inner qdiscs -
  *						 original idea by Martin Devera
- *
+ * Fixes:
+ * 		Hirokazu Takahashi <taka@valinux.co.jp> : TSO support
  */
 
 #include <linux/module.h>
@@ -139,7 +140,7 @@ static int tbf_enqueue(struct sk_buff *s
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if (skb->len > q->max_size) {
+	if (skb->len > q->max_size && !(sch->dev->features & NETIF_F_GSO_MASK)) {
 		sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_POLICE
 		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
@@ -205,6 +206,16 @@ static struct sk_buff *tbf_dequeue(struc
 		long toks, delay;
 		long ptoks = 0;
 		unsigned int len = skb->len;
+		/*
+		 * Note: TSO packets will be larger than its actual mtu.
+		 * These packets should be treated as packets including
+		 * several ordinary ones. In this case, tokens should
+		 * be held until it reaches the length of them.
+		 */
+		long max_toks = max(len, q->buffer);
+		unsigned int rmtu = sch->dev->mtu? min(q->max_size, sch->dev->mtu) : q->max_size;
+		unsigned int segs = len/rmtu;
+		unsigned int rest = len - rmtu*segs;
 
 		PSCHED_GET_TIME(now);
 
@@ -212,14 +223,18 @@ static struct sk_buff *tbf_dequeue(struc
 
 		if (q->P_tab) {
 			ptoks = toks + q->ptokens;
-			if (ptoks > (long)q->mtu)
-				ptoks = q->mtu;
-			ptoks -= L2T_P(q, len);
+			if (ptoks > (long)(q->mtu * (segs + !!rest)))
+				ptoks = q->mtu * (segs + !!rest);
+			ptoks -= L2T_P(q, rmtu) * segs;
+			if (rest)
+				ptoks -= L2T_P(q, rest);
 		}
 		toks += q->tokens;
-		if (toks > (long)q->buffer)
-			toks = q->buffer;
-		toks -= L2T(q, len);
+		if (toks > max_toks)
+			toks = max_toks;
+		toks -= L2T(q, rmtu) * segs;
+		if (rest)
+			toks -= L2T(q, rest);
 
 		if ((toks|ptoks) >= 0) {
 			q->t_c = now;
