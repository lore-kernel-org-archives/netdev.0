From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 11/11] gianfar: Carefully free skbs in functions called by netpoll.
Date: Mon, 10 Mar 2014 20:24:47 -0700
Message-ID: <87iorlo1s0.fsf_-_@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<871ty9qvaf.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:37708 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbaCKDYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:24:53 -0400
In-Reply-To: <871ty9qvaf.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 10 Mar 2014 20:16:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


netpoll can call functions in hard irq context that are ordinarily
called in lesser contexts.  For those functions use dev_kfree_skb_any
and dev_consume_skb_any so skbs are freed safely from hard irq context.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index c5b9320f7629..9ab00ba6b580 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2146,13 +2146,13 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		skb_new = skb_realloc_headroom(skb, fcb_len);
 		if (!skb_new) {
 			dev->stats.tx_errors++;
-			kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			return NETDEV_TX_OK;
 		}
 
 		if (skb->sk)
 			skb_set_owner_w(skb_new, skb->sk);
-		consume_skb(skb);
+		dev_consume_skb_any(skb);
 		skb = skb_new;
 	}
 
@@ -2744,7 +2744,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 			if (unlikely(!newskb))
 				newskb = skb;
 			else if (skb)
-				dev_kfree_skb(skb);
+				dev_kfree_skb_any(skb);
 		} else {
 			/* Increment the number of packets */
 			rx_queue->stats.rx_packets++;
-- 
1.7.5.4
