From: Enric Balletbo i Serra <eballetbo@iseebcn.com>
Subject: [PATCH] smsc911x: fix mac_lock acquision before calling smsc911x_mac_read
Date: Tue,  5 Apr 2011 18:52:49 +0200
Message-ID: <1302022369-24285-1-git-send-email-eballetbo@iseebcn.com>
Cc: Enric Balletbo i Serra <eballetbo@iseebcn.com>
To: steve.glendinning@smsc.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58969 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940Ab1DEQxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 12:53:32 -0400
Received: by wya21 with SMTP id 21so509282wya.19
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2011 09:53:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When SMSC911X_SAVE_MAC_ADDRESS flag is enabled the driver calls
smsc911x_mac_read and smsc911x_mac_read function without acquiring mac_lock
spinlock

This patch fixes following warning

smsc911x: Driver version 2008-10-21.
------------[ cut here ]------------
WARNING: at drivers/net/smsc911x.c:261 smsc911x_mac_read+0x24/0x220()
Modules linked in:
[<c0060858>] (unwind_backtrace+0x0/0xe0) from [<c009322c>] (warn_slowpath_common+0x4c/0x64)
[<c009322c>] (warn_slowpath_common+0x4c/0x64) from [<c009325c>] (warn_slowpath_null+0x18/0x1c)
[<c009325c>] (warn_slowpath_null+0x18/0x1c) from [<c0324bec>] (smsc911x_mac_read+0x24/0x220)
[<c0324bec>] (smsc911x_mac_read+0x24/0x220) from [<c0434788>] (smsc911x_read_mac_address+0x18/0x6c)
[<c0434788>] (smsc911x_read_mac_address+0x18/0x6c) from [<c0434c74>] (smsc911x_drv_probe+0x498/0x1788)
[<c0434c74>] (smsc911x_drv_probe+0x498/0x1788) from [<c02d3e54>] (platform_drv_probe+0x14/0x18)
[<c02d3e54>] (platform_drv_probe+0x14/0x18) from [<c02d2d60>] (driver_probe_device+0xc8/0x184)
[<c02d2d60>] (driver_probe_device+0xc8/0x184) from [<c02d2e84>] (__driver_attach+0x68/0x8c)
[<c02d2e84>] (__driver_attach+0x68/0x8c) from [<c02d1fc8>] (bus_for_each_dev+0x48/0x74)
[<c02d1fc8>] (bus_for_each_dev+0x48/0x74) from [<c02d2660>] (bus_add_driver+0x9c/0x228)
[<c02d2660>] (bus_add_driver+0x9c/0x228) from [<c02d3598>] (driver_register+0xa0/0x124)
[<c02d3598>] (driver_register+0xa0/0x124) from [<c0050668>] (do_one_initcall+0x94/0x168)
[<c0050668>] (do_one_initcall+0x94/0x168) from [<c0008984>] (kernel_init+0xa0/0x154)
[<c0008984>] (kernel_init+0xa0/0x154) from [<c005afac>] (kernel_thread_exit+0x0/0x8)
---[ end trace 2c931a35b7885770 ]---

Signed-off-by: Enric Balletbo i Serra <eballetbo@iseebcn.com>
---
 drivers/net/smsc911x.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 1566259..4747846 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1818,6 +1818,7 @@ static int __devinit smsc911x_init(struct net_device *dev)
 	SMSC_TRACE(PROBE, "PHY will be autodetected.");
 
 	spin_lock_init(&pdata->dev_lock);
+	spin_lock_init(&pdata->mac_lock);
 
 	if (pdata->ioaddr == 0) {
 		SMSC_WARNING(PROBE, "pdata->ioaddr: 0x00000000");
@@ -1895,8 +1896,11 @@ static int __devinit smsc911x_init(struct net_device *dev)
 	/* workaround for platforms without an eeprom, where the mac address
 	 * is stored elsewhere and set by the bootloader.  This saves the
 	 * mac address before resetting the device */
-	if (pdata->config.flags & SMSC911X_SAVE_MAC_ADDRESS)
+	if (pdata->config.flags & SMSC911X_SAVE_MAC_ADDRESS) {
+		spin_lock_irq(&pdata->mac_lock);
 		smsc911x_read_mac_address(dev);
+		spin_unlock_irq(&pdata->mac_lock);
+	}
 
 	/* Reset the LAN911x */
 	if (smsc911x_soft_reset(pdata))
@@ -2059,8 +2063,6 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 		SMSC_TRACE(PROBE, "Network interface: \"%s\"", dev->name);
 	}
 
-	spin_lock_init(&pdata->mac_lock);
-
 	retval = smsc911x_mii_init(pdev, dev);
 	if (retval) {
 		SMSC_WARNING(PROBE,
-- 
1.7.0.4

