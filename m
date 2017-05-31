From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] b43legacy: Fix a sleep-in-atomic bug in b43legacy_op_bss_info_changed
Date: Wed, 31 May 2017 18:09:13 +0800
Message-ID: <1496225353-5544-1-git-send-email-baijiaju1990@163.com>
Cc: linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@163.com>
To: Larry.Finger@lwfinger.net, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver may sleep under a spin lock, and the function call path is:
b43legacy_op_bss_info_changed (acquire the lock by spin_lock_irqsave)
  b43legacy_synchronize_irq
    synchronize_irq --> may sleep

To fix it, the lock is released before b43legacy_synchronize_irq, and the 
lock is acquired again after this function.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/wireless/broadcom/b43legacy/main.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/broadcom/b43legacy/main.c b/drivers/net/wireless/broadcom/b43legacy/main.c
index f1e3dad..31ead21 100644
--- a/drivers/net/wireless/broadcom/b43legacy/main.c
+++ b/drivers/net/wireless/broadcom/b43legacy/main.c
@@ -2859,7 +2859,9 @@ static void b43legacy_op_bss_info_changed(struct ieee80211_hw *hw,
 	b43legacy_write32(dev, B43legacy_MMIO_GEN_IRQ_MASK, 0);
 
 	if (changed & BSS_CHANGED_BSSID) {
+		spin_unlock_irqrestore(&wl->irq_lock, flags);
 		b43legacy_synchronize_irq(dev);
+		spin_lock_irqsave(&wl->irq_lock, flags);
 
 		if (conf->bssid)
 			memcpy(wl->bssid, conf->bssid, ETH_ALEN);
-- 
1.7.9.5
