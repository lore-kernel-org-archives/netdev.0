From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 05/14] tg3: Eliminate nvram routine forward declarations
Date: Wed, 25 Feb 2009 16:24:28 -0800
Message-ID: <1235616372.16007@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1875 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753627AbZBZCqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves all NVRAM routines earlier in the source file to
eliminate forward declarations.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |  388 ++++++++++++++++++++++++++---------------------------
 1 files changed, 191 insertions(+), 197 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ce29097..d32b3ef 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2050,8 +2050,6 @@ static int tg3_setup_phy(struct tg3 *, int);
 
 static void tg3_write_sig_post_reset(struct tg3 *, int);
 static int tg3_halt_cpu(struct tg3 *, u32);
-static int tg3_nvram_lock(struct tg3 *);
-static void tg3_nvram_unlock(struct tg3 *);
 
 static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 {
@@ -2108,6 +2106,197 @@ static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 }
 
 /* tp->lock is held. */
+static int tg3_nvram_lock(struct tg3 *tp)
+{
+	if (tp->tg3_flags & TG3_FLAG_NVRAM) {
+		int i;
+
+		if (tp->nvram_lock_cnt == 0) {
+			tw32(NVRAM_SWARB, SWARB_REQ_SET1);
+			for (i = 0; i < 8000; i++) {
+				if (tr32(NVRAM_SWARB) & SWARB_GNT1)
+					break;
+				udelay(20);
+			}
+			if (i == 8000) {
+				tw32(NVRAM_SWARB, SWARB_REQ_CLR1);
+				return -ENODEV;
+			}
+		}
+		tp->nvram_lock_cnt++;
+	}
+	return 0;
+}
+
+/* tp->lock is held. */
+static void tg3_nvram_unlock(struct tg3 *tp)
+{
+	if (tp->tg3_flags & TG3_FLAG_NVRAM) {
+		if (tp->nvram_lock_cnt > 0)
+			tp->nvram_lock_cnt--;
+		if (tp->nvram_lock_cnt == 0)
+			tw32_f(NVRAM_SWARB, SWARB_REQ_CLR1);
+	}
+}
+
+/* tp->lock is held. */
+static void tg3_enable_nvram_access(struct tg3 *tp)
+{
+	if ((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
+	    !(tp->tg3_flags2 & TG3_FLG2_PROTECTED_NVRAM)) {
+		u32 nvaccess = tr32(NVRAM_ACCESS);
+
+		tw32(NVRAM_ACCESS, nvaccess | ACCESS_ENABLE);
+	}
+}
+
+/* tp->lock is held. */
+static void tg3_disable_nvram_access(struct tg3 *tp)
+{
+	if ((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
+	    !(tp->tg3_flags2 & TG3_FLG2_PROTECTED_NVRAM)) {
+		u32 nvaccess = tr32(NVRAM_ACCESS);
+
+		tw32(NVRAM_ACCESS, nvaccess & ~ACCESS_ENABLE);
+	}
+}
+
+static int tg3_nvram_read_using_eeprom(struct tg3 *tp,
+					u32 offset, u32 *val)
+{
+	u32 tmp;
+	int i;
+
+	if (offset > EEPROM_ADDR_ADDR_MASK || (offset % 4) != 0)
+		return -EINVAL;
+
+	tmp = tr32(GRC_EEPROM_ADDR) & ~(EEPROM_ADDR_ADDR_MASK |
+					EEPROM_ADDR_DEVID_MASK |
+					EEPROM_ADDR_READ);
+	tw32(GRC_EEPROM_ADDR,
+	     tmp |
+	     (0 << EEPROM_ADDR_DEVID_SHIFT) |
+	     ((offset << EEPROM_ADDR_ADDR_SHIFT) &
+	      EEPROM_ADDR_ADDR_MASK) |
+	     EEPROM_ADDR_READ | EEPROM_ADDR_START);
+
+	for (i = 0; i < 1000; i++) {
+		tmp = tr32(GRC_EEPROM_ADDR);
+
+		if (tmp & EEPROM_ADDR_COMPLETE)
+			break;
+		msleep(1);
+	}
+	if (!(tmp & EEPROM_ADDR_COMPLETE))
+		return -EBUSY;
+
+	*val = tr32(GRC_EEPROM_DATA);
+	return 0;
+}
+
+#define NVRAM_CMD_TIMEOUT 10000
+
+static int tg3_nvram_exec_cmd(struct tg3 *tp, u32 nvram_cmd)
+{
+	int i;
+
+	tw32(NVRAM_CMD, nvram_cmd);
+	for (i = 0; i < NVRAM_CMD_TIMEOUT; i++) {
+		udelay(10);
+		if (tr32(NVRAM_CMD) & NVRAM_CMD_DONE) {
+			udelay(10);
+			break;
+		}
+	}
+
+	if (i == NVRAM_CMD_TIMEOUT)
+		return -EBUSY;
+
+	return 0;
+}
+
+static u32 tg3_nvram_phys_addr(struct tg3 *tp, u32 addr)
+{
+	if ((tp->tg3_flags & TG3_FLAG_NVRAM) &&
+	    (tp->tg3_flags & TG3_FLAG_NVRAM_BUFFERED) &&
+	    (tp->tg3_flags2 & TG3_FLG2_FLASH) &&
+	   !(tp->tg3_flags3 & TG3_FLG3_NO_NVRAM_ADDR_TRANS) &&
+	    (tp->nvram_jedecnum == JEDEC_ATMEL))
+
+		addr = ((addr / tp->nvram_pagesize) <<
+			ATMEL_AT45DB0X1B_PAGE_POS) +
+		       (addr % tp->nvram_pagesize);
+
+	return addr;
+}
+
+static u32 tg3_nvram_logical_addr(struct tg3 *tp, u32 addr)
+{
+	if ((tp->tg3_flags & TG3_FLAG_NVRAM) &&
+	    (tp->tg3_flags & TG3_FLAG_NVRAM_BUFFERED) &&
+	    (tp->tg3_flags2 & TG3_FLG2_FLASH) &&
+	   !(tp->tg3_flags3 & TG3_FLG3_NO_NVRAM_ADDR_TRANS) &&
+	    (tp->nvram_jedecnum == JEDEC_ATMEL))
+
+		addr = ((addr >> ATMEL_AT45DB0X1B_PAGE_POS) *
+			tp->nvram_pagesize) +
+		       (addr & ((1 << ATMEL_AT45DB0X1B_PAGE_POS) - 1));
+
+	return addr;
+}
+
+static int tg3_nvram_read(struct tg3 *tp, u32 offset, u32 *val)
+{
+	int ret;
+
+	if (!(tp->tg3_flags & TG3_FLAG_NVRAM))
+		return tg3_nvram_read_using_eeprom(tp, offset, val);
+
+	offset = tg3_nvram_phys_addr(tp, offset);
+
+	if (offset > NVRAM_ADDR_MSK)
+		return -EINVAL;
+
+	ret = tg3_nvram_lock(tp);
+	if (ret)
+		return ret;
+
+	tg3_enable_nvram_access(tp);
+
+	tw32(NVRAM_ADDR, offset);
+	ret = tg3_nvram_exec_cmd(tp, NVRAM_CMD_RD | NVRAM_CMD_GO |
+		NVRAM_CMD_FIRST | NVRAM_CMD_LAST | NVRAM_CMD_DONE);
+
+	if (ret == 0)
+		*val = swab32(tr32(NVRAM_RDDATA));
+
+	tg3_disable_nvram_access(tp);
+
+	tg3_nvram_unlock(tp);
+
+	return ret;
+}
+
+static int tg3_nvram_read_swab(struct tg3 *tp, u32 offset, u32 *val)
+{
+	int err;
+	u32 tmp;
+
+	err = tg3_nvram_read(tp, offset, &tmp);
+	*val = swab32(tmp);
+	return err;
+}
+
+static int tg3_nvram_read_le(struct tg3 *tp, u32 offset, __le32 *val)
+{
+	u32 v;
+	int res = tg3_nvram_read(tp, offset, &v);
+	if (!res)
+		*val = cpu_to_le32(v);
+	return res;
+}
+
+/* tp->lock is held. */
 static void __tg3_set_mac_addr(struct tg3 *tp, int skip_mac_1)
 {
 	u32 addr_high, addr_low;
@@ -5638,62 +5827,6 @@ static int tg3_abort_hw(struct tg3 *tp, int silent)
 	return err;
 }
 
-/* tp->lock is held. */
-static int tg3_nvram_lock(struct tg3 *tp)
-{
-	if (tp->tg3_flags & TG3_FLAG_NVRAM) {
-		int i;
-
-		if (tp->nvram_lock_cnt == 0) {
-			tw32(NVRAM_SWARB, SWARB_REQ_SET1);
-			for (i = 0; i < 8000; i++) {
-				if (tr32(NVRAM_SWARB) & SWARB_GNT1)
-					break;
-				udelay(20);
-			}
-			if (i == 8000) {
-				tw32(NVRAM_SWARB, SWARB_REQ_CLR1);
-				return -ENODEV;
-			}
-		}
-		tp->nvram_lock_cnt++;
-	}
-	return 0;
-}
-
-/* tp->lock is held. */
-static void tg3_nvram_unlock(struct tg3 *tp)
-{
-	if (tp->tg3_flags & TG3_FLAG_NVRAM) {
-		if (tp->nvram_lock_cnt > 0)
-			tp->nvram_lock_cnt--;
-		if (tp->nvram_lock_cnt == 0)
-			tw32_f(NVRAM_SWARB, SWARB_REQ_CLR1);
-	}
-}
-
-/* tp->lock is held. */
-static void tg3_enable_nvram_access(struct tg3 *tp)
-{
-	if ((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
-	    !(tp->tg3_flags2 & TG3_FLG2_PROTECTED_NVRAM)) {
-		u32 nvaccess = tr32(NVRAM_ACCESS);
-
-		tw32(NVRAM_ACCESS, nvaccess | ACCESS_ENABLE);
-	}
-}
-
-/* tp->lock is held. */
-static void tg3_disable_nvram_access(struct tg3 *tp)
-{
-	if ((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
-	    !(tp->tg3_flags2 & TG3_FLG2_PROTECTED_NVRAM)) {
-		u32 nvaccess = tr32(NVRAM_ACCESS);
-
-		tw32(NVRAM_ACCESS, nvaccess & ~ACCESS_ENABLE);
-	}
-}
-
 static void tg3_ape_send_event(struct tg3 *tp, u32 event)
 {
 	int i;
@@ -8394,10 +8527,6 @@ static int tg3_get_eeprom_len(struct net_device *dev)
 	return tp->nvram_size;
 }
 
-static int tg3_nvram_read(struct tg3 *tp, u32 offset, u32 *val);
-static int tg3_nvram_read_le(struct tg3 *tp, u32 offset, __le32 *val);
-static int tg3_nvram_read_swab(struct tg3 *tp, u32 offset, u32 *val);
-
 static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom, u8 *data)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -10511,141 +10640,6 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 	}
 }
 
-static int tg3_nvram_read_using_eeprom(struct tg3 *tp,
-					u32 offset, u32 *val)
-{
-	u32 tmp;
-	int i;
-
-	if (offset > EEPROM_ADDR_ADDR_MASK ||
-	    (offset % 4) != 0)
-		return -EINVAL;
-
-	tmp = tr32(GRC_EEPROM_ADDR) & ~(EEPROM_ADDR_ADDR_MASK |
-					EEPROM_ADDR_DEVID_MASK |
-					EEPROM_ADDR_READ);
-	tw32(GRC_EEPROM_ADDR,
-	     tmp |
-	     (0 << EEPROM_ADDR_DEVID_SHIFT) |
-	     ((offset << EEPROM_ADDR_ADDR_SHIFT) &
-	      EEPROM_ADDR_ADDR_MASK) |
-	     EEPROM_ADDR_READ | EEPROM_ADDR_START);
-
-	for (i = 0; i < 1000; i++) {
-		tmp = tr32(GRC_EEPROM_ADDR);
-
-		if (tmp & EEPROM_ADDR_COMPLETE)
-			break;
-		msleep(1);
-	}
-	if (!(tmp & EEPROM_ADDR_COMPLETE))
-		return -EBUSY;
-
-	*val = tr32(GRC_EEPROM_DATA);
-	return 0;
-}
-
-#define NVRAM_CMD_TIMEOUT 10000
-
-static int tg3_nvram_exec_cmd(struct tg3 *tp, u32 nvram_cmd)
-{
-	int i;
-
-	tw32(NVRAM_CMD, nvram_cmd);
-	for (i = 0; i < NVRAM_CMD_TIMEOUT; i++) {
-		udelay(10);
-		if (tr32(NVRAM_CMD) & NVRAM_CMD_DONE) {
-			udelay(10);
-			break;
-		}
-	}
-	if (i == NVRAM_CMD_TIMEOUT) {
-		return -EBUSY;
-	}
-	return 0;
-}
-
-static u32 tg3_nvram_phys_addr(struct tg3 *tp, u32 addr)
-{
-	if ((tp->tg3_flags & TG3_FLAG_NVRAM) &&
-	    (tp->tg3_flags & TG3_FLAG_NVRAM_BUFFERED) &&
-	    (tp->tg3_flags2 & TG3_FLG2_FLASH) &&
-	   !(tp->tg3_flags3 & TG3_FLG3_NO_NVRAM_ADDR_TRANS) &&
-	    (tp->nvram_jedecnum == JEDEC_ATMEL))
-
-		addr = ((addr / tp->nvram_pagesize) <<
-			ATMEL_AT45DB0X1B_PAGE_POS) +
-		       (addr % tp->nvram_pagesize);
-
-	return addr;
-}
-
-static u32 tg3_nvram_logical_addr(struct tg3 *tp, u32 addr)
-{
-	if ((tp->tg3_flags & TG3_FLAG_NVRAM) &&
-	    (tp->tg3_flags & TG3_FLAG_NVRAM_BUFFERED) &&
-	    (tp->tg3_flags2 & TG3_FLG2_FLASH) &&
-	   !(tp->tg3_flags3 & TG3_FLG3_NO_NVRAM_ADDR_TRANS) &&
-	    (tp->nvram_jedecnum == JEDEC_ATMEL))
-
-		addr = ((addr >> ATMEL_AT45DB0X1B_PAGE_POS) *
-			tp->nvram_pagesize) +
-		       (addr & ((1 << ATMEL_AT45DB0X1B_PAGE_POS) - 1));
-
-	return addr;
-}
-
-static int tg3_nvram_read(struct tg3 *tp, u32 offset, u32 *val)
-{
-	int ret;
-
-	if (!(tp->tg3_flags & TG3_FLAG_NVRAM))
-		return tg3_nvram_read_using_eeprom(tp, offset, val);
-
-	offset = tg3_nvram_phys_addr(tp, offset);
-
-	if (offset > NVRAM_ADDR_MSK)
-		return -EINVAL;
-
-	ret = tg3_nvram_lock(tp);
-	if (ret)
-		return ret;
-
-	tg3_enable_nvram_access(tp);
-
-	tw32(NVRAM_ADDR, offset);
-	ret = tg3_nvram_exec_cmd(tp, NVRAM_CMD_RD | NVRAM_CMD_GO |
-		NVRAM_CMD_FIRST | NVRAM_CMD_LAST | NVRAM_CMD_DONE);
-
-	if (ret == 0)
-		*val = swab32(tr32(NVRAM_RDDATA));
-
-	tg3_disable_nvram_access(tp);
-
-	tg3_nvram_unlock(tp);
-
-	return ret;
-}
-
-static int tg3_nvram_read_le(struct tg3 *tp, u32 offset, __le32 *val)
-{
-	u32 v;
-	int res = tg3_nvram_read(tp, offset, &v);
-	if (!res)
-		*val = cpu_to_le32(v);
-	return res;
-}
-
-static int tg3_nvram_read_swab(struct tg3 *tp, u32 offset, u32 *val)
-{
-	int err;
-	u32 tmp;
-
-	err = tg3_nvram_read(tp, offset, &tmp);
-	*val = swab32(tmp);
-	return err;
-}
-
 static int tg3_nvram_write_block_using_eeprom(struct tg3 *tp,
 				    u32 offset, u32 len, u8 *buf)
 {
-- 
1.6.0.6


