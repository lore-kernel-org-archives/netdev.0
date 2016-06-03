From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V4 2/4] net-next: mediatek: fix gigabit and flow control
 advertisement
Date: Fri,  3 Jun 2016 10:17:07 +0200
Message-ID: <1464941829-38712-3-git-send-email-john@phrozen.org>
References: <1464941829-38712-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, Sean Wang <keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1464941829-38712-1-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

The current code will not setup the PHYs advertisement features correctly.
Fix this and properly advertise Gigabit features and properly handle
asymmetric pause frames.

Signed-off-by: Sean Wang <keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
---
Changes in V4
* set SUPPORTED_Asym_Pause rather than clearing it
* add debug code
* only setup asym if we are in full duplex

 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   30 +++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 28f169f..b0652f6 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -133,6 +133,8 @@ static int mtk_mdio_read(struct mii_bus *bus, int phy_addr, int phy_reg)
 static void mtk_phy_link_adjust(struct net_device *dev)
 {
 	struct mtk_mac *mac = netdev_priv(dev);
+	u16 lcl_adv = 0, rmt_adv = 0;
+	u8 flowctrl;
 	u32 mcr = MAC_MCR_MAX_RX_1536 | MAC_MCR_IPG_CFG |
 		  MAC_MCR_FORCE_MODE | MAC_MCR_TX_EN |
 		  MAC_MCR_RX_EN | MAC_MCR_BACKOFF_EN |
@@ -150,11 +152,30 @@ static void mtk_phy_link_adjust(struct net_device *dev)
 	if (mac->phy_dev->link)
 		mcr |= MAC_MCR_FORCE_LINK;
 
-	if (mac->phy_dev->duplex)
+	if (mac->phy_dev->duplex) {
 		mcr |= MAC_MCR_FORCE_DPX;
 
-	if (mac->phy_dev->pause)
-		mcr |= MAC_MCR_FORCE_RX_FC | MAC_MCR_FORCE_TX_FC;
+		if (mac->phy_dev->pause)
+			rmt_adv = LPA_PAUSE_CAP;
+		if (mac->phy_dev->asym_pause)
+			rmt_adv |= LPA_PAUSE_ASYM;
+
+		if (mac->phy_dev->advertising & ADVERTISED_Pause)
+			lcl_adv |= ADVERTISE_PAUSE_CAP;
+		if (mac->phy_dev->advertising & ADVERTISED_Asym_Pause)
+			lcl_adv |= ADVERTISE_PAUSE_ASYM;
+
+		flowctrl = mii_resolve_flowctrl_fdx(lcl_adv, rmt_adv);
+
+		if (flowctrl & FLOW_CTRL_TX)
+			mcr |= MAC_MCR_FORCE_TX_FC;
+		if (flowctrl & FLOW_CTRL_RX)
+			mcr |= MAC_MCR_FORCE_RX_FC;
+
+		netif_dbg(mac->hw, link, dev, "rx pause %s, tx pause %s\n",
+			  flowctrl & FLOW_CTRL_RX ? "enabled" : "disabled",
+			  flowctrl & FLOW_CTRL_TX ? "enabled" : "disabled");
+	}
 
 	mtk_w32(mac->hw, mcr, MTK_MAC_MCR(mac->id));
 
@@ -236,7 +257,8 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 	mac->phy_dev->autoneg = AUTONEG_ENABLE;
 	mac->phy_dev->speed = 0;
 	mac->phy_dev->duplex = 0;
-	mac->phy_dev->supported &= PHY_BASIC_FEATURES;
+	mac->phy_dev->supported &= PHY_GBIT_FEATURES | SUPPORTED_Pause |
+				   SUPPORTED_Asym_Pause;
 	mac->phy_dev->advertising = mac->phy_dev->supported |
 				    ADVERTISED_Autoneg;
 	phy_start_aneg(mac->phy_dev);
-- 
1.7.10.4
