From: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] netdev/phy: Handle IEEE802.3 clause 45 Ethernet PHYs
Date: Wed, 12 Oct 2011 11:06:21 -0700
Message-ID: <1318442783-29058-2-git-send-email-david.daney@cavium.com>
References: <1318442783-29058-1-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: afleming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1318442783-29058-1-git-send-email-david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

The IEEE802.3 clause 45 MDIO bus protocol allows for directly
addressing PHY registers using a 21 bit address, and is used by many
10G Ethernet PHYS.  Already existing is the ability of MDIO bus
drivers to use clause 45, with the MII_ADDR_C45 flag.  Here we add
some support in the PHY and device tree infrastructure to use these
PHYs.

Normally the MII_ADDR_C45 flag is ORed with the register address to
indicate a clause 45 transaction.  Here we also use this flag in the
*device* address passed to get_phy_id() and get_phy_device() to
indicate that probing should be done with clause 45 transactions.  If
a PHY is successfully probed with MII_ADDR_C45, the new struct
phy_device is_c45 flag is set for the PHY.

Signed-off-by: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/phy/phy_device.c |   25 ++++++++++++++++++++++---
 include/linux/phy.h          |    3 +++
 2 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 83a5a5a..7e4d61b 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -171,6 +171,8 @@ static struct phy_device* phy_device_create(struct mii_bus *bus,
 
 	dev->autoneg = AUTONEG_ENABLE;
 
+	dev->is_c45 = (addr & MII_ADDR_C45) != 0;
+	addr &= ~MII_ADDR_C45;
 	dev->addr = addr;
 	dev->phy_id = phy_id;
 	dev->bus = bus;
@@ -205,15 +207,24 @@ static struct phy_device* phy_device_create(struct mii_bus *bus,
  * @phy_id: where to store the ID retrieved.
  *
  * Description: Reads the ID registers of the PHY at @addr on the
- *   @bus, stores it in @phy_id and returns zero on success.
+ *   @bus, stores it in @phy_id and returns zero on success.  If the
+ *   @addr has been ORed with MII_ADDR_C45, mdio clause 45 data
+ *   transfer is used to read ID from the PHY device, otherwise the
+ *   standard protocol (clause 22) is used.
  */
 int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
 {
 	int phy_reg;
+	u32 c45_reg_base = 0;
 
+	if (addr & MII_ADDR_C45) {
+		addr &= ~MII_ADDR_C45;
+		/* Access the PHY's PHY XS registers with C45 mode. */
+		c45_reg_base = MII_ADDR_C45 | 0x40000;
+	}
 	/* Grab the bits from PHYIR1, and put them
 	 * in the upper half */
-	phy_reg = mdiobus_read(bus, addr, MII_PHYSID1);
+	phy_reg = mdiobus_read(bus, addr, c45_reg_base | MII_PHYSID1);
 
 	if (phy_reg < 0)
 		return -EIO;
@@ -221,7 +232,7 @@ int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
 	*phy_id = (phy_reg & 0xffff) << 16;
 
 	/* Grab the bits from PHYIR2, and put them in the lower half */
-	phy_reg = mdiobus_read(bus, addr, MII_PHYSID2);
+	phy_reg = mdiobus_read(bus, addr, c45_reg_base | MII_PHYSID2);
 
 	if (phy_reg < 0)
 		return -EIO;
@@ -239,6 +250,9 @@ EXPORT_SYMBOL(get_phy_id);
  *
  * Description: Reads the ID registers of the PHY at @addr on the
  *   @bus, then allocates and returns the phy_device to represent it.
+ *   If the @addr has been ORed with MII_ADDR_C45, mdio clause 45 data
+ *   transfer is used to read the PHY device, otherwise the standard
+ *   protocol (clause 22) is used.
  */
 struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
 {
@@ -447,6 +461,11 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	/* Assume that if there is no driver, that it doesn't
 	 * exist, and we should use the genphy driver. */
 	if (NULL == d->driver) {
+		if (phydev->is_c45) {
+			pr_err("No driver for phy %x\n", phydev->phy_id);
+			return -ENODEV;
+		}
+
 		d->driver = &genphy_driver.driver;
 
 		err = d->driver->probe(d);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e4c3844..0a25e2c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -246,6 +246,7 @@ struct sk_buff;
  * phy_id: UID for this device found during discovery
  * state: state of the PHY for management purposes
  * dev_flags: Device-specific flags used by the PHY driver.
+ * is_c45:  Set to 1 if this phy uses clause 45 addressing.
  * addr: Bus address of PHY
  * link_timeout: The number of timer firings to wait before the
  * giving up on the current attempt at acquiring a link
@@ -283,6 +284,8 @@ struct phy_device {
 
 	u32 dev_flags;
 
+	unsigned int is_c45:1;
+
 	phy_interface_t interface;
 
 	/* Bus address of the PHY (0-31) */
-- 
1.7.2.3
