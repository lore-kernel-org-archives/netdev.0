From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 3/3] net: thunderx: Don't leak phy device references on -EPROBE_DEFER condition.
Date: Mon, 14 Mar 2016 17:30:39 -0700
Message-ID: <1458001839-15993-4-git-send-email-ddaney.cavm@gmail.com>
References: <1458001839-15993-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	David Daney <david.daney@cavium.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Robert Richter <rric@kernel.org>,
	Sunil Goutham <sgoutham@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458001839-15993-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

It is possible, although unlikely, that probing will find the
phy_device for the first LMAC of a thunder BGX device, but then need
to fail with -EPROBE_DEFER on a subsequent LMAC.  In this case, we
need to call put_device() on each of the phy_devices that were
obtained, but will be unused due to returning -EPROBE_DEFER.

Also, since we can break out of the probing loop early, we need to
explicitly call of_node_put() outside of the loop.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 26 +++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index feed231..9679515 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -974,17 +974,18 @@ static int bgx_init_acpi_phy(struct bgx *bgx)
 static int bgx_init_of_phy(struct bgx *bgx)
 {
 	struct fwnode_handle *fwn;
+	struct device_node *node = NULL;
 	u8 lmac = 0;
-	const char *mac;
 
 	device_for_each_child_node(&bgx->pdev->dev, fwn) {
 		struct phy_device *pd;
 		struct device_node *phy_np;
-		struct device_node *node = to_of_node(fwn);
+		const char *mac;
 
 		/* Should always be an OF node.  But if it is not, we
 		 * cannot handle it, so exit the loop.
 		 */
+		node = to_of_node(fwn);
 		if (!node)
 			break;
 
@@ -1005,17 +1006,30 @@ static int bgx_init_of_phy(struct bgx *bgx)
 			/* Wait until the phy drivers are available */
 			pd = of_phy_find_device(phy_np);
 			if (!pd)
-				return -EPROBE_DEFER;
+				goto defer;
 			bgx->lmac[lmac].phydev = pd;
 		}
 
 		lmac++;
-		if (lmac == MAX_LMAC_PER_BGX) {
-			of_node_put(node);
+		if (lmac == MAX_LMAC_PER_BGX)
 			break;
-		}
 	}
+	of_node_put(node);
 	return 0;
+
+defer:
+	/* We are bailing out, try not to leak device reference counts
+	 * for phy devices we may have already found.
+	 */
+	while (lmac) {
+		if (bgx->lmac[lmac].phydev) {
+			put_device(&bgx->lmac[lmac].phydev->mdio.dev);
+			bgx->lmac[lmac].phydev = NULL;
+		}
+		lmac--;
+	}
+	of_node_put(node);
+	return -EPROBE_DEFER;
 }
 
 #else
-- 
1.7.11.7
