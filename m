From: Tom Herbert <therbert@google.com>
Subject: [RFC PATCH v2 7/9] tg3: Support for byte queue limits
Date: Sun, 7 Aug 2011 21:53:34 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1108072149400.14333@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:13974 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab1HHExj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 00:53:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to tg3 to use byte queue limits.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/tg3.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index dc3fbf6..ad06c40 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4818,6 +4818,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 	u32 sw_idx = tnapi->tx_cons;
 	struct netdev_queue *txq;
 	int index = tnapi - tp->napi;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 
 	if (tg3_flag(tp, ENABLE_TSS))
 		index--;
@@ -4868,6 +4869,9 @@ static void tg3_tx(struct tg3_napi *tnapi)
 			sw_idx = NEXT_TX(sw_idx);
 		}
 
+		pkts_compl++;
+		bytes_compl += skb->len;
+
 		dev_kfree_skb(skb);
 
 		if (unlikely(tx_bug)) {
@@ -4876,6 +4880,8 @@ static void tg3_tx(struct tg3_napi *tnapi)
 		}
 	}
 
+	netdev_completed_queue(tp->dev, pkts_compl, bytes_compl);
+
 	tnapi->tx_cons = sw_idx;
 
 	/* Need to make the tx_cons update visible to tg3_start_xmit()
@@ -6313,6 +6319,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	skb_tx_timestamp(skb);
+	netdev_sent_queue(tp->dev, 1, skb->len);
 
 	/* Packets are ready, update Tx producer idx local and on card. */
 	tw32_tx_mbox(tnapi->prodmbox, entry);
@@ -6680,6 +6687,7 @@ static void tg3_free_rings(struct tg3 *tp)
 
 			dev_kfree_skb_any(skb);
 		}
+		netdev_reset_queue(tp->dev);
 	}
 }
 
-- 
1.7.3.1

