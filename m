From: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Subject: [PATCH] net: phy: smsc: disable energy detect mode
Date: Tue, 13 Oct 2015 07:13:09 +0200
Message-ID: <1444713189-23063-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Georg.Soffel-k21M0aUVSxZWk0Htik3J/w@public.gmane.org,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On some boards the energy enable detect mode leads in
trouble with some switches, so make the enabling of
this mode configurable through DT.

Signed-off-by: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
---

 .../devicetree/bindings/net/smsc-lan87xx.txt       | 19 +++++++++++++++++
 drivers/net/phy/smsc.c                             | 24 +++++++++++++++++-----
 2 files changed, 38 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/smsc-lan87xx.txt

diff --git a/Documentation/devicetree/bindings/net/smsc-lan87xx.txt b/Documentation/devicetree/bindings/net/smsc-lan87xx.txt
new file mode 100644
index 0000000..39aa1dc
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/smsc-lan87xx.txt
@@ -0,0 +1,19 @@
+SMSC LAN87xx Ethernet PHY
+
+Some boards require special tuning values. Configure them
+through an Ethernet OF device node.
+
+Optional properties:
+
+- disable-energy-detect:
+  If set, do not enable energy detect mode for the SMSC phy.
+  default: enable energy detect mode
+
+Examples:
+
+	/* Attach to an Ethernet device with autodetected PHY */
+	&cpsw_emac0 {
+		phy_id = <&davinci_mdio>, <0>;
+		phy-mode = "mii";
+		disable-energy-detect;
+	};
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 70b0895..f90fbf3 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -43,16 +43,30 @@ static int smsc_phy_ack_interrupt(struct phy_device *phydev)
 
 static int smsc_phy_config_init(struct phy_device *phydev)
 {
+#ifdef CONFIG_OF
+	int len;
+	struct device *dev = &phydev->dev;
+	struct device_node *of_node = dev->of_node;
+#endif
 	int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
+	int enable_energy = 1;
 
 	if (rc < 0)
 		return rc;
 
-	/* Enable energy detect mode for this SMSC Transceivers */
-	rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
-		       rc | MII_LAN83C185_EDPWRDOWN);
-	if (rc < 0)
-		return rc;
+#ifdef CONFIG_OF
+	if (!of_node && dev->parent->of_node)
+		of_node = dev->parent->of_node;
+	if (of_find_property(of_node, "disable-energy-detect", &len))
+		enable_energy = 0;
+#endif
+	if (enable_energy) {
+		/* Enable energy detect mode for this SMSC Transceivers */
+		rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
+			       rc | MII_LAN83C185_EDPWRDOWN);
+		if (rc < 0)
+			return rc;
+	}
 
 	return smsc_phy_ack_interrupt(phydev);
 }
-- 
2.1.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
