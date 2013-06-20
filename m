From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Subject: [patch 2/2] Try to fix mvneta when compiled as module
Date: Fri, 21 Jun 2013 00:06:46 +0200
Message-ID: <20130620221008.551534830@rtp-net.org>
References: <20130620220644.715387300@rtp-net.org>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lebrac.rtp-net.org ([88.191.135.105]:50536 "EHLO
	lebrac.rtp-net.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab3FVUZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jun 2013 16:25:31 -0400
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
--- linux-next.orig/drivers/net/ethernet/marvell/mvneta.c	2013-06-20 23:39:37.485391949 +0200
+++ linux-next/drivers/net/ethernet/marvell/mvneta.c	2013-06-20 23:39:37.481391949 +0200
@@ -88,6 +88,8 @@
 #define      MVNETA_TX_IN_PRGRS                  BIT(1)
 #define      MVNETA_TX_FIFO_EMPTY                BIT(8)
 #define MVNETA_RX_MIN_FRAME_SIZE                 0x247c
+#define MVETH_SGMII_SERDES_CFG			 0x24A0
+#define MVETH_SGMII_SERDES_STAT			 0x24A4
 #define MVNETA_TYPE_PRIO                         0x24bc
 #define      MVNETA_FORCE_UNI                    BIT(21)
 #define MVNETA_TXQ_CMD_1                         0x24e4
@@ -655,6 +657,7 @@ static void mvneta_port_sgmii_config(str
 	val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
 	val |= MVNETA_GMAC2_PSC_ENABLE;
 	mvreg_write(pp, MVNETA_GMAC_CTRL_2, val);
+	mvreg_write(pp, MVETH_SGMII_SERDES_CFG, 0xcc7);
 }
 
 /* Start the Ethernet port RX and TX activity */
