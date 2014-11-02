From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 2/5] net/mlx4_core: Protect port type setting by mutex
Date: Sun,  2 Nov 2014 16:26:14 +0200
Message-ID: <1414938377-421-3-git-send-email-ogerlitz@mellanox.com>
References: <1414938377-421-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52330 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751103AbaKBO0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2014 09:26:23 -0500
In-Reply-To: <1414938377-421-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>

We need to protect set_port_type() for concurrency, as the sysfs code could
call it from mutliple contexts in parallel.

The port_mutex is not enough because we need to protect from concurrent
modification of 'info' and stopping of the port sensing work.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 90de6e1..9f82196 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -901,9 +901,12 @@ static ssize_t set_port_type(struct device *dev,
 	struct mlx4_priv *priv = mlx4_priv(mdev);
 	enum mlx4_port_type types[MLX4_MAX_PORTS];
 	enum mlx4_port_type new_types[MLX4_MAX_PORTS];
+	static DEFINE_MUTEX(set_port_type_mutex);
 	int i;
 	int err = 0;
 
+	mutex_lock(&set_port_type_mutex);
+
 	if (!strcmp(buf, "ib\n"))
 		info->tmp_type = MLX4_PORT_TYPE_IB;
 	else if (!strcmp(buf, "eth\n"))
@@ -912,7 +915,8 @@ static ssize_t set_port_type(struct device *dev,
 		info->tmp_type = MLX4_PORT_TYPE_AUTO;
 	else {
 		mlx4_err(mdev, "%s is not supported port type\n", buf);
-		return -EINVAL;
+		err = -EINVAL;
+		goto err_out;
 	}
 
 	mlx4_stop_sense(mdev);
@@ -958,6 +962,9 @@ static ssize_t set_port_type(struct device *dev,
 out:
 	mlx4_start_sense(mdev);
 	mutex_unlock(&priv->port_mutex);
+err_out:
+	mutex_unlock(&set_port_type_mutex);
+
 	return err ? err : count;
 }
 
-- 
1.7.1
