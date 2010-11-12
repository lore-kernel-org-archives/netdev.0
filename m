From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH 1/2] ucc_geth: Do not bring the whole IF down when TX failure.
Date: Fri, 12 Nov 2010 14:55:08 +0100
Message-ID: <1289570109-8160-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:48024 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757301Ab0KLNzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Nov 2010 08:55:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ucc_geth_close lacks a cancel_work_sync(&ugeth->timeout_work)
to stop any outstanding processing of TX fail. However, one
can not call cancel_work_sync without fixing the timeout function
otherwise it will deadlock. This patch brings ucc_geth in line with
gianfar:

Don't bring the interface down and up, just reinit controller HW
and PHY.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ucc_geth.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 97f9f7d..6c254ed 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2065,9 +2065,6 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 	/* Disable Rx and Tx */
 	clrbits32(&ug_regs->maccfg1, MACCFG1_ENABLE_RX | MACCFG1_ENABLE_TX);
 
-	phy_disconnect(ugeth->phydev);
-	ugeth->phydev = NULL;
-
 	ucc_geth_memclean(ugeth);
 }
 
@@ -3556,7 +3553,10 @@ static int ucc_geth_close(struct net_device *dev)
 
 	napi_disable(&ugeth->napi);
 
+	cancel_work_sync(&ugeth->timeout_work);
 	ucc_geth_stop(ugeth);
+	phy_disconnect(ugeth->phydev);
+	ugeth->phydev = NULL;
 
 	free_irq(ugeth->ug_info->uf_info.irq, ugeth->ndev);
 
@@ -3585,8 +3585,12 @@ static void ucc_geth_timeout_work(struct work_struct *work)
 		 * Must reset MAC *and* PHY. This is done by reopening
 		 * the device.
 		 */
-		ucc_geth_close(dev);
-		ucc_geth_open(dev);
+		netif_tx_stop_all_queues(dev);
+		ucc_geth_stop(ugeth);
+		ucc_geth_init_mac(ugeth);
+		/* Must start PHY here */
+		phy_start(ugeth->phydev);
+		netif_tx_start_all_queues(dev);
 	}
 
 	netif_tx_schedule_all(dev);
@@ -3600,7 +3604,6 @@ static void ucc_geth_timeout(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 
-	netif_carrier_off(dev);
 	schedule_work(&ugeth->timeout_work);
 }
 
-- 
1.7.2.2

