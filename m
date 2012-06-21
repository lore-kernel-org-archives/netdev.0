From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/3 net-next] tg3: Add sysfs file to export sensor data
Date: Wed, 20 Jun 2012 17:06:32 -0700
Message-ID: <1340237192-30052-3-git-send-email-mchan@broadcom.com>
References: <1340237192-30052-1-git-send-email-mchan@broadcom.com>
 <1340237192-30052-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3303 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758619Ab2FTXzo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 19:55:44 -0400
In-Reply-To: <1340237192-30052-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some tg3 devices have management firmware that can export data such as
temperature and other real time diagnostics data.  Export this data to
sysfs so that userspace can access this information.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  241 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/tg3.h |   60 +++++++++
 2 files changed, 301 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e93760c..f6c56ff 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9538,6 +9538,182 @@ static int tg3_init_hw(struct tg3 *tp, int reset_phy)
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
+static ssize_t tg3_sd_read(struct device *dev, struct device_attribute *attr,
+			     char *buff)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct tg3 *tp = netdev_priv(netdev);
+	struct tg3_sd *sd = tp->sd;
+
+	memcpy(buff, sd->buf, sd->buf_size);
+
+	return sd->buf_size;
+}
+
+static DEVICE_ATTR(tg3_sd, 0400, tg3_sd_read, NULL);
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
+	sd->sd_flags_off = 2 * TG3_OCIR_LEN +
+			     (tp->pci_fn * sizeof(u32)) +
+			     TG3_OCIR_PORT0_FLGS_OFF;
+
+	tg3_sd_update_drvflags(tp, false);
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
+	tg3_sd_update_drvflags(tp, true);
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
+	device_remove_file(&tp->pdev->dev, &dev_attr_tg3_sd);
+}
+
+static int tg3_sd_open(struct tg3 *tp)
+{
+	struct tg3_sd *sd = tp->sd;
+
+	if (!sd)
+		return -ENODEV;
+
+	return device_create_file(&tp->pdev->dev, &dev_attr_tg3_sd);
+}
+
 #define TG3_STAT_ADD32(PSTAT, REG) \
 do {	u32 __val = tr32(REG); \
 	(PSTAT)->low += __val; \
@@ -9623,6 +9799,59 @@ static void tg3_chk_missed_msi(struct tg3 *tp)
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
@@ -9661,6 +9890,9 @@ static void tg3_timer(unsigned long __opaque)
 		if (tg3_flag(tp, 5705_PLUS))
 			tg3_periodic_fetch_stats(tp);
 
+		if (tp->sd)
+			tg3_sd_timer(tp);
+
 		if (tp->setlpicnt && !--tp->setlpicnt)
 			tg3_phy_eee_enable(tp);
 
@@ -10246,6 +10478,8 @@ static int tg3_open(struct net_device *dev)
 
 	tg3_phy_start(tp);
 
+	tg3_sd_open(tp);
+
 	tg3_full_lock(tp, 0);
 
 	tg3_timer_start(tp);
@@ -10295,6 +10529,8 @@ static int tg3_close(struct net_device *dev)
 
 	tg3_timer_stop(tp);
 
+	tg3_sd_close(tp);
+
 	tg3_phy_stop(tp);
 
 	tg3_full_lock(tp, 1);
@@ -15945,6 +16181,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	tg3_timer_init(tp);
 
+	tg3_sd_init(tp);
+
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting\n");
@@ -16039,6 +16277,9 @@ static void __devexit tg3_remove_one(struct pci_dev *pdev)
 		}
 
 		unregister_netdev(dev);
+
+		tg3_sd_fini(tp);
+
 		if (tp->aperegs) {
 			iounmap(tp->aperegs);
 			tp->aperegs = NULL;
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index d167a1c..61a8f71 100644
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
 
 
@@ -2677,6 +2689,52 @@ struct tg3_hw_stats {
 	u8				__reserved4[0xb00-0x9c8];
 };
 
+#define TG3_SD_NUM_RECS		3
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
+	struct tg3_sd_record		rec[TG3_SD_NUM_RECS];
+	u32				sd_flags_off;
+	int				buf_size;
+	u8				*buf;
+};
+
 /* 'mapping' is superfluous as the chip does not write into
  * the tx/rx post rings so we could just fetch it from there.
  * But the cache behavior is better how we are doing it now.
@@ -3212,6 +3270,8 @@ struct tg3 {
 	const char			*fw_needed;
 	const struct firmware		*fw;
 	u32				fw_len; /* includes BSS */
+
+	struct tg3_sd			*sd;
 };
 
 #endif /* !(_T3_H) */
-- 
1.7.1
