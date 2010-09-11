From: Andreas Schwab <schwab@linux-m68k.org>
Subject: [PATCH] net/de4x5: remove undefined operations
Date: Sat, 11 Sep 2010 13:08:58 +0200
Message-ID: <m2r5h0fsfp.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:46132 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967Ab0IKLJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Sep 2010 07:09:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modifying an object twice without an intervening sequence point is
undefined.

Signed-off-by: Andreas Schwab <schwab@linux-m68k.org>
---
 drivers/net/tulip/de4x5.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 75a64c8..4f75030 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1448,7 +1448,7 @@ de4x5_sw_reset(struct net_device *dev)
 	status = -EIO;
     }
 
-    lp->tx_new = (++lp->tx_new) % lp->txRingSize;
+    lp->tx_new = (lp->tx_new + 1) % lp->txRingSize;
     lp->tx_old = lp->tx_new;
 
     return status;
@@ -1506,7 +1506,7 @@ de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
  	    lp->stats.tx_bytes += skb->len;
 	    outl(POLL_DEMAND, DE4X5_TPD);/* Start the TX */
 
-	    lp->tx_new = (++lp->tx_new) % lp->txRingSize;
+	    lp->tx_new = (lp->tx_new + 1) % lp->txRingSize;
 
 	    if (TX_BUFFS_AVAIL) {
 		netif_start_queue(dev);         /* Another pkt may be queued */
@@ -1657,7 +1657,7 @@ de4x5_rx(struct net_device *dev)
 	    }
 
 	    /* Change buffer ownership for this frame, back to the adapter */
-	    for (;lp->rx_old!=entry;lp->rx_old=(++lp->rx_old)%lp->rxRingSize) {
+	    for (;lp->rx_old!=entry;lp->rx_old=(lp->rx_old + 1)%lp->rxRingSize) {
 		lp->rx_ring[lp->rx_old].status = cpu_to_le32(R_OWN);
 		barrier();
 	    }
@@ -1668,7 +1668,7 @@ de4x5_rx(struct net_device *dev)
 	/*
 	** Update entry information
 	*/
-	lp->rx_new = (++lp->rx_new) % lp->rxRingSize;
+	lp->rx_new = (lp->rx_new + 1) % lp->rxRingSize;
     }
 
     return 0;
@@ -1726,7 +1726,7 @@ de4x5_tx(struct net_device *dev)
 	}
 
 	/* Update all the pointers */
-	lp->tx_old = (++lp->tx_old) % lp->txRingSize;
+	lp->tx_old = (lp->tx_old + 1) % lp->txRingSize;
     }
 
     /* Any resources available? */
@@ -1801,7 +1801,7 @@ de4x5_rx_ovfc(struct net_device *dev)
 
     for (; (s32)le32_to_cpu(lp->rx_ring[lp->rx_new].status)>=0;) {
 	lp->rx_ring[lp->rx_new].status = cpu_to_le32(R_OWN);
-	lp->rx_new = (++lp->rx_new % lp->rxRingSize);
+	lp->rx_new = (lp->rx_new + 1) % lp->rxRingSize;
     }
 
     outl(omr, DE4X5_OMR);
@@ -1932,7 +1932,7 @@ set_multicast_list(struct net_device *dev)
 	    load_packet(dev, lp->setup_frame, TD_IC | PERFECT_F | TD_SET |
 			                                SETUP_FRAME_LEN, (struct sk_buff *)1);
 
-	    lp->tx_new = (++lp->tx_new) % lp->txRingSize;
+	    lp->tx_new = (lp->tx_new + 1) % lp->txRingSize;
 	    outl(POLL_DEMAND, DE4X5_TPD);       /* Start the TX */
 	    dev->trans_start = jiffies; /* prevent tx timeout */
 	}
@@ -3568,7 +3568,7 @@ ping_media(struct net_device *dev, int msec)
 
 	lp->tmp = lp->tx_new;                /* Remember the ring position */
 	load_packet(dev, lp->frame, TD_LS | TD_FS | sizeof(lp->frame), (struct sk_buff *)1);
-	lp->tx_new = (++lp->tx_new) % lp->txRingSize;
+	lp->tx_new = (lp->tx_new + 1) % lp->txRingSize;
 	outl(POLL_DEMAND, DE4X5_TPD);
     }
 
@@ -5417,7 +5417,7 @@ de4x5_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	/* Set up the descriptor and give ownership to the card */
 	load_packet(dev, lp->setup_frame, TD_IC | PERFECT_F | TD_SET |
 		                                       SETUP_FRAME_LEN, (struct sk_buff *)1);
-	lp->tx_new = (++lp->tx_new) % lp->txRingSize;
+	lp->tx_new = (lp->tx_new + 1) % lp->txRingSize;
 	outl(POLL_DEMAND, DE4X5_TPD);                /* Start the TX */
 	netif_wake_queue(dev);                      /* Unlock the TX ring */
 	break;
-- 
1.7.2.3

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
