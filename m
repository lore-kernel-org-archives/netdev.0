From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: Fix fallout from tg3_readphy() value is zero on error
Date: Fri, 21 Jan 2005 12:52:31 +1100
Message-ID: <16880.24671.640491.852938@berry.gelato.unsw.EDU.AU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


After DaveM's patch to make the `default' value returned by
tg3_readphy() to be zero, the attached patch fixes the few cases where
a zero changes the previous behaviur, and deletes a couple of
initialisation to zero that are no longer necessary.


===== drivers/net/tg3.c 1.228 vs edited =====
--- 1.228/drivers/net/tg3.c	2005-01-20 06:37:04 +00:00
+++ edited/drivers/net/tg3.c	2005-01-21 01:10:21 +00:00
@@ -634,7 +634,8 @@ static int tg3_wait_macro_done(struct tg
 	while (limit--) {
 		u32 tmp32;
 
-		tg3_readphy(tp, 0x16, &tmp32);
+		if (tg3_readphy(tp, 0x16, &tmp32) < 0)
+			continue;
 		if ((tmp32 & 0x1000) == 0)
 			break;
 	}
@@ -1379,7 +1380,8 @@ static int tg3_phy_copper_begin(struct t
 
 				udelay(10);
 				tg3_readphy(tp, MII_BMSR, &tmp);
-				tg3_readphy(tp, MII_BMSR, &tmp);
+				if (tg3_readphy(tp, MII_BMSR, &tmp) < 0)
+					continue;
 				if (!(tmp & BMSR_LSTATUS)) {
 					udelay(40);
 					break;
@@ -1558,7 +1560,6 @@ static int tg3_setup_copper_phy(struct t
 		}
 	}
 
-	bmsr = 0;
 	for (i = 0; i < 100; i++) {
 		tg3_readphy(tp, MII_BMSR, &bmsr);
 		tg3_readphy(tp, MII_BMSR, &bmsr);
@@ -1582,7 +1583,6 @@ static int tg3_setup_copper_phy(struct t
 					     &current_speed,
 					     &current_duplex);
 
-		bmcr = 0;
 		for (i = 0; i < 200; i++) {
 			tg3_readphy(tp, MII_BMCR, &bmcr);
 			tg3_readphy(tp, MII_BMCR, &bmcr);
