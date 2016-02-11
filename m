From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 4/6] net: thunderx: bgx: Use standard firmware node infrastructure.
Date: Thu, 11 Feb 2016 21:50:24 +0530
Message-ID: <1455207626-35488-5-git-send-email-sunil.kovvuri@gmail.com>
References: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com,
	David Daney <david.daney@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

In the case of OF device tree, the firmware information is attached to
the BGX device structure in the standard manner, so use the firmware
iterators and accessors where possible.

Signed-off-by: David Daney <david.daney@cavium.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c |   27 +++++++++++----------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 9df26c2..111835b 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -968,26 +968,27 @@ static int bgx_init_acpi_phy(struct bgx *bgx)
 
 static int bgx_init_of_phy(struct bgx *bgx)
 {
-	struct device_node *np;
-	struct device_node *np_child;
+	struct fwnode_handle *fwn;
 	u8 lmac = 0;
-	char bgx_sel[5];
 	const char *mac;
 
-	/* Get BGX node from DT */
-	snprintf(bgx_sel, 5, "bgx%d", bgx->bgx_id);
-	np = of_find_node_by_name(NULL, bgx_sel);
-	if (!np)
-		return -ENODEV;
+	device_for_each_child_node(&bgx->pdev->dev, fwn) {
+		struct device_node *phy_np;
+		struct device_node *node = to_of_node(fwn);
+
+		/* If it is not an OF node we cannot handle it yet, so
+		 * exit the loop.
+		 */
+		if (!node)
+			break;
 
-	for_each_child_of_node(np, np_child) {
-		struct device_node *phy_np = of_parse_phandle(np_child,
-							      "phy-handle", 0);
+		phy_np = of_parse_phandle(node, "phy-handle", 0);
 		if (!phy_np)
 			continue;
+
 		bgx->lmac[lmac].phydev = of_phy_find_device(phy_np);
 
-		mac = of_get_mac_address(np_child);
+		mac = of_get_mac_address(node);
 		if (mac)
 			ether_addr_copy(bgx->lmac[lmac].mac, mac);
 
@@ -995,7 +996,7 @@ static int bgx_init_of_phy(struct bgx *bgx)
 		bgx->lmac[lmac].lmacid = lmac;
 		lmac++;
 		if (lmac == MAX_LMAC_PER_BGX) {
-			of_node_put(np_child);
+			of_node_put(node);
 			break;
 		}
 	}
-- 
1.7.1
