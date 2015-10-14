From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 4/4] net/mlx4_core: Replace VF zero mac with random mac in mlx4_core
Date: Wed, 14 Oct 2015 17:43:48 +0300
Message-ID: <1444833828-8240-5-git-send-email-ogerlitz@mellanox.com>
References: <1444833828-8240-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37143 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753193AbbJNOoj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 10:44:39 -0400
In-Reply-To: <1444833828-8240-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

By design, when no default MAC addresses are set in the Hypervisor for VFs,
the VFs are passed zero-macs. When such a MAC is received by the VF, it
generates a random MAC address and registers that MAC address
with the Hypervisor.

This random mac generation is currently done in the mlx4_en module.
There is a problem, though, if the mlx4_ib module is loaded by a VF before
the mlx4_en module. In this case, for RoCE, mlx4_ib will see the un-replaced
zero-mac and register that zero-mac as part of QP1 initialization.

Having a zero-mac in the port's MAC table creates problems for a
Baseboard Management Console. The BMC occasionally sends packets with a
zero-mac destination MAC. If there is a zero-mac present in the port's
MAC table, the FW will send such BMC packets to the host driver rather than
to the wire, and BMC will stop working.

To address this problem, we move the replacement of zero-mac addresses
with random-mac addresses to procedure mlx4_slave_cap(), which is part of the
driver startup for VFs, and is before activation of mlx4_ib and mlx4_en.
As a result, zero-mac addresses will never be registered in the port MAC table
by the driver.

In addition, when mlx4_en does initialize the net device, it needs to set
the NET_ADDR_RANDOM flag in the netdev structure if the address was
randomly generated. This is done so that udev on the VM does not create
a new device name after each VF probe (VM boot and such). To accomplish this,
we add a per-port flag in mlx4_dev which gets set whenever mlx4_core replaces
a zero-mac with a randomly-generated mac. This flag is examined when mlx4_en
initializes the net-device.

Fix was suggested by Matan Barak <matanb@mellanox.com>

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 23 +++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/fw.c        | 16 ++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c      |  2 ++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |  2 ++
 include/linux/mlx4/device.h                    |  1 +
 5 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 597d892..886e1bc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2816,7 +2816,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	struct mlx4_en_priv *priv;
 	int i;
 	int err;
-	u64 mac_u64;
 
 	dev = alloc_etherdev_mqs(sizeof(struct mlx4_en_priv),
 				 MAX_TX_RINGS, MAX_RX_RINGS);
@@ -2908,17 +2907,17 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	dev->addr_len = ETH_ALEN;
 	mlx4_en_u64_to_mac(dev->dev_addr, mdev->dev->caps.def_mac[priv->port]);
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		if (mlx4_is_slave(priv->mdev->dev)) {
-			eth_hw_addr_random(dev);
-			en_warn(priv, "Assigned random MAC address %pM\n", dev->dev_addr);
-			mac_u64 = mlx4_mac_to_u64(dev->dev_addr);
-			mdev->dev->caps.def_mac[priv->port] = mac_u64;
-		} else {
-			en_err(priv, "Port: %d, invalid mac burned: %pM, quiting\n",
-			       priv->port, dev->dev_addr);
-			err = -EINVAL;
-			goto out;
-		}
+		en_err(priv, "Port: %d, invalid mac burned: %pM, quiting\n",
+		       priv->port, dev->dev_addr);
+		err = -EINVAL;
+		goto out;
+	} else if (mlx4_is_slave(priv->mdev->dev) &&
+		   (priv->mdev->dev->port_random_macs & 1 << priv->port)) {
+		/* Random MAC was assigned in mlx4_slave_cap
+		 * in mlx4_core module
+		 */
+		dev->addr_assign_type |= NET_ADDR_RANDOM;
+		en_warn(priv, "Assigned random MAC address %pM\n", dev->dev_addr);
 	}
 
 	memcpy(priv->current_mac, dev->dev_addr, sizeof(priv->current_mac));
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index e8ec1de..f13a4d7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -2840,3 +2840,19 @@ int set_phv_bit(struct mlx4_dev *dev, u8 port, int new_val)
 	return -EOPNOTSUPP;
 }
 EXPORT_SYMBOL(set_phv_bit);
+
+void mlx4_replace_zero_macs(struct mlx4_dev *dev)
+{
+	int i;
+	u8 mac_addr[ETH_ALEN];
+
+	dev->port_random_macs = 0;
+	for (i = 1; i <= dev->caps.num_ports; ++i)
+		if (!dev->caps.def_mac[i] &&
+		    dev->caps.port_type[i] == MLX4_PORT_TYPE_ETH) {
+			eth_random_addr(mac_addr);
+			dev->port_random_macs |= 1 << i;
+			dev->caps.def_mac[i] = mlx4_mac_to_u64(mac_addr);
+		}
+}
+EXPORT_SYMBOL_GPL(mlx4_replace_zero_macs);
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 006757f..bcbdfab 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -863,6 +863,8 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 		return -ENODEV;
 	}
 
+	mlx4_replace_zero_macs(dev);
+
 	dev->caps.qp0_qkey = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
 	dev->caps.qp0_tunnel = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
 	dev->caps.qp0_proxy = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 232b2b5..e1cf903 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1378,6 +1378,8 @@ void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work);
 
 void mlx4_init_quotas(struct mlx4_dev *dev);
 
+/* for VFs, replace zero MACs with randomly-generated MACs at driver start */
+void mlx4_replace_zero_macs(struct mlx4_dev *dev);
 int mlx4_get_slave_num_gids(struct mlx4_dev *dev, int slave, int port);
 /* Returns the VF index of slave */
 int mlx4_get_vf_indx(struct mlx4_dev *dev, int slave);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index baad4cb..5a8677b 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -833,6 +833,7 @@ struct mlx4_dev {
 	struct mlx4_quotas	quotas;
 	struct radix_tree_root	qp_table_tree;
 	u8			rev_id;
+	u8			port_random_macs;
 	char			board_id[MLX4_BOARD_ID_LEN];
 	int			numa_node;
 	int			oper_log_mgm_entry_size;
-- 
2.3.7
