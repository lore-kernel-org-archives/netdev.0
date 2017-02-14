From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH v2 4/4] ptp: create "pins" together with the rest of attributes
Date: Tue, 14 Feb 2017 10:23:34 -0800
Message-ID: <20170214182334.23296-5-dmitry.torokhov@gmail.com>
References: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let's switch to using device_create_with_groups(), which will allow us to
create "pins" attribute group together with the rest of ptp device
attributes, and before userspace gets notified about ptp device creation.

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 drivers/ptp/ptp_clock.c   | 20 +++++++++++---------
 drivers/ptp/ptp_private.h |  7 ++++---
 drivers/ptp/ptp_sysfs.c   | 39 +++++++++------------------------------
 3 files changed, 24 insertions(+), 42 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index b4e5e8022c29..e8142803a1a7 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -221,16 +221,17 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 	mutex_init(&ptp->pincfg_mux);
 	init_waitqueue_head(&ptp->tsev_wq);
 
+	err = ptp_populate_pin_groups(ptp);
+	if (err)
+		goto no_pin_groups;
+
 	/* Create a new device in our class. */
-	ptp->dev = device_create(ptp_class, parent, ptp->devid, ptp,
-				 "ptp%d", ptp->index);
+	ptp->dev = device_create_with_groups(ptp_class, parent, ptp->devid,
+					     ptp, ptp->pin_attr_groups,
+					     "ptp%d", ptp->index);
 	if (IS_ERR(ptp->dev))
 		goto no_device;
 
-	err = ptp_populate_sysfs(ptp);
-	if (err)
-		goto no_sysfs;
-
 	/* Register a new PPS source. */
 	if (info->pps) {
 		struct pps_source_info pps;
@@ -258,10 +259,10 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 	if (ptp->pps_source)
 		pps_unregister_source(ptp->pps_source);
 no_pps:
-	ptp_cleanup_sysfs(ptp);
-no_sysfs:
 	device_destroy(ptp_class, ptp->devid);
 no_device:
+	ptp_cleanup_pin_groups(ptp);
+no_pin_groups:
 	mutex_destroy(&ptp->tsevq_mux);
 	mutex_destroy(&ptp->pincfg_mux);
 	ida_simple_remove(&ptp_clocks_map, index);
@@ -280,8 +281,9 @@ int ptp_clock_unregister(struct ptp_clock *ptp)
 	/* Release the clock's resources. */
 	if (ptp->pps_source)
 		pps_unregister_source(ptp->pps_source);
-	ptp_cleanup_sysfs(ptp);
+
 	device_destroy(ptp_class, ptp->devid);
+	ptp_cleanup_pin_groups(ptp);
 
 	posix_clock_unregister(&ptp->clock);
 	return 0;
diff --git a/drivers/ptp/ptp_private.h b/drivers/ptp/ptp_private.h
index 9c5d41421b65..d95888974d0c 100644
--- a/drivers/ptp/ptp_private.h
+++ b/drivers/ptp/ptp_private.h
@@ -54,6 +54,8 @@ struct ptp_clock {
 	struct device_attribute *pin_dev_attr;
 	struct attribute **pin_attr;
 	struct attribute_group pin_attr_group;
+	/* 1st entry is a pointer to the real group, 2nd is NULL terminator */
+	const struct attribute_group *pin_attr_groups[2];
 };
 
 /*
@@ -94,8 +96,7 @@ uint ptp_poll(struct posix_clock *pc,
 
 extern const struct attribute_group *ptp_groups[];
 
-int ptp_cleanup_sysfs(struct ptp_clock *ptp);
-
-int ptp_populate_sysfs(struct ptp_clock *ptp);
+int ptp_populate_pin_groups(struct ptp_clock *ptp);
+void ptp_cleanup_pin_groups(struct ptp_clock *ptp);
 
 #endif
diff --git a/drivers/ptp/ptp_sysfs.c b/drivers/ptp/ptp_sysfs.c
index 426e42c51df4..48401dfcd999 100644
--- a/drivers/ptp/ptp_sysfs.c
+++ b/drivers/ptp/ptp_sysfs.c
@@ -268,25 +268,14 @@ static ssize_t ptp_pin_store(struct device *dev, struct device_attribute *attr,
 	return count;
 }
 
-int ptp_cleanup_sysfs(struct ptp_clock *ptp)
+int ptp_populate_pin_groups(struct ptp_clock *ptp)
 {
-	struct device *dev = ptp->dev;
-	struct ptp_clock_info *info = ptp->info;
-
-	if (info->n_pins) {
-		sysfs_remove_group(&dev->kobj, &ptp->pin_attr_group);
-		kfree(ptp->pin_attr);
-		kfree(ptp->pin_dev_attr);
-	}
-	return 0;
-}
-
-static int ptp_populate_pins(struct ptp_clock *ptp)
-{
-	struct device *dev = ptp->dev;
 	struct ptp_clock_info *info = ptp->info;
 	int err = -ENOMEM, i, n_pins = info->n_pins;
 
+	if (!n_pins)
+		return 0;
+
 	ptp->pin_dev_attr = kcalloc(n_pins, sizeof(*ptp->pin_dev_attr),
 				    GFP_KERNEL);
 	if (!ptp->pin_dev_attr)
@@ -309,28 +298,18 @@ static int ptp_populate_pins(struct ptp_clock *ptp)
 	ptp->pin_attr_group.name = "pins";
 	ptp->pin_attr_group.attrs = ptp->pin_attr;
 
-	err = sysfs_create_group(&dev->kobj, &ptp->pin_attr_group);
-	if (err)
-		goto no_group;
+	ptp->pin_attr_groups[0] = &ptp->pin_attr_group;
+
 	return 0;
 
-no_group:
-	kfree(ptp->pin_attr);
 no_pin_attr:
 	kfree(ptp->pin_dev_attr);
 no_dev_attr:
 	return err;
 }
 
-int ptp_populate_sysfs(struct ptp_clock *ptp)
+void ptp_cleanup_pin_groups(struct ptp_clock *ptp)
 {
-	struct ptp_clock_info *info = ptp->info;
-	int err;
-
-	if (info->n_pins) {
-		err = ptp_populate_pins(ptp);
-		if (err)
-			return err;
-	}
-	return 0;
+	kfree(ptp->pin_attr);
+	kfree(ptp->pin_dev_attr);
 }
-- 
2.11.0.483.g087da7b7c-goog
