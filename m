From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/6] sky2: fix receive pause thresholds
Date: Thu, 29 Oct 2009 09:37:07 -0700
Message-ID: <20091029163849.356238568@vyatta.com>
References: <20091029163704.793246334@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57319 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755513AbZJ2QjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 12:39:23 -0400
Content-Disposition: inline; filename=sky2-rxthresh.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Program the receive pause thresholds differently depending on
chip version. This cloned from from the vendor (GPL) driver.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.h	2009-10-29 08:35:53.313438448 -0700
+++ b/drivers/net/sky2.h	2009-10-29 08:37:04.959438572 -0700
@@ -808,10 +808,11 @@ enum {
 	RX_GMF_AF_THR	= 0x0c44,/* 32 bit	Rx GMAC FIFO Almost Full Thresh. */
 	RX_GMF_CTRL_T	= 0x0c48,/* 32 bit	Rx GMAC FIFO Control/Test */
 	RX_GMF_FL_MSK	= 0x0c4c,/* 32 bit	Rx GMAC FIFO Flush Mask */
-	RX_GMF_FL_THR	= 0x0c50,/* 32 bit	Rx GMAC FIFO Flush Threshold */
+	RX_GMF_FL_THR	= 0x0c50,/* 16 bit	Rx GMAC FIFO Flush Threshold */
+	RX_GMF_FL_CTRL	= 0x0c52,/* 16 bit	Rx GMAC FIFO Flush Control */
 	RX_GMF_TR_THR	= 0x0c54,/* 32 bit	Rx Truncation Threshold (Yukon-2) */
-	RX_GMF_UP_THR	= 0x0c58,/*  8 bit	Rx Upper Pause Thr (Yukon-EC_U) */
-	RX_GMF_LP_THR	= 0x0c5a,/*  8 bit	Rx Lower Pause Thr (Yukon-EC_U) */
+	RX_GMF_UP_THR	= 0x0c58,/* 16 bit	Rx Upper Pause Thr (Yukon-EC_U) */
+	RX_GMF_LP_THR	= 0x0c5a,/* 16 bit	Rx Lower Pause Thr (Yukon-EC_U) */
 	RX_GMF_VLAN	= 0x0c5c,/* 32 bit	Rx VLAN Type Register (Yukon-2) */
 	RX_GMF_WP	= 0x0c60,/* 32 bit	Rx GMAC FIFO Write Pointer */
 
--- a/drivers/net/sky2.c	2009-10-29 08:34:04.765191254 -0700
+++ b/drivers/net/sky2.c	2009-10-29 08:52:37.995315808 -0700
@@ -926,8 +926,14 @@ static void sky2_mac_init(struct sky2_hw
 
 	/* On chips without ram buffer, pause is controled by MAC level */
 	if (!(hw->flags & SKY2_HW_RAM_BUFFER)) {
-		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
-		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
+		/* Pause threshold is scaled by 8 in bytes */
+		if (hw->chip_id == CHIP_ID_YUKON_FE_P
+			&& hw->chip_rev == CHIP_REV_YU_FE2_A0)
+			reg = 1568 / 8;
+		else
+			reg = 1024 / 8;
+		sky2_write16(hw, SK_REG(port, RX_GMF_UP_THR), reg);
+		sky2_write16(hw, SK_REG(port, RX_GMF_LP_THR), 768 / 8);
 
 		sky2_set_tx_stfwd(hw, port);
 	}

-- 

