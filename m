From: Philip Craig <philipc@snapgear.com>
Subject: [PATCH 2/2 resend] 8139cp: add ethtool eeprom support
Date: Wed, 21 Jun 2006 11:33:27 +1000
Message-ID: <20060621013337.915916000@snapgear.com>
References: <4497B73A.4080804@pobox.com>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:17885 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S1750745AbWFUBwZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 21:52:25 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=8139cp-ethtool-eeprom.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement the ethtool eeprom operations for the 8139cp driver.
Tested on x86 and big-endian ARM.

Signed-off-by: Philip Craig <philipc@snapgear.com>

Index: linux-2.6.17-rc6/drivers/net/8139cp.c
===================================================================
--- linux-2.6.17-rc6.orig/drivers/net/8139cp.c	2006-06-14 15:59:26.000000000 +1000
+++ linux-2.6.17-rc6/drivers/net/8139cp.c	2006-06-14 15:59:53.000000000 +1000
@@ -401,6 +401,11 @@ static void cp_clean_rings (struct cp_pr
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void cp_poll_controller(struct net_device *dev);
 #endif
+static int cp_get_eeprom_len(struct net_device *dev);
+static int cp_get_eeprom(struct net_device *dev,
+			 struct ethtool_eeprom *eeprom, u8 *data);
+static int cp_set_eeprom(struct net_device *dev,
+			 struct ethtool_eeprom *eeprom, u8 *data);
 
 static struct pci_device_id cp_pci_tbl[] = {
 	{ PCI_VENDOR_ID_REALTEK, PCI_DEVICE_ID_REALTEK_8139,
@@ -1577,6 +1582,9 @@ static struct ethtool_ops cp_ethtool_ops
 	.get_strings		= cp_get_strings,
 	.get_ethtool_stats	= cp_get_ethtool_stats,
 	.get_perm_addr		= ethtool_op_get_perm_addr,
+	.get_eeprom_len		= cp_get_eeprom_len,
+	.get_eeprom		= cp_get_eeprom,
+	.set_eeprom		= cp_set_eeprom,
 };
 
 static int cp_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
@@ -1612,24 +1620,32 @@ static int cp_ioctl (struct net_device *
 #define eeprom_delay()	readl(ee_addr)
 
 /* The EEPROM commands include the alway-set leading bit. */
+#define EE_EXTEND_CMD	(4)
 #define EE_WRITE_CMD	(5)
 #define EE_READ_CMD		(6)
 #define EE_ERASE_CMD	(7)
 
-static int read_eeprom (void __iomem *ioaddr, int location, int addr_len)
-{
-	int i;
-	unsigned retval = 0;
-	void __iomem *ee_addr = ioaddr + Cfg9346;
-	int read_cmd = location | (EE_READ_CMD << addr_len);
+#define EE_EWDS_ADDR	(0)
+#define EE_WRAL_ADDR	(1)
+#define EE_ERAL_ADDR	(2)
+#define EE_EWEN_ADDR	(3)
+
+#define CP_EEPROM_MAGIC PCI_DEVICE_ID_REALTEK_8139
 
+static void eeprom_cmd_start(void __iomem *ee_addr)
+{
 	writeb (EE_ENB & ~EE_CS, ee_addr);
 	writeb (EE_ENB, ee_addr);
 	eeprom_delay ();
+}
+
+static void eeprom_cmd(void __iomem *ee_addr, int cmd, int cmd_len)
+{
+	int i;
 
-	/* Shift the read command bits out. */
-	for (i = 3 + addr_len - 1; i >= 0; i--) {
-		int dataval = (read_cmd & (1 << i)) ? EE_DATA_WRITE : 0;
+	/* Shift the command bits out. */
+	for (i = cmd_len - 1; i >= 0; i--) {
+		int dataval = (cmd & (1 << i)) ? EE_DATA_WRITE : 0;
 		writeb (EE_ENB | dataval, ee_addr);
 		eeprom_delay ();
 		writeb (EE_ENB | dataval | EE_SHIFT_CLK, ee_addr);
@@ -1637,6 +1653,33 @@ static int read_eeprom (void __iomem *io
 	}
 	writeb (EE_ENB, ee_addr);
 	eeprom_delay ();
+}
+
+static void eeprom_cmd_end(void __iomem *ee_addr)
+{
+	writeb (~EE_CS, ee_addr);
+	eeprom_delay ();
+}
+
+static void eeprom_extend_cmd(void __iomem *ee_addr, int extend_cmd,
+			      int addr_len)
+{
+	int cmd = (EE_EXTEND_CMD << addr_len) | (extend_cmd << (addr_len - 2));
+
+	eeprom_cmd_start(ee_addr);
+	eeprom_cmd(ee_addr, cmd, 3 + addr_len);
+	eeprom_cmd_end(ee_addr);
+}
+
+static u16 read_eeprom (void __iomem *ioaddr, int location, int addr_len)
+{
+	int i;
+	u16 retval = 0;
+	void __iomem *ee_addr = ioaddr + Cfg9346;
+	int read_cmd = location | (EE_READ_CMD << addr_len);
+
+	eeprom_cmd_start(ee_addr);
+	eeprom_cmd(ee_addr, read_cmd, 3 + addr_len);
 
 	for (i = 16; i > 0; i--) {
 		writeb (EE_ENB | EE_SHIFT_CLK, ee_addr);
@@ -1648,13 +1691,125 @@ static int read_eeprom (void __iomem *io
 		eeprom_delay ();
 	}
 
-	/* Terminate the EEPROM access. */
-	writeb (~EE_CS, ee_addr);
-	eeprom_delay ();
+	eeprom_cmd_end(ee_addr);
 
 	return retval;
 }
 
+static void write_eeprom(void __iomem *ioaddr, int location, u16 val,
+			 int addr_len)
+{
+	int i;
+	void __iomem *ee_addr = ioaddr + Cfg9346;
+	int write_cmd = location | (EE_WRITE_CMD << addr_len);
+
+	eeprom_extend_cmd(ee_addr, EE_EWEN_ADDR, addr_len);
+
+	eeprom_cmd_start(ee_addr);
+	eeprom_cmd(ee_addr, write_cmd, 3 + addr_len);
+	eeprom_cmd(ee_addr, val, 16);
+	eeprom_cmd_end(ee_addr);
+
+	eeprom_cmd_start(ee_addr);
+	for (i = 0; i < 20000; i++)
+		if (readb(ee_addr) & EE_DATA_READ)
+			break;
+	eeprom_cmd_end(ee_addr);
+
+	eeprom_extend_cmd(ee_addr, EE_EWDS_ADDR, addr_len);
+}
+
+static int cp_get_eeprom_len(struct net_device *dev)
+{
+	struct cp_private *cp = netdev_priv(dev);
+	int size;
+
+	spin_lock_irq(&cp->lock);
+	size = read_eeprom(cp->regs, 0, 8) == 0x8129 ? 256 : 128;
+	spin_unlock_irq(&cp->lock);
+
+	return size;
+}
+
+static int cp_get_eeprom(struct net_device *dev,
+			 struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct cp_private *cp = netdev_priv(dev);
+	unsigned int addr_len;
+	u16 val;
+	u32 offset = eeprom->offset >> 1;
+	u32 len = eeprom->len;
+	u32 i = 0;
+
+	eeprom->magic = CP_EEPROM_MAGIC;
+
+	spin_lock_irq(&cp->lock);
+
+	addr_len = read_eeprom(cp->regs, 0, 8) == 0x8129 ? 8 : 6;
+
+	if (eeprom->offset & 1) {
+		val = read_eeprom(cp->regs, offset, addr_len);
+		data[i++] = (u8)(val >> 8);
+		offset++;
+	}
+
+	while (i < len - 1) {
+		val = read_eeprom(cp->regs, offset, addr_len);
+		data[i++] = (u8)val;
+		data[i++] = (u8)(val >> 8);
+		offset++;
+	}
+
+	if (i < len) {
+		val = read_eeprom(cp->regs, offset, addr_len);
+		data[i] = (u8)val;
+	}
+
+	spin_unlock_irq(&cp->lock);
+	return 0;
+}
+
+static int cp_set_eeprom(struct net_device *dev,
+			 struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct cp_private *cp = netdev_priv(dev);
+	unsigned int addr_len;
+	u16 val;
+	u32 offset = eeprom->offset >> 1;
+	u32 len = eeprom->len;
+	u32 i = 0;
+
+	if (eeprom->magic != CP_EEPROM_MAGIC)
+		return -EINVAL;
+
+	spin_lock_irq(&cp->lock);
+
+	addr_len = read_eeprom(cp->regs, 0, 8) == 0x8129 ? 8 : 6;
+
+	if (eeprom->offset & 1) {
+		val = read_eeprom(cp->regs, offset, addr_len) & 0xff;
+		val |= (u16)data[i++] << 8;
+		write_eeprom(cp->regs, offset, val, addr_len);
+		offset++;
+	}
+
+	while (i < len - 1) {
+		val = (u16)data[i++];
+		val |= (u16)data[i++] << 8;
+		write_eeprom(cp->regs, offset, val, addr_len);
+		offset++;
+	}
+
+	if (i < len) {
+		val = read_eeprom(cp->regs, offset, addr_len) & 0xff00;
+		val |= (u16)data[i];
+		write_eeprom(cp->regs, offset, val, addr_len);
+	}
+
+	spin_unlock_irq(&cp->lock);
+	return 0;
+}
+
 /* Put the board into D3cold state and wait for WakeUp signal */
 static void cp_set_d3_state (struct cp_private *cp)
 {

--

