From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH 2/3] net: ethoc: set up MII management bus clock
Date: Mon, 27 Jan 2014 07:59:26 +0400
Message-ID: <1390795167-6677-3-git-send-email-jcmvbkbc@gmail.com>
References: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MII management bus clock is derived from the MAC clock by dividing it by
MIIMODER register CLKDIV field value. This value may need to be set up
in case it is undefined or its default value is too high (and
communication with PHY is too slow) or too low (and communication with
PHY is impossible). The value of CLKDIV is not specified directly, but
as a pair of MAC frequency and desired MII management bus frequency, as
these parameters are natural.

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 27 +++++++++++++++++++++++++--
 include/net/ethoc.h          |  2 ++
 2 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 0aa1a05..5831406 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -919,6 +919,9 @@ static int ethoc_probe(struct platform_device *pdev)
 	int num_bd;
 	int ret = 0;
 	bool random_mac = false;
+	u32 eth_clkfreq = 0;
+	u32 mii_clkfreq = 0;
+	struct ethoc_platform_data *pdata = dev_get_platdata(&pdev->dev);
 
 	/* allocate networking device */
 	netdev = alloc_etherdev(sizeof(struct ethoc));
@@ -1032,8 +1035,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	}
 
 	/* Allow the platform setup code to pass in a MAC address. */
-	if (dev_get_platdata(&pdev->dev)) {
-		struct ethoc_platform_data *pdata = dev_get_platdata(&pdev->dev);
+	if (pdata) {
 		memcpy(netdev->dev_addr, pdata->hwaddr, IFHWADDRLEN);
 		priv->phy_id = pdata->phy_id;
 	} else {
@@ -1071,6 +1073,27 @@ static int ethoc_probe(struct platform_device *pdev)
 	if (random_mac)
 		netdev->addr_assign_type = NET_ADDR_RANDOM;
 
+	/* Allow the platform setup code to adjust MII management bus clock. */
+	if (pdata) {
+		eth_clkfreq = pdata->eth_clkfreq;
+		mii_clkfreq = pdata->mii_mgmt_clkfreq;
+	} else {
+		of_property_read_u32(pdev->dev.of_node,
+				     "clock-frequency", &eth_clkfreq);
+		of_property_read_u32(pdev->dev.of_node,
+				     "mii-mgmt-clock-frequency", &mii_clkfreq);
+	}
+	if (eth_clkfreq && mii_clkfreq) {
+		u32 clkdiv = MIIMODER_CLKDIV(eth_clkfreq / mii_clkfreq + 1);
+
+		if (!clkdiv)
+			clkdiv = 2;
+		dev_dbg(&pdev->dev, "setting MII clkdiv to %u\n", clkdiv);
+		ethoc_write(priv, MIIMODER,
+			    (ethoc_read(priv, MIIMODER) & MIIMODER_NOPRE) |
+			    clkdiv);
+	}
+
 	/* register MII bus */
 	priv->mdio = mdiobus_alloc();
 	if (!priv->mdio) {
diff --git a/include/net/ethoc.h b/include/net/ethoc.h
index 96f3789..b292474 100644
--- a/include/net/ethoc.h
+++ b/include/net/ethoc.h
@@ -16,6 +16,8 @@
 struct ethoc_platform_data {
 	u8 hwaddr[IFHWADDRLEN];
 	s8 phy_id;
+	u32 eth_clkfreq;
+	u32 mii_mgmt_clkfreq;
 };
 
 #endif /* !LINUX_NET_ETHOC_H */
-- 
1.8.1.4
