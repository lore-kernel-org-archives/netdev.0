From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH v5] ixgbe: Add module parameter to disable VLAN filter
Date: Thu, 21 May 2015 13:10:49 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05EB460C@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "sy.jong.choi@intel.com" <sy.jong.choi@intel.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: ja-JP
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

Introduce module parameter "disable_hw_vlan_filter" to disable HW VLAN
filter on ixgbe module load.

>From the hardware limitation, there are only 64 VLAN entries for HW VLAN
filter, and it leads to limit the number of VLANs up to 64 among PF and
VFs. For SDN/NFV case, we need to handle unlimited VLAN packets on VF.
In such case, every VLAN packet can be transmitted to each VF.

When we try to make VLAN devices on VF, the 65th VLAN registration fails
and never be able to receive a packet with that VLAN tag.
If we do the below command on VM, ethX.65 to ethX.100 cannot be created.
  # for i in `seq 1 100`; do \
    ip link add link ethX name ethX.$i type vlan id $i; done

There is a capability to disable HW VLAN filter and that makes all VLAN
tagged packets can be transmitted to every VFs. After VLAN filter stage,
unicast packets are transmitted to VF which has the MAC address same as
the transmitting packet.

With this patch and "disable_hw_vlan_filter=1", we can use unlimited
number of VLANs on VF.

Disabling HW VLAN filter breaks some NIC features such as DCB and FCoE.
DCB and FCoE are disabled when HW VLAN filter is disabled by this module
parameter.
Because of that reason, the administrator has to know that before turning
off HW VLAN filter.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 29 +++++++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  4 ++++
 3 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 5181a4d..492615d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -632,6 +632,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 21)
 #define IXGBE_FLAG_SRIOV_CAPABLE                (u32)(1 << 22)
 #define IXGBE_FLAG_SRIOV_ENABLED                (u32)(1 << 23)
+#define IXGBE_FLAG_VLAN_FILTER_ENABLED          (u32)(1 << 24)
 
 	u32 flags2;
 #define IXGBE_FLAG2_RSC_CAPABLE                 (u32)(1 << 0)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 263cb40..b45570f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -158,6 +158,10 @@ module_param(allow_unsupported_sfp, uint, 0);
 MODULE_PARM_DESC(allow_unsupported_sfp,
 		 "Allow unsupported and untested SFP+ modules on 82599-based adapters");
 
+static unsigned int disable_hw_vlan_filter;
+module_param(disable_hw_vlan_filter, uint, 0);
+MODULE_PARM_DESC(disable_hw_vlan_filter, "Disable HW VLAN filter");
+
 #define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
 static int debug = -1;
 module_param(debug, int, 0);
@@ -4159,6 +4163,9 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		hw->addr_ctrl.user_set_promisc = false;
 	}
 
+	if (!(adapter->flags & IXGBE_FLAG_VLAN_FILTER_ENABLED))
+		vlnctrl &= ~(IXGBE_VLNCTRL_VFE | IXGBE_VLNCTRL_CFIEN);
+
 	/*
 	 * Write addresses to available RAR registers, if there is not
 	 * sufficient space to store all the addresses then enable
@@ -5251,6 +5258,22 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 #endif /* CONFIG_IXGBE_DCB */
 #endif /* IXGBE_FCOE */
 
+	if (likely(!disable_hw_vlan_filter)) {
+		/* HW VLAN filter is enabled by default */
+		adapter->flags |= IXGBE_FLAG_VLAN_FILTER_ENABLED;
+	} else {
+		e_dev_warn("Disabling HW VLAN filter. "
+			   "DCB and FCoE are also disabled.\n");
+#ifdef IXGBE_FCOE
+		/* Disabling FCoE */
+		adapter->flags &= ~IXGBE_FLAG_FCOE_CAPABLE;
+		adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
+#ifdef CONFIG_IXGBE_DCB
+		adapter->fcoe.up = 0;
+#endif /* CONFIG_IXGBE_DCB */
+#endif /* IXGBE_FCOE */
+	}
+
 	adapter->mac_table = kzalloc(sizeof(struct ixgbe_mac_addr) *
 				     hw->mac.num_rar_entries,
 				     GFP_ATOMIC);
@@ -7733,6 +7756,9 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	ixgbe_clear_interrupt_scheme(adapter);
 
 #ifdef CONFIG_IXGBE_DCB
+	/* Unable to use DCB if HW VLAN filter is disabled */
+	if (!(adapter->flags & IXGBE_FLAG_VLAN_FILTER_ENABLED))
+		tc = 0;
 	if (tc) {
 		netdev_set_num_tc(dev, tc);
 		ixgbe_set_prio_tc_map(adapter);
@@ -8562,7 +8588,8 @@ skip_sriov:
 	}
 
 	netdev->hw_features |= NETIF_F_RXALL;
-	netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+	if (adapter->flags & IXGBE_FLAG_VLAN_FILTER_ENABLED)
+		netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 6c602bc..50bbc0d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -862,6 +862,10 @@ static int ixgbe_set_vf_vlan_msg(struct ixgbe_adapter *adapter,
 		return -1;
 	}
 
+	/* If we disabled HW VLAN filter, nothing to do */
+	if (!(adapter->flags & IXGBE_FLAG_VLAN_FILTER_ENABLED))
+		return 0;
+
 	if (add)
 		adapter->vfinfo[vf].vlan_count++;
 	else if (adapter->vfinfo[vf].vlan_count)
-- 
1.8.3.1
