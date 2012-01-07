From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/7] via-rhine: factor out tx_thresh handling
Date: Sat, 7 Jan 2012 23:49:41 +0100
Message-ID: <20120107224941.GA25021@electric-eye.fr.zoreil.com>
References: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50350 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023Ab2AGW7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 17:59:01 -0500
Content-Disposition: inline
In-Reply-To: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 5c4983b..93987e8 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -657,6 +657,16 @@ static void rhine_poll(struct net_device *dev)
 }
 #endif
 
+static void rhine_kick_tx_threshold(struct rhine_private *rp)
+{
+	if (rp->tx_thresh < 0xe0) {
+		void __iomem *ioaddr = rp->base;
+
+		rp->tx_thresh += 0x20;
+		BYTE_REG_BITS_SET(rp->tx_thresh, 0x80, ioaddr + TxConfig);
+	}
+}
+
 static int rhine_napipoll(struct napi_struct *napi, int budget)
 {
 	struct rhine_private *rp = container_of(napi, struct rhine_private, napi);
@@ -1910,8 +1920,7 @@ static void rhine_error(struct net_device *dev, int intr_status)
 				    intr_status);
 	}
 	if (intr_status & IntrTxUnderrun) {
-		if (rp->tx_thresh < 0xE0)
-			BYTE_REG_BITS_SET((rp->tx_thresh += 0x20), 0x80, ioaddr + TxConfig);
+		rhine_kick_tx_threshold(rp);
 		if (debug > 1)
 			netdev_info(dev, "Transmitter underrun, Tx threshold now %02x\n",
 				    rp->tx_thresh);
@@ -1923,9 +1932,7 @@ static void rhine_error(struct net_device *dev, int intr_status)
 	if ((intr_status & IntrTxError) &&
 	    (intr_status & (IntrTxAborted |
 	     IntrTxUnderrun | IntrTxDescRace)) == 0) {
-		if (rp->tx_thresh < 0xE0) {
-			BYTE_REG_BITS_SET((rp->tx_thresh += 0x20), 0x80, ioaddr + TxConfig);
-		}
+		rhine_kick_tx_threshold(rp);
 		if (debug > 1)
 			netdev_info(dev, "Unspecified error. Tx threshold now %02x\n",
 				    rp->tx_thresh);
-- 
1.7.6.4
