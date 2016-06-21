From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_en: Fix the return value of a failure in VLAN VID add/kill
Date: Tue, 21 Jun 2016 14:20:02 +0300
Message-ID: <1466508003-13835-2-git-send-email-tariqt@mellanox.com>
References: <1466508003-13835-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Kamal Heib <kamalh@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56925 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750744AbcFULWq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 07:22:46 -0400
In-Reply-To: <1466508003-13835-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

Modify mlx4_en_vlan_rx_[add/kill]_vid to return error value in case of
failure.

Fixes: 8e586137e6b6 ('net: make vlan ndo_vlan_rx_[add/kill]_vid return error value')
Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index a2c2536..43f505e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -406,14 +406,18 @@ static int mlx4_en_vlan_rx_add_vid(struct net_device *dev,
 	mutex_lock(&mdev->state_lock);
 	if (mdev->device_up && priv->port_up) {
 		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
-		if (err)
+		if (err) {
 			en_err(priv, "Failed configuring VLAN filter\n");
+			goto out;
+		}
 	}
-	if (mlx4_register_vlan(mdev->dev, priv->port, vid, &idx))
-		en_dbg(HW, priv, "failed adding vlan %d\n", vid);
-	mutex_unlock(&mdev->state_lock);
+	err = mlx4_register_vlan(mdev->dev, priv->port, vid, &idx);
+	if (err)
+		en_dbg(HW, priv, "Failed adding vlan %d\n", vid);
 
-	return 0;
+out:
+	mutex_unlock(&mdev->state_lock);
+	return err;
 }
 
 static int mlx4_en_vlan_rx_kill_vid(struct net_device *dev,
@@ -421,7 +425,7 @@ static int mlx4_en_vlan_rx_kill_vid(struct net_device *dev,
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
-	int err;
+	int err = 0;
 
 	en_dbg(HW, priv, "Killing VID:%d\n", vid);
 
@@ -438,7 +442,7 @@ static int mlx4_en_vlan_rx_kill_vid(struct net_device *dev,
 	}
 	mutex_unlock(&mdev->state_lock);
 
-	return 0;
+	return err;
 }
 
 static void mlx4_en_u64_to_mac(unsigned char dst_mac[ETH_ALEN + 2], u64 src_mac)
-- 
1.8.3.1
