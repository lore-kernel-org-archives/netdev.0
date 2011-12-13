From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH net-next V2 02/21] mlx4: Extanding port_mask functionality
Date: Tue, 13 Dec 2011 16:10:41 +0200
Message-ID: <4EE75CE1.1080504@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>

Port mask now has additional state.
Port can be set as "none". In this case neither the mlx4_en or mlx4_ib
drivers take ownership of the port.
In multifunction mode there is an option to set the vfs as single ported devices.
(in single function mode, both physical ports belong to same function)

Signed-off-by: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/infiniband/hw/mlx4/main.c         |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c |    4 +---
 include/linux/mlx4/device.h               |   13 ++++++-------
 3 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 77f3dbc..6128b29 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -177,7 +177,7 @@ mlx4_ib_port_link_layer(struct ib_device *device, u8 port_num)
 {
 	struct mlx4_dev *dev = to_mdev(device)->dev;
 
-	return dev->caps.port_mask & (1 << (port_num - 1)) ?
+	return dev->caps.port_mask[port_num] == MLX4_PORT_TYPE_IB ?
 		IB_LINK_LAYER_INFINIBAND : IB_LINK_LAYER_ETHERNET;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 94bbc85..64d03f8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -140,10 +140,8 @@ static void mlx4_set_port_mask(struct mlx4_dev *dev)
 {
 	int i;
 
-	dev->caps.port_mask = 0;
 	for (i = 1; i <= dev->caps.num_ports; ++i)
-		if (dev->caps.port_type[i] == MLX4_PORT_TYPE_IB)
-			dev->caps.port_mask |= 1 << (i - 1);
+		dev->caps.port_mask[i] = dev->caps.port_type[i];
 }
 
 static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index b9466af..3333018 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -302,7 +302,7 @@ struct mlx4_caps {
 	int                     log_num_prios;
 	enum mlx4_port_type	port_type[MLX4_MAX_PORTS + 1];
 	u8			supported_type[MLX4_MAX_PORTS + 1];
-	u32			port_mask;
+	u32			port_mask[MLX4_MAX_PORTS + 1];
 	enum mlx4_port_type	possible_type[MLX4_MAX_PORTS + 1];
 	u32			max_counters;
 	u8			ext_port_cap[MLX4_MAX_PORTS + 1];
@@ -507,13 +507,12 @@ struct mlx4_init_port_param {
 
 #define mlx4_foreach_port(port, dev, type)				\
 	for ((port) = 1; (port) <= (dev)->caps.num_ports; (port)++)	\
-		if (((type) == MLX4_PORT_TYPE_IB ? (dev)->caps.port_mask : \
-		     ~(dev)->caps.port_mask) & 1 << ((port) - 1))
+		if ((type) == (dev)->caps.port_mask[(port)])
 
-#define mlx4_foreach_ib_transport_port(port, dev)			\
-	for ((port) = 1; (port) <= (dev)->caps.num_ports; (port)++)	\
-		if (((dev)->caps.port_mask & 1 << ((port) - 1)) ||	\
-		     ((dev)->caps.flags & MLX4_DEV_CAP_FLAG_IBOE))
+#define mlx4_foreach_ib_transport_port(port, dev)                         \
+	for ((port) = 1; (port) <= (dev)->caps.num_ports; (port)++)	  \
+		if (((dev)->caps.port_mask[port] == MLX4_PORT_TYPE_IB) || \
+			((dev)->caps.flags & MLX4_DEV_CAP_FLAG_IBOE))
 
 static inline int mlx4_is_master(struct mlx4_dev *dev)
 {
-- 
1.7.7








--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
