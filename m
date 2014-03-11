From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 10/10] gianfar: Carefully free skbs in functions called by netpoll.
Date: Tue, 11 Mar 2014 14:20:26 -0700
Message-ID: <877g80a0v9.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<87r468bfqj.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:41759 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644AbaCKVUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:20:30 -0400
In-Reply-To: <87r468bfqj.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 14:13:56 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


netpoll can call functions in hard irq context that are ordinarily
called in lesser contexts.  For those functions use dev_kfree_skb_any
and dev_consume_skb_any so skbs are freed safely from hard irq
context.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index c5b9320f7629..4d000f844390 100644
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
 
-- 
1.7.5.4
