From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: dsa/mv88e6352: make mv88e6352_wait generic
Date: Fri, 23 Jan 2015 18:34:41 -0500
Message-ID: <1422056081-30088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:53323 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbbAWXeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 18:34:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some busy bits are available in the global register 1, such as the ATU
Busy bit. We may want to use this function to wait for them to change,
so add a new parameter to mv88e6352_wait() instead of hard-coding
REG_GLOBAL2.

In the meantime, since the REG_READ() macro already checks for error,
remove the redundant check for ret < 0.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6352.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 258d9ef..e13adc7 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -22,17 +22,14 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-static int mv88e6352_wait(struct dsa_switch *ds, int reg, u16 mask)
+static int mv88e6352_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
 {
 	unsigned long timeout = jiffies + HZ / 10;
 
 	while (time_before(jiffies, timeout)) {
 		int ret;
 
-		ret = REG_READ(REG_GLOBAL2, reg);
-		if (ret < 0)
-			return ret;
-
+		ret = REG_READ(reg, offset);
 		if (!(ret & mask))
 			return 0;
 
@@ -43,17 +40,17 @@ static int mv88e6352_wait(struct dsa_switch *ds, int reg, u16 mask)
 
 static inline int mv88e6352_phy_wait(struct dsa_switch *ds)
 {
-	return mv88e6352_wait(ds, 0x18, 0x8000);
+	return mv88e6352_wait(ds, REG_GLOBAL2, 0x18, 0x8000);
 }
 
 static inline int mv88e6352_eeprom_load_wait(struct dsa_switch *ds)
 {
-	return mv88e6352_wait(ds, 0x14, 0x0800);
+	return mv88e6352_wait(ds, REG_GLOBAL2, 0x14, 0x0800);
 }
 
 static inline int mv88e6352_eeprom_busy_wait(struct dsa_switch *ds)
 {
-	return mv88e6352_wait(ds, 0x14, 0x8000);
+	return mv88e6352_wait(ds, REG_GLOBAL2, 0x14, 0x8000);
 }
 
 static int __mv88e6352_phy_read(struct dsa_switch *ds, int addr, int regnum)
-- 
2.2.2
