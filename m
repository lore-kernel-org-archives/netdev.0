From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 31/54] skge: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:17 -0700
Message-ID: <1395727540-12148-31-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59057 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbaCYGL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:29 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_kfree_skb_any skge_xmit_free that can
be called in hard irq and other contexts, on the path that
handles dropped packets.

Replace dev_kfree_skb with dev_consume_skb_any in skge_tx_done that can
be called in hard irq and other contexts, on the path that handles
successfully transmitted skbs.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/marvell/skge.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 597846193869..7f81ae66cc89 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -2845,7 +2845,7 @@ mapping_unwind:
 mapping_error:
 	if (net_ratelimit())
 		dev_warn(&hw->pdev->dev, "%s: tx mapping error\n", dev->name);
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
 }
 
@@ -3172,7 +3172,7 @@ static void skge_tx_done(struct net_device *dev)
 			pkts_compl++;
 			bytes_compl += e->skb->len;
 
-			dev_kfree_skb(e->skb);
+			dev_consume_skb_any(e->skb);
 		}
 	}
 	netdev_completed_queue(dev, pkts_compl, bytes_compl);
-- 
1.7.10.4
