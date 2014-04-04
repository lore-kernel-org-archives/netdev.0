From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 1/2] mdio_bus: implement devm_mdiobus_alloc/devm_mdiobus_free
Date: Fri, 4 Apr 2014 16:40:24 +0300
Message-ID: <1396618825-4241-2-git-send-email-grygorii.strashko@ti.com>
References: <1396618825-4241-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <santosh.shilimkar-l0cyMroinI0@public.gmane.org>,
        "David S. Miller"
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Jonathan Cameron <jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1396618825-4241-1-git-send-email-grygorii.strashko-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a resource managed devm_mdiobus_alloc()/devm_mdiobus_free()
to automatically clean up MDIO bus alocations made by MDIO drivers,
thus leading to simplified MDIO drivers code.

Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
---
 Documentation/driver-model/devres.txt |    4 ++
 drivers/net/phy/mdio_bus.c            |   68 +++++++++++++++++++++++++++++++++
 include/linux/phy.h                   |    2 +
 3 files changed, 74 insertions(+)

diff --git a/Documentation/driver-model/devres.txt b/Documentation/driver-model/devres.txt
index 4f7897e..31aa066 100644
--- a/Documentation/driver-model/devres.txt
+++ b/Documentation/driver-model/devres.txt
@@ -308,3 +308,7 @@ SLAVE DMA ENGINE
 
 SPI
   devm_spi_register_master()
+
+MDIO
+  devm_mdiobus_alloc()
+  devm_mdiobus_free()
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 76f54b3..fdcd6d1 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -69,6 +69,74 @@ struct mii_bus *mdiobus_alloc_size(size_t size)
 }
 EXPORT_SYMBOL(mdiobus_alloc_size);
 
+static void _devm_mdiobus_free(struct device *dev, void *res)
+{
+	mdiobus_free(*(struct mii_bus **)res);
+}
+
+static int devm_mdiobus_match(struct device *dev, void *res, void *data)
+{
+	struct mii_bus **r = res;
+	if (!r || !*r) {
+		WARN_ON(!r || !*r);
+		return 0;
+	}
+	return *r == data;
+}
+
+/**
+ * devm_mdiobus_alloc - Resource-managed mdiobus_alloc_size()
+ * @dev:		Device to allocate mii_bus for
+ * @sizeof_priv:	Space to allocate for private structure.
+ *
+ * Managed mdiobus_alloc_size. mii_bus allocated with this function is
+ * automatically freed on driver detach.
+ *
+ * If an mii_bus allocated with this function needs to be freed separately,
+ * devm_mdiobus_free() must be used.
+ *
+ * RETURNS:
+ * Pointer to allocated mii_bus on success, NULL on failure.
+ */
+struct mii_bus *devm_mdiobus_alloc(struct device *dev, int sizeof_priv)
+{
+	struct mii_bus **ptr, *bus;
+
+	ptr = devres_alloc(_devm_mdiobus_free, sizeof(*ptr),
+			   GFP_KERNEL);
+	if (!ptr)
+		return NULL;
+
+	/* use raw alloc_dr for kmalloc caller tracing */
+	bus = mdiobus_alloc_size(sizeof_priv);
+	if (bus) {
+		*ptr = bus;
+		devres_add(dev, ptr);
+	} else {
+		devres_free(ptr);
+	}
+
+	return bus;
+}
+EXPORT_SYMBOL_GPL(devm_mdiobus_alloc);
+
+/**
+ * devm_mdiobus_free - Resource-managed mdiobus_free()
+ * @dev:		Device this mii_bus belongs to
+ * @bus:		the mii_bus associated with the device
+ *
+ * Free mii_bus allocated with devm_mdiobus_alloc().
+ */
+void devm_mdiobus_free(struct device *dev, struct mii_bus *bus)
+{
+	int rc;
+
+	rc = devres_release(dev, _devm_mdiobus_free,
+		devm_mdiobus_match, bus);
+	WARN_ON(rc);
+}
+EXPORT_SYMBOL_GPL(devm_mdiobus_free);
+
 /**
  * mdiobus_release - mii_bus device release callback
  * @d: the target struct device that contains the mii_bus
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 24126c4..2238bea 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -195,6 +195,8 @@ static inline struct mii_bus *mdiobus_alloc(void)
 int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
 void mdiobus_free(struct mii_bus *bus);
+struct mii_bus *devm_mdiobus_alloc(struct device *dev, int sizeof_priv);
+void devm_mdiobus_free(struct device *dev, struct mii_bus *bus);
 struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);
 int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum);
 int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val);
-- 
1.7.9.5
