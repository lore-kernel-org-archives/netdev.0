From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] enc28j60: reduce the number of spi transfers in
	enc28j60_set_bank()
Date: Thu, 18 Dec 2008 09:57:32 +0200
Message-ID: <20081218075732.GA1880@diamond.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:58548 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750888AbYLRH5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 02:57:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A major source of overhead in the enc28j60 driver is the SPI transfers. Each 
SPI transfer entails two kernel thread context switches. One major source of 
SPI transfers is the enc28j60_set_bank() functions which runs before every 
register access. This patch reduces the number of SPI transfers that 
enc28j60_set_bank() performs in two ways:

  1. removes unnecessary bank switch for the registers that are present in all 
	 banks

  2. when switching from banks 0 or 3 to banks 1 or 2 (i.e. only one bit 
	 changes) enc28j60_set_bank() does only one SPI transfer instead of two

According to my tests these changes reduce the number of SPI transfers in 
about 25%.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---

--- drivers/net/enc28j60.c-git	2008-12-18 09:29:49.000000000 +0200
+++ drivers/net/enc28j60.c	2008-12-18 09:33:14.000000000 +0200
@@ -196,16 +196,32 @@ static void enc28j60_soft_reset(struct e
  */
 static void enc28j60_set_bank(struct enc28j60_net *priv, u8 addr)
 {
-	if ((addr & BANK_MASK) != priv->bank) {
-		u8 b = (addr & BANK_MASK) >> 5;
+	u8 b = (addr & BANK_MASK) >> 5;
 
-		if (b != (ECON1_BSEL1 | ECON1_BSEL0))
+	/* These registers (EIE, EIR, ESTAT, ECON2, ECON1)
+	 * are present in all banks, no need to switch bank
+	 */
+	if (addr >= EIE && addr <= ECON1)
+		return;
+
+	/* Clear or set each bank selection bit as needed */
+	if ((b & ECON1_BSEL0) != (priv->bank & ECON1_BSEL0)) {
+		if (b & ECON1_BSEL0)
+			spi_write_op(priv, ENC28J60_BIT_FIELD_SET, ECON1,
+					ECON1_BSEL0);
+		else
+			spi_write_op(priv, ENC28J60_BIT_FIELD_CLR, ECON1,
+					ECON1_BSEL0);
+	}
+	if ((b & ECON1_BSEL1) != (priv->bank & ECON1_BSEL1)) {
+		if (b & ECON1_BSEL1)
+			spi_write_op(priv, ENC28J60_BIT_FIELD_SET, ECON1,
+					ECON1_BSEL1);
+		else
 			spi_write_op(priv, ENC28J60_BIT_FIELD_CLR, ECON1,
-				     ECON1_BSEL1 | ECON1_BSEL0);
-		if (b != 0)
-			spi_write_op(priv, ENC28J60_BIT_FIELD_SET, ECON1, b);
-		priv->bank = (addr & BANK_MASK);
+					ECON1_BSEL1);
 	}
+	priv->bank = b;
 }
 
 /*

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
