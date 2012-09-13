From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH] mISDN: Fix wrong usage of flush_work_sync while holding locks
Date: Thu, 13 Sep 2012 16:36:20 +0200
Message-ID: <1347546980-15923-1-git-send-email-keil@b1-systems.de>
Cc: netdev@vger.kernel.org, <stable@kernel.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.b1-systems.de ([217.11.58.35]:52860 "EHLO mx1.b1-systems.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754358Ab2IMOqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 10:46:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a bad idea to hold a spinlock and call flush_work_sync.
Move the workqueue cleanup outside the spinlock and use cancel_work_sync,
on closing the channel this seems to be the more correct function.
Remove the never used and constant return value of mISDN_freebchannel.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
Cc: <stable@kernel.org>
---
 drivers/isdn/hardware/mISDN/avmfritz.c  |    3 ++-
 drivers/isdn/hardware/mISDN/mISDNipac.c |    3 ++-
 drivers/isdn/hardware/mISDN/mISDNisar.c |    3 ++-
 drivers/isdn/hardware/mISDN/netjet.c    |    3 ++-
 drivers/isdn/hardware/mISDN/w6692.c     |    3 ++-
 drivers/isdn/mISDN/hwchannel.c          |    9 ++++-----
 include/linux/mISDNhw.h                 |    2 +-
 7 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index fa6ca47..dceaec8 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -857,8 +857,9 @@ avm_bctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	switch (cmd) {
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
+		cancel_work_sync(&bch->workq);
 		spin_lock_irqsave(&fc->lock, flags);
-		mISDN_freebchannel(bch);
+		mISDN_clear_bchannel(bch);
 		modehdlc(bch, ISDN_P_NONE);
 		spin_unlock_irqrestore(&fc->lock, flags);
 		ch->protocol = ISDN_P_NONE;
diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index 752e082..ccd7d85 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -1406,8 +1406,9 @@ hscx_bctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	switch (cmd) {
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
+		cancel_work_sync(&bch->workq);
 		spin_lock_irqsave(hx->ip->hwlock, flags);
-		mISDN_freebchannel(bch);
+		mISDN_clear_bchannel(bch);
 		hscx_mode(hx, ISDN_P_NONE);
 		spin_unlock_irqrestore(hx->ip->hwlock, flags);
 		ch->protocol = ISDN_P_NONE;
diff --git a/drivers/isdn/hardware/mISDN/mISDNisar.c b/drivers/isdn/hardware/mISDN/mISDNisar.c
index be5973d..182ecf0 100644
--- a/drivers/isdn/hardware/mISDN/mISDNisar.c
+++ b/drivers/isdn/hardware/mISDN/mISDNisar.c
@@ -1588,8 +1588,9 @@ isar_bctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	switch (cmd) {
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
+		cancel_work_sync(&bch->workq);
 		spin_lock_irqsave(ich->is->hwlock, flags);
-		mISDN_freebchannel(bch);
+		mISDN_clear_bchannel(bch);
 		modeisar(ich, ISDN_P_NONE);
 		spin_unlock_irqrestore(ich->is->hwlock, flags);
 		ch->protocol = ISDN_P_NONE;
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index c3e3e76..9bcade5 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -812,8 +812,9 @@ nj_bctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	switch (cmd) {
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
+		cancel_work_sync(&bch->workq);
 		spin_lock_irqsave(&card->lock, flags);
-		mISDN_freebchannel(bch);
+		mISDN_clear_bchannel(bch);
 		mode_tiger(bc, ISDN_P_NONE);
 		spin_unlock_irqrestore(&card->lock, flags);
 		ch->protocol = ISDN_P_NONE;
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 26a86b8..335fe64 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -1054,8 +1054,9 @@ w6692_bctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	switch (cmd) {
 	case CLOSE_CHANNEL:
 		test_and_clear_bit(FLG_OPEN, &bch->Flags);
+		cancel_work_sync(&bch->workq);
 		spin_lock_irqsave(&card->lock, flags);
-		mISDN_freebchannel(bch);
+		mISDN_clear_bchannel(bch);
 		w6692_mode(bc, ISDN_P_NONE);
 		spin_unlock_irqrestore(&card->lock, flags);
 		ch->protocol = ISDN_P_NONE;
diff --git a/drivers/isdn/mISDN/hwchannel.c b/drivers/isdn/mISDN/hwchannel.c
index ef34fd4..2602be2 100644
--- a/drivers/isdn/mISDN/hwchannel.c
+++ b/drivers/isdn/mISDN/hwchannel.c
@@ -148,17 +148,16 @@ mISDN_clear_bchannel(struct bchannel *ch)
 	ch->next_minlen = ch->init_minlen;
 	ch->maxlen = ch->init_maxlen;
 	ch->next_maxlen = ch->init_maxlen;
+	skb_queue_purge(&ch->rqueue);
+	ch->rcount = 0;
 }
 EXPORT_SYMBOL(mISDN_clear_bchannel);
 
-int
+void
 mISDN_freebchannel(struct bchannel *ch)
 {
+	cancel_work_sync(&ch->workq);
 	mISDN_clear_bchannel(ch);
-	skb_queue_purge(&ch->rqueue);
-	ch->rcount = 0;
-	flush_work_sync(&ch->workq);
-	return 0;
 }
 EXPORT_SYMBOL(mISDN_freebchannel);
 
diff --git a/include/linux/mISDNhw.h b/include/linux/mISDNhw.h
index d0752ec..9d96d5d 100644
--- a/include/linux/mISDNhw.h
+++ b/include/linux/mISDNhw.h
@@ -183,7 +183,7 @@ extern int	mISDN_initbchannel(struct bchannel *, unsigned short,
 				   unsigned short);
 extern int	mISDN_freedchannel(struct dchannel *);
 extern void	mISDN_clear_bchannel(struct bchannel *);
-extern int	mISDN_freebchannel(struct bchannel *);
+extern void	mISDN_freebchannel(struct bchannel *);
 extern int	mISDN_ctrl_bchannel(struct bchannel *, struct mISDN_ctrl_req *);
 extern void	queue_ch_frame(struct mISDNchannel *, u_int,
 			int, struct sk_buff *);
-- 
1.7.7
