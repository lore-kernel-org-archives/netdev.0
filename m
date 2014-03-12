From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net] at86rf230: fix lockdep splats
Date: Wed, 12 Mar 2014 08:21:24 +0100
Message-ID: <1394608884-3644-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:53135 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756211AbaCLHVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 03:21:34 -0400
Received: by mail-ea0-f179.google.com with SMTP id q10so4737053ead.24
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 00:21:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix a lockdep in the at86rf230 driver, otherwise we get:

[   30.206517] =================================
[   30.211078] [ INFO: inconsistent lock state ]
[   30.215647] 3.14.0-20140108-1-00994-g32e9426 #163 Not tainted
[   30.221660] ---------------------------------
[   30.226222] inconsistent {HARDIRQ-ON-W} -> {IN-HARDIRQ-W} usage.
[   30.232514] systemd-udevd/157 [HC1[1]:SC0[0]:HE0:SE1] takes:
[   30.238439]  (&(&lp->lock)->rlock){?.+...}, at: [<c03600f8>] at86rf230_isr+0x18/0x44
[   30.246621] {HARDIRQ-ON-W} state was registered at:
[   30.251728]   [<c0061ce4>] __lock_acquire+0x7a4/0x18d8
[   30.257135]   [<c0063500>] lock_acquire+0x68/0x7c
[   30.262071]   [<c0588820>] _raw_spin_lock+0x28/0x38
[   30.267203]   [<c0361240>] at86rf230_xmit+0x1c/0x144
[   30.272412]   [<c057ba6c>] mac802154_xmit_worker+0x88/0x148
[   30.278271]   [<c0047844>] process_one_work+0x274/0x404
[   30.283761]   [<c00484c0>] worker_thread+0x228/0x374
[   30.288971]   [<c004cfb8>] kthread+0xd0/0xe4
[   30.293455]   [<c000dac8>] ret_from_fork+0x14/0x2c
[   30.298493] irq event stamp: 8948
[   30.301963] hardirqs last  enabled at (8947): [<c00cb290>] __kmalloc+0xb4/0x110
[   30.309636] hardirqs last disabled at (8948): [<c00115d4>] __irq_svc+0x34/0x5c
[   30.317215] softirqs last  enabled at (8452): [<c0037324>] __do_softirq+0x1dc/0x264
[   30.325243] softirqs last disabled at (8439): [<c0037638>] irq_exit+0x80/0xf4

We use the lp->lock inside the isr of at86rf230, that's why we need the
irqsave spinlock calls.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index ab31544..a30258a 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -546,12 +546,12 @@ at86rf230_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
 	int rc;
 	unsigned long flags;
 
-	spin_lock(&lp->lock);
+	spin_lock_irqsave(&lp->lock, flags);
 	if  (lp->irq_busy) {
-		spin_unlock(&lp->lock);
+		spin_unlock_irqrestore(&lp->lock, flags);
 		return -EBUSY;
 	}
-	spin_unlock(&lp->lock);
+	spin_unlock_irqrestore(&lp->lock, flags);
 
 	might_sleep();
 
@@ -725,10 +725,11 @@ static void at86rf230_irqwork_level(struct work_struct *work)
 static irqreturn_t at86rf230_isr(int irq, void *data)
 {
 	struct at86rf230_local *lp = data;
+	unsigned long flags;
 
-	spin_lock(&lp->lock);
+	spin_lock_irqsave(&lp->lock, flags);
 	lp->irq_busy = 1;
-	spin_unlock(&lp->lock);
+	spin_unlock_irqrestore(&lp->lock, flags);
 
 	schedule_work(&lp->irqwork);
 
-- 
1.9.0
