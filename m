From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: set random switch address
Date: Thu, 12 Oct 2017 18:10:09 -0400
Message-ID: <20171012221009.14615-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An Ethernet switch may support having a MAC address, which can be used
as the switch's source address in transmitted full-duplex Pause frames.

If a DSA switch supports the related .set_addr operation, the DSA core
sets the master's MAC address on the switch.

This won't make sense anymore in a multi-CPU ports system, because there
won't be a unique master device assigned to a switch tree.

To fix this, assign a random MAC address to the switch chip instead.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c     |  8 +++-----
 net/dsa/dsa_priv.h |  1 +
 net/dsa/legacy.c   |  8 +++-----
 net/dsa/switch.c   | 17 +++++++++++++++++
 4 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 54ed054777bd..8e5780ddd7f9 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -336,11 +336,9 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	if (err)
 		return err;
 
-	if (ds->ops->set_addr) {
-		err = ds->ops->set_addr(ds, dst->cpu_dp->netdev->dev_addr);
-		if (err < 0)
-			return err;
-	}
+	err = dsa_switch_set_addr(ds);
+	if (err)
+		return err;
 
 	if (!ds->slave_mii_bus && ds->ops->phy_read) {
 		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 2850077cc9cc..9c4c17a4bd6b 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -172,6 +172,7 @@ void dsa_slave_unregister_notifier(void);
 /* switch.c */
 int dsa_switch_register_notifier(struct dsa_switch *ds);
 void dsa_switch_unregister_notifier(struct dsa_switch *ds);
+int dsa_switch_set_addr(struct dsa_switch *ds);
 
 /* tag_brcm.c */
 extern const struct dsa_device_ops brcm_netdev_ops;
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 19ff6e0a21dc..340ca7997271 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -172,11 +172,9 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 	if (ret)
 		return ret;
 
-	if (ops->set_addr) {
-		ret = ops->set_addr(ds, master->dev_addr);
-		if (ret < 0)
-			return ret;
-	}
+	ret = dsa_switch_set_addr(ds);
+	if (ret)
+		return ret;
 
 	if (!ds->slave_mii_bus && ops->phy_read) {
 		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index e6c06aa349a6..b45a26b006af 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -10,6 +10,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/etherdevice.h>
 #include <linux/netdevice.h>
 #include <linux/notifier.h>
 #include <net/switchdev.h>
@@ -267,3 +268,19 @@ void dsa_switch_unregister_notifier(struct dsa_switch *ds)
 	if (err)
 		dev_err(ds->dev, "failed to unregister notifier (%d)\n", err);
 }
+
+int dsa_switch_set_addr(struct dsa_switch *ds)
+{
+	u8 addr[6];
+	int err;
+
+	if (ds->ops->set_addr) {
+		eth_random_addr(addr);
+
+		err = ds->ops->set_addr(ds, addr);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
-- 
2.14.2
