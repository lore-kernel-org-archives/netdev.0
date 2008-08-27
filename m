From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH] [NET] smc91x: provide configurable leds
Date: Wed, 27 Aug 2008 12:52:54 +0100
Message-ID: <20080827115254.GB2899@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:52364 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927AbYH0LxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 07:53:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides a mechanism for platforms to be able to supply the
LED configuration via platform data, rather than having to hard code
it in smc91x.h.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
Tested-by: Marc Zyngier <maz@misterjones.org>
Acked-by: Nicolas Pitre <nico@cam.org>

--
As noticed by Eric against the Viper patches, being able to configure
the LEDs from platform code would be a good idea.  This patch implements
a mechanism to allow that to happen.

Since ARM platforms will depend on this, I'd prefer to add it to the
ARM tree, so I'm after an Ack from networking people.

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 2040965..ceed2f6 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1520,7 +1520,9 @@ smc_open(struct net_device *dev)
 	/* Setup the default Register Modes */
 	lp->tcr_cur_mode = TCR_DEFAULT;
 	lp->rcr_cur_mode = RCR_DEFAULT;
-	lp->rpc_cur_mode = RPC_DEFAULT;
+	lp->rpc_cur_mode = RPC_DEFAULT |
+				lp->cfg.leda << RPC_LSXA_SHFT |
+				lp->cfg.ledb << RPC_LSXB_SHFT;
 
 	/*
 	 * If we are not using a MII interface, we need to
@@ -2157,6 +2159,11 @@ static int smc_drv_probe(struct platform_device *pdev)
 		lp->cfg.flags |= (nowait) ? SMC91X_NOWAIT : 0;
 	}
 
+	if (!lp->cfg.leda && !lp->cfg.ledb) {
+		lp->cfg.leda = RPC_LSA_DEFAULT;
+		lp->cfg.ledb = RPC_LSB_DEFAULT;
+	}
+
 	ndev->dma = (unsigned char)-1;
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-regs");
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 997e7f1..8322e7f 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -794,7 +794,7 @@ smc_pxa_dma_irq(int dma, void *dummy)
 #define RPC_LSB_DEFAULT RPC_LED_FD
 #endif
 
-#define RPC_DEFAULT (RPC_ANEG | (RPC_LSA_DEFAULT << RPC_LSXA_SHFT) | (RPC_LSB_DEFAULT << RPC_LSXB_SHFT) | RPC_SPEED | RPC_DPLX)
+#define RPC_DEFAULT (RPC_ANEG | RPC_SPEED | RPC_DPLX)
 
 
 /* Bank 0 0x0C is reserved */
diff --git a/include/linux/smc91x.h b/include/linux/smc91x.h
index 3827b92..ed25483 100644
--- a/include/linux/smc91x.h
+++ b/include/linux/smc91x.h
@@ -18,6 +18,8 @@
 
 struct smc91x_platdata {
 	unsigned long flags;
+	unsigned char leda;
+	unsigned char ledb;
 };
 
 #endif /* __SMC91X_H__ */

