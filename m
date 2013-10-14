From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH 05/07] via-velocity: Support for byte queue limits
Date: Mon, 14 Oct 2013 20:26:21 +0200
Message-ID: <1381775183-24866-6-git-send-email-milky-kernel@mcmilk.de>
References: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:35492 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757064Ab3JNSf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 14:35:57 -0400
In-Reply-To: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to via-velocity to use byte queue limits.

I can't test this patch on real hardware :(


Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/via/via-velocity.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index d022bf9..037f304 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -1751,6 +1751,8 @@ static void velocity_free_tx_buf(struct velocity_info *vptr,
 					le16_to_cpu(pktlen), DMA_TO_DEVICE);
 		}
 	}
+
+	netdev_reset_queue(vptr->netdev);
 	dev_kfree_skb_irq(skb);
 	tdinfo->skb = NULL;
 }
@@ -1915,6 +1917,7 @@ static int velocity_tx_srv(struct velocity_info *vptr)
 	int works = 0;
 	struct velocity_td_info *tdinfo;
 	struct net_device_stats *stats = &vptr->netdev->stats;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 
 	for (qnum = 0; qnum < vptr->tx.numq; qnum++) {
 		for (idx = vptr->tx.tail[qnum]; vptr->tx.used[qnum] > 0;
@@ -1946,6 +1949,8 @@ static int velocity_tx_srv(struct velocity_info *vptr)
 			} else {
 				stats->tx_packets++;
 				stats->tx_bytes += tdinfo->skb->len;
+				pkts_compl++;
+				bytes_compl += tdinfo->skb->len;
 			}
 			velocity_free_tx_buf(vptr, tdinfo, td);
 			vptr->tx.used[qnum]--;
@@ -1955,6 +1960,9 @@ static int velocity_tx_srv(struct velocity_info *vptr)
 		if (AVAIL_TD(vptr, qnum) < 1)
 			full = 1;
 	}
+
+	netdev_completed_queue(vptr->netdev, pkts_compl, bytes_compl);
+
 	/*
 	 *	Look to see if we should kick the transmit network
 	 *	layer for more work.
@@ -2641,6 +2649,7 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 	td_ptr->td_buf[0].size |= TD_QUEUE;
 	mac_tx_queue_wake(vptr->mac_regs, qnum);
 
+	netdev_sent_queue(vptr->netdev, skb->len);
 	spin_unlock_irqrestore(&vptr->lock, flags);
 out:
 	return NETDEV_TX_OK;
-- 
1.8.4
