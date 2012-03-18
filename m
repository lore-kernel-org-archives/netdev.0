From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 18/28] mISDN: Cleanup channel also if it already was deactivated
Date: Sun, 18 Mar 2012 14:50:02 +0100
Message-ID: <20120423170550.A30F39FB80@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:52902 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415Ab2DWRIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a channel was closed after it was deactivated it
could happen that something was not proper resetted.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c  |   12 ++++--------
 drivers/isdn/hardware/mISDN/hfcmulti.c  |    3 +--
 drivers/isdn/hardware/mISDN/hfcpci.c    |    3 +--
 drivers/isdn/hardware/mISDN/hfcsusb.c   |    3 +--
 drivers/isdn/hardware/mISDN/mISDNipac.c |   13 ++++---------
 drivers/isdn/hardware/mISDN/mISDNisar.c |   13 ++++---------
 drivers/isdn/hardware/mISDN/netjet.c    |   12 ++++--------
 drivers/isdn/hardware/mISDN/w6692.c     |   13 ++++---------
 8 files changed, 23 insertions(+), 49 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index c0b8c96..e76e1ba 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -839,14 +839,10 @@ avm_bctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	switch (cmd) {
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
-		if (test_bit(FLG_ACTIVE, &bch->Flags)) {
-			spin_lock_irqsave(&fc->lock, flags);
-			mISDN_freebchannel(bch);
-			test_and_clear_bit(FLG_TX_BUSY, &bch->Flags);
-			test_and_clear_bit(FLG_ACTIVE, &bch->Flags);
-			modehdlc(bch, ISDN_P_NONE);
-			spin_unlock_irqrestore(&fc->lock, flags);
-		}
+		spin_lock_irqsave(&fc->lock, flags);
+		mISDN_freebchannel(bch);
+		modehdlc(bch, ISDN_P_NONE);
+		spin_unlock_irqrestore(&fc->lock, flags);
 		ch->protocol = ISDN_P_NONE;
 		ch->peer = NULL;
 		module_put(THIS_MODULE);
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 4ae6f8e..e91f82a 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -3859,8 +3859,7 @@ hfcm_bctrl(struct mISDNchannel *ch, u_int cmd, void *arg)
 	switch (cmd) {
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
-		if (test_bit(FLG_ACTIVE, &bch->Flags))
-			deactivate_bchannel(bch); /* locked there */
+		deactivate_bchannel(bch); /* locked there */
 		ch->protocol = ISDN_P_NONE;
 		ch->peer = NULL;
 		module_put(THIS_MODULE);
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index e2c83a2..9262136 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -1581,8 +1581,7 @@ hfc_bctrl(struct mISDNchannel *ch, u_int cmd, void *arg)
 		break;
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
-		if (test_bit(FLG_ACTIVE, &bch->Flags))
-			deactivate_bchannel(bch);
+		deactivate_bchannel(bch);
 		ch->protocol = ISDN_P_NONE;
 		ch->peer = NULL;
 		module_put(THIS_MODULE);
diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 8cde2a0..add28ac 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -1836,8 +1836,7 @@ hfc_bctrl(struct mISDNchannel *ch, u_int cmd, void *arg)
 
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
-		if (test_bit(FLG_ACTIVE, &bch->Flags))
-			deactivate_bchannel(bch);
+		deactivate_bchannel(bch);
 		ch->protocol = ISDN_P_NONE;
 		ch->peer = NULL;
 		module_put(THIS_MODULE);
diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index 884369f..4c1937b 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -1416,15 +1416,10 @@ hscx_bctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	switch (cmd) {
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
-		if (test_bit(FLG_ACTIVE, &bch->Flags)) {
-			spin_lock_irqsave(hx->ip->hwlock, flags);
-			mISDN_freebchannel(bch);
-			hscx_mode(hx, ISDN_P_NONE);
-			spin_unlock_irqrestore(hx->ip->hwlock, flags);
-		} else {
-			skb_queue_purge(&bch->rqueue);
-			bch->rcount = 0;
-		}
+		spin_lock_irqsave(hx->ip->hwlock, flags);
+		mISDN_freebchannel(bch);
+		hscx_mode(hx, ISDN_P_NONE);
+		spin_unlock_irqrestore(hx->ip->hwlock, flags);
 		ch->protocol = ISDN_P_NONE;
 		ch->peer = NULL;
 		module_put(hx->ip->owner);
diff --git a/drivers/isdn/hardware/mISDN/mISDNisar.c b/drivers/isdn/hardware/mISDN/mISDNisar.c
index 9a6da6e..af9a966 100644
--- a/drivers/isdn/hardware/mISDN/mISDNisar.c
+++ b/drivers/isdn/hardware/mISDN/mISDNisar.c
@@ -1603,15 +1603,10 @@ isar_bctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	switch (cmd) {
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
-		if (test_bit(FLG_ACTIVE, &bch->Flags)) {
-			spin_lock_irqsave(ich->is->hwlock, flags);
-			mISDN_freebchannel(bch);
-			modeisar(ich, ISDN_P_NONE);
-			spin_unlock_irqrestore(ich->is->hwlock, flags);
-		} else {
-			skb_queue_purge(&bch->rqueue);
-			bch->rcount = 0;
-		}
+		spin_lock_irqsave(ich->is->hwlock, flags);
+		mISDN_freebchannel(bch);
+		modeisar(ich, ISDN_P_NONE);
+		spin_unlock_irqrestore(ich->is->hwlock, flags);
 		ch->protocol = ISDN_P_NONE;
 		ch->peer = NULL;
 		module_put(ich->is->owner);
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index c726e09..0dccda8 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -808,14 +808,10 @@ nj_bctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	switch (cmd) {
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
-		if (test_bit(FLG_ACTIVE, &bch->Flags)) {
-			spin_lock_irqsave(&card->lock, flags);
-			mISDN_freebchannel(bch);
-			test_and_clear_bit(FLG_TX_BUSY, &bch->Flags);
-			test_and_clear_bit(FLG_ACTIVE, &bch->Flags);
-			mode_tiger(bc, ISDN_P_NONE);
-			spin_unlock_irqrestore(&card->lock, flags);
-		}
+		spin_lock_irqsave(&card->lock, flags);
+		mISDN_freebchannel(bch);
+		mode_tiger(bc, ISDN_P_NONE);
+		spin_unlock_irqrestore(&card->lock, flags);
 		ch->protocol = ISDN_P_NONE;
 		ch->peer = NULL;
 		module_put(THIS_MODULE);
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 2183357..dec013e1 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -1058,15 +1058,10 @@ w6692_bctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	switch (cmd) {
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
-		if (test_bit(FLG_ACTIVE, &bch->Flags)) {
-			spin_lock_irqsave(&card->lock, flags);
-			mISDN_freebchannel(bch);
-			w6692_mode(bc, ISDN_P_NONE);
-			spin_unlock_irqrestore(&card->lock, flags);
-		} else {
-			skb_queue_purge(&bch->rqueue);
-			bch->rcount = 0;
-		}
+		spin_lock_irqsave(&card->lock, flags);
+		mISDN_freebchannel(bch);
+		w6692_mode(bc, ISDN_P_NONE);
+		spin_unlock_irqrestore(&card->lock, flags);
 		ch->protocol = ISDN_P_NONE;
 		ch->peer = NULL;
 		module_put(THIS_MODULE);
-- 
1.7.3.4
