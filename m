From: <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 1/3] net: ethernet: mediatek: add extension of
 phy-mode for TRGMII
Date: Tue, 20 Sep 2016 15:59:18 +0800
Message-ID: <1474358360-29901-2-git-send-email-sean.wang@mediatek.com>
References: <1474358360-29901-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1474358360-29901-1-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
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

From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>

adds PHY-mode "trgmii" as an extension for the operation
mode of the PHY interface, TRGMII can be compatible with
RGMII, so the extended mode doesn't really have effects on
the target MAC and PHY, is used as the indication if the
current MAC is connected to an internal switch or external
PHY respectively by the given configuration on the board and
then to perform the corresponding setup on TRGMII hardware
module.

Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 24 ++++++++++++++++++++++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  3 +++
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index ca6b501..a0e338b 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -135,6 +135,26 @@ static int mtk_mdio_read(struct mii_bus *bus, int phy_addr, int phy_reg)
 	return _mtk_mdio_read(eth, phy_addr, phy_reg);
 }
 
+static int mtk_of_get_phy_mode(struct mtk_mac *mac, struct device_node *np)
+{
+	int phy_mode, err;
+	const char *pm;
+
+	phy_mode = of_get_phy_mode(np);
+
+	if (phy_mode >= 0)
+		return phy_mode;
+	err = of_property_read_string(np, "phy-mode", &pm);
+	if (err < 0)
+		return err;
+	if (!strcasecmp(pm, "trgmii")) {
+		mac->trgmii = true;
+		/* TRGMII could be compatible with RGMII */
+		return PHY_INTERFACE_MODE_RGMII;
+	} else
+		return -ENODEV;
+}
+
 static void mtk_phy_link_adjust(struct net_device *dev)
 {
 	struct mtk_mac *mac = netdev_priv(dev);
@@ -207,7 +227,7 @@ static int mtk_phy_connect_node(struct mtk_eth *eth, struct mtk_mac *mac,
 		return -EINVAL;
 	}
 	addr = be32_to_cpu(*_addr);
-	phy_mode = of_get_phy_mode(phy_node);
+	phy_mode = mtk_of_get_phy_mode(mac, phy_node);
 	if (phy_mode < 0) {
 		dev_err(eth->dev, "incorrect phy-mode %d\n", phy_mode);
 		return -EINVAL;
@@ -243,7 +263,7 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 	if (!np)
 		return -ENODEV;
 
-	switch (of_get_phy_mode(np)) {
+	switch (mtk_of_get_phy_mode(mac, np)) {
 	case PHY_INTERFACE_MODE_RGMII_TXID:
 	case PHY_INTERFACE_MODE_RGMII_RXID:
 	case PHY_INTERFACE_MODE_RGMII_ID:
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 7c5e534..e3b9525 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -529,6 +529,8 @@ struct mtk_eth {
  * @hw:			Backpointer to our main datastruture
  * @hw_stats:		Packet statistics counter
  * @phy_dev:		The attached PHY if available
+ * @trgmii		Indicate if the MAC uses TRGMII connected to internal
+			switch
  */
 struct mtk_mac {
 	int				id;
@@ -539,6 +541,7 @@ struct mtk_mac {
 	struct phy_device		*phy_dev;
 	__be32				hwlro_ip[MTK_MAX_LRO_IP_CNT];
 	int				hwlro_ip_cnt;
+	bool				trgmii;
 };
 
 /* the struct describing the SoC. these are declared in the soc_xyz.c files */
-- 
1.9.1
