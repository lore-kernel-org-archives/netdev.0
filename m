From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/3] r8169: RxFIFO overflow oddities with 8168 chipsets
Date: Thu, 3 Feb 2011 18:26:47 +0100
Message-ID: <20110203172647.GC9024@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36854 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756162Ab1BCR3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 12:29:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some experiment-based action to prevent my 8168 chipsets locking-up hard
in the irq handler under load (pktgen ~1Mpps). Apparently a reset is not
always mandatory (is it at all ?).

- RTL_GIGA_MAC_VER_12
- RTL_GIGA_MAC_VER_25
  Missed ~55% packets. Note:
  - this is an old SiS 965L motherboard
  - the 8168 chipset emits (lots of) control frames towards the sender

- RTL_GIGA_MAC_VER_26
  The chipset does not go into a frenzy of mac control pause when it
  crashes yet but it can still be crashed. It needs more work.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Ivan Vecera <ivecera@redhat.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   30 +++++++++++++++++++++---------
 1 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9ab3b43..40dabe2 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -973,7 +973,8 @@ static void __rtl8169_check_link_status(struct net_device *dev,
 		if (pm)
 			pm_request_resume(&tp->pci_dev->dev);
 		netif_carrier_on(dev);
-		netif_info(tp, ifup, dev, "link up\n");
+		if (net_ratelimit())
+			netif_info(tp, ifup, dev, "link up\n");
 	} else {
 		netif_carrier_off(dev);
 		netif_info(tp, ifdown, dev, "link down\n");
@@ -4640,13 +4641,24 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			break;
 		}
 
-		/* Work around for rx fifo overflow */
-		if (unlikely(status & RxFIFOOver) &&
-		    (tp->mac_version == RTL_GIGA_MAC_VER_11 ||
-		     tp->mac_version == RTL_GIGA_MAC_VER_22)) {
-			netif_stop_queue(dev);
-			rtl8169_tx_timeout(dev);
-			break;
+		if (unlikely(status & RxFIFOOver)) {
+			switch (tp->mac_version) {
+			/* Work around for rx fifo overflow */
+			case RTL_GIGA_MAC_VER_11:
+			case RTL_GIGA_MAC_VER_22:
+			case RTL_GIGA_MAC_VER_26:
+				netif_stop_queue(dev);
+				rtl8169_tx_timeout(dev);
+				goto done;
+			/* Experimental science. Pktgen proof. */
+			case RTL_GIGA_MAC_VER_12:
+			case RTL_GIGA_MAC_VER_25:
+				if (status == RxFIFOOver)
+					goto done;
+				break;
+			default:
+				break;
+			}
 		}
 
 		if (unlikely(status & SYSErr)) {
@@ -4682,7 +4694,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			(status & RxFIFOOver) ? (status | RxOverflow) : status);
 		status = RTL_R16(IntrStatus);
 	}
-
+done:
 	return IRQ_RETVAL(handled);
 }
 
-- 
1.7.3.5

