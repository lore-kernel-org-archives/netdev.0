From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH] net:v4: Add support to configure SR-IOV VF minimum and maximum Tx rate through ip tool.
Date: Wed, 14 May 2014 01:55:06 -0400
Message-ID: <1400046906-13929-2-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1400046906-13929-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Dept-HSGLinuxNICDev@qlogic.com>, <ben@decadent.org.uk>,
	<gregory.v.rose@intel.com>, <linux-net-drivers@solarflare.com>,
	<Ariel.Elior@qlogic.com>, <amirv@mellanox.com>, <mkubecek@suse.cz>,
	<stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:11665 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750871AbaENGY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 02:24:27 -0400
In-Reply-To: <1400046906-13929-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o min_tx_rate puts lower limit on the VF bandwidth. VF is guaranteed
  to have a bandwidth of at least this value.
  max_tx_rate puts cap on the VF bandwidth. VF can have a bandwidth
  of up to this value.

o A new handler set_vf_rate for attr IFLA_VF_RATE has been introduced
  which takes 4 arguments:
  netdev, VF number, min_tx_rate, max_tx_rate

o ndo_set_vf_rate replaces ndo_set_vf_tx_rate handler.

o Drivers that currently implement ndo_set_vf_tx_rate should now call
  ndo_set_vf_rate instead and reject attempt to set a minimum bandwidth
  greater than 0 for IFLA_VF_TX_RATE when IFLA_VF_RATE is not yet
  implemented by driver.

o If user enters only one of either min_tx_rate or max_tx_rate, then,
  userland should read back the other value from driver and set both
  for IFLA_VF_RATE.
  Drivers that have not yet implemented IFLA_VF_RATE should always
  return min_tx_rate as 0 when read from ip tool.

o If both IFLA_VF_TX_RATE and IFLA_VF_RATE options are specified, then
  IFLA_VF_RATE should override.

o Idea is to have consistent display of rate values to user.

o Usage example: -

  ./ip link set p4p1 vf 0 rate 900

  ./ip link show p4p1
  32: p4p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
  DEFAULT qlen 1000
    link/ether 00:0e:1e:08:b0:f0 brd ff:ff:ff:ff:ff:ff
    vf 0 MAC 3e:a0:ca:bd:ae:5a, tx rate 900 (Mbps), max_tx_rate 900Mbps
    vf 1 MAC f6:c6:7c:3f:3d:6c
    vf 2 MAC 56:32:43:98:d7:71
    vf 3 MAC d6:be:c3:b5:85:ff
    vf 4 MAC ee:a9:9a:1e:19:14
    vf 5 MAC 4a:d0:4c:07:52:18
    vf 6 MAC 3a:76:44:93:62:f9
    vf 7 MAC 82:e9:e7:e3:15:1a

  ./ip link set p4p1 vf 0 max_tx_rate 300 min_tx_rate 200

  ./ip link show p4p1
  32: p4p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
  DEFAULT qlen 1000
    link/ether 00:0e:1e:08:b0:f0 brd ff:ff:ff:ff:ff:ff
    vf 0 MAC 3e:a0:ca:bd:ae:5a, tx rate 300 (Mbps), max_tx_rate 300Mbps,
    min_tx_rate 200Mbps
    vf 1 MAC f6:c6:7c:3f:3d:6c
    vf 2 MAC 56:32:43:98:d7:71
    vf 3 MAC d6:be:c3:b5:85:ff
    vf 4 MAC ee:a9:9a:1e:19:14
    vf 5 MAC 4a:d0:4c:07:52:18
    vf 6 MAC 3a:76:44:93:62:f9
    vf 7 MAC 82:e9:e7:e3:15:1a

  ./ip link set p4p1 vf 0 max_tx_rate 600 rate 300

  ./ip link show p4p1
  32: p4p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
  DEFAULT qlen 1000
    link/ether 00:0e:1e:08:b0:f brd ff:ff:ff:ff:ff:ff
    vf 0 MAC 3e:a0:ca:bd:ae:5, tx rate 600 (Mbps), max_tx_rate 600Mbps,
    min_tx_rate 200Mbps
    vf 1 MAC f6:c6:7c:3f:3d:6c
    vf 2 MAC 56:32:43:98:d7:71
    vf 3 MAC d6:be:c3:b5:85:ff
    vf 4 MAC ee:a9:9a:1e:19:14
    vf 5 MAC 4a:d0:4c:07:52:18
    vf 6 MAC 3a:76:44:93:62:f9
    vf 7 MAC 82:e9:e7:e3:15:1a

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |    3 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |   20 +++++---
 drivers/net/ethernet/intel/i40e/i40e_main.c        |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |    6 ++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |    3 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |   20 +++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |   13 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |    3 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   11 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    2 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   52 ++++++++++++++------
 drivers/net/ethernet/sfc/siena_sriov.c             |    3 +-
 include/linux/if_link.h                            |    3 +-
 include/linux/netdevice.h                          |    8 ++-
 include/uapi/linux/if_link.h                       |    9 +++-
 net/core/rtnetlink.c                               |   38 ++++++++++++--
 20 files changed, 142 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 5c523b3..fcaee7e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2551,7 +2551,8 @@ int bnx2x_get_vf_config(struct net_device *dev, int vfidx,
 
 	ivi->vf = vfidx;
 	ivi->qos = 0;
-	ivi->tx_rate = 10000; /* always 10G. TBA take from link struct */
+	ivi->max_tx_rate = 10000; /* always 10G. TBA take from link struct */
+	ivi->min_tx_rate = 0;
 	ivi->spoofchk = 1; /*always enabled */
 	if (vf->state == VF_ENABLED) {
 		/* mac and vlan are in vlan_mac objects */
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3e6df47..e500b4e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1307,7 +1307,8 @@ static int be_get_vf_config(struct net_device *netdev, int vf,
 		return -EINVAL;
 
 	vi->vf = vf;
-	vi->tx_rate = vf_cfg->tx_rate;
+	vi->max_tx_rate = vf_cfg->tx_rate;
+	vi->min_tx_rate = 0;
 	vi->vlan = vf_cfg->vlan_tag & VLAN_VID_MASK;
 	vi->qos = vf_cfg->vlan_tag >> VLAN_PRIO_SHIFT;
 	memcpy(&vi->mac, vf_cfg->mac_addr, ETH_ALEN);
@@ -1348,8 +1349,8 @@ static int be_set_vf_vlan(struct net_device *netdev,
 	return status;
 }
 
-static int be_set_vf_tx_rate(struct net_device *netdev,
-			int vf, int rate)
+static int be_set_vf_tx_rate(struct net_device *netdev, int vf,
+			     int min_tx_rate, int max_tx_rate)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status = 0;
@@ -1360,18 +1361,21 @@ static int be_set_vf_tx_rate(struct net_device *netdev,
 	if (vf >= adapter->num_vfs)
 		return -EINVAL;
 
-	if (rate < 100 || rate > 10000) {
+	if (min_tx_rate)
+		return -EINVAL;
+
+	if (max_tx_rate < 100 || max_tx_rate > 10000) {
 		dev_err(&adapter->pdev->dev,
 			"tx rate must be between 100 and 10000 Mbps\n");
 		return -EINVAL;
 	}
 
-	status = be_cmd_config_qos(adapter, rate / 10, vf + 1);
+	status = be_cmd_config_qos(adapter, max_tx_rate / 10, vf + 1);
 	if (status)
 		dev_err(&adapter->pdev->dev,
-				"tx rate %d on VF %d failed\n", rate, vf);
+			"max tx rate %d on VF %d failed\n", max_tx_rate, vf);
 	else
-		adapter->vf_cfg[vf].tx_rate = rate;
+		adapter->vf_cfg[vf].tx_rate = max_tx_rate;
 	return status;
 }
 static int be_set_vf_link_state(struct net_device *netdev, int vf,
@@ -4245,7 +4249,7 @@ static const struct net_device_ops be_netdev_ops = {
 	.ndo_vlan_rx_kill_vid	= be_vlan_rem_vid,
 	.ndo_set_vf_mac		= be_set_vf_mac,
 	.ndo_set_vf_vlan	= be_set_vf_vlan,
-	.ndo_set_vf_tx_rate	= be_set_vf_tx_rate,
+	.ndo_set_vf_rate	= be_set_vf_tx_rate,
 	.ndo_get_vf_config	= be_get_vf_config,
 	.ndo_set_vf_link_state  = be_set_vf_link_state,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 861b722..8b219d8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6664,7 +6664,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_set_features	= i40e_set_features,
 	.ndo_set_vf_mac		= i40e_ndo_set_vf_mac,
 	.ndo_set_vf_vlan	= i40e_ndo_set_vf_port_vlan,
-	.ndo_set_vf_tx_rate	= i40e_ndo_set_vf_bw,
+	.ndo_set_vf_rate	= i40e_ndo_set_vf_bw,
 	.ndo_get_vf_config	= i40e_ndo_get_vf_config,
 	.ndo_set_vf_link_state	= i40e_ndo_set_vf_link_state,
 #ifdef CONFIG_I40E_VXLAN
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 02c11a7..5bececa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2158,7 +2158,8 @@ error_pvid:
  *
  * configure vf tx rate
  **/
-int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int tx_rate)
+int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
+		       int max_tx_rate)
 {
 	return -EOPNOTSUPP;
 }
@@ -2200,7 +2201,8 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 
 	memcpy(&ivi->mac, vf->default_lan_addr.addr, ETH_ALEN);
 
-	ivi->tx_rate = 0;
+	ivi->max_tx_rate = 0;
+	ivi->min_tx_rate = 0;
 	ivi->vlan = le16_to_cpu(vsi->info.pvid) & I40E_VLAN_MASK;
 	ivi->qos = (le16_to_cpu(vsi->info.pvid) & I40E_PRIORITY_MASK) >>
 		   I40E_VLAN_PRIORITY_SHIFT;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 389c47f..9a71212 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -115,7 +115,8 @@ void i40e_vc_notify_vf_reset(struct i40e_vf *vf);
 int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac);
 int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 			      int vf_id, u16 vlan_id, u8 qos);
-int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int tx_rate);
+int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
+		       int max_tx_rate);
 int i40e_ndo_get_vf_config(struct net_device *netdev,
 			   int vf_id, struct ifla_vf_info *ivi);
 int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 3019818..3e90a33 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -172,7 +172,7 @@ static void igb_restore_vf_multicasts(struct igb_adapter *adapter);
 static int igb_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac);
 static int igb_ndo_set_vf_vlan(struct net_device *netdev,
 			       int vf, u16 vlan, u8 qos);
-static int igb_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate);
+static int igb_ndo_set_vf_bw(struct net_device *, int, int, int);
 static int igb_ndo_set_vf_spoofchk(struct net_device *netdev, int vf,
 				   bool setting);
 static int igb_ndo_get_vf_config(struct net_device *netdev, int vf,
@@ -2087,7 +2087,7 @@ static const struct net_device_ops igb_netdev_ops = {
 	.ndo_vlan_rx_kill_vid	= igb_vlan_rx_kill_vid,
 	.ndo_set_vf_mac		= igb_ndo_set_vf_mac,
 	.ndo_set_vf_vlan	= igb_ndo_set_vf_vlan,
-	.ndo_set_vf_tx_rate	= igb_ndo_set_vf_bw,
+	.ndo_set_vf_rate	= igb_ndo_set_vf_bw,
 	.ndo_set_vf_spoofchk	= igb_ndo_set_vf_spoofchk,
 	.ndo_get_vf_config	= igb_ndo_get_vf_config,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -7870,7 +7870,8 @@ static void igb_check_vf_rate_limit(struct igb_adapter *adapter)
 	}
 }
 
-static int igb_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate)
+static int igb_ndo_set_vf_bw(struct net_device *netdev, int vf,
+			     int min_tx_rate, int max_tx_rate)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -7879,15 +7880,19 @@ static int igb_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate)
 	if (hw->mac.type != e1000_82576)
 		return -EOPNOTSUPP;
 
+	if (min_tx_rate)
+		return -EINVAL;
+
 	actual_link_speed = igb_link_mbps(adapter->link_speed);
 	if ((vf >= adapter->vfs_allocated_count) ||
 	    (!(rd32(E1000_STATUS) & E1000_STATUS_LU)) ||
-	    (tx_rate < 0) || (tx_rate > actual_link_speed))
+	    (max_tx_rate < 0) ||
+	    (max_tx_rate > actual_link_speed))
 		return -EINVAL;
 
 	adapter->vf_rate_link_speed = actual_link_speed;
-	adapter->vf_data[vf].tx_rate = (u16)tx_rate;
-	igb_set_vf_rate_limit(hw, vf, tx_rate, actual_link_speed);
+	adapter->vf_data[vf].tx_rate = (u16)max_tx_rate;
+	igb_set_vf_rate_limit(hw, vf, max_tx_rate, actual_link_speed);
 
 	return 0;
 }
@@ -7927,7 +7932,8 @@ static int igb_ndo_get_vf_config(struct net_device *netdev,
 		return -EINVAL;
 	ivi->vf = vf;
 	memcpy(&ivi->mac, adapter->vf_data[vf].vf_mac_addresses, ETH_ALEN);
-	ivi->tx_rate = adapter->vf_data[vf].tx_rate;
+	ivi->max_tx_rate = adapter->vf_data[vf].tx_rate;
+	ivi->min_tx_rate = 0;
 	ivi->vlan = adapter->vf_data[vf].pf_vlan;
 	ivi->qos = adapter->vf_data[vf].pf_qos;
 	ivi->spoofchk = adapter->vf_data[vf].spoofchk_enabled;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8436c65..61d48fa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7782,7 +7782,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_do_ioctl		= ixgbe_ioctl,
 	.ndo_set_vf_mac		= ixgbe_ndo_set_vf_mac,
 	.ndo_set_vf_vlan	= ixgbe_ndo_set_vf_vlan,
-	.ndo_set_vf_tx_rate	= ixgbe_ndo_set_vf_bw,
+	.ndo_set_vf_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_set_vf_spoofchk	= ixgbe_ndo_set_vf_spoofchk,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index e6c68d3..b014087 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1231,7 +1231,8 @@ void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter)
 	}
 }
 
-int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate)
+int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int min_tx_rate,
+			int max_tx_rate)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int link_speed;
@@ -1249,13 +1250,16 @@ int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate)
 	if (link_speed != 10000)
 		return -EINVAL;
 
+	if (min_tx_rate)
+		return -EINVAL;
+
 	/* rate limit cannot be less than 10Mbs or greater than link speed */
-	if (tx_rate && ((tx_rate <= 10) || (tx_rate > link_speed)))
+	if (max_tx_rate && ((max_tx_rate <= 10) || (max_tx_rate > link_speed)))
 		return -EINVAL;
 
 	/* store values */
 	adapter->vf_rate_link_speed = link_speed;
-	adapter->vfinfo[vf].tx_rate = tx_rate;
+	adapter->vfinfo[vf].tx_rate = max_tx_rate;
 
 	/* update hardware configuration */
 	ixgbe_set_vf_rate_limit(adapter, vf);
@@ -1297,7 +1301,8 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 		return -EINVAL;
 	ivi->vf = vf;
 	memcpy(&ivi->mac, adapter->vfinfo[vf].vf_mac_addresses, ETH_ALEN);
-	ivi->tx_rate = adapter->vfinfo[vf].tx_rate;
+	ivi->max_tx_rate = adapter->vfinfo[vf].tx_rate;
+	ivi->min_tx_rate = 0;
 	ivi->vlan = adapter->vfinfo[vf].pf_vlan;
 	ivi->qos = adapter->vfinfo[vf].pf_qos;
 	ivi->spoofchk = adapter->vfinfo[vf].spoofchk_enabled;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 139eadd..3adc6a4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -42,7 +42,8 @@ void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter);
 int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int queue, u8 *mac);
 int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int queue, u16 vlan,
 			   u8 qos);
-int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate);
+int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int min_tx_rate,
+			int max_tx_rate);
 int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi);
diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 78099ea..c3f59c0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2481,11 +2481,12 @@ int mlx4_get_vf_config(struct mlx4_dev *dev, int port, int vf, struct ifla_vf_in
 	ivf->mac[4] = ((s_info->mac >> (1*8)) & 0xff);
 	ivf->mac[5] = ((s_info->mac)  & 0xff);
 
-	ivf->vlan	= s_info->default_vlan;
-	ivf->qos	= s_info->default_qos;
-	ivf->tx_rate	= s_info->tx_rate;
-	ivf->spoofchk	= s_info->spoofchk;
-	ivf->linkstate	= s_info->link_state;
+	ivf->vlan		= s_info->default_vlan;
+	ivf->qos		= s_info->default_qos;
+	ivf->max_tx_rate	= s_info->tx_rate;
+	ivf->min_tx_rate	= 0;
+	ivf->spoofchk		= s_info->spoofchk;
+	ivf->linkstate		= s_info->link_state;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index f31bb5e..9166c8b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1315,6 +1315,7 @@ struct qlcnic_eswitch {
 #define QL_STATUS_INVALID_PARAM	-1
 
 #define MAX_BW			100	/* % of link speed */
+#define MIN_BW			1	/* % of link speed */
 #define MAX_VLAN_ID		4095
 #define MIN_VLAN_ID		2
 #define DEFAULT_MAC_LEARN	1
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 309d056..a891e53 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -522,7 +522,7 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 #endif
 #ifdef CONFIG_QLCNIC_SRIOV
 	.ndo_set_vf_mac		= qlcnic_sriov_set_vf_mac,
-	.ndo_set_vf_tx_rate	= qlcnic_sriov_set_vf_tx_rate,
+	.ndo_set_vf_rate	= qlcnic_sriov_set_vf_tx_rate,
 	.ndo_get_vf_config	= qlcnic_sriov_get_vf_config,
 	.ndo_set_vf_vlan	= qlcnic_sriov_set_vf_vlan,
 	.ndo_set_vf_spoofchk	= qlcnic_sriov_set_vf_spoofchk,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
index 396bd1f..c38ac4c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
@@ -231,7 +231,7 @@ bool qlcnic_sriov_soft_flr_check(struct qlcnic_adapter *,
 void qlcnic_sriov_pf_reset(struct qlcnic_adapter *);
 int qlcnic_sriov_pf_reinit(struct qlcnic_adapter *);
 int qlcnic_sriov_set_vf_mac(struct net_device *, int, u8 *);
-int qlcnic_sriov_set_vf_tx_rate(struct net_device *, int, int);
+int qlcnic_sriov_set_vf_tx_rate(struct net_device *, int, int, int);
 int qlcnic_sriov_get_vf_config(struct net_device *, int ,
 			       struct ifla_vf_info *);
 int qlcnic_sriov_set_vf_vlan(struct net_device *, int, u16, u8);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 0638c18..2304848 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -198,6 +198,7 @@ int qlcnic_sriov_init(struct qlcnic_adapter *adapter, int num_vfs)
 			}
 			sriov->vf_info[i].vp = vp;
 			vp->max_tx_bw = MAX_BW;
+			vp->min_tx_bw = MIN_BW;
 			vp->spoofchk = true;
 			random_ether_addr(vp->mac);
 			dev_info(&adapter->pdev->dev,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 14f748c..c490475 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -1805,7 +1805,8 @@ int qlcnic_sriov_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	return 0;
 }
 
-int qlcnic_sriov_set_vf_tx_rate(struct net_device *netdev, int vf, int tx_rate)
+int qlcnic_sriov_set_vf_tx_rate(struct net_device *netdev, int vf,
+				int min_tx_rate, int max_tx_rate)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
@@ -1820,35 +1821,52 @@ int qlcnic_sriov_set_vf_tx_rate(struct net_device *netdev, int vf, int tx_rate)
 	if (vf >= sriov->num_vfs)
 		return -EINVAL;
 
-	if (tx_rate >= 10000 || tx_rate < 100) {
+	vf_info = &sriov->vf_info[vf];
+	vp = vf_info->vp;
+	vpid = vp->handle;
+
+	if (!min_tx_rate)
+		min_tx_rate = QLC_VF_MIN_TX_RATE;
+
+	if (max_tx_rate &&
+	    (max_tx_rate >= 10000 || max_tx_rate < min_tx_rate)) {
 		netdev_err(netdev,
-			   "Invalid Tx rate, allowed range is [%d - %d]",
-			   QLC_VF_MIN_TX_RATE, QLC_VF_MAX_TX_RATE);
+			   "Invalid max Tx rate, allowed range is [%d - %d]",
+			   min_tx_rate, QLC_VF_MAX_TX_RATE);
 		return -EINVAL;
 	}
 
-	if (tx_rate == 0)
-		tx_rate = 10000;
+	if (!max_tx_rate)
+		max_tx_rate = 10000;
 
-	vf_info = &sriov->vf_info[vf];
-	vp = vf_info->vp;
-	vpid = vp->handle;
+	if (min_tx_rate &&
+	    (min_tx_rate > max_tx_rate || min_tx_rate < QLC_VF_MIN_TX_RATE)) {
+		netdev_err(netdev,
+			   "Invalid min Tx rate, allowed range is [%d - %d]",
+			   QLC_VF_MIN_TX_RATE, max_tx_rate);
+		return -EINVAL;
+	}
 
 	if (test_bit(QLC_BC_VF_STATE, &vf_info->state)) {
 		if (qlcnic_sriov_get_vf_vport_info(adapter, &nic_info, vpid))
 			return -EIO;
 
-		nic_info.max_tx_bw = tx_rate / 100;
+		nic_info.max_tx_bw = max_tx_rate / 100;
+		nic_info.min_tx_bw = min_tx_rate / 100;
 		nic_info.bit_offsets = BIT_0;
 
 		if (qlcnic_sriov_pf_set_vport_info(adapter, &nic_info, vpid))
 			return -EIO;
 	}
 
-	vp->max_tx_bw = tx_rate / 100;
+	vp->max_tx_bw = max_tx_rate / 100;
+	netdev_info(netdev,
+		    "Setting Max Tx rate %d (Mbps), %d %% of PF bandwidth, for VF %d\n",
+		    max_tx_rate, vp->max_tx_bw, vf);
+	vp->min_tx_bw = min_tx_rate / 100;
 	netdev_info(netdev,
-		    "Setting Tx rate %d (Mbps), %d %% of PF bandwidth, for VF %d\n",
-		    tx_rate, vp->max_tx_bw, vf);
+		    "Setting Min Tx rate %d (Mbps), %d %% of PF bandwidth, for VF %d\n",
+		    min_tx_rate, vp->min_tx_bw, vf);
 	return 0;
 }
 
@@ -1947,9 +1965,13 @@ int qlcnic_sriov_get_vf_config(struct net_device *netdev,
 	ivi->qos = vp->qos;
 	ivi->spoofchk = vp->spoofchk;
 	if (vp->max_tx_bw == MAX_BW)
-		ivi->tx_rate = 0;
+		ivi->max_tx_rate = 0;
+	else
+		ivi->max_tx_rate = vp->max_tx_bw * 100;
+	if (vp->min_tx_bw == MIN_BW)
+		ivi->min_tx_rate = 0;
 	else
-		ivi->tx_rate = vp->max_tx_bw * 100;
+		ivi->min_tx_rate = vp->min_tx_bw * 100;
 
 	ivi->vf = vf;
 	return 0;
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 9a9205e..43d2e64 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -1633,7 +1633,8 @@ int efx_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
 
 	ivi->vf = vf_i;
 	ether_addr_copy(ivi->mac, vf->addr.mac_addr);
-	ivi->tx_rate = 0;
+	ivi->max_tx_rate = 0;
+	ivi->min_tx_rate = 0;
 	tci = ntohs(vf->addr.tci);
 	ivi->vlan = tci & VLAN_VID_MASK;
 	ivi->qos = (tci >> VLAN_PRIO_SHIFT) & 0x7;
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index a86784d..119130e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -10,8 +10,9 @@ struct ifla_vf_info {
 	__u8 mac[32];
 	__u32 vlan;
 	__u32 qos;
-	__u32 tx_rate;
 	__u32 spoofchk;
 	__u32 linkstate;
+	__u32 min_tx_rate;
+	__u32 max_tx_rate;
 };
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 775cc95..07dfef4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -846,7 +846,8 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	SR-IOV management functions.
  * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
  * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
- * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
+ * int (*ndo_set_vf_rate)(struct net_device *dev, int vf, int min_tx_rate,
+ *			  int max_tx_rate);
  * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
@@ -1040,8 +1041,9 @@ struct net_device_ops {
 						  int queue, u8 *mac);
 	int			(*ndo_set_vf_vlan)(struct net_device *dev,
 						   int queue, u16 vlan, u8 qos);
-	int			(*ndo_set_vf_tx_rate)(struct net_device *dev,
-						      int vf, int rate);
+	int			(*ndo_set_vf_rate)(struct net_device *dev,
+						   int vf, int min_tx_rate,
+						   int max_tx_rate);
 	int			(*ndo_set_vf_spoofchk)(struct net_device *dev,
 						       int vf, bool setting);
 	int			(*ndo_get_vf_config)(struct net_device *dev,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 9a7f7ac..622e791 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -399,9 +399,10 @@ enum {
 	IFLA_VF_UNSPEC,
 	IFLA_VF_MAC,		/* Hardware queue specific attributes */
 	IFLA_VF_VLAN,
-	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
+	IFLA_VF_TX_RATE,	/* Max TX Bandwidth Allocation */
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
 	IFLA_VF_LINK_STATE,	/* link state enable/disable/auto switch */
+	IFLA_VF_RATE,		/* Min and Max TX Bandwidth Allocation */
 	__IFLA_VF_MAX,
 };
 
@@ -423,6 +424,12 @@ struct ifla_vf_tx_rate {
 	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
 };
 
+struct ifla_vf_rate {
+	__u32 vf;
+	__u32 min_tx_rate; /* Min Bandwidth in Mbps */
+	__u32 max_tx_rate; /* Max Bandwidth in Mbps */
+};
+
 struct ifla_vf_spoofchk {
 	__u32 vf;
 	__u32 setting;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d4ff417..fa693eb 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -767,8 +767,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 		size += num_vfs *
 			(nla_total_size(sizeof(struct ifla_vf_mac)) +
 			 nla_total_size(sizeof(struct ifla_vf_vlan)) +
-			 nla_total_size(sizeof(struct ifla_vf_tx_rate)) +
-			 nla_total_size(sizeof(struct ifla_vf_spoofchk)));
+			 nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
+			 nla_total_size(sizeof(struct ifla_vf_rate)));
 		return size;
 	} else
 		return 0;
@@ -1030,6 +1030,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_info ivi;
 			struct ifla_vf_mac vf_mac;
 			struct ifla_vf_vlan vf_vlan;
+			struct ifla_vf_rate vf_rate;
 			struct ifla_vf_tx_rate vf_tx_rate;
 			struct ifla_vf_spoofchk vf_spoofchk;
 			struct ifla_vf_link_state vf_linkstate;
@@ -1050,6 +1051,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				break;
 			vf_mac.vf =
 				vf_vlan.vf =
+				vf_rate.vf =
 				vf_tx_rate.vf =
 				vf_spoofchk.vf =
 				vf_linkstate.vf = ivi.vf;
@@ -1057,7 +1059,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
 			vf_vlan.vlan = ivi.vlan;
 			vf_vlan.qos = ivi.qos;
-			vf_tx_rate.rate = ivi.tx_rate;
+			vf_tx_rate.rate = ivi.max_tx_rate;
+			vf_rate.min_tx_rate = ivi.min_tx_rate;
+			vf_rate.max_tx_rate = ivi.max_tx_rate;
 			vf_spoofchk.setting = ivi.spoofchk;
 			vf_linkstate.link_state = ivi.linkstate;
 			vf = nla_nest_start(skb, IFLA_VF_INFO);
@@ -1067,6 +1071,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			}
 			if (nla_put(skb, IFLA_VF_MAC, sizeof(vf_mac), &vf_mac) ||
 			    nla_put(skb, IFLA_VF_VLAN, sizeof(vf_vlan), &vf_vlan) ||
+			    nla_put(skb, IFLA_VF_RATE, sizeof(vf_rate),
+				    &vf_rate) ||
 			    nla_put(skb, IFLA_VF_TX_RATE, sizeof(vf_tx_rate),
 				    &vf_tx_rate) ||
 			    nla_put(skb, IFLA_VF_SPOOFCHK, sizeof(vf_spoofchk),
@@ -1173,6 +1179,8 @@ static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 				    .len = sizeof(struct ifla_vf_tx_rate) },
 	[IFLA_VF_SPOOFCHK]	= { .type = NLA_BINARY,
 				    .len = sizeof(struct ifla_vf_spoofchk) },
+	[IFLA_VF_RATE]		= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_vf_rate) },
 };
 
 static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
@@ -1325,11 +1333,29 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 		}
 		case IFLA_VF_TX_RATE: {
 			struct ifla_vf_tx_rate *ivt;
+			struct ifla_vf_info ivf;
 			ivt = nla_data(vf);
 			err = -EOPNOTSUPP;
-			if (ops->ndo_set_vf_tx_rate)
-				err = ops->ndo_set_vf_tx_rate(dev, ivt->vf,
-							      ivt->rate);
+			if (ops->ndo_get_vf_config)
+				err = ops->ndo_get_vf_config(dev, ivt->vf,
+							     &ivf);
+			if (err)
+				break;
+			err = -EOPNOTSUPP;
+			if (ops->ndo_set_vf_rate)
+				err = ops->ndo_set_vf_rate(dev, ivt->vf,
+							   ivf.min_tx_rate,
+							   ivt->rate);
+			break;
+		}
+		case IFLA_VF_RATE: {
+			struct ifla_vf_rate *ivt;
+			ivt = nla_data(vf);
+			err = -EOPNOTSUPP;
+			if (ops->ndo_set_vf_rate)
+				err = ops->ndo_set_vf_rate(dev, ivt->vf,
+							   ivt->min_tx_rate,
+							   ivt->max_tx_rate);
 			break;
 		}
 		case IFLA_VF_SPOOFCHK: {
-- 
1.6.3.3
