From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 24/28] mISDN: Bufferlimits for hfcmulti
Date: Sat, 21 Apr 2012 17:55:29 +0200
Message-ID: <20120423170551.899DE9FBC7@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:50680 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754349Ab2DWRIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the minimum packet length for transparent data.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c |   51 +++++++++++++++++++++++---------
 1 files changed, 37 insertions(+), 14 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 144c35a..50d10ea 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -2374,25 +2374,36 @@ next_frame:
 	} else {
 		/* transparent */
 		if (*sp == NULL) {
-			*sp = mI_alloc_skb(Zsize, GFP_ATOMIC);
+			if (Zsize >= bch->minlen)
+				temp = Zsize;
+			else
+				temp = 2 * bch->minlen;
+			if (temp > maxlen)
+				temp = maxlen;
+
+			*sp = mI_alloc_skb(temp, GFP_ATOMIC);
 			if (*sp == NULL) {
 				printk(KERN_DEBUG "%s: No mem for rx_skb\n",
 				    __func__);
 				return;
 			}
 		}
-		if (Zsize > skb_tailroom(*sp))
-			Zsize = skb_tailroom(*sp);
-		hc->read_fifo(hc, skb_put(*sp, Zsize), Zsize);
-		skb = NULL;
+		temp = Zsize;
+		if (temp > skb_tailroom(*sp))
+			temp = skb_tailroom(*sp);
+		hc->read_fifo(hc, skb_put(*sp, temp), temp);
 		if (debug & DEBUG_HFCMULTI_FIFO)
 			printk(KERN_DEBUG
-			       "%s(card %d): fifo(%d) reading %d bytes "
-			       "(z1=%04x, z2=%04x) TRANS\n",
-			       __func__, hc->id + 1, ch, Zsize, z1, z2);
-		/* only bch is transparent */
-		recv_Bchannel(bch, hc->chan[ch].Zfill);
-		*sp = skb;
+			    "%s(card %d): fifo(%d) reading %d/%d bytes "
+			    "(z1=%04x, z2=%04x) TRANS\n", __func__,
+			    hc->id + 1, ch, temp, Zsize, z1, z2);
+		Zsize -= temp;
+		if ((*sp)->len >= bch->minlen) {
+			recv_Bchannel(bch, hc->chan[ch].Zfill);
+			*sp = NULL;
+			if (Zsize)
+				goto next_frame;
+		}
 	}
 }
 
@@ -3678,21 +3689,21 @@ static int
 channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 {
 	int			ret = 0;
-	struct dsp_features	*features =
-		(struct dsp_features *)(*((u_long *)&cq->p1));
+	struct dsp_features	*features;
 	struct hfc_multi	*hc = bch->hw;
 	int			slot_tx;
 	int			bank_tx;
 	int			slot_rx;
 	int			bank_rx;
 	int			num;
+	int			o1, o2;
 	u8			v1, v2;
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
 		cq->op = MISDN_CTRL_HFC_OP | MISDN_CTRL_HW_FEATURES_OP |
 			MISDN_CTRL_RX_OFF | MISDN_CTRL_FILL_EMPTY |
-			MISDN_CTRL_L1_TESTS;
+			MISDN_CTRL_L1_TESTS | MISDN_CTRL_RX_BUFFER;
 		break;
 	case MISDN_CTRL_RX_OFF: /* turn off / on rx stream */
 		hc->chan[bch->slot].rx_off = !!cq->p1;
@@ -3714,6 +3725,7 @@ channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 			       "off=%d)\n", __func__, bch->nr, !!cq->p1);
 		break;
 	case MISDN_CTRL_HW_FEATURES: /* fill features structure */
+		features = (struct dsp_features *)(*((u_long *)&cq->p1));
 		if (debug & DEBUG_HFCMULTI_MSG)
 			printk(KERN_DEBUG "%s: HW_FEATURE request\n",
 			       __func__);
@@ -3831,6 +3843,17 @@ channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 		cq->p3 = HFC_inb(hc, R_JATT_STA);
 		cq->p3 |= (HFC_inb(hc, R_SLIP) << 8);
 		break;
+	case MISDN_CTRL_RX_BUFFER:
+		/* We return the old values */
+		o1 = bch->minlen;
+		o2 =  bch->maxlen;
+		if (cq->p1 != MISDN_CTRL_RX_SIZE_IGNORE)
+			bch->minlen = cq->p1;
+		if (cq->p2 != MISDN_CTRL_RX_SIZE_IGNORE)
+			bch->minlen = cq->p2;
+		cq->p1 = o1;
+		cq->p2 = o2;
+		break;
 	default:
 		printk(KERN_WARNING "%s: unknown Op %x\n",
 		       __func__, cq->op);
-- 
1.7.3.4
