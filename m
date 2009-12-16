From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Subject: [PATCH  1/3] gianfar: Fix a filer bug
Date: Wed, 16 Dec 2009 16:44:58 +0530
Message-ID: <1260962098-16815-1-git-send-email-Sandeep.Kumar@freescale.com>
Cc: davem@davemloft.net, Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
To: netdev@vger.kernel.org, avorontsov@ru.mvista.com,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35814 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762023AbZLPLPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 06:15:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to enable filer whenever we need to use multiple RX
queues. Also, need to program RIR0 register with the required
distribution we require, if using RX filer hashing support for
packet distribution to multiple queues.

Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
---
 *. Sorry for the delay in resending the patches. My machine went down
    for the last couple of days.

 *. These patches are based on net-next-2.6 tree as of 20091216.

 *. Included Anton's comments.

 drivers/net/gianfar.c |    8 +++++++-
 drivers/net/gianfar.h |    4 ++++
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6850dc0..1616531 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -357,8 +357,11 @@ static void gfar_init_mac(struct net_device *ndev)
 	/* Configure the coalescing support */
 	gfar_configure_coalescing(priv, 0xFF, 0xFF);
 
-	if (priv->rx_filer_enable)
+	if (priv->rx_filer_enable) {
 		rctrl |= RCTRL_FILREN;
+		/* Program the RIR0 reg with the required distribution */
+		gfar_write(&regs->rir0, DEFAULT_RIR0);
+	}
 
 	if (priv->rx_csum_enable)
 		rctrl |= RCTRL_CHECKSUMMING;
@@ -1022,6 +1025,9 @@ static int gfar_probe(struct of_device *ofdev,
 		priv->rx_queue[i]->rxic = DEFAULT_RXIC;
 	}
 
+	/* enable filer if using multiple RX queues*/
+	if(priv->num_rx_queues > 1)
+		priv->rx_filer_enable = 1;
 	/* Enable most messages by default */
 	priv->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index cbb4510..68d16dc 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -401,6 +401,10 @@ extern const char gfar_driver_version[];
 #define FPR_FILER_MASK	0xFFFFFFFF
 #define MAX_FILER_IDX	0xFF
 
+/* This default RIR value directly corresponds
+ * to the 3-bit hash value generated */
+#define DEFAULT_RIR0	0x05397700
+
 /* RQFCR register bits */
 #define RQFCR_GPI		0x80000000
 #define RQFCR_HASHTBL_Q		0x00000000
-- 
1.6.5.6

