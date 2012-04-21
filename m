From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 19/28] mISDN: Early confirm for transparent data
Date: Sat, 21 Apr 2012 17:11:17 +0200
Message-ID: <20120423170551.5F5E29FB78@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:64024 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209Ab2DWRIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is better to send a confirm early, less TX underuns will
happen.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c  |    7 ++-----
 drivers/isdn/hardware/mISDN/hfcmulti.c  |    9 ++-------
 drivers/isdn/hardware/mISDN/hfcpci.c    |    7 ++-----
 drivers/isdn/hardware/mISDN/hfcsusb.c   |    6 ------
 drivers/isdn/hardware/mISDN/mISDNipac.c |    7 ++-----
 drivers/isdn/hardware/mISDN/mISDNisar.c |    7 ++-----
 drivers/isdn/hardware/mISDN/netjet.c    |    7 ++-----
 drivers/isdn/hardware/mISDN/w6692.c     |    7 ++-----
 drivers/isdn/mISDN/hwchannel.c          |    5 +++--
 9 files changed, 17 insertions(+), 45 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index e76e1ba..c773a7f 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -670,11 +670,8 @@ avm_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 			id = hh->id; /* skb can be freed */
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
index e91f82a..d826586 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -3586,13 +3586,8 @@ handle_bmsg(struct mISDNchannel *ch, struct sk_buff *skb)
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
index 9262136..6a0d964 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -1702,11 +1702,8 @@ hfcpci_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 			id = hh->id; /* skb can be freed */
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
index add28ac..404184a 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -227,12 +227,6 @@ hfcusb_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 			printk(KERN_DEBUG "%s: %s PH_DATA_REQ ret(%i)\n",
 			       hw->name, __func__, ret);
 		if (ret > 0) {
-			/*
-			 * other l1 drivers don't send early confirms on
-			 * transp data, but hfcsusb does because tx_next
-			 * skb is needed in tx_iso_complete()
-			 */
-			queue_ch_frame(ch, PH_DATA_CNF, hh->id, NULL);
 			ret = 0;
 		}
 		return ret;
diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index 4c1937b..d301d8c 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -1349,11 +1349,8 @@ hscx_l2l1(struct mISDNchannel *ch, struct sk_buff *skb)
 			id = hh->id; /* skb can be freed */
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
index af9a966..8db914a 100644
--- a/drivers/isdn/hardware/mISDN/mISDNisar.c
+++ b/drivers/isdn/hardware/mISDN/mISDNisar.c
@@ -1490,11 +1490,8 @@ isar_l2l1(struct mISDNchannel *ch, struct sk_buff *skb)
 			id = hh->id; /* skb can be freed */
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
index 0dccda8..fd421e7 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -743,11 +743,8 @@ nj_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 			id = hh->id; /* skb can be freed */
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
index dec013e1..0424652 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -955,11 +955,8 @@ w6692_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 			id = hh->id; /* skb can be freed */
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
index c74c363..a250244 100644
--- a/drivers/isdn/mISDN/hwchannel.c
+++ b/drivers/isdn/mISDN/hwchannel.c
@@ -305,8 +305,8 @@ get_next_bframe(struct bchannel *bch)
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
@@ -395,6 +395,7 @@ bchannel_senddata(struct bchannel *ch, struct sk_buff *skb)
 		/* write to fifo */
 		ch->tx_skb = skb;
 		ch->tx_idx = 0;
+		confirm_Bsend(ch);
 		return 1;
 	}
 }
-- 
1.7.3.4
