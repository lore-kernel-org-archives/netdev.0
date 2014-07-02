From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 net-next 02/13] at86rf230: add
	regmap support
Date: Thu,  3 Jul 2014 00:20:44 +0200
Message-ID: <1404339655-8456-3-git-send-email-alex.aring@gmail.com>
References: <1404339655-8456-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1404339655-8456-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds regmap support for the at86rf230 driver and drop the
lowlevel spi access functions and use the regmap access functions.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/Kconfig     |   1 +
 drivers/net/ieee802154/at86rf230.c | 272 +++++++++++++++++++++++--------------
 2 files changed, 168 insertions(+), 105 deletions(-)

diff --git a/drivers/net/ieee802154/Kconfig b/drivers/net/ieee802154/Kconfig
index 8b7ae51..391a916 100644
--- a/drivers/net/ieee802154/Kconfig
+++ b/drivers/net/ieee802154/Kconfig
@@ -34,6 +34,7 @@ config IEEE802154_AT86RF230
 	depends on IEEE802154_DRIVERS && MAC802154
 	tristate "AT86RF230/231/233/212 transceiver driver"
 	depends on SPI
+	select REGMAP_SPI
 	---help---
 	  Say Y here to enable the at86rf230/231/233/212 SPI 802.15.4 wireless
 	  controller.
diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index dca6bae..e369703 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -31,6 +31,7 @@
 #include <linux/spinlock.h>
 #include <linux/spi/spi.h>
 #include <linux/spi/at86rf230.h>
+#include <linux/regmap.h>
 #include <linux/skbuff.h>
 #include <linux/of_gpio.h>
 
@@ -50,6 +51,7 @@ struct at86rf230_local {
 	struct completion tx_complete;
 
 	struct ieee802154_dev *dev;
+	struct regmap *regmap;
 
 	spinlock_t lock;
 	bool irq_busy;
@@ -256,6 +258,157 @@ static bool is_rf212(struct at86rf230_local *local)
 #define STATE_BUSY_RX_AACK_NOCLK 0x1E
 #define STATE_TRANSITION_IN_PROGRESS 0x1F
 
+#define AT86RF2XX_NUMREGS 0x3F
+
+static inline int
+__at86rf230_write(struct at86rf230_local *lp,
+		  unsigned int addr, unsigned int data)
+{
+	return regmap_write(lp->regmap, addr, data);
+}
+
+static inline int
+__at86rf230_read(struct at86rf230_local *lp,
+		 unsigned int addr, unsigned int *data)
+{
+	return regmap_read(lp->regmap, addr, data);
+}
+
+static inline int
+at86rf230_read_subreg(struct at86rf230_local *lp,
+		      unsigned int addr, unsigned int mask,
+		      unsigned int shift, unsigned int *data)
+{
+	int rc;
+
+	rc = __at86rf230_read(lp, addr, data);
+	if (rc > 0)
+		*data = (*data & mask) >> shift;
+
+	return rc;
+}
+
+static inline int
+at86rf230_write_subreg(struct at86rf230_local *lp,
+		       unsigned int addr, unsigned int mask,
+		       unsigned int shift, unsigned int data)
+{
+	return regmap_update_bits(lp->regmap, addr, mask, data << shift);
+}
+
+static bool
+at86rf230_reg_writeable(struct device *dev, unsigned int reg)
+{
+	switch (reg) {
+	case RG_TRX_STATE:
+	case RG_TRX_CTRL_0:
+	case RG_TRX_CTRL_1:
+	case RG_PHY_TX_PWR:
+	case RG_PHY_ED_LEVEL:
+	case RG_PHY_CC_CCA:
+	case RG_CCA_THRES:
+	case RG_RX_CTRL:
+	case RG_SFD_VALUE:
+	case RG_TRX_CTRL_2:
+	case RG_ANT_DIV:
+	case RG_IRQ_MASK:
+	case RG_VREG_CTRL:
+	case RG_BATMON:
+	case RG_XOSC_CTRL:
+	case RG_RX_SYN:
+	case RG_XAH_CTRL_1:
+	case RG_FTN_CTRL:
+	case RG_PLL_CF:
+	case RG_PLL_DCU:
+	case RG_SHORT_ADDR_0:
+	case RG_SHORT_ADDR_1:
+	case RG_PAN_ID_0:
+	case RG_PAN_ID_1:
+	case RG_IEEE_ADDR_0:
+	case RG_IEEE_ADDR_1:
+	case RG_IEEE_ADDR_2:
+	case RG_IEEE_ADDR_3:
+	case RG_IEEE_ADDR_4:
+	case RG_IEEE_ADDR_5:
+	case RG_IEEE_ADDR_6:
+	case RG_IEEE_ADDR_7:
+	case RG_XAH_CTRL_0:
+	case RG_CSMA_SEED_0:
+	case RG_CSMA_SEED_1:
+	case RG_CSMA_BE:
+		return true;
+	default:
+		return false;
+	}
+}
+
+static bool
+at86rf230_reg_readable(struct device *dev, unsigned int reg)
+{
+	bool rc;
+
+	/* all writeable are also readable */
+	rc = at86rf230_reg_writeable(dev, reg);
+	if (rc)
+		return rc;
+
+	/* readonly regs */
+	switch (reg) {
+	case RG_TRX_STATUS:
+	case RG_PHY_RSSI:
+	case RG_IRQ_STATUS:
+	case RG_PART_NUM:
+	case RG_VERSION_NUM:
+	case RG_MAN_ID_1:
+	case RG_MAN_ID_0:
+		return true;
+	default:
+		return false;
+	}
+}
+
+static bool
+at86rf230_reg_volatile(struct device *dev, unsigned int reg)
+{
+	/* can be changed during runtime */
+	switch (reg) {
+	case RG_TRX_STATUS:
+	case RG_TRX_STATE:
+	case RG_PHY_RSSI:
+	case RG_PHY_ED_LEVEL:
+	case RG_IRQ_STATUS:
+	case RG_VREG_CTRL:
+		return true;
+	default:
+		return false;
+	}
+}
+
+static bool
+at86rf230_reg_precious(struct device *dev, unsigned int reg)
+{
+	/* don't clear irq line on read */
+	switch (reg) {
+	case RG_IRQ_STATUS:
+		return true;
+	default:
+		return false;
+	}
+}
+
+static struct regmap_config at86rf230_regmap_spi_config = {
+	.reg_bits = 8,
+	.val_bits = 8,
+	.write_flag_mask = CMD_REG | CMD_WRITE,
+	.read_flag_mask = CMD_REG,
+	.cache_type = REGCACHE_RBTREE,
+	.max_register = AT86RF2XX_NUMREGS,
+	.writeable_reg = at86rf230_reg_writeable,
+	.readable_reg = at86rf230_reg_readable,
+	.volatile_reg = at86rf230_reg_volatile,
+	.precious_reg = at86rf230_reg_precious,
+};
+
 static int
 __at86rf230_detect_device(struct spi_device *spi, u16 *man_id, u8 *part,
 		u8 *version)
@@ -308,105 +461,6 @@ __at86rf230_detect_device(struct spi_device *spi, u16 *man_id, u8 *part,
 }
 
 static int
-__at86rf230_write(struct at86rf230_local *lp, u8 addr, u8 data)
-{
-	u8 *buf = lp->buf;
-	int status;
-	struct spi_message msg;
-	struct spi_transfer xfer = {
-		.len	= 2,
-		.tx_buf	= buf,
-	};
-
-	buf[0] = (addr & CMD_REG_MASK) | CMD_REG | CMD_WRITE;
-	buf[1] = data;
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
-	spi_message_init(&msg);
-	spi_message_add_tail(&xfer, &msg);
-
-	status = spi_sync(lp->spi, &msg);
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	if (msg.status)
-		status = msg.status;
-
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
-
-	return status;
-}
-
-static int
-__at86rf230_read_subreg(struct at86rf230_local *lp,
-			u8 addr, u8 mask, int shift, u8 *data)
-{
-	u8 *buf = lp->buf;
-	int status;
-	struct spi_message msg;
-	struct spi_transfer xfer = {
-		.len	= 2,
-		.tx_buf	= buf,
-		.rx_buf	= buf,
-	};
-
-	buf[0] = (addr & CMD_REG_MASK) | CMD_REG;
-	buf[1] = 0xff;
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	spi_message_init(&msg);
-	spi_message_add_tail(&xfer, &msg);
-
-	status = spi_sync(lp->spi, &msg);
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	if (msg.status)
-		status = msg.status;
-
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
-
-	if (status == 0)
-		*data = (buf[1] & mask) >> shift;
-
-	return status;
-}
-
-static int
-at86rf230_read_subreg(struct at86rf230_local *lp,
-		      u8 addr, u8 mask, int shift, u8 *data)
-{
-	int status;
-
-	mutex_lock(&lp->bmux);
-	status = __at86rf230_read_subreg(lp, addr, mask, shift, data);
-	mutex_unlock(&lp->bmux);
-
-	return status;
-}
-
-static int
-at86rf230_write_subreg(struct at86rf230_local *lp,
-		       u8 addr, u8 mask, int shift, u8 data)
-{
-	int status;
-	u8 val;
-
-	mutex_lock(&lp->bmux);
-	status = __at86rf230_read_subreg(lp, addr, 0xff, 0, &val);
-	if (status)
-		goto out;
-
-	val &= ~mask;
-	val |= (data << shift) & mask;
-
-	status = __at86rf230_write(lp, addr, val);
-out:
-	mutex_unlock(&lp->bmux);
-
-	return status;
-}
-
-static int
 at86rf230_write_fbuf(struct at86rf230_local *lp, u8 *data, u8 len)
 {
 	u8 *buf = lp->buf;
@@ -520,7 +574,7 @@ at86rf230_state(struct ieee802154_dev *dev, int state)
 {
 	struct at86rf230_local *lp = dev->priv;
 	int rc;
-	u8 val;
+	unsigned int val;
 	u8 desired_status;
 
 	might_sleep();
@@ -890,12 +944,11 @@ static void at86rf230_irqwork(struct work_struct *work)
 {
 	struct at86rf230_local *lp =
 		container_of(work, struct at86rf230_local, irqwork);
-	u8 status = 0, val;
+	unsigned int status;
 	int rc;
 	unsigned long flags;
 
-	rc = at86rf230_read_subreg(lp, RG_IRQ_STATUS, 0xff, 0, &val);
-	status |= val;
+	rc = at86rf230_read_subreg(lp, RG_IRQ_STATUS, 0xff, 0, &status);
 
 	status &= ~IRQ_PLL_LOCK; /* ignore */
 	status &= ~IRQ_RX_START; /* ignore */
@@ -954,7 +1007,7 @@ static irqreturn_t at86rf230_isr_level(int irq, void *data)
 static int at86rf230_hw_init(struct at86rf230_local *lp)
 {
 	int rc, irq_pol, irq_type;
-	u8 dvdd;
+	unsigned int dvdd;
 	u8 csma_seed[2];
 
 	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_FORCE_TRX_OFF);
@@ -1033,7 +1086,8 @@ static int at86rf230_probe(struct spi_device *spi)
 	struct ieee802154_dev *dev;
 	struct at86rf230_local *lp;
 	u16 man_id = 0;
-	u8 part = 0, version = 0, status;
+	u8 part = 0, version = 0;
+	unsigned int status;
 	irq_handler_t irq_handler;
 	work_func_t irq_worker;
 	int rc, irq_type;
@@ -1128,6 +1182,14 @@ static int at86rf230_probe(struct spi_device *spi)
 	if (rc < 0)
 		goto free_dev;
 
+	lp->regmap = devm_regmap_init_spi(spi, &at86rf230_regmap_spi_config);
+	if (IS_ERR(lp->regmap)) {
+		rc = PTR_ERR(lp->regmap);
+		dev_err(&spi->dev, "Failed to allocate register map: %d\n",
+			rc);
+		goto free_dev;
+	}
+
 	irq_type = irq_get_trigger_type(spi->irq);
 	if (!irq_type)
 		irq_type = IRQF_TRIGGER_RISING;
-- 
2.0.1


------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
