From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RESEND v3 5/9] of_mdio: fix MDIO phy device refcounting
Date: Thu, 24 Sep 2015 20:36:13 +0100
Message-ID: <E1ZfCJR-0004Rk-8M@rmk-PC.arm.linux.org.uk>
References: <20150922161710.GA21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: devicetree@vger.kernel.org, Frank Rowand <frowand.list@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, Li Yang <leoli@freescale.com>,
	Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
	Robert Richter <rric@kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	"Soren Brinkmann" <soren.brinkmann@xilinx.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150922161710.GA21084@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bus_find_device() is defined as:

 * This is similar to the bus_for_each_dev() function above, but it
 * returns a reference to a device that is 'found' for later use, as
 * determined by the @match callback.

and it does indeed return a reference-counted pointer to the device:

        while ((dev = next_device(&i)))
                if (match(dev, data) && get_device(dev))
                                        ^^^^^^^^^^^^^^^
                        break;
        klist_iter_exit(&i);
        return dev;

What that means is that when we're done with the struct device, we must
drop that reference.  Neither of_phy_connect() nor of_phy_attach() did
this when phy_connect_direct() or phy_attach_direct() failed.

With our previous patch, phy_connect_direct() and phy_attach_direct()
take a new refcount on the phy device when successful, so we can drop
our local reference immediatley after these functions, whether or not
they succeeded.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/of/of_mdio.c | 27 +++++++++++++++++++++++----
 1 file changed, 23 insertions(+), 4 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 1350fa25cdb0..a87a868fed64 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -197,7 +197,8 @@ static int of_phy_match(struct device *dev, void *phy_np)
  * of_phy_find_device - Give a PHY node, find the phy_device
  * @phy_np: Pointer to the phy's device tree node
  *
- * Returns a pointer to the phy_device.
+ * If successful, returns a pointer to the phy_device with the embedded
+ * struct device refcount incremented by one, or NULL on failure.
  */
 struct phy_device *of_phy_find_device(struct device_node *phy_np)
 {
@@ -217,7 +218,9 @@ EXPORT_SYMBOL(of_phy_find_device);
  * @hndlr: Link state callback for the network device
  * @iface: PHY data interface type
  *
- * Returns a pointer to the phy_device if successful.  NULL otherwise
+ * If successful, returns a pointer to the phy_device with the embedded
+ * struct device refcount incremented by one, or NULL on failure. The
+ * refcount must be dropped by calling phy_disconnect() or phy_detach().
  */
 struct phy_device *of_phy_connect(struct net_device *dev,
 				  struct device_node *phy_np,
@@ -225,13 +228,19 @@ struct phy_device *of_phy_connect(struct net_device *dev,
 				  phy_interface_t iface)
 {
 	struct phy_device *phy = of_phy_find_device(phy_np);
+	int ret;
 
 	if (!phy)
 		return NULL;
 
 	phy->dev_flags = flags;
 
-	return phy_connect_direct(dev, phy, hndlr, iface) ? NULL : phy;
+	ret = phy_connect_direct(dev, phy, hndlr, iface);
+
+	/* refcount is held by phy_connect_direct() on success */
+	put_device(&phy->dev);
+
+	return ret ? NULL : phy;
 }
 EXPORT_SYMBOL(of_phy_connect);
 
@@ -241,17 +250,27 @@ EXPORT_SYMBOL(of_phy_connect);
  * @phy_np: Node pointer for the PHY
  * @flags: flags to pass to the PHY
  * @iface: PHY data interface type
+ *
+ * If successful, returns a pointer to the phy_device with the embedded
+ * struct device refcount incremented by one, or NULL on failure. The
+ * refcount must be dropped by calling phy_disconnect() or phy_detach().
  */
 struct phy_device *of_phy_attach(struct net_device *dev,
 				 struct device_node *phy_np, u32 flags,
 				 phy_interface_t iface)
 {
 	struct phy_device *phy = of_phy_find_device(phy_np);
+	int ret;
 
 	if (!phy)
 		return NULL;
 
-	return phy_attach_direct(dev, phy, flags, iface) ? NULL : phy;
+	ret = phy_attach_direct(dev, phy, flags, iface);
+
+	/* refcount is held by phy_attach_direct() on success */
+	put_device(&phy->dev);
+
+	return ret ? NULL : phy;
 }
 EXPORT_SYMBOL(of_phy_attach);
 
-- 
2.1.0
