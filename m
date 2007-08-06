From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/2] r8169: avoid needless NAPI poll scheduling
Date: Tue, 7 Aug 2007 00:22:23 +0200
Message-ID: <20070806222223.GD23302@electric-eye.fr.zoreil.com>
References: <20070806221612.GA23302@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Andy Gospodarek <agospoda@redhat.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54134 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823AbXHFW0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 18:26:55 -0400
Content-Disposition: inline
In-Reply-To: <20070806221612.GA23302@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Theory  : though needless, it should not have hurt.
Practice: it does not play nice with DEBUG_SHIRQ + LOCKDEP + UP
(see https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=242572).

The patch makes sense in itself but I should dig why it has an effect
on #242572 (assuming that NAPI do not change in a near future).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index ec4f545..631e55d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2767,14 +2767,16 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			rtl8169_check_link_status(dev, tp, ioaddr);
 
 #ifdef CONFIG_R8169_NAPI
-		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
-		tp->intr_mask = ~tp->napi_event;
-
-		if (likely(netif_rx_schedule_prep(dev)))
-			__netif_rx_schedule(dev);
-		else if (netif_msg_intr(tp)) {
-			printk(KERN_INFO "%s: interrupt %04x taken in poll\n",
-			       dev->name, status);
+		if (status & tp->napi_event) {
+			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
+			tp->intr_mask = ~tp->napi_event;
+
+			if (likely(netif_rx_schedule_prep(dev)))
+				__netif_rx_schedule(dev);
+			else if (netif_msg_intr(tp)) {
+				printk(KERN_INFO "%s: interrupt %04x in poll\n",
+				       dev->name, status);
+			}
 		}
 		break;
 #else
-- 
1.4.4.2

