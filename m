From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/3] net/mlx4: Add VF link state support
Date: Sun,  9 Jun 2013 16:14:26 +0300
Message-ID: <1370783667-19457-3-git-send-email-ogerlitz@mellanox.com>
References: <1370783667-19457-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:54495 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752932Ab3FINNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jun 2013 09:13:19 -0400
In-Reply-To: <1370783667-19457-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rony Efraim <ronye@mellanox.com>

Add support to change the link state of VF (vPort)

Signed-off-by: Rony Efraim <ronye@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c       |   48 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    8 ++++
 drivers/net/ethernet/mellanox/mlx4/eq.c        |    9 +++-
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    8 ++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |    1 +
 include/linux/mlx4/cmd.h                       |    2 +-
 6 files changed, 73 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 0e572a5..ea1e038 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -39,6 +39,7 @@
 #include <linux/errno.h>
 
 #include <linux/mlx4/cmd.h>
+#include <linux/mlx4/device.h>
 #include <linux/semaphore.h>
 #include <rdma/ib_smi.h>
 
@@ -2178,7 +2179,54 @@ int mlx4_get_vf_config(struct mlx4_dev *dev, int port, int vf, struct ifla_vf_in
 	ivf->qos	= s_info->default_qos;
 	ivf->tx_rate	= s_info->tx_rate;
 	ivf->spoofchk	= s_info->spoofchk;
+	ivf->linkstate	= s_info->link_state;
 
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx4_get_vf_config);
+
+int mlx4_set_vf_link_state(struct mlx4_dev *dev, int port, int vf, int link_state)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_vport_state *s_info;
+	struct mlx4_vport_oper_state *vp_oper;
+	int slave;
+	u8 link_stat_event;
+
+	slave = mlx4_get_slave_indx(dev, vf);
+	if (slave < 0)
+		return -EINVAL;
+
+	switch (link_state) {
+	case IFLA_VF_LINK_STATE_AUTO:
+		/* get current link state */
+		if (!priv->sense.do_sense_port[port])
+			link_stat_event = MLX4_PORT_CHANGE_SUBTYPE_ACTIVE;
+		else
+			link_stat_event = MLX4_PORT_CHANGE_SUBTYPE_DOWN;
+	    break;
+
+	case IFLA_VF_LINK_STATE_ENABLE:
+		link_stat_event = MLX4_PORT_CHANGE_SUBTYPE_ACTIVE;
+	    break;
+
+	case IFLA_VF_LINK_STATE_DISABLE:
+		link_stat_event = MLX4_PORT_CHANGE_SUBTYPE_DOWN;
+	    break;
+
+	default:
+		mlx4_warn(dev, "unknown value for link_state %02x on slave %d port %d\n",
+			  link_state, slave, port);
+		return -EINVAL;
+	};
+	/* update the admin & oper state on the link state */
+	s_info = &priv->mfunc.master.vf_admin[slave].vport[port];
+	vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
+	s_info->link_state = link_state;
+	vp_oper->state.link_state = link_state;
+
+	/* send event */
+	mlx4_gen_port_state_change_eqe(dev, slave, port, link_stat_event);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx4_set_vf_link_state);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 89c47ea..ade276c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2061,6 +2061,13 @@ static int mlx4_en_get_vf_config(struct net_device *dev, int vf, struct ifla_vf_
 	return mlx4_get_vf_config(mdev->dev, en_priv->port, vf, ivf);
 }
 
+static int mlx4_en_set_vf_link_state(struct net_device *dev, int vf, int link_state)
+{
+	struct mlx4_en_priv *en_priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = en_priv->mdev;
+
+	return mlx4_set_vf_link_state(mdev->dev, en_priv->port, vf, link_state);
+}
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
@@ -2101,6 +2108,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 	.ndo_set_vf_mac		= mlx4_en_set_vf_mac,
 	.ndo_set_vf_vlan	= mlx4_en_set_vf_vlan,
 	.ndo_set_vf_spoofchk	= mlx4_en_set_vf_spoofchk,
+	.ndo_set_vf_link_state	= mlx4_en_set_vf_link_state,
 	.ndo_get_vf_config	= mlx4_en_get_vf_config,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= mlx4_en_netpoll,
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 6000342..7e04286 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -448,6 +448,7 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 	int i;
 	enum slave_port_gen_event gen_event;
 	unsigned long flags;
+	struct mlx4_vport_state *s_info;
 
 	while ((eqe = next_eqe_sw(eq, dev->caps.eqe_factor))) {
 		/*
@@ -556,7 +557,9 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 						mlx4_dbg(dev, "%s: Sending MLX4_PORT_CHANGE_SUBTYPE_DOWN"
 							 " to slave: %d, port:%d\n",
 							 __func__, i, port);
-						mlx4_slave_event(dev, i, eqe);
+						s_info = &priv->mfunc.master.vf_oper[slave].vport[port].state;
+						if (IFLA_VF_LINK_STATE_AUTO == s_info->link_state)
+							mlx4_slave_event(dev, i, eqe);
 					} else {  /* IB port */
 						set_and_calc_slave_port_state(dev, i, port,
 									      MLX4_PORT_STATE_DEV_EVENT_PORT_DOWN,
@@ -580,7 +583,9 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 					for (i = 0; i < dev->num_slaves; i++) {
 						if (i == mlx4_master_func_num(dev))
 							continue;
-						mlx4_slave_event(dev, i, eqe);
+						s_info = &priv->mfunc.master.vf_oper[slave].vport[port].state;
+						if (IFLA_VF_LINK_STATE_AUTO == s_info->link_state)
+							mlx4_slave_event(dev, i, eqe);
 					}
 				else /* IB port */
 					/* port-up event will be sent to a slave when the
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 2c97901..569bbe3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -830,8 +830,10 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 	u8 port_type;
 	u16 short_field;
 	int err;
+	int admin_link_state;
 
 #define MLX4_VF_PORT_NO_LINK_SENSE_MASK	0xE0
+#define MLX4_PORT_LINK_UP_MASK		0x80
 #define QUERY_PORT_CUR_MAX_PKEY_OFFSET	0x0c
 #define QUERY_PORT_CUR_MAX_GID_OFFSET	0x0e
 
@@ -861,6 +863,12 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 		/* set port type to currently operating port type */
 		port_type |= (dev->caps.port_type[vhcr->in_modifier] & 0x3);
 
+		admin_link_state = priv->mfunc.master.vf_oper[slave].vport[vhcr->in_modifier].state.link_state;
+		if (IFLA_VF_LINK_STATE_ENABLE == admin_link_state)
+			port_type |= MLX4_PORT_LINK_UP_MASK;
+		else if (IFLA_VF_LINK_STATE_DISABLE == admin_link_state)
+			port_type &= ~MLX4_PORT_LINK_UP_MASK;
+
 		MLX4_PUT(outbox->buf, port_type,
 			 QUERY_PORT_SUPPORTED_TYPE_OFFSET);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index df15bb6..7527293 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -482,6 +482,7 @@ struct mlx4_vport_state {
 	u8  default_qos;
 	u32 tx_rate;
 	bool spoofchk;
+	u32 link_state;
 };
 
 struct mlx4_vf_admin_state {
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index adf6e06..8074a97 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -237,7 +237,7 @@ int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac);
 int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos);
 int mlx4_set_vf_spoofchk(struct mlx4_dev *dev, int port, int vf, bool setting);
 int mlx4_get_vf_config(struct mlx4_dev *dev, int port, int vf, struct ifla_vf_info *ivf);
-
+int mlx4_set_vf_link_state(struct mlx4_dev *dev, int port, int vf, int link_state);
 
 #define MLX4_COMM_GET_IF_REV(cmd_chan_ver) (u8)((cmd_chan_ver) >> 8)
 
-- 
1.7.1
