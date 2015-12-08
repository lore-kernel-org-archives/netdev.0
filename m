From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/3] ser_gigaset: fix deallocation of platform device structure
Date: Tue,  8 Dec 2015 12:00:33 +0100 (CET)
Message-ID: <83c4ab9bbca911aad62343154eabfa1af077b021.1449570042.git.tilman@imap.cc>
References: <cover.1449570042.git.tilman@imap.cc>
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	<syzkaller@googlegroups.com>, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	<gigaset307x-common@lists.sourceforge.net>,
	<linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1449570042.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When shutting down the device, the struct ser_cardstate must not be
kfree()d immediately after the call to platform_device_unregister()
since the embedded struct platform_device is still in use.
Move the kfree() call to the release method instead.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Fixes: 2869b23e4b95 ("drivers/isdn/gigaset: new M101 driver (v2)")
Reported-by: Sasha Levin <sasha.levin@oracle.com>
---
 drivers/isdn/gigaset/ser-gigaset.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index d8771b5..2693cb2 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -370,19 +370,23 @@ static void gigaset_freecshw(struct cardstate *cs)
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
1.9.2.459.g68773ac
