From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 1/8] mISDN: Cleanup channel also if it already was deactivated
Date: Wed, 16 May 2012 06:22:47 +0200
Message-ID: <1337142174-8304-2-git-send-email-kkeil@linux-pingi.de>
References: <1337142174-8304-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:64585 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638Ab2EPEcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 00:32:11 -0400
In-Reply-To: <1337142174-8304-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a channel was closed after it was deactivated it could happen that
something was not proper resetted. The test if a channel is still activ
was wrong, so remove it and always do the cleanup.

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
index 6bf2c58..2271f2b 100644
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
index 4c128e4..25fab85 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -3725,8 +3725,7 @@ hfcm_bctrl(struct mISDNchannel *ch, u_int cmd, void *arg)
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
index 5fe993e..f7a5ea7 100644
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
index 92d4a78..6c044d5 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -1420,15 +1420,10 @@ hscx_bctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
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
index 27998d7..55a77ed 100644
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
index 1d04467..0b5e929 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -1061,15 +1061,10 @@ w6692_bctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
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
