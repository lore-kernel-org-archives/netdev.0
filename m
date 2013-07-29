From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Subject: [patch v2 2/2] Try to fix mvneta when compiled as module
Date: Mon, 29 Jul 2013 21:56:48 +0200
Message-ID: <20130729195711.893401612@rtp-net.org>
References: <20130729195646.433524957@rtp-net.org>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lebrac.rtp-net.org ([88.191.135.105]:53115 "EHLO
	lebrac.rtp-net.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962Ab3G2UDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 16:03:48 -0400
Content-Disposition: inline; filename=mvneta-init-fix.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the mvneta driver is compiled as module, the clock is disabled before
it's loading. This will reset the registers values and all configuration
made by the bootloader.

This patch sets the "sgmii serdes configuration" register to a magical value
found in:
https://github.com/yellowback/ubuntu-precise-armadaxp/blob/master/arch/arm/mach-armadaxp/armada_xp_family/ctrlEnv/mvCtrlEnvLib.c

With this change, the interrupts are working/generated and ethernet is
working.

Signed-off-by: Arnaud Patard <arnaud.patard@rtp-net.org>

Index: linux-next/drivers/net/ethernet/marvell/mvneta.c
===================================================================
--- linux-next.orig/drivers/net/ethernet/marvell/mvneta.c	2013-07-29 21:48:20.673275215 +0200
+++ linux-next/drivers/net/ethernet/marvell/mvneta.c	2013-07-29 21:53:03.021262793 +0200
@@ -88,6 +88,8 @@
 #define      MVNETA_TX_IN_PRGRS                  BIT(1)
 #define      MVNETA_TX_FIFO_EMPTY                BIT(8)
 #define MVNETA_RX_MIN_FRAME_SIZE                 0x247c
+#define MVNETA_SGMII_SERDES_CFG			 0x24A0
+#define      MVNETA_SGMII_SERDES_PROTO		 0x0cc7
 #define MVNETA_TYPE_PRIO                         0x24bc
 #define      MVNETA_FORCE_UNI                    BIT(21)
 #define MVNETA_TXQ_CMD_1                         0x24e4
@@ -655,6 +657,8 @@ static void mvneta_port_sgmii_config(str
 	val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
 	val |= MVNETA_GMAC2_PSC_ENABLE;
 	mvreg_write(pp, MVNETA_GMAC_CTRL_2, val);
+
+	mvreg_write(pp, MVNETA_SGMII_SERDES_CFG, MVNETA_SGMII_SERDES_PROTO);
 }
 
 /* Start the Ethernet port RX and TX activity */
@@ -2735,11 +2739,17 @@ static int mvneta_probe(struct platform_
 	pp->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pp->clk)) {
 		err = PTR_ERR(pp->clk);
-		goto err_unmap;
+		goto err_free_irq;
 	}
 
 	clk_prepare_enable(pp->clk);
 
+	pp->base = of_iomap(dn, 0);
+	if (pp->base == NULL) {
+		err = -ENOMEM;
+		goto err_clk;
+	}
+
 	dt_mac_addr = of_get_mac_address(dn);
 	if (dt_mac_addr && is_valid_ether_addr(dt_mac_addr)) {
 		mac_from = "device tree";
@@ -2755,12 +2765,6 @@ static int mvneta_probe(struct platform_
 		}
 	}
 
-	pp->base = of_iomap(dn, 0);
-	if (pp->base == NULL) {
-		err = -ENOMEM;
-		goto err_free_irq;
-	}
-
 	pp->tx_done_timer.data = (unsigned long)dev;
 	pp->tx_done_timer.function = mvneta_tx_done_timer_callback;
 	init_timer(&pp->tx_done_timer);
@@ -2775,7 +2779,7 @@ static int mvneta_probe(struct platform_
 	err = mvneta_init(pp, phy_addr);
 	if (err < 0) {
 		dev_err(&pdev->dev, "can't init eth hal\n");
-		goto err_clk;
+		goto err_unmap;
 	}
 	mvneta_port_power_up(pp, phy_mode);
 
@@ -2805,10 +2809,10 @@ static int mvneta_probe(struct platform_
 
 err_deinit:
 	mvneta_deinit(pp);
-err_clk:
-	clk_disable_unprepare(pp->clk);
 err_unmap:
 	iounmap(pp->base);
+err_clk:
+	clk_disable_unprepare(pp->clk);
 err_free_irq:
 	irq_dispose_mapping(dev->irq);
 err_free_netdev:
