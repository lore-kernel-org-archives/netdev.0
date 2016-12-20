From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next 02/10] net: netcp: ethss: add support of 10gbe pcsr link status
Date: Tue, 20 Dec 2016 17:09:45 -0500
Message-ID: <1482271793-7671-3-git-send-email-m-karicheri2@ti.com>
References: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <grygorii.strashko@ti.com>, <mugunthanvnm@ti.com>,
        <linux-kernel@vger.kernel.org>, <arnd@arndb.de>,
        <davem@davemloft.net>, <devicetree@vger.kernel.org>,
        <mark.rutland@arm.com>, <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: WingMan Kwok <w-kwok2@ti.com>

The 10GBASE-R Physical Coding Sublayer (PCS-R) module provides
functionality of a physical coding sublayer (PCS) on data being
transferred between a demuxed XGMII and SerDes supporting a 16
or 32 bit interface.  From the driver point of view, whether
a ethernet link is up or not depends also on the status of the
block-lock bit of the PCSR.  This patch adds the checking of that
bit in order to determine the link status.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 .../devicetree/bindings/net/keystone-netcp.txt     |  3 ++
 drivers/net/ethernet/ti/netcp_ethss.c              | 37 ++++++++++++++++++++--
 2 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
index 0854a73..57fc13f 100644
--- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
+++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
@@ -75,6 +75,9 @@ Required properties:
 - syscon-subsys:	phandle to syscon node of the switch
 			subsystem registers.
 
+- syscon-pcsr:		(10gbe only) phandle to syscon node of the
+			switch PCSR registers.
+
 - reg:		register location and the size for the following register
 		regions in the specified order.
 		- switch subsystem registers
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 473edda1..cb48f88 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -63,6 +63,12 @@
 #define GBE13_ALE_OFFSET		0x600
 #define GBE13_HOST_PORT_NUM		0
 #define GBE13_NUM_ALE_ENTRIES		1024
+/* offset relative to PCSR regmap */
+#define XGBE10_PCSR_OFFSET(x)		((x) * 0x80)
+#define XGBE10_PCSR_RX_STATUS(x)	(XGBE10_PCSR_OFFSET(x) + 0x0C)
+
+#define XGBE10_PCSR_BLOCK_LOCK_MASK	BIT(30)
+#define XGBE10_PCSR_BLOCK_LOCK_SHIFT	30
 
 /* 1G Ethernet NU SS defines */
 #define GBENU_MODULE_NAME		"netcp-gbenu"
@@ -2111,6 +2117,10 @@ static void netcp_ethss_link_state_action(struct gbe_priv *gbe_dev,
 
 	if (phy)
 		phy_print_status(phy);
+	else if (slave->link_interface == XGMII_LINK_MAC_MAC_FORCED) {
+		netdev_printk(KERN_INFO, ndev,
+			      "Link is %s\n", (up ? "Up" : "Down"));
+	}
 }
 
 static bool gbe_phy_link_status(struct gbe_slave *slave)
@@ -2123,18 +2133,29 @@ static void netcp_ethss_update_link_state(struct gbe_priv *gbe_dev,
 					  struct net_device *ndev)
 {
 	int sp = slave->slave_num;
-	int phy_link_state, sgmii_link_state = 1, link_state;
+	int phy_link_state, sw_link_state = 1, link_state, ret;
+	u32 pcsr_rx_stat;
 
 	if (!slave->open)
 		return;
 
 	if (!SLAVE_LINK_IS_XGMII(slave)) {
-		sgmii_link_state =
+		sw_link_state =
 			netcp_sgmii_get_port_link(SGMII_BASE(gbe_dev, sp), sp);
+	} else if (slave->link_interface == XGMII_LINK_MAC_MAC_FORCED) {
+		/* read status from pcsr status reg */
+		ret = regmap_read(gbe_dev->pcsr_regmap,
+				  XGBE10_PCSR_RX_STATUS(sp), &pcsr_rx_stat);
+
+		if (ret)
+			return;
+
+		sw_link_state = (pcsr_rx_stat & XGBE10_PCSR_BLOCK_LOCK_MASK) >>
+				 XGBE10_PCSR_BLOCK_LOCK_SHIFT;
 	}
 
 	phy_link_state = gbe_phy_link_status(slave);
-	link_state = phy_link_state & sgmii_link_state;
+	link_state = phy_link_state & sw_link_state;
 
 	if (atomic_xchg(&slave->link_state, link_state) != link_state)
 		netcp_ethss_link_state_action(gbe_dev, ndev, slave,
@@ -3154,6 +3175,16 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 		return PTR_ERR(gbe_dev->ss_regmap);
 	}
 
+	gbe_dev->pcsr_regmap = syscon_regmap_lookup_by_phandle(node,
+							       "syscon-pcsr");
+
+	if (IS_ERR(gbe_dev->pcsr_regmap)) {
+		dev_err(gbe_dev->dev,
+			"pcsr regmap lookup failed: %ld\n",
+			PTR_ERR(gbe_dev->pcsr_regmap));
+		return PTR_ERR(gbe_dev->pcsr_regmap);
+	}
+
 	ret = of_address_to_resource(node, XGBE_SM_REG_INDEX, &res);
 	if (ret) {
 		dev_err(gbe_dev->dev,
-- 
1.9.1
