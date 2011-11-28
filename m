From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 2/3] dsa: Move all definitions needed by drivers
 into <net/dsa.h>
Date: Mon, 28 Nov 2011 03:06:08 +0000
Message-ID: <1322449568.7454.35.camel@deadeye>
References: <1322449506.7454.34.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54042 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754951Ab1K1DGP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Nov 2011 22:06:15 -0500
In-Reply-To: <1322449506.7454.34.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any headers included by drivers should be under include/, and
any definitions they use are not really private to the core as
the name "dsa_priv.h" suggests.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/net/dsa.h         |   90 ++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/dsa_priv.h        |   91 ---------------------------------------------
 net/dsa/mv88e6060.c       |    2 +-
 net/dsa/mv88e6123_61_65.c |    2 +-
 net/dsa/mv88e6131.c       |    2 +-
 net/dsa/mv88e6xxx.c       |    2 +-
 6 files changed, 94 insertions(+), 95 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 32a1b49..b78db3c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -11,6 +11,7 @@
 #ifndef __LINUX_NET_DSA_H
 #define __LINUX_NET_DSA_H
 
+#include <linux/list.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 
@@ -90,6 +91,95 @@ struct dsa_switch_tree {
 	struct dsa_switch	*ds[DSA_MAX_SWITCHES];
 };
 
+struct dsa_switch {
+	/*
+	 * Parent switch tree, and switch index.
+	 */
+	struct dsa_switch_tree	*dst;
+	int			index;
+
+	/*
+	 * Configuration data for this switch.
+	 */
+	struct dsa_chip_data	*pd;
+
+	/*
+	 * The used switch driver.
+	 */
+	struct dsa_switch_driver	*drv;
+
+	/*
+	 * Reference to mii bus to use.
+	 */
+	struct mii_bus		*master_mii_bus;
+
+	/*
+	 * Slave mii_bus and devices for the individual ports.
+	 */
+	u32			dsa_port_mask;
+	u32			phys_port_mask;
+	struct mii_bus		*slave_mii_bus;
+	struct net_device	*ports[DSA_MAX_PORTS];
+};
+
+static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
+{
+	return !!(ds->index == ds->dst->cpu_switch && p == ds->dst->cpu_port);
+}
+
+static inline u8 dsa_upstream_port(struct dsa_switch *ds)
+{
+	struct dsa_switch_tree *dst = ds->dst;
+
+	/*
+	 * If this is the root switch (i.e. the switch that connects
+	 * to the CPU), return the cpu port number on this switch.
+	 * Else return the (DSA) port number that connects to the
+	 * switch that is one hop closer to the cpu.
+	 */
+	if (dst->cpu_switch == ds->index)
+		return dst->cpu_port;
+	else
+		return ds->pd->rtable[dst->cpu_switch];
+}
+
+struct dsa_switch_driver {
+	struct list_head	list;
+
+	__be16			tag_protocol;
+	int			priv_size;
+
+	/*
+	 * Probing and setup.
+	 */
+	char	*(*probe)(struct mii_bus *bus, int sw_addr);
+	int	(*setup)(struct dsa_switch *ds);
+	int	(*set_addr)(struct dsa_switch *ds, u8 *addr);
+
+	/*
+	 * Access to the switch's PHY registers.
+	 */
+	int	(*phy_read)(struct dsa_switch *ds, int port, int regnum);
+	int	(*phy_write)(struct dsa_switch *ds, int port,
+			     int regnum, u16 val);
+
+	/*
+	 * Link state polling and IRQ handling.
+	 */
+	void	(*poll_link)(struct dsa_switch *ds);
+
+	/*
+	 * ethtool hardware statistics.
+	 */
+	void	(*get_strings)(struct dsa_switch *ds, int port, uint8_t *data);
+	void	(*get_ethtool_stats)(struct dsa_switch *ds,
+				     int port, uint64_t *data);
+	int	(*get_sset_count)(struct dsa_switch *ds);
+};
+
+void register_switch_driver(struct dsa_switch_driver *type);
+void unregister_switch_driver(struct dsa_switch_driver *type);
+
 /*
  * The original DSA tag format and some other tag formats have no
  * ethertype, which means that we need to add a little hack to the
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 89a2eb4..d4cf5cc 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -11,64 +11,9 @@
 #ifndef __DSA_PRIV_H
 #define __DSA_PRIV_H
 
-#include <linux/list.h>
 #include <linux/phy.h>
-#include <linux/timer.h>
-#include <linux/workqueue.h>
 #include <net/dsa.h>
 
-struct dsa_switch {
-	/*
-	 * Parent switch tree, and switch index.
-	 */
-	struct dsa_switch_tree	*dst;
-	int			index;
-
-	/*
-	 * Configuration data for this switch.
-	 */
-	struct dsa_chip_data	*pd;
-
-	/*
-	 * The used switch driver.
-	 */
-	struct dsa_switch_driver	*drv;
-
-	/*
-	 * Reference to mii bus to use.
-	 */
-	struct mii_bus		*master_mii_bus;
-
-	/*
-	 * Slave mii_bus and devices for the individual ports.
-	 */
-	u32			dsa_port_mask;
-	u32			phys_port_mask;
-	struct mii_bus		*slave_mii_bus;
-	struct net_device	*ports[DSA_MAX_PORTS];
-};
-
-static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
-{
-	return !!(ds->index == ds->dst->cpu_switch && p == ds->dst->cpu_port);
-}
-
-static inline u8 dsa_upstream_port(struct dsa_switch *ds)
-{
-	struct dsa_switch_tree *dst = ds->dst;
-
-	/*
-	 * If this is the root switch (i.e. the switch that connects
-	 * to the CPU), return the cpu port number on this switch.
-	 * Else return the (DSA) port number that connects to the
-	 * switch that is one hop closer to the cpu.
-	 */
-	if (dst->cpu_switch == ds->index)
-		return dst->cpu_port;
-	else
-		return ds->pd->rtable[dst->cpu_switch];
-}
-
 struct dsa_slave_priv {
 	/*
 	 * The linux network interface corresponding to this
@@ -90,44 +35,8 @@ struct dsa_slave_priv {
 	struct phy_device	*phy;
 };
 
-struct dsa_switch_driver {
-	struct list_head	list;
-
-	__be16			tag_protocol;
-	int			priv_size;
-
-	/*
-	 * Probing and setup.
-	 */
-	char	*(*probe)(struct mii_bus *bus, int sw_addr);
-	int	(*setup)(struct dsa_switch *ds);
-	int	(*set_addr)(struct dsa_switch *ds, u8 *addr);
-
-	/*
-	 * Access to the switch's PHY registers.
-	 */
-	int	(*phy_read)(struct dsa_switch *ds, int port, int regnum);
-	int	(*phy_write)(struct dsa_switch *ds, int port,
-			     int regnum, u16 val);
-
-	/*
-	 * Link state polling and IRQ handling.
-	 */
-	void	(*poll_link)(struct dsa_switch *ds);
-
-	/*
-	 * ethtool hardware statistics.
-	 */
-	void	(*get_strings)(struct dsa_switch *ds, int port, uint8_t *data);
-	void	(*get_ethtool_stats)(struct dsa_switch *ds,
-				     int port, uint64_t *data);
-	int	(*get_sset_count)(struct dsa_switch *ds);
-};
-
 /* dsa.c */
 extern char dsa_driver_version[];
-void register_switch_driver(struct dsa_switch_driver *type);
-void unregister_switch_driver(struct dsa_switch_driver *type);
 
 /* slave.c */
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
diff --git a/net/dsa/mv88e6060.c b/net/dsa/mv88e6060.c
index 0e028df..7fc4e81 100644
--- a/net/dsa/mv88e6060.c
+++ b/net/dsa/mv88e6060.c
@@ -11,7 +11,7 @@
 #include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
-#include "dsa_priv.h"
+#include <net/dsa.h>
 
 #define REG_PORT(p)		(8 + (p))
 #define REG_GLOBAL		0x0f
diff --git a/net/dsa/mv88e6123_61_65.c b/net/dsa/mv88e6123_61_65.c
index 6504405..c0a458f 100644
--- a/net/dsa/mv88e6123_61_65.c
+++ b/net/dsa/mv88e6123_61_65.c
@@ -11,7 +11,7 @@
 #include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
-#include "dsa_priv.h"
+#include <net/dsa.h>
 #include "mv88e6xxx.h"
 
 static char *mv88e6123_61_65_probe(struct mii_bus *bus, int sw_addr)
diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
index 6786ba4..e0eb6824 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -11,7 +11,7 @@
 #include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
-#include "dsa_priv.h"
+#include <net/dsa.h>
 #include "mv88e6xxx.h"
 
 /*
diff --git a/net/dsa/mv88e6xxx.c b/net/dsa/mv88e6xxx.c
index cacd955..5467c04 100644
--- a/net/dsa/mv88e6xxx.c
+++ b/net/dsa/mv88e6xxx.c
@@ -11,7 +11,7 @@
 #include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
-#include "dsa_priv.h"
+#include <net/dsa.h>
 #include "mv88e6xxx.h"
 
 /*
-- 
1.7.7.3
