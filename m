From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 02/10] net/mlx4_core: Avoid setting ports to auto when only one port type is supported
Date: Thu, 27 Oct 2016 16:27:14 +0300
Message-ID: <1477574842-29688-3-git-send-email-tariqt@mellanox.com>
References: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Maor Gottlieb <maorg@mellanox.com>,
        Moshe Shemesh <moshe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57524 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941447AbcJ0NyR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:54:17 -0400
In-Reply-To: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

When only one port type is supported, it should be read only.
We reject changing requests, even to the auto sense mode.

Fixes: 27bf91d6a0d5 ("mlx4_core: Add link type autosensing")
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 7183ac4135d2..6f4e67bc3538 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1102,6 +1102,14 @@ static int __set_port_type(struct mlx4_port_info *info,
 	int i;
 	int err = 0;
 
+	if ((port_type & mdev->caps.supported_type[info->port]) != port_type) {
+		mlx4_err(mdev,
+			 "Requested port type for port %d is not supported on this HCA\n",
+			 info->port);
+		err = -EINVAL;
+		goto err_sup;
+	}
+
 	mlx4_stop_sense(mdev);
 	mutex_lock(&priv->port_mutex);
 	info->tmp_type = port_type;
@@ -1147,7 +1155,7 @@ static int __set_port_type(struct mlx4_port_info *info,
 out:
 	mlx4_start_sense(mdev);
 	mutex_unlock(&priv->port_mutex);
-
+err_sup:
 	return err;
 }
 
-- 
1.8.3.1
