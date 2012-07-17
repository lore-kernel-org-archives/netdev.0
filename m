From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/4 v3 net-next] tg3: Add hwmon support for temperature
Date: Mon, 16 Jul 2012 19:24:02 -0700
Message-ID: <1342491842-29818-5-git-send-email-mchan@broadcom.com>
References: <1342491842-29818-1-git-send-email-mchan@broadcom.com>
 <1342491842-29818-2-git-send-email-mchan@broadcom.com>
 <1342491842-29818-3-git-send-email-mchan@broadcom.com>
 <1342491842-29818-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3888 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754319Ab2GQCMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 22:12:30 -0400
In-Reply-To: <1342491842-29818-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some tg3 devices have management firmware that can export sensor data.
Export temperature sensor reading via hwmon sysfs.

[hwmon interface suggested by Ben Hutchings <bhutchings@solarflare.com>]

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  112 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/tg3.h |   38 ++++++++++++
 2 files changed, 150 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 26ca368..fce4c1e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -44,6 +44,10 @@
 #include <linux/prefetch.h>
 #include <linux/dma-mapping.h>
 #include <linux/firmware.h>
+#if IS_ENABLED(CONFIG_HWMON)
+#include <linux/hwmon.h>
+#include <linux/hwmon-sysfs.h>
+#endif
 
 #include <net/checksum.h>
 #include <net/ip.h>
@@ -9481,6 +9485,110 @@ static int tg3_init_hw(struct tg3 *tp, int reset_phy)
 	return tg3_reset_hw(tp, reset_phy);
 }
 
+#if IS_ENABLED(CONFIG_HWMON)
+static void tg3_sd_scan_scratchpad(struct tg3 *tp, struct tg3_ocir *ocir)
+{
+	int i;
+
+	for (i = 0; i < TG3_SD_NUM_RECS; i++, ocir++) {
+		u32 off = i * TG3_OCIR_LEN, len = TG3_OCIR_LEN;
+
+		tg3_ape_scratchpad_read(tp, (u32 *) ocir, off, len);
+		off += len;
+
+		if (ocir->signature != TG3_OCIR_SIG_MAGIC ||
+		    !(ocir->version_flags & TG3_OCIR_FLAG_ACTIVE))
+			memset(ocir, 0, TG3_OCIR_LEN);
+	}
+}
+
+/* sysfs attributes for hwmon */
+static ssize_t tg3_show_temp(struct device *dev,
+			     struct device_attribute *devattr, char *buf)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct tg3 *tp = netdev_priv(netdev);
+	struct sensor_device_attribute *attr = to_sensor_dev_attr(devattr);
+	u32 temperature;
+
+	spin_lock_bh(&tp->lock);
+	tg3_ape_scratchpad_read(tp, &temperature, attr->index,
+				sizeof(temperature));
+	spin_unlock_bh(&tp->lock);
+	return sprintf(buf, "%u\n", temperature);
+}
+
+
+static SENSOR_DEVICE_ATTR(temp1_input, S_IRUGO, tg3_show_temp, NULL,
+			  TG3_TEMP_SENSOR_OFFSET);
+static SENSOR_DEVICE_ATTR(temp1_crit, S_IRUGO, tg3_show_temp, NULL,
+			  TG3_TEMP_CAUTION_OFFSET);
+static SENSOR_DEVICE_ATTR(temp1_max, S_IRUGO, tg3_show_temp, NULL,
+			  TG3_TEMP_MAX_OFFSET);
+
+static struct attribute *tg3_attributes[] = {
+	&sensor_dev_attr_temp1_input.dev_attr.attr,
+	&sensor_dev_attr_temp1_crit.dev_attr.attr,
+	&sensor_dev_attr_temp1_max.dev_attr.attr,
+	NULL
+};
+
+static const struct attribute_group tg3_group = {
+	.attrs = tg3_attributes,
+};
+
+#endif
+
+static void tg3_hwmon_close(struct tg3 *tp)
+{
+#if IS_ENABLED(CONFIG_HWMON)
+	if (tp->hwmon_dev) {
+		hwmon_device_unregister(tp->hwmon_dev);
+		tp->hwmon_dev = NULL;
+		sysfs_remove_group(&tp->pdev->dev.kobj, &tg3_group);
+	}
+#endif
+}
+
+static void tg3_hwmon_open(struct tg3 *tp)
+{
+#if IS_ENABLED(CONFIG_HWMON)
+	int i, err;
+	u32 size = 0;
+	struct pci_dev *pdev = tp->pdev;
+	struct tg3_ocir ocirs[TG3_SD_NUM_RECS];
+
+	tg3_sd_scan_scratchpad(tp, ocirs);
+
+	for (i = 0; i < TG3_SD_NUM_RECS; i++) {
+		if (!ocirs[i].src_data_length)
+			continue;
+
+		size += ocirs[i].src_hdr_length;
+		size += ocirs[i].src_data_length;
+	}
+
+	if (!size)
+		return;
+
+	/* Register hwmon sysfs hooks */
+	err = sysfs_create_group(&pdev->dev.kobj, &tg3_group);
+	if (err) {
+		dev_err(&pdev->dev, "Cannot create sysfs group, aborting\n");
+		return;
+	}
+
+	tp->hwmon_dev = hwmon_device_register(&pdev->dev);
+	if (IS_ERR(tp->hwmon_dev)) {
+		tp->hwmon_dev = NULL;
+		dev_err(&pdev->dev, "Cannot register hwmon device, aborting\n");
+		sysfs_remove_group(&pdev->dev.kobj, &tg3_group);
+	}
+#endif
+}
+
+
 #define TG3_STAT_ADD32(PSTAT, REG) \
 do {	u32 __val = tr32(REG); \
 	(PSTAT)->low += __val; \
@@ -10189,6 +10297,8 @@ static int tg3_open(struct net_device *dev)
 
 	tg3_phy_start(tp);
 
+	tg3_hwmon_open(tp);
+
 	tg3_full_lock(tp, 0);
 
 	tg3_timer_start(tp);
@@ -10238,6 +10348,8 @@ static int tg3_close(struct net_device *dev)
 
 	tg3_timer_stop(tp);
 
+	tg3_hwmon_close(tp);
+
 	tg3_phy_stop(tp);
 
 	tg3_full_lock(tp, 1);
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index f8a0d9c..a1b75cd 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2676,6 +2676,40 @@ struct tg3_hw_stats {
 	u8				__reserved4[0xb00-0x9c8];
 };
 
+#define TG3_SD_NUM_RECS			3
+#define TG3_OCIR_LEN			(sizeof(struct tg3_ocir))
+#define TG3_OCIR_SIG_MAGIC		0x5253434f
+#define TG3_OCIR_FLAG_ACTIVE		0x00000001
+
+#define TG3_TEMP_CAUTION_OFFSET		0xc8
+#define TG3_TEMP_MAX_OFFSET		0xcc
+#define TG3_TEMP_SENSOR_OFFSET		0xd4
+
+
+struct tg3_ocir {
+	u32				signature;
+	u16				version_flags;
+	u16				refresh_int;
+	u32				refresh_tmr;
+	u32				update_tmr;
+	u32				dst_base_addr;
+	u16				src_hdr_offset;
+	u16				src_hdr_length;
+	u16				src_data_offset;
+	u16				src_data_length;
+	u16				dst_hdr_offset;
+	u16				dst_data_offset;
+	u16				dst_reg_upd_offset;
+	u16				dst_sem_offset;
+	u32				reserved1[2];
+	u32				port0_flags;
+	u32				port1_flags;
+	u32				port2_flags;
+	u32				port3_flags;
+	u32				reserved2[1];
+};
+
+
 /* 'mapping' is superfluous as the chip does not write into
  * the tx/rx post rings so we could just fetch it from there.
  * But the cache behavior is better how we are doing it now.
@@ -3211,6 +3245,10 @@ struct tg3 {
 	const char			*fw_needed;
 	const struct firmware		*fw;
 	u32				fw_len; /* includes BSS */
+
+#if IS_ENABLED(CONFIG_HWMON)
+	struct device			*hwmon_dev;
+#endif
 };
 
 #endif /* !(_T3_H) */
-- 
1.7.1
