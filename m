From: Corey Ashford <cjashfor@linux.vnet.ibm.com>
Subject: [PATCH net 1/1] RFC: drivers/net/phy: Fix for a BCM5482S auto-negotion problem
Date: Sat,  7 Sep 2013 14:04:19 -0700
Message-ID: <1378587859-29358-1-git-send-email-cjashfor@linux.vnet.ibm.com>
Cc: Corey Ashford <cjashfor@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:45231 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918Ab3IGVEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 17:04:52 -0400
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cjashfor@linux.vnet.ibm.com>;
	Sun, 8 Sep 2013 02:24:02 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 86FCA394004D
	for <netdev@vger.kernel.org>; Sun,  8 Sep 2013 02:34:35 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r87L6duC45678756
	for <netdev@vger.kernel.org>; Sun, 8 Sep 2013 02:36:40 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r87L4l1w006614
	for <netdev@vger.kernel.org>; Sun, 8 Sep 2013 02:34:47 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a 1Gb network interface is used in SGMII mode off, and then
a Broadcom 5482S is used to redrive SGMII (SGMII to SGMII mode)
to a Broadcom 54616 PHY, the standard PHY registers do not appear to
be updated correctly after auto-negotiation.  This causes the
kernel to get confused about the state of the link and also
causes the MAC layer driver to inappropriately configure the MAC.

By 'standard' registers I mean those that are read by genphy_read_link
(MII_BMSR, 0x01) and genphy_read_status (MII_STAT1000, 0x0a; MII_CTRL1000,
0x09; MII_LPA, 0x05).

Here are the register dumps for the various configurations:

SGMII-to-SGMII mode, 1Gb, full duplex:

# /var/dump1GPhy
Shadow register '11111'=0x00007E5C
Dumping registers for PHY at port e:
PHY register 0=0x00001140
PHY register 1=0x00007949
PHY register 2=0x00000143
PHY register 3=0x0000BCB2
PHY register 4=0x000001E1
PHY register 5=0x00000000
PHY register 6=0x00000064
PHY register 7=0x00002001
PHY register 8=0x00000000
PHY register 9=0x00000200
PHY register A=0x00000000
PHY register B=0x00000000
PHY register C=0x00000000
PHY register D=0x00000000
PHY register E=0x00000000
PHY register F=0x00003000
PHY register 10=0x00001000
PHY register 11=0x00002000
PHY register 12=0x00000000
PHY register 13=0x00000C00
PHY register 14=0x00000000
PHY register 15=0x00000000
PHY register 16=0x00000000
PHY register 17=0x00000000
PHY register 18=0x00000400
PHY register 19=0x00001000
PHY register 1A=0x00000000
PHY register 1B=0x0000FFF1
PHY register 1C=0x00007E5C
PHY register 1D=0x00000000
PHY register 1E=0x00000000
PHY register 1F=0x00000000
PHY expansion register E00=0x00001140
PHY expansion register E01=0x0000016D
PHY expansion register E02=0x00000143
PHY expansion register E03=0x0000BCB2
PHY expansion register E04=0x00000001
PHY expansion register E05=0x0000D801
PHY expansion register E06=0x00000064
PHY expansion register E07=0x00002001
PHY expansion register E08=0x00000000
PHY expansion register E09=0x00000000
PHY expansion register E0A=0x00000000
PHY expansion register E0B=0x00000000
PHY expansion register E0C=0x00000000
PHY expansion register E0D=0x00000000
PHY expansion register E0E=0x00000000
PHY expansion register E0F=0x0000C000
PHY expansion register E10=0x00000000
PHY expansion register E11=0x00000000
PHY expansion register E12=0x00000080
PHY expansion register E13=0x00000089
PHY expansion register E14=0x00000000
PHY expansion register E15=0x0000038A
PHY expansion register E16=0x0000002E
Mode status register = 0x0000D072
Successfully completed!


SGMII-to-SGMII mode, 100Mb, half duplex:

# /var/dump1GPhy
Shadow register '11111'=0x00007E5C
Dumping registers for PHY at port e:
PHY register 0=0x00001140
PHY register 1=0x00007949
PHY register 2=0x00000143
PHY register 3=0x0000BCB2
PHY register 4=0x000001E1
PHY register 5=0x00000000
PHY register 6=0x00000064
PHY register 7=0x00002001
PHY register 8=0x00000000
PHY register 9=0x00000200
PHY register A=0x00000000
PHY register B=0x00000000
PHY register C=0x00000000
PHY register D=0x00000000
PHY register E=0x00000000
PHY register F=0x00003000
PHY register 10=0x00001000
PHY register 11=0x00002000
PHY register 12=0x00000000
PHY register 13=0x00000C00
PHY register 14=0x00000000
PHY register 15=0x00000000
PHY register 16=0x00000000
PHY register 17=0x00000000
PHY register 18=0x00000400
PHY register 19=0x00001000
PHY register 1A=0x00000000
PHY register 1B=0x0000FFF1
PHY register 1C=0x00007E5C
PHY register 1D=0x00000000
PHY register 1E=0x00000000
PHY register 1F=0x00000000
PHY expansion register E00=0x00001140
PHY expansion register E01=0x00000169
PHY expansion register E02=0x00000143
PHY expansion register E03=0x0000BCB2
PHY expansion register E04=0x00000001
PHY expansion register E05=0x0000C401
PHY expansion register E06=0x00000066
PHY expansion register E07=0x00002001
PHY expansion register E08=0x00000000
PHY expansion register E09=0x00000000
PHY expansion register E0A=0x00000000
PHY expansion register E0B=0x00000000
PHY expansion register E0C=0x00000000
PHY expansion register E0D=0x00000000
PHY expansion register E0E=0x00000000
PHY expansion register E0F=0x0000C000
PHY expansion register E10=0x00000000
PHY expansion register E11=0x00000000
PHY expansion register E12=0x00000080
PHY expansion register E13=0x00000058
PHY expansion register E14=0x00000000
PHY expansion register E15=0x0000026A
PHY expansion register E16=0x0000002E
Mode status register = 0x0000A072
Successfully completed!


SGMII-to-serdes, 1Gb, full duplex:

# /var/dump1GPhy
Shadow register '11111'=0x00007E5C
Dumping registers for PHY at port e:
PHY register 0=0x00001140
PHY register 1=0x00007949
PHY register 2=0x00000143
PHY register 3=0x0000BCB2
PHY register 4=0x000001E1
PHY register 5=0x00000000
PHY register 6=0x00000064
PHY register 7=0x00002001
PHY register 8=0x00000000
PHY register 9=0x00000200
PHY register A=0x00000000
PHY register B=0x00000000
PHY register C=0x00000000
PHY register D=0x00000000
PHY register E=0x00000000
PHY register F=0x00003000
PHY register 10=0x00001000
PHY register 11=0x00000000
PHY register 12=0x00000000
PHY register 13=0x00000C00
PHY register 14=0x00000000
PHY register 15=0x0000D072
PHY register 16=0x00000000
PHY register 17=0x00000F42
PHY register 18=0x00000400
PHY register 19=0x00001000
PHY register 1A=0x00000000
PHY register 1B=0x0000FFF1
PHY register 1C=0x00007E5C
PHY register 1D=0x00000000
PHY register 1E=0x00000000
PHY register 1F=0x00000000
PHY expansion register E00=0x00001140
PHY expansion register E01=0x0000014D
PHY expansion register E02=0x00000143
PHY expansion register E03=0x0000BCB2
PHY expansion register E04=0x00000060
PHY expansion register E05=0x00000000
PHY expansion register E06=0x00000064
PHY expansion register E07=0x00002001
PHY expansion register E08=0x00000000
PHY expansion register E09=0x00000000
PHY expansion register E0A=0x00000000
PHY expansion register E0B=0x00000000
PHY expansion register E0C=0x00000000
PHY expansion register E0D=0x00000000
PHY expansion register E0E=0x00000000
PHY expansion register E0F=0x0000C000
PHY expansion register E10=0x00000000
PHY expansion register E11=0x00000000
PHY expansion register E12=0x00000080
PHY expansion register E13=0x000002D3
PHY expansion register E14=0x00000000
PHY expansion register E15=0x00000388
PHY expansion register E16=0x0000002E
Mode status register = 0x0000D072
Successfully completed!

Signed-off-by: Corey Ashford <cjashfor@linux.vnet.ibm.com>
---
 drivers/net/phy/broadcom.c | 37 +++++++++++++++++++++++++++----------
 1 file changed, 27 insertions(+), 10 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index f8c90ea..9f5d076 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -142,6 +142,13 @@
 #define  MII_BCM54XX_EXP_EXP96_MYST		0x0010
 #define MII_BCM54XX_EXP_EXP97			0x0f97
 #define  MII_BCM54XX_EXP_EXP97_MYST		0x0c0c
+#define MII_BCM54XX_EXP_OPER_MODE		(MII_BCM54XX_EXP_SEL_ER | 0x42)
+#define MII_BCM54XX_EXP_OPER_MODE_SERDES_LINK		0x8000
+#define MII_BCM54XX_EXP_OPER_MODE_SERDES_SPEED_MASK	0x6000
+#define MII_BCM54XX_EXP_OPER_MODE_SERDES_SPEED_1000	0x4000
+#define MII_BCM54XX_EXP_OPER_MODE_SERDES_SPEED_100	0x2000
+#define MII_BCM54XX_EXP_OPER_MODE_SERDES_SPEED_10	0x0000
+#define MII_BCM54XX_EXP_OPER_MODE_SERDES_DUPLEX		0x1000
 
 /*
  * BCM5482: Secondary SerDes registers
@@ -491,21 +498,31 @@ static int bcm5482_config_init(struct phy_device *phydev)
 static int bcm5482_read_status(struct phy_device *phydev)
 {
 	int err;
+	err = bcm54xx_exp_read(phydev, MII_BCM54XX_EXP_OPER_MODE);
+	if (err < 0)
+		return err;
 
-	err = genphy_read_status(phydev);
+	phydev->link = ((err & MII_BCM54XX_EXP_OPER_MODE_SERDES_LINK) ==
+		MII_BCM54XX_EXP_OPER_MODE_SERDES_LINK);
 
-	if (phydev->dev_flags & PHY_BCM_FLAGS_MODE_1000BX) {
-		/*
-		 * Only link status matters for 1000Base-X mode, so force
-		 * 1000 Mbit/s full-duplex status
-		 */
-		if (phydev->link) {
+	if (phydev->link) {
+		switch (err & MII_BCM54XX_EXP_OPER_MODE_SERDES_SPEED_MASK) {
+		case MII_BCM54XX_EXP_OPER_MODE_SERDES_SPEED_1000:
 			phydev->speed = SPEED_1000;
-			phydev->duplex = DUPLEX_FULL;
+			break;
+		case MII_BCM54XX_EXP_OPER_MODE_SERDES_SPEED_100:
+			phydev->speed = SPEED_100;
+			break;
+		default:
+			phydev->speed = SPEED_10;
+			break;
 		}
+		if (err & MII_BCM54XX_EXP_OPER_MODE_SERDES_DUPLEX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
 	}
-
-	return err;
+	return 0;
 }
 
 static int bcm54xx_ack_interrupt(struct phy_device *phydev)
-- 
1.8.1.4
