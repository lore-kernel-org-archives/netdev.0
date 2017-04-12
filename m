From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 03/10] ftgmac100: Disable HW checksum generation on AST2400, enable on others
Date: Wed, 12 Apr 2017 13:27:03 +1000
Message-ID: <20170412032710.17546-4-benh@kernel.crashing.org>
References: <20170412032710.17546-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41852 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752303AbdDLD1g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 23:27:36 -0400
In-Reply-To: <20170412032710.17546-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We found out that HW checksum generation only works from AST2500
onward. This disables it on AST2400 and removes the "no-hw-checksum"
properties in the device-trees. The problem we had wasn't related
to NC-SI.

Also rework the logic testing for that property so it can be used
to disable HW checksum generation and checking regardless of whether
NC-SI is used or not in case other variants out there need this.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/arm/boot/dts/aspeed-g4.dtsi         |  2 --
 arch/arm/boot/dts/aspeed-g5.dtsi         |  2 --
 drivers/net/ethernet/faraday/ftgmac100.c | 12 ++++++------
 3 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/arch/arm/boot/dts/aspeed-g4.dtsi b/arch/arm/boot/dts/aspeed-g4.dtsi
index 6068e79..c79c937 100644
--- a/arch/arm/boot/dts/aspeed-g4.dtsi
+++ b/arch/arm/boot/dts/aspeed-g4.dtsi
@@ -45,7 +45,6 @@
 			compatible = "aspeed,ast2400-mac", "faraday,ftgmac100";
 			reg = <0x1e660000 0x180>;
 			interrupts = <2>;
-			no-hw-checksum;
 			status = "disabled";
 		};
 
@@ -53,7 +52,6 @@
 			compatible = "aspeed,ast2400-mac", "faraday,ftgmac100";
 			reg = <0x1e680000 0x180>;
 			interrupts = <3>;
-			no-hw-checksum;
 			status = "disabled";
 		};
 
diff --git a/arch/arm/boot/dts/aspeed-g5.dtsi b/arch/arm/boot/dts/aspeed-g5.dtsi
index 4dbe91a..b659663 100644
--- a/arch/arm/boot/dts/aspeed-g5.dtsi
+++ b/arch/arm/boot/dts/aspeed-g5.dtsi
@@ -36,7 +36,6 @@
 			compatible = "aspeed,ast2500-mac", "faraday,ftgmac100";
 			reg = <0x1e660000 0x180>;
 			interrupts = <2>;
-			no-hw-checksum;
 			status = "disabled";
 		};
 
@@ -44,7 +43,6 @@
 			compatible = "aspeed,ast2500-mac", "faraday,ftgmac100";
 			reg = <0x1e680000 0x180>;
 			interrupts = <3>;
-			no-hw-checksum;
 			status = "disabled";
 		};
 
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 6a4fed6..bd25b6b 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1471,15 +1471,15 @@ static int ftgmac100_probe(struct platform_device *pdev)
 			goto err_setup_mdio;
 	}
 
-	/* We have to disable on-chip IP checksum functionality
-	 * when NCSI is enabled on the interface. It doesn't work
-	 * in that case.
-	 */
+	/* Base feature set */
 	netdev->features = NETIF_F_RXCSUM | NETIF_F_HW_CSUM |
 		NETIF_F_GRO | NETIF_F_SG;
-	if (priv->use_ncsi &&
-	    of_get_property(np, "no-hw-checksum", NULL))
+
+	/* AST2400  doesn't have working HW checksum generation */
+	if (np && (of_device_is_compatible(np, "aspeed,ast2400-mac")))
 		netdev->features &= ~NETIF_F_HW_CSUM;
+	if (np && of_get_property(np, "no-hw-checksum", NULL))
+		netdev->features &= ~(NETIF_F_HW_CSUM | NETIF_F_RXCSUM);
 
 	/* register network device */
 	err = register_netdev(netdev);
-- 
2.9.3
