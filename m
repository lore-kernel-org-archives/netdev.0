From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: TG3 fix for slow switches (Was: TG3 driver failure on HP 16-way)
Date: Tue, 21 Dec 2004 11:12:23 +1100
Message-ID: <16839.27239.264551.415058@berry.gelato.unsw.EDU.AU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
	I've tracked down the problem I was having with the TG3
driver on the HP 16-way.  If you'll recall, the problem was that the
link was always marked as down, and autonegotiation was failing.



The problem is that the driver gives up before the switch that the NIC
is connected to has finished the negotiation phase.

Here's a simple patch.  I changed the way the loop works too, because
tg3_readphys() sets *val to 0xffffffff if it fails.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

===== drivers/net/tg3.c 1.222 vs edited =====
--- 1.222/drivers/net/tg3.c	2004-11-15 23:53:08 +00:00
+++ edited/drivers/net/tg3.c	2004-12-21 00:00:58 +00:00
@@ -1554,10 +1554,11 @@ static int tg3_setup_copper_phy(struct t
 		}
 	}
 
-	bmsr = 0;
-	for (i = 0; i < 100; i++) {
-		tg3_readphy(tp, MII_BMSR, &bmsr);
+
+	for (i = 0; i < 1000; i++) {
 		tg3_readphy(tp, MII_BMSR, &bmsr);
+		if (tg3_readphy(tp, MII_BMSR, &bmsr))
+			bmsr = 0;
 		if (bmsr & BMSR_LSTATUS)
 			break;
 		udelay(40);
