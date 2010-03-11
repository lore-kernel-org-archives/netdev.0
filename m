From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 01/27] drivercore: Add of_match_table to the common device
	drivers
Date: Thu, 11 Mar 2010 11:21:53 -0700
Message-ID: <20100311182153.13103.40899.stgit__41297.1966471106$1268332136$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f198.google.com ([209.85.216.198]:53576 "EHLO
	mail-px0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969Ab0CKS2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:28:37 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OF-style matching can be available to any device, on any type of bus.
This patch allows any driver to provide an OF match table when CONFIG_OF
is enabled so that drivers can be bound against devices described in
the device tree.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
---

 arch/powerpc/kernel/ibmebus.c  |    2 +-
 drivers/macintosh/macio_asic.c |    5 ++---
 drivers/of/platform.c          |    7 ++++---
 include/linux/device.h         |    4 ++++
 4 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/kernel/ibmebus.c b/arch/powerpc/kernel/ibmebus.c
index 797e9ac..62ded8b 100644
--- a/arch/powerpc/kernel/ibmebus.c
+++ b/arch/powerpc/kernel/ibmebus.c
@@ -201,7 +201,7 @@ static int ibmebus_create_devices(const struct of_device_id *matches)
 int ibmebus_register_driver(struct of_platform_driver *drv)
 {
 	/* If the driver uses devices that ibmebus doesn't know, add them */
-	ibmebus_create_devices(drv->match_table);
+	ibmebus_create_devices(drv->driver.of_match_table);
 
 	return of_register_driver(drv, &ibmebus_bus_type);
 }
diff --git a/drivers/macintosh/macio_asic.c b/drivers/macintosh/macio_asic.c
index 48a5f04..e3ba1d8 100644
--- a/drivers/macintosh/macio_asic.c
+++ b/drivers/macintosh/macio_asic.c
@@ -40,8 +40,7 @@ static struct macio_chip      *macio_on_hold;
 static int macio_bus_match(struct device *dev, struct device_driver *drv) 
 {
 	struct macio_dev * macio_dev = to_macio_device(dev);
-	struct macio_driver * macio_drv = to_macio_driver(drv);
-	const struct of_device_id * matches = macio_drv->match_table;
+	const struct of_device_id * matches = drv->of_match_table;
 
 	if (!matches) 
 		return 0;
@@ -84,7 +83,7 @@ static int macio_device_probe(struct device *dev)
 
 	macio_dev_get(macio_dev);
 
-	match = of_match_device(drv->match_table, &macio_dev->ofdev);
+	match = of_match_device(drv->driver.of_match_table, &macio_dev->ofdev);
 	if (match)
 		error = drv->probe(macio_dev, match);
 	if (error)
diff --git a/drivers/of/platform.c b/drivers/of/platform.c
index d58ade1..9fd7f7d 100644
--- a/drivers/of/platform.c
+++ b/drivers/of/platform.c
@@ -22,8 +22,7 @@ extern struct device_attribute of_platform_device_attrs[];
 static int of_platform_bus_match(struct device *dev, struct device_driver *drv)
 {
 	struct of_device *of_dev = to_of_device(dev);
-	struct of_platform_driver *of_drv = to_of_platform_driver(drv);
-	const struct of_device_id *matches = of_drv->match_table;
+	const struct of_device_id *matches = drv->of_match_table;
 
 	if (!matches)
 		return 0;
@@ -46,7 +45,7 @@ static int of_platform_device_probe(struct device *dev)
 
 	of_dev_get(of_dev);
 
-	match = of_match_device(drv->match_table, of_dev);
+	match = of_match_device(drv->driver.of_match_table, of_dev);
 	if (match)
 		error = drv->probe(of_dev, match);
 	if (error)
@@ -391,6 +390,8 @@ int of_register_driver(struct of_platform_driver *drv, struct bus_type *bus)
 		drv->driver.name = drv->name;
 	if (!drv->driver.owner)
 		drv->driver.owner = drv->owner;
+	if (!drv->driver.of_match_table)
+		drv->driver.of_match_table = drv->match_table;
 	drv->driver.bus = bus;
 
 	/* register with core */
diff --git a/include/linux/device.h b/include/linux/device.h
index 7a968bd..cd7534c 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -129,6 +129,10 @@ struct device_driver {
 
 	bool suppress_bind_attrs;	/* disables bind/unbind via sysfs */
 
+#if defined(CONFIG_OF)
+	const struct of_device_id	*of_match_table;
+#endif
+
 	int (*probe) (struct device *dev);
 	int (*remove) (struct device *dev);
 	void (*shutdown) (struct device *dev);

