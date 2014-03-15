From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 3/3] sh_eth: fold netif_msg_*() and netdev_*() calls into netif_*() invocations
Date: Sat, 15 Mar 2014 03:30:59 +0300
Message-ID: <201403150330.59864.sergei.shtylyov@cogentembedded.com>
References: <201403150321.47674.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:40462 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791AbaCNXa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 19:30:59 -0400
Received: by mail-lb0-f171.google.com with SMTP id w7so2221268lbi.2
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 16:30:58 -0700 (PDT)
In-Reply-To: <201403150321.47674.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we call netdev_*() under netif_msg_*() checks, we can fold these into
netif_*() macro invocations.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   33 +++++++++++----------------------
 1 file changed, 11 insertions(+), 22 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1557,8 +1557,7 @@ ignore_link:
 		/* Unused write back interrupt */
 		if (intr_status & EESR_TABT) {	/* Transmit Abort int */
 			ndev->stats.tx_aborted_errors++;
-			if (netif_msg_tx_err(mdp))
-				netdev_err(ndev, "Transmit Abort\n");
+			netif_err(mdp, tx_err, ndev, "Transmit Abort\n");
 		}
 	}
 
@@ -1567,45 +1566,38 @@ ignore_link:
 		if (intr_status & EESR_RFRMER) {
 			/* Receive Frame Overflow int */
 			ndev->stats.rx_frame_errors++;
-			if (netif_msg_rx_err(mdp))
-				netdev_err(ndev, "Receive Abort\n");
+			netif_err(mdp, rx_err, ndev, "Receive Abort\n");
 		}
 	}
 
 	if (intr_status & EESR_TDE) {
 		/* Transmit Descriptor Empty int */
 		ndev->stats.tx_fifo_errors++;
-		if (netif_msg_tx_err(mdp))
-			netdev_err(ndev, "Transmit Descriptor Empty\n");
+		netif_err(mdp, tx_err, ndev, "Transmit Descriptor Empty\n");
 	}
 
 	if (intr_status & EESR_TFE) {
 		/* FIFO under flow */
 		ndev->stats.tx_fifo_errors++;
-		if (netif_msg_tx_err(mdp))
-			netdev_err(ndev, "Transmit FIFO Under flow\n");
+		netif_err(mdp, tx_err, ndev, "Transmit FIFO Under flow\n");
 	}
 
 	if (intr_status & EESR_RDE) {
 		/* Receive Descriptor Empty int */
 		ndev->stats.rx_over_errors++;
-
-		if (netif_msg_rx_err(mdp))
-			netdev_err(ndev, "Receive Descriptor Empty\n");
+		netif_err(mdp, rx_err, ndev, "Receive Descriptor Empty\n");
 	}
 
 	if (intr_status & EESR_RFE) {
 		/* Receive FIFO Overflow int */
 		ndev->stats.rx_fifo_errors++;
-		if (netif_msg_rx_err(mdp))
-			netdev_err(ndev, "Receive FIFO Overflow\n");
+		netif_err(mdp, rx_err, ndev, "Receive FIFO Overflow\n");
 	}
 
 	if (!mdp->cd->no_ade && (intr_status & EESR_ADE)) {
 		/* Address Error */
 		ndev->stats.tx_fifo_errors++;
-		if (netif_msg_tx_err(mdp))
-			netdev_err(ndev, "Address Error\n");
+		netif_err(mdp, tx_err, ndev, "Address Error\n");
 	}
 
 	mask = EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | EESR_TFE;
@@ -2064,11 +2056,9 @@ static void sh_eth_tx_timeout(struct net
 
 	netif_stop_queue(ndev);
 
-	if (netif_msg_timer(mdp)) {
-		netdev_err(ndev,
-			   "transmit timed out, status %8.8x, resetting...\n",
-			   (int)sh_eth_read(ndev, EESR));
-	}
+	netif_err(mdp, timer, ndev,
+		  "transmit timed out, status %8.8x, resetting...\n",
+		  (int)sh_eth_read(ndev, EESR));
 
 	/* tx_errors count up */
 	ndev->stats.tx_errors++;
@@ -2103,8 +2093,7 @@ static int sh_eth_start_xmit(struct sk_b
 	spin_lock_irqsave(&mdp->lock, flags);
 	if ((mdp->cur_tx - mdp->dirty_tx) >= (mdp->num_tx_ring - 4)) {
 		if (!sh_eth_txfree(ndev)) {
-			if (netif_msg_tx_queued(mdp))
-				netdev_warn(ndev, "TxFD exhausted.\n");
+			netif_warn(mdp, tx_queued, ndev, "TxFD exhausted.\n");
 			netif_stop_queue(ndev);
 			spin_unlock_irqrestore(&mdp->lock, flags);
 			return NETDEV_TX_BUSY;
