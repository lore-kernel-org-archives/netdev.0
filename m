From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 -next 3/4] tg3: Add hwmon support
Date: Tue, 26 Jun 2012 17:53:34 -0700
Message-ID: <1340758415-10746-3-git-send-email-mchan@broadcom.com>
References: <1340758415-10746-1-git-send-email-mchan@broadcom.com>
 <1340758415-10746-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3158 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755275Ab2F0Amd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 20:42:33 -0400
In-Reply-To: <1340758415-10746-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some tg3 devices have management firmware that can export sensor data such
as temperature and other real time diagnostics data.  Export temperature
sensor reading via hwmon sysfs.

[hwmon interface suggested by Ben Hutchings <bhutchings@solarflare.com>]

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  189 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/tg3.h |   63 ++++++++++++
 2 files changed, 252 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 693a584..6b51e3a 100644
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
@@ -9538,6 +9542,182 @@ static int tg3_init_hw(struct tg3 *tp, int reset_phy)
 	return tg3_reset_hw(tp, reset_phy);
 }
 
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
+#if IS_ENABLED(CONFIG_HWMON)
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
+#define TG3_TEMP_SENSOR_OFFSET 0xd4
+static SENSOR_DEVICE_ATTR(temp1_input, S_IRUGO, tg3_show_temp, NULL,
+			  TG3_TEMP_SENSOR_OFFSET);
+static struct attribute *tg3_attributes[] = {
+	&sensor_dev_attr_temp1_input.dev_attr.attr,
+	NULL
+};
+
+static const struct attribute_group tg3_group = {
+	.attrs = tg3_attributes,
+};
+
+static void tg3_hwmon_open(struct tg3 *tp)
+{
+	int err;
+	struct tg3_sd *sd = tp->sd;
+	struct pci_dev *pdev = tp->pdev;
+
+	/* Register hwmon sysfs hooks */
+	err = sysfs_create_group(&pdev->dev.kobj, &tg3_group);
+	if (err) {
+		dev_err(&pdev->dev, "Cannot create sysfs group, aborting\n");
+		return;
+	}
+
+	sd->hwmon_dev = hwmon_device_register(&pdev->dev);
+	if (IS_ERR(sd->hwmon_dev)) {
+		sd->hwmon_dev = NULL;
+		dev_err(&pdev->dev, "Cannot register hwmon device, aborting\n");
+		sysfs_remove_group(&pdev->dev.kobj, &tg3_group);
+	}
+}
+#endif
+
+static int tg3_sd_init(struct tg3 *tp)
+{
+	int i;
+	u32 size = 0;
+	struct tg3_sd *sd;
+	struct tg3_ocir ocirs[TG3_SD_NUM_RECS];
+
+	if (!tg3_flag(tp, ENABLE_APE))
+		return 0;
+
+	tp->sd = kzalloc(sizeof(struct tg3_sd), GFP_KERNEL);
+	if (!tp->sd)
+		return -ENOMEM;
+
+	sd = tp->sd;
+	tg3_sd_scan_scratchpad(tp, ocirs);
+
+	for (i = 0; i < TG3_SD_NUM_RECS; i++) {
+		u32 val = 1;
+		struct tg3_sd_record *rec = &sd->rec[i];
+
+		if (!ocirs[i].src_data_length)
+			continue;
+
+		rec->hdr_len = ocirs[i].src_hdr_length;
+		rec->hdr_off = ocirs[i].src_hdr_offset;
+		rec->data_len = ocirs[i].src_data_length;
+		rec->data_off = ocirs[i].src_data_offset;
+
+		size += ocirs[i].src_hdr_length;
+		size += ocirs[i].src_data_length;
+
+		rec->utmr_off = i * TG3_OCIR_LEN + TG3_OCIR_UPDATE_TMR_OFF;
+		rec->rtmr_off = i * TG3_OCIR_LEN + TG3_OCIR_REFRESH_TMR_OFF;
+		rec->rtmr_int = ocirs[i].refresh_int;
+
+		/* Initialize utmr_off to non-zero so that we read the region
+		 * at least once */
+		if (tg3_ape_scratchpad_write(tp, rec->utmr_off, &val, 4))
+			netdev_err(tp->dev, "write scratchpad error\n");
+
+		ocirs[i].update_tmr = 0;
+	}
+	if (!size) {
+		kfree(sd);
+		tp->sd = NULL;
+		return -ENODEV;
+	}
+
+	size += sizeof(ocirs);
+
+	sd->buf = kzalloc(size, GFP_KERNEL);
+	if (!sd->buf) {
+		kfree(sd);
+		tp->sd = NULL;
+		return -ENOMEM;
+	}
+
+	sd->buf_size = size;
+	memcpy(sd->buf, ocirs, sizeof(ocirs));
+
+	sd->sd_flags_off = 2 * TG3_OCIR_LEN + (tp->pci_fn * sizeof(u32)) +
+				TG3_OCIR_PORT0_FLGS_OFF;
+
+	return 0;
+}
+
+static void tg3_sd_fini(struct tg3 *tp)
+{
+	struct tg3_sd *sd = tp->sd;
+
+	if (!sd)
+		return;
+
+	kfree(sd->buf);
+	kfree(sd);
+	tp->sd = NULL;
+}
+
+static void tg3_sd_close(struct tg3 *tp)
+{
+	struct tg3_sd *sd = tp->sd;
+
+	if (!sd)
+		return;
+
+#if IS_ENABLED(CONFIG_HWMON)
+	if (sd->hwmon_dev) {
+		hwmon_device_unregister(sd->hwmon_dev);
+		sd->hwmon_dev = NULL;
+		sysfs_remove_group(&tp->pdev->dev.kobj, &tg3_group);
+	}
+#endif
+}
+
+static int tg3_sd_open(struct tg3 *tp)
+{
+	struct tg3_sd *sd = tp->sd;
+
+	if (!sd)
+		return -ENODEV;
+
+#if IS_ENABLED(CONFIG_HWMON)
+	tg3_hwmon_open(tp);
+#endif
+	return 0;
+}
+
 #define TG3_STAT_ADD32(PSTAT, REG) \
 do {	u32 __val = tr32(REG); \
 	(PSTAT)->low += __val; \
@@ -10246,6 +10426,8 @@ static int tg3_open(struct net_device *dev)
 
 	tg3_phy_start(tp);
 
+	tg3_sd_open(tp);
+
 	tg3_full_lock(tp, 0);
 
 	tg3_timer_start(tp);
@@ -10295,6 +10477,8 @@ static int tg3_close(struct net_device *dev)
 
 	tg3_timer_stop(tp);
 
+	tg3_sd_close(tp);
+
 	tg3_phy_stop(tp);
 
 	tg3_full_lock(tp, 1);
@@ -15945,6 +16129,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	tg3_timer_init(tp);
 
+	tg3_sd_init(tp);
+
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting\n");
@@ -16039,6 +16225,9 @@ static void __devexit tg3_remove_one(struct pci_dev *pdev)
 		}
 
 		unregister_netdev(dev);
+
+		tg3_sd_fini(tp);
+
 		if (tp->aperegs) {
 			iounmap(tp->aperegs);
 			tp->aperegs = NULL;
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index d167a1c..a3a51c9 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2379,6 +2379,18 @@
 #define TG3_APE_LOCK_PHY3		5
 #define TG3_APE_LOCK_GPIO		7
 
+/* SD flags */
+#define TG3_OCIR_SIG_MAGIC		0x5253434f
+#define TG3_OCIR_FLAG_ACTIVE		0x00000001
+
+#define TG3_OCIR_DRVR_FEAT_CSUM		0x00000001
+#define TG3_OCIR_DRVR_FEAT_TSO		0x00000002
+#define TG3_OCIR_DRVR_FEAT_MASK		0xff
+
+#define TG3_OCIR_REFRESH_TMR_OFF	0x00000008
+#define TG3_OCIR_UPDATE_TMR_OFF		0x0000000c
+#define TG3_OCIR_PORT0_FLGS_OFF		0x0000002c
+
 #define TG3_EEPROM_SB_F1R2_MBA_OFF	0x10
 
 
@@ -2677,6 +2689,55 @@ struct tg3_hw_stats {
 	u8				__reserved4[0xb00-0x9c8];
 };
 
+#define TG3_SD_NUM_RECS			3
+#define TG3_OCIR_LEN			(sizeof(struct tg3_ocir))
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
+struct tg3_sd_record {
+	u16				hdr_off;
+	u16				hdr_len;
+	u16				data_off;
+	u16				data_len;
+	u32				updated_seq;
+	u16				utmr_off;
+	u16				rtmr_off;
+	u32				rtmr_val;
+	u16				rtmr_int;
+};
+
+struct tg3_sd {
+#if IS_ENABLED(CONFIG_HWMON)
+	struct device			*hwmon_dev;
+#endif
+	struct tg3_sd_record		rec[TG3_SD_NUM_RECS];
+	u32				sd_flags_off;
+	int				buf_size;
+	u8				*buf;
+};
+
 /* 'mapping' is superfluous as the chip does not write into
  * the tx/rx post rings so we could just fetch it from there.
  * But the cache behavior is better how we are doing it now.
@@ -3212,6 +3273,8 @@ struct tg3 {
 	const char			*fw_needed;
 	const struct firmware		*fw;
 	u32				fw_len; /* includes BSS */
+
+	struct tg3_sd			*sd;
 };
 
 #endif /* !(_T3_H) */
-- 
1.7.1
