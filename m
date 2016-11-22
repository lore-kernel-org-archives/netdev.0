From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH/RFC -next] net: phy: Fix double free in phy_detach()
Date: Tue, 22 Nov 2016 19:07:30 +0100
Message-ID: <1479838050-28957-1-git-send-email-geert+renesas@glider.be>
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Josh Cartwright <josh.cartwright@ni.com>,
        Nathan Sullivan <nathan.sullivan@ni.com>,
        Zach Brown <zach.brown@ni.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During "poweroff" on sh73a0/kzm9g:

    WARNING: CPU: 0 PID: 1271 at drivers/base/devres.c:889 phy_detach+0x44/0x60
    Modules linked in:
    CPU: 0 PID: 1271 Comm: halt Not tainted 4.9.0-rc6-kzm9g-05637-gb090128865050239 #823
    Hardware name: Generic SH73A0 (Flattened Device Tree)
    [<c010e7e0>] (unwind_backtrace) from [<c010aeb8>] (show_stack+0x10/0x14)
    [<c010aeb8>] (show_stack) from [<c02f2b68>] (dump_stack+0xa4/0xdc)
    [<c02f2b68>] (dump_stack) from [<c0121204>] (__warn+0xcc/0xfc)
    [<c0121204>] (__warn) from [<c01212d8>] (warn_slowpath_null+0x1c/0x24)
    [<c01212d8>] (warn_slowpath_null) from [<c03aac40>] (phy_detach+0x44/0x60)
    [<c03aac40>] (phy_detach) from [<c03ae924>] (smsc911x_stop+0xf4/0x10c)
    [<c03ae924>] (smsc911x_stop) from [<c0464c4c>] (__dev_close_many+0x94/0xb8)
    [<c0464c4c>] (__dev_close_many) from [<c0464d64>] (__dev_close+0x20/0x34)
    [<c0464d64>] (__dev_close) from [<c046d8ac>] (__dev_change_flags+0x8c/0x130)
    [<c046d8ac>] (__dev_change_flags) from [<c046d968>] (dev_change_flags+0x18/0x48)
    [<c046d968>] (dev_change_flags) from [<c04d1aac>] (devinet_ioctl+0x33c/0x708)
    [<c04d1aac>] (devinet_ioctl) from [<c0450694>] (sock_ioctl+0x29c/0x2f8)
    [<c0450694>] (sock_ioctl) from [<c02079a0>] (vfs_ioctl+0x20/0x34)
    [<c02079a0>] (vfs_ioctl) from [<c0208398>] (do_vfs_ioctl+0x870/0x9c4)
    [<c0208398>] (do_vfs_ioctl) from [<c0208520>] (SyS_ioctl+0x34/0x5c)
    [<c0208520>] (SyS_ioctl) from [<c0106dc0>] (ret_fast_syscall+0x0/0x1c)
    ---[ end trace 4555b9be7369b463 ]---

If device_release_driver(&phydev->mdio.dev) was called, it has already
released all resources belonging to the PHY device. Hence the subsequent
call to phy_led_triggers_unregister() may cause a double free, leading
to the warning.

Move the call to phy_led_triggers_unregister() before the possible call
to device_release_driver() to fix this.

Fixes: 2e0bc452f4721520 ("net: phy: leds: add support for led triggers on phy link state change")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
Is this the right fix?
---
 drivers/net/phy/phy_device.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 9e8f048891bd192f..b32457660db66de4 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -981,6 +981,8 @@ void phy_detach(struct phy_device *phydev)
 	phydev->attached_dev = NULL;
 	phy_suspend(phydev);
 
+	phy_led_triggers_unregister(phydev);
+
 	/* If the device had no specific driver before (i.e. - it
 	 * was using the generic driver), we unbind the device
 	 * from the generic driver so that there's a chance a
@@ -994,8 +996,6 @@ void phy_detach(struct phy_device *phydev)
 		}
 	}
 
-	phy_led_triggers_unregister(phydev);
-
 	/*
 	 * The phydev might go away on the put_device() below, so avoid
 	 * a use-after-free bug by reading the underlying bus first.
-- 
1.9.1
