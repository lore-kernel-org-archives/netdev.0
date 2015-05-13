From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH net-next 1/3] be2net: Export board temperature using hwmon-sysfs interface.
Date: Wed, 13 May 2015 13:00:12 +0530
Message-ID: <1431502214-11810-2-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
References: <1431502214-11810-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:49883 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753256AbbEMHwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 03:52:02 -0400
In-Reply-To: <1431502214-11810-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethtool statistics is not the right place to display board temperature.
This patch adds support to export die temperature of devices supported
by be2net driver via the sysfs hwmon interface.

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |   10 ++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    4 ++-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    1 -
 drivers/net/ethernet/emulex/benet/be_main.c    |   34 ++++++++++++++++++++++++
 4 files changed, 46 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 1eafc07..c62a32f 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -31,6 +31,8 @@
 #include <linux/slab.h>
 #include <linux/u64_stats_sync.h>
 #include <linux/cpumask.h>
+#include <linux/hwmon.h>
+#include <linux/hwmon-sysfs.h>
 
 #include "be_hw.h"
 #include "be_roce.h"
@@ -314,7 +316,6 @@ struct be_rx_obj {
 } ____cacheline_aligned_in_smp;
 
 struct be_drv_stats {
-	u32 be_on_die_temperature;
 	u32 eth_red_drops;
 	u32 dma_map_errors;
 	u32 rx_drops_no_pbuf;
@@ -434,6 +435,12 @@ struct rss_info {
 	u8 rss_hkey[RSS_HASH_KEY_LEN];
 };
 
+#define BE_INVALID_DIE_TEMP	0xFF
+struct be_hwmon {
+	struct device *hwmon_dev;
+	u8 be_on_die_temp;  /* Unit: millidegree Celsius */
+};
+
 /* Macros to read/write the 'features' word of be_wrb_params structure.
  */
 #define	BE_WRB_F_BIT(name)			BE_WRB_F_##name##_BIT
@@ -573,6 +580,7 @@ struct be_adapter {
 	u16 qnq_vid;
 	u32 msg_enable;
 	int be_get_temp_freq;
+	struct be_hwmon hwmon_info;
 	u8 pf_number;
 	struct rss_info rss_info;
 };
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index b419bde..ecd92a0 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -192,10 +192,12 @@ static void be_async_cmd_process(struct be_adapter *adapter,
 		if (base_status == MCC_STATUS_SUCCESS) {
 			struct be_cmd_resp_get_cntl_addnl_attribs *resp =
 							(void *)resp_hdr;
-			adapter->drv_stats.be_on_die_temperature =
+			adapter->hwmon_info.be_on_die_temp =
 						resp->on_die_temperature;
 		} else {
 			adapter->be_get_temp_freq = 0;
+			adapter->hwmon_info.be_on_die_temp =
+						BE_INVALID_DIE_TEMP;
 		}
 		return;
 	}
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 9124a93..675cbac 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -123,7 +123,6 @@ static const struct be_ethtool_stat et_stats[] = {
 	{DRVSTAT_INFO(dma_map_errors)},
 	/* Number of packets dropped due to random early drop function */
 	{DRVSTAT_INFO(eth_red_drops)},
-	{DRVSTAT_INFO(be_on_die_temperature)},
 	{DRVSTAT_INFO(rx_roce_bytes_lsd)},
 	{DRVSTAT_INFO(rx_roce_bytes_msd)},
 	{DRVSTAT_INFO(rx_roce_frames)},
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f15a3cf..b4cea55 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5470,6 +5470,30 @@ static void be_remove(struct pci_dev *pdev)
 	free_netdev(adapter->netdev);
 }
 
+ssize_t be_hwmon_show_temp(struct device *dev,
+			   struct device_attribute *dev_attr,
+			   char *buf)
+{
+	struct be_adapter *adapter = dev_get_drvdata(dev);
+
+	/* Unit: millidegree Celsius */
+	if (adapter->hwmon_info.be_on_die_temp == BE_INVALID_DIE_TEMP)
+		return -EIO;
+	else
+		return sprintf(buf, "%u\n",
+			       adapter->hwmon_info.be_on_die_temp * 1000);
+}
+
+static SENSOR_DEVICE_ATTR(temp1_input, S_IRUGO,
+			  be_hwmon_show_temp, NULL, 1);
+
+static struct attribute *be_hwmon_attrs[] = {
+	&sensor_dev_attr_temp1_input.dev_attr.attr,
+	NULL
+};
+
+ATTRIBUTE_GROUPS(be_hwmon);
+
 static char *mc_name(struct be_adapter *adapter)
 {
 	char *str = "";	/* default */
@@ -5589,6 +5613,16 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 
 	be_schedule_err_detection(adapter);
 
+	/* On Die temperature not supported for VF. */
+	if (be_physfn(adapter)) {
+		adapter->hwmon_info.hwmon_dev =
+			devm_hwmon_device_register_with_groups(&pdev->dev,
+							       DRV_NAME,
+							       adapter,
+							       be_hwmon_groups);
+		adapter->hwmon_info.be_on_die_temp = BE_INVALID_DIE_TEMP;
+	}
+
 	dev_info(&pdev->dev, "%s: %s %s port %c\n", nic_name(pdev),
 		 func_name(adapter), mc_name(adapter), adapter->port_name);
 
-- 
1.7.1
