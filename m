From: Li Yang <leoli@freescale.com>
Subject: [Patch 1/3] ucc_geth: Fix BD processing
Date: Tue, 06 Mar 2007 16:53:46 +0800
Message-ID: <45ED2C1A.2080602@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:35746 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933085AbXCFIw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 03:52:29 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l268qQCA009707
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 01:52:27 -0700 (MST)
Received: from zch01exm20.fsl.freescale.net (zch01exm20.ap.freescale.net [10.192.129.204])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l268qNrm023686
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 02:52:24 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix broken BD processing code.

Signed-off-by: Michael Barkowski <michael.barkowski@freescale.com>
Signed-off-by: Li Yang <leoli@freescale.com>

---
 drivers/net/ucc_geth.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 885e73d..639e1e6 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3598,9 +3598,9 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Move to next BD in the ring */
 	if (!(bd_status & T_W))
-		ugeth->txBd[txQ] = bd + sizeof(struct qe_bd);
+		bd += sizeof(struct qe_bd);
 	else
-		ugeth->txBd[txQ] = ugeth->p_tx_bd_ring[txQ];
+		bd = ugeth->p_tx_bd_ring[txQ];
 
 	/* If the next BD still needs to be cleaned up, then the bds
 	   are full.  We need to tell the kernel to stop sending us stuff. */
@@ -3609,6 +3609,8 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_stop_queue(dev);
 	}
 
+	ugeth->txBd[txQ] = bd;
+
 	if (ugeth->p_scheduler) {
 		ugeth->cpucount[txQ]++;
 		/* Indicate to QE that there are more Tx bds ready for
@@ -3722,7 +3724,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 		/* Handle the transmitted buffer and release */
 		/* the BD to be used with the current frame  */
 
-		if ((bd = ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
+		if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
 			break;
 
 		ugeth->stats.tx_packets++;
@@ -3741,10 +3743,12 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 
 		/* Advance the confirmation BD pointer */
 		if (!(bd_status & T_W))
-			ugeth->confBd[txQ] += sizeof(struct qe_bd);
+			bd += sizeof(struct qe_bd);
 		else
-			ugeth->confBd[txQ] = ugeth->p_tx_bd_ring[txQ];
+			bd = ugeth->p_tx_bd_ring[txQ];
+		bd_status = in_be32((u32 *)bd);
 	}
+	ugeth->confBd[txQ] = bd;
 	return 0;
 }

