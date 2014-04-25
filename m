From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 2/6] qlcnic: Add hwmon interface to export board temperature.
Date: Fri, 25 Apr 2014 17:43:57 -0400
Message-ID: <1398462241-15478-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shahed.shaikh@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Harish Patil <harish.patil@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:15863 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751400AbaDYWWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 18:22:00 -0400
In-Reply-To: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>

Signed-off-by: Harish Patil <harish.patil@qlogic.com>
---
 drivers/net/ethernet/qlogic/Kconfig               | 11 ++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h       | 15 ++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c  |  4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 66 +++++++++++++++++++++++
 4 files changed, 95 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index c14bd31..25b19dd 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -66,6 +66,17 @@ config QLCNIC_VXLAN
 	  Say Y here if you want to enable hardware offload support for
 	  Virtual eXtensible Local Area Network (VXLAN) in the driver.
 
+config QLCNIC_HWMON
+	bool "QLOGIC QLCNIC 82XX and 83XX family HWMON support"
+	depends on QLCNIC && HWMON
+	default y
+	---help---
+	  This configuration parameter can be used to read the
+	  board temperature in Converged Ethernet devices
+	  supported by qlcnic.
+
+	  This data is available via the hwmon sysfs interface.
+
 config QLGE
 	tristate "QLogic QLGE 10Gb Ethernet Driver Support"
 	depends on PCI
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 7b52a88..381da04 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -537,6 +537,7 @@ struct qlcnic_hardware_context {
 	u8 phys_port_id[ETH_ALEN];
 	u8 lb_mode;
 	u16 vxlan_port;
+	struct device *hwmon_dev;
 };
 
 struct qlcnic_adapter_stats {
@@ -2361,4 +2362,18 @@ static inline u32 qlcnic_get_vnic_func_count(struct qlcnic_adapter *adapter)
 	else
 		return QLC_DEFAULT_VNIC_COUNT;
 }
+
+#ifdef CONFIG_QLCNIC_HWMON
+void qlcnic_register_hwmon_dev(struct qlcnic_adapter *);
+void qlcnic_unregister_hwmon_dev(struct qlcnic_adapter *);
+#else
+static inline void qlcnic_register_hwmon_dev(struct qlcnic_adapter *adapter)
+{
+	return;
+}
+static inline void qlcnic_unregister_hwmon_dev(struct qlcnic_adapter *adapter)
+{
+	return;
+}
+#endif
 #endif				/* __QLCNIC_H_ */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index dbf7539..d853e31 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2593,7 +2593,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		qlcnic_alloc_lb_filters_mem(adapter);
 
 	qlcnic_add_sysfs(adapter);
-
+	qlcnic_register_hwmon_dev(adapter);
 	return 0;
 
 err_out_disable_mbx_intr:
@@ -2700,6 +2700,8 @@ static void qlcnic_remove(struct pci_dev *pdev)
 
 	qlcnic_remove_sysfs(adapter);
 
+	qlcnic_unregister_hwmon_dev(adapter);
+
 	qlcnic_cleanup_pci_map(adapter->ahw);
 
 	qlcnic_release_firmware(adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index cd346e2..eee5fc9 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -19,6 +19,10 @@
 #include <linux/sysfs.h>
 #include <linux/aer.h>
 #include <linux/log2.h>
+#ifdef CONFIG_QLCNIC_HWMON
+#include <linux/hwmon.h>
+#include <linux/hwmon-sysfs.h>
+#endif
 
 #define QLC_STATUS_UNSUPPORTED_CMD	-2
 
@@ -1243,6 +1247,68 @@ static struct bin_attribute bin_attr_flash = {
 	.write = qlcnic_83xx_sysfs_flash_write_handler,
 };
 
+#ifdef CONFIG_QLCNIC_HWMON
+
+static ssize_t qlcnic_hwmon_show_temp(struct device *dev,
+				      struct device_attribute *dev_attr,
+				      char *buf)
+{
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	unsigned int temperature = 0, value = 0;
+
+	if (qlcnic_83xx_check(adapter))
+		value = QLCRDX(adapter->ahw, QLC_83XX_ASIC_TEMP);
+	else if (qlcnic_82xx_check(adapter))
+		value = QLC_SHARED_REG_RD32(adapter, QLCNIC_ASIC_TEMP);
+
+	temperature = qlcnic_get_temp_val(value);
+	/* display millidegree celcius */
+	temperature *= 1000;
+	return sprintf(buf, "%u\n", temperature);
+}
+
+/* hwmon-sysfs attributes */
+static SENSOR_DEVICE_ATTR(temp1_input, S_IRUGO,
+			  qlcnic_hwmon_show_temp, NULL, 1);
+
+static struct attribute *qlcnic_hwmon_attrs[] = {
+	&sensor_dev_attr_temp1_input.dev_attr.attr,
+	NULL
+};
+
+ATTRIBUTE_GROUPS(qlcnic_hwmon);
+
+void qlcnic_register_hwmon_dev(struct qlcnic_adapter *adapter)
+{
+	struct device *dev = &adapter->pdev->dev;
+	struct device *hwmon_dev;
+
+	/* Skip hwmon registration for a VF device */
+	if (qlcnic_sriov_vf_check(adapter)) {
+		adapter->ahw->hwmon_dev = NULL;
+		return;
+	}
+	hwmon_dev = hwmon_device_register_with_groups(dev, qlcnic_driver_name,
+						      adapter,
+						      qlcnic_hwmon_groups);
+	if (IS_ERR(hwmon_dev)) {
+		dev_err(dev, "Cannot register with hwmon, err=%ld\n",
+			PTR_ERR(hwmon_dev));
+		hwmon_dev = NULL;
+	}
+	adapter->ahw->hwmon_dev = hwmon_dev;
+}
+
+void qlcnic_unregister_hwmon_dev(struct qlcnic_adapter *adapter)
+{
+	struct device *hwmon_dev = adapter->ahw->hwmon_dev;
+	if (hwmon_dev) {
+		hwmon_device_unregister(hwmon_dev);
+		adapter->ahw->hwmon_dev = NULL;
+	}
+}
+#endif
+
 void qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
-- 
1.8.1.4
