From: Ladislav Michl <ladis@linux-mips.org>
Subject: [PATCH] smc91x: get/set eeprom
Date: Fri, 18 Mar 2005 00:35:08 +0100
Message-ID: <20050317233508.GA13623@orphique>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Netdev <netdev@oss.sgi.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is implementation of get_eeprom and set_eeprom ethtool's methods.
Tested on custom OMAP based board. Comment and/or objections welcome as
always.

Best regards,
	ladis

===== drivers/net/smc91x.c 1.17 vs edited =====
--- 1.17/drivers/net/smc91x.c	2005-03-14 14:54:37 +01:00
+++ edited/drivers/net/smc91x.c	2005-03-18 00:23:13 +01:00
@@ -1727,6 +1727,160 @@
 	lp->msg_enable = level;
 }
 
+/*
+ * Must be called with lp->lock locked. Caller must select bank 2 again.
+ */
+static int smc_read_eeprom_reg(unsigned long ioaddr, unsigned int reg)
+{
+	unsigned int timeout;
+
+	SMC_SELECT_BANK(2);
+	SMC_SET_PTR(reg);
+
+	SMC_SELECT_BANK(1);
+	SMC_SET_CTL(SMC_GET_CTL() | CTL_EEPROM_SELECT | CTL_RELOAD);
+	timeout = 100;
+	while ((SMC_GET_CTL() & CTL_RELOAD) && --timeout)
+		udelay(100);
+	if (timeout == 0) {
+		printk(KERN_INFO "%s: timeout reading EEPROM register %02x\n",
+			CARDNAME, reg);
+		return -EIO;
+	}
+
+	return SMC_GET_GP();
+}
+
+/*
+ * Must be called with lp->lock locked. Caller must select bank 2 again.
+ */
+static int smc_write_eeprom_reg(unsigned long ioaddr, unsigned int reg,
+				unsigned int val)
+{
+	unsigned int timeout;
+
+	SMC_SELECT_BANK(2);
+	SMC_SET_PTR(reg);
+
+	SMC_SELECT_BANK(1);
+	SMC_SET_GP(val);
+	SMC_SET_CTL(SMC_GET_CTL() | CTL_EEPROM_SELECT | CTL_STORE);
+	timeout = 100;
+	while ((SMC_GET_CTL() & CTL_STORE) && --timeout)
+		udelay(100);
+	if (timeout == 0) {
+		printk(KERN_INFO "%s: timeout writing EEPROM register %02x\n",
+			CARDNAME, reg);
+		return -EIO;
+	}
+
+	return 0;
+}
+
+static int smc_ethtool_geteepromlen(struct net_device *dev)
+{
+	return SMC_EEPROM_SIZE;
+}
+
+static int smc_ethtool_geteeprom(struct net_device *dev,
+				 struct ethtool_eeprom *eeprom, u8 *data)
+{
+
+	struct smc_local *lp = netdev_priv(dev);
+	unsigned long ioaddr = dev->base_addr;
+	unsigned reg;
+	int ret, len;
+
+	len = eeprom->len;
+	reg = eeprom->offset >> 1;
+	eeprom->len = 0;
+	eeprom->magic = SMC_EEPROM_MAGIC;
+
+	spin_lock_irq(&lp->lock);
+
+	if (eeprom->offset & 1) {
+		ret = smc_read_eeprom_reg(ioaddr, reg++);
+		if (ret < 0)
+			goto out;
+		*data++ = ret >> 8;
+	        eeprom->len++;
+		len--;
+	}
+	while (len) {
+		len -= 2;
+		ret = smc_read_eeprom_reg(ioaddr, reg++);
+		if (ret < 0)
+			goto out;
+		*data++ = ret & 0xff;
+		if (len < 0) {
+			eeprom->len++;
+			break;
+		}
+		*data++ = ret >> 8;
+		eeprom->len += 2;
+	}
+
+	ret = 0;
+out:
+	SMC_SELECT_BANK(2);
+	spin_unlock_irq(&lp->lock);
+
+	return ret;
+}
+
+static int smc_ethtool_seteeprom(struct net_device *dev,
+				 struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct smc_local *lp = netdev_priv(dev);
+	unsigned long ioaddr = dev->base_addr;
+	unsigned reg;
+	int ret, len;
+
+	if (eeprom->magic != SMC_EEPROM_MAGIC)
+		return -EINVAL;
+
+	reg = eeprom->offset >> 1;
+	len = eeprom->len;
+
+	spin_lock_irq(&lp->lock);
+
+	if (eeprom->offset & 1) {
+		ret = smc_read_eeprom_reg(ioaddr, reg);
+		if (ret < 0)
+			goto out;
+		ret = (ret & 0xff) | ((int)*data++ << 8);
+		ret = smc_write_eeprom_reg(ioaddr, reg++, ret);
+		if (ret < 0)
+			goto out;
+		len--;
+	}
+	while (len) {
+		len -= 2;
+		if (len < 0) {
+			ret = smc_read_eeprom_reg(ioaddr, reg);
+			if (ret < 0)
+				goto out;
+			ret = (ret & 0xff) | *data;
+			ret = smc_write_eeprom_reg(ioaddr, reg, ret);
+			if (ret < 0)
+				goto out;
+			break;
+		}
+		ret = *data++;
+		ret |= (int)*data++ << 8;
+		ret = smc_write_eeprom_reg(ioaddr, reg++, ret);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = 0;
+out:
+	SMC_SELECT_BANK(2);
+	spin_unlock_irq(&lp->lock);
+
+	return ret;
+}
+
 static struct ethtool_ops smc_ethtool_ops = {
 	.get_settings	= smc_ethtool_getsettings,
 	.set_settings	= smc_ethtool_setsettings,
@@ -1736,8 +1890,9 @@
 	.set_msglevel	= smc_ethtool_setmsglevel,
 	.nway_reset	= smc_ethtool_nwayreset,
 	.get_link	= ethtool_op_get_link,
-//	.get_eeprom	= smc_ethtool_geteeprom,
-//	.set_eeprom	= smc_ethtool_seteeprom,
+	.get_eeprom_len	= smc_ethtool_geteepromlen,
+	.get_eeprom	= smc_ethtool_geteeprom,
+	.set_eeprom	= smc_ethtool_seteeprom,
 };
 
 /*
===== drivers/net/smc91x.h 1.14 vs edited =====
--- 1.14/drivers/net/smc91x.h	2005-03-14 14:54:37 +01:00
+++ edited/drivers/net/smc91x.h	2005-03-17 23:33:13 +01:00
@@ -404,6 +404,13 @@
 #define SMC_DATA_EXTENT (4)
 
 /*
+ * 128 bytes serial EEPROM
+ */
+#define SMC_EEPROM_SIZE		128
+
+#define SMC_EEPROM_MAGIC	0x3A8EBEEF
+
+/*
  . Bank Select Register:
  .
  .		yyyy yyyy 0000 00xx
@@ -834,6 +841,8 @@
 #define SMC_GET_CONFIG()	SMC_inw( ioaddr, CONFIG_REG )
 #define SMC_SET_CONFIG(x)	SMC_outw( x, ioaddr, CONFIG_REG )
 #define SMC_GET_COUNTER()	SMC_inw( ioaddr, COUNTER_REG )
+#define SMC_GET_GP()		SMC_inw( ioaddr, GP_REG )
+#define SMC_SET_GP(x)		SMC_outw( x, ioaddr, GP_REG )
 #define SMC_GET_CTL()		SMC_inw( ioaddr, CTL_REG )
 #define SMC_SET_CTL(x)		SMC_outw( x, ioaddr, CTL_REG )
 #define SMC_GET_MII()		SMC_inw( ioaddr, MII_REG )
