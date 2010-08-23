From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: [PATCH v2] driver core: platform_bus: allow runtime override of dev_pm_ops
Date: Mon, 23 Aug 2010 10:18:42 -0700
Message-ID: <1282583922-984-1-git-send-email-khilman@deeprootsystems.com>
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Magnus Damm <magnus.damm@gmail.com>,
	Kevin Hilman <khilman@deeprootsystems.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>, Paul Mundt <lethal@linux-sh.org>,
	Magnus Damm <damm@opensource.se>,
	Eric Miao <eric.y.miao@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, the platform_bus allows customization of several of the
busses dev_pm_ops methods by using weak symbols so that platform code
can override them.  The weak-symbol approach is not scalable when
wanting to support multiple platforms in a single kernel binary.

Instead, provide __init methods for platform code to customize the
dev_pm_ops methods at runtime.

NOTE: after these dynamic methods are merged, the weak symbols should
      be removed from drivers/base/platform.c.  AFAIK, this will only
      affect SH and sh-mobile which should be converted to use this
      runtime approach instead of the weak symbols.  After SH &
      sh-mobile are converted, the weak symobols could be removed.

Tested on OMAP3.

Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Magnus Damm <magnus.damm@gmail.com>
Signed-off-by: Kevin Hilman <khilman@deeprootsystems.com>
---
 drivers/base/platform.c         |   35 +++++++++++++++++++++++++++++++++++
 include/linux/platform_device.h |    3 +++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/base/platform.c b/drivers/base/platform.c
index c6c933f..e40a773 100644
--- a/drivers/base/platform.c
+++ b/drivers/base/platform.c
@@ -976,6 +976,41 @@ struct bus_type platform_bus_type = {
 };
 EXPORT_SYMBOL_GPL(platform_bus_type);
 
+/**
+ * platform_bus_get_pm_ops: return pointer to busses dev_pm_ops
+ *
+ * This function can be used by platform code to get the current
+ * set of dev_pm_ops functions used by the platform_bus_type.
+ */
+const struct dev_pm_ops * __init platform_bus_get_pm_ops(void)
+{
+	return platform_bus_type.pm;
+}
+
+/**
+ * platform_bus_set_pm_ops: update dev_pm_ops for the platform_bus_type
+ *
+ * @pm: pointer to new dev_pm_ops struct to be used for platform_bus_type
+ *
+ * Platform code can override the dev_pm_ops methods of
+ * platform_bus_type by using this function.  It is expected that
+ * platform code will first do a platform_bus_get_pm_ops(), then
+ * kmemdup it, then customize selected methods and pass a pointer to
+ * the new struct dev_pm_ops to this function.
+ *
+ * Since platform-specific code is customizing methods for *all*
+ * devices (not just platform-specific devices) it is expected that
+ * any custom overrides of these functions will keep existing behavior
+ * and simply extend it.  For example, any customization of the
+ * runtime PM methods should continue to call the pm_generic_*
+ * functions as the default ones do in addition to the
+ * platform-specific behavior.
+ */
+void __init platform_bus_set_pm_ops(struct dev_pm_ops *pm)
+{
+	platform_bus_type.pm = pm;
+}
+
 int __init platform_bus_init(void)
 {
 	int error;
diff --git a/include/linux/platform_device.h b/include/linux/platform_device.h
index d7ecad0..cd55d39 100644
--- a/include/linux/platform_device.h
+++ b/include/linux/platform_device.h
@@ -138,6 +138,9 @@ extern struct platform_device *platform_create_bundle(struct platform_driver *dr
 					struct resource *res, unsigned int n_res,
 					const void *data, size_t size);
 
+extern const struct dev_pm_ops * __init platform_bus_get_pm_ops(void);
+extern void __init platform_bus_set_pm_ops(struct dev_pm_ops *pm);
+
 /* early platform driver interface */
 struct early_platform_driver {
 	const char *class_str;
-- 
1.7.2.1
