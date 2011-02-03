From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/3] r8169: use RxFIFO overflow workaround for 8168c chipset
Date: Thu, 3 Feb 2011 18:26:36 +0100
Message-ID: <20110203172636.GB9024@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36848 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756162Ab1BCR3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 12:29:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found that one of the 8168c chipsets (concretely XID 1c4000c0) starts
generating RxFIFO overflow errors. The result is an infinite loop in
interrupt handler as the RxFIFOOver is handled only for ...MAC_VER_11.
With the workaround everything goes fine.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bde7d61..9ab3b43 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3757,7 +3757,8 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	RTL_W16(IntrMitigate, 0x5151);
 
 	/* Work around for RxFIFO overflow. */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_11 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_22) {
 		tp->intr_event |= RxFIFOOver | PCSTimeout;
 		tp->intr_event &= ~RxOverflow;
 	}
@@ -4641,7 +4642,8 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 
 		/* Work around for rx fifo overflow */
 		if (unlikely(status & RxFIFOOver) &&
-		(tp->mac_version == RTL_GIGA_MAC_VER_11)) {
+		    (tp->mac_version == RTL_GIGA_MAC_VER_11 ||
+		     tp->mac_version == RTL_GIGA_MAC_VER_22)) {
 			netif_stop_queue(dev);
 			rtl8169_tx_timeout(dev);
 			break;
-- 
1.7.3.5

