From: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: [v16, 5/7] base: soc: introduce soc_device_match() interface
Date: Wed, 9 Nov 2016 11:14:10 +0800
Message-ID: <1478661252-42439-6-git-send-email-yangbo.lu@nxp.com>
References: <1478661252-42439-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
	Minghuan Lian <minghuan.lian-3arQi8VN3Tc@public.gmane.org>, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Jochen Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Scott Wood
	<oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1478661252-42439-1-git-send-email-yangbo.lu-3arQi8VN3Tc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

We keep running into cases where device drivers want to know the exact
version of the a SoC they are currently running on. In the past, this has
usually been done through a vendor specific API that can be called by a
driver, or by directly accessing some kind of version register that is
not part of the device itself but that belongs to a global register area
of the chip.

Common reasons for doing this include:

- A machine is not using devicetree or similar for passing data about
  on-chip devices, but just announces their presence using boot-time
  platform devices, and the machine code itself does not care about the
  revision.

- There is existing firmware or boot loaders with existing DT binaries
  with generic compatible strings that do not identify the particular
  revision of each device, but the driver knows which SoC revisions
  include which part.

- A prerelease version of a chip has some quirks and we are using the same
  version of the bootloader and the DT blob on both the prerelease and the
  final version. An update of the DT binding seems inappropriate because
  that would involve maintaining multiple copies of the dts and/or
  bootloader.

This patch introduces the soc_device_match() interface that is meant to
work like of_match_node() but instead of identifying the version of a
device, it identifies the SoC itself using a vendor-agnostic interface.

Unlike of_match_node(), we do not do an exact string compare but instead
use glob_match() to allow wildcards in strings.

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Signed-off-by: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Acked-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
---
Changes for v11:
	- Added this patch for soc match
Changes for v12:
	- Corrected the author
	- Rewrited soc_device_match with while loop
Changes for v13:
	- Added ack from Greg
Changes for v14:
	- None
Changes for v15:
	- None
Changes for v16:
	- None
---
 drivers/base/Kconfig    |  1 +
 drivers/base/soc.c      | 66 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/sys_soc.h |  3 +++
 3 files changed, 70 insertions(+)

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index d02e7c0..2abea87 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -237,6 +237,7 @@ config GENERIC_CPU_AUTOPROBE
 
 config SOC_BUS
 	bool
+	select GLOB
 
 source "drivers/base/regmap/Kconfig"
 
diff --git a/drivers/base/soc.c b/drivers/base/soc.c
index b63f23e..0c5cf87 100644
--- a/drivers/base/soc.c
+++ b/drivers/base/soc.c
@@ -13,6 +13,7 @@
 #include <linux/spinlock.h>
 #include <linux/sys_soc.h>
 #include <linux/err.h>
+#include <linux/glob.h>
 
 static DEFINE_IDA(soc_ida);
 
@@ -159,3 +160,68 @@ static int __init soc_bus_register(void)
 	return bus_register(&soc_bus_type);
 }
 core_initcall(soc_bus_register);
+
+static int soc_device_match_one(struct device *dev, void *arg)
+{
+	struct soc_device *soc_dev = container_of(dev, struct soc_device, dev);
+	const struct soc_device_attribute *match = arg;
+
+	if (match->machine &&
+	    !glob_match(match->machine, soc_dev->attr->machine))
+		return 0;
+
+	if (match->family &&
+	    !glob_match(match->family, soc_dev->attr->family))
+		return 0;
+
+	if (match->revision &&
+	    !glob_match(match->revision, soc_dev->attr->revision))
+		return 0;
+
+	if (match->soc_id &&
+	    !glob_match(match->soc_id, soc_dev->attr->soc_id))
+		return 0;
+
+	return 1;
+}
+
+/*
+ * soc_device_match - identify the SoC in the machine
+ * @matches: zero-terminated array of possible matches
+ *
+ * returns the first matching entry of the argument array, or NULL
+ * if none of them match.
+ *
+ * This function is meant as a helper in place of of_match_node()
+ * in cases where either no device tree is available or the information
+ * in a device node is insufficient to identify a particular variant
+ * by its compatible strings or other properties. For new devices,
+ * the DT binding should always provide unique compatible strings
+ * that allow the use of of_match_node() instead.
+ *
+ * The calling function can use the .data entry of the
+ * soc_device_attribute to pass a structure or function pointer for
+ * each entry.
+ */
+const struct soc_device_attribute *soc_device_match(
+	const struct soc_device_attribute *matches)
+{
+	int ret = 0;
+
+	if (!matches)
+		return NULL;
+
+	while (!ret) {
+		if (!(matches->machine || matches->family ||
+		      matches->revision || matches->soc_id))
+			break;
+		ret = bus_for_each_dev(&soc_bus_type, NULL, (void *)matches,
+				       soc_device_match_one);
+		if (!ret)
+			matches++;
+		else
+			return matches;
+	}
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(soc_device_match);
diff --git a/include/linux/sys_soc.h b/include/linux/sys_soc.h
index 2739ccb..9f5eb06 100644
--- a/include/linux/sys_soc.h
+++ b/include/linux/sys_soc.h
@@ -13,6 +13,7 @@ struct soc_device_attribute {
 	const char *family;
 	const char *revision;
 	const char *soc_id;
+	const void *data;
 };
 
 /**
@@ -34,4 +35,6 @@ void soc_device_unregister(struct soc_device *soc_dev);
  */
 struct device *soc_device_to_device(struct soc_device *soc);
 
+const struct soc_device_attribute *soc_device_match(
+	const struct soc_device_attribute *matches);
 #endif /* __SOC_BUS_H */
-- 
2.1.0.27.g96db324
