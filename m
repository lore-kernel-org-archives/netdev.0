From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH] mlx4: Fixing Ethernet unicast packet steering
Date: Wed, 3 Aug 2011 17:21:00 +0300
Message-ID: <4E39594C.4090808@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


For older FW versions, fixing the usage of per port Mac table.
For each port we must define the base QP number, which is passed
to the HW.
Setting the correct value in SET_PORT FW command to enable the steering.

Reported-by: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/en_port.c |    2 +-
 drivers/net/mlx4/main.c    |    2 ++
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index 5e71091..5ada5b4 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -128,7 +128,7 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 	memset(context, 0, sizeof *context);
 
 	context->base_qpn = cpu_to_be32(base_qpn);
-	context->n_mac = 0x7;
+	context->n_mac = 0x2;
 	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT |
 				       base_qpn);
 	context->mcast = cpu_to_be32(m_promisc << SET_PORT_MC_PROMISC_SHIFT |
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index c94b342..f0ee35d 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -1117,6 +1117,8 @@ static int mlx4_init_port_info(struct mlx4_dev *dev, int port)
 	info->port = port;
 	mlx4_init_mac_table(dev, &info->mac_table);
 	mlx4_init_vlan_table(dev, &info->vlan_table);
+	info->base_qpn = dev->caps.reserved_qps_base[MLX4_QP_REGION_ETH_ADDR] +
+			(port - 1) * (1 << log_num_mac);
 
 	sprintf(info->dev_name, "mlx4_port%d", port);
 	info->port_attr.attr.name = info->dev_name;
-- 
1.6.0.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
