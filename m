From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e100: e100_phy_init() isolates selected PHY,
	causes 10 second boot delay
Date: Thu, 29 Oct 2009 16:42:41 -0700
Message-ID: <20091029234228.5100.17917.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bernhard Kaindl <bernhard.kaindl@gmx.net>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:53951
	"EHLO QMTA13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752385AbZJ2Xm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 19:42:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

A change in how PHYs are electrically isolated caused all PHYs to be
isolated followed by reverting that isolation for the selected PHY.
Unfortunately, isolating the selected PHY for even a short period of
time can result in DHCP negotiation taking more than 10 seconds on certain
embedded configurations delaying boot time as reported by Bernhard Kaindl.
This patch reverts the change to how PHYs are isolated yet still works
around the issue for 82552 needing the selected PHY's BMCR register to
be written after the unused PHYs are isolated.  This code is moved below
the setting of nic->phy ID in order to do the 82552-specific workaround.

Cc: Bernhard Kaindl <bernhard.kaindl@gmx.net>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e100.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 679965c..d19b084 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1426,19 +1426,31 @@ static int e100_phy_init(struct nic *nic)
 	} else
 		DPRINTK(HW, DEBUG, "phy_addr = %d\n", nic->mii.phy_id);
 
-	/* Isolate all the PHY ids */
-	for (addr = 0; addr < 32; addr++)
-		mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);
-	/* Select the discovered PHY */
-	bmcr &= ~BMCR_ISOLATE;
-	mdio_write(netdev, nic->mii.phy_id, MII_BMCR, bmcr);
-
 	/* Get phy ID */
 	id_lo = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID1);
 	id_hi = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID2);
 	nic->phy = (u32)id_hi << 16 | (u32)id_lo;
 	DPRINTK(HW, DEBUG, "phy ID = 0x%08X\n", nic->phy);
 
+	/* Select the phy and isolate the rest */
+	for (addr = 0; addr < 32; addr++) {
+		if (addr != nic->mii.phy_id) {
+			mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);
+		} else if (nic->phy != phy_82552_v) {
+			bmcr = mdio_read(netdev, addr, MII_BMCR);
+			mdio_write(netdev, addr, MII_BMCR,
+				bmcr & ~BMCR_ISOLATE);
+		}
+	}
+	/*
+	 * Workaround for 82552:
+	 * Clear the ISOLATE bit on selected phy_id last (mirrored on all
+	 * other phy_id's) using bmcr value from addr discovery loop above.
+	 */
+	if (nic->phy == phy_82552_v)
+		mdio_write(netdev, nic->mii.phy_id, MII_BMCR,
+			bmcr & ~BMCR_ISOLATE);
+
 	/* Handle National tx phys */
 #define NCS_PHY_MODEL_MASK	0xFFF0FFFF
 	if ((nic->phy & NCS_PHY_MODEL_MASK) == phy_nsc_tx) {

