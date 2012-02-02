From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/3 v2] drivers/net/ethernet/ti: Move call to PTR_ERR after reassignment
Date: Thu,  2 Feb 2012 15:53:01 +0100
Message-ID: <1328194382-32465-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1328194382-32465-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328194382-32465-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

PTR_ERR should be called before its argument is cleared.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression e,e1;
constant c;
@@

*e = c
... when != e = e1
    when != &e
    when != true IS_ERR(e)
*PTR_ERR(e)
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
Reported-by: Josh Triplett <josh@joshtriplett.org>

---
v2: correct commit message.

 drivers/net/ethernet/ti/davinci_emac.c |    3 ++-
 drivers/net/ethernet/ti/davinci_mdio.c |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index efd4f3e..922a937 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1600,8 +1600,9 @@ static int emac_dev_open(struct net_device *ndev)
 		if (IS_ERR(priv->phydev)) {
 			dev_err(emac_dev, "could not connect to phy %s\n",
 				priv->phy_id);
+			ret = PTR_ERR(priv->phydev);
 			priv->phydev = NULL;
-			return PTR_ERR(priv->phydev);
+			return ret;
 		}
 
 		priv->link = 0;
diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index ef7c9c1..af8b8fc 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -318,9 +318,9 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 
 	data->clk = clk_get(dev, NULL);
 	if (IS_ERR(data->clk)) {
-		data->clk = NULL;
 		dev_err(dev, "failed to get device clock\n");
 		ret = PTR_ERR(data->clk);
+		data->clk = NULL;
 		goto bail_out;
 	}
 
