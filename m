From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 02/16] of_mdio: add helper to deregister fixed-link PHYs
Date: Mon, 28 Nov 2016 19:24:55 +0100
Message-ID: <1480357509-28074-3-git-send-email-johan@kernel.org>
References: <1480357509-28074-1-git-send-email-johan@kernel.org>
Cc: Vince Bridgers <vbridger@opensource.altera.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>,
        Claudiu Manoil <claudiu.manoil@freescale.com>,
        Li Yang <leoli@freescale.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Felix Fietkau <nbd@openwrt.org>,
        John Crispin <blogic@openwrt.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Lars Persson <lars.persson@axis.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1480357509-28074-1-git-send-email-johan@kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add helper to deregister fixed-link PHYs registered using
of_phy_register_fixed_link().

Convert the two drivers that care to deregister their fixed-link PHYs to
use the new helper, but note that most drivers currently fail to do so.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/cpsw.c | 16 ++--------------
 drivers/of/of_mdio.c           | 15 +++++++++++++++
 include/linux/of_mdio.h        |  4 ++++
 net/dsa/dsa.c                  | 12 ++----------
 4 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 58947aae31c7..9f0646512624 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2459,20 +2459,8 @@ static void cpsw_remove_dt(struct platform_device *pdev)
 		if (strcmp(slave_node->name, "slave"))
 			continue;
 
-		if (of_phy_is_fixed_link(slave_node)) {
-			struct phy_device *phydev;
-
-			phydev = of_phy_find_device(slave_node);
-			if (phydev) {
-				fixed_phy_unregister(phydev);
-				/* Put references taken by
-				 * of_phy_find_device() and
-				 * of_phy_register_fixed_link().
-				 */
-				phy_device_free(phydev);
-				phy_device_free(phydev);
-			}
-		}
+		if (of_phy_is_fixed_link(slave_node))
+			of_phy_deregister_fixed_link(slave_node);
 
 		of_node_put(slave_data->phy_node);
 
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 5a3145a02547..262281bd68fa 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -490,3 +490,18 @@ int of_phy_register_fixed_link(struct device_node *np)
 	return -ENODEV;
 }
 EXPORT_SYMBOL(of_phy_register_fixed_link);
+
+void of_phy_deregister_fixed_link(struct device_node *np)
+{
+	struct phy_device *phydev;
+
+	phydev = of_phy_find_device(np);
+	if (!phydev)
+		return;
+
+	fixed_phy_unregister(phydev);
+
+	put_device(&phydev->mdio.dev);	/* of_phy_find_device() */
+	phy_device_free(phydev);	/* fixed_phy_register() */
+}
+EXPORT_SYMBOL(of_phy_deregister_fixed_link);
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 2ab233661ae5..a58cca8bcb29 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -29,6 +29,7 @@ struct phy_device *of_phy_attach(struct net_device *dev,
 extern struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np);
 extern int of_mdio_parse_addr(struct device *dev, const struct device_node *np);
 extern int of_phy_register_fixed_link(struct device_node *np);
+extern void of_phy_deregister_fixed_link(struct device_node *np);
 extern bool of_phy_is_fixed_link(struct device_node *np);
 
 #else /* CONFIG_OF */
@@ -83,6 +84,9 @@ static inline int of_phy_register_fixed_link(struct device_node *np)
 {
 	return -ENOSYS;
 }
+static inline void of_phy_deregister_fixed_link(struct device_node *np)
+{
+}
 static inline bool of_phy_is_fixed_link(struct device_node *np)
 {
 	return false;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index cb0091b99592..7899919cd9f0 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -506,16 +506,8 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 
 void dsa_cpu_dsa_destroy(struct device_node *port_dn)
 {
-	struct phy_device *phydev;
-
-	if (of_phy_is_fixed_link(port_dn)) {
-		phydev = of_phy_find_device(port_dn);
-		if (phydev) {
-			fixed_phy_unregister(phydev);
-			put_device(&phydev->mdio.dev);
-			phy_device_free(phydev);
-		}
-	}
+	if (of_phy_is_fixed_link(port_dn))
+		of_phy_deregister_fixed_link(port_dn);
 }
 
 static void dsa_switch_destroy(struct dsa_switch *ds)
-- 
2.7.3
