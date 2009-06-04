From: Riccardo Ghetta <birrachiara@tin.it>
Subject: [PATCH 3/3] sis190: fix gigabit negotiation
Date: Thu, 4 Jun 2009 21:05:20 +0200
Message-ID: <20090604190520.GA32651@localhost>
References: <cover.1244141444.git.birrachiara@tin.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsmtp2.tin.it ([212.216.176.222]:62405 "EHLO vsmtp2.tin.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752958AbZFDTFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2009 15:05:19 -0400
Content-Disposition: inline
In-Reply-To: <cover.1244141444.git.birrachiara@tin.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes an initialization error; the chip negotiates gigabit, but
the driver mistakenly handled it as 100Mb.
Changes based on both SiS own GPL driver and forcedeth.
Hopefully should fix
	http://bugzilla.kernel.org/show_bug.cgi?id=9735
	http://bugzilla.kernel.org/show_bug.cgi?id=11149

Signed-off-by: Riccardo Ghetta <birrachiara@tin.it>
---
 drivers/net/sis190.c |   37 +++++++++++++++++++++++++------------
 1 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index df1d1f7..f0d73ab 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -47,7 +47,7 @@
 #define PHY_ID_ANY		0x1f
 #define MII_REG_ANY		0x1f
 
-#define DRV_VERSION		"1.2"
+#define DRV_VERSION		"1.3"
 #define DRV_NAME		"sis190"
 #define SIS190_DRIVER_NAME	DRV_NAME " Gigabit Ethernet driver " DRV_VERSION
 #define PFX DRV_NAME ": "
@@ -943,9 +943,9 @@ static void sis190_phy_task(struct work_struct *work)
 			u32 ctl;
 			const char *msg;
 		} reg31[] = {
-			{ LPA_1000XFULL | LPA_SLCT, 0x07000c00 | 0x00001000,
+			{ LPA_1000FULL, 0x07000c00 | 0x00001000,
 				"1000 Mbps Full Duplex" },
-			{ LPA_1000XHALF | LPA_SLCT, 0x07000c00,
+			{ LPA_1000HALF, 0x07000c00,
 				"1000 Mbps Half Duplex" },
 			{ LPA_100FULL, 0x04000800 | 0x00001000,
 				"100 Mbps Full Duplex" },
@@ -956,22 +956,35 @@ static void sis190_phy_task(struct work_struct *work)
 			{ LPA_10HALF, 0x04000400,
 				"10 Mbps Half Duplex" },
 			{ 0, 0x04000400, "unknown" }
- 		}, *p;
-		u16 adv;
+		}, *p = NULL;
+		u16 adv, autoexp, gigadv, gigrec;
 
 		val = mdio_read(ioaddr, phy_id, 0x1f);
 		net_link(tp, KERN_INFO "%s: mii ext = %04x.\n", dev->name, val);
 
 		val = mdio_read(ioaddr, phy_id, MII_LPA);
 		adv = mdio_read(ioaddr, phy_id, MII_ADVERTISE);
-		net_link(tp, KERN_INFO "%s: mii lpa = %04x adv = %04x.\n",
-			 dev->name, val, adv);
-
-		val &= adv;
+		autoexp = mdio_read(ioaddr, phy_id, MII_EXPANSION);
+		net_link(tp, KERN_INFO "%s: mii lpa=%04x adv=%04x exp=%04x.\n",
+			 dev->name, val, adv, autoexp);
+
+		if (val & LPA_NPAGE && autoexp & EXPANSION_NWAY) {
+			/* check for gigabit speed */
+			gigadv = mdio_read(ioaddr, phy_id, MII_CTRL1000);
+			gigrec = mdio_read(ioaddr, phy_id, MII_STAT1000);
+			val = (gigadv & (gigrec >> 2));
+			if (val & ADVERTISE_1000FULL)
+				p = reg31;
+			else if (val & ADVERTISE_1000HALF)
+				p = reg31 + 1;
+		}
+		if (!p) {
+			val &= adv;
 
-		for (p = reg31; p->val; p++) {
-			if ((val & p->val) == p->val)
-				break;
+			for (p = reg31; p->val; p++) {
+				if ((val & p->val) == p->val)
+					break;
+			}
 		}
 
 		p->ctl |= SIS_R32(StationControl) & ~0x0f001c00;
-- 
1.6.2.4

