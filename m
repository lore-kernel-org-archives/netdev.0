From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 07/26] rt2x00: BBP busy check
Date: Sun, 3 Dec 2006 19:19:04 +0100
Message-ID: <200612031919.04272.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:57177 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758781AbWLCSTe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:34 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144387nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:33 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rt61pci and rt73usb legacy drivers have hinted that there are
race conditions with the bbp register handling. This must be
fixed by doing a busy check before the actual read command.
At the same time we can remove duplicate code by putting that
busy check into a seperate function.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-d80211/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-d80211/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-02 23:56:59.000000000 +0100
+++ wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 12:38:28.000000000 +0100
@@ -98,8 +98,7 @@
 	memcpy_toio(rt2x00dev->csr_addr + offset, value, length);
 }
 
-static void rt2x00_bbp_write(const struct rt2x00_dev *rt2x00dev,
-	const u8 reg_id, const u8 value)
+static u32 rt2x00_bbp_check(const struct rt2x00_dev *rt2x00dev)
 {
 	u32 reg;
 	unsigned int i;
@@ -107,14 +106,29 @@
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
 		rt2x00_register_read(rt2x00dev, BBPCSR, &reg);
 		if (!rt2x00_get_field32(reg, BBPCSR_BUSY))
-			goto bbp_write;
+			return reg;
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR("BBPCSR register busy. Write failed.\n");
-	return;
+	return 0xffff;
+}
 
-bbp_write:
+static void rt2x00_bbp_write(const struct rt2x00_dev *rt2x00dev,
+	const u8 reg_id, const u8 value)
+{
+	u32 reg;
+
+	/*
+	 *  Wait untill the BBP becomes ready.
+	 */
+	if (rt2x00_bbp_check(rt2x00dev) == 0xffff) {
+		ERROR("BBPCSR register busy. Write failed.\n");
+		return;
+	}
+
+	/*
+	 * Write the data into the BBP.
+	 */
 	reg = 0;
 	rt2x00_set_field32(&reg, BBPCSR_VALUE, value);
 	rt2x00_set_field32(&reg, BBPCSR_REGNUM, reg_id);
@@ -128,10 +142,17 @@
 	const u8 reg_id, u8 *value)
 {
 	u32 reg;
-	unsigned int i;
 
 	/*
-	 * First request the register we wish to read from.
+	 *  Wait untill the BBP becomes ready.
+	 */
+	if (rt2x00_bbp_check(rt2x00dev) == 0xffff) {
+		ERROR("BBPCSR register busy. Read failed.\n");
+		return;
+	}
+
+	/*
+	 * Write the request into the BBP.
 	 */
 	reg = 0;
 	rt2x00_set_field32(&reg, BBPCSR_REGNUM, reg_id);
@@ -140,17 +161,14 @@
 
 	rt2x00_register_write(rt2x00dev, BBPCSR, reg);
 
-	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2x00_register_read(rt2x00dev, BBPCSR, &reg);
-		if (!rt2x00_get_field32(reg, BBPCSR_BUSY)) {
-			*value = rt2x00_get_field32(reg, BBPCSR_VALUE);
-			return;
-		}
-		udelay(REGISTER_BUSY_DELAY);
-	}
+	/*
+	 *  Wait untill the BBP becomes ready.
+	 */
+	reg = rt2x00_bbp_check(rt2x00dev);
+	if (reg == 0xffff)
+		ERROR("BBPCSR register busy. Read failed.\n");
 
-	ERROR("BBPCSR register busy. Read failed.\n");
-	*value = 0xff;
+	*value = rt2x00_get_field32(reg, BBPCSR_VALUE);
 }
 
 static void rt2x00_rf_write(const struct rt2x00_dev *rt2x00dev,
diff -rU3 wireless-dev-d80211/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-d80211/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 00:09:32.000000000 +0100
+++ wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 12:34:39.000000000 +0100
@@ -98,8 +98,7 @@
 	memcpy_toio(rt2x00dev->csr_addr + offset, value, length);
 }
 
-static void rt2x00_bbp_write(const struct rt2x00_dev *rt2x00dev,
-	const u8 reg_id, const u8 value)
+static u32 rt2x00_bbp_check(const struct rt2x00_dev *rt2x00dev)
 {
 	u32 reg;
 	unsigned int i;
@@ -107,14 +106,29 @@
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
 		rt2x00_register_read(rt2x00dev, BBPCSR, &reg);
 		if (!rt2x00_get_field32(reg, BBPCSR_BUSY))
-			goto bbp_write;
+			return reg;
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR("BBPCSR register busy. Write failed.\n");
-	return;
+	return 0xffff;
+}
 
-bbp_write:
+static void rt2x00_bbp_write(const struct rt2x00_dev *rt2x00dev,
+	const u8 reg_id, const u8 value)
+{
+	u32 reg;
+
+	/*
+	 *  Wait untill the BBP becomes ready.
+	 */
+	if (rt2x00_bbp_check(rt2x00dev) == 0xffff) {
+		ERROR("BBPCSR register busy. Write failed.\n");
+		return;
+	}
+
+	/*
+	 * Write the data into the BBP.
+	 */
 	reg = 0;
 	rt2x00_set_field32(&reg, BBPCSR_VALUE, value);
 	rt2x00_set_field32(&reg, BBPCSR_REGNUM, reg_id);
@@ -128,10 +142,17 @@
 	const u8 reg_id, u8 *value)
 {
 	u32 reg;
-	unsigned int i;
 
 	/*
-	 * First request the register we wish to read from.
+	 *  Wait untill the BBP becomes ready.
+	 */
+	if (rt2x00_bbp_check(rt2x00dev) == 0xffff) {
+		ERROR("BBPCSR register busy. Read failed.\n");
+		return;
+	}
+
+	/*
+	 * Write the request into the BBP.
 	 */
 	reg = 0;
 	rt2x00_set_field32(&reg, BBPCSR_REGNUM, reg_id);
@@ -140,17 +161,14 @@
 
 	rt2x00_register_write(rt2x00dev, BBPCSR, reg);
 
-	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2x00_register_read(rt2x00dev, BBPCSR, &reg);
-		if (!rt2x00_get_field32(reg, BBPCSR_BUSY)) {
-			*value = rt2x00_get_field32(reg, BBPCSR_VALUE);
-			return;
-		}
-		udelay(REGISTER_BUSY_DELAY);
-	}
+	/*
+	 *  Wait untill the BBP becomes ready.
+	 */
+	reg = rt2x00_bbp_check(rt2x00dev);
+	if (reg == 0xffff)
+		ERROR("BBPCSR register busy. Read failed.\n");
 
-	ERROR("BBPCSR register busy. Read failed.\n");
-	*value = 0xff;
+	*value = rt2x00_get_field32(reg, BBPCSR_VALUE);
 }
 
 static void rt2x00_rf_write(const struct rt2x00_dev *rt2x00dev,
diff -rU3 wireless-dev-d80211/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-d80211/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 00:01:21.000000000 +0100
+++ wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 12:35:13.000000000 +0100
@@ -117,8 +117,7 @@
 		offset, 0x00, value, length);
 }
 
-static void rt2x00_bbp_write(const struct rt2x00_dev *rt2x00dev,
-	const u8 reg_id, const u8 value)
+static u16 rt2x00_bbp_check(const struct rt2x00_dev *rt2x00dev)
 {
 	u16 reg;
 	unsigned int i;
@@ -126,14 +125,29 @@
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
 		rt2x00_register_read(rt2x00dev, PHY_CSR8, &reg);
 		if (!rt2x00_get_field16(reg, PHY_CSR8_BBP_BUSY))
-			goto bbp_write;
+			return reg;
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR("BBPCSR register busy. Write failed.\n");
-	return;
+	return 0xffff;
+}
 
-bbp_write:
+static void rt2x00_bbp_write(const struct rt2x00_dev *rt2x00dev,
+	const u8 reg_id, const u8 value)
+{
+	u16 reg;
+
+	/*
+	 *  Wait untill the BBP becomes ready.
+	 */
+	if (rt2x00_bbp_check(rt2x00dev) == 0xffff) {
+		ERROR("PHY_CSR8 register busy. Write failed.\n");
+		return;
+	}
+
+	/*
+	 * Write the data into the BBP.
+	 */
 	reg = 0;
 	rt2x00_set_field16(&reg, PHY_CSR7_BBP_DATA, value);
 	rt2x00_set_field16(&reg, PHY_CSR7_BBP_REG_ID, reg_id);
@@ -146,28 +160,35 @@
 	const u8 reg_id, u8 *value)
 {
 	u16 reg;
-	unsigned int i;
 
 	/*
-	 * First request the register we wish to read from.
+	 *  Wait untill the BBP becomes ready.
+	 */
+	if (rt2x00_bbp_check(rt2x00dev) == 0xffff) {
+		ERROR("PHY_CSR8 register busy. Read failed.\n");
+		return;
+	}
+
+	/*
+	 * Write the request into the BBP.
 	 */
+	reg =0;
 	rt2x00_set_field16(&reg, PHY_CSR7_BBP_REG_ID, reg_id);
 	rt2x00_set_field16(&reg, PHY_CSR7_BBP_READ_CONTROL, 1);
 
 	rt2x00_register_write(rt2x00dev, PHY_CSR7, reg);
 
-	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2x00_register_read(rt2x00dev, PHY_CSR8, &reg);
-		if (!rt2x00_get_field16(reg, PHY_CSR8_BBP_BUSY)) {
-			rt2x00_register_read(rt2x00dev, PHY_CSR7, &reg);
-			*value = rt2x00_get_field16(reg, PHY_CSR7_BBP_DATA);
-			return;
-		}
-		udelay(REGISTER_BUSY_DELAY);
+	/*
+	 *  Wait untill the BBP becomes ready.
+	 */
+	if (rt2x00_bbp_check(rt2x00dev) == 0xffff) {
+		ERROR("PHY_CSR8 register busy. Read failed.\n");
+		*value = 0xff;
+		return;
 	}
 
-	ERROR("BBPCSR register busy. Read failed.\n");
-	*value = 0xff;
+	rt2x00_register_read(rt2x00dev, PHY_CSR7, &reg);
+	*value = rt2x00_get_field16(reg, PHY_CSR7_BBP_DATA);
 }
 
 static void rt2x00_rf_write(const struct rt2x00_dev *rt2x00dev,
diff -rU3 wireless-dev-d80211/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-d80211/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 00:04:48.000000000 +0100
+++ wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 12:35:34.000000000 +0100
@@ -105,8 +105,7 @@
 	memcpy_toio(rt2x00dev->csr_addr + offset, value, length);
 }
 
-static void rt2x00_bbp_write(const struct rt2x00_dev *rt2x00dev,
-	const u8 reg_id, const u8 value)
+static u32 rt2x00_bbp_check(const struct rt2x00_dev *rt2x00dev)
 {
 	u32 reg;
 	unsigned int i;
@@ -114,14 +113,29 @@
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
 		rt2x00_register_read(rt2x00dev, PHY_CSR3, &reg);
 		if (!rt2x00_get_field32(reg, PHY_CSR3_BUSY))
-			goto bbp_write;
+			return reg;
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR("PHY_CSR3 register busy. Write failed.\n");
-	return;
+	return 0xffff;
+}
 
-bbp_write:
+static void rt2x00_bbp_write(const struct rt2x00_dev *rt2x00dev,
+	const u8 reg_id, const u8 value)
+{
+	u32 reg;
+
+	/*
+	 *  Wait untill the BBP becomes ready.
+	 */
+	if (rt2x00_bbp_check(rt2x00dev) == 0xffff) {
+		ERROR("PHY_CSR3 register busy. Write failed.\n");
+		return;
+	}
+
+	/*
+	 * Write the data into the BBP.
+	 */
 	reg = 0;
 	rt2x00_set_field32(&reg, PHY_CSR3_VALUE, value);
 	rt2x00_set_field32(&reg, PHY_CSR3_REGNUM, reg_id);
@@ -135,10 +149,17 @@
 	const u8 reg_id, u8 *value)
 {
 	u32 reg;
-	unsigned int i;
 
 	/*
-	 * First request the register we wish to read from.
+	 *  Wait untill the BBP becomes ready.
+	 */
+	if (rt2x00_bbp_check(rt2x00dev) == 0xffff) {
+		ERROR("PHY_CSR3 register busy. Read failed.\n");
+		return;
+	}
+
+	/*
+	 * Write the request into the BBP.
 	 */
 	reg =0;
 	rt2x00_set_field32(&reg, PHY_CSR3_REGNUM, reg_id);
@@ -147,17 +168,14 @@
 
 	rt2x00_register_write(rt2x00dev, PHY_CSR3, reg);
 
-	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2x00_register_read(rt2x00dev, PHY_CSR3, &reg);
-		if (!rt2x00_get_field32(reg, PHY_CSR3_BUSY)) {
-			*value = rt2x00_get_field32(reg, PHY_CSR3_VALUE);
-			return;
-		}
-		udelay(REGISTER_BUSY_DELAY);
-	}
+	/*
+	 *  Wait untill the BBP becomes ready.
+	 */
+	reg = rt2x00_bbp_check(rt2x00dev);
+	if (reg == 0xffff)
+		ERROR("PHY_CSR3 register busy. Read failed.\n");
 
-	ERROR("PHY_CSR3 register busy. Read failed.\n");
-	*value = 0xff;
+	*value = rt2x00_get_field32(reg, PHY_CSR3_VALUE);
 }
 
 static void rt2x00_rf_write(const struct rt2x00_dev *rt2x00dev,
diff -rU3 wireless-dev-d80211/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-d80211/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 00:13:18.000000000 +0100
+++ wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 12:35:52.000000000 +0100
@@ -119,8 +119,7 @@
 		offset, 0x00, value, length);
 }
 
-static void rt2x00_bbp_write(const struct rt2x00_dev *rt2x00dev,
-	const u8 reg_id, const u8 value)
+static u32 rt2x00_bbp_check(const struct rt2x00_dev *rt2x00dev)
 {
 	u32 reg;
 	unsigned int i;
@@ -128,14 +127,29 @@
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
 		rt2x00_register_read(rt2x00dev, PHY_CSR3, &reg);
 		if (!rt2x00_get_field32(reg, PHY_CSR3_BUSY))
-			goto bbp_write;
+			return reg;
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR("PHY_CSR3 register busy. Write failed.\n");
-	return;
+	return 0xffff;
+}
 
-bbp_write:
+static void rt2x00_bbp_write(const struct rt2x00_dev *rt2x00dev,
+	const u8 reg_id, const u8 value)
+{
+	u32 reg;
+
+	/*
+	 *  Wait untill the BBP becomes ready.
+	 */
+	if (rt2x00_bbp_check(rt2x00dev) == 0xffff) {
+		ERROR("PHY_CSR3 register busy. Write failed.\n");
+		return;
+	}
+
+	/*
+	 * Write the data into the BBP.
+	 */
 	reg = 0;
 	rt2x00_set_field32(&reg, PHY_CSR3_VALUE, value);
 	rt2x00_set_field32(&reg, PHY_CSR3_REGNUM, reg_id);
@@ -149,10 +163,17 @@
 	const u8 reg_id, u8 *value)
 {
 	u32 reg;
-	unsigned int i;
 
 	/*
-	 * First request the register we wish to read from.
+	 *  Wait untill the BBP becomes ready.
+	 */
+	if (rt2x00_bbp_check(rt2x00dev) == 0xffff) {
+		ERROR("PHY_CSR3 register busy. Read failed.\n");
+		return;
+	}
+
+	/*
+	 * Write the request into the BBP.
 	 */
 	reg =0;
 	rt2x00_set_field32(&reg, PHY_CSR3_REGNUM, reg_id);
@@ -161,17 +182,14 @@
 
 	rt2x00_register_write(rt2x00dev, PHY_CSR3, reg);
 
-	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2x00_register_read(rt2x00dev, PHY_CSR3, &reg);
-		if (!rt2x00_get_field32(reg, PHY_CSR3_BUSY)) {
-			*value = rt2x00_get_field32(reg, PHY_CSR3_VALUE);
-			return;
-		}
-		udelay(REGISTER_BUSY_DELAY);
-	}
+	/*
+	 *  Wait untill the BBP becomes ready.
+	 */
+	reg = rt2x00_bbp_check(rt2x00dev);
+	if (reg == 0xffff)
+		ERROR("PHY_CSR3 register busy. Read failed.\n");
 
-	ERROR("PHY_CSR3 register busy. Read failed.\n");
-	*value = 0xff;
+	*value = rt2x00_get_field32(reg, PHY_CSR3_VALUE);
 }
 
 static void rt2x00_rf_write(const struct rt2x00_dev *rt2x00dev,
