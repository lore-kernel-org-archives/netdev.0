From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 1/3] net: Add provision to specify pf number while assigning VF mac
Date: Thu, 30 Jun 2016 21:04:42 +0530
Message-ID: <1467300884-32340-2-git-send-email-hariprasad@chelsio.com>
References: <1467300884-32340-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, leedom@chelsio.com,
	kumaras@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:48377 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932435AbcF3PiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 11:38:12 -0400
In-Reply-To: <1467300884-32340-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chelsio T4/T5 cards have SR-IOV Capabilities on Physical Functions
0..3 and the administrative Driver(cxgb4) attaches to Physical Function 4.
Each of the Physical Functions 0..3 can support up to 16 Virtual
Functions. With the current Linux APIs, a 2-Port card would only be
able to use the Virtual Functions on Physical Functions 0..1 and not
allow the Virtual Functions on Physical Functions 2..3 to be used since
there are no Ports 2..3 on a 2-Port card.

Also the current ip commands takes netdev as one of the argument, and
it assumes a 1-to-1 mapping of Network Ports, Physical Functions and the
SR-IOV Virtual Functions of those Physical Functions. But it is not
true in our case and won't work for us.

Added a new argument to specify the PF number associated with the VF, to
fix this.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |    2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c    |    2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h    |    2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c        |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |    2 +-
 drivers/net/ethernet/intel/fm10k/fm10k.h           |    3 ++-
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c       |    3 ++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |    6 ++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |    3 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    2 +-
 drivers/net/ethernet/sfc/sriov.c                   |    3 ++-
 drivers/net/ethernet/sfc/sriov.h                   |    3 ++-
 include/linux/netdevice.h                          |    2 +-
 include/uapi/linux/if_link.h                       |    1 +
 net/core/rtnetlink.c                               |    4 ++--
 22 files changed, 32 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 0e68fad..bc8560b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -491,7 +491,7 @@ int __bnx2x_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 
 int bnx2x_get_vf_config(struct net_device *dev, int vf,
 			struct ifla_vf_info *ivi);
-int bnx2x_set_vf_mac(struct net_device *dev, int queue, u8 *mac);
+int bnx2x_set_vf_mac(struct net_device *dev, int pf, int queue, u8 *mac);
 int bnx2x_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos);
 
 /* select_queue callback */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 632daff..2342daa 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2664,7 +2664,7 @@ int bnx2x_get_vf_config(struct net_device *dev, int vfidx,
  * mac configuration request, the PF will simply fail the request and VF can try
  * again after consulting its bulletin board.
  */
-int bnx2x_set_vf_mac(struct net_device *dev, int vfidx, u8 *mac)
+int bnx2x_set_vf_mac(struct net_device *dev, int pf, int vfidx, u8 *mac)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	int rc, q_logical_state;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 50d2007..7d0a318 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -107,7 +107,7 @@ int bnxt_get_vf_config(struct net_device *dev, int vf_id,
 	return 0;
 }
 
-int bnxt_set_vf_mac(struct net_device *dev, int vf_id, u8 *mac)
+int bnxt_set_vf_mac(struct net_device *dev, int pf, int vf_id, u8 *mac)
 {
 	struct hwrm_func_cfg_input req = {0};
 	struct bnxt *bp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
index 0392670..a44e7b2 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
@@ -11,7 +11,7 @@
 #define BNXT_SRIOV_H
 
 int bnxt_get_vf_config(struct net_device *, int, struct ifla_vf_info *);
-int bnxt_set_vf_mac(struct net_device *, int, u8 *);
+int bnxt_set_vf_mac(struct net_device *, int, int, u8 *);
 int bnxt_set_vf_vlan(struct net_device *, int, u16, u8);
 int bnxt_set_vf_bw(struct net_device *, int, int, int);
 int bnxt_set_vf_link_state(struct net_device *, int, int);
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index f15560a..7d70eb9 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -877,7 +877,7 @@ static void enic_tx_timeout(struct net_device *netdev)
 	schedule_work(&enic->tx_hang_reset);
 }
 
-static int enic_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
+static int enic_set_vf_mac(struct net_device *netdev, int pf, int vf, u8 *mac)
 {
 	struct enic *enic = netdev_priv(netdev);
 	struct enic_port_profile *pp;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2451a47..b6d9d25 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1581,7 +1581,7 @@ static void be_set_rx_mode(struct net_device *netdev)
 	be_set_mc_list(adapter);
 }
 
-static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
+static int be_set_vf_mac(struct net_device *netdev, int pf, int vf, u8 *mac)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct be_vf_cfg *vf_cfg = &adapter->vf_cfg[vf];
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index fcf106e..9b4f62b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -505,7 +505,8 @@ int fm10k_iov_resume(struct pci_dev *pdev);
 void fm10k_iov_disable(struct pci_dev *pdev);
 int fm10k_iov_configure(struct pci_dev *pdev, int num_vfs);
 s32 fm10k_iov_update_pvid(struct fm10k_intfc *interface, u16 glort, u16 pvid);
-int fm10k_ndo_set_vf_mac(struct net_device *netdev, int vf_idx, u8 *mac);
+int fm10k_ndo_set_vf_mac(struct net_device *netdev, int pf,
+			 int vf_idx, u8 *mac);
 int fm10k_ndo_set_vf_vlan(struct net_device *netdev,
 			  int vf_idx, u16 vid, u8 qos);
 int fm10k_ndo_set_vf_bw(struct net_device *netdev, int vf_idx, int rate,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index 47f0743..060a543 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -421,7 +421,8 @@ static inline void fm10k_reset_vf_info(struct fm10k_intfc *interface,
 	fm10k_mbx_unlock(interface);
 }
 
-int fm10k_ndo_set_vf_mac(struct net_device *netdev, int vf_idx, u8 *mac)
+int fm10k_ndo_set_vf_mac(struct net_device *netdev, int pf,
+			 int vf_idx, u8 *mac)
 {
 	struct fm10k_intfc *interface = netdev_priv(netdev);
 	struct fm10k_iov_data *iov_data = interface->iov_data;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 1fcafcf..1d6b289 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2661,7 +2661,7 @@ int i40e_vc_process_vflr_event(struct i40e_pf *pf)
  *
  * program VF mac address
  **/
-int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
+int i40e_ndo_set_vf_mac(struct net_device *netdev, int pf, int vf_id, u8 *mac)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 8751741..9ff6bf3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -128,7 +128,7 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr);
 void i40e_vc_notify_vf_reset(struct i40e_vf *vf);
 
 /* VF configuration related iplink handlers */
-int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac);
+int i40e_ndo_set_vf_mac(struct net_device *netdev, int pf, int vf_id, u8 *mac);
 int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 			      int vf_id, u16 vlan_id, u8 qos);
 int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ef3d642..3b2af00 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -167,7 +167,8 @@ static void igb_msg_task(struct igb_adapter *);
 static void igb_vmm_control(struct igb_adapter *);
 static int igb_set_vf_mac(struct igb_adapter *, int, unsigned char *);
 static void igb_restore_vf_multicasts(struct igb_adapter *adapter);
-static int igb_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac);
+static int igb_ndo_set_vf_mac(struct net_device *netdev,
+			      int pf, int vf, u8 *mac);
 static int igb_ndo_set_vf_vlan(struct net_device *netdev,
 			       int vf, u16 vlan, u8 qos);
 static int igb_ndo_set_vf_bw(struct net_device *, int, int, int);
@@ -7942,7 +7943,8 @@ static int igb_set_vf_mac(struct igb_adapter *adapter,
 	return 0;
 }
 
-static int igb_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
+static int igb_ndo_set_vf_mac(struct net_device *netdev,
+			      int pf, int vf, u8 *mac)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	if (!is_valid_ether_addr(mac) || (vf >= adapter->vfs_allocated_count))
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index c5caacd..2a39e6e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1277,7 +1277,7 @@ void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter)
 	}
 }
 
-int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
+int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int pf, int vf, u8 *mac)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	if (!is_valid_ether_addr(mac) || (vf >= adapter->num_vfs))
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 47e65e2..eaafbd3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -41,7 +41,8 @@ void ixgbe_msg_task(struct ixgbe_adapter *adapter);
 int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask);
 void ixgbe_disable_tx_rx(struct ixgbe_adapter *adapter);
 void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter);
-int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int queue, u8 *mac);
+int ixgbe_ndo_set_vf_mac(struct net_device *netdev,
+			 int pf, int queue, u8 *mac);
 int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int queue, u16 vlan,
 			   u8 qos);
 int ixgbe_link_mbps(struct ixgbe_adapter *adapter);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 973391b..acf1b70 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2259,7 +2259,8 @@ static int mlx4_en_set_features(struct net_device *netdev,
 	return 0;
 }
 
-static int mlx4_en_set_vf_mac(struct net_device *dev, int queue, u8 *mac)
+static int mlx4_en_set_vf_mac(struct net_device *dev,
+			      int pf, int queue, u8 *mac)
 {
 	struct mlx4_en_priv *en_priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = en_priv->mdev;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f5c8d5d..7ae99bd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2431,7 +2431,7 @@ static int mlx5e_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	}
 }
 
-static int mlx5e_set_vf_mac(struct net_device *dev, int vf, u8 *mac)
+static int mlx5e_set_vf_mac(struct net_device *dev, int pf, int vf, u8 *mac)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5_core_dev *mdev = priv->mdev;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
index 017d8c2c..ef39d70 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
@@ -233,7 +233,7 @@ bool qlcnic_sriov_soft_flr_check(struct qlcnic_adapter *,
 				 struct qlcnic_vf_info *);
 void qlcnic_sriov_pf_reset(struct qlcnic_adapter *);
 int qlcnic_sriov_pf_reinit(struct qlcnic_adapter *);
-int qlcnic_sriov_set_vf_mac(struct net_device *, int, u8 *);
+int qlcnic_sriov_set_vf_mac(struct net_device *, int, int, u8 *);
 int qlcnic_sriov_set_vf_tx_rate(struct net_device *, int, int, int);
 int qlcnic_sriov_get_vf_config(struct net_device *, int ,
 			       struct ifla_vf_info *);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index afd687e..d7cc7a7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -1802,7 +1802,7 @@ int qlcnic_sriov_pf_reinit(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-int qlcnic_sriov_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
+int qlcnic_sriov_set_vf_mac(struct net_device *netdev, int pf, int vf, u8 *mac)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
diff --git a/drivers/net/ethernet/sfc/sriov.c b/drivers/net/ethernet/sfc/sriov.c
index 816c446..d20edd0 100644
--- a/drivers/net/ethernet/sfc/sriov.c
+++ b/drivers/net/ethernet/sfc/sriov.c
@@ -11,7 +11,8 @@
 #include "nic.h"
 #include "sriov.h"
 
-int efx_sriov_set_vf_mac(struct net_device *net_dev, int vf_i, u8 *mac)
+int efx_sriov_set_vf_mac(struct net_device *net_dev,
+			 int pf, int vf_i, u8 *mac)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
diff --git a/drivers/net/ethernet/sfc/sriov.h b/drivers/net/ethernet/sfc/sriov.h
index 400df52..a8c8b7b 100644
--- a/drivers/net/ethernet/sfc/sriov.h
+++ b/drivers/net/ethernet/sfc/sriov.h
@@ -14,7 +14,8 @@
 
 #ifdef CONFIG_SFC_SRIOV
 
-int efx_sriov_set_vf_mac(struct net_device *net_dev, int vf_i, u8 *mac);
+int efx_sriov_set_vf_mac(struct net_device *net_dev,
+			 int pf, int vf_i, u8 *mac);
 int efx_sriov_set_vf_vlan(struct net_device *net_dev, int vf_i, u16 vlan,
 			  u8 qos);
 int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf_i,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 890158e..78c14bf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1148,7 +1148,7 @@ struct net_device_ops {
 	int			(*ndo_busy_poll)(struct napi_struct *dev);
 #endif
 	int			(*ndo_set_vf_mac)(struct net_device *dev,
-						  int queue, u8 *mac);
+						  int pf, int queue, u8 *mac);
 	int			(*ndo_set_vf_vlan)(struct net_device *dev,
 						   int queue, u16 vlan, u8 qos);
 	int			(*ndo_set_vf_rate)(struct net_device *dev,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index bb36bd5..bc9ef4e 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -633,6 +633,7 @@ enum {
 #define IFLA_VF_MAX (__IFLA_VF_MAX - 1)
 
 struct ifla_vf_mac {
+	__u32 pf;
 	__u32 vf;
 	__u8 mac[32]; /* MAX_ADDR_LEN */
 };
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index eb49ca2..b75b15c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1643,8 +1643,8 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
 
 		err = -EOPNOTSUPP;
 		if (ops->ndo_set_vf_mac)
-			err = ops->ndo_set_vf_mac(dev, ivm->vf,
-						  ivm->mac);
+			err = ops->ndo_set_vf_mac(dev, ivm->pf,
+						  ivm->vf, ivm->mac);
 		if (err < 0)
 			return err;
 	}
-- 
1.7.3
