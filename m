From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 06/18] tg3: Add mailbox assignments
Date: Tue, 1 Sep 2009 15:58:41 -0700
Message-ID: <1251867304.5929@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3813 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754097AbZIBEzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5717 assigns mailbox locations to interrupt vectors in a rather
non-intuitive way.  (Much of the complexity stems from legacy
compatibility issues.)  This patch implements the assignment scheme.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   59 ++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 50 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 12ead83..4d16ce0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9219,7 +9219,7 @@ static void tg3_get_ringparam(struct net_device *dev, struct ethtool_ringparam *
 static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	int irq_sync = 0, err = 0;
+	int i, irq_sync = 0, err = 0;
 
 	if ((ering->rx_pending > TG3_RX_RING_SIZE - 1) ||
 	    (ering->rx_jumbo_pending > TG3_RX_JUMBO_RING_SIZE - 1) ||
@@ -9243,7 +9243,9 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 	    tp->rx_pending > 63)
 		tp->rx_pending = 63;
 	tp->rx_jumbo_pending = ering->rx_jumbo_pending;
-	tp->napi[0].tx_pending = ering->tx_pending;
+
+	for (i = 0; i < TG3_IRQ_MAX_VECS; i++)
+		tp->napi[i].tx_pending = ering->tx_pending;
 
 	if (netif_running(dev)) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
@@ -13443,7 +13445,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	static int tg3_version_printed = 0;
 	struct net_device *dev;
 	struct tg3 *tp;
-	int err, pm_cap;
+	int i, err, pm_cap;
+	u32 sndmbx, rcvmbx, intmbx;
 	char str[40];
 	u64 dma_mask, persist_dma_mask;
 
@@ -13538,12 +13541,50 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	tp->rx_pending = TG3_DEF_RX_RING_PENDING;
 	tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
 
-	tp->napi[0].tp = tp;
-	tp->napi[0].int_mbox = MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW;
-	tp->napi[0].consmbox = MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW;
-	tp->napi[0].prodmbox = MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW;
-	tp->napi[0].coal_now = HOSTCC_MODE_NOW;
-	tp->napi[0].tx_pending = TG3_DEF_TX_RING_PENDING;
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
+		if (i)
+			tnapi->coal_now = HOSTCC_MODE_COAL_VEC1_NOW << (i - 1);
+		else
+			tnapi->coal_now = HOSTCC_MODE_NOW;
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
 	netif_napi_add(dev, &tp->napi[0].napi, tg3_poll, 64);
 	dev->ethtool_ops = &tg3_ethtool_ops;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
-- 
1.6.3.3


