From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/7][TG3]: Fix Phy loopback.
Date: Wed, 06 Dec 2006 23:46:06 -0800
Message-ID: <1165477566.8488.27.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3189 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031734AbWLGG4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 01:56:08 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Fix Phy loopback.

Phy loopback on most 10/100 devices need to be run in 1Gbps mode in
GMII mode.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c20bb99..819758e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8781,17 +8781,20 @@ static int tg3_run_loopback(struct tg3 *
 					tg3_writephy(tp, 0x10, phy & ~0x4000);
 				tg3_writephy(tp, MII_TG3_EPHY_TEST, phytest);
 			}
-		}
-		val = BMCR_LOOPBACK | BMCR_FULLDPLX;
-		if (tp->tg3_flags & TG3_FLAG_10_100_ONLY)
-			val |= BMCR_SPEED100;
-		else
-			val |= BMCR_SPEED1000;
+			val = BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED100;
+		} else
+			val = BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED1000;
 
 		tg3_writephy(tp, MII_BMCR, val);
 		udelay(40);
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+
+		mac_mode = (tp->mac_mode & ~MAC_MODE_PORT_MODE_MASK) |
+			   MAC_MODE_LINK_POLARITY;
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 			tg3_writephy(tp, MII_TG3_EPHY_PTEST, 0x1800);
+			mac_mode |= MAC_MODE_PORT_MODE_MII;
+		} else
+			mac_mode |= MAC_MODE_PORT_MODE_GMII;
 
 		/* reset to prevent losing 1st rx packet intermittently */
 		if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES) {
@@ -8799,12 +8802,6 @@ static int tg3_run_loopback(struct tg3 *
 			udelay(10);
 			tw32_f(MAC_RX_MODE, tp->rx_mode);
 		}
-		mac_mode = (tp->mac_mode & ~MAC_MODE_PORT_MODE_MASK) |
-			   MAC_MODE_LINK_POLARITY;
-		if (tp->tg3_flags & TG3_FLAG_10_100_ONLY)
-			mac_mode |= MAC_MODE_PORT_MODE_MII;
-		else
-			mac_mode |= MAC_MODE_PORT_MODE_GMII;
 		if ((tp->phy_id & PHY_ID_MASK) == PHY_ID_BCM5401) {
 			mac_mode &= ~MAC_MODE_LINK_POLARITY;
 			tg3_writephy(tp, MII_TG3_EXT_CTRL,


