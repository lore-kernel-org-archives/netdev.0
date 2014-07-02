From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH v2 net-next 01/13] mac802154: at86rf230: add hw flags and merge ops
Date: Wed,  2 Jul 2014 17:09:58 +0200
Message-ID: <1404313810-30232-2-git-send-email-alex.aring@gmail.com>
References: <1404313810-30232-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, stilwellt@openlabs.co,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:34158 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718AbaGBPKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 11:10:20 -0400
Received: by mail-wi0-f182.google.com with SMTP id bs8so688427wib.9
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 08:10:19 -0700 (PDT)
In-Reply-To: <1404313810-30232-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds new mac802154 hw flags for transmit power, csma and
listen before transmit (lbt). These flags indicates that the transceiver
supports these features. If the flags are set and the driver doesn't
implement the necessary functions, then ieee802154_register_device
returns -ENOSYS "Function not implemented".

This patch merges also all at86rf230 operations into one operations structure
and set the right hw flags for the at86rf230 transceivers.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 81 +++++++++++++++++---------------------
 include/net/mac802154.h            | 19 +++++++++
 net/mac802154/ieee802154_dev.c     | 60 +++++++++++++++++++++-------
 3 files changed, 102 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 5089941..dca6bae 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -784,7 +784,7 @@ at86rf230_set_hw_addr_filt(struct ieee802154_dev *dev,
 }
 
 static int
-at86rf212_set_txpower(struct ieee802154_dev *dev, int db)
+at86rf230_set_txpower(struct ieee802154_dev *dev, int db)
 {
 	struct at86rf230_local *lp = dev->priv;
 
@@ -803,7 +803,7 @@ at86rf212_set_txpower(struct ieee802154_dev *dev, int db)
 }
 
 static int
-at86rf212_set_lbt(struct ieee802154_dev *dev, bool on)
+at86rf230_set_lbt(struct ieee802154_dev *dev, bool on)
 {
 	struct at86rf230_local *lp = dev->priv;
 
@@ -811,7 +811,7 @@ at86rf212_set_lbt(struct ieee802154_dev *dev, bool on)
 }
 
 static int
-at86rf212_set_cca_mode(struct ieee802154_dev *dev, u8 mode)
+at86rf230_set_cca_mode(struct ieee802154_dev *dev, u8 mode)
 {
 	struct at86rf230_local *lp = dev->priv;
 
@@ -819,7 +819,7 @@ at86rf212_set_cca_mode(struct ieee802154_dev *dev, u8 mode)
 }
 
 static int
-at86rf212_set_cca_ed_level(struct ieee802154_dev *dev, s32 level)
+at86rf230_set_cca_ed_level(struct ieee802154_dev *dev, s32 level)
 {
 	struct at86rf230_local *lp = dev->priv;
 	int desens_steps;
@@ -833,7 +833,7 @@ at86rf212_set_cca_ed_level(struct ieee802154_dev *dev, s32 level)
 }
 
 static int
-at86rf212_set_csma_params(struct ieee802154_dev *dev, u8 min_be, u8 max_be,
+at86rf230_set_csma_params(struct ieee802154_dev *dev, u8 min_be, u8 max_be,
 			  u8 retries)
 {
 	struct at86rf230_local *lp = dev->priv;
@@ -854,7 +854,7 @@ at86rf212_set_csma_params(struct ieee802154_dev *dev, u8 min_be, u8 max_be,
 }
 
 static int
-at86rf212_set_frame_retries(struct ieee802154_dev *dev, s8 retries)
+at86rf230_set_frame_retries(struct ieee802154_dev *dev, s8 retries)
 {
 	struct at86rf230_local *lp = dev->priv;
 	int rc = 0;
@@ -878,22 +878,12 @@ static struct ieee802154_ops at86rf230_ops = {
 	.start = at86rf230_start,
 	.stop = at86rf230_stop,
 	.set_hw_addr_filt = at86rf230_set_hw_addr_filt,
-};
-
-static struct ieee802154_ops at86rf212_ops = {
-	.owner = THIS_MODULE,
-	.xmit = at86rf230_xmit,
-	.ed = at86rf230_ed,
-	.set_channel = at86rf230_channel,
-	.start = at86rf230_start,
-	.stop = at86rf230_stop,
-	.set_hw_addr_filt = at86rf230_set_hw_addr_filt,
-	.set_txpower = at86rf212_set_txpower,
-	.set_lbt = at86rf212_set_lbt,
-	.set_cca_mode = at86rf212_set_cca_mode,
-	.set_cca_ed_level = at86rf212_set_cca_ed_level,
-	.set_csma_params = at86rf212_set_csma_params,
-	.set_frame_retries = at86rf212_set_frame_retries,
+	.set_txpower = at86rf230_set_txpower,
+	.set_lbt = at86rf230_set_lbt,
+	.set_cca_mode = at86rf230_set_cca_mode,
+	.set_cca_ed_level = at86rf230_set_cca_ed_level,
+	.set_csma_params = at86rf230_set_csma_params,
+	.set_frame_retries = at86rf230_set_frame_retries,
 };
 
 static void at86rf230_irqwork(struct work_struct *work)
@@ -1048,7 +1038,6 @@ static int at86rf230_probe(struct spi_device *spi)
 	work_func_t irq_worker;
 	int rc, irq_type;
 	const char *chip;
-	struct ieee802154_ops *ops = NULL;
 
 	if (!spi->irq) {
 		dev_err(&spi->dev, "no IRQ specified\n");
@@ -1084,9 +1073,25 @@ static int at86rf230_probe(struct spi_device *spi)
 		usleep_range(120, 240);
 	}
 
+	dev = ieee802154_alloc_device(sizeof(*lp), &at86rf230_ops);
+	if (!dev)
+		return -ENOMEM;
+
+	lp = dev->priv;
+	lp->dev = dev;
+	lp->part = part;
+	lp->vers = version;
+
+	lp->spi = spi;
+
+	dev->parent = &spi->dev;
+	dev->extra_tx_headroom = 0;
+	dev->flags = IEEE802154_HW_OMIT_CKSUM | IEEE802154_HW_AACK |
+		     IEEE802154_HW_TXPOWER | IEEE802154_HW_CSMA;
+
 	rc = __at86rf230_detect_device(spi, &man_id, &part, &version);
 	if (rc < 0)
-		return rc;
+		goto free_dev;
 
 	if (man_id != 0x001f) {
 		dev_err(&spi->dev, "Non-Atmel dev found (MAN_ID %02x %02x)\n",
@@ -1097,44 +1102,31 @@ static int at86rf230_probe(struct spi_device *spi)
 	switch (part) {
 	case 2:
 		chip = "at86rf230";
+		rc = -ENOTSUPP;
 		/* FIXME: should be easy to support; */
 		break;
 	case 3:
 		chip = "at86rf231";
-		ops = &at86rf230_ops;
 		break;
 	case 7:
 		chip = "at86rf212";
 		if (version == 1)
-			ops = &at86rf212_ops;
+			dev->flags |= IEEE802154_HW_LBT;
+		else
+			rc = -ENOTSUPP;
 		break;
 	case 11:
 		chip = "at86rf233";
-		ops = &at86rf230_ops;
 		break;
 	default:
 		chip = "UNKNOWN";
+		rc = -ENOTSUPP;
 		break;
 	}
 
 	dev_info(&spi->dev, "Detected %s chip version %d\n", chip, version);
-	if (!ops)
-		return -ENOTSUPP;
-
-	dev = ieee802154_alloc_device(sizeof(*lp), ops);
-	if (!dev)
-		return -ENOMEM;
-
-	lp = dev->priv;
-	lp->dev = dev;
-	lp->part = part;
-	lp->vers = version;
-
-	lp->spi = spi;
-
-	dev->parent = &spi->dev;
-	dev->extra_tx_headroom = 0;
-	dev->flags = IEEE802154_HW_OMIT_CKSUM | IEEE802154_HW_AACK;
+	if (rc < 0)
+		goto free_dev;
 
 	irq_type = irq_get_trigger_type(spi->irq);
 	if (!irq_type)
@@ -1185,6 +1177,7 @@ static int at86rf230_probe(struct spi_device *spi)
 err_hw_init:
 	flush_work(&lp->irqwork);
 	mutex_destroy(&lp->bmux);
+free_dev:
 	ieee802154_free_device(lp->dev);
 
 	return rc;
diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index a591053..2e67cdd 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -80,6 +80,25 @@ struct ieee802154_dev {
 #define	IEEE802154_HW_OMIT_CKSUM	0x00000001
 /* Indicates that receiver will autorespond with ACK frames. */
 #define	IEEE802154_HW_AACK		0x00000002
+/* Indicates that transceiver will support transmit power setting. */
+#define	IEEE802154_HW_TXPOWER		0x00000004
+/* Indicates that transceiver will support listen before transmit. */
+#define	IEEE802154_HW_LBT		0x00000008
+/* Indicates that transceiver will support cca mode setting. */
+#define	IEEE802154_HW_CCA_MODE		0x00000010
+/* Indicates that transceiver will support cca ed level setting. */
+#define	IEEE802154_HW_CCA_ED_LEVEL	0x00000020
+/* Indicates that transceiver will support csma (max_be, min_be, csma retries)
+ * settings. */
+#define	IEEE802154_HW_CSMA_PARAMS	0x00000040
+/* Indicates that transceiver will support ARET frame retries setting. */
+#define	IEEE802154_HW_FRAME_RETRIES	0x00000080
+
+/* This groups the most common CSMA support fields into one. */
+#define IEEE802154_HW_CSMA		(IEEE802154_HW_CCA_MODE | \
+					 IEEE802154_HW_CCA_ED_LEVEL | \
+					 IEEE802154_HW_CSMA_PARAMS | \
+					 IEEE802154_HW_FRAME_RETRIES)
 
 /* struct ieee802154_ops - callbacks from mac802154 to the driver
  *
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 2cf66d8..0e7befc 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -302,29 +302,61 @@ EXPORT_SYMBOL(ieee802154_free_device);
 int ieee802154_register_device(struct ieee802154_dev *dev)
 {
 	struct mac802154_priv *priv = mac802154_to_priv(dev);
-	int rc = -ENOMEM;
+	int rc = -ENOSYS;
+
+	if (dev->flags & IEEE802154_HW_TXPOWER) {
+		if (!priv->ops->set_txpower)
+			goto out;
+
+		priv->phy->set_txpower = mac802154_set_txpower;
+	}
+
+	if (dev->flags & IEEE802154_HW_LBT) {
+		if (!priv->ops->set_lbt)
+			goto out;
+
+		priv->phy->set_lbt = mac802154_set_lbt;
+	}
+
+	if (dev->flags & IEEE802154_HW_CCA_MODE) {
+		if (!priv->ops->set_cca_mode)
+			goto out;
+
+		priv->phy->set_cca_mode = mac802154_set_cca_mode;
+	}
+
+	if (dev->flags & IEEE802154_HW_CCA_ED_LEVEL) {
+		if (!priv->ops->set_cca_ed_level)
+			goto out;
+
+		priv->phy->set_cca_ed_level = mac802154_set_cca_ed_level;
+	}
+
+	if (dev->flags & IEEE802154_HW_CSMA_PARAMS) {
+		if (!priv->ops->set_csma_params)
+			goto out;
+
+		priv->phy->set_csma_params = mac802154_set_csma_params;
+	}
+
+	if (dev->flags & IEEE802154_HW_FRAME_RETRIES) {
+		if (!priv->ops->set_frame_retries)
+			goto out;
+
+		priv->phy->set_frame_retries = mac802154_set_frame_retries;
+	}
 
 	priv->dev_workqueue =
 		create_singlethread_workqueue(wpan_phy_name(priv->phy));
-	if (!priv->dev_workqueue)
+	if (!priv->dev_workqueue) {
+		rc = -ENOMEM;
 		goto out;
+	}
 
 	wpan_phy_set_dev(priv->phy, priv->hw.parent);
 
 	priv->phy->add_iface = mac802154_add_iface;
 	priv->phy->del_iface = mac802154_del_iface;
-	if (priv->ops->set_txpower)
-		priv->phy->set_txpower = mac802154_set_txpower;
-	if (priv->ops->set_lbt)
-		priv->phy->set_lbt = mac802154_set_lbt;
-	if (priv->ops->set_cca_mode)
-		priv->phy->set_cca_mode = mac802154_set_cca_mode;
-	if (priv->ops->set_cca_ed_level)
-		priv->phy->set_cca_ed_level = mac802154_set_cca_ed_level;
-	if (priv->ops->set_csma_params)
-		priv->phy->set_csma_params = mac802154_set_csma_params;
-	if (priv->ops->set_frame_retries)
-		priv->phy->set_frame_retries = mac802154_set_frame_retries;
 
 	rc = wpan_phy_register(priv->phy);
 	if (rc < 0)
-- 
2.0.1
