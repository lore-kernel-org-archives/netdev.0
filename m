From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [PATCH 1/2] ethtool.h: Add #defines for unidirectional ethernet duplex
Date: Fri, 27 Aug 2010 15:42:17 -0400
Message-ID: <1282938138-17844-2-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1282938138-17844-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <kyle@moffetthome.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Kyle Moffett <Kyle.D.Moffett@boeing.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282938138-17844-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A large variety of fiber ethernet PHYs and some copper ethernet PHYs
support forced "unidirectional link" modes.  Some signalling modes are
designed for last-mile ethernet plants while others are designed for
strict security isolation (fiber with no return-path).

In order to configure those kinds of forced modes from userspace, we
need to add additional options to the "ethtool" interface.  As such
"unidirectional" ethernet modes most closely resemble ethernet "duplex",
we add two additional DUPLEX_* defines to the ethtool interface:

  #define DUPLEX_TXONLY 0x02
  #define DUPLEX_RXONLY 0x03

Most ethernet PHYs will still need to be configured internally in a mode
with autoneg off and duplex full, except for a few model-specific PHY
register adjustments.

Most PHYs can simply use a regular forced-mode for rx-only configuration,
but it may be useful in the ethernet driver to completely disable the TX
queues or similar.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 drivers/net/phy/phy.c   |   23 ++++++++++++++++-------
 include/linux/ethtool.h |    4 +++-
 2 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 64be466..1103a80 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -44,14 +44,23 @@
  */
 void phy_print_status(struct phy_device *phydev)
 {
-	pr_info("PHY: %s - Link is %s", dev_name(&phydev->dev),
-			phydev->link ? "Up" : "Down");
-	if (phydev->link)
-		printk(" - %d/%s", phydev->speed,
-				DUPLEX_FULL == phydev->duplex ?
-				"Full" : "Half");
-
-	printk("\n");
+	const char *strduplex = "Unknown";
+
+	/* Not much to show if the link is down */
+	if (!phydev->link) {
+		pr_info("PHY: %s - Link is Down\n", dev_name(&phydev->dev));
+		return;
+	}
+
+	/* Otherwise we need to print out speed and duplex */
+	switch (phydev->duplex) {
+		case DUPLEX_HALF:   strduplex = "Half";    break;
+		case DUPLEX_FULL:   strduplex = "Full";    break;
+		case DUPLEX_TXONLY: strduplex = "TX-Only"; break;
+		case DUPLEX_RXONLY: strduplex = "RX-Only"; break;
+	}
+	pr_info("PHY: %s - Link is Up - %d/%s\n", dev_name(&phydev->dev),
+			phydev->speed, strduplex);
 }
 EXPORT_SYMBOL(phy_print_status);
 
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index b4207ca..ccf2e32 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -703,9 +703,11 @@ struct ethtool_ops {
 #define SPEED_2500		2500
 #define SPEED_10000		10000
 
-/* Duplex, half or full. */
+/* Duplex: half/full or unidirectional communication */
 #define DUPLEX_HALF		0x00
 #define DUPLEX_FULL		0x01
+#define DUPLEX_TXONLY		0x02
+#define DUPLEX_RXONLY		0x03
 
 /* Which connector port. */
 #define PORT_TP		0x00
-- 
1.7.1
