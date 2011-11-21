From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 5/5] KSZ8851-SNL: Add ethtool support for EEPROM via eeprom_93cx6
Date: Mon, 21 Nov 2011 10:58:00 -0800
Message-ID: <1321901880-12883-6-git-send-email-sboyd@codeaurora.org>
References: <1321901880-12883-1-git-send-email-sboyd@codeaurora.org>
Cc: Ben Dooks <ben@simtec.co.uk>, linux-kernel@vger.kernel.org,
	Sebastien Jan <s-jan@ti.com>,
	Simtec Linux Team <linux@simtec.co.uk>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321901880-12883-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Dooks <ben@simtec.co.uk>

Add ethtool EEPROM read/write support using the eeprom_93cx6
library instead of open-coding the functions.

Depends on eeprom_93cx6 driver getting EEPROM write support.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>
Signed-off-by: Simtec Linux Team <linux@simtec.co.uk>
[sboyd@codeaurora.org: Removed previous eeprom implementation]
Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 drivers/net/ethernet/micrel/Kconfig  |    2 +
 drivers/net/ethernet/micrel/ks8851.c |  425 ++++++++++------------------------
 drivers/net/ethernet/micrel/ks8851.h |   13 +-
 3 files changed, 120 insertions(+), 320 deletions(-)

diff --git a/drivers/net/ethernet/micrel/Kconfig b/drivers/net/ethernet/micrel/Kconfig
index d10c2e1..1ea811c 100644
--- a/drivers/net/ethernet/micrel/Kconfig
+++ b/drivers/net/ethernet/micrel/Kconfig
@@ -42,6 +42,8 @@ config KS8851
 	select NET_CORE
 	select MII
 	select CRC32
+	select MISC_DEVICES
+	select EEPROM_93CX6
 	---help---
 	  SPI driver for Micrel KS8851 SPI attached network chip.
 
diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 208e25a..6b35e7d 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -22,6 +22,7 @@
 #include <linux/cache.h>
 #include <linux/crc32.h>
 #include <linux/mii.h>
+#include <linux/eeprom_93cx6.h>
 
 #include <linux/spi/spi.h>
 
@@ -82,6 +83,7 @@ union ks8851_tx_hdr {
  * @rc_ccr: Cached copy of KS_CCR.
  * @rc_rxqcr: Cached copy of KS_RXQCR.
  * @eeprom_size: Companion eeprom size in Bytes, 0 if no eeprom
+ * @eeprom: 93CX6 EEPROM state for accessing on-board EEPROM.
  *
  * The @lock ensures that the chip is protected when certain operations are
  * in progress. When the read or write packet transfer is in progress, most
@@ -128,6 +130,8 @@ struct ks8851_net {
 	struct spi_message	spi_msg2;
 	struct spi_transfer	spi_xfer1;
 	struct spi_transfer	spi_xfer2[2];
+
+	struct eeprom_93cx6	eeprom;
 };
 
 static int msg_enable;
@@ -1071,234 +1075,6 @@ static const struct net_device_ops ks8851_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-/* Companion eeprom access */
-
-enum {	/* EEPROM programming states */
-	EEPROM_CONTROL,
-	EEPROM_ADDRESS,
-	EEPROM_DATA,
-	EEPROM_COMPLETE
-};
-
-/**
- * ks8851_eeprom_read - read a 16bits word in ks8851 companion EEPROM
- * @dev: The network device the PHY is on.
- * @addr: EEPROM address to read
- *
- * eeprom_size: used to define the data coding length. Can be changed
- * through debug-fs.
- *
- * Programs a read on the EEPROM using ks8851 EEPROM SW access feature.
- * Warning: The READ feature is not supported on ks8851 revision 0.
- *
- * Rough programming model:
- *  - on period start: set clock high and read value on bus
- *  - on period / 2: set clock low and program value on bus
- *  - start on period / 2
- */
-unsigned int ks8851_eeprom_read(struct net_device *dev, unsigned int addr)
-{
-	struct ks8851_net *ks = netdev_priv(dev);
-	int eepcr;
-	int ctrl = EEPROM_OP_READ;
-	int state = EEPROM_CONTROL;
-	int bit_count = EEPROM_OP_LEN - 1;
-	unsigned int data = 0;
-	int dummy;
-	unsigned int addr_len;
-
-	addr_len = (ks->eeprom_size == 128) ? 6 : 8;
-
-	/* start transaction: chip select high, authorize write */
-	mutex_lock(&ks->lock);
-	eepcr = EEPCR_EESA | EEPCR_EESRWA;
-	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
-	eepcr |= EEPCR_EECS;
-	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
-	mutex_unlock(&ks->lock);
-
-	while (state != EEPROM_COMPLETE) {
-		/* falling clock period starts... */
-		/* set EED_IO pin for control and address */
-		eepcr &= ~EEPCR_EEDO;
-		switch (state) {
-		case EEPROM_CONTROL:
-			eepcr |= ((ctrl >> bit_count) & 1) << 2;
-			if (bit_count-- <= 0) {
-				bit_count = addr_len - 1;
-				state = EEPROM_ADDRESS;
-			}
-			break;
-		case EEPROM_ADDRESS:
-			eepcr |= ((addr >> bit_count) & 1) << 2;
-			bit_count--;
-			break;
-		case EEPROM_DATA:
-			/* Change to receive mode */
-			eepcr &= ~EEPCR_EESRWA;
-			break;
-		}
-
-		/* lower clock  */
-		eepcr &= ~EEPCR_EESCK;
-
-		mutex_lock(&ks->lock);
-		ks8851_wrreg16(ks, KS_EEPCR, eepcr);
-		mutex_unlock(&ks->lock);
-
-		/* waitread period / 2 */
-		udelay(EEPROM_SK_PERIOD / 2);
-
-		/* rising clock period starts... */
-
-		/* raise clock */
-		mutex_lock(&ks->lock);
-		eepcr |= EEPCR_EESCK;
-		ks8851_wrreg16(ks, KS_EEPCR, eepcr);
-		mutex_unlock(&ks->lock);
-
-		/* Manage read */
-		switch (state) {
-		case EEPROM_ADDRESS:
-			if (bit_count < 0) {
-				bit_count = EEPROM_DATA_LEN - 1;
-				state = EEPROM_DATA;
-			}
-			break;
-		case EEPROM_DATA:
-			mutex_lock(&ks->lock);
-			dummy = ks8851_rdreg16(ks, KS_EEPCR);
-			mutex_unlock(&ks->lock);
-			data |= ((dummy >> EEPCR_EESB_OFFSET) & 1) << bit_count;
-			if (bit_count-- <= 0)
-				state = EEPROM_COMPLETE;
-			break;
-		}
-
-		/* wait period / 2 */
-		udelay(EEPROM_SK_PERIOD / 2);
-	}
-
-	/* close transaction */
-	mutex_lock(&ks->lock);
-	eepcr &= ~EEPCR_EECS;
-	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
-	eepcr = 0;
-	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
-	mutex_unlock(&ks->lock);
-
-	return data;
-}
-
-/**
- * ks8851_eeprom_write - write a 16bits word in ks8851 companion EEPROM
- * @dev: The network device the PHY is on.
- * @op: operand (can be WRITE, EWEN, EWDS)
- * @addr: EEPROM address to write
- * @data: data to write
- *
- * eeprom_size: used to define the data coding length. Can be changed
- * through debug-fs.
- *
- * Programs a write on the EEPROM using ks8851 EEPROM SW access feature.
- *
- * Note that a write enable is required before writing data.
- *
- * Rough programming model:
- *  - on period start: set clock high
- *  - on period / 2: set clock low and program value on bus
- *  - start on period / 2
- */
-void ks8851_eeprom_write(struct net_device *dev, unsigned int op,
-					unsigned int addr, unsigned int data)
-{
-	struct ks8851_net *ks = netdev_priv(dev);
-	int eepcr;
-	int state = EEPROM_CONTROL;
-	int bit_count = EEPROM_OP_LEN - 1;
-	unsigned int addr_len;
-
-	addr_len = (ks->eeprom_size == 128) ? 6 : 8;
-
-	switch (op) {
-	case EEPROM_OP_EWEN:
-		addr = 0x30;
-	break;
-	case EEPROM_OP_EWDS:
-		addr = 0;
-		break;
-	}
-
-	/* start transaction: chip select high, authorize write */
-	mutex_lock(&ks->lock);
-	eepcr = EEPCR_EESA | EEPCR_EESRWA;
-	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
-	eepcr |= EEPCR_EECS;
-	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
-	mutex_unlock(&ks->lock);
-
-	while (state != EEPROM_COMPLETE) {
-		/* falling clock period starts... */
-		/* set EED_IO pin for control and address */
-		eepcr &= ~EEPCR_EEDO;
-		switch (state) {
-		case EEPROM_CONTROL:
-			eepcr |= ((op >> bit_count) & 1) << 2;
-			if (bit_count-- <= 0) {
-				bit_count = addr_len - 1;
-				state = EEPROM_ADDRESS;
-			}
-			break;
-		case EEPROM_ADDRESS:
-			eepcr |= ((addr >> bit_count) & 1) << 2;
-			if (bit_count-- <= 0) {
-				if (op == EEPROM_OP_WRITE) {
-					bit_count = EEPROM_DATA_LEN - 1;
-					state = EEPROM_DATA;
-				} else {
-					state = EEPROM_COMPLETE;
-				}
-			}
-			break;
-		case EEPROM_DATA:
-			eepcr |= ((data >> bit_count) & 1) << 2;
-			if (bit_count-- <= 0)
-				state = EEPROM_COMPLETE;
-			break;
-		}
-
-		/* lower clock  */
-		eepcr &= ~EEPCR_EESCK;
-
-		mutex_lock(&ks->lock);
-		ks8851_wrreg16(ks, KS_EEPCR, eepcr);
-		mutex_unlock(&ks->lock);
-
-		/* wait period / 2 */
-		udelay(EEPROM_SK_PERIOD / 2);
-
-		/* rising clock period starts... */
-
-		/* raise clock */
-		eepcr |= EEPCR_EESCK;
-		mutex_lock(&ks->lock);
-		ks8851_wrreg16(ks, KS_EEPCR, eepcr);
-		mutex_unlock(&ks->lock);
-
-		/* wait period / 2 */
-		udelay(EEPROM_SK_PERIOD / 2);
-	}
-
-	/* close transaction */
-	mutex_lock(&ks->lock);
-	eepcr &= ~EEPCR_EECS;
-	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
-	eepcr = 0;
-	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
-	mutex_unlock(&ks->lock);
-
-}
-
 /* ethtool support */
 
 static void ks8851_get_drvinfo(struct net_device *dev,
@@ -1345,115 +1121,141 @@ static int ks8851_nway_reset(struct net_device *dev)
 	return mii_nway_restart(&ks->mii);
 }
 
-static int ks8851_get_eeprom_len(struct net_device *dev)
-{
-	struct ks8851_net *ks = netdev_priv(dev);
-	return ks->eeprom_size;
-}
+/* EEPROM support */
 
-static int ks8851_get_eeprom(struct net_device *dev,
-			    struct ethtool_eeprom *eeprom, u8 *bytes)
+static void ks8851_eeprom_regread(struct eeprom_93cx6 *ee)
 {
-	struct ks8851_net *ks = netdev_priv(dev);
-	u16 *eeprom_buff;
-	int first_word;
-	int last_word;
-	int ret_val = 0;
-	u16 i;
-
-	if (eeprom->len == 0)
-		return -EINVAL;
+	struct ks8851_net *ks = ee->data;
+	unsigned val;
 
-	if (eeprom->len > ks->eeprom_size)
-		return -EINVAL;
+	val = ks8851_rdreg16(ks, KS_EEPCR);
 
-	eeprom->magic = ks8851_rdreg16(ks, KS_CIDER);
+	ee->reg_data_out = (val & EEPCR_EESB) ? 1 : 0;
+	ee->reg_data_clock = (val & EEPCR_EESCK) ? 1 : 0;
+	ee->reg_chip_select = (val & EEPCR_EECS) ? 1 : 0;
+}
 
-	first_word = eeprom->offset >> 1;
-	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
+static void ks8851_eeprom_regwrite(struct eeprom_93cx6 *ee)
+{
+	struct ks8851_net *ks = ee->data;
+	unsigned val = EEPCR_EESA;	/* default - eeprom access on */
+
+	if (ee->drive_data)
+		val |= EEPCR_EESRWA;
+	if (ee->reg_data_in)
+		val |= EEPCR_EEDO;
+	if (ee->reg_data_clock)
+		val |= EEPCR_EESCK;
+	if (ee->reg_chip_select)
+		val |= EEPCR_EECS;
+
+	ks8851_wrreg16(ks, KS_EEPCR, val);
+}
 
-	eeprom_buff = kmalloc(sizeof(u16) *
-			(last_word - first_word + 1), GFP_KERNEL);
-	if (!eeprom_buff)
-		return -ENOMEM;
+/**
+ * ks8851_eeprom_claim - claim device EEPROM and activate the interface
+ * @ks: The network device state.
+ *
+ * Check for the presence of an EEPROM, and then activate software access
+ * to the device.
+ */
+static int ks8851_eeprom_claim(struct ks8851_net *ks)
+{
+	if (!(ks->rc_ccr & CCR_EEPROM))
+		return -ENOENT;
 
-	for (i = 0; i < last_word - first_word + 1; i++)
-		eeprom_buff[i] = ks8851_eeprom_read(dev, first_word + 1);
+	mutex_lock(&ks->lock);
 
-	/* Device's eeprom is little-endian, word addressable */
-	for (i = 0; i < last_word - first_word + 1; i++)
-		le16_to_cpus(&eeprom_buff[i]);
+	/* start with clock low, cs high */
+	ks8851_wrreg16(ks, KS_EEPCR, EEPCR_EESA | EEPCR_EECS);
+	return 0;
+}
 
-	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1), eeprom->len);
-	kfree(eeprom_buff);
+/**
+ * ks8851_eeprom_release - release the EEPROM interface
+ * @ks: The device state
+ *
+ * Release the software access to the device EEPROM
+ */
+static void ks8851_eeprom_release(struct ks8851_net *ks)
+{
+	unsigned val = ks8851_rdreg16(ks, KS_EEPCR);
 
-	return ret_val;
+	ks8851_wrreg16(ks, KS_EEPCR, val & ~EEPCR_EESA);
+	mutex_unlock(&ks->lock);
 }
 
+#define KS_EEPROM_MAGIC (0x00008851)
+
 static int ks8851_set_eeprom(struct net_device *dev,
-			    struct ethtool_eeprom *eeprom, u8 *bytes)
+			     struct ethtool_eeprom *ee, u8 *data)
 {
 	struct ks8851_net *ks = netdev_priv(dev);
-	u16 *eeprom_buff;
-	void *ptr;
-	int max_len;
-	int first_word;
-	int last_word;
-	int ret_val = 0;
-	u16 i;
-
-	if (eeprom->len == 0)
-		return -EOPNOTSUPP;
-
-	if (eeprom->len > ks->eeprom_size)
+	int offset = ee->offset;
+	int len = ee->len;
+	u16 tmp;
+
+	/* currently only support byte writing */
+	if (len != 1)
 		return -EINVAL;
 
-	if (eeprom->magic != ks8851_rdreg16(ks, KS_CIDER))
-		return -EFAULT;
+	if (ee->magic != KS_EEPROM_MAGIC)
+		return -EINVAL;
 
-	first_word = eeprom->offset >> 1;
-	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
-	max_len = (last_word - first_word + 1) * 2;
-	eeprom_buff = kmalloc(max_len, GFP_KERNEL);
-	if (!eeprom_buff)
-		return -ENOMEM;
+	if (ks8851_eeprom_claim(ks))
+		return -ENOENT;
+
+	eeprom_93cx6_wren(&ks->eeprom, true);
+
+	/* ethtool currently only supports writing bytes, which means
+	 * we have to read/modify/write our 16bit EEPROMs */
 
-	ptr = (void *)eeprom_buff;
+	eeprom_93cx6_read(&ks->eeprom, offset/2, &tmp);
 
-	if (eeprom->offset & 1) {
-		/* need read/modify/write of first changed EEPROM word */
-		/* only the second byte of the word is being modified */
-		eeprom_buff[0] = ks8851_eeprom_read(dev, first_word);
-		ptr++;
+	if (offset & 1) {
+		tmp &= 0xff;
+		tmp |= *data << 8;
+	} else {
+		tmp &= 0xff00;
+		tmp |= *data;
 	}
-	if ((eeprom->offset + eeprom->len) & 1)
-		/* need read/modify/write of last changed EEPROM word */
-		/* only the first byte of the word is being modified */
-		eeprom_buff[last_word - first_word] =
-					ks8851_eeprom_read(dev, last_word);
 
+	eeprom_93cx6_write(&ks->eeprom, offset/2, tmp);
+	eeprom_93cx6_wren(&ks->eeprom, false);
+
+	ks8851_eeprom_release(ks);
+
+	return 0;
+}
 
-	/* Device's eeprom is little-endian, word addressable */
-	le16_to_cpus(&eeprom_buff[0]);
-	le16_to_cpus(&eeprom_buff[last_word - first_word]);
+static int ks8851_get_eeprom(struct net_device *dev,
+			     struct ethtool_eeprom *ee, u8 *data)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+	int offset = ee->offset;
+	int len = ee->len;
 
-	memcpy(ptr, bytes, eeprom->len);
+	/* must be 2 byte aligned */
+	if (len & 1 || offset & 1)
+		return -EINVAL;
 
-	for (i = 0; i < last_word - first_word + 1; i++)
-		eeprom_buff[i] = cpu_to_le16(eeprom_buff[i]);
+	if (ks8851_eeprom_claim(ks))
+		return -ENOENT;
 
-	ks8851_eeprom_write(dev, EEPROM_OP_EWEN, 0, 0);
+	ee->magic = KS_EEPROM_MAGIC;
 
-	for (i = 0; i < last_word - first_word + 1; i++) {
-		ks8851_eeprom_write(dev, EEPROM_OP_WRITE, first_word + i,
-							eeprom_buff[i]);
-		mdelay(EEPROM_WRITE_TIME);
-	}
+	eeprom_93cx6_multiread(&ks->eeprom, offset/2, (__le16 *)data, len/2);
+	ks8851_eeprom_release(ks);
 
-	ks8851_eeprom_write(dev, EEPROM_OP_EWDS, 0, 0);
+	return 0;
+}
 
-	kfree(eeprom_buff);
-	return ret_val;
+static int ks8851_get_eeprom_len(struct net_device *dev)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+
+	/* currently, we assume it is an 93C46 attached, so return 128 */
+	return ks->rc_ccr & CCR_EEPROM ? 128 : 0;
 }
 
 static const struct ethtool_ops ks8851_ethtool_ops = {
@@ -1646,6 +1448,13 @@ static int __devinit ks8851_probe(struct spi_device *spi)
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
diff --git a/drivers/net/ethernet/micrel/ks8851.h b/drivers/net/ethernet/micrel/ks8851.h
index b2703a1..b0fae86 100644
--- a/drivers/net/ethernet/micrel/ks8851.h
+++ b/drivers/net/ethernet/micrel/ks8851.h
@@ -27,22 +27,11 @@
 #define KS_EEPCR				0x22
 #define EEPCR_EESRWA				(1 << 5)
 #define EEPCR_EESA				(1 << 4)
-#define EEPCR_EESB_OFFSET			3
-#define EEPCR_EESB				(1 << EEPCR_EESB_OFFSET)
+#define EEPCR_EESB				(1 << 3)
 #define EEPCR_EEDO				(1 << 2)
 #define EEPCR_EESCK				(1 << 1)
 #define EEPCR_EECS				(1 << 0)
 
-#define EEPROM_OP_LEN				3	/* bits:*/
-#define EEPROM_OP_READ				0x06
-#define EEPROM_OP_EWEN				0x04
-#define EEPROM_OP_WRITE				0x05
-#define EEPROM_OP_EWDS				0x14
-
-#define EEPROM_DATA_LEN				16	/* 16 bits EEPROM */
-#define EEPROM_WRITE_TIME			4	/* wrt ack time in ms */
-#define EEPROM_SK_PERIOD			400	/* in us */
-
 #define KS_MBIR					0x24
 #define MBIR_TXMBF				(1 << 12)
 #define MBIR_TXMBFA				(1 << 11)
-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
