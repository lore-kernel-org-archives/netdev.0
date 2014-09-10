From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/4] net/mlx4: Correctly configure single ported VFs from the host
Date: Wed, 10 Sep 2014 16:41:53 +0300
Message-ID: <1410356516-23594-2-git-send-email-ogerlitz@mellanox.com>
References: <1410356516-23594-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46259 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750935AbaIJNmG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 09:42:06 -0400
In-Reply-To: <1410356516-23594-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Single port VFs are seen PCI wise on both ports of the PF (we don't have
single port PFs with ConnectX). With this in mind, it's possible for
virtualization tools to try and configure a single ported VF through
the "wrong" PF port.

To handle that, we use the PF driver mapping of single port VFs to NIC
ports and adjust the port value before calling into the low level
code that does the actual VF configuration

Fixes: 449fc48 ('net/mlx4: Adapt code for N-Port VF')
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 65a4a0f..02a2e90 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2389,6 +2389,22 @@ struct mlx4_slaves_pport mlx4_phys_to_slaves_pport_actv(
 }
 EXPORT_SYMBOL_GPL(mlx4_phys_to_slaves_pport_actv);
 
+static int mlx4_slaves_closest_port(struct mlx4_dev *dev, int slave, int port)
+{
+	struct mlx4_active_ports actv_ports = mlx4_get_active_ports(dev, slave);
+	int min_port = find_first_bit(actv_ports.ports, dev->caps.num_ports)
+			+ 1;
+	int max_port = min_port +
+		bitmap_weight(actv_ports.ports, dev->caps.num_ports);
+
+	if (port < min_port)
+		port = min_port;
+	else if (port >= max_port)
+		port = max_port - 1;
+
+	return port;
+}
+
 int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -2402,6 +2418,7 @@ int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac)
 	if (slave < 0)
 		return -EINVAL;
 
+	port = mlx4_slaves_closest_port(dev, slave, port);
 	s_info = &priv->mfunc.master.vf_admin[slave].vport[port];
 	s_info->mac = mac;
 	mlx4_info(dev, "default mac on vf %d port %d to %llX will take afect only after vf restart\n",
@@ -2428,6 +2445,7 @@ int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos)
 	if (slave < 0)
 		return -EINVAL;
 
+	port = mlx4_slaves_closest_port(dev, slave, port);
 	vf_admin = &priv->mfunc.master.vf_admin[slave].vport[port];
 
 	if ((0 == vlan) && (0 == qos))
@@ -2455,6 +2473,7 @@ bool mlx4_get_slave_default_vlan(struct mlx4_dev *dev, int port, int slave,
 	struct mlx4_priv *priv;
 
 	priv = mlx4_priv(dev);
+	port = mlx4_slaves_closest_port(dev, slave, port);
 	vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
 
 	if (MLX4_VGT != vp_oper->state.default_vlan) {
@@ -2482,6 +2501,7 @@ int mlx4_set_vf_spoofchk(struct mlx4_dev *dev, int port, int vf, bool setting)
 	if (slave < 0)
 		return -EINVAL;
 
+	port = mlx4_slaves_closest_port(dev, slave, port);
 	s_info = &priv->mfunc.master.vf_admin[slave].vport[port];
 	s_info->spoofchk = setting;
 
@@ -2535,6 +2555,7 @@ int mlx4_set_vf_link_state(struct mlx4_dev *dev, int port, int vf, int link_stat
 	if (slave < 0)
 		return -EINVAL;
 
+	port = mlx4_slaves_closest_port(dev, slave, port);
 	switch (link_state) {
 	case IFLA_VF_LINK_STATE_AUTO:
 		/* get current link state */
-- 
1.7.1
