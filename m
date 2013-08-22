From: Boris BREZILLON <b.brezillon@overkiz.com>
Subject: [RFC PATCH] phylib: mdio: handle register/unregister/register sequence
Date: Thu, 22 Aug 2013 14:34:43 +0200
Message-ID: <1377174883-10643-1-git-send-email-b.brezillon@overkiz.com>
References: <1377174836-10569-1-git-send-email-b.brezillon@overkiz.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org,
 Boris BREZILLON <b.brezillon@overkiz.com>
To: "David S. Miller" <davem@davemloft.net>, Mark Brown <broonie@kernel.org>,
 Nick Bowler <nbowler@elliptictech.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1377174836-10569-1-git-send-email-b.brezillon@overkiz.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The current implementation does not accept this sequence on a given mdio
bus: register/unregister/register.

The device core framework complain about already initialized kobject
struct:

"kobject (df9e9848): tried to init an initialized object, something is
seriously wrong."

This patch replaces the device_register call with device_add in
mdiobus_register and move the device struct initialization in the
mdiobus_alloc_size function.
Thus the device struct is only initialized once.

Signed-off-by: Boris BREZILLON <b.brezillon@overkiz.com>
---
 drivers/net/phy/mdio_bus.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index dc92097..a256de3 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -68,6 +68,8 @@ struct mii_bus *mdiobus_alloc_size(size_t size)
 			bus->priv = (void *)bus + aligned_size;
 	}
 
+	device_initialize(&bus->dev);
+
 	return bus;
 }
 EXPORT_SYMBOL(mdiobus_alloc_size);
@@ -151,7 +153,7 @@ int mdiobus_register(struct mii_bus *bus)
 	bus->dev.groups = NULL;
 	dev_set_name(&bus->dev, "%s", bus->id);
 
-	err = device_register(&bus->dev);
+	err = device_add(&bus->dev);
 	if (err) {
 		pr_err("mii_bus %s failed to register\n", bus->id);
 		return -EINVAL;
@@ -195,12 +197,12 @@ void mdiobus_unregister(struct mii_bus *bus)
 	BUG_ON(bus->state != MDIOBUS_REGISTERED);
 	bus->state = MDIOBUS_UNREGISTERED;
 
-	device_del(&bus->dev);
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
 		if (bus->phy_map[i])
 			device_unregister(&bus->phy_map[i]->dev);
 		bus->phy_map[i] = NULL;
 	}
+	device_del(&bus->dev);
 }
 EXPORT_SYMBOL(mdiobus_unregister);
 
-- 
1.7.9.5
