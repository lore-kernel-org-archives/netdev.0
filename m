From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 23/28] mISDN: Fix compiler warnings
Date: Sat, 21 Apr 2012 17:49:11 +0200
Message-ID: <20120423170551.B37049FB98@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:49402 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754391Ab2DWRIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Newer gcc found some possible uninitialized pointer access.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c |   11 +++++------
 drivers/isdn/hardware/mISDN/hfcmulti.c |    8 ++++----
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index 3781446..d0bdde3 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -404,7 +404,7 @@ static void
 hdlc_empty_fifo(struct bchannel *bch, int count)
 {
 	u32 *ptr;
-	u8 *p, copy;
+	u8 *p;
 	u32  val, addr;
 	int cnt;
 	struct fritzcard *fc = bch->hw;
@@ -412,13 +412,12 @@ hdlc_empty_fifo(struct bchannel *bch, int count)
 	pr_debug("%s: %s %d\n", fc->name, __func__, count);
 	if (test_bit(FLG_RX_OFF, &bch->Flags)) {
 		/* We drop the content, but need to read all bytes from FIFO */
-		copy = 0;
+		p = NULL;
 		if (debug & DEBUG_HW_BFIFO)
 			printk(KERN_DEBUG "Dropped %d bytes - RX off\n", count);
 		val = (bch->nr - 1) & 1;
 		fc->dropcnt[val] += count;
 	} else {
-		copy = 1;
 		if (!bch->rx_skb) {
 			if (test_bit(FLG_TRANSPARENT, &bch->Flags)) {
 				if (count >= bch->minlen)
@@ -441,8 +440,8 @@ hdlc_empty_fifo(struct bchannel *bch, int count)
 			return;
 		}
 		p = skb_put(bch->rx_skb, count);
-		ptr = (u32 *)p;
 	}
+	ptr = (u32 *)p;
 	if (AVM_FRITZ_PCIV2 == fc->type)
 		addr = fc->addr + (bch->nr == 2 ?
 				   AVM_HDLC_FIFO_2 : AVM_HDLC_FIFO_1);
@@ -453,13 +452,13 @@ hdlc_empty_fifo(struct bchannel *bch, int count)
 	cnt = 0;
 	while (cnt < count) {
 		val = le32_to_cpu(inl(addr));
-		if (copy) {
+		if (ptr) {
 			put_unaligned(val, ptr);
 			ptr++;
 		}
 		cnt += 4;
 	}
-	if (copy && (debug & DEBUG_HW_BFIFO)) {
+	if (ptr && (debug & DEBUG_HW_BFIFO)) {
 		snprintf(fc->log, LOG_SIZE, "B%1d-recv %s %d ",
 			 bch->nr, fc->name, count);
 		print_hex_dump_bytes(fc->log, DUMP_PREFIX_OFFSET, p, count);
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 884c090..144c35a 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -2456,12 +2456,12 @@ handle_timer_irq(struct hfc_multi *hc)
 		spin_unlock_irqrestore(&HFClock, flags);
 	}
 	if (test_bit(HFC_CHIP_2MBITRAW, &hc->chip)) {
-		if (hc->created[hc->chan[0].port] && hc->chan[ch].bch &&
+		ch = 0;
+		if (hc->created[hc->chan[ch].port] && hc->chan[ch].bch &&
 		    test_bit(FLG_ACTIVE, &hc->chan[ch].bch->Flags)) {
 			ch_activ++;
-			hfcmulti_tx(hc, 0);
-			hfcmulti_rx(hc, 0);
-			ch = 1;
+			hfcmulti_tx(hc, ch);
+			hfcmulti_rx(hc, ch);
 			if (hc->chan[ch].dch &&
 			    hc->chan[ch].nt_timer > -1) {
 				dch = hc->chan[ch].dch;
-- 
1.7.3.4
