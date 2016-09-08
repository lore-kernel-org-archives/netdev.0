From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 3/9] net/mlx4_en: Fix the return value of mlx4_en_dcbnl_set_all()
Date: Thu,  8 Sep 2016 11:51:55 +0300
Message-ID: <1473324721-5206-4-git-send-email-tariqt@mellanox.com>
References: <1473324721-5206-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Kamal Heib <kamalh@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55636 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S938685AbcIHIxO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 04:53:14 -0400
In-Reply-To: <1473324721-5206-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

mlx4_en_dcbnl_set_all() returns u8, so return value can't be negative in
case of failure.

Fixes: af7d51852631 ("net/mlx4_en: Add DCB PFC support through CEE netlink commands")
Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Signed-off-by: Rana Shahout <ranas@mellanox.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 99c6bbdff501..97081e5bafd1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -158,10 +158,9 @@ static u8 mlx4_en_dcbnl_set_all(struct net_device *netdev)
 	struct mlx4_en_priv *priv = netdev_priv(netdev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_cee_config *dcb_cfg = &priv->cee_params.dcb_cfg;
-	int err = 0;
 
 	if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
-		return -EINVAL;
+		return 1;
 
 	if (dcb_cfg->pfc_state) {
 		int tc;
@@ -199,15 +198,17 @@ static u8 mlx4_en_dcbnl_set_all(struct net_device *netdev)
 		en_dbg(DRV, priv, "Set pfc off\n");
 	}
 
-	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
-				    priv->rx_skb_size + ETH_FCS_LEN,
-				    priv->prof->tx_pause,
-				    priv->prof->tx_ppp,
-				    priv->prof->rx_pause,
-				    priv->prof->rx_ppp);
-	if (err)
+	if (mlx4_SET_PORT_general(mdev->dev, priv->port,
+				  priv->rx_skb_size + ETH_FCS_LEN,
+				  priv->prof->tx_pause,
+				  priv->prof->tx_ppp,
+				  priv->prof->rx_pause,
+				  priv->prof->rx_ppp)) {
 		en_err(priv, "Failed setting pause params\n");
-	return err;
+		return 1;
+	}
+
+	return 0;
 }
 
 static u8 mlx4_en_dcbnl_get_state(struct net_device *dev)
-- 
1.8.3.1
