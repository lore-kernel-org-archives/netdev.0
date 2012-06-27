From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 -next 4/4] tg3: Add binary sysfs file to export bulk
 sensor data
Date: Tue, 26 Jun 2012 17:53:35 -0700
Message-ID: <1340758415-10746-4-git-send-email-mchan@broadcom.com>
References: <1340758415-10746-1-git-send-email-mchan@broadcom.com>
 <1340758415-10746-2-git-send-email-mchan@broadcom.com>
 <1340758415-10746-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3155 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754871Ab2F0Amd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 20:42:33 -0400
In-Reply-To: <1340758415-10746-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bulk of the sensor data is exported as binary data to sysfs for
userspace access.

[binary sysfs suggested by Ben Hutchings <bhutchings@solarflare.com>]

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  130 ++++++++++++++++++++++++++++++++++-
 1 files changed, 129 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 6b51e3a..109a7cb 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9542,6 +9542,48 @@ static int tg3_init_hw(struct tg3 *tp, int reset_phy)
 	return tg3_reset_hw(tp, reset_phy);
 }
 
+static void tg3_sd_xfer(struct tg3 *tp, u32 off, u32 size)
+{
+	struct tg3_sd *sd = tp->sd;
+
+	if (!size)
+		return;
+
+	tg3_ape_scratchpad_read(tp, (u32 *) &sd->buf[off], off, size);
+}
+
+static void tg3_sd_update_host(struct tg3 *tp, struct tg3_sd_record *rec)
+{
+	tg3_sd_xfer(tp, rec->data_off, rec->data_len);
+	tg3_sd_xfer(tp, rec->hdr_off, rec->hdr_len);
+}
+
+static void tg3_sd_update_drvflags(struct tg3 *tp, bool unloading)
+{
+	struct tg3_sd *sd = tp->sd;
+	u32 flags;
+
+	if (!sd || !sd->sd_flags_off)
+		return;
+
+	tg3_ape_scratchpad_read(tp, &flags, sd->sd_flags_off, 4);
+
+	flags &= ~TG3_OCIR_DRVR_FEAT_MASK;
+
+	if (!unloading) {
+		u32 mask = NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
+			   NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM;
+
+		if (tp->dev->features & mask)
+			flags |= TG3_OCIR_DRVR_FEAT_CSUM;
+
+		if (tp->dev->features & NETIF_F_ALL_TSO)
+			flags |= TG3_OCIR_DRVR_FEAT_TSO;
+	}
+
+	tg3_ape_scratchpad_write(tp, sd->sd_flags_off, &flags, 4);
+}
+
 static void tg3_sd_scan_scratchpad(struct tg3 *tp, struct tg3_ocir *ocir)
 {
 	int i;
@@ -9610,6 +9652,32 @@ static void tg3_hwmon_open(struct tg3 *tp)
 }
 #endif
 
+static ssize_t tg3_sd_read(struct file *filep, struct kobject *kobj,
+			   struct bin_attribute *attr, char *buff,
+			   loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct tg3 *tp = netdev_priv(netdev);
+	struct tg3_sd *sd = tp->sd;
+	int len = size < sd->buf_size ? size : sd->buf_size;
+
+	if (offset > sd->buf_size)
+		return 0;
+
+	if (offset + len > sd->buf_size)
+		len = sd->buf_size - offset;
+
+	memcpy(buff, sd->buf + offset, len);
+	return len;
+}
+
+static struct bin_attribute bin_attr_tg3_sd = {
+	.attr = {.name = "tg3_sd", .mode = S_IRUSR},
+	.read = tg3_sd_read,
+};
+
 static int tg3_sd_init(struct tg3 *tp)
 {
 	int i;
@@ -9674,6 +9742,7 @@ static int tg3_sd_init(struct tg3 *tp)
 	sd->sd_flags_off = 2 * TG3_OCIR_LEN + (tp->pci_fn * sizeof(u32)) +
 				TG3_OCIR_PORT0_FLGS_OFF;
 
+	tg3_sd_update_drvflags(tp, false);
 	return 0;
 }
 
@@ -9684,6 +9753,8 @@ static void tg3_sd_fini(struct tg3 *tp)
 	if (!sd)
 		return;
 
+	tg3_sd_update_drvflags(tp, true);
+
 	kfree(sd->buf);
 	kfree(sd);
 	tp->sd = NULL;
@@ -9703,6 +9774,7 @@ static void tg3_sd_close(struct tg3 *tp)
 		sysfs_remove_group(&tp->pdev->dev.kobj, &tg3_group);
 	}
 #endif
+	device_remove_bin_file(&tp->pdev->dev, &bin_attr_tg3_sd);
 }
 
 static int tg3_sd_open(struct tg3 *tp)
@@ -9715,7 +9787,7 @@ static int tg3_sd_open(struct tg3 *tp)
 #if IS_ENABLED(CONFIG_HWMON)
 	tg3_hwmon_open(tp);
 #endif
-	return 0;
+	return device_create_bin_file(&tp->pdev->dev, &bin_attr_tg3_sd);
 }
 
 #define TG3_STAT_ADD32(PSTAT, REG) \
@@ -9803,6 +9875,59 @@ static void tg3_chk_missed_msi(struct tg3 *tp)
 	}
 }
 
+
+static void tg3_sd_timer(struct tg3 *tp)
+{
+	int i;
+	u32 val;
+	struct tg3_sd *sd = tp->sd;
+	struct tg3_ocir *ocirp = (struct tg3_ocir *) sd->buf;
+
+	if (!netif_running(tp->dev))
+		return;
+
+	for (i = 0; i < TG3_SD_NUM_RECS; i++, ocirp++) {
+		struct tg3_sd_record *rec = &sd->rec[i];
+
+		if (!rec->data_len)
+			continue;
+
+		tg3_ape_scratchpad_read(tp, &val, rec->utmr_off, 4);
+		/* Check if data has changed */
+		if (val) {
+
+			if (!rec->rtmr_int) {
+				tg3_sd_update_host(tp, rec);
+
+				rec->updated_seq++;
+				ocirp->update_tmr = rec->updated_seq;
+			} else {
+				u32 curr;
+				unsigned long tgt;
+
+				curr = tg3_ape_read32(tp, TG3_APE_STICKY_TMR);
+				tgt = rec->rtmr_val + rec->rtmr_int;
+				if (time_after((unsigned long) curr, tgt)) {
+					tg3_sd_update_host(tp, rec);
+
+					rec->rtmr_val = curr;
+					tg3_ape_scratchpad_write(tp,
+							rec->rtmr_off,
+							&curr, 4);
+
+					rec->updated_seq++;
+					ocirp->update_tmr = rec->updated_seq;
+				}
+			}
+
+			val = 0;
+			if (tg3_ape_scratchpad_write(tp, rec->utmr_off,
+						     &val, 4))
+				netdev_err(tp->dev, "write scratchpad error\n");
+		}
+	}
+}
+
 static void tg3_timer(unsigned long __opaque)
 {
 	struct tg3 *tp = (struct tg3 *) __opaque;
@@ -9841,6 +9966,9 @@ static void tg3_timer(unsigned long __opaque)
 		if (tg3_flag(tp, 5705_PLUS))
 			tg3_periodic_fetch_stats(tp);
 
+		if (tp->sd)
+			tg3_sd_timer(tp);
+
 		if (tp->setlpicnt && !--tp->setlpicnt)
 			tg3_phy_eee_enable(tp);
 
-- 
1.7.1
