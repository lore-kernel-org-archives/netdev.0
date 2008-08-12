From: Manuel Lauss <mano@roarinelk.homelinux.net>
Subject: [PATCH] smc91x: allow platform data to configure LEDs.
Date: Tue, 12 Aug 2008 20:49:23 +0200
Message-ID: <1218566963-14943-1-git-send-email-mano@roarinelk.homelinux.net>
Cc: Manuel Lauss <mano@roarinelk.homelinux.net>
To: Nicolas Pitre <nico@cam.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fnoeppeil48.netpark.at ([217.175.205.176]:60420 "EHLO
	roarinelk.homelinux.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbYHLStZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 14:49:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add another field to smc91x_platdata to configure LEDs.

Signed-off-by: Manuel Lauss <mano@roarinelk.homelinux.net>
---
 drivers/net/smc91x.c   |    7 ++++++-
 drivers/net/smc91x.h   |    5 ++++-
 include/linux/smc91x.h |   17 +++++++++++++++++
 3 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 2040965..a591508 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1520,7 +1520,7 @@ smc_open(struct net_device *dev)
 	/* Setup the default Register Modes */
 	lp->tcr_cur_mode = TCR_DEFAULT;
 	lp->rcr_cur_mode = RCR_DEFAULT;
-	lp->rpc_cur_mode = RPC_DEFAULT;
+	lp->rpc_cur_mode = lp->cfg.rpc;
 
 	/*
 	 * If we are not using a MII interface, we need to
@@ -2150,11 +2150,16 @@ static int smc_drv_probe(struct platform_device *pdev)
 	if (pd) {
 		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
 		lp->io_shift = SMC91X_IO_SHIFT(lp->cfg.flags);
+		if (!lp->cfg.rpc)
+			lp->cfg.rpc = RPC_DEFAULT;
+		else
+			lp->cfg.rpc |= RPC_DEFAULT_NET;	/* speed/duplex */
 	} else {
 		lp->cfg.flags |= (SMC_CAN_USE_8BIT)  ? SMC91X_USE_8BIT  : 0;
 		lp->cfg.flags |= (SMC_CAN_USE_16BIT) ? SMC91X_USE_16BIT : 0;
 		lp->cfg.flags |= (SMC_CAN_USE_32BIT) ? SMC91X_USE_32BIT : 0;
 		lp->cfg.flags |= (nowait) ? SMC91X_NOWAIT : 0;
+		lp->cfg.rpc = RPC_DEFAULT;
 	}
 
 	ndev->dma = (unsigned char)-1;
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 997e7f1..5672a82 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -794,7 +794,10 @@ smc_pxa_dma_irq(int dma, void *dummy)
 #define RPC_LSB_DEFAULT RPC_LED_FD
 #endif
 
-#define RPC_DEFAULT (RPC_ANEG | (RPC_LSA_DEFAULT << RPC_LSXA_SHFT) | (RPC_LSB_DEFAULT << RPC_LSXB_SHFT) | RPC_SPEED | RPC_DPLX)
+#define RPC_DEFAULT_NET	(RPC_ANEG | RPC_SPEED | RPC_DPLX)
+#define RPC_DEFAULT	(RPC_DEFAULT_NET			| \
+			 (RPC_LSA_DEFAULT << RPC_LSXA_SHFT)	| \
+			 (RPC_LSB_DEFAULT << RPC_LSXB_SHFT))
 
 
 /* Bank 0 0x0C is reserved */
diff --git a/include/linux/smc91x.h b/include/linux/smc91x.h
index 3827b92..c6732f2 100644
--- a/include/linux/smc91x.h
+++ b/include/linux/smc91x.h
@@ -16,8 +16,25 @@
 
 #define SMC91X_USE_DMA		(1 << 6)
 
+#define SMC91X_RPC_LED_100_10	(0x00)	/* LED = 10/100Mbps link detect */
+#define SMC91X_RPC_LED_RES	(0x01)	/* LED = Reserved */
+#define SMC91X_RPC_LED_10	(0x02)	/* LED = 10Mbps link detect */
+#define SMC91X_RPC_LED_FD	(0x03)	/* LED = Full Duplex Mode */
+#define SMC91X_RPC_LED_TX_RX	(0x04)	/* LED = TX or RX packet occurred */
+#define SMC91X_RPC_LED_100	(0x05)	/* LED = 100Mbps link dectect */
+#define SMC91X_RPC_LED_TX	(0x06)	/* LED = TX packet occurred */
+#define SMC91X_RPC_LED_RX	(0x07)	/* LED = RX packet occurred */
+
+#define RPC_LSXA_SHFT	5	/* Bits to shift LS2A,LS1A,LS0A to lsb */
+#define RPC_LSXB_SHFT	2	/* Bits to get LS2B,LS1B,LS0B to lsb */
+
+/* LED macros */
+#define SMC91X_RPC_LSA(x)	((x) << RPC_LSXA_SHFT)
+#define SMC91X_RPC_LSB(x)	((x) << RPC_LSXB_SHFT)
+
 struct smc91x_platdata {
 	unsigned long flags;
+	unsigned long rpc;
 };
 
 #endif /* __SMC91X_H__ */
-- 
1.5.6.4

