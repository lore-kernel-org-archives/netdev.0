From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/4] net/mlx4_en: Handle unassigned VF MAC address correctly
Date: Tue,  4 Jun 2013 18:13:28 +0300
Message-ID: <1370358809-7484-4-git-send-email-ogerlitz@mellanox.com>
References: <1370358809-7484-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59257 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755786Ab3FDPTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 11:19:09 -0400
In-Reply-To: <1370358809-7484-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a VF sense they didn't get MAC address, use random one. This will
address the case of administrator not assigning MAC to the VF through
the PF OS APIs and keep udev happy.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 810aab0..89c47ea 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2119,6 +2119,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	struct mlx4_en_priv *priv;
 	int i;
 	int err;
+	u64 mac_u64;
 
 	dev = alloc_etherdev_mqs(sizeof(struct mlx4_en_priv),
 				 MAX_TX_RINGS, MAX_RX_RINGS);
@@ -2192,10 +2193,17 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	dev->addr_len = ETH_ALEN;
 	mlx4_en_u64_to_mac(dev->dev_addr, mdev->dev->caps.def_mac[priv->port]);
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		en_err(priv, "Port: %d, invalid mac burned: %pM, quiting\n",
-		       priv->port, dev->dev_addr);
-		err = -EINVAL;
-		goto out;
+		if (mlx4_is_slave(priv->mdev->dev)) {
+			eth_hw_addr_random(dev);
+			en_warn(priv, "Assigned random MAC address %pM\n", dev->dev_addr);
+			mac_u64 = mlx4_en_mac_to_u64(dev->dev_addr);
+			mdev->dev->caps.def_mac[priv->port] = mac_u64;
+		} else {
+			en_err(priv, "Port: %d, invalid mac burned: %pM, quiting\n",
+			       priv->port, dev->dev_addr);
+			err = -EINVAL;
+			goto out;
+		}
 	}
 
 	memcpy(priv->prev_mac, dev->dev_addr, sizeof(priv->prev_mac));
-- 
1.7.1
