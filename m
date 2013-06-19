From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 1/2] sh_eth: define/use EESR_RX_CHECK macro
Date: Wed, 19 Jun 2013 23:29:23 +0400
Message-ID: <201306192329.24022.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:42436 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935093Ab3FST3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 15:29:23 -0400
Received: by mail-la0-f50.google.com with SMTP id dy20so4909090lab.37
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 12:29:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sh_eth_interrupt() uses the same Rx interrupt mask twice to check the interrupt
status register -- #define EESR_RX_CHECK  and use it instead. 

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the Dave Miller's 'net-next.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |   13 ++-----------
 drivers/net/ethernet/renesas/sh_eth.h |    8 ++++++++
 2 files changed, 10 insertions(+), 11 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1497,23 +1497,14 @@ static irqreturn_t sh_eth_interrupt(int 
 	 */
 	intr_status &= sh_eth_read(ndev, EESIPR) | DMAC_M_ECI;
 	/* Clear interrupt */
-	if (intr_status & (EESR_FRC | EESR_RMAF | EESR_RRF |
-			EESR_RTLF | EESR_RTSF | EESR_PRE | EESR_CERF |
-			cd->tx_check | cd->eesr_err_check)) {
+	if (intr_status & (EESR_RX_CHECK | cd->tx_check | cd->eesr_err_check)) {
 		sh_eth_write(ndev, intr_status, EESR);
 		ret = IRQ_HANDLED;
 	} else
 		goto other_irq;
 
-	if (intr_status & (EESR_FRC | /* Frame recv*/
-			EESR_RMAF | /* Multi cast address recv*/
-			EESR_RRF  | /* Bit frame recv */
-			EESR_RTLF | /* Long frame recv*/
-			EESR_RTSF | /* short frame recv */
-			EESR_PRE  | /* PHY-LSI recv error */
-			EESR_CERF)){ /* recv frame CRC error */
+	if (intr_status & EESR_RX_CHECK)
 		sh_eth_rx(ndev, intr_status);
-	}
 
 	/* Tx Check */
 	if (intr_status & cd->tx_check) {
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -248,6 +248,14 @@ enum EESR_BIT {
 	EESR_CERF	= 0x00000001,
 };
 
+#define EESR_RX_CHECK		(EESR_FRC  | /* Frame recv */		\
+				 EESR_RMAF | /* Multicast address recv */ \
+				 EESR_RRF  | /* Bit frame recv */	\
+				 EESR_RTLF | /* Long frame recv */	\
+				 EESR_RTSF | /* Short frame recv */	\
+				 EESR_PRE  | /* PHY-LSI recv error */	\
+				 EESR_CERF)  /* Recv frame CRC error */
+
 #define DEFAULT_TX_CHECK	(EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | \
 				 EESR_RTO)
 #define DEFAULT_EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | \
