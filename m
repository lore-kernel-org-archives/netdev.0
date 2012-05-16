From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 2/8] mISDN: Early confirm for transparent data
Date: Wed, 16 May 2012 06:22:48 +0200
Message-ID: <1337142174-8304-3-git-send-email-kkeil@linux-pingi.de>
References: <1337142174-8304-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:50382 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863Ab2EPEcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 00:32:12 -0400
In-Reply-To: <1337142174-8304-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is better to send a confirm for transparent data early as possible
to avoid TX underuns.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c  |   21 ++++++---------------
 drivers/isdn/hardware/mISDN/hfcmulti.c  |   21 +++++----------------
 drivers/isdn/hardware/mISDN/hfcpci.c    |   14 +++-----------
 drivers/isdn/hardware/mISDN/hfcsusb.c   |   15 ++-------------
 drivers/isdn/hardware/mISDN/mISDNipac.c |   21 ++++++---------------
 drivers/isdn/hardware/mISDN/mISDNisar.c |   18 +++++-------------
 drivers/isdn/hardware/mISDN/netjet.c    |   21 ++++++---------------
 drivers/isdn/hardware/mISDN/w6692.c     |   21 ++++++---------------
 drivers/isdn/mISDN/hwchannel.c          |    8 ++++----
 include/linux/mISDNhw.h                 |    1 -
 10 files changed, 43 insertions(+), 118 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index 2271f2b..788b9a7 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -488,15 +488,11 @@ hdlc_fill_fifo(struct bchannel *bch)
 static void
 HDLC_irq_xpr(struct bchannel *bch)
 {
-	if (bch->tx_skb && bch->tx_idx < bch->tx_skb->len)
+	if (bch->tx_skb && bch->tx_idx < bch->tx_skb->len) {
 		hdlc_fill_fifo(bch);
-	else {
-		if (bch->tx_skb) {
-			/* send confirm, on trans, free on hdlc. */
-			if (test_bit(FLG_TRANSPARENT, &bch->Flags))
-				confirm_Bsend(bch);
+	} else {
+		if (bch->tx_skb)
 			dev_kfree_skb(bch->tx_skb);
-		}
 		if (get_next_bframe(bch))
 			hdlc_fill_fifo(bch);
 	}
@@ -659,22 +655,17 @@ avm_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 	struct fritzcard *fc = bch->hw;
 	int ret = -EINVAL;
 	struct mISDNhead *hh = mISDN_HEAD_P(skb);
-	u32 id;
-	u_long flags;
+	unsigned long flags;
 
 	switch (hh->prim) {
 	case PH_DATA_REQ:
 		spin_lock_irqsave(&fc->lock, flags);
 		ret = bchannel_senddata(bch, skb);
 		if (ret > 0) { /* direct TX */
-			id = hh->id; /* skb can be freed */
 			hdlc_fill_fifo(bch);
 			ret = 0;
-			spin_unlock_irqrestore(&fc->lock, flags);
-			if (!test_bit(FLG_TRANSPARENT, &bch->Flags))
-				queue_ch_frame(ch, PH_DATA_CNF, id, NULL);
-		} else
-			spin_unlock_irqrestore(&fc->lock, flags);
+		}
+		spin_unlock_irqrestore(&fc->lock, flags);
 		return ret;
 	case PH_ACTIVATE_REQ:
 		spin_lock_irqsave(&fc->lock, flags);
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 25fab85..bcb2b8e 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -2166,13 +2166,9 @@ next_frame:
 		HFC_wait_nodebug(hc);
 	}
 
-	/* send confirm, since get_net_bframe will not do it with trans */
-	if (bch && test_bit(FLG_TRANSPARENT, &bch->Flags))
-		confirm_Bsend(bch);
-
-	/* check for next frame */
 	dev_kfree_skb(*sp);
-	if (bch && get_next_bframe(bch)) { /* hdlc is confirmed here */
+	/* check for next frame */
+	if (bch && get_next_bframe(bch)) {
 		len = (*sp)->len;
 		goto next_frame;
 	}
@@ -3482,8 +3478,7 @@ handle_bmsg(struct mISDNchannel *ch, struct sk_buff *skb)
 	struct hfc_multi	*hc = bch->hw;
 	int			ret = -EINVAL;
 	struct mISDNhead	*hh = mISDN_HEAD_P(skb);
-	unsigned int		id;
-	u_long			flags;
+	unsigned long		flags;
 
 	switch (hh->prim) {
 	case PH_DATA_REQ:
@@ -3492,19 +3487,13 @@ handle_bmsg(struct mISDNchannel *ch, struct sk_buff *skb)
 		spin_lock_irqsave(&hc->lock, flags);
 		ret = bchannel_senddata(bch, skb);
 		if (ret > 0) { /* direct TX */
-			id = hh->id; /* skb can be freed */
 			hfcmulti_tx(hc, bch->slot);
 			ret = 0;
 			/* start fifo */
 			HFC_outb_nodebug(hc, R_FIFO, 0);
 			HFC_wait_nodebug(hc);
-			if (!test_bit(FLG_TRANSPARENT, &bch->Flags)) {
-				spin_unlock_irqrestore(&hc->lock, flags);
-				queue_ch_frame(ch, PH_DATA_CNF, id, NULL);
-			} else
-				spin_unlock_irqrestore(&hc->lock, flags);
-		} else
-			spin_unlock_irqrestore(&hc->lock, flags);
+		}
+		spin_unlock_irqrestore(&hc->lock, flags);
 		return ret;
 	case PH_ACTIVATE_REQ:
 		if (debug & DEBUG_HFCMULTI_MSG)
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index f7a5ea7..123e8e5 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -849,9 +849,6 @@ hfcpci_fill_fifo(struct bchannel *bch)
 		*z1t = cpu_to_le16(new_z1);	/* now send data */
 		if (bch->tx_idx < bch->tx_skb->len)
 			return;
-		/* send confirm, on trans, free on hdlc. */
-		if (test_bit(FLG_TRANSPARENT, &bch->Flags))
-			confirm_Bsend(bch);
 		dev_kfree_skb(bch->tx_skb);
 		if (get_next_bframe(bch))
 			goto next_t_frame;
@@ -1691,22 +1688,17 @@ hfcpci_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 	struct hfc_pci		*hc = bch->hw;
 	int			ret = -EINVAL;
 	struct mISDNhead	*hh = mISDN_HEAD_P(skb);
-	unsigned int		id;
-	u_long			flags;
+	unsigned long		flags;
 
 	switch (hh->prim) {
 	case PH_DATA_REQ:
 		spin_lock_irqsave(&hc->lock, flags);
 		ret = bchannel_senddata(bch, skb);
 		if (ret > 0) { /* direct TX */
-			id = hh->id; /* skb can be freed */
 			hfcpci_fill_fifo(bch);
 			ret = 0;
-			spin_unlock_irqrestore(&hc->lock, flags);
-			if (!test_bit(FLG_TRANSPARENT, &bch->Flags))
-				queue_ch_frame(ch, PH_DATA_CNF, id, NULL);
-		} else
-			spin_unlock_irqrestore(&hc->lock, flags);
+		}
+		spin_unlock_irqrestore(&hc->lock, flags);
 		return ret;
 	case PH_ACTIVATE_REQ:
 		spin_lock_irqsave(&hc->lock, flags);
diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index add28ac..a4c5b24 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -226,15 +226,8 @@ hfcusb_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 		if (debug & DBG_HFC_CALL_TRACE)
 			printk(KERN_DEBUG "%s: %s PH_DATA_REQ ret(%i)\n",
 			       hw->name, __func__, ret);
-		if (ret > 0) {
-			/*
-			 * other l1 drivers don't send early confirms on
-			 * transp data, but hfcsusb does because tx_next
-			 * skb is needed in tx_iso_complete()
-			 */
-			queue_ch_frame(ch, PH_DATA_CNF, hh->id, NULL);
+		if (ret > 0)
 			ret = 0;
-		}
 		return ret;
 	case PH_ACTIVATE_REQ:
 		if (!test_and_set_bit(FLG_ACTIVE, &bch->Flags)) {
@@ -1365,12 +1358,8 @@ tx_iso_complete(struct urb *urb)
 				if (fifo->dch && get_next_dframe(fifo->dch))
 					tx_skb = fifo->dch->tx_skb;
 				else if (fifo->bch &&
-					 get_next_bframe(fifo->bch)) {
-					if (test_bit(FLG_TRANSPARENT,
-						     &fifo->bch->Flags))
-						confirm_Bsend(fifo->bch);
+					 get_next_bframe(fifo->bch))
 					tx_skb = fifo->bch->tx_skb;
-				}
 			}
 		}
 		errcode = usb_submit_urb(urb, GFP_ATOMIC);
diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index 6c044d5..e4b6d8d 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -1011,15 +1011,11 @@ hscx_fill_fifo(struct hscx_hw *hscx)
 static void
 hscx_xpr(struct hscx_hw *hx)
 {
-	if (hx->bch.tx_skb && hx->bch.tx_idx < hx->bch.tx_skb->len)
+	if (hx->bch.tx_skb && hx->bch.tx_idx < hx->bch.tx_skb->len) {
 		hscx_fill_fifo(hx);
-	else {
-		if (hx->bch.tx_skb) {
-			/* send confirm, on trans, free on hdlc. */
-			if (test_bit(FLG_TRANSPARENT, &hx->bch.Flags))
-				confirm_Bsend(&hx->bch);
+	} else {
+		if (hx->bch.tx_skb)
 			dev_kfree_skb(hx->bch.tx_skb);
-		}
 		if (get_next_bframe(&hx->bch))
 			hscx_fill_fifo(hx);
 	}
@@ -1342,22 +1338,17 @@ hscx_l2l1(struct mISDNchannel *ch, struct sk_buff *skb)
 	struct hscx_hw	*hx = container_of(bch, struct hscx_hw, bch);
 	int ret = -EINVAL;
 	struct mISDNhead *hh = mISDN_HEAD_P(skb);
-	u32 id;
-	u_long flags;
+	unsigned long flags;
 
 	switch (hh->prim) {
 	case PH_DATA_REQ:
 		spin_lock_irqsave(hx->ip->hwlock, flags);
 		ret = bchannel_senddata(bch, skb);
 		if (ret > 0) { /* direct TX */
-			id = hh->id; /* skb can be freed */
 			ret = 0;
 			hscx_fill_fifo(hx);
-			spin_unlock_irqrestore(hx->ip->hwlock, flags);
-			if (!test_bit(FLG_TRANSPARENT, &bch->Flags))
-				queue_ch_frame(ch, PH_DATA_CNF, id, NULL);
-		} else
-			spin_unlock_irqrestore(hx->ip->hwlock, flags);
+		}
+		spin_unlock_irqrestore(hx->ip->hwlock, flags);
 		return ret;
 	case PH_ACTIVATE_REQ:
 		spin_lock_irqsave(hx->ip->hwlock, flags);
diff --git a/drivers/isdn/hardware/mISDN/mISDNisar.c b/drivers/isdn/hardware/mISDN/mISDNisar.c
index af9a966..9deea88 100644
--- a/drivers/isdn/hardware/mISDN/mISDNisar.c
+++ b/drivers/isdn/hardware/mISDN/mISDNisar.c
@@ -702,15 +702,11 @@ send_next(struct isar_ch *ch)
 			}
 		}
 	}
-	if (ch->bch.tx_skb) {
-		/* send confirm, on trans, free on hdlc. */
-		if (test_bit(FLG_TRANSPARENT, &ch->bch.Flags))
-			confirm_Bsend(&ch->bch);
+	if (ch->bch.tx_skb)
 		dev_kfree_skb(ch->bch.tx_skb);
-	}
-	if (get_next_bframe(&ch->bch))
+	if (get_next_bframe(&ch->bch)) {
 		isar_fill_fifo(ch);
-	else {
+	} else {
 		if (test_and_clear_bit(FLG_DLEETX, &ch->bch.Flags)) {
 			if (test_and_clear_bit(FLG_LASTDATA,
 					       &ch->bch.Flags)) {
@@ -1487,14 +1483,10 @@ isar_l2l1(struct mISDNchannel *ch, struct sk_buff *skb)
 		spin_lock_irqsave(ich->is->hwlock, flags);
 		ret = bchannel_senddata(bch, skb);
 		if (ret > 0) { /* direct TX */
-			id = hh->id; /* skb can be freed */
 			ret = 0;
 			isar_fill_fifo(ich);
-			spin_unlock_irqrestore(ich->is->hwlock, flags);
-			if (!test_bit(FLG_TRANSPARENT, &bch->Flags))
-				queue_ch_frame(ch, PH_DATA_CNF, id, NULL);
-		} else
-			spin_unlock_irqrestore(ich->is->hwlock, flags);
+		}
+		spin_unlock_irqrestore(ich->is->hwlock, flags);
 		return ret;
 	case PH_ACTIVATE_REQ:
 		spin_lock_irqsave(ich->is->hwlock, flags);
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index 55a77ed..da13b07 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -595,15 +595,11 @@ fill_dma(struct tiger_ch *bc)
 static int
 bc_next_frame(struct tiger_ch *bc)
 {
-	if (bc->bch.tx_skb && bc->bch.tx_idx < bc->bch.tx_skb->len)
+	if (bc->bch.tx_skb && bc->bch.tx_idx < bc->bch.tx_skb->len) {
 		fill_dma(bc);
-	else {
-		if (bc->bch.tx_skb) {
-			/* send confirm, on trans, free on hdlc. */
-			if (test_bit(FLG_TRANSPARENT, &bc->bch.Flags))
-				confirm_Bsend(&bc->bch);
+	} else {
+		if (bc->bch.tx_skb)
 			dev_kfree_skb(bc->bch.tx_skb);
-		}
 		if (get_next_bframe(&bc->bch))
 			fill_dma(bc);
 		else
@@ -732,22 +728,17 @@ nj_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 	struct tiger_ch *bc = container_of(bch, struct tiger_ch, bch);
 	struct tiger_hw *card = bch->hw;
 	struct mISDNhead *hh = mISDN_HEAD_P(skb);
-	u32 id;
-	u_long flags;
+	unsigned long flags;
 
 	switch (hh->prim) {
 	case PH_DATA_REQ:
 		spin_lock_irqsave(&card->lock, flags);
 		ret = bchannel_senddata(bch, skb);
 		if (ret > 0) { /* direct TX */
-			id = hh->id; /* skb can be freed */
 			fill_dma(bc);
 			ret = 0;
-			spin_unlock_irqrestore(&card->lock, flags);
-			if (!test_bit(FLG_TRANSPARENT, &bch->Flags))
-				queue_ch_frame(ch, PH_DATA_CNF, id, NULL);
-		} else
-			spin_unlock_irqrestore(&card->lock, flags);
+		}
+		spin_unlock_irqrestore(&card->lock, flags);
 		return ret;
 	case PH_ACTIVATE_REQ:
 		spin_lock_irqsave(&card->lock, flags);
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 0b5e929..f1c0bf1 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -638,15 +638,11 @@ w6692_mode(struct w6692_ch *wch, u32 pr)
 static void
 send_next(struct w6692_ch *wch)
 {
-	if (wch->bch.tx_skb && wch->bch.tx_idx < wch->bch.tx_skb->len)
+	if (wch->bch.tx_skb && wch->bch.tx_idx < wch->bch.tx_skb->len) {
 		W6692_fill_Bfifo(wch);
-	else {
-		if (wch->bch.tx_skb) {
-			/* send confirm, on trans, free on hdlc. */
-			if (test_bit(FLG_TRANSPARENT, &wch->bch.Flags))
-				confirm_Bsend(&wch->bch);
+	} else {
+		if (wch->bch.tx_skb)
 			dev_kfree_skb(wch->bch.tx_skb);
-		}
 		if (get_next_bframe(&wch->bch))
 			W6692_fill_Bfifo(wch);
 	}
@@ -944,22 +940,17 @@ w6692_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 	struct w6692_hw *card = bch->hw;
 	int ret = -EINVAL;
 	struct mISDNhead *hh = mISDN_HEAD_P(skb);
-	u32 id;
-	u_long flags;
+	unsigned long flags;
 
 	switch (hh->prim) {
 	case PH_DATA_REQ:
 		spin_lock_irqsave(&card->lock, flags);
 		ret = bchannel_senddata(bch, skb);
 		if (ret > 0) { /* direct TX */
-			id = hh->id; /* skb can be freed */
 			ret = 0;
 			W6692_fill_Bfifo(bc);
-			spin_unlock_irqrestore(&card->lock, flags);
-			if (!test_bit(FLG_TRANSPARENT, &bch->Flags))
-				queue_ch_frame(ch, PH_DATA_CNF, id, NULL);
-		} else
-			spin_unlock_irqrestore(&card->lock, flags);
+		}
+		spin_unlock_irqrestore(&card->lock, flags);
 		return ret;
 	case PH_ACTIVATE_REQ:
 		spin_lock_irqsave(&card->lock, flags);
diff --git a/drivers/isdn/mISDN/hwchannel.c b/drivers/isdn/mISDN/hwchannel.c
index c74c363..5c5ab47 100644
--- a/drivers/isdn/mISDN/hwchannel.c
+++ b/drivers/isdn/mISDN/hwchannel.c
@@ -272,7 +272,7 @@ get_next_dframe(struct dchannel *dch)
 }
 EXPORT_SYMBOL(get_next_dframe);
 
-void
+static void
 confirm_Bsend(struct bchannel *bch)
 {
 	struct sk_buff	*skb;
@@ -294,7 +294,6 @@ confirm_Bsend(struct bchannel *bch)
 	skb_queue_tail(&bch->rqueue, skb);
 	schedule_event(bch, FLG_RECVQUEUE);
 }
-EXPORT_SYMBOL(confirm_Bsend);
 
 int
 get_next_bframe(struct bchannel *bch)
@@ -305,8 +304,8 @@ get_next_bframe(struct bchannel *bch)
 		if (bch->tx_skb) {
 			bch->next_skb = NULL;
 			test_and_clear_bit(FLG_TX_NEXT, &bch->Flags);
-			if (!test_bit(FLG_TRANSPARENT, &bch->Flags))
-				confirm_Bsend(bch); /* not for transparent */
+			/* confirm imediately to allow next data */
+			confirm_Bsend(bch);
 			return 1;
 		} else {
 			test_and_clear_bit(FLG_TX_NEXT, &bch->Flags);
@@ -395,6 +394,7 @@ bchannel_senddata(struct bchannel *ch, struct sk_buff *skb)
 		/* write to fifo */
 		ch->tx_skb = skb;
 		ch->tx_idx = 0;
+		confirm_Bsend(ch);
 		return 1;
 	}
 }
diff --git a/include/linux/mISDNhw.h b/include/linux/mISDNhw.h
index de165b5..491afd6 100644
--- a/include/linux/mISDNhw.h
+++ b/include/linux/mISDNhw.h
@@ -182,7 +182,6 @@ extern void	recv_Echannel(struct dchannel *, struct dchannel *);
 extern void	recv_Bchannel(struct bchannel *, unsigned int id);
 extern void	recv_Dchannel_skb(struct dchannel *, struct sk_buff *);
 extern void	recv_Bchannel_skb(struct bchannel *, struct sk_buff *);
-extern void	confirm_Bsend(struct bchannel *bch);
 extern int	get_next_bframe(struct bchannel *);
 extern int	get_next_dframe(struct dchannel *);
 
-- 
1.7.3.4
