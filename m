From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 12/16] net: ethernet: mediatek: fix fixed-link phydev leaks
Date: Mon, 28 Nov 2016 19:25:05 +0100
Message-ID: <1480357509-28074-13-git-send-email-johan@kernel.org>
References: <1480357509-28074-1-git-send-email-johan@kernel.org>
Cc: Vince Bridgers <vbridger@opensource.altera.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>,
        Claudiu Manoil <claudiu.manoil@freescale.com>,
        Li Yang <leoli@freescale.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Felix Fietkau <nbd@openwrt.org>,
        John Crispin <blogic@openwrt.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Lars Persson <lars.persson@axis.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1480357509-28074-1-git-send-email-johan@kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to deregister and free any fixed-link PHY registered using
of_phy_register_fixed_link() on initialisation errors and on uninit.

Fixes: 0c72c50f6f93 ("net-next: mediatek: add fixed-phy support")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 4a62ffd7729d..86a89cbd3ec9 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -318,6 +318,8 @@ static int mtk_phy_connect(struct net_device *dev)
 	return 0;
 
 err_phy:
+	if (of_phy_is_fixed_link(mac->of_node))
+		of_phy_deregister_fixed_link(mac->of_node);
 	of_node_put(np);
 	dev_err(eth->dev, "%s: invalid phy\n", __func__);
 	return -EINVAL;
@@ -1923,6 +1925,8 @@ static void mtk_uninit(struct net_device *dev)
 	struct mtk_eth *eth = mac->hw;
 
 	phy_disconnect(dev->phydev);
+	if (of_phy_is_fixed_link(mac->of_node))
+		of_phy_deregister_fixed_link(mac->of_node);
 	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, ~0);
 	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, ~0);
 }
-- 
2.7.3
