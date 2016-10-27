From: Ulf Hansson <ulf.hansson@linaro.org>
Subject: [PATCH] net: smsc911x: Synchronize the runtime PM status during system suspend
Date: Thu, 27 Oct 2016 13:23:54 +0200
Message-ID: <1477567434-5128-1-git-send-email-ulf.hansson@linaro.org>
Cc: Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
        Kevin Hilman <khilman@kernel.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Lina Iyer <lina.iyer@linaro.org>,
        Jon Hunter <jonathanh@nvidia.com>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Linus Walleij <linus.walleij@linaro.org>,
        Steve Glendinning <steve.glendinning@shawell.net>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Alan Stern <stern@rowland.harvard.edu>,
        Ulf Hansson <ulf.hansson@linaro.org>, linux-pm@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-pm-owner@vger.kernel.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The smsc911c driver puts its device into low power state when entering
system suspend. Although it doesn't update the device's runtime PM status
to RPM_SUSPENDED, which causes problems for a parent device.

In particular, when the runtime PM status of the parent is requested to be
updated to RPM_SUSPENDED, the runtime PM core prevent this, because it's
forbidden to runtime suspend a device, which has an active child.

Fix this by updating the runtime PM status of the smsc911x device to
RPM_SUSPENDED during system suspend. In system resume, let's reverse that
action by runtime resuming the device and thus also the parent.

Signed-off-by: Ulf Hansson <ulf.hansson@linaro.org>
Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
Fixes: 8b1107b85efd ("PM / Runtime: Don't allow to suspend a device with an active child")
---

Note that the commit this change fixes is currently queued for 4.10 via
Rafael's linux-pm tree. So this fix should go via that tree as well.

---
 drivers/net/ethernet/smsc/smsc911x.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index e9b8579..65fca9c 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2584,6 +2584,9 @@ static int smsc911x_suspend(struct device *dev)
 		PMT_CTRL_PM_MODE_D1_ | PMT_CTRL_WOL_EN_ |
 		PMT_CTRL_ED_EN_ | PMT_CTRL_PME_EN_);
 
+	pm_runtime_disable(dev);
+	pm_runtime_set_suspended(dev);
+
 	return 0;
 }
 
@@ -2593,6 +2596,9 @@ static int smsc911x_resume(struct device *dev)
 	struct smsc911x_data *pdata = netdev_priv(ndev);
 	unsigned int to = 100;
 
+	pm_runtime_enable(dev);
+	pm_runtime_resume(dev);
+
 	/* Note 3.11 from the datasheet:
 	 * 	"When the LAN9220 is in a power saving state, a write of any
 	 * 	 data to the BYTE_TEST register will wake-up the device."
-- 
1.9.1

