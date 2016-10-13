From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] net: asix: Avoid looping when the device does not respond
Date: Thu, 13 Oct 2016 16:43:16 -0700
Message-ID: <1476402196-5920-1-git-send-email-linux@roeck-us.net>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        Guenter Roeck <linux@roeck-us.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:47326 "EHLO
        bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751050AbcJMXnY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 19:43:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check answers from USB stack and avoid re-sending the request
multiple times if the device does not respond.

This fixes the following problem, observed with a probably flaky adapter.

[62108.732707] usb 1-3: new high-speed USB device number 5 using xhci_hcd
[62108.914421] usb 1-3: New USB device found, idVendor=0b95, idProduct=7720
[62108.914463] usb 1-3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[62108.914476] usb 1-3: Product: AX88x72A
[62108.914486] usb 1-3: Manufacturer: ASIX Elec. Corp.
[62108.914495] usb 1-3: SerialNumber: 000001
[62114.109109] asix 1-3:1.0 (unnamed net_device) (uninitialized):
	Failed to write reg index 0x0000: -110
[62114.109139] asix 1-3:1.0 (unnamed net_device) (uninitialized):
	Failed to send software reset: ffffff92
[62119.109048] asix 1-3:1.0 (unnamed net_device) (uninitialized):
	Failed to write reg index 0x0000: -110
...

Since the USB timeout is 5 seconds, and the operation is retried 30 times,
this results in

[62278.180353] INFO: task mtpd:1725 blocked for more than 120 seconds.
[62278.180373]       Tainted: G        W      3.18.0-13298-g94ace9e #1
[62278.180383] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
...
[62278.180957] kworker/2:0     D 0000000000000000     0  5744      2 0x00000000
[62278.180978] Workqueue: usb_hub_wq hub_event
[62278.181029]  ffff880177f833b8 0000000000000046 ffff88017fd00000 ffff88017b126d80
[62278.181048]  ffff880177f83fd8 ffff880065a71b60 0000000000013340 ffff880065a71b60
[62278.181065]  0000000000000286 0000000103b1c199 0000000000001388 0000000000000002
[62278.181081] Call Trace:
[62278.181092]  [<ffffffff8e0971fd>] ? console_conditional_schedule+0x2c/0x2c
[62278.181105]  [<ffffffff8e094f7b>] schedule+0x69/0x6b
[62278.181117]  [<ffffffff8e0972e0>] schedule_timeout+0xe3/0x11d
[62278.181133]  [<ffffffff8daadb1b>] ? trace_timer_start+0x51/0x51
[62278.181146]  [<ffffffff8e095a05>] do_wait_for_common+0x12f/0x16c
[62278.181162]  [<ffffffff8da856a7>] ? wake_up_process+0x39/0x39
[62278.181174]  [<ffffffff8e095aee>] wait_for_common+0x52/0x6d
[62278.181187]  [<ffffffff8e095b3b>] wait_for_completion_timeout+0x13/0x15
[62278.181201]  [<ffffffff8de676ce>] usb_start_wait_urb+0x93/0xf1
[62278.181214]  [<ffffffff8de6780d>] usb_control_msg+0xe1/0x11d
[62278.181230]  [<ffffffffc037d629>] usbnet_write_cmd+0x9c/0xc6 [usbnet]
[62278.181286]  [<ffffffffc03af793>] asix_write_cmd+0x4e/0x7e [asix]
[62278.181300]  [<ffffffffc03afb41>] asix_set_sw_mii+0x25/0x4e [asix]
[62278.181314]  [<ffffffffc03b001d>] asix_mdio_read+0x51/0x109 [asix]
...

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/usb/asix_common.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index f79eb12c326a..125cff57c759 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -433,13 +433,13 @@ int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
 	mutex_lock(&dev->phy_mutex);
 	do {
 		ret = asix_set_sw_mii(dev, 0);
-		if (ret == -ENODEV)
+		if (ret == -ENODEV || ret == -ETIMEDOUT)
 			break;
 		usleep_range(1000, 1100);
 		ret = asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG,
 				    0, 0, 1, &smsr, 0);
 	} while (!(smsr & AX_HOST_EN) && (i++ < 30) && (ret != -ENODEV));
-	if (ret == -ENODEV) {
+	if (ret == -ENODEV || ret == -ETIMEDOUT) {
 		mutex_unlock(&dev->phy_mutex);
 		return ret;
 	}
@@ -497,13 +497,13 @@ int asix_mdio_read_nopm(struct net_device *netdev, int phy_id, int loc)
 	mutex_lock(&dev->phy_mutex);
 	do {
 		ret = asix_set_sw_mii(dev, 1);
-		if (ret == -ENODEV)
+		if (ret == -ENODEV || ret == -ETIMEDOUT)
 			break;
 		usleep_range(1000, 1100);
 		ret = asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG,
 				    0, 0, 1, &smsr, 1);
 	} while (!(smsr & AX_HOST_EN) && (i++ < 30) && (ret != -ENODEV));
-	if (ret == -ENODEV) {
+	if (ret == -ENODEV || ret == -ETIMEDOUT) {
 		mutex_unlock(&dev->phy_mutex);
 		return ret;
 	}
-- 
2.5.0
