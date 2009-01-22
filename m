From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] phylib: Fix oops in suspend/resume paths
Date: Thu, 22 Jan 2009 21:09:30 +0300
Message-ID: <20090122180930.GA27624@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: David Miller <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:52140 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753389AbZAVSJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 13:09:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suspend/resume routines check for phydrv != NULL, but that is
wrong because "phydrv" comes from container_of(drv). If drv is NULL,
then container_of(drv) will return non-NULL result, and the checks
won't work.

The Freescale TBI PHYs are driver-less, so "drv" is NULL, and that
leads to the following oops:

Unable to handle kernel paging request for data at address 0xffffffe4
Faulting instruction address: 0xc0215554
Oops: Kernel access of bad area, sig: 11 [#1]
[...]
NIP [c0215554] mdio_bus_suspend+0x34/0x70
LR [c01cc508] suspend_device+0x258/0x2bc
Call Trace:
[cfad3da0] [cfad3db8] 0xcfad3db8 (unreliable)
[cfad3db0] [c01cc508] suspend_device+0x258/0x2bc
[cfad3dd0] [c01cc62c] dpm_suspend+0xc0/0x140
[cfad3e20] [c01cc6f4] device_suspend+0x48/0x5c
[cfad3e40] [c0068dd8] suspend_devices_and_enter+0x8c/0x148
[cfad3e60] [c00690f8] enter_state+0x100/0x118
[cfad3e80] [c00691c0] state_store+0xb0/0xe4
[cfad3ea0] [c018c938] kobj_attr_store+0x24/0x3c
[cfad3eb0] [c00ea9a8] flush_write_buffer+0x58/0x7c
[cfad3ed0] [c00eadf0] sysfs_write_file+0x58/0xa0
[cfad3ef0] [c009e810] vfs_write+0xb4/0x16c
[cfad3f10] [c009ed40] sys_write+0x4c/0x90
[cfad3f40] [c0014954] ret_from_syscall+0x0/0x38
[...]

This patch fixes the issue, plus removes unneeded parentheses
and fixes indentation level in mdio_bus_suspend().

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/phy/mdio_bus.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 11adf6e..811a637 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -296,9 +296,8 @@ static int mdio_bus_suspend(struct device * dev, pm_message_t state)
 	struct phy_driver *phydrv = to_phy_driver(drv);
 	struct phy_device *phydev = to_phy_device(dev);
 
-	if ((!device_may_wakeup(phydev->dev.parent)) &&
-		(phydrv && phydrv->suspend))
-			ret = phydrv->suspend(phydev);
+	if (drv && phydrv->suspend && !device_may_wakeup(phydev->dev.parent))
+		ret = phydrv->suspend(phydev);
 
 	return ret;
 }
@@ -310,8 +309,7 @@ static int mdio_bus_resume(struct device * dev)
 	struct phy_driver *phydrv = to_phy_driver(drv);
 	struct phy_device *phydev = to_phy_device(dev);
 
-	if ((!device_may_wakeup(phydev->dev.parent)) &&
-		(phydrv && phydrv->resume))
+	if (drv && phydrv->resume && !device_may_wakeup(phydev->dev.parent))
 		ret = phydrv->resume(phydev);
 
 	return ret;
-- 
1.5.6.5
