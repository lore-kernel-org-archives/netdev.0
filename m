From: Mao Wenan <maowenan@huawei.com>
Subject: [PATCH] net:phy fix driver reference count error when attach and detach phy device
Date: Wed, 30 Nov 2016 18:22:58 +0800
Message-ID: <1480501378-10172-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:49785 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754243AbcK3K0G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 05:26:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The nic in my board use the phy dev from marvell, and the system will
load the marvell phy driver automatically, but when I remove the phy
drivers, the system immediately panic:
Call trace:
[ 2582.834493] [<ffff800000715384>] phy_state_machine+0x3c/0x438 [
2582.851754] [<ffff8000000db3b8>] process_one_work+0x150/0x428 [
2582.868188] [<ffff8000000db7d4>] worker_thread+0x144/0x4b0 [
2582.883882] [<ffff8000000e1d0c>] kthread+0xfc/0x110

there should be proper reference counting in place to avoid that.
I found that phy_attach_direct() forgets to add phy device driver
reference count, and phy_detach() forgets to subtract reference count.
This patch is to fix this bug, after that panic is disappeared when remove
marvell.ko

Signed-off-by: Mao Wenan <maowenan@huawei.com>
---
 drivers/net/phy/phy_device.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 1a4bf8a..a7ec7c2 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -866,6 +866,11 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		return -EIO;
 	}
 
+	if (!try_module_get(d->driver->owner)) {
+		dev_err(&dev->dev, "failed to get the device driver module\n");
+		return -EIO;
+	}
+
 	get_device(d);
 
 	/* Assume that if there is no driver, that it doesn't
@@ -921,6 +926,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 
 error:
 	put_device(d);
+	module_put(d->driver->owner);
 	module_put(bus->owner);
 	return err;
 }
@@ -998,6 +1004,7 @@ void phy_detach(struct phy_device *phydev)
 	bus = phydev->mdio.bus;
 
 	put_device(&phydev->mdio.dev);
+	module_put(phydev->mdio.dev.driver->owner);
 	module_put(bus->owner);
 }
 EXPORT_SYMBOL(phy_detach);
-- 
2.7.0
