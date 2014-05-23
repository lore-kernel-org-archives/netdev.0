From: Prashant Sreedharan <prashant@broadcom.com>
Subject: [PATCH net-next] tg3: Override clock, link aware and link idle mode during NVRAM dump
Date: Fri, 23 May 2014 09:54:44 -0700
Message-ID: <1400864084-27118-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:22292 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbaEWQ5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 12:57:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When cable is not present the clock speed of some of the devices is
reduced based upon power saving mode setting in NVRAM. Due to this
NVRAM reads take long time to complete as a result CPU soft lockup
message is seen. Fix is to override clock, disable link aware and link
idle modes before NVRAM reads and restore them back after the reads
are complete. During this period also check if the thread needs to be
rescheduled and if there are any signals to handle.

Also decrease the NVRAM command execution timeout value to 1ms.

Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   44 +++++++++++++++++++++++++++++-----
 1 files changed, 37 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ccd9015..c59e938 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3224,7 +3224,7 @@ static int tg3_nvram_read_using_eeprom(struct tg3 *tp,
 	return 0;
 }
 
-#define NVRAM_CMD_TIMEOUT 10000
+#define NVRAM_CMD_TIMEOUT 100
 
 static int tg3_nvram_exec_cmd(struct tg3 *tp, u32 nvram_cmd)
 {
@@ -11893,9 +11893,9 @@ static int tg3_get_eeprom_len(struct net_device *dev)
 static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom, u8 *data)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	int ret;
+	int ret, cpmu_restore = 0;
 	u8  *pd;
-	u32 i, offset, len, b_offset, b_count;
+	u32 i, offset, len, b_offset, b_count, cpmu_val = 0;
 	__be32 val;
 
 	if (tg3_flag(tp, NO_NVRAM))
@@ -11907,6 +11907,20 @@ static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 
 	eeprom->magic = TG3_EEPROM_MAGIC;
 
+	/* Override clock, link aware and link idle modes */
+	if (tg3_flag(tp, CPMU_PRESENT)) {
+		cpmu_val = tr32(TG3_CPMU_CTRL);
+		if (cpmu_val & (CPMU_CTRL_LINK_AWARE_MODE |
+				CPMU_CTRL_LINK_IDLE_MODE)) {
+
+			tw32(TG3_CPMU_CTRL, cpmu_val &
+			     ~(CPMU_CTRL_LINK_AWARE_MODE |
+			       CPMU_CTRL_LINK_IDLE_MODE));
+			cpmu_restore = 1;
+		}
+	}
+	tg3_override_clk(tp);
+
 	if (offset & 3) {
 		/* adjustments to start on required 4 byte boundary */
 		b_offset = offset & 3;
@@ -11917,7 +11931,7 @@ static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 		}
 		ret = tg3_nvram_read_be32(tp, offset-b_offset, &val);
 		if (ret)
-			return ret;
+			goto eeprom_done;
 		memcpy(data, ((char *)&val) + b_offset, b_count);
 		len -= b_count;
 		offset += b_count;
@@ -11927,10 +11941,18 @@ static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	/* read bytes up to the last 4 byte boundary */
 	pd = &data[eeprom->len];
 	for (i = 0; i < (len - (len & 3)); i += 4) {
+		if (need_resched()) {
+			if (signal_pending(current)) {
+				eeprom->len += i;
+				ret = -EINTR;
+				goto eeprom_done;
+			}
+			cond_resched();
+		}
 		ret = tg3_nvram_read_be32(tp, offset + i, &val);
 		if (ret) {
 			eeprom->len += i;
-			return ret;
+			goto eeprom_done;
 		}
 		memcpy(pd + i, &val, 4);
 	}
@@ -11943,11 +11965,19 @@ static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 		b_offset = offset + len - b_count;
 		ret = tg3_nvram_read_be32(tp, b_offset, &val);
 		if (ret)
-			return ret;
+			goto eeprom_done;
 		memcpy(pd, &val, b_count);
 		eeprom->len += b_count;
 	}
-	return 0;
+	ret = 0;
+
+eeprom_done:
+	/* Restore clock, link aware and link idle modes */
+	tg3_restore_clk(tp);
+	if (cpmu_restore)
+		tw32(TG3_CPMU_CTRL, cpmu_val);
+
+	return ret;
 }
 
 static int tg3_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom, u8 *data)
-- 
1.7.1
