From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] sky2: fix rx filter setup on link up
Date: Mon, 17 Sep 2012 17:10:17 +0200
Message-ID: <1347894617-13614-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, mlindner@marvell.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In my case I have following problem. sky2_set_multicast() sets registers
GM_MC_ADDR_H[1-4] correctly to:
0000 0800 0001 0410
However, when adapter gets link and sky2_link_up() is called, the values
are for some reason different:
0000 0800 0016 0410
This in my case prevents iface to be able to receive packets with dst mac
01:80:C2:00:00:02 (LACPDU dst mac), which I set up previously by
SIOCADDMULTI.

So remember computed rx_filter data and write it to GM_MC_ADDR_H[1-4] on
link_up.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/marvell/sky2.c | 30 ++++++++++++++++++++++--------
 drivers/net/ethernet/marvell/sky2.h |  2 ++
 2 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 2b0748d..5293ff4 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2186,6 +2186,8 @@ static u16 sky2_phy_speed(const struct sky2_hw *hw, u16 aux)
 	}
 }
 
+static void sky2_write_rx_filter(struct sky2_port *sky2, u8 *filter);
+
 static void sky2_link_up(struct sky2_port *sky2)
 {
 	struct sky2_hw *hw = sky2->hw;
@@ -2211,6 +2213,9 @@ static void sky2_link_up(struct sky2_port *sky2)
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
 
+	/* Refresh RX filter */
+	sky2_write_rx_filter(sky2, sky2->rx_filter);
+
 	netif_info(sky2, link, sky2->netdev,
 		   "Link is up at %d Mbps, %s duplex, flow control %s\n",
 		   sky2->speed,
@@ -3849,6 +3854,21 @@ static inline void sky2_add_filter(u8 filter[8], const u8 *addr)
 	filter[bit >> 3] |= 1 << (bit & 7);
 }
 
+static void sky2_write_rx_filter(struct sky2_port *sky2, u8 *filter)
+{
+	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
+
+	gma_write16(hw, port, GM_MC_ADDR_H1,
+		    (u16) filter[0] | ((u16) filter[1] << 8));
+	gma_write16(hw, port, GM_MC_ADDR_H2,
+		    (u16) filter[2] | ((u16) filter[3] << 8));
+	gma_write16(hw, port, GM_MC_ADDR_H3,
+		    (u16) filter[4] | ((u16) filter[5] << 8));
+	gma_write16(hw, port, GM_MC_ADDR_H4,
+		    (u16) filter[6] | ((u16) filter[7] << 8));
+}
+
 static void sky2_set_multicast(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
@@ -3882,14 +3902,8 @@ static void sky2_set_multicast(struct net_device *dev)
 			sky2_add_filter(filter, ha->addr);
 	}
 
-	gma_write16(hw, port, GM_MC_ADDR_H1,
-		    (u16) filter[0] | ((u16) filter[1] << 8));
-	gma_write16(hw, port, GM_MC_ADDR_H2,
-		    (u16) filter[2] | ((u16) filter[3] << 8));
-	gma_write16(hw, port, GM_MC_ADDR_H3,
-		    (u16) filter[4] | ((u16) filter[5] << 8));
-	gma_write16(hw, port, GM_MC_ADDR_H4,
-		    (u16) filter[6] | ((u16) filter[7] << 8));
+	sky2_write_rx_filter(sky2, filter);
+	memcpy(sky2->rx_filter, filter, sizeof(sky2->rx_filter));
 
 	gma_write16(hw, port, GM_RX_CTRL, reg);
 }
diff --git a/drivers/net/ethernet/marvell/sky2.h b/drivers/net/ethernet/marvell/sky2.h
index 615ac63..513c266 100644
--- a/drivers/net/ethernet/marvell/sky2.h
+++ b/drivers/net/ethernet/marvell/sky2.h
@@ -2272,6 +2272,8 @@ struct sky2_port {
 #ifdef CONFIG_SKY2_DEBUG
 	struct dentry	     *debugfs;
 #endif
+
+	u8		     rx_filter[8];
 };
 
 struct sky2_hw {
-- 
1.7.11.4
