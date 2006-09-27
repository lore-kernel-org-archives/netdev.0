From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 8/9][TG3]: Add 5709 self-test support.
Date: Wed, 27 Sep 2006 13:35:14 -0700
Message-ID: <1159389314.3411.25.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:7436 "EHLO mms1.broadcom.com")
	by vger.kernel.org with ESMTP id S1030794AbWI0Uic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 16:38:32 -0400
To: davem@davemloft.net, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add 5709 self-test support.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 23f5744..21843de 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3615,8 +3615,7 @@ static irqreturn_t tg3_test_isr(int irq,
 
 	if ((sblk->status & SD_STATUS_UPDATED) ||
 	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
-		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
-			     0x00000001);
+		tg3_disable_ints(tp);
 		return IRQ_RETVAL(1);
 	}
 	return IRQ_RETVAL(0);
@@ -6860,8 +6859,7 @@ static int tg3_request_irq(struct tg3 *t
 static int tg3_test_interrupt(struct tg3 *tp)
 {
 	struct net_device *dev = tp->dev;
-	int err, i;
-	u32 int_mbox = 0;
+	int err, i, intr_ok = 0;
 
 	if (!netif_running(dev))
 		return -ENODEV;
@@ -6882,10 +6880,18 @@ static int tg3_test_interrupt(struct tg3
 	       HOSTCC_MODE_NOW);
 
 	for (i = 0; i < 5; i++) {
+		u32 int_mbox, misc_host_ctrl;
+
 		int_mbox = tr32_mailbox(MAILBOX_INTERRUPT_0 +
 					TG3_64BIT_REG_LOW);
-		if (int_mbox != 0)
+		misc_host_ctrl = tr32(TG3PCI_MISC_HOST_CTRL);
+
+		if ((int_mbox != 0) ||
+		    (misc_host_ctrl & MISC_HOST_CTRL_MASK_PCI_INT)) {
+			intr_ok = 1;
 			break;
+		}
+
 		msleep(10);
 	}
 
@@ -6898,7 +6904,7 @@ static int tg3_test_interrupt(struct tg3
 	if (err)
 		return err;
 
-	if (int_mbox != 0)
+	if (intr_ok)
 		return 0;
 
 	return -EIO;
@@ -8288,6 +8294,8 @@ static void tg3_get_ethtool_stats (struc
 
 #define NVRAM_TEST_SIZE 0x100
 #define NVRAM_SELFBOOT_FORMAT1_SIZE 0x14
+#define NVRAM_SELFBOOT_HW_SIZE 0x20
+#define NVRAM_SELFBOOT_DATA_SIZE 0x1c
 
 static int tg3_test_nvram(struct tg3 *tp)
 {
@@ -8299,12 +8307,14 @@ static int tg3_test_nvram(struct tg3 *tp
 
 	if (magic == TG3_EEPROM_MAGIC)
 		size = NVRAM_TEST_SIZE;
-	else if ((magic & 0xff000000) == 0xa5000000) {
+	else if ((magic & TG3_EEPROM_MAGIC_FW_MSK) == TG3_EEPROM_MAGIC_FW) {
 		if ((magic & 0xe00000) == 0x200000)
 			size = NVRAM_SELFBOOT_FORMAT1_SIZE;
 		else
 			return 0;
-	} else
+	} else if ((magic & TG3_EEPROM_MAGIC_HW_MSK) == TG3_EEPROM_MAGIC_HW)
+		size = NVRAM_SELFBOOT_HW_SIZE;
+	else
 		return -EIO;
 
 	buf = kmalloc(size, GFP_KERNEL);
@@ -8323,7 +8333,8 @@ static int tg3_test_nvram(struct tg3 *tp
 		goto out;
 
 	/* Selfboot format */
-	if (cpu_to_be32(buf[0]) != TG3_EEPROM_MAGIC) {
+	if ((cpu_to_be32(buf[0]) & TG3_EEPROM_MAGIC_FW_MSK) ==
+	    TG3_EEPROM_MAGIC_FW) {
 		u8 *buf8 = (u8 *) buf, csum8 = 0;
 
 		for (i = 0; i < size; i++)
@@ -8338,6 +8349,51 @@ static int tg3_test_nvram(struct tg3 *tp
 		goto out;
 	}
 
+	if ((cpu_to_be32(buf[0]) & TG3_EEPROM_MAGIC_HW_MSK) ==
+	    TG3_EEPROM_MAGIC_HW) {
+		u8 data[NVRAM_SELFBOOT_DATA_SIZE];
+	       	u8 parity[NVRAM_SELFBOOT_DATA_SIZE];
+		u8 *buf8 = (u8 *) buf;
+		int j, k;
+
+		/* Separate the parity bits and the data bytes.  */
+		for (i = 0, j = 0, k = 0; i < NVRAM_SELFBOOT_HW_SIZE; i++) {
+			if ((i == 0) || (i == 8)) {
+				int l;
+				u8 msk;
+
+				for (l = 0, msk = 0x80; l < 7; l++, msk >>= 1)
+					parity[k++] = buf8[i] & msk;
+				i++;
+			}
+			else if (i == 16) {
+				int l;
+				u8 msk;
+
+				for (l = 0, msk = 0x20; l < 6; l++, msk >>= 1)
+					parity[k++] = buf8[i] & msk;
+				i++;
+
+				for (l = 0, msk = 0x80; l < 8; l++, msk >>= 1)
+					parity[k++] = buf8[i] & msk;
+				i++;
+			}
+			data[j++] = buf8[i];
+		}
+
+		err = -EIO;
+		for (i = 0; i < NVRAM_SELFBOOT_DATA_SIZE; i++) {
+			u8 hw8 = hweight8(data[i]);
+
+			if ((hw8 & 0x1) && parity[i])
+				goto out;
+			else if (!(hw8 & 0x1) && !parity[i])
+				goto out;
+		}
+		err = 0;
+		goto out;
+	}
+
 	/* Bootstrap checksum at offset 0x10 */
 	csum = calc_crc((unsigned char *) buf, 0x10);
 	if(csum != cpu_to_le32(buf[0x10/4]))
@@ -8384,7 +8440,7 @@ static int tg3_test_link(struct tg3 *tp)
 /* Only test the commonly used registers */
 static int tg3_test_registers(struct tg3 *tp)
 {
-	int i, is_5705;
+	int i, is_5705, is_5750;
 	u32 offset, read_mask, write_mask, val, save_val, read_val;
 	static struct {
 		u16 offset;
@@ -8392,6 +8448,7 @@ static int tg3_test_registers(struct tg3
 #define TG3_FL_5705	0x1
 #define TG3_FL_NOT_5705	0x2
 #define TG3_FL_NOT_5788	0x4
+#define TG3_FL_NOT_5750	0x8
 		u32 read_mask;
 		u32 write_mask;
 	} reg_tbl[] = {
@@ -8502,9 +8559,9 @@ static int tg3_test_registers(struct tg3
 			0xffffffff, 0x00000000 },
 
 		/* Buffer Manager Control Registers. */
-		{ BUFMGR_MB_POOL_ADDR, 0x0000,
+		{ BUFMGR_MB_POOL_ADDR, TG3_FL_NOT_5750,
 			0x00000000, 0x007fff80 },
-		{ BUFMGR_MB_POOL_SIZE, 0x0000,
+		{ BUFMGR_MB_POOL_SIZE, TG3_FL_NOT_5750,
 			0x00000000, 0x007fffff },
 		{ BUFMGR_MB_RDMA_LOW_WATER, 0x0000,
 			0x00000000, 0x0000003f },
@@ -8530,10 +8587,12 @@ static int tg3_test_registers(struct tg3
 		{ 0xffff, 0x0000, 0x00000000, 0x00000000 },
 	};
 
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)
+	is_5705 = is_5750 = 0;
+	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
 		is_5705 = 1;
-	else
-		is_5705 = 0;
+		if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS)
+			is_5750 = 1;
+	}
 
 	for (i = 0; reg_tbl[i].offset != 0xffff; i++) {
 		if (is_5705 && (reg_tbl[i].flags & TG3_FL_NOT_5705))
@@ -8546,6 +8605,9 @@ static int tg3_test_registers(struct tg3
 		    (reg_tbl[i].flags & TG3_FL_NOT_5788))
 			continue;
 
+		if (is_5750 && (reg_tbl[i].flags & TG3_FL_NOT_5750))
+			continue;
+
 		offset = (u32) reg_tbl[i].offset;
 		read_mask = reg_tbl[i].read_mask;
 		write_mask = reg_tbl[i].write_mask;
@@ -8637,6 +8699,13 @@ static int tg3_test_memory(struct tg3 *t
 		{ 0x00008000, 0x02000},
 		{ 0x00010000, 0x0c000},
 		{ 0xffffffff, 0x00000}
+	}, mem_tbl_5906[] = {
+		{ 0x00000200, 0x00008},
+		{ 0x00004000, 0x00400},
+		{ 0x00006000, 0x00400},
+		{ 0x00008000, 0x01000},
+		{ 0x00010000, 0x01000},
+		{ 0xffffffff, 0x00000}
 	};
 	struct mem_entry *mem_tbl;
 	int err = 0;
@@ -8646,6 +8715,8 @@ static int tg3_test_memory(struct tg3 *t
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
 			mem_tbl = mem_tbl_5755;
+		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+			mem_tbl = mem_tbl_5906;
 		else
 			mem_tbl = mem_tbl_5705;
 	} else
@@ -8691,6 +8762,21 @@ static int tg3_run_loopback(struct tg3 *
 	} else if (loopback_mode == TG3_PHY_LOOPBACK) {
 		u32 val;
 
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+			u32 phytest;
+
+			if (!tg3_readphy(tp, MII_TG3_EPHY_TEST, &phytest)) {
+				u32 phy;
+
+				tg3_writephy(tp, MII_TG3_EPHY_TEST,
+					     phytest | MII_TG3_EPHY_SHADOW_EN);
+				if (!tg3_readphy(tp, 0x1b, &phy))
+					tg3_writephy(tp, 0x1b, phy & ~0x20);
+				if (!tg3_readphy(tp, 0x10, &phy))
+					tg3_writephy(tp, 0x10, phy & ~0x4000);
+				tg3_writephy(tp, MII_TG3_EPHY_TEST, phytest);
+			}
+		}
 		val = BMCR_LOOPBACK | BMCR_FULLDPLX;
 		if (tp->tg3_flags & TG3_FLAG_10_100_ONLY)
 			val |= BMCR_SPEED100;
@@ -8699,6 +8785,9 @@ static int tg3_run_loopback(struct tg3 *
 
 		tg3_writephy(tp, MII_BMCR, val);
 		udelay(40);
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+			tg3_writephy(tp, MII_TG3_EPHY_PTEST, 0x1800);
+
 		/* reset to prevent losing 1st rx packet intermittently */
 		if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES) {
 			tw32_f(MAC_RX_MODE, RX_MODE_RESET);
@@ -9112,7 +9201,9 @@ static void __devinit tg3_get_eeprom_siz
 	if (tg3_nvram_read_swab(tp, 0, &magic) != 0)
 		return;
 
-	if ((magic != TG3_EEPROM_MAGIC) && ((magic & 0xff000000) != 0xa5000000))
+	if ((magic != TG3_EEPROM_MAGIC) &&
+	    ((magic & TG3_EEPROM_MAGIC_FW_MSK) != TG3_EEPROM_MAGIC_FW) &&
+	    ((magic & TG3_EEPROM_MAGIC_HW_MSK) != TG3_EEPROM_MAGIC_HW))
 		return;
 
 	/*
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 9259d12..92f5300 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1507,6 +1507,10 @@
 
 
 #define TG3_EEPROM_MAGIC		0x669955aa
+#define TG3_EEPROM_MAGIC_FW		0xa5000000
+#define TG3_EEPROM_MAGIC_FW_MSK		0xff000000
+#define TG3_EEPROM_MAGIC_HW		0xabcd
+#define TG3_EEPROM_MAGIC_HW_MSK		0xffff
 
 /* 32K Window into NIC internal memory */
 #define NIC_SRAM_WIN_BASE		0x00008000


