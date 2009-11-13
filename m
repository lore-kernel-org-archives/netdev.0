From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 10/20] tg3: Move napi_add calls below tg3_get_invariants
Date: Fri, 13 Nov 2009 15:03:42 -0800
Message-ID: <1258153432-7036-11-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4661 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932471AbZKMXEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3_get_invariants(), among other things, discovers whether or not
the device is MSI-X capable and how many interrupts it supports.
This discovery needs to happen before registering NAPI instances with
netdev.  This patch moves the code block that calls napi_add later in
tg3_init_one() so that tg3_get_invariants() has a chance to run first.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   94 ++++++++++++++++++++++++++--------------------------
 1 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5e17abb..f0360f8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -14089,53 +14089,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	tp->rx_pending = TG3_DEF_RX_RING_PENDING;
 	tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
 
-	intmbx = MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW;
-	rcvmbx = MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW;
-	sndmbx = MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW;
-	for (i = 0; i < TG3_IRQ_MAX_VECS; i++) {
-		struct tg3_napi *tnapi = &tp->napi[i];
-
-		tnapi->tp = tp;
-		tnapi->tx_pending = TG3_DEF_TX_RING_PENDING;
-
-		tnapi->int_mbox = intmbx;
-		if (i < 4)
-			intmbx += 0x8;
-		else
-			intmbx += 0x4;
-
-		tnapi->consmbox = rcvmbx;
-		tnapi->prodmbox = sndmbx;
-
-		if (i) {
-			tnapi->coal_now = HOSTCC_MODE_COAL_VEC1_NOW << (i - 1);
-			netif_napi_add(dev, &tnapi->napi, tg3_poll_msix, 64);
-		} else {
-			tnapi->coal_now = HOSTCC_MODE_NOW;
-			netif_napi_add(dev, &tnapi->napi, tg3_poll, 64);
-		}
-
-		if (!(tp->tg3_flags & TG3_FLAG_SUPPORT_MSIX))
-			break;
-
-		/*
-		 * If we support MSIX, we'll be using RSS.  If we're using
-		 * RSS, the first vector only handles link interrupts and the
-		 * remaining vectors handle rx and tx interrupts.  Reuse the
-		 * mailbox values for the next iteration.  The values we setup
-		 * above are still useful for the single vectored mode.
-		 */
-		if (!i)
-			continue;
-
-		rcvmbx += 0x8;
-
-		if (sndmbx & 0x4)
-			sndmbx -= 0x4;
-		else
-			sndmbx += 0xc;
-	}
-
 	dev->ethtool_ops = &tg3_ethtool_ops;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
 	dev->irq = pdev->irq;
@@ -14278,6 +14231,53 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
 	tp->link_config.flowctrl = FLOW_CTRL_TX | FLOW_CTRL_RX;
 
+	intmbx = MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW;
+	rcvmbx = MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW;
+	sndmbx = MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW;
+	for (i = 0; i < TG3_IRQ_MAX_VECS; i++) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+
+		tnapi->tp = tp;
+		tnapi->tx_pending = TG3_DEF_TX_RING_PENDING;
+
+		tnapi->int_mbox = intmbx;
+		if (i < 4)
+			intmbx += 0x8;
+		else
+			intmbx += 0x4;
+
+		tnapi->consmbox = rcvmbx;
+		tnapi->prodmbox = sndmbx;
+
+		if (i) {
+			tnapi->coal_now = HOSTCC_MODE_COAL_VEC1_NOW << (i - 1);
+			netif_napi_add(dev, &tnapi->napi, tg3_poll_msix, 64);
+		} else {
+			tnapi->coal_now = HOSTCC_MODE_NOW;
+			netif_napi_add(dev, &tnapi->napi, tg3_poll, 64);
+		}
+
+		if (!(tp->tg3_flags & TG3_FLAG_SUPPORT_MSIX))
+			break;
+
+		/*
+		 * If we support MSIX, we'll be using RSS.  If we're using
+		 * RSS, the first vector only handles link interrupts and the
+		 * remaining vectors handle rx and tx interrupts.  Reuse the
+		 * mailbox values for the next iteration.  The values we setup
+		 * above are still useful for the single vectored mode.
+		 */
+		if (!i)
+			continue;
+
+		rcvmbx += 0x8;
+
+		if (sndmbx & 0x4)
+			sndmbx -= 0x4;
+		else
+			sndmbx += 0xc;
+	}
+
 	tg3_init_coal(tp);
 
 	pci_set_drvdata(pdev, dev);
-- 
1.6.4.4


