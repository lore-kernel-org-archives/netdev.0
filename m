From: Zoran Markovic <zoran.markovic@linaro.org>
Subject: [RFC PATCH] net: rfkill: move poll work to power efficient workqueue
Date: Thu, 30 Jan 2014 14:43:34 -0800
Message-ID: <1391121814-6026-1-git-send-email-zoran.markovic@linaro.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Shaibal Dutta <shaibal.dutta@broadcom.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zoran Markovic <zoran.markovic@linaro.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shaibal Dutta <shaibal.dutta@broadcom.com>

This patch moves the rfkill poll_work to the power efficient workqueue.
This work does not have to be bound to the CPU that scheduled it, hence
the selection of CPU that executes it would be left to the scheduler.
Net result is that CPU idle times would be extended, resulting in power
savings.

This behaviour is enabled when CONFIG_WQ_POWER_EFFICIENT is selected.

Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Shaibal Dutta <shaibal.dutta@broadcom.com>
[zoran.markovic@linaro.org: Rebased to latest kernel, added commit message.
Fixed workqueue selection after suspend/resume cycle.]
Signed-off-by: Zoran Markovic <zoran.markovic@linaro.org>
---
 net/rfkill/core.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index ed7e0b4..b3b16c0 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -789,7 +789,8 @@ void rfkill_resume_polling(struct rfkill *rfkill)
 	if (!rfkill->ops->poll)
 		return;
 
-	schedule_work(&rfkill->poll_work.work);
+	queue_delayed_work(system_power_efficient_wq,
+			   &rfkill->poll_work, 0);
 }
 EXPORT_SYMBOL(rfkill_resume_polling);
 
@@ -894,7 +895,8 @@ static void rfkill_poll(struct work_struct *work)
 	 */
 	rfkill->ops->poll(rfkill, rfkill->data);
 
-	schedule_delayed_work(&rfkill->poll_work,
+	queue_delayed_work(system_power_efficient_wq,
+		&rfkill->poll_work,
 		round_jiffies_relative(POLL_INTERVAL));
 }
 
@@ -958,7 +960,8 @@ int __must_check rfkill_register(struct rfkill *rfkill)
 	INIT_WORK(&rfkill->sync_work, rfkill_sync_work);
 
 	if (rfkill->ops->poll)
-		schedule_delayed_work(&rfkill->poll_work,
+		queue_delayed_work(system_power_efficient_wq,
+			&rfkill->poll_work,
 			round_jiffies_relative(POLL_INTERVAL));
 
 	if (!rfkill->persistent || rfkill_epo_lock_active) {
-- 
1.7.9.5
