From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH #2 0/0] r8169 driver fixes
Date: Fri, 4 Feb 2011 10:58:32 +0100
Message-ID: <20110204095832.GA9224@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55732 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754930Ab1BDKBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 05:01:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rebased on top of davem/net-2.6.git.

The following series includes Ivan Rx fifo overflow fix and similar
changes I did after testing with various 8168 chipsets.

The series is available as
git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-davem

to get the changes below.

Distance from 'davem' (38db9e1db1c91c953b2a539130257ce91533c9f6)
----------------------------------------------------------------

f60ac8e7ab7cbb413a0131d5665b053f9f386526
1519e57fe81c14bb8fa4855579f19264d1ef63b4
b5ba6d12bdac21bc0620a5089e0f24e362645efd

Diffstat
--------

 drivers/net/r8169.c |   41 ++++++++++++++++++++++++++++++++---------
 1 files changed, 32 insertions(+), 9 deletions(-)

Shortlog
--------

Francois Romieu (2):
      r8169: RxFIFO overflow oddities with 8168 chipsets.
      r8169: prevent RxFIFO induced loops in the irq handler.

Ivan Vecera (1):
      r8169: use RxFIFO overflow workaround for 8168c chipset.

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bde7d61..59ccf0c 100644
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
@@ -3757,7 +3758,8 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	RTL_W16(IntrMitigate, 0x5151);
 
 	/* Work around for RxFIFO overflow. */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_11 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_22) {
 		tp->intr_event |= RxFIFOOver | PCSTimeout;
 		tp->intr_event &= ~RxOverflow;
 	}
@@ -4639,12 +4641,33 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			break;
 		}
 
-		/* Work around for rx fifo overflow */
-		if (unlikely(status & RxFIFOOver) &&
-		(tp->mac_version == RTL_GIGA_MAC_VER_11)) {
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
+			/* Testers needed. */
+			case RTL_GIGA_MAC_VER_17:
+			case RTL_GIGA_MAC_VER_19:
+			case RTL_GIGA_MAC_VER_20:
+			case RTL_GIGA_MAC_VER_21:
+			case RTL_GIGA_MAC_VER_23:
+			case RTL_GIGA_MAC_VER_24:
+			case RTL_GIGA_MAC_VER_27:
+			case RTL_GIGA_MAC_VER_28:
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
@@ -4680,7 +4703,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			(status & RxFIFOOver) ? (status | RxOverflow) : status);
 		status = RTL_R16(IntrStatus);
 	}
-
+done:
 	return IRQ_RETVAL(handled);
 }
 
-- 
Ueimor
