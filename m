From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] be2net: make hwmon interface optional
Date: Mon, 18 May 2015 23:06:45 +0200
Message-ID: <2638325.2pcgKkR8vC@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@emulex.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sathya Perla <sathya.perla@avagotech.com>,
	Ajit Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hwmon interface in the be2net driver causes a link error when
be2net is built-in while the hwmon subsystem is a loadable module:

drivers/built-in.o: In function `be_probe':
drivers/net/ethernet/emulex/benet/be_main.c:5761: undefined reference to `devm_hwmon_device_register_with_groups'

This adds a new Kconfig symbol, following the example of multiple
other drivers that have the same problem. The new CONFIG_BE2NET_HWMON
will not be available when (BE2NET=y && HWMON=m) to avoid this
problem.

We have to also mark be_hwmon_show_temp as 'static' to ensure the
compiler can optimize out all the unused code.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 29e9122b3a ("be2net: Export board temperature using hwmon-sysfs interface.")
---
Found on ARM randconfig builds in linux-next

diff --git a/drivers/net/ethernet/emulex/benet/Kconfig b/drivers/net/ethernet/emulex/benet/Kconfig
index ea94a8eb6b35..7108563260ae 100644
--- a/drivers/net/ethernet/emulex/benet/Kconfig
+++ b/drivers/net/ethernet/emulex/benet/Kconfig
@@ -5,6 +5,15 @@ config BE2NET
 	  This driver implements the NIC functionality for ServerEngines'
 	  10Gbps network adapter - BladeEngine.
 
+config BE2NET_HWMON
+	bool "HWMON support for be2net driver"
+	depends on BE2NET && HWMON
+	depends on !(BE2NET=y && HWMON=m)
+	default y
+	---help---
+	  Say Y here if you want to expose thermal sensor data on
+	  be2net network adapter.
+
 config BE2NET_VXLAN
         bool "VXLAN offload support on be2net driver"
         default y
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index dc7c0fd239f7..75696d4f9ed0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5612,9 +5612,9 @@ static void be_remove(struct pci_dev *pdev)
 	free_netdev(adapter->netdev);
 }
 
-ssize_t be_hwmon_show_temp(struct device *dev,
-			   struct device_attribute *dev_attr,
-			   char *buf)
+static ssize_t be_hwmon_show_temp(struct device *dev,
+				  struct device_attribute *dev_attr,
+				  char *buf)
 {
 	struct be_adapter *adapter = dev_get_drvdata(dev);
 
@@ -5756,7 +5756,7 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 	be_schedule_err_detection(adapter);
 
 	/* On Die temperature not supported for VF. */
-	if (be_physfn(adapter)) {
+	if (be_physfn(adapter) && IS_ENABLED(CONFIG_BE2NET_HWMON)) {
 		adapter->hwmon_info.hwmon_dev =
 			devm_hwmon_device_register_with_groups(&pdev->dev,
 							       DRV_NAME,
