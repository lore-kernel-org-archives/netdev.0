From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 4/5] net: Update API for VST QinQ support
Date: Mon, 25 Jul 2016 14:15:35 +0300
Message-ID: <1469445336-21952-5-git-send-email-tariqt@mellanox.com>
References: <1469445336-21952-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Moshe Shemesh <moshe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36469 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751139AbcGYLQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 07:16:00 -0400
In-Reply-To: <1469445336-21952-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

Intoduce new rtnl UAPI that exposes a protocol parameter, giving
the ability for user-space application to specify it for the VF.
We adjusted IP Link tool to support this option.

Add IFLA_VF_VLAN_INFO in addition to IFLA_VF_VLAN to keep backward
compatibility with older versions of IP Link tool.
Add a vlan protocol parameter to the ndo_set_vf_vlan callback.
We kept 802.1Q as the drivers' default vlan protocol, setting vf vlan
protocol to 802.1ad shall set the vf to VST QinQ mode.

Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |  3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |  9 +++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c    |  6 ++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h    |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |  6 ++++-
 drivers/net/ethernet/intel/fm10k/fm10k.h           |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c       |  6 ++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 11 +++++++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c          |  9 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |  5 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  6 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  6 ++++-
 drivers/net/ethernet/qlogic/qede/qede_main.c       |  6 ++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |  2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |  5 +++-
 drivers/net/ethernet/sfc/sriov.c                   |  5 +++-
 drivers/net/ethernet/sfc/sriov.h                   |  2 +-
 include/linux/if_link.h                            |  1 +
 include/linux/netdevice.h                          |  6 +++--
 include/uapi/linux/if_link.h                       | 10 +++++++-
 net/core/rtnetlink.c                               | 28 ++++++++++++++++++++--
 23 files changed, 113 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 0e68fadecfdb..243cb9748d35 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -492,7 +492,8 @@ int __bnx2x_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 int bnx2x_get_vf_config(struct net_device *dev, int vf,
 			struct ifla_vf_info *ivi);
 int bnx2x_set_vf_mac(struct net_device *dev, int queue, u8 *mac);
-int bnx2x_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos);
+int bnx2x_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos,
+		      __be16 vlan_proto);
 
 /* select_queue callback */
 u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 632daff117d3..2f18bd856913 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2527,7 +2527,8 @@ void bnx2x_pf_set_vfs_vlan(struct bnx2x *bp)
 	for_each_vf(bp, vfidx) {
 		bulletin = BP_VF_BULLETIN(bp, vfidx);
 		if (bulletin->valid_bitmap & (1 << VLAN_VALID))
-			bnx2x_set_vf_vlan(bp->dev, vfidx, bulletin->vlan, 0);
+			bnx2x_set_vf_vlan(bp->dev, vfidx, bulletin->vlan, 0,
+					  htons(ETH_P_8021Q));
 	}
 }
 
@@ -2787,7 +2788,8 @@ static int bnx2x_set_vf_vlan_filter(struct bnx2x *bp, struct bnx2x_virtf *vf,
 	return 0;
 }
 
-int bnx2x_set_vf_vlan(struct net_device *dev, int vfidx, u16 vlan, u8 qos)
+int bnx2x_set_vf_vlan(struct net_device *dev, int vfidx, u16 vlan, u8 qos,
+		      __be16 vlan_proto)
 {
 	struct pf_vf_bulletin_content *bulletin = NULL;
 	struct bnx2x *bp = netdev_priv(dev);
@@ -2802,6 +2804,9 @@ int bnx2x_set_vf_vlan(struct net_device *dev, int vfidx, u16 vlan, u8 qos)
 		return -EINVAL;
 	}
 
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
+
 	DP(BNX2X_MSG_IOV, "configuring VF %d with VLAN %d qos %d\n",
 	   vfidx, vlan, 0);
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 50d2007a2640..d2049a9d6c61 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -135,7 +135,8 @@ int bnxt_set_vf_mac(struct net_device *dev, int vf_id, u8 *mac)
 	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 }
 
-int bnxt_set_vf_vlan(struct net_device *dev, int vf_id, u16 vlan_id, u8 qos)
+int bnxt_set_vf_vlan(struct net_device *dev, int vf_id, u16 vlan_id, u8 qos,
+		     __be16 vlan_proto)
 {
 	struct hwrm_func_cfg_input req = {0};
 	struct bnxt *bp = netdev_priv(dev);
@@ -146,6 +147,9 @@ int bnxt_set_vf_vlan(struct net_device *dev, int vf_id, u16 vlan_id, u8 qos)
 	if (bp->hwrm_spec_code < 0x10201)
 		return -ENOTSUPP;
 
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
+
 	rc = bnxt_vf_ndo_prep(bp, vf_id);
 	if (rc)
 		return rc;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
index 0392670ab49c..1ab72e4820af 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
@@ -12,7 +12,7 @@
 
 int bnxt_get_vf_config(struct net_device *, int, struct ifla_vf_info *);
 int bnxt_set_vf_mac(struct net_device *, int, u8 *);
-int bnxt_set_vf_vlan(struct net_device *, int, u16, u8);
+int bnxt_set_vf_vlan(struct net_device *, int, u16, u8, __be16);
 int bnxt_set_vf_bw(struct net_device *, int, int, int);
 int bnxt_set_vf_link_state(struct net_device *, int, int);
 int bnxt_set_vf_spoofchk(struct net_device *, int, bool);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 1f16e73f6d0c..f567049d834e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1701,7 +1701,8 @@ static int be_clear_vf_tvt(struct be_adapter *adapter, int vf)
 	return 0;
 }
 
-static int be_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
+static int be_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos,
+			  __be16 vlan_proto)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct be_vf_cfg *vf_cfg = &adapter->vf_cfg[vf];
@@ -1713,6 +1714,9 @@ static int be_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 	if (vf >= adapter->num_vfs || vlan > 4095 || qos > 7)
 		return -EINVAL;
 
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
+
 	if (vlan || qos) {
 		vlan |= qos << VLAN_PRIO_SHIFT;
 		status = be_set_vf_tvt(adapter, vf, vlan);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index c4cf08dcf5af..1a3697749809 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -509,7 +509,7 @@ int fm10k_iov_configure(struct pci_dev *pdev, int num_vfs);
 s32 fm10k_iov_update_pvid(struct fm10k_intfc *interface, u16 glort, u16 pvid);
 int fm10k_ndo_set_vf_mac(struct net_device *netdev, int vf_idx, u8 *mac);
 int fm10k_ndo_set_vf_vlan(struct net_device *netdev,
-			  int vf_idx, u16 vid, u8 qos);
+			  int vf_idx, u16 vid, u8 qos, __be16 vlan_proto);
 int fm10k_ndo_set_vf_bw(struct net_device *netdev, int vf_idx, int rate,
 			int unused);
 int fm10k_ndo_get_vf_config(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index 47f0743ec03b..972bb0fa5e7e 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -445,7 +445,7 @@ int fm10k_ndo_set_vf_mac(struct net_device *netdev, int vf_idx, u8 *mac)
 }
 
 int fm10k_ndo_set_vf_vlan(struct net_device *netdev, int vf_idx, u16 vid,
-			  u8 qos)
+			  u8 qos, __be16 vlan_proto)
 {
 	struct fm10k_intfc *interface = netdev_priv(netdev);
 	struct fm10k_iov_data *iov_data = interface->iov_data;
@@ -460,6 +460,10 @@ int fm10k_ndo_set_vf_vlan(struct net_device *netdev, int vf_idx, u16 vid,
 	if (qos || (vid > (VLAN_VID_MASK - 1)))
 		return -EINVAL;
 
+	/* VF VLAN Protocol part to default is unsupported */
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
+
 	vf_info = &iov_data->vf_info[vf_idx];
 
 	/* exit if there is nothing to do */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 6fcbf764f32b..ad2bb21e9f8f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2742,11 +2742,12 @@ error_param:
  * @vf_id: VF identifier
  * @vlan_id: mac address
  * @qos: priority setting
+ * @vlan_proto: vlan protocol
  *
  * program VF vlan id and/or qos
  **/
-int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
-			      int vf_id, u16 vlan_id, u8 qos)
+int i40e_ndo_set_vf_port_vlan(struct net_device *netdev, int vf_id,
+			      u16 vlan_id, u8 qos, __be16 vlan_proto)
 {
 	u16 vlanprio = vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT);
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
@@ -2769,6 +2770,12 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		goto error_pvid;
 	}
 
+	if (vlan_proto != htons(ETH_P_8021Q)) {
+		dev_err(&pf->pdev->dev, "VF VLAN protocol is not supported\n");
+		ret = -EPROTONOSUPPORT;
+		goto error_pvid;
+	}
+
 	vf = &(pf->vf[vf_id]);
 	vsi = pf->vsi[vf->lan_vsi_idx];
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 875174141451..4012d069939a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -129,8 +129,8 @@ void i40e_vc_notify_vf_reset(struct i40e_vf *vf);
 
 /* VF configuration related iplink handlers */
 int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac);
-int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
-			      int vf_id, u16 vlan_id, u8 qos);
+int i40e_ndo_set_vf_port_vlan(struct net_device *netdev, int vf_id,
+			      u16 vlan_id, u8 qos, __be16 vlan_proto);
 int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
 		       int max_tx_rate);
 int i40e_ndo_set_vf_trust(struct net_device *netdev, int vf_id, bool setting);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 9bcba42abb91..b97e4b6fe37a 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -169,7 +169,7 @@ static int igb_set_vf_mac(struct igb_adapter *, int, unsigned char *);
 static void igb_restore_vf_multicasts(struct igb_adapter *adapter);
 static int igb_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac);
 static int igb_ndo_set_vf_vlan(struct net_device *netdev,
-			       int vf, u16 vlan, u8 qos);
+			       int vf, u16 vlan, u8 qos, __be16 vlan_proto);
 static int igb_ndo_set_vf_bw(struct net_device *, int, int, int);
 static int igb_ndo_set_vf_spoofchk(struct net_device *netdev, int vf,
 				   bool setting);
@@ -6205,14 +6205,17 @@ static int igb_disable_port_vlan(struct igb_adapter *adapter, int vf)
 	return 0;
 }
 
-static int igb_ndo_set_vf_vlan(struct net_device *netdev,
-			       int vf, u16 vlan, u8 qos)
+static int igb_ndo_set_vf_vlan(struct net_device *netdev, int vf,
+			       u16 vlan, u8 qos, __be16 vlan_proto)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
 	if ((vf >= adapter->vfs_allocated_count) || (vlan > 4095) || (qos > 7))
 		return -EINVAL;
 
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
+
 	return (vlan || qos) ? igb_enable_port_vlan(adapter, vf, vlan, qos) :
 			       igb_disable_port_vlan(adapter, vf);
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 8618599dfd6f..b18590a995db 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1354,13 +1354,16 @@ static int ixgbe_disable_port_vlan(struct ixgbe_adapter *adapter, int vf)
 	return err;
 }
 
-int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
+int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan,
+			  u8 qos, __be16 vlan_proto)
 {
 	int err = 0;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	if ((vf >= adapter->num_vfs) || (vlan > 4095) || (qos > 7))
 		return -EINVAL;
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
 	if (vlan || qos) {
 		/* Check if there is already a port VLAN set, if so
 		 * we have to delete the old one first before we
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 47e65e2f886a..0c7977d27b71 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -43,7 +43,7 @@ void ixgbe_disable_tx_rx(struct ixgbe_adapter *adapter);
 void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter);
 int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int queue, u8 *mac);
 int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int queue, u16 vlan,
-			   u8 qos);
+			   u8 qos, __be16 vlan_proto);
 int ixgbe_link_mbps(struct ixgbe_adapter *adapter);
 int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int min_tx_rate,
 			int max_tx_rate);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 3d51bcdd6e8f..e0f05e63237c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2399,11 +2399,15 @@ static int mlx4_en_set_vf_mac(struct net_device *dev, int queue, u8 *mac)
 	return mlx4_set_vf_mac(mdev->dev, en_priv->port, queue, mac_u64);
 }
 
-static int mlx4_en_set_vf_vlan(struct net_device *dev, int vf, u16 vlan, u8 qos)
+static int mlx4_en_set_vf_vlan(struct net_device *dev, int vf, u16 vlan, u8 qos,
+			       __be16 vlan_proto)
 {
 	struct mlx4_en_priv *en_priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = en_priv->mdev;
 
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
+
 	return mlx4_set_vf_vlan(mdev->dev, en_priv->port, vf, vlan, qos);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index bdcb699fe63e..0d8e391a5c3d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2616,11 +2616,15 @@ static int mlx5e_set_vf_mac(struct net_device *dev, int vf, u8 *mac)
 	return mlx5_eswitch_set_vport_mac(mdev->priv.eswitch, vf + 1, mac);
 }
 
-static int mlx5e_set_vf_vlan(struct net_device *dev, int vf, u16 vlan, u8 qos)
+static int mlx5e_set_vf_vlan(struct net_device *dev, int vf, u16 vlan, u8 qos,
+			     __be16 vlan_proto)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
+
 	return mlx5_eswitch_set_vport_vlan(mdev->priv.eswitch, vf + 1,
 					   vlan, qos);
 }
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 91e7bb0b85c8..ecc0dc72f408 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -100,7 +100,8 @@ static int qede_alloc_rx_buffer(struct qede_dev *edev,
 static void qede_link_update(void *dev, struct qed_link_output *link);
 
 #ifdef CONFIG_QED_SRIOV
-static int qede_set_vf_vlan(struct net_device *ndev, int vf, u16 vlan, u8 qos)
+static int qede_set_vf_vlan(struct net_device *ndev, int vf, u16 vlan, u8 qos,
+			    __be16 vlan_proto)
 {
 	struct qede_dev *edev = netdev_priv(ndev);
 
@@ -109,6 +110,9 @@ static int qede_set_vf_vlan(struct net_device *ndev, int vf, u16 vlan, u8 qos)
 		return -EINVAL;
 	}
 
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
+
 	DP_VERBOSE(edev, QED_MSG_IOV, "Setting Vlan 0x%04x to VF [%d]\n",
 		   vlan, vf);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
index 017d8c2c8285..8c98d927ae90 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
@@ -237,7 +237,7 @@ int qlcnic_sriov_set_vf_mac(struct net_device *, int, u8 *);
 int qlcnic_sriov_set_vf_tx_rate(struct net_device *, int, int, int);
 int qlcnic_sriov_get_vf_config(struct net_device *, int ,
 			       struct ifla_vf_info *);
-int qlcnic_sriov_set_vf_vlan(struct net_device *, int, u16, u8);
+int qlcnic_sriov_set_vf_vlan(struct net_device *, int, u16, u8, __be16);
 int qlcnic_sriov_set_vf_spoofchk(struct net_device *, int, bool);
 #else
 static inline void qlcnic_sriov_pf_disable(struct qlcnic_adapter *adapter) {}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index afd687e5e779..50eaafa3eaba 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -1915,7 +1915,7 @@ int qlcnic_sriov_set_vf_tx_rate(struct net_device *netdev, int vf,
 }
 
 int qlcnic_sriov_set_vf_vlan(struct net_device *netdev, int vf,
-			     u16 vlan, u8 qos)
+			     u16 vlan, u8 qos, __be16 vlan_proto)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
@@ -1928,6 +1928,9 @@ int qlcnic_sriov_set_vf_vlan(struct net_device *netdev, int vf,
 	if (vf >= sriov->num_vfs || qos > 7)
 		return -EINVAL;
 
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
+
 	if (vlan > MAX_VLAN_ID) {
 		netdev_err(netdev,
 			   "Invalid VLAN ID, allowed range is [0 - %d]\n",
diff --git a/drivers/net/ethernet/sfc/sriov.c b/drivers/net/ethernet/sfc/sriov.c
index 816c44689e67..9abcf4aded30 100644
--- a/drivers/net/ethernet/sfc/sriov.c
+++ b/drivers/net/ethernet/sfc/sriov.c
@@ -22,7 +22,7 @@ int efx_sriov_set_vf_mac(struct net_device *net_dev, int vf_i, u8 *mac)
 }
 
 int efx_sriov_set_vf_vlan(struct net_device *net_dev, int vf_i, u16 vlan,
-			  u8 qos)
+			  u8 qos, __be16 vlan_proto)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
@@ -31,6 +31,9 @@ int efx_sriov_set_vf_vlan(struct net_device *net_dev, int vf_i, u16 vlan,
 		    (qos & ~(VLAN_PRIO_MASK >> VLAN_PRIO_SHIFT)))
 			return -EINVAL;
 
+		if (vlan_proto != htons(ETH_P_8021Q))
+			return -EPROTONOSUPPORT;
+
 		return efx->type->sriov_set_vf_vlan(efx, vf_i, vlan, qos);
 	} else {
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/sfc/sriov.h b/drivers/net/ethernet/sfc/sriov.h
index 400df526586d..ba1762e7f216 100644
--- a/drivers/net/ethernet/sfc/sriov.h
+++ b/drivers/net/ethernet/sfc/sriov.h
@@ -16,7 +16,7 @@
 
 int efx_sriov_set_vf_mac(struct net_device *net_dev, int vf_i, u8 *mac);
 int efx_sriov_set_vf_vlan(struct net_device *net_dev, int vf_i, u16 vlan,
-			  u8 qos);
+			  u8 qos, __be16 vlan_proto);
 int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf_i,
 			      bool spoofchk);
 int efx_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f923d15b432c..0b17c585b5cd 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -25,5 +25,6 @@ struct ifla_vf_info {
 	__u32 max_tx_rate;
 	__u32 rss_query_en;
 	__u32 trusted;
+	__be16 vlan_proto;
 };
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 43c749b1b619..63aec4dea1ad 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -933,7 +933,8 @@ struct netdev_xdp {
  *
  *	SR-IOV management functions.
  * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
- * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
+ * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan,
+ *			  u8 qos, __be16 proto);
  * int (*ndo_set_vf_rate)(struct net_device *dev, int vf, int min_tx_rate,
  *			  int max_tx_rate);
  * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
@@ -1170,7 +1171,8 @@ struct net_device_ops {
 	int			(*ndo_set_vf_mac)(struct net_device *dev,
 						  int queue, u8 *mac);
 	int			(*ndo_set_vf_vlan)(struct net_device *dev,
-						   int queue, u16 vlan, u8 qos);
+						   int queue, u16 vlan,
+						   u8 qos, __be16 proto);
 	int			(*ndo_set_vf_rate)(struct net_device *dev,
 						   int vf, int min_tx_rate,
 						   int max_tx_rate);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index a1b5202c5f6b..6dc9cd92d9db 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -617,7 +617,7 @@ enum {
 enum {
 	IFLA_VF_UNSPEC,
 	IFLA_VF_MAC,		/* Hardware queue specific attributes */
-	IFLA_VF_VLAN,
+	IFLA_VF_VLAN,		/* VLAN ID and QoS */
 	IFLA_VF_TX_RATE,	/* Max TX Bandwidth Allocation */
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
 	IFLA_VF_LINK_STATE,	/* link state enable/disable/auto switch */
@@ -629,6 +629,7 @@ enum {
 	IFLA_VF_TRUST,		/* Trust VF */
 	IFLA_VF_IB_NODE_GUID,	/* VF Infiniband node GUID */
 	IFLA_VF_IB_PORT_GUID,	/* VF Infiniband port GUID */
+	IFLA_VF_VLAN_INFO,	/* VLAN ID, QoS and VLAN protocol */
 	__IFLA_VF_MAX,
 };
 
@@ -645,6 +646,13 @@ struct ifla_vf_vlan {
 	__u32 qos;
 };
 
+struct ifla_vf_vlan_info {
+	__u32 vf;
+	__u32 vlan; /* 0 - 4095, 0 disables VLAN filter */
+	__u32 qos;
+	__be16 vlan_proto; /* VLAN protocol either 802.1Q or 802.1ad */
+};
+
 struct ifla_vf_tx_rate {
 	__u32 vf;
 	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 189cc78c77eb..9e67dc7b0168 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -841,7 +841,7 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 		size += nla_total_size(num_vfs * sizeof(struct nlattr));
 		size += num_vfs *
 			(nla_total_size(sizeof(struct ifla_vf_mac)) +
-			 nla_total_size(sizeof(struct ifla_vf_vlan)) +
+			 nla_total_size(sizeof(struct ifla_vf_vlan_info)) +
 			 nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
 			 nla_total_size(sizeof(struct ifla_vf_rate)) +
 			 nla_total_size(sizeof(struct ifla_vf_link_state)) +
@@ -1115,6 +1115,7 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 	struct ifla_vf_stats vf_stats;
 	struct ifla_vf_trust vf_trust;
 	struct ifla_vf_vlan vf_vlan;
+	struct ifla_vf_vlan_info vf_vlan_info;
 	struct ifla_vf_rate vf_rate;
 	struct nlattr *vf, *vfstats;
 	struct ifla_vf_mac vf_mac;
@@ -1133,11 +1134,14 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 	 * IFLA_VF_LINK_STATE_AUTO which equals zero
 	 */
 	ivi.linkstate = 0;
+	/* VLAN Protocol by default is 802.1Q */
+	ivi.vlan_proto = htons(ETH_P_8021Q);
 	if (dev->netdev_ops->ndo_get_vf_config(dev, vfs_num, &ivi))
 		return 0;
 
 	vf_mac.vf =
 		vf_vlan.vf =
+		vf_vlan_info.vf =
 		vf_rate.vf =
 		vf_tx_rate.vf =
 		vf_spoofchk.vf =
@@ -1148,6 +1152,10 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 	memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
 	vf_vlan.vlan = ivi.vlan;
 	vf_vlan.qos = ivi.qos;
+	vf_vlan_info.vlan = ivi.vlan;
+	vf_vlan_info.qos = ivi.qos;
+	vf_vlan_info.vlan_proto = ivi.vlan_proto;
+
 	vf_tx_rate.rate = ivi.max_tx_rate;
 	vf_rate.min_tx_rate = ivi.min_tx_rate;
 	vf_rate.max_tx_rate = ivi.max_tx_rate;
@@ -1161,6 +1169,8 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 		return -EMSGSIZE;
 	}
 	if (nla_put(skb, IFLA_VF_MAC, sizeof(vf_mac), &vf_mac) ||
+	    nla_put(skb, IFLA_VF_VLAN_INFO, sizeof(vf_vlan_info),
+		    &vf_vlan_info) ||
 	    nla_put(skb, IFLA_VF_VLAN, sizeof(vf_vlan), &vf_vlan) ||
 	    nla_put(skb, IFLA_VF_RATE, sizeof(vf_rate),
 		    &vf_rate) ||
@@ -1446,6 +1456,7 @@ static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
 static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 	[IFLA_VF_MAC]		= { .len = sizeof(struct ifla_vf_mac) },
 	[IFLA_VF_VLAN]		= { .len = sizeof(struct ifla_vf_vlan) },
+	[IFLA_VF_VLAN_INFO]	= { .len = sizeof(struct ifla_vf_vlan_info) },
 	[IFLA_VF_TX_RATE]	= { .len = sizeof(struct ifla_vf_tx_rate) },
 	[IFLA_VF_SPOOFCHK]	= { .len = sizeof(struct ifla_vf_spoofchk) },
 	[IFLA_VF_RATE]		= { .len = sizeof(struct ifla_vf_rate) },
@@ -1702,7 +1713,20 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
 		err = -EOPNOTSUPP;
 		if (ops->ndo_set_vf_vlan)
 			err = ops->ndo_set_vf_vlan(dev, ivv->vf, ivv->vlan,
-						   ivv->qos);
+						   ivv->qos,
+						   htons(ETH_P_8021Q));
+		if (err < 0)
+			return err;
+	}
+
+	if (tb[IFLA_VF_VLAN_INFO]) {
+		struct ifla_vf_vlan_info *ivv = nla_data(tb[IFLA_VF_VLAN_INFO]);
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_vlan)
+			err = ops->ndo_set_vf_vlan(dev, ivv->vf, ivv->vlan,
+						   ivv->qos,
+						   ivv->vlan_proto);
 		if (err < 0)
 			return err;
 	}
-- 
1.8.3.1
