From: Uri Mashiach <uri.mashiach@compulab.co.il>
Subject: [PATCH] wlcore/wl12xx: spi: fix NULL pointer dereference (Oops)
Date: Thu, 24 Dec 2015 16:05:00 +0200
Message-ID: <1450965900-23222-1-git-send-email-uri.mashiach@compulab.co.il>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	igor.grinberg@compulab.co.il,
	Uri Mashiach <uri.mashiach@compulab.co.il>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from softlayer.compulab.co.il ([50.23.254.55]:39716 "EHLO
	compulab.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751676AbbLXOF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Dec 2015 09:05:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the below Oops when trying to modprobe wlcore_spi.
The oops occurs because the wl1271_power_{off,on}()
function doesn't check the power() function pointer.

[   23.401447] Unable to handle kernel NULL pointer dereference at
virtual address 00000000
[   23.409954] pgd = c0004000
[   23.412922] [00000000] *pgd=00000000
[   23.416693] Internal error: Oops: 80000007 [#1] SMP ARM
[   23.422168] Modules linked in: wl12xx wlcore mac80211 cfg80211
musb_dsps musb_hdrc usbcore usb_common snd_soc_simple_card evdev joydev
omap_rng wlcore_spi snd_soc_tlv320aic23_i2c rng_core snd_soc_tlv320aic23
c_can_platform c_can can_dev snd_soc_davinci_mcasp snd_soc_edma
snd_soc_omap omap_wdt musb_am335x cpufreq_dt thermal_sys hwmon
[   23.453253] CPU: 0 PID: 36 Comm: kworker/0:2 Not tainted
4.2.0-00002-g951efee-dirty #233
[   23.461720] Hardware name: Generic AM33XX (Flattened Device Tree)
[   23.468123] Workqueue: events request_firmware_work_func
[   23.473690] task: de32efc0 ti: de4ee000 task.ti: de4ee000
[   23.479341] PC is at 0x0
[   23.482112] LR is at wl12xx_set_power_on+0x28/0x124 [wlcore]
[   23.488074] pc : [<00000000>]    lr : [<bf2581f0>]    psr: 60000013
[   23.488074] sp : de4efe50  ip : 00000002  fp : 00000000
[   23.500162] r10: de7cdd00  r9 : dc848800  r8 : bf27af00
[   23.505663] r7 : bf27a1a8  r6 : dcbd8a80  r5 : dce0e2e0  r4 :
dce0d2e0
[   23.512536] r3 : 00000000  r2 : 00000000  r1 : 00000001  r0 :
dc848810
[   23.519412] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM
Segment kernel
[   23.527109] Control: 10c5387d  Table: 9cb78019  DAC: 00000015
[   23.533160] Process kworker/0:2 (pid: 36, stack limit = 0xde4ee218)
[   23.539760] Stack: (0xde4efe50 to 0xde4f0000)

[...]

[   23.665030] [<bf2581f0>] (wl12xx_set_power_on [wlcore]) from
[<bf25f7ac>] (wlcore_nvs_cb+0x118/0xa4c [wlcore])
[   23.675604] [<bf25f7ac>] (wlcore_nvs_cb [wlcore]) from [<c04387ec>]
(request_firmware_work_func+0x30/0x58)
[   23.685784] [<c04387ec>] (request_firmware_work_func) from
[<c0058e2c>] (process_one_work+0x1b4/0x4b4)
[   23.695591] [<c0058e2c>] (process_one_work) from [<c0059168>]
(worker_thread+0x3c/0x4a4)
[   23.704124] [<c0059168>] (worker_thread) from [<c005ee68>]
(kthread+0xd4/0xf0)
[   23.711747] [<c005ee68>] (kthread) from [<c000f598>]
(ret_from_fork+0x14/0x3c)
[   23.719357] Code: bad PC value
[   23.722760] ---[ end trace 981be8510db9b3a9 ]---

Prevent oops by validationg power() pointer value before
calling the function.

Signed-off-by: Uri Mashiach <uri.mashiach@compulab.co.il>
Cc: stable@vger.kernel.org
Acked-by: Igor Grinberg <grinberg@compulab.co.il>
---
 drivers/net/wireless/ti/wlcore/io.h | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/io.h b/drivers/net/wireless/ti/wlcore/io.h
index 0305729..10cf374 100644
--- a/drivers/net/wireless/ti/wlcore/io.h
+++ b/drivers/net/wireless/ti/wlcore/io.h
@@ -207,19 +207,23 @@ static inline int __must_check wlcore_write_reg(struct wl1271 *wl, int reg,
 
 static inline void wl1271_power_off(struct wl1271 *wl)
 {
-	int ret;
+	int ret = 0;
 
 	if (!test_bit(WL1271_FLAG_GPIO_POWER, &wl->flags))
 		return;
 
-	ret = wl->if_ops->power(wl->dev, false);
+	if (wl->if_ops->power)
+		ret = wl->if_ops->power(wl->dev, false);
 	if (!ret)
 		clear_bit(WL1271_FLAG_GPIO_POWER, &wl->flags);
 }
 
 static inline int wl1271_power_on(struct wl1271 *wl)
 {
-	int ret = wl->if_ops->power(wl->dev, true);
+	int ret = 0;
+
+	if (wl->if_ops->power)
+		ret = wl->if_ops->power(wl->dev, true);
 	if (ret == 0)
 		set_bit(WL1271_FLAG_GPIO_POWER, &wl->flags);
 
-- 
2.5.0
