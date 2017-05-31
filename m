From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH net-next] mdio: mux: make child bus walking more permissive and errors more verbose
Date: Wed, 31 May 2017 15:44:50 -0400
Message-ID: <1496259890-3719-1-git-send-email-jon.mason@broadcom.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If any errors are encountered while walking the device tree structure of
the MDIO bus for children, the code may silently continue, silently
exit, or throw an error and exit.  This make it difficult for device
tree writers to know there is an error.  Also, it makes any error in a
child entry of the MDIO bus be fatal for all entries.  Instead, we
should provide verbose errors describing the error and then attempt to
continue if it all possible.  Also, use of_mdio_parse_addr()

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 drivers/net/phy/mdio-mux.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 599ce24c514f..47ded3904050 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -135,27 +135,33 @@ int mdio_mux_init(struct device *dev,
 	for_each_available_child_of_node(dev->of_node, child_bus_node) {
 		u32 v;
 
-		r = of_property_read_u32(child_bus_node, "reg", &v);
-		if (r)
+		v = of_mdio_parse_addr(dev, child_bus_node);
+		if (v < 0) {
+			dev_err(dev,
+				"Error: Failed to find reg for child %s\n",
+				of_node_full_name(child_bus_node));
 			continue;
+		}
 
 		cb = devm_kzalloc(dev, sizeof(*cb), GFP_KERNEL);
 		if (cb == NULL) {
 			dev_err(dev,
-				"Error: Failed to allocate memory for child\n");
+				"Error: Failed to allocate memory for child %s\n",
+				of_node_full_name(child_bus_node));
 			ret_val = -ENOMEM;
-			of_node_put(child_bus_node);
-			break;
+			continue;
 		}
 		cb->bus_number = v;
 		cb->parent = pb;
 
 		cb->mii_bus = mdiobus_alloc();
 		if (!cb->mii_bus) {
+			dev_err(dev,
+				"Error: Failed to allocate MDIO bus for child %s\n",
+				of_node_full_name(child_bus_node));
 			ret_val = -ENOMEM;
 			devm_kfree(dev, cb);
-			of_node_put(child_bus_node);
-			break;
+			continue;
 		}
 		cb->mii_bus->priv = cb;
 
@@ -167,6 +173,9 @@ int mdio_mux_init(struct device *dev,
 		cb->mii_bus->write = mdio_mux_write;
 		r = of_mdiobus_register(cb->mii_bus, child_bus_node);
 		if (r) {
+			dev_err(dev,
+				"Error: Failed to register MDIO bus for child %s\n",
+				of_node_full_name(child_bus_node));
 			mdiobus_free(cb->mii_bus);
 			devm_kfree(dev, cb);
 		} else {
@@ -180,6 +189,7 @@ int mdio_mux_init(struct device *dev,
 		return 0;
 	}
 
+	dev_err(dev, "Error: No acceptable child buses found\n");
 	devm_kfree(dev, pb);
 err_pb_kz:
 	/* balance the reference of_mdio_find_bus() took */
-- 
2.7.4
