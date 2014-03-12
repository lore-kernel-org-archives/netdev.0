From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: [PATCH v2a RESEND 2/2] of_mdio: Allow the DT to specify the phy ID and avoid autoprobing
Date: Wed, 12 Mar 2014 15:05:11 -0600
Message-ID: <1394658311-17769-2-git-send-email-jgunthorpe@obsidianresearch.com>
References: <1394658311-17769-1-git-send-email-jgunthorpe@obsidianresearch.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394658311-17769-1-git-send-email-jgunthorpe@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This makes the generic of_mdiobus_register parse the DT compatible string for
the pattern ethernet-phy-idAAAA.BBBB. If present it should be a value that
matches the phy-id register normally readable through MDIO.

When the ID is given the phy autoprobing is defeated and the phy is
created directly.

This is necessary to support phy's that cannot be autoprobed when
of_mdiobus_register is called. Specifically, my case has the phy in reset at
of_mdiobus_register, the reset is only released once the ethernet driver
starts, before it attaches to the phy.

Tested on ARM Kirkwood with phy id 0x01410e90 (Marvell 88E1318)

Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/of/of_mdio.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

There was some reworking of the original code in v3.14-rc6, this resolves the
merge conflicts and I retested the resolved patch on Kirkwood.

Florian, do you know what path to mainline a this patch should take?

Thanks,
Jason

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 5b3c24f..6cdcbda 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -43,6 +43,30 @@ static void of_set_phy_supported(struct phy_device *phydev, u32 max_speed)
 	}
 }
 
+/* Extract the clause 22 phy ID from the compatible string of the form
+ * ethernet-phy-idAAAA.BBBB */
+static int of_get_phy_id(struct device_node *device, u32 *phy_id)
+{
+	const char *cp;
+	int cplen, l;
+	unsigned int upper, lower;
+
+	cp = of_get_property(device, "compatible", &cplen);
+	if (cp == NULL)
+		return -EINVAL;
+	while (cplen > 0) {
+		if (sscanf(cp, "ethernet-phy-id%4x.%4x", &upper, &lower) == 2) {
+			*phy_id = ((upper & 0xFFFF) << 16) | (lower & 0xFFFF);
+			return 0;
+		}
+
+		l = strlen(cp) + 1;
+		cp += l;
+		cplen -= l;
+	}
+	return -EINVAL;
+}
+
 static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *child,
 				   u32 addr)
 {
@@ -50,11 +74,15 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
 	bool is_c45;
 	int rc;
 	u32 max_speed = 0;
+	u32 phy_id;
 
 	is_c45 = of_device_is_compatible(child,
 					 "ethernet-phy-ieee802.3-c45");
 
-	phy = get_phy_device(mdio, addr, is_c45);
+	if (!is_c45 && !of_get_phy_id(child, &phy_id))
+		phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
+	else
+		phy = get_phy_device(mdio, addr, is_c45);
 	if (!phy || IS_ERR(phy))
 		return 1;
 
-- 
1.8.1.2
