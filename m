From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] mdio_bus: NULL dereference on allocation error
Date: Tue, 12 Jan 2016 12:34:36 +0300
Message-ID: <20160112093435.GD29804@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If bus = kzalloc() fails then we end up dereferencing bus when we do
"bus->irq[i] = PHY_POLL;".  The code is a little simpler if we reverse
the NULL check and return directly on failure.

Fixes: e7f4dc3536a4 ('mdio: Move allocation of interrupts into core')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 0be7b3d..0cba64f 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -102,11 +102,12 @@ struct mii_bus *mdiobus_alloc_size(size_t size)
 		alloc_size = sizeof(*bus);
 
 	bus = kzalloc(alloc_size, GFP_KERNEL);
-	if (bus) {
-		bus->state = MDIOBUS_ALLOCATED;
-		if (size)
-			bus->priv = (void *)bus + aligned_size;
-	}
+	if (!bus)
+		return NULL;
+
+	bus->state = MDIOBUS_ALLOCATED;
+	if (size)
+		bus->priv = (void *)bus + aligned_size;
 
 	/* Initialise the interrupts to polling */
 	for (i = 0; i < PHY_MAX_ADDR; i++)
