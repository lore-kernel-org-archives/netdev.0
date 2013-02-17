From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH v2 1/2] net: fec: Do a sanity check on the gpio number
Date: Sun, 17 Feb 2013 10:36:43 -0300
Message-ID: <1361108204-9498-1-git-send-email-festevam@gmail.com>
Cc: s.hauer@pengutronix.de, shawn.guo@linaro.org, marex@denx.de,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f180.google.com ([209.85.213.180]:62608 "EHLO
	mail-ye0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756123Ab3BQNpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 08:45:11 -0500
Received: by mail-ye0-f180.google.com with SMTP id r14so836788yen.25
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2013 05:45:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Since commit 372e722ea4d (gpiolib: use descriptors internally) the following 
warning is seen on a mx28evk board:

[    5.116291] ------------[ cut here ]------------
[    5.121306] WARNING: at drivers/gpio/gpiolib.c:125 gpio_to_desc+0x30/0x44()
[    5.128491] invalid GPIO -2
[    5.131563] Modules linked in:
[    5.134846] [<c0014e20>] (unwind_backtrace+0x0/0xf4) from [<c001d428>] (warn_slowpath_common+0x4c/0x68)
[    5.144682] [<c001d428>] (warn_slowpath_common+0x4c/0x68) from [<c001d4d8>] (warn_slowpath_fmt+0x30/0x40)
[    5.154693] [<c001d4d8>] (warn_slowpath_fmt+0x30/0x40) from [<c0283434>] (gpio_to_desc+0x30/0x44)
[    5.164002] [<c0283434>] (gpio_to_desc+0x30/0x44) from [<c0285470>] (gpio_request_one+0x10/0xe8)
[    5.173294] [<c0285470>] (gpio_request_one+0x10/0xe8) from [<c0282f50>] (devm_gpio_request_one+0x40/0x74)
[    5.183332] [<c0282f50>] (devm_gpio_request_one+0x40/0x74) from [<c0319be0>] (fec_probe+0x2d0/0x99c)
[    5.192923] [<c0319be0>] (fec_probe+0x2d0/0x99c) from [<c02c8114>] (platform_drv_probe+0x14/0x18)
[    5.202228] [<c02c8114>] (platform_drv_probe+0x14/0x18) from [<c02c6e00>] (driver_probe_device+0x90/0x224)
[    5.212332] [<c02c6e00>] (driver_probe_device+0x90/0x224) from [<c02c7028>] (__driver_attach+0x94/0x98)
[    5.222162] [<c02c7028>] (__driver_attach+0x94/0x98) from [<c02c5750>] (bus_for_each_dev+0x78/0x98)
[    5.231642] [<c02c5750>] (bus_for_each_dev+0x78/0x98) from [<c02c5fd0>] (bus_add_driver+0x1a4/0x240)
[    5.241207] [<c02c5fd0>] (bus_add_driver+0x1a4/0x240) from [<c02c7608>] (driver_register+0x78/0x140)
[    5.250768] [<c02c7608>] (driver_register+0x78/0x140) from [<c00087a4>] (do_one_initcall+0x30/0x17c)
[    5.260347] [<c00087a4>] (do_one_initcall+0x30/0x17c) from [<c05fa29c>] (kernel_init_freeable+0xe8/0x1b0)
[    5.270381] [<c05fa29c>] (kernel_init_freeable+0xe8/0x1b0) from [<c044dfd4>] (kernel_init+0x8/0xe4)
[    5.279886] [<c044dfd4>] (kernel_init+0x8/0xe4) from [<c000f248>] (ret_from_fork+0x14/0x2c)
[    5.288740] ---[ end trace c15c72a22979d58d ]--- 

mx28evk has two ethernet controllers. The GPIO that performs the 
ethernet reset on both ports is the same GPIO, so on the board dts file, only in
one ethernet instance is passed the GPIO reset property.

Validate the gpio number prior to requesting it in order to avoid such warning.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
Acked-by: Shawn Guo <shawn.guo@linaro.org>
---
Changes since v1:
- Added Shawn's ack
 drivers/net/ethernet/freescale/fec.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 0fe68c4..5864a67 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1689,6 +1689,9 @@ static void fec_reset_phy(struct platform_device *pdev)
 		msec = 1;
 
 	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
+	if (!gpio_is_valid(phy_reset))
+		return;
+
 	err = devm_gpio_request_one(&pdev->dev, phy_reset,
 				    GPIOF_OUT_INIT_LOW, "phy-reset");
 	if (err) {
-- 
1.7.9.5
