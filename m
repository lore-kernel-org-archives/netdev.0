From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH]  sky2: fix management of driver LED
Date: Mon, 31 Aug 2009 10:31:41 -0700
Message-ID: <20090831103141.77598705@nehalam>
References: <4A9928C9.7000907@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Rene Mayrhofer <rene.mayrhofer@gibraltar.at>,
	Richard Leitner <leitner@esys.at>
To: Mike McCormack <mikem@ring3k.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41552 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751556AbZHaRcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 13:32:13 -0400
In-Reply-To: <4A9928C9.7000907@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Observed by Mike McCormack.

The LED bit here is just a software controlled value used to
turn on one of the LED's on some boards. The register value was wrong,
which could have been causing some power control issues.
Get rid of problematic define use the correct mask.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/sky2.c |   12 ++++++------
 drivers/net/sky2.h |    9 +--------
 2 files changed, 7 insertions(+), 14 deletions(-)

--- a/drivers/net/sky2.c	2009-08-31 09:05:07.941736447 -0700
+++ b/drivers/net/sky2.c	2009-08-31 09:46:24.611967164 -0700
@@ -256,6 +256,9 @@ static void sky2_power_on(struct sky2_hw
 
 		sky2_read32(hw, B2_GP_IO);
 	}
+
+	/* Turn on "driver loaded" LED */
+	sky2_write16(hw, B0_CTST, Y2_LED_STAT_ON);
 }
 
 static void sky2_power_aux(struct sky2_hw *hw)
@@ -274,6 +277,9 @@ static void sky2_power_aux(struct sky2_h
 		sky2_write8(hw, B0_POWER_CTRL,
 			    (PC_VAUX_ENA | PC_VCC_ENA |
 			     PC_VAUX_ON | PC_VCC_OFF));
+
+	/* turn off "driver loaded LED" */
+	sky2_write16(hw, B0_CTST, Y2_LED_STAT_OFF);
 }
 
 static void sky2_gmac_reset(struct sky2_hw *hw, unsigned port)
@@ -1866,9 +1872,6 @@ static int sky2_down(struct net_device *
 	sky2_phy_power_down(hw, port);
 	spin_unlock_bh(&sky2->phy_lock);
 
-	/* turn off LED's */
-	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
-
 	sky2_tx_reset(hw, port);
 
 	/* Free any pending frames stuck in HW queue */
@@ -2982,8 +2985,6 @@ static void sky2_reset(struct sky2_hw *h
 	sky2_write8(hw, B2_TI_CTRL, TIM_STOP);
 	sky2_write8(hw, B2_TI_CTRL, TIM_CLR_IRQ);
 
-	sky2_write8(hw, B0_Y2LED, LED_STAT_ON);
-
 	/* Turn off descriptor polling */
 	sky2_write32(hw, B28_DPT_CTRL, DPT_STOP);
 
@@ -4600,7 +4601,6 @@ static void __devexit sky2_remove(struct
 
 	sky2_power_aux(hw);
 
-	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 	sky2_write8(hw, B0_CTST, CS_RST_SET);
 	sky2_read8(hw, B0_CTST);
 
--- a/drivers/net/sky2.h	2009-08-31 09:05:07.954719390 -0700
+++ b/drivers/net/sky2.h	2009-08-31 09:05:36.488716877 -0700
@@ -155,7 +155,7 @@ enum pci_cfg_reg1 {
 enum csr_regs {
 	B0_RAP		= 0x0000,
 	B0_CTST		= 0x0004,
-	B0_Y2LED	= 0x0005,
+
 	B0_POWER_CTRL	= 0x0007,
 	B0_ISRC		= 0x0008,
 	B0_IMSK		= 0x000c,
@@ -283,13 +283,6 @@ enum {
 	CS_RST_SET	= 1,	/* Set   Software reset	*/
 };
 
-/*	B0_LED			 8 Bit	LED register */
-enum {
-/* Bit  7.. 2:	reserved */
-	LED_STAT_ON	= 1<<1,	/* Status LED on	*/
-	LED_STAT_OFF	= 1,	/* Status LED off	*/
-};
-
 /*	B0_POWER_CTRL	 8 Bit	Power Control reg (YUKON only) */
 enum {
 	PC_VAUX_ENA	= 1<<7,	/* Switch VAUX Enable  */
