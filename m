From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH v2 4/8] mISDN: Bugfix hfcsusb: usb endpoint activation/deactivation
Date: Wed, 16 May 2012 11:51:04 +0200
Message-ID: <1337161868-19399-5-git-send-email-kkeil@linux-pingi.de>
References: <1337161868-19399-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org, Martin Bachem <info@colognechip.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:60333 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966703Ab2EPKA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 06:00:27 -0400
In-Reply-To: <1337161868-19399-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Bachem <info@colognechip.com>

Here was a off by one in the activation/deactivation.
The additional activation in open_bchannel() did hide
it, but only if you do not try to use B2.

Signed-off-by: Martin Bachem <info@colognechip.com>
Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/hfcsusb.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index a4c5b24..919eccc 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -231,7 +231,7 @@ hfcusb_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 		return ret;
 	case PH_ACTIVATE_REQ:
 		if (!test_and_set_bit(FLG_ACTIVE, &bch->Flags)) {
-			hfcsusb_start_endpoint(hw, bch->nr);
+			hfcsusb_start_endpoint(hw, bch->nr - 1);
 			ret = hfcsusb_setup_bch(bch, ch->protocol);
 		} else
 			ret = 0;
@@ -495,12 +495,6 @@ open_bchannel(struct hfcsusb *hw, struct channel_req *rq)
 	bch->ch.protocol = rq->protocol;
 	rq->ch = &bch->ch;
 
-	/* start USB endpoint for bchannel */
-	if (rq->adr.channel  == 1)
-		hfcsusb_start_endpoint(hw, HFC_CHAN_B1);
-	else
-		hfcsusb_start_endpoint(hw, HFC_CHAN_B2);
-
 	if (!try_module_get(THIS_MODULE))
 		printk(KERN_WARNING "%s: %s:cannot get module\n",
 		       hw->name, __func__);
@@ -1801,7 +1795,7 @@ deactivate_bchannel(struct bchannel *bch)
 	mISDN_clear_bchannel(bch);
 	spin_unlock_irqrestore(&hw->lock, flags);
 	hfcsusb_setup_bch(bch, ISDN_P_NONE);
-	hfcsusb_stop_endpoint(hw, bch->nr);
+	hfcsusb_stop_endpoint(hw, bch->nr - 1);
 }
 
 /*
-- 
1.7.3.4
