From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v3 1/4] mdio_bus: implement
	devm_mdiobus_alloc/devm_mdiobus_free
Date: Wed, 30 Apr 2014 15:23:33 +0300
Message-ID: <1398860616-6612-2-git-send-email-grygorii.strashko@ti.com>
References: <1398860616-6612-1-git-send-email-grygorii.strashko@ti.com>
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
In-Reply-To: <1398860616-6612-1-git-send-email-grygorii.strashko-l0cyMroinI0@public.gmane.org>
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

Add a resource managed devm_mdiobus_alloc[_size]()/devm_mdiobus_free()
to automatically clean up MDIO bus alocations made by MDIO drivers,
thus leading to simplified MDIO drivers code.

Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Acked-and-tested-by: Lad, Prabhakar <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
---
 Documentation/driver-model/devres.txt |    5 +++
 drivers/net/phy/mdio_bus.c            |   67 +++++++++++++++++++++++++++++++++
 include/linux/phy.h                   |    7 ++++
 3 files changed, 79 insertions(+)

diff --git a/Documentation/driver-model/devres.txt b/Documentation/driver-model/devres.txt
index 4f7897e..c74e044 100644
--- a/Documentation/driver-model/devres.txt
+++ b/Documentation/driver-model/devres.txt
@@ -308,3 +308,8 @@ SLAVE DMA ENGINE
 
 SPI
   devm_spi_register_master()
+
+MDIO
+  devm_mdiobus_alloc()
+  devm_mdiobus_alloc_size()
+  devm_mdiobus_free()
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 76f54b3..68a9a38 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -69,6 +69,73 @@ struct mii_bus *mdiobus_alloc_size(size_t size)
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
+
+	if (WARN_ON(!r || !*r))
+		return 0;
+
+	return *r == data;
+}
+
+/**
+ * devm_mdiobus_alloc_size - Resource-managed mdiobus_alloc_size()
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
+struct mii_bus *devm_mdiobus_alloc_size(struct device *dev, int sizeof_priv)
+{
+	struct mii_bus **ptr, *bus;
+
+	ptr = devres_alloc(_devm_mdiobus_free, sizeof(*ptr), GFP_KERNEL);
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
+ * Free mii_bus allocated with devm_mdiobus_alloc_size().
+ */
+void devm_mdiobus_free(struct device *dev, struct mii_bus *bus)
+{
+	int rc;
+
+	rc = devres_release(dev, _devm_mdiobus_free,
+			    devm_mdiobus_match, bus);
+	WARN_ON(rc);
+}
+EXPORT_SYMBOL_GPL(devm_mdiobus_free);
+
 /**
  * mdiobus_release - mii_bus device release callback
  * @d: the target struct device that contains the mii_bus
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 24126c4..d7f5ef8 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -195,6 +195,13 @@ static inline struct mii_bus *mdiobus_alloc(void)
 int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
 void mdiobus_free(struct mii_bus *bus);
+struct mii_bus *devm_mdiobus_alloc_size(struct device *dev, int sizeof_priv);
+static inline struct mii_bus *devm_mdiobus_alloc(struct device *dev)
+{
+	return devm_mdiobus_alloc_size(dev, 0);
+}
+
+void devm_mdiobus_free(struct device *dev, struct mii_bus *bus);
 struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);
 int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum);
 int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val);
-- 
1.7.9.5
