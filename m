From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH net-next v2 05/07] via-velocity: Support for byte queue limits
Date: Sun, 20 Oct 2013 20:13:21 +0200
Message-ID: <1382292803-18875-6-git-send-email-milky-kernel@mcmilk.de>
References: <1382292803-18875-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:45394 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350Ab3JTSNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 14:13:38 -0400
In-Reply-To: <1382292803-18875-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to via-velocity driver to use byte queue limits.


Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/via/via-velocity.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index d022bf9..b084404 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -1,3 +1,4 @@
+
 /*
  * This code is derived from the VIA reference driver (copyright message
  * below) provided to Red Hat by VIA Networking Technologies, Inc. for
@@ -368,6 +369,11 @@ static int rx_copybreak = 200;
 module_param(rx_copybreak, int, 0644);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 
+static bool bql_disable;
+module_param(bql_disable, bool, 0);
+MODULE_PARM_DESC(bql_disable,
+	"Disable Byte Queue Limits functionality (default: false)");
+
 /*
  *	Internal board variants. At the moment we have only one
  */
@@ -1751,6 +1757,9 @@ static void velocity_free_tx_buf(struct velocity_info *vptr,
 					le16_to_cpu(pktlen), DMA_TO_DEVICE);
 		}
 	}
+
+	if (likely(bql_disable == false))
+		netdev_reset_queue(vptr->netdev);
 	dev_kfree_skb_irq(skb);
 	tdinfo->skb = NULL;
 }
@@ -1915,6 +1924,7 @@ static int velocity_tx_srv(struct velocity_info *vptr)
 	int works = 0;
 	struct velocity_td_info *tdinfo;
 	struct net_device_stats *stats = &vptr->netdev->stats;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 
 	for (qnum = 0; qnum < vptr->tx.numq; qnum++) {
 		for (idx = vptr->tx.tail[qnum]; vptr->tx.used[qnum] > 0;
@@ -1946,6 +1956,8 @@ static int velocity_tx_srv(struct velocity_info *vptr)
 			} else {
 				stats->tx_packets++;
 				stats->tx_bytes += tdinfo->skb->len;
+				pkts_compl++;
+				bytes_compl += tdinfo->skb->len;
 			}
 			velocity_free_tx_buf(vptr, tdinfo, td);
 			vptr->tx.used[qnum]--;
@@ -1955,6 +1967,10 @@ static int velocity_tx_srv(struct velocity_info *vptr)
 		if (AVAIL_TD(vptr, qnum) < 1)
 			full = 1;
 	}
+
+	if (likely(bql_disable == false))
+		netdev_completed_queue(vptr->netdev, pkts_compl, bytes_compl);
+
 	/*
 	 *	Look to see if we should kick the transmit network
 	 *	layer for more work.
@@ -2641,6 +2657,8 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 	td_ptr->td_buf[0].size |= TD_QUEUE;
 	mac_tx_queue_wake(vptr->mac_regs, qnum);
 
+	if (likely(bql_disable == false))
+		netdev_sent_queue(vptr->netdev, skb->len);
 	spin_unlock_irqrestore(&vptr->lock, flags);
 out:
 	return NETDEV_TX_OK;
-- 
1.8.4.1
