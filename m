From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH 1/3] net-next: mediatek: fix gigabit and flow control
 advertisement
Date: Thu,  5 May 2016 11:17:34 +0200
Message-ID: <1462439856-51788-2-git-send-email-john@phrozen.org>
References: <1462439856-51788-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-Vt+b4OUoWG0@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1462439856-51788-1-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
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

Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index c984462..093073c 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -133,6 +133,8 @@ static int mtk_mdio_read(struct mii_bus *bus, int phy_addr, int phy_reg)
 static void mtk_phy_link_adjust(struct net_device *dev)
 {
 	struct mtk_mac *mac = netdev_priv(dev);
+	u16 lcl_adv, rmt_adv = 0;
+	u8 flowctrl;
 	u32 mcr = MAC_MCR_MAX_RX_1536 | MAC_MCR_IPG_CFG |
 		  MAC_MCR_FORCE_MODE | MAC_MCR_TX_EN |
 		  MAC_MCR_RX_EN | MAC_MCR_BACKOFF_EN |
@@ -154,7 +156,16 @@ static void mtk_phy_link_adjust(struct net_device *dev)
 		mcr |= MAC_MCR_FORCE_DPX;
 
 	if (mac->phy_dev->pause)
-		mcr |= MAC_MCR_FORCE_RX_FC | MAC_MCR_FORCE_TX_FC;
+		rmt_adv = LPA_PAUSE_CAP;
+	if (mac->phy_dev->asym_pause)
+		rmt_adv |= LPA_PAUSE_ASYM;
+
+	lcl_adv = mii_advertise_flowctrl(FLOW_CTRL_RX | FLOW_CTRL_TX);
+	flowctrl = mii_resolve_flowctrl_fdx(lcl_adv, rmt_adv);
+	if (flowctrl & FLOW_CTRL_TX)
+		mcr |= MAC_MCR_FORCE_TX_FC;
+	if (flowctrl & FLOW_CTRL_RX)
+		mcr |= MAC_MCR_FORCE_RX_FC;
 
 	mtk_w32(mac->hw, mcr, MTK_MAC_MCR(mac->id));
 
@@ -236,7 +247,8 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 	mac->phy_dev->autoneg = AUTONEG_ENABLE;
 	mac->phy_dev->speed = 0;
 	mac->phy_dev->duplex = 0;
-	mac->phy_dev->supported &= PHY_BASIC_FEATURES;
+	mac->phy_dev->supported &= PHY_GBIT_FEATURES | SUPPORTED_Pause |
+				   ~SUPPORTED_Asym_Pause;
 	mac->phy_dev->advertising = mac->phy_dev->supported |
 				    ADVERTISED_Autoneg;
 	phy_start_aneg(mac->phy_dev);
-- 
1.7.10.4
