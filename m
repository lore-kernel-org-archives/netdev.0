From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/3] dsa: mv88e6xxx: Timeout based on iterations, not time
Date: Fri, 19 Aug 2016 00:01:55 +0200
Message-ID: <1471557717-21852-2-git-send-email-andrew@lunn.ch>
References: <1471557717-21852-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38660 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754032AbcHSBzN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 21:55:13 -0400
In-Reply-To: <1471557717-21852-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6xxx driver times out operations on the switch based on
looping until an elapsed wall clock time is reached. However, if
usleep_range() sleeps much longer than expected, it could timeout with
an error without actually checking to see if the devices has completed
the operation. So replace the elapsed time with a fixed upper bound on
the number of loops.

Testing on various switches has shown that switches takes either 0 or
1 iteration, so a maximum of 16 iterations is a safe limit.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index a230fcba5b64..ac8e9af4879f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -309,9 +309,9 @@ static int mv88e6xxx_serdes_write(struct mv88e6xxx_chip *chip, int reg, u16 val)
 static int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg,
 			  u16 mask)
 {
-	unsigned long timeout = jiffies + HZ / 10;
+	int i;
 
-	while (time_before(jiffies, timeout)) {
+	for (i = 0; i < 16; i++) {
 		u16 val;
 		int err;
 
@@ -375,7 +375,7 @@ static int _mv88e6xxx_reg_write(struct mv88e6xxx_chip *chip, int addr,
 static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 {
 	int ret;
-	unsigned long timeout;
+	int i;
 
 	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_CONTROL);
 	if (ret < 0)
@@ -386,8 +386,7 @@ static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 	if (ret)
 		return ret;
 
-	timeout = jiffies + 1 * HZ;
-	while (time_before(jiffies, timeout)) {
+	for (i = 0; i < 16; i++) {
 		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_STATUS);
 		if (ret < 0)
 			return ret;
@@ -403,8 +402,7 @@ static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 
 static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
 {
-	int ret, err;
-	unsigned long timeout;
+	int ret, err, i;
 
 	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_CONTROL);
 	if (ret < 0)
@@ -415,8 +413,7 @@ static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	timeout = jiffies + 1 * HZ;
-	while (time_before(jiffies, timeout)) {
+	for (i = 0; i < 16; i++) {
 		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_STATUS);
 		if (ret < 0)
 			return ret;
-- 
2.8.1
