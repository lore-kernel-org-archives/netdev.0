From: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Subject: [PATCH v2 2/2] net: phy: smsc: disable energy detect mode
Date: Sat, 17 Oct 2015 06:04:36 +0200
Message-ID: <1445054676-21523-3-git-send-email-hs@denx.de>
References: <1445054676-21523-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Georg.Soffel-k21M0aUVSxZWk0Htik3J/w@public.gmane.org,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1445054676-21523-1-git-send-email-hs-ynQEQJNshbs@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On some boards the energy enable detect mode leads in
trouble with some switches, so make the enabling of
this mode configurable through DT.

Signed-off-by: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
---

Changes in v2:
- add comments from Florian Fainelli
  - I did not change disable property name into enable
    because I fear to break existing behaviour
  - add smsc vendor prefix
  - remove CONFIG_OF and use __maybe_unused
  - introduce "phy-handle" ability into ti,cpsw
    driver, so I can remove bogus:
      if (!of_node && dev->parent->of_node)
          of_node = dev->parent->of_node;
    construct. Therefore new patch for the ti,cpsw
    driver is necessary.

 .../devicetree/bindings/net/smsc-lan87xx.txt       | 24 ++++++++++++++++++++++
 drivers/net/phy/smsc.c                             | 19 ++++++++++++-----
 2 files changed, 38 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/smsc-lan87xx.txt

diff --git a/Documentation/devicetree/bindings/net/smsc-lan87xx.txt b/Documentation/devicetree/bindings/net/smsc-lan87xx.txt
new file mode 100644
index 0000000..974edd5
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/smsc-lan87xx.txt
@@ -0,0 +1,24 @@
+SMSC LAN87xx Ethernet PHY
+
+Some boards require special tuning values. Configure them
+through an Ethernet OF device node.
+
+Optional properties:
+
+- smsc,disable-energy-detect:
+  If set, do not enable energy detect mode for the SMSC phy.
+  default: enable energy detect mode
+
+Examples:
+smsc phy with disabled energy detect mode on an am335x based board.
+&davinci_mdio {
+	pinctrl-names = "default", "sleep";
+	pinctrl-0 = <&davinci_mdio_default>;
+	pinctrl-1 = <&davinci_mdio_sleep>;
+	status = "okay";
+
+	ethernetphy0: ethernet-phy@0 {
+		reg = <0>;
+		smsc,disable-energy-detect;
+	};
+};
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 70b0895..dc2da87 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -43,16 +43,25 @@ static int smsc_phy_ack_interrupt(struct phy_device *phydev)
 
 static int smsc_phy_config_init(struct phy_device *phydev)
 {
+	int __maybe_unused len;
+	struct device *dev __maybe_unused = &phydev->dev;
+	struct device_node *of_node __maybe_unused = dev->of_node;
 	int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
+	int enable_energy = 1;
 
 	if (rc < 0)
 		return rc;
 
-	/* Enable energy detect mode for this SMSC Transceivers */
-	rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
-		       rc | MII_LAN83C185_EDPWRDOWN);
-	if (rc < 0)
-		return rc;
+	if (of_find_property(of_node, "smsc,disable-energy-detect", &len))
+		enable_energy = 0;
+
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
