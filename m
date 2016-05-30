From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/4]  base: soc: introduce soc_device_match() interface
Date: Mon, 30 May 2016 15:14:38 +0200
Message-ID: <6032641.cjSseEG2PF@wuerfel>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com> <HE1PR04MB0889852B7809A1CCFF8922ACF8410@HE1PR04MB0889.eurprd04.prod.outlook.com> <CAPDyKFqx2JMLzXoDxGCKFYMFV47+SegnkuWFXKvsQHK7L5w-1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ulf Hansson <ulf.hansson@linaro.org>,
	Yangbo Lu <yangbo.lu@nxp.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Xiaobo Xie <xiaobo.xie@nxp.com>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Scott Wood <oss@buserror.net>,
	Rob Herring <robh+dt@kernel.org>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Yang-Leo
To: linuxppc-dev@lists.ozlabs.org
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <CAPDyKFqx2JMLzXoDxGCKFYMFV47+SegnkuWFXKvsQHK7L5w-1g@mail.gmail.com>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We keep running into cases where device drivers want to know the exact
version of the SoC a they are currently running on. In the past, this
has usually been done through a vendor specific API that can be called
by a driver, or by directly accessing some kind of version register
that is not part of the device itself but that belongs to a global
register area of the chip.

Common reasons for doing this include:

- A machine is not using devicetree or similar for passing data
  about on-chip devices, but just announces their presence using
  boot-time platform devices, and the machine code itself does
  not care about the revision.

- There is existing firmware or boot loaders with existing DT
  binaries with generic compatible strings that do not identify
  the particular revision of each device, but the driver knows
  which SoC revisions include which part

- A prerelease version of a chip has some quirks and we are
  using the same version of the bootloader and the DT blob
  on both the prerelease and the final version. An update of
  the DT binding seems inappropriate because that would involve
  maintaining multiple copies of the dts and/or bootloader.

This introduces the soc_device_match() interface that is meant
to work like of_match_node() but instead of identifying the
version of a device, it identifies the SoC itself using a
vendor-agnostic interface.

Unlike soc_device_match(), we do not do an exact string compare
but instead use glob_match() to allow wildcards in strings.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 246acdafedb6..fc7613cc7fd5 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -225,6 +225,7 @@ config GENERIC_CPU_AUTOPROBE
 
 config SOC_BUS
 	bool
+	select GLOB
 
 source "drivers/base/regmap/Kconfig"
 
diff --git a/drivers/base/soc.c b/drivers/base/soc.c
index 75b98aad6faf..e9623c6674a5 100644
--- a/drivers/base/soc.c
+++ b/drivers/base/soc.c
@@ -14,6 +14,7 @@
 #include <linux/spinlock.h>
 #include <linux/sys_soc.h>
 #include <linux/err.h>
+#include <linux/glob.h>
 
 static DEFINE_IDA(soc_ida);
 
@@ -168,3 +169,60 @@ static void __exit soc_bus_unregister(void)
 	bus_unregister(&soc_bus_type);
 }
 module_exit(soc_bus_unregister);
+
+static int soc_device_match_one(struct device *dev, void *arg)
+{
+	struct soc_device *soc_dev = container_of(dev, struct soc_device, dev);
+	struct soc_device_attribute *match = arg;
+
+	if (match->machine && !glob_match(match->machine, soc_dev->attr->machine))
+		return 0;
+
+	if (match->family && !glob_match(match->family, soc_dev->attr->family))
+		return 0;
+
+	if (match->revision && !glob_match(match->revision, soc_dev->attr->revision))
+		return 0;
+
+	if (match->soc_id && !glob_match(match->soc_id, soc_dev->attr->revision))
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
+struct soc_device_attribute *soc_device_match(struct soc_device_attribute *matches)
+{
+	struct device *dev;
+	int ret;
+
+	for (ret = 0; ret == 0; matches++) {
+		if (matches->machine || matches->family ||
+		    matches->revision || matches->soc_id)
+			return NULL;
+
+		dev = NULL;
+		ret = bus_for_each_dev(&soc_bus_type, dev, matches,
+					 soc_device_match_one);
+	}
+
+	return matches;
+}
+EXPORT_SYMBOL_GPL(soc_device_match);
diff --git a/include/linux/sys_soc.h b/include/linux/sys_soc.h
index 2739ccb69571..02c48c76052b 100644
--- a/include/linux/sys_soc.h
+++ b/include/linux/sys_soc.h
@@ -13,6 +13,8 @@ struct soc_device_attribute {
 	const char *family;
 	const char *revision;
 	const char *soc_id;
+
+	const void *data;
 };
 
 /**
@@ -34,4 +36,6 @@ void soc_device_unregister(struct soc_device *soc_dev);
  */
 struct device *soc_device_to_device(struct soc_device *soc);
 
+struct soc_device_attribute *soc_device_match(struct soc_device_attribute *matches);
+
 #endif /* __SOC_BUS_H */

