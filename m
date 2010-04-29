From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 07/13] KSZ8851-SNL: Add ethtool support for EEPROM
Date: Fri, 30 Apr 2010 00:16:28 +0100
Message-ID: <20100429231740.237072315@fluff.org.uk>
References: <20100429231621.015936077@fluff.org.uk>
Cc: tristram.ha@micrel.com, support@tincantools.com,
	Simtec Linux Team <linux@simtec.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:27351 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932451Ab0D3Vsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 17:48:32 -0400
Content-Disposition: inline; filename=ks8851-add-eeprom-ethtool.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ethtool EEPROM read/write support for the KS8851 driver.

Depends on eeprom_93cx6 driver getting EEPROM write support.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>
Signed-off-by: Simtec Linux Team <linux@simtec.co.uk>

---
 drivers/net/Kconfig  |    1 
 drivers/net/ks8851.c |  149 +++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ks8851.h |    1 
 3 files changed, 151 insertions(+)

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2010-04-29 01:01:31.118391091 +0900
+++ b/drivers/net/ks8851.c	2010-04-29 01:22:42.667052653 +0900
@@ -19,6 +19,7 @@
 #include <linux/cache.h>
 #include <linux/crc32.h>
 #include <linux/mii.h>
+#include <linux/eeprom_93cx6.h>
 
 #include <linux/spi/spi.h>
 
@@ -78,6 +79,7 @@ union ks8851_tx_hdr {
  * @rc_ier: Cached copy of KS_IER.
  * @rc_ccr: Cached copy of KS_CCR.
  * @rc_rxqcr: Cached copy of KS_RXQCR.
+ * @eeprom: 93CX6 EEPROM state for accessing on-board EEPROM.
  *
  * The @lock ensures that the chip is protected when certain operations are
  * in progress. When the read or write packet transfer is in progress, most
@@ -125,6 +127,8 @@ struct ks8851_net {
 	struct spi_message	spi_msg2;
 	struct spi_transfer	spi_xfer1;
 	struct spi_transfer	spi_xfer2[2];
+
+	struct eeprom_93cx6	eeprom;
 };
 
 static int msg_enable;
@@ -1149,6 +1153,141 @@ static int ks8851_nway_reset(struct net_
 	return mii_nway_restart(&ks->mii);
 }
 
+/* EEPROM support */
+
+static void ks8851_eeprom_regread(struct eeprom_93cx6 *ee)
+{
+	struct ks8851_net *ks = ee->data;
+	unsigned val;
+
+	val = ks8851_rdreg16(ks, KS_EEPCR);
+
+	ee->reg_data_out = (val & EEPCR_EESB) ? 1 : 0;
+	ee->reg_data_clock = (val & EEPCR_EESCK) ? 1 : 0;
+	ee->reg_chip_select = (val & EEPCR_EECS) ? 1 : 0;
+}
+
+static void ks8851_eeprom_regwrite(struct eeprom_93cx6 *ee)
+{
+	struct ks8851_net *ks = ee->data;
+	unsigned val = EEPCR_EESA;	/* default - eeprom access on */
+
+	if (ee->drive_data)
+		val |= EEPRC_EESRW;
+	if (ee->reg_data_in)
+		val |= EEPCR_EEDO;
+	if (ee->reg_data_clock)
+		val |= EEPCR_EESCK;
+	if (ee->reg_chip_select)
+		val |= EEPCR_EECS;
+
+	printk(KERN_INFO "%s: wr %04x\n", __func__, val);
+	ks8851_wrreg16(ks, KS_EEPCR, val);
+}
+
+/**
+ * ks8851_eeprom_claim - claim device EEPROM and activate the interface
+ * @ks: The network deice state.
+ *
+ * Check for the presence of an EEPROM, and then activate software access
+ * to the device.
+ */
+static int ks8851_eeprom_claim(struct ks8851_net *ks)
+{
+	if (!(ks->rc_ccr & CCR_EEPROM))
+		return -ENOENT;
+
+	/* start with clock low, cs high */
+	ks8851_wrreg16(ks, KS_EEPCR, EEPCR_EESA | EEPCR_EECS);
+	return 0;
+}
+
+/**
+ * ks8851_eeprom_release - release the EEPROM interface
+ * @ks: The device state
+ *
+ * Release the software access to the device EEPROM
+ */
+static void ks8851_eeprom_release(struct ks8851_net *ks)
+{
+	unsigned val = ks8851_rdreg16(ks,KS_EEPCR);
+
+	ks8851_wrreg16(ks, KS_EEPCR, val & ~EEPCR_EESA);
+}
+
+#define KS_EEPROM_MAGIC (0x00008851)
+
+static int ks8851_set_eeprom(struct net_device *dev,
+			     struct ethtool_eeprom *ee, u8 *data)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+	int offset = ee->offset;
+	int len = ee->len;
+	u16 tmp;
+
+	/* currently only support byte writing */
+	if (len != 1)
+		return -EINVAL;
+
+	if (ee->magic != KS_EEPROM_MAGIC)
+		return -EINVAL;
+
+	if (ks8851_eeprom_claim(ks))
+		return -ENOENT;
+
+	eeprom_93cx6_wren(&ks->eeprom, true);
+
+	/* ethtool currently only supports writing bytes, which means
+	 * we have to read/modify/write our 16bit EEPROMs */
+
+	eeprom_93cx6_read(&ks->eeprom, offset/2, &tmp);
+
+	if (offset & 1) {
+		tmp &= 0xff;
+		tmp |= *data << 8;
+	} else {
+		tmp &= 0xff00;
+		tmp |= *data;
+	}
+
+	eeprom_93cx6_write(&ks->eeprom, offset/2, tmp);
+	eeprom_93cx6_wren(&ks->eeprom, false);
+
+	ks8851_eeprom_release(ks);
+
+	return 0;
+}
+
+static int ks8851_get_eeprom(struct net_device *dev,
+			     struct ethtool_eeprom *ee, u8 *data)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+	int offset = ee->offset;
+	int len = ee->len;
+
+	/* must be 2 byte aligned */
+	if (len & 1 || offset & 1)
+		return -EINVAL;
+
+	if (ks8851_eeprom_claim(ks))
+		return -ENOENT;
+
+	ee->magic = KS_EEPROM_MAGIC;
+
+	eeprom_93cx6_multiread(&ks->eeprom, offset/2, (__le16 *)data, len/2);
+	ks8851_eeprom_release(ks);
+
+	return 0;
+}
+
+static int ks8851_get_eeprom_len(struct net_device *dev)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+
+	/* currently, we assume it is an 93C46 attached, so return 128 */
+	return ks->rc_ccr & CCR_EEPROM ? 128 : 0;
+}
+
 static const struct ethtool_ops ks8851_ethtool_ops = {
 	.get_drvinfo	= ks8851_get_drvinfo,
 	.get_msglevel	= ks8851_get_msglevel,
@@ -1157,6 +1296,9 @@ static const struct ethtool_ops ks8851_e
 	.set_settings	= ks8851_set_settings,
 	.get_link	= ks8851_get_link,
 	.nway_reset	= ks8851_nway_reset,
+	.get_eeprom_len = ks8851_get_eeprom_len,
+	.get_eeprom	= ks8851_get_eeprom,
+	.set_eeprom	= ks8851_set_eeprom,
 };
 
 /* MII interface controls */
@@ -1305,6 +1447,13 @@ static int __devinit ks8851_probe(struct
 	spi_message_add_tail(&ks->spi_xfer2[0], &ks->spi_msg2);
 	spi_message_add_tail(&ks->spi_xfer2[1], &ks->spi_msg2);
 
+	/* setup EEPROM state */
+
+	ks->eeprom.data = ks;
+	ks->eeprom.width = PCI_EEPROM_WIDTH_93C46;
+	ks->eeprom.register_read = ks8851_eeprom_regread;
+	ks->eeprom.register_write = ks8851_eeprom_regwrite;
+
 	/* setup mii state */
 	ks->mii.dev		= ndev;
 	ks->mii.phy_id		= 1,
Index: b/drivers/net/Kconfig
===================================================================
--- a/drivers/net/Kconfig	2010-04-28 23:24:20.657052849 +0900
+++ b/drivers/net/Kconfig	2010-04-29 01:22:42.667052653 +0900
@@ -1766,6 +1766,7 @@ config KS8851
        depends on SPI
        select MII
 	select CRC32
+	select EEPROM_93CX6
        help
          SPI driver for Micrel KS8851 SPI attached network chip.
 
Index: b/drivers/net/ks8851.h
===================================================================
--- a/drivers/net/ks8851.h	2010-04-29 01:00:35.029526937 +0900
+++ b/drivers/net/ks8851.h	2010-04-29 01:22:42.667052653 +0900
@@ -25,6 +25,7 @@
 #define OBCR_ODS_16mA				(1 << 6)
 
 #define KS_EEPCR				0x22
+#define EEPRC_EESRW				(1 << 5)
 #define EEPCR_EESA				(1 << 4)
 #define EEPCR_EESB				(1 << 3)
 #define EEPCR_EEDO				(1 << 2)

