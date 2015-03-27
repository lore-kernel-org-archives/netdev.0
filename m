From: Stas Sergeev <stsp@list.ru>
Subject: PATCH 1/6] fixed_phy: pass phy_device instead of net_device to link_update()
 function
Date: Fri, 27 Mar 2015 16:31:08 +0300
Message-ID: <55155B9C.9070609@list.ru>
References: <55155AFC.4050800@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp38.i.mail.ru ([94.100.177.98]:57505 "EHLO smtp38.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752617AbbC0NbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 09:31:17 -0400
In-Reply-To: <55155AFC.4050800@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Looking up phy_device pointer from net_device requires looking into
private data. This may be problematic if phy is handled separately
from net_device.
Pass phy_device pointer to link_update() function because looking
up net_device pointer from phy_device is trivial, if needed.

CC: Florian Fainelli <f.fainelli@gmail.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Andrew Lunn <andrew@lunn.ch>
CC: Guenter Roeck <linux@roeck-us.net>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Joe Perches <joe@perches.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/net/phy/fixed_phy.c |    7 +++----
 include/linux/phy_fixed.h   |    4 ++--
 net/dsa/slave.c             |    3 ++-
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index a08a3c7..8078998 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -36,7 +36,7 @@ struct fixed_phy {
 	u16 regs[MII_REGS_NUM];
 	struct phy_device *phydev;
 	struct fixed_phy_status status;
-	int (*link_update)(struct net_device *, struct fixed_phy_status *);
+	int (*link_update)(struct phy_device *, struct fixed_phy_status *);
 	struct list_head node;
 };

@@ -139,8 +139,7 @@ static int fixed_mdio_read(struct mii_bus *bus, int phy_addr, int reg_num)
 		if (fp->addr == phy_addr) {
 			/* Issue callback if user registered it. */
 			if (fp->link_update) {
-				fp->link_update(fp->phydev->attached_dev,
-						&fp->status);
+				fp->link_update(fp->phydev, &fp->status);
 				fixed_phy_update_regs(fp);
 			}
 			return fp->regs[reg_num];
@@ -162,7 +161,7 @@ static int fixed_mdio_write(struct mii_bus *bus, int phy_addr, int reg_num,
  * May be useful for PHY's that need to be software-driven.
  */
 int fixed_phy_set_link_update(struct phy_device *phydev,
-			      int (*link_update)(struct net_device *,
+			      int (*link_update)(struct phy_device *,
 						 struct fixed_phy_status *))
 {
 	struct fixed_mdio_bus *fmb = &platform_fmb;
diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
index 7e75bfe..ac82e6d 100644
--- a/include/linux/phy_fixed.h
+++ b/include/linux/phy_fixed.h
@@ -19,7 +19,7 @@ extern struct phy_device *fixed_phy_register(unsigned int irq,
 					     struct device_node *np);
 extern void fixed_phy_del(int phy_addr);
 extern int fixed_phy_set_link_update(struct phy_device *phydev,
-			int (*link_update)(struct net_device *,
+			int (*link_update)(struct phy_device *,
 					   struct fixed_phy_status *));
 #else
 static inline int fixed_phy_add(unsigned int irq, int phy_id,
@@ -38,7 +38,7 @@ static inline int fixed_phy_del(int phy_addr)
 	return -ENODEV;
 }
 static inline int fixed_phy_set_link_update(struct phy_device *phydev,
-			int (*link_update)(struct net_device *,
+			int (*link_update)(struct phy_device *,
 					   struct fixed_phy_status *))
 {
 	return -ENODEV;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index f23dead..86ac744 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -500,9 +500,10 @@ static void dsa_slave_adjust_link(struct net_device *dev)
 		phy_print_status(p->phy);
 }

-static int dsa_slave_fixed_link_update(struct net_device *dev,
+static int dsa_slave_fixed_link_update(struct phy_device *phy,
 				       struct fixed_phy_status *status)
 {
+	struct net_device *dev = phy->attached_dev;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;

-- 
1.7.9.5
