From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] stmmac: Don't exit mdio registration when mdio subnode is
 not found in the DTS
Date: Fri, 01 Jan 2016 21:51:17 -0800
Message-ID: <0E6F98A1-B9F1-48B0-B5CA-A215803E827F@gmail.com>
References: <1451397935-23643-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Romain Perier <romain.perier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,peppe.cavallaro-qxv4g6HH51o@public.gmane.org
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1451397935-23643-1-git-send-email-romain.perier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On December 29, 2015 6:05:35 AM PST, Romain Perier <romain.perier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>Originally, most of the platforms using this driver did not define an
>mdio subnode
>in the devicetree. Commit e34d65 ("stmmac: create of compatible mdio
>bus for stmmac driver")
>introduced a backward compatibily issue by using of_mdiobus_register
>explicitly
>with an mdio subnode. This patch fixes the issue by calling the
>function
>mdiobus_register, when mdio subnode is not found. The driver is now
>compatible
>with both modes.

Looks reasonable to me, though you will want to make sure the different DTSes get updated to include the proper compatible node for the MDIO bus.

>
>Signed-off-by: Romain Perier <romain.perier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Please include a Fixes tag to help keep track of changes.

>---
> drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 8 +++++---
> 1 file changed, 5 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>index 16c85cc..0034de44 100644
>--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>@@ -218,8 +218,7 @@ int stmmac_mdio_register(struct net_device *ndev)
> 		if (mdio_node) {
> 			netdev_dbg(ndev, "FOUND MDIO subnode\n");
> 		} else {
>-			netdev_err(ndev, "NO MDIO subnode\n");
>-			return 0;
>+			netdev_warn(ndev, "No MDIO subnode found\n");
> 		}
> 	}
> 
>@@ -251,7 +250,10 @@ int stmmac_mdio_register(struct net_device *ndev)
> 	new_bus->phy_mask = mdio_bus_data->phy_mask;
> 	new_bus->parent = priv->device;
> 
>-	err = of_mdiobus_register(new_bus, mdio_node);
>+	if (IS_ENABLED(CONFIG_OF) && mdio_node)

You should be able to drop the IS_ENABLED part since there is an inline provided in the non-OF case which does a fallback to mdiobus_register().

>+		err = of_mdiobus_register(new_bus, mdio_node);
>+	else
>+		err = mdiobus_register(new_bus);
> 	if (err != 0) {

This looks reasonable, does it work if we just assign mdio_node to the pdev->dev.of_node to be backwards compatible with DTSes which have not yet been updated?

> 		pr_err("%s: Cannot register as MDIO bus\n", new_bus->name);
> 		goto bus_register_fail;


-- 
Florian
