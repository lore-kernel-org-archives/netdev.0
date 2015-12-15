From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH 3/4] ser_gigaset: fix deallocation of platform device structure
Date: Tue, 15 Dec 2015 18:11:30 +0100
Message-ID: <1450199491-30471-4-git-send-email-pebolle@tiscali.nl>
References: <1450199491-30471-1-git-send-email-pebolle@tiscali.nl>
Cc: Tilman Schmidt <tilman@imap.cc>, Alan Cox <alan@linux.intel.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Peter Hurley <peter@hurleysoftware.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450199491-30471-1-git-send-email-pebolle@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>

When shutting down the device, the struct ser_cardstate must not be
kfree()d immediately after the call to platform_device_unregister()
since the embedded struct platform_device is still in use.
Move the kfree() call to the release method instead.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Fixes: 2869b23e4b95 ("drivers/isdn/gigaset: new M101 driver (v2)")
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
 drivers/isdn/gigaset/ser-gigaset.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index 8e21f6afa832..635baaf34e95 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -368,19 +368,23 @@ static void gigaset_freecshw(struct cardstate *cs)
 	tasklet_kill(&cs->write_tasklet);
 	if (!cs->hw.ser)
 		return;
-	dev_set_drvdata(&cs->hw.ser->dev.dev, NULL);
 	platform_device_unregister(&cs->hw.ser->dev);
-	kfree(cs->hw.ser);
-	cs->hw.ser = NULL;
 }
 
 static void gigaset_device_release(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
+	struct cardstate *cs = dev_get_drvdata(dev);
 
 	/* adapted from platform_device_release() in drivers/base/platform.c */
 	kfree(dev->platform_data);
 	kfree(pdev->resource);
+
+	if (!cs)
+		return;
+	dev_set_drvdata(dev, NULL);
+	kfree(cs->hw.ser);
+	cs->hw.ser = NULL;
 }
 
 /*
-- 
2.4.3
