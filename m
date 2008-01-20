From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/4] dsmark: handle cloned and non-linear skb's
Date: Sun, 20 Jan 2008 13:23:54 -0800
Message-ID: <20080120132354.55de46ed@deepthought>
References: <20080120131008.2039a35d@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:38689 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755386AbYATVaf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 16:30:35 -0500
In-Reply-To: <20080120131008.2039a35d@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make dsmark work properly with non-linear and cloned skb's
Before modifying the header, it needs to check that skb header is
writeable.

Note: this makes the assumption, that if it queues a good skb
then a good skb will come out of the embedded qdisc.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/sch_dsmark.c	2008-01-20 13:22:54.000000000 -0800
+++ b/net/sched/sch_dsmark.c	2008-01-20 13:23:34.000000000 -0800
@@ -192,13 +192,19 @@ static int dsmark_enqueue(struct sk_buff
 	pr_debug("dsmark_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
 
 	if (p->set_tc_index) {
-		/* FIXME: Safe with non-linear skbs? --RR */
 		switch (skb->protocol) {
 			case __constant_htons(ETH_P_IP):
+				if (skb_cow_head(skb, sizeof(struct iphdr)))
+					goto drop;
+
 				skb->tc_index = ipv4_get_dsfield(ip_hdr(skb))
 					& ~INET_ECN_MASK;
 				break;
+
 			case __constant_htons(ETH_P_IPV6):
+				if (skb_cow_head(skb, sizeof(struct ipv6hdr)))
+					goto drop;
+
 				skb->tc_index = ipv6_get_dsfield(ipv6_hdr(skb))
 					& ~INET_ECN_MASK;
 				break;
@@ -222,14 +228,14 @@ static int dsmark_enqueue(struct sk_buff
 		case TC_ACT_STOLEN:
 			kfree_skb(skb);
 			return NET_XMIT_SUCCESS;
+
 		case TC_ACT_SHOT:
-			kfree_skb(skb);
-			sch->qstats.drops++;
-			return NET_XMIT_BYPASS;
+			goto drop;
 #endif
 		case TC_ACT_OK:
 			skb->tc_index = TC_H_MIN(res.classid);
 			break;
+
 		default:
 			if (p->default_index != NO_DEFAULT_INDEX)
 				skb->tc_index = p->default_index;
@@ -248,6 +254,11 @@ static int dsmark_enqueue(struct sk_buff
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
+
+drop:
+	kfree_skb(skb);
+	sch->qstats.drops++;
+	return NET_XMIT_BYPASS;
 }
 
 static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
