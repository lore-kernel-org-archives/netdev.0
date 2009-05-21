From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next] cxgb: set phy's mdio dev before the phy init sequence
Date: Wed, 20 May 2009 18:56:12 -0700
Message-ID: <20090521015612.1940.83961.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756014AbZEUB4Y@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

mdio's dev field needs to be set before mdio ops occur.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/chelsio/cphy.h      |    6 ++++--
 drivers/net/chelsio/mv88e1xxx.c |    5 +++--
 drivers/net/chelsio/mv88x201x.c |    4 ++--
 drivers/net/chelsio/my3126.c    |    4 ++--
 drivers/net/chelsio/subr.c      |    5 ++---
 5 files changed, 13 insertions(+), 11 deletions(-)


diff --git a/drivers/net/chelsio/cphy.h b/drivers/net/chelsio/cphy.h
index 8b5165a..1f095a9 100644
--- a/drivers/net/chelsio/cphy.h
+++ b/drivers/net/chelsio/cphy.h
@@ -137,10 +137,11 @@ static inline int simple_mdio_write(struct cphy *cphy, int reg,
 }
 
 /* Convenience initializer */
-static inline void cphy_init(struct cphy *phy, adapter_t *adapter,
+static inline void cphy_init(struct cphy *phy, struct net_device *dev,
 			     int phy_addr, struct cphy_ops *phy_ops,
 			     const struct mdio_ops *mdio_ops)
 {
+	struct adapter *adapter = netdev_priv(dev);
 	phy->adapter = adapter;
 	phy->ops     = phy_ops;
 	if (mdio_ops) {
@@ -150,12 +151,13 @@ static inline void cphy_init(struct cphy *phy, adapter_t *adapter,
 		phy->mdio.mdio_read = mdio_ops->read;
 		phy->mdio.mdio_write = mdio_ops->write;
 	}
+	phy->mdio.dev = dev;
 }
 
 /* Operations of the PHY-instance factory */
 struct gphy {
 	/* Construct a PHY instance with the given PHY address */
-	struct cphy *(*create)(adapter_t *adapter, int phy_addr,
+	struct cphy *(*create)(struct net_device *dev, int phy_addr,
 			       const struct mdio_ops *mdio_ops);
 
 	/*
diff --git a/drivers/net/chelsio/mv88e1xxx.c b/drivers/net/chelsio/mv88e1xxx.c
index 0632be0..809047a 100644
--- a/drivers/net/chelsio/mv88e1xxx.c
+++ b/drivers/net/chelsio/mv88e1xxx.c
@@ -353,15 +353,16 @@ static struct cphy_ops mv88e1xxx_ops = {
 	.get_link_status      = mv88e1xxx_get_link_status,
 };
 
-static struct cphy *mv88e1xxx_phy_create(adapter_t *adapter, int phy_addr,
+static struct cphy *mv88e1xxx_phy_create(struct net_device *dev, int phy_addr,
 					 const struct mdio_ops *mdio_ops)
 {
+	struct adapter *adapter = netdev_priv(dev);
 	struct cphy *cphy = kzalloc(sizeof(*cphy), GFP_KERNEL);
 
 	if (!cphy)
 		return NULL;
 
-	cphy_init(cphy, adapter, phy_addr, &mv88e1xxx_ops, mdio_ops);
+	cphy_init(cphy, dev, phy_addr, &mv88e1xxx_ops, mdio_ops);
 
 	/* Configure particular PHY's to run in a different mode. */
 	if ((board_info(adapter)->caps & SUPPORTED_TP) &&
diff --git a/drivers/net/chelsio/mv88x201x.c b/drivers/net/chelsio/mv88x201x.c
index 29e0cba..df880bb 100644
--- a/drivers/net/chelsio/mv88x201x.c
+++ b/drivers/net/chelsio/mv88x201x.c
@@ -208,7 +208,7 @@ static struct cphy_ops mv88x201x_ops = {
 			      MDIO_DEVS_PHYXS | MDIO_DEVS_WIS),
 };
 
-static struct cphy *mv88x201x_phy_create(adapter_t *adapter, int phy_addr,
+static struct cphy *mv88x201x_phy_create(struct net_device *dev, int phy_addr,
 					 const struct mdio_ops *mdio_ops)
 {
 	u32 val;
@@ -217,7 +217,7 @@ static struct cphy *mv88x201x_phy_create(adapter_t *adapter, int phy_addr,
 	if (!cphy)
 		return NULL;
 
-	cphy_init(cphy, adapter, phy_addr, &mv88x201x_ops, mdio_ops);
+	cphy_init(cphy, dev, phy_addr, &mv88x201x_ops, mdio_ops);
 
 	/* Commands the PHY to enable XFP's clock. */
 	cphy_mdio_read(cphy, MDIO_MMD_PCS, 0x8300, &val);
diff --git a/drivers/net/chelsio/my3126.c b/drivers/net/chelsio/my3126.c
index 977c7e0..4c60285 100644
--- a/drivers/net/chelsio/my3126.c
+++ b/drivers/net/chelsio/my3126.c
@@ -167,7 +167,7 @@ static struct cphy_ops my3126_ops = {
 				   MDIO_DEVS_PHYXS),
 };
 
-static struct cphy *my3126_phy_create(adapter_t *adapter,
+static struct cphy *my3126_phy_create(struct net_device *dev,
 			int phy_addr, const struct mdio_ops *mdio_ops)
 {
 	struct cphy *cphy = kzalloc(sizeof (*cphy), GFP_KERNEL);
@@ -175,7 +175,7 @@ static struct cphy *my3126_phy_create(adapter_t *adapter,
 	if (!cphy)
 		return NULL;
 
-	cphy_init(cphy, adapter, phy_addr, &my3126_ops, mdio_ops);
+	cphy_init(cphy, dev, phy_addr, &my3126_ops, mdio_ops);
 	INIT_DELAYED_WORK(&cphy->phy_update, my3216_poll);
 	cphy->bmsr = 0;
 
diff --git a/drivers/net/chelsio/subr.c b/drivers/net/chelsio/subr.c
index 2564312..17720c6 100644
--- a/drivers/net/chelsio/subr.c
+++ b/drivers/net/chelsio/subr.c
@@ -1135,14 +1135,13 @@ int __devinit t1_init_sw_modules(adapter_t *adapter,
 		struct cmac *mac;
 		int phy_addr = bi->mdio_phybaseaddr + i;
 
-		adapter->port[i].phy = bi->gphy->create(adapter, phy_addr,
-							bi->mdio_ops);
+		adapter->port[i].phy = bi->gphy->create(adapter->port[i].dev,
+							phy_addr, bi->mdio_ops);
 		if (!adapter->port[i].phy) {
 			CH_ERR("%s: PHY %d initialization failed\n",
 			       adapter->name, i);
 			goto error;
 		}
-		adapter->port[i].phy->mdio.dev = adapter->port[i].dev;
 
 		adapter->port[i].mac = mac = bi->gmac->create(adapter, i);
 		if (!mac) {
