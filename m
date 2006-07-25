From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/3] tg3: Handle tg3_init_rings() failures
Date: Tue, 25 Jul 2006 15:56:20 -0700
Message-ID: <1153868180.3167.27.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sdoyon@max-t.com, howie@vmware.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:60682 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030219AbWGYWyw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 18:54:52 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handle dev_alloc_skb() failures when initializing the RX rings.
Without proper handling, the driver will crash when using a partial
ring.

Thanks to Stephane Doyon <sdoyon@max-t.com> for reporting the bug and
providing the initial patch.

Howie Xu <howie@vmware.com> also reported the same issue.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1253cec..d66b06f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4258,7 +4258,7 @@ static void tg3_free_rings(struct tg3 *t
  * end up in the driver.  tp->{tx,}lock are held and thus
  * we may not sleep.
  */
-static void tg3_init_rings(struct tg3 *tp)
+static int tg3_init_rings(struct tg3 *tp)
 {
 	u32 i;
 
@@ -4307,18 +4307,38 @@ static void tg3_init_rings(struct tg3 *t
 
 	/* Now allocate fresh SKBs for each rx ring. */
 	for (i = 0; i < tp->rx_pending; i++) {
-		if (tg3_alloc_rx_skb(tp, RXD_OPAQUE_RING_STD,
-				     -1, i) < 0)
+		if (tg3_alloc_rx_skb(tp, RXD_OPAQUE_RING_STD, -1, i) < 0) {
+			printk(KERN_WARNING PFX
+			       "%s: Using a smaller RX standard ring, "
+			       "only %d out of %d buffers were allocated "
+			       "successfully.\n",
+			       tp->dev->name, i, tp->rx_pending);
+			if (i == 0)
+				return -ENOMEM;
+			tp->rx_pending = i;
 			break;
+		}
 	}
 
 	if (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) {
 		for (i = 0; i < tp->rx_jumbo_pending; i++) {
 			if (tg3_alloc_rx_skb(tp, RXD_OPAQUE_RING_JUMBO,
-					     -1, i) < 0)
+					     -1, i) < 0) {
+				printk(KERN_WARNING PFX
+				       "%s: Using a smaller RX jumbo ring, "
+				       "only %d out of %d buffers were "
+				       "allocated successfully.\n",
+				       tp->dev->name, i, tp->rx_jumbo_pending);
+				if (i == 0) {
+					tg3_free_rings(tp);
+					return -ENOMEM;
+				}
+				tp->rx_jumbo_pending = i;
 				break;
+			}
 		}
 	}
+	return 0;
 }
 
 /*
@@ -5969,7 +5989,9 @@ static int tg3_reset_hw(struct tg3 *tp, 
 	 * can only do this after the hardware has been
 	 * successfully reset.
 	 */
-	tg3_init_rings(tp);
+	err = tg3_init_rings(tp);
+	if (err)
+		return err;
 
 	/* This value is determined during the probe time DMA
 	 * engine test, tg3_test_dma.


