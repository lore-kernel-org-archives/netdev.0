From: Lee Jones <lee.jones@linaro.org>
Subject: [PATCH 4/4 v3] net/smsc911x: Provide common clock functionality
Date: Thu, 3 Jan 2013 11:14:50 +0000
Message-ID: <20130103111450.GC14714@gmail.com>
References: <1355937587-31730-1-git-send-email-lee.jones@linaro.org>
 <1355937587-31730-4-git-send-email-lee.jones@linaro.org>
 <CACRpkda79O_b3Z8g7Sy7vMtW9neZU4x-Z=iEQgjqu4X5tFKyhw@mail.gmail.com>
 <20121220192441.GC14363@n2100.arm.linux.org.uk>
 <20121220203514.GN2691@gmail.com>
 <20121220205113.GD14363@n2100.arm.linux.org.uk>
 <20121221091306.GO2691@gmail.com>
 <20121221092421.GG14363@n2100.arm.linux.org.uk>
 <20121221114105.GP2691@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Walleij <linus.walleij@linaro.org>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Robert Marklund <robert.marklund@stericsson.com>,
	linus.walleij@stericsson.com, arnd@arndb.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121221114105.GP2691@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some platforms provide clocks which require enabling before the
SMSC911x chip will power on. This patch uses the new common clk
framework to do just that. If no clock is provided, it will just
be ignored and the driver will continue to assume that no clock
is required for the chip to run successfully.

Cc: Steve Glendinning <steve.glendinning@shawell.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Lee Jones <lee.jones@linaro.org>
---
 drivers/net/ethernet/smsc/smsc911x.c |   29 ++++++++++++++++++++++++++++-
 1 file changed, 28 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index e112877..f9b6bb7 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -33,6 +33,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/crc32.h>
+#include <linux/clk.h>
 #include <linux/delay.h>
 #include <linux/errno.h>
 #include <linux/etherdevice.h>
@@ -144,6 +145,9 @@ struct smsc911x_data {
 
 	/* regulators */
 	struct regulator_bulk_data supplies[SMSC911X_NUM_SUPPLIES];
+
+	/* clock */
+	struct clk *clk;
 };
 
 /* Easy access to information */
@@ -369,7 +373,7 @@ out:
 }
 
 /*
- * enable resources, currently just regulators.
+ * enable regulator and clock resources.
  */
 static int smsc911x_enable_resources(struct platform_device *pdev)
 {
@@ -382,6 +386,13 @@ static int smsc911x_enable_resources(struct platform_device *pdev)
 	if (ret)
 		netdev_err(ndev, "failed to enable regulators %d\n",
 				ret);
+
+	if (!IS_ERR(pdata->clk)) {
+		ret = clk_prepare_enable(pdata->clk);
+		if (ret < 0)
+			netdev_err(ndev, "failed to enable clock %d\n", ret);
+	}
+
 	return ret;
 }
 
@@ -396,6 +407,10 @@ static int smsc911x_disable_resources(struct platform_device *pdev)
 
 	ret = regulator_bulk_disable(ARRAY_SIZE(pdata->supplies),
 			pdata->supplies);
+
+	if (!IS_ERR(pdata->clk))
+		clk_disable_unprepare(pdata->clk);
+
 	return ret;
 }
 
@@ -421,6 +436,12 @@ static int smsc911x_request_resources(struct platform_device *pdev)
 	if (ret)
 		netdev_err(ndev, "couldn't get regulators %d\n",
 				ret);
+
+	/* Request clock */
+	pdata->clk = clk_get(&pdev->dev, NULL);
+	if (IS_ERR(pdata->clk))
+		netdev_warn(ndev, "couldn't get clock %li\n", PTR_ERR(pdata->clk));
+
 	return ret;
 }
 
@@ -436,6 +457,12 @@ static void smsc911x_free_resources(struct platform_device *pdev)
 	/* Free regulators */
 	regulator_bulk_free(ARRAY_SIZE(pdata->supplies),
 			pdata->supplies);
+
+	/* Free clock */
+	if (!IS_ERR(pdata->clk)) {
+		clk_put(pdata->clk);
+		pdata->clk = NULL;
+	}
 }
 
 /* waits for MAC not busy, with timeout.  Only called by smsc911x_mac_read
-- 
1.7.9.5
