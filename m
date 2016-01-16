From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH v2 resend] b43: Fix memory leaks in b43_bus_dev_ssb_init and b43_bus_dev_bcma_init
Date: Sat, 16 Jan 2016 21:08:10 +0800
Message-ID: <1452949690-16387-1-git-send-email-baijiaju1990@163.com>
Cc: linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, Jia-Ju Bai <baijiaju1990@163.com>
To: kvalo@codeaurora.org, zajec5@gmail.com, joe@perches.com,
	davem@davemloft.net, m@bues.ch, johannes.berg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:60709 "EHLO m12-12.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbcAPNIs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jan 2016 08:08:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory allocated by kzalloc in b43_bus_dev_ssb_init and
b43_bus_dev_bcma_init is not freed.
This patch fixes the bug by adding kfree in b43_ssb_remove,
b43_bcma_remove and error handling code of b43_bcma_probe.

Thanks Michael for his suggestion.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/wireless/b43/main.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index ec013fb..bbea769 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -5682,11 +5682,12 @@ static int b43_bcma_probe(struct bcma_device *core)
 	INIT_WORK(&wl->firmware_load, b43_request_firmware);
 	schedule_work(&wl->firmware_load);
 
-bcma_out:
 	return err;
 
 bcma_err_wireless_exit:
 	ieee80211_free_hw(wl->hw);
+bcma_out:
+	kfree(dev);
 	return err;
 }
 
@@ -5714,8 +5715,8 @@ static void b43_bcma_remove(struct bcma_device *core)
 	b43_rng_exit(wl);
 
 	b43_leds_unregister(wl);
-
 	ieee80211_free_hw(wl->hw);
+	kfree(wldev->dev);
 }
 
 static struct bcma_driver b43_bcma_driver = {
@@ -5798,6 +5799,7 @@ static void b43_ssb_remove(struct ssb_device *sdev)
 
 	b43_leds_unregister(wl);
 	b43_wireless_exit(dev, wl);
+	kfree(dev);
 }
 
 static struct ssb_driver b43_ssb_driver = {
-- 
1.7.9.5
