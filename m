From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 4/4] net/mlx4_core: Load higher level modules according to ports type
Date: Tue, 15 Oct 2013 16:55:24 +0200
Message-ID: <1381848924-18992-5-git-send-email-amirv@mellanox.com>
References: <1381848924-18992-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52150 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933173Ab3JOO4C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 10:56:02 -0400
In-Reply-To: <1381848924-18992-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

Mellanox ConnectX architecture is:  mlx4_core is the lower level
PCI driver which register on the PCI id, and protocol specific drivers
are depended on it: mlx4_en - for Ethernet and mlx4_ib for Infiniband.
NIC could have multiple ports which can change their type dynamically.
We use the request_module() call to load the relevant protocol driver
when needed: on loading time or at port type change event.


Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 60c9f4f..179d267 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -42,6 +42,7 @@
 #include <linux/io-mapping.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
+#include <linux/kmod.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/doorbell.h>
@@ -650,6 +651,27 @@ err_mem:
 	return err;
 }
 
+static void mlx4_request_modules(struct mlx4_dev *dev)
+{
+	int port;
+	int has_ib_port = false;
+	int has_eth_port = false;
+#define EN_DRV_NAME	"mlx4_en"
+#define IB_DRV_NAME	"mlx4_ib"
+
+	for (port = 1; port <= dev->caps.num_ports; port++) {
+		if (dev->caps.port_type[port] == MLX4_PORT_TYPE_IB)
+			has_ib_port = true;
+		else if (dev->caps.port_type[port] == MLX4_PORT_TYPE_ETH)
+			has_eth_port = true;
+	}
+
+	if (has_ib_port)
+		request_module_nowait(IB_DRV_NAME);
+	if (has_eth_port)
+		request_module_nowait(EN_DRV_NAME);
+}
+
 /*
  * Change the port configuration of the device.
  * Every user of this function must hold the port mutex.
@@ -681,6 +703,11 @@ int mlx4_change_port_types(struct mlx4_dev *dev,
 		}
 		mlx4_set_port_mask(dev);
 		err = mlx4_register_device(dev);
+		if (err) {
+			mlx4_err(dev, "Failed to register device\n");
+			goto out;
+		}
+		mlx4_request_modules(dev);
 	}
 
 out:
@@ -2305,6 +2332,8 @@ slave_start:
 	if (err)
 		goto err_port;
 
+	mlx4_request_modules(dev);
+
 	mlx4_sense_init(dev);
 	mlx4_start_sense(dev);
 
-- 
1.8.3.4
