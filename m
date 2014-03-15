From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 4/5] at86rf230: make reset pin
	optionally
Date: Sat, 15 Mar 2014 09:29:06 +0100
Message-ID: <1394872147-3021-5-git-send-email-alex.aring@gmail.com>
References: <1394872147-3021-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1394872147-3021-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch make the reset pin optionally. Some devices like the atben
from qi-hardware don't have a reset pin externally. The usually way is
to turn power off/on for the atben device to initiate a device reset.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 34 +++++++++++++++++++++-------------
 1 file changed, 21 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 3744240..47677e3f9 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -1059,9 +1059,11 @@ static int at86rf230_probe(struct spi_device *spi)
 		return -EINVAL;
 	}
 
-	rc = gpio_request(pdata->rstn, "rstn");
-	if (rc)
-		return rc;
+	if (gpio_is_valid(pdata->rstn)) {
+		rc = gpio_request(pdata->rstn, "rstn");
+		if (rc)
+			return rc;
+	}
 
 	if (gpio_is_valid(pdata->slp_tr)) {
 		rc = gpio_request(pdata->slp_tr, "slp_tr");
@@ -1069,9 +1071,11 @@ static int at86rf230_probe(struct spi_device *spi)
 			goto err_slp_tr;
 	}
 
-	rc = gpio_direction_output(pdata->rstn, 1);
-	if (rc)
-		goto err_gpio_dir;
+	if (gpio_is_valid(pdata->rstn)) {
+		rc = gpio_direction_output(pdata->rstn, 1);
+		if (rc)
+			goto err_gpio_dir;
+	}
 
 	if (gpio_is_valid(pdata->slp_tr)) {
 		rc = gpio_direction_output(pdata->slp_tr, 0);
@@ -1080,11 +1084,13 @@ static int at86rf230_probe(struct spi_device *spi)
 	}
 
 	/* Reset */
-	udelay(1);
-	gpio_set_value(pdata->rstn, 0);
-	udelay(1);
-	gpio_set_value(pdata->rstn, 1);
-	usleep_range(120, 240);
+	if (gpio_is_valid(pdata->rstn)) {
+		udelay(1);
+		gpio_set_value(pdata->rstn, 0);
+		udelay(1);
+		gpio_set_value(pdata->rstn, 1);
+		usleep_range(120, 240);
+	}
 
 	rc = __at86rf230_detect_device(spi, &man_id, &part, &version);
 	if (rc < 0)
@@ -1198,7 +1204,8 @@ err_gpio_dir:
 	if (gpio_is_valid(pdata->slp_tr))
 		gpio_free(pdata->slp_tr);
 err_slp_tr:
-	gpio_free(pdata->rstn);
+	if (gpio_is_valid(pdata->rstn))
+		gpio_free(pdata->rstn);
 	return rc;
 }
 
@@ -1214,7 +1221,8 @@ static int at86rf230_remove(struct spi_device *spi)
 
 	if (gpio_is_valid(pdata->slp_tr))
 		gpio_free(pdata->slp_tr);
-	gpio_free(pdata->rstn);
+	if (gpio_is_valid(pdata->rstn))
+		gpio_free(pdata->rstn);
 
 	mutex_destroy(&lp->bmux);
 	ieee802154_free_device(lp->dev);
-- 
1.9.0


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
