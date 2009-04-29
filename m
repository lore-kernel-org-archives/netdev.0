From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 05/16] chelsio: Use generic MDIO definitions and
	mdio_mii_ioctl()
Date: Wed, 29 Apr 2009 19:06:34 +0100
Message-ID: <1241028394.3246.41.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Divy Le Ray <divy@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:53102 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751713AbZD2SGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:06:37 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/Kconfig             |    1 +
 drivers/net/chelsio/common.h    |    2 +-
 drivers/net/chelsio/cphy.h      |   45 +++++++++++++++++++++-----------------
 drivers/net/chelsio/cxgb2.c     |   36 ++----------------------------
 drivers/net/chelsio/mv88x201x.c |   45 ++++++++++++++++++++-------------------
 drivers/net/chelsio/my3126.c    |   10 +++++---
 drivers/net/chelsio/subr.c      |   43 ++++++++++++++++++++-----------------
 7 files changed, 82 insertions(+), 100 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 2f81db5..1ccd547 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2450,6 +2450,7 @@ config CHELSIO_T1
         tristate "Chelsio 10Gb Ethernet support"
         depends on PCI
 	select CRC32
+	select MDIO
         help
           This driver supports Chelsio gigabit and 10-gigabit
           Ethernet cards. More information about adapter features and
diff --git a/drivers/net/chelsio/common.h b/drivers/net/chelsio/common.h
index 4bd2455..699d22c 100644
--- a/drivers/net/chelsio/common.h
+++ b/drivers/net/chelsio/common.h
@@ -46,7 +46,7 @@
 #include <linux/pci.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
-#include <linux/mii.h>
+#include <linux/mdio.h>
 #include <linux/crc32.h>
 #include <linux/init.h>
 #include <asm/io.h>
diff --git a/drivers/net/chelsio/cphy.h b/drivers/net/chelsio/cphy.h
index 79d855e..8b5165a 100644
--- a/drivers/net/chelsio/cphy.h
+++ b/drivers/net/chelsio/cphy.h
@@ -43,10 +43,11 @@
 
 struct mdio_ops {
 	void (*init)(adapter_t *adapter, const struct board_info *bi);
-	int  (*read)(adapter_t *adapter, int phy_addr, int mmd_addr,
-		     int reg_addr, unsigned int *val);
-	int  (*write)(adapter_t *adapter, int phy_addr, int mmd_addr,
-		      int reg_addr, unsigned int val);
+	int  (*read)(struct net_device *dev, int phy_addr, int mmd_addr,
+		     u16 reg_addr);
+	int  (*write)(struct net_device *dev, int phy_addr, int mmd_addr,
+		      u16 reg_addr, u16 val);
+	unsigned mode_support;
 };
 
 /* PHY interrupt types */
@@ -83,11 +84,12 @@ struct cphy_ops {
 	int (*set_speed_duplex)(struct cphy *phy, int speed, int duplex);
 	int (*get_link_status)(struct cphy *phy, int *link_ok, int *speed,
 			       int *duplex, int *fc);
+
+	u32 mmds;
 };
 
 /* A PHY instance */
 struct cphy {
-	int addr;                            /* PHY address */
 	int state;	/* Link status state machine */
 	adapter_t *adapter;                  /* associated adapter */
 
@@ -101,36 +103,37 @@ struct cphy {
 	u32 elmer_gpo;
 
 	const struct cphy_ops *ops;            /* PHY operations */
-	int (*mdio_read)(adapter_t *adapter, int phy_addr, int mmd_addr,
-			 int reg_addr, unsigned int *val);
-	int (*mdio_write)(adapter_t *adapter, int phy_addr, int mmd_addr,
-			  int reg_addr, unsigned int val);
+	struct mdio_if_info mdio;
 	struct cphy_instance *instance;
 };
 
 /* Convenience MDIO read/write wrappers */
-static inline int mdio_read(struct cphy *cphy, int mmd, int reg,
-			    unsigned int *valp)
+static inline int cphy_mdio_read(struct cphy *cphy, int mmd, int reg,
+				 unsigned int *valp)
 {
-	return cphy->mdio_read(cphy->adapter, cphy->addr, mmd, reg, valp);
+	int rc = cphy->mdio.mdio_read(cphy->mdio.dev, cphy->mdio.prtad, mmd,
+				      reg);
+	*valp = (rc >= 0) ? rc : -1;
+	return (rc >= 0) ? 0 : rc;
 }
 
-static inline int mdio_write(struct cphy *cphy, int mmd, int reg,
-			     unsigned int val)
+static inline int cphy_mdio_write(struct cphy *cphy, int mmd, int reg,
+				  unsigned int val)
 {
-	return cphy->mdio_write(cphy->adapter, cphy->addr, mmd, reg, val);
+	return cphy->mdio.mdio_write(cphy->mdio.dev, cphy->mdio.prtad, mmd,
+				     reg, val);
 }
 
 static inline int simple_mdio_read(struct cphy *cphy, int reg,
 				   unsigned int *valp)
 {
-	return mdio_read(cphy, 0, reg, valp);
+	return cphy_mdio_read(cphy, MDIO_DEVAD_NONE, reg, valp);
 }
 
 static inline int simple_mdio_write(struct cphy *cphy, int reg,
 				    unsigned int val)
 {
-	return mdio_write(cphy, 0, reg, val);
+	return cphy_mdio_write(cphy, MDIO_DEVAD_NONE, reg, val);
 }
 
 /* Convenience initializer */
@@ -139,11 +142,13 @@ static inline void cphy_init(struct cphy *phy, adapter_t *adapter,
 			     const struct mdio_ops *mdio_ops)
 {
 	phy->adapter = adapter;
-	phy->addr    = phy_addr;
 	phy->ops     = phy_ops;
 	if (mdio_ops) {
-		phy->mdio_read  = mdio_ops->read;
-		phy->mdio_write = mdio_ops->write;
+		phy->mdio.prtad = phy_addr;
+		phy->mdio.mmds = phy_ops->mmds;
+		phy->mdio.mode_support = mdio_ops->mode_support;
+		phy->mdio.mdio_read = mdio_ops->read;
+		phy->mdio.mdio_write = mdio_ops->write;
 	}
 }
 
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index fa06994..082cdb2 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -589,7 +589,7 @@ static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	}
 
 	cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
-	cmd->phy_address = p->phy->addr;
+	cmd->phy_address = p->phy->mdio.prtad;
 	cmd->transceiver = XCVR_EXTERNAL;
 	cmd->autoneg = p->link_config.autoneg;
 	cmd->maxtxpkt = 0;
@@ -849,39 +849,9 @@ static const struct ethtool_ops t1_ethtool_ops = {
 static int t1_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
 	struct adapter *adapter = dev->ml_priv;
-	struct mii_ioctl_data *data = if_mii(req);
-
-	switch (cmd) {
-	case SIOCGMIIPHY:
-		data->phy_id = adapter->port[dev->if_port].phy->addr;
-		/* FALLTHRU */
-	case SIOCGMIIREG: {
-		struct cphy *phy = adapter->port[dev->if_port].phy;
-		u32 val;
-
-		if (!phy->mdio_read)
-			return -EOPNOTSUPP;
-		phy->mdio_read(adapter, data->phy_id, 0, data->reg_num & 0x1f,
-			       &val);
-		data->val_out = val;
-		break;
-	}
-	case SIOCSMIIREG: {
-		struct cphy *phy = adapter->port[dev->if_port].phy;
-
-		if (!capable(CAP_NET_ADMIN))
-		    return -EPERM;
-		if (!phy->mdio_write)
-			return -EOPNOTSUPP;
-		phy->mdio_write(adapter, data->phy_id, 0, data->reg_num & 0x1f,
-			        data->val_in);
-		break;
-	}
+	struct mdio_if_info *mdio = &adapter->port[dev->if_port].phy->mdio;
 
-	default:
-		return -EOPNOTSUPP;
-	}
-	return 0;
+	return mdio_mii_ioctl(mdio, if_mii(req), cmd);
 }
 
 static int t1_change_mtu(struct net_device *dev, int new_mtu)
diff --git a/drivers/net/chelsio/mv88x201x.c b/drivers/net/chelsio/mv88x201x.c
index cd85604..29e0cba 100644
--- a/drivers/net/chelsio/mv88x201x.c
+++ b/drivers/net/chelsio/mv88x201x.c
@@ -53,7 +53,7 @@ static int led_init(struct cphy *cphy)
 	 * Writing these bits maps control to another
 	 * register. mmd(0x1) addr(0x7)
 	 */
-	mdio_write(cphy, 0x3, 0x8304, 0xdddd);
+	cphy_mdio_write(cphy, MDIO_MMD_PCS, 0x8304, 0xdddd);
 	return 0;
 }
 
@@ -62,14 +62,14 @@ static int led_link(struct cphy *cphy, u32 do_enable)
 	u32 led = 0;
 #define LINK_ENABLE_BIT 0x1
 
-	mdio_read(cphy, 0x1, 0x7, &led);
+	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_CTRL2, &led);
 
 	if (do_enable & LINK_ENABLE_BIT) {
 		led |= LINK_ENABLE_BIT;
-		mdio_write(cphy, 0x1, 0x7, led);
+		cphy_mdio_write(cphy, MDIO_MMD_PMAPMD, MDIO_CTRL2, led);
 	} else {
 		led &= ~LINK_ENABLE_BIT;
-		mdio_write(cphy, 0x1, 0x7, led);
+		cphy_mdio_write(cphy, MDIO_MMD_PMAPMD, MDIO_CTRL2, led);
 	}
 	return 0;
 }
@@ -86,7 +86,7 @@ static int mv88x201x_reset(struct cphy *cphy, int wait)
 static int mv88x201x_interrupt_enable(struct cphy *cphy)
 {
 	/* Enable PHY LASI interrupts. */
-	mdio_write(cphy, 0x1, 0x9002, 0x1);
+	cphy_mdio_write(cphy, MDIO_MMD_PMAPMD, 0x9002, 0x1);
 
 	/* Enable Marvell interrupts through Elmer0. */
 	if (t1_is_asic(cphy->adapter)) {
@@ -102,7 +102,7 @@ static int mv88x201x_interrupt_enable(struct cphy *cphy)
 static int mv88x201x_interrupt_disable(struct cphy *cphy)
 {
 	/* Disable PHY LASI interrupts. */
-	mdio_write(cphy, 0x1, 0x9002, 0x0);
+	cphy_mdio_write(cphy, MDIO_MMD_PMAPMD, 0x9002, 0x0);
 
 	/* Disable Marvell interrupts through Elmer0. */
 	if (t1_is_asic(cphy->adapter)) {
@@ -122,25 +122,25 @@ static int mv88x201x_interrupt_clear(struct cphy *cphy)
 
 #ifdef MV88x2010_LINK_STATUS_BUGS
 	/* Required to read twice before clear takes affect. */
-	mdio_read(cphy, 0x1, 0x9003, &val);
-	mdio_read(cphy, 0x1, 0x9004, &val);
-	mdio_read(cphy, 0x1, 0x9005, &val);
+	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, 0x9003, &val);
+	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, 0x9004, &val);
+	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, 0x9005, &val);
 
 	/* Read this register after the others above it else
 	 * the register doesn't clear correctly.
 	 */
-	mdio_read(cphy, 0x1, 0x1, &val);
+	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_STAT1, &val);
 #endif
 
 	/* Clear link status. */
-	mdio_read(cphy, 0x1, 0x1, &val);
+	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_STAT1, &val);
 	/* Clear PHY LASI interrupts. */
-	mdio_read(cphy, 0x1, 0x9005, &val);
+	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, 0x9005, &val);
 
 #ifdef MV88x2010_LINK_STATUS_BUGS
 	/* Do it again. */
-	mdio_read(cphy, 0x1, 0x9003, &val);
-	mdio_read(cphy, 0x1, 0x9004, &val);
+	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, 0x9003, &val);
+	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, 0x9004, &val);
 #endif
 
 	/* Clear Marvell interrupts through Elmer0. */
@@ -172,13 +172,12 @@ static int mv88x201x_get_link_status(struct cphy *cphy, int *link_ok,
 				     int *speed, int *duplex, int *fc)
 {
 	u32 val = 0;
-#define LINK_STATUS_BIT 0x4
 
 	if (link_ok) {
 		/* Read link status. */
-		mdio_read(cphy, 0x1, 0x1, &val);
-		val &= LINK_STATUS_BIT;
-		*link_ok = (val == LINK_STATUS_BIT);
+		cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_STAT1, &val);
+		val &= MDIO_STAT1_LSTATUS;
+		*link_ok = (val == MDIO_STAT1_LSTATUS);
 		/* Turn on/off Link LED */
 		led_link(cphy, *link_ok);
 	}
@@ -205,6 +204,8 @@ static struct cphy_ops mv88x201x_ops = {
 	.interrupt_handler = mv88x201x_interrupt_handler,
 	.get_link_status   = mv88x201x_get_link_status,
 	.set_loopback      = mv88x201x_set_loopback,
+	.mmds              = (MDIO_DEVS_PMAPMD | MDIO_DEVS_PCS |
+			      MDIO_DEVS_PHYXS | MDIO_DEVS_WIS),
 };
 
 static struct cphy *mv88x201x_phy_create(adapter_t *adapter, int phy_addr,
@@ -219,12 +220,12 @@ static struct cphy *mv88x201x_phy_create(adapter_t *adapter, int phy_addr,
 	cphy_init(cphy, adapter, phy_addr, &mv88x201x_ops, mdio_ops);
 
 	/* Commands the PHY to enable XFP's clock. */
-	mdio_read(cphy, 0x3, 0x8300, &val);
-	mdio_write(cphy, 0x3, 0x8300, val | 1);
+	cphy_mdio_read(cphy, MDIO_MMD_PCS, 0x8300, &val);
+	cphy_mdio_write(cphy, MDIO_MMD_PCS, 0x8300, val | 1);
 
 	/* Clear link status. Required because of a bug in the PHY.  */
-	mdio_read(cphy, 0x1, 0x8, &val);
-	mdio_read(cphy, 0x3, 0x8, &val);
+	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_STAT2, &val);
+	cphy_mdio_read(cphy, MDIO_MMD_PCS, MDIO_STAT2, &val);
 
 	/* Allows for Link,Ack LED turn on/off */
 	led_init(cphy);
diff --git a/drivers/net/chelsio/my3126.c b/drivers/net/chelsio/my3126.c
index 040acd2..977c7e0 100644
--- a/drivers/net/chelsio/my3126.c
+++ b/drivers/net/chelsio/my3126.c
@@ -43,11 +43,11 @@ static int my3126_interrupt_handler(struct cphy *cphy)
 	adapter = cphy->adapter;
 
 	if (cphy->count == 50) {
-		mdio_read(cphy, 0x1, 0x1, &val);
+		cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_STAT1, &val);
 		val16 = (u16) val;
 		status = cphy->bmsr ^ val16;
 
-		if (status & BMSR_LSTATUS)
+		if (status & MDIO_STAT1_LSTATUS)
 			t1_link_changed(adapter, 0);
 		cphy->bmsr = val16;
 
@@ -114,14 +114,14 @@ static int my3126_get_link_status(struct cphy *cphy,
 	adapter_t *adapter;
 
 	adapter = cphy->adapter;
-	mdio_read(cphy, 0x1, 0x1, &val);
+	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_STAT1, &val);
 	val16 = (u16) val;
 
 	/* Populate elmer_gpo with the register value */
 	t1_tpi_read(adapter, A_ELMER0_GPO, &val);
 	cphy->elmer_gpo = val;
 
-	*link_ok = (val16 & BMSR_LSTATUS);
+	*link_ok = (val16 & MDIO_STAT1_LSTATUS);
 
 	if (*link_ok) {
 		/* Turn on the LED. */
@@ -163,6 +163,8 @@ static struct cphy_ops my3126_ops = {
 	.interrupt_handler	= my3126_interrupt_handler,
 	.get_link_status	= my3126_get_link_status,
 	.set_loopback		= my3126_set_loopback,
+	.mmds			= (MDIO_DEVS_PMAPMD | MDIO_DEVS_PCS |
+				   MDIO_DEVS_PHYXS),
 };
 
 static struct cphy *my3126_phy_create(adapter_t *adapter,
diff --git a/drivers/net/chelsio/subr.c b/drivers/net/chelsio/subr.c
index 7adf302..2564312 100644
--- a/drivers/net/chelsio/subr.c
+++ b/drivers/net/chelsio/subr.c
@@ -284,32 +284,29 @@ static void mi1_mdio_init(adapter_t *adapter, const struct board_info *bi)
 /*
  * Elmer MI1 MDIO read/write operations.
  */
-static int mi1_mdio_read(adapter_t *adapter, int phy_addr, int mmd_addr,
-			 int reg_addr, unsigned int *valp)
+static int mi1_mdio_read(struct net_device *dev, int phy_addr, int mmd_addr,
+			 u16 reg_addr)
 {
+	struct adapter *adapter = dev->ml_priv;
 	u32 addr = V_MI1_REG_ADDR(reg_addr) | V_MI1_PHY_ADDR(phy_addr);
-
-	if (mmd_addr)
-		return -EINVAL;
+	unsigned int val;
 
 	spin_lock(&adapter->tpi_lock);
 	__t1_tpi_write(adapter, A_ELMER0_PORT0_MI1_ADDR, addr);
 	__t1_tpi_write(adapter,
 			A_ELMER0_PORT0_MI1_OP, MI1_OP_DIRECT_READ);
 	mi1_wait_until_ready(adapter, A_ELMER0_PORT0_MI1_OP);
-	__t1_tpi_read(adapter, A_ELMER0_PORT0_MI1_DATA, valp);
+	__t1_tpi_read(adapter, A_ELMER0_PORT0_MI1_DATA, &val);
 	spin_unlock(&adapter->tpi_lock);
-	return 0;
+	return val;
 }
 
-static int mi1_mdio_write(adapter_t *adapter, int phy_addr, int mmd_addr,
-			  int reg_addr, unsigned int val)
+static int mi1_mdio_write(struct net_device *dev, int phy_addr, int mmd_addr,
+			  u16 reg_addr, u16 val)
 {
+	struct adapter *adapter = dev->ml_priv;
 	u32 addr = V_MI1_REG_ADDR(reg_addr) | V_MI1_PHY_ADDR(phy_addr);
 
-	if (mmd_addr)
-		return -EINVAL;
-
 	spin_lock(&adapter->tpi_lock);
 	__t1_tpi_write(adapter, A_ELMER0_PORT0_MI1_ADDR, addr);
 	__t1_tpi_write(adapter, A_ELMER0_PORT0_MI1_DATA, val);
@@ -324,16 +321,19 @@ static int mi1_mdio_write(adapter_t *adapter, int phy_addr, int mmd_addr,
 static const struct mdio_ops mi1_mdio_ops = {
 	.init = mi1_mdio_init,
 	.read = mi1_mdio_read,
-	.write = mi1_mdio_write
+	.write = mi1_mdio_write,
+	.mode_support = MDIO_SUPPORTS_C22
 };
 #endif
 
 #endif
 
-static int mi1_mdio_ext_read(adapter_t *adapter, int phy_addr, int mmd_addr,
-			     int reg_addr, unsigned int *valp)
+static int mi1_mdio_ext_read(struct net_device *dev, int phy_addr, int mmd_addr,
+			     u16 reg_addr)
 {
+	struct adapter *adapter = dev->ml_priv;
 	u32 addr = V_MI1_REG_ADDR(mmd_addr) | V_MI1_PHY_ADDR(phy_addr);
+	unsigned int val;
 
 	spin_lock(&adapter->tpi_lock);
 
@@ -350,14 +350,15 @@ static int mi1_mdio_ext_read(adapter_t *adapter, int phy_addr, int mmd_addr,
 	mi1_wait_until_ready(adapter, A_ELMER0_PORT0_MI1_OP);
 
 	/* Read the data. */
-	__t1_tpi_read(adapter, A_ELMER0_PORT0_MI1_DATA, valp);
+	__t1_tpi_read(adapter, A_ELMER0_PORT0_MI1_DATA, &val);
 	spin_unlock(&adapter->tpi_lock);
-	return 0;
+	return val;
 }
 
-static int mi1_mdio_ext_write(adapter_t *adapter, int phy_addr, int mmd_addr,
-			      int reg_addr, unsigned int val)
+static int mi1_mdio_ext_write(struct net_device *dev, int phy_addr,
+			      int mmd_addr, u16 reg_addr, u16 val)
 {
+	struct adapter *adapter = dev->ml_priv;
 	u32 addr = V_MI1_REG_ADDR(mmd_addr) | V_MI1_PHY_ADDR(phy_addr);
 
 	spin_lock(&adapter->tpi_lock);
@@ -380,7 +381,8 @@ static int mi1_mdio_ext_write(adapter_t *adapter, int phy_addr, int mmd_addr,
 static const struct mdio_ops mi1_mdio_ext_ops = {
 	.init = mi1_mdio_init,
 	.read = mi1_mdio_ext_read,
-	.write = mi1_mdio_ext_write
+	.write = mi1_mdio_ext_write,
+	.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22
 };
 
 enum {
@@ -1140,6 +1142,7 @@ int __devinit t1_init_sw_modules(adapter_t *adapter,
 			       adapter->name, i);
 			goto error;
 		}
+		adapter->port[i].phy->mdio.dev = adapter->port[i].dev;
 
 		adapter->port[i].mac = mac = bi->gmac->create(adapter, i);
 		if (!mac) {

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

