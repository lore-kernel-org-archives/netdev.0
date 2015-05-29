From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: [PATCH 6/7] net: dsa: ar8xxx: add support for second xMII interfaces through DT
Date: Thu, 28 May 2015 18:42:21 -0700
Message-ID: <1432863742-18427-7-git-send-email-mathieu@codeaurora.org>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, mathieu@codeaurora.org, andrew@lunn.ch,
	f.fainelli@gmail.com, linux@roeck-us.net, gang.chen.5i5j@gmail.com,
	jiri@resnulli.us, leitec@staticky.com, fabf@skynet.be,
	alexander.h.duyck@intel.com, pavel.nakonechny@skitlab.ru,
	joe@perches.com, sfeldma@gmail.com, nbd@openwrt.org,
	juhosg@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is adding support for port6 specific options to device tree.
They can be used to setup the second xMII interface, and connect it to
one of the switch port.

Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>
---
 drivers/net/dsa/ar8xxx.c | 50 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

diff --git a/drivers/net/dsa/ar8xxx.c b/drivers/net/dsa/ar8xxx.c
index 4044614..7559249 100644
--- a/drivers/net/dsa/ar8xxx.c
+++ b/drivers/net/dsa/ar8xxx.c
@@ -19,6 +19,7 @@
 #include <net/dsa.h>
 #include <linux/phy.h>
 #include <linux/of_net.h>
+#include <linux/of_platform.h>
 
 #include "ar8xxx.h"
 
@@ -260,6 +261,9 @@ static int ar8xxx_set_pad_ctrl(struct dsa_switch *ds, int port, int mode)
 		ar8xxx_write(ds, AR8327_REG_PORT5_PAD_CTRL,
 			     AR8327_PORT_PAD_RGMII_RX_DELAY_EN);
 		break;
+	case PHY_INTERFACE_MODE_SGMII:
+		ar8xxx_write(ds, reg, AR8327_PORT_PAD_SGMII_EN);
+		break;
 	default:
 		pr_err("xMII mode %d not supported\n", mode);
 		return -EINVAL;
@@ -268,6 +272,48 @@ static int ar8xxx_set_pad_ctrl(struct dsa_switch *ds, int port, int mode)
 	return 0;
 }
 
+static int ar8xxx_of_setup(struct dsa_switch *ds)
+{
+	struct device_node *dn = ds->pd->of_node;
+	const char *s_phymode;
+	int ret, mode;
+	u32 phy_id, ctrl;
+
+	/* If port6-phy-mode property exists, configure it accordingly */
+	if (!of_property_read_string(dn, "qca,port6-phy-mode", &s_phymode)) {
+		for (mode = 0; mode < PHY_INTERFACE_MODE_MAX; mode++)
+			if (!strcasecmp(s_phymode, phy_modes(mode)))
+				break;
+
+		if (mode == PHY_INTERFACE_MODE_MAX)
+			pr_err("Unknown phy-mode: \"%s\"\n", s_phymode);
+
+		ret = ar8xxx_set_pad_ctrl(ds, 6, mode);
+		if (ret < 0)
+			return ret;
+	}
+
+	/* If a phy ID is specified for PORT6 mac, connect them together */
+	if (!of_property_read_u32(dn, "qca,port6-phy-id", &phy_id)) {
+		ar8xxx_rmw(ds, AR8327_PORT_LOOKUP_CTRL(6),
+			   AR8327_PORT_LOOKUP_MEMBER, BIT(phy_to_port(phy_id)));
+		ar8xxx_rmw(ds, AR8327_PORT_LOOKUP_CTRL(phy_to_port(phy_id)),
+			   AR8327_PORT_LOOKUP_MEMBER, BIT(6));
+
+		/* We want the switch to be pass-through and act like a PHY on
+		 * these ports. So BC/MC/UC & IGMP frames need to be accepted
+		 */
+		ctrl = BIT(phy_to_port(phy_id)) | BIT(6);
+		ar8xxx_reg_set(ds, AR8327_REG_GLOBAL_FW_CTRL1,
+			       ctrl << AR8327_GLOBAL_FW_CTRL1_IGMP_DP_S |
+			       ctrl << AR8327_GLOBAL_FW_CTRL1_BC_DP_S |
+			       ctrl << AR8327_GLOBAL_FW_CTRL1_MC_DP_S |
+			       ctrl << AR8327_GLOBAL_FW_CTRL1_UC_DP_S);
+	}
+
+	return 0;
+}
+
 static int ar8xxx_setup(struct dsa_switch *ds)
 {
 	struct ar8xxx_priv *priv = ds_to_priv(ds);
@@ -341,6 +387,10 @@ static int ar8xxx_setup(struct dsa_switch *ds)
 		}
 	}
 
+	ret = ar8xxx_of_setup(ds);
+	if (ret < 0)
+		return ret;
+
 	return 0;
 }
 
-- 
2.1.4
