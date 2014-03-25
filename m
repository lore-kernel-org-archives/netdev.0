From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 40/54] smc91x: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:26 -0700
Message-ID: <1395727540-12148-40-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58553 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbaCYGLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:38 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in
smc_hardware_send_pkt that can be called in hard irq and other
contexts, and handles successfully transmitted packets.

Replace dev_kfree_skb with dev_kfree_skb_any in smc_hard_start_xmit which
can be called in hard irq and other contexts, and only frees skbs
when dropping them.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/smsc/smc91x.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 839c0e6cca01..d1b4dca53a9d 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -621,7 +621,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 done:	if (!THROTTLE_TX_PKTS)
 		netif_wake_queue(dev);
 
-	dev_kfree_skb(skb);
+	dev_consume_skb_any(skb);
 }
 
 /*
@@ -657,7 +657,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netdev_warn(dev, "Far too big packet error.\n");
 		dev->stats.tx_errors++;
 		dev->stats.tx_dropped++;
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
-- 
1.7.10.4
