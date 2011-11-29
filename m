From: Tom Herbert <therbert@google.com>
Subject: [PATCH 08/10] tg3: Support for byte queue limits
Date: Mon, 28 Nov 2011 18:33:30 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1111281820510.23826@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f202.google.com ([209.85.161.202]:52832 "EHLO
	mail-gx0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076Ab1K2Ckb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 21:40:31 -0500
Received: by ggnp2 with SMTP id p2so610029ggn.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 18:40:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to tg3 to use byte queue limits.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0acb279..abb38f7 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5302,6 +5302,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 	u32 sw_idx = tnapi->tx_cons;
 	struct netdev_queue *txq;
 	int index = tnapi - tp->napi;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 
 	if (tg3_flag(tp, ENABLE_TSS))
 		index--;
@@ -5352,6 +5353,9 @@ static void tg3_tx(struct tg3_napi *tnapi)
 			sw_idx = NEXT_TX(sw_idx);
 		}
 
+		pkts_compl++;
+		bytes_compl += skb->len;
+
 		dev_kfree_skb(skb);
 
 		if (unlikely(tx_bug)) {
@@ -5360,6 +5364,8 @@ static void tg3_tx(struct tg3_napi *tnapi)
 		}
 	}
 
+	netdev_completed_queue(tp->dev, pkts_compl, bytes_compl);
+
 	tnapi->tx_cons = sw_idx;
 
 	/* Need to make the tx_cons update visible to tg3_start_xmit()
@@ -6804,6 +6810,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	skb_tx_timestamp(skb);
+	netdev_sent_queue(tp->dev, skb->len);
 
 	/* Packets are ready, update Tx producer idx local and on card. */
 	tw32_tx_mbox(tnapi->prodmbox, entry);
@@ -7286,6 +7293,7 @@ static void tg3_free_rings(struct tg3 *tp)
 			dev_kfree_skb_any(skb);
 		}
 	}
+	netdev_reset_queue(tp->dev);
 }
 
 /* Initialize tx/rx rings for packet processing.
-- 
1.7.3.1
