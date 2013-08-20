From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V1 1/4] net/mlx4_en: Disable global flow
 control when PFC enabled
Date: Tue, 20 Aug 2013 09:58:00 -0700
Message-ID: <1377017880.2016.49.camel@joe-AO722>
References: <1377013369-14711-1-git-send-email-amirv@mellanox.com>
	 <1377013369-14711-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37682 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751255Ab3HTQ6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 12:58:01 -0400
In-Reply-To: <1377013369-14711-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-20 at 18:42 +0300, Amir Vadai wrote:
> Fix a bug when FC and PFC are enabled/disabled at the same time.
> According to ConnectX-3 Programmer Manual these two features are mutial
> exclusive.  So make sure when enabling PFC to turn off global FC and
> vise versa.  Otherwise it hurts the performance.
[]
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
> index 9d4a1ea..fcef764 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
> @@ -169,7 +169,8 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
>  			pfc->mbc,
>  			pfc->delay);
>  
> -	priv->prof->rx_pause = priv->prof->tx_pause = !!pfc->pfc_en;
> +	priv->prof->rx_pause = !pfc->pfc_en;
> +	priv->prof->tx_pause = !pfc->pfc_en;
>  	priv->prof->rx_ppp = priv->prof->tx_ppp = pfc->pfc_en;

Just do the minimal change.

Otherwise, because you're using separate sets for the
pause vars I think you should change the line below as
well so a single style is used.

Maybe I'd just go ahead and use a temporary for prof too.
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 9d4a1ea..45894c6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -161,6 +161,7 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_port_profile *prof = priv->prof;
 	int err;
 
 	en_dbg(DRV, priv, "cap: 0x%x en: 0x%x mbc: 0x%x delay: %d\n",
@@ -169,15 +170,17 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
 			pfc->mbc,
 			pfc->delay);
 
-	priv->prof->rx_pause = priv->prof->tx_pause = !!pfc->pfc_en;
-	priv->prof->rx_ppp = priv->prof->tx_ppp = pfc->pfc_en;
+	prof->rx_pause = !pfc->pfc_en;
+	prof->tx_pause = !pfc->pfc_en;
+	prof->rx_ppp = pfc->pfc_en;
+	prof->tx_ppp = pfc->pfc_en;
 
 	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
 				    priv->rx_skb_size + ETH_FCS_LEN,
-				    priv->prof->tx_pause,
-				    priv->prof->tx_ppp,
-				    priv->prof->rx_pause,
-				    priv->prof->rx_ppp);
+				    prof->tx_pause,
+				    prof->tx_ppp,
+				    prof->rx_pause,
+				    prof->rx_ppp);
 	if (err)
 		en_err(priv, "Failed setting pause params\n");
 
