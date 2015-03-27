From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 3/6] of_mdio: restructure of_phy_register_fixed_link() for
 further modifications
Date: Fri, 27 Mar 2015 16:35:56 +0300
Message-ID: <55155CBC.6010402@list.ru>
References: <55155AFC.4050800@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, devicetree@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55155AFC.4050800@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is a no-op patch needed to separate code rearrangements from
the actual changes. It allows to easily add code to the function
without duplicating it for new and old fixed-phy DT binding.
The subsequent patch therefore happily adds the code without duplications.

CC: Florian Fainelli <f.fainelli@gmail.com>
CC: Grant Likely <grant.likely@linaro.org>
CC: Rob Herring <robh+dt@kernel.org>
CC: netdev@vger.kernel.org
CC: devicetree@vger.kernel.org
CC: linux-kernel@vger.kernel.org

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/of/of_mdio.c |   32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 1bd4305..b3dc1e6 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -301,22 +301,26 @@ int of_phy_register_fixed_link(struct device_node *np)
 							  "asym-pause");
 		of_node_put(fixed_link_node);
 		phy = fixed_phy_register(PHY_POLL, &status, np);
-		return IS_ERR(phy) ? PTR_ERR(phy) : 0;
-	}
-
-	/* Old binding */
-	fixed_link_prop = of_get_property(np, "fixed-link", &len);
-	if (fixed_link_prop && len == (5 * sizeof(__be32))) {
-		status.link = 1;
-		status.duplex = be32_to_cpu(fixed_link_prop[1]);
-		status.speed = be32_to_cpu(fixed_link_prop[2]);
-		status.pause = be32_to_cpu(fixed_link_prop[3]);
-		status.asym_pause = be32_to_cpu(fixed_link_prop[4]);
-		phy = fixed_phy_register(PHY_POLL, &status, np);
-		return IS_ERR(phy) ? PTR_ERR(phy) : 0;
+		if (IS_ERR(phy))
+			return PTR_ERR(phy);
+	} else {
+		/* Old binding */
+		fixed_link_prop = of_get_property(np, "fixed-link", &len);
+		if (fixed_link_prop && len == (5 * sizeof(__be32))) {
+			status.link = 1;
+			status.duplex = be32_to_cpu(fixed_link_prop[1]);
+			status.speed = be32_to_cpu(fixed_link_prop[2]);
+			status.pause = be32_to_cpu(fixed_link_prop[3]);
+			status.asym_pause = be32_to_cpu(fixed_link_prop[4]);
+			phy = fixed_phy_register(PHY_POLL, &status, np);
+			if (IS_ERR(phy))
+				return PTR_ERR(phy);
+		} else {
+			return -ENODEV;
+		}
 	}

-	return -ENODEV;
+	return 0;
 }
 EXPORT_SYMBOL(of_phy_register_fixed_link);
 #endif
-- 
1.7.9.5
