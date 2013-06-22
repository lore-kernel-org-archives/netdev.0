From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH v2 net-next 2/8] qlcnic: Secondary unicast MAC address support.
Date: Sat, 22 Jun 2013 04:12:01 -0400
Message-ID: <1371888727-16422-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1371888727-16422-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0253.outbound.messaging.microsoft.com ([213.199.154.253]:40701
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932333Ab3FVIx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jun 2013 04:53:29 -0400
In-Reply-To: <1371888727-16422-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Add support for configuring secondary unicast address which
will use existing HW filters to store all the unicast MAC
addresses and prevent device going into promiscuous mode.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    8 ++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   17 ++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    3 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   34 +++++++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   43 +++++++++++++++----
 6 files changed, 83 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 534e36e..28a1276 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -426,6 +426,7 @@ struct qlcnic_hardware_context {
 	u8 nic_mode;
 	char diag_cnt;
 
+	u16 max_uc_count;
 	u16 port_type;
 	u16 board_type;
 	u16 supported_type;
@@ -1494,6 +1495,7 @@ netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 int qlcnic_set_max_rss(struct qlcnic_adapter *, u8, size_t);
 int qlcnic_validate_max_rss(struct qlcnic_adapter *, __u32);
 void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
+void qlcnic_82xx_set_mac_filter_count(struct qlcnic_adapter *);
 int qlcnic_enable_msix(struct qlcnic_adapter *, u32);
 
 /*  eSwitch management functions */
@@ -1631,6 +1633,7 @@ struct qlcnic_hardware_ops {
 	int (*config_promisc_mode) (struct qlcnic_adapter *, u32);
 	void (*change_l2_filter) (struct qlcnic_adapter *, u64 *, u16);
 	int (*get_board_info) (struct qlcnic_adapter *);
+	void (*set_mac_filter_count) (struct qlcnic_adapter *);
 	void (*free_mac_list) (struct qlcnic_adapter *);
 };
 
@@ -1846,6 +1849,11 @@ static inline void qlcnic_free_mac_list(struct qlcnic_adapter *adapter)
 	return adapter->ahw->hw_ops->free_mac_list(adapter);
 }
 
+static inline void qlcnic_set_mac_filter_count(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->set_mac_filter_count(adapter);
+}
+
 static inline void qlcnic_dev_request_reset(struct qlcnic_adapter *adapter,
 					    u32 key)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 88e2e23..ab66410 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -172,6 +172,7 @@ static struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
 	.config_promisc_mode		= qlcnic_83xx_nic_set_promisc,
 	.change_l2_filter		= qlcnic_83xx_change_l2_filter,
 	.get_board_info			= qlcnic_83xx_get_port_info,
+	.set_mac_filter_count		= qlcnic_83xx_set_mac_filter_count,
 	.free_mac_list			= qlcnic_82xx_free_mac_list,
 };
 
@@ -609,6 +610,22 @@ int qlcnic_83xx_get_port_info(struct qlcnic_adapter *adapter)
 	return status;
 }
 
+void qlcnic_83xx_set_mac_filter_count(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	u16 act_pci_fn = ahw->act_pci_func;
+	u16 count;
+
+	ahw->max_mc_count = QLC_83XX_MAX_MC_COUNT;
+	if (act_pci_fn <= 2)
+		count = (QLC_83XX_MAX_UC_COUNT - QLC_83XX_MAX_MC_COUNT) /
+			 act_pci_fn;
+	else
+		count = (QLC_83XX_LB_MAX_FILTERS - QLC_83XX_MAX_MC_COUNT) /
+			 act_pci_fn;
+	ahw->max_uc_count = count;
+}
+
 void qlcnic_83xx_enable_mbx_intrpt(struct qlcnic_adapter *adapter)
 {
 	u32 val;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 1bfe283..e821ee4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -393,6 +393,8 @@ enum qlcnic_83xx_states {
 #define QLC_83XX_LB_MAX_FILTERS			2048
 #define QLC_83XX_LB_BUCKET_SIZE			256
 #define QLC_83XX_MINIMUM_VECTOR			3
+#define QLC_83XX_MAX_MC_COUNT			38
+#define QLC_83XX_MAX_UC_COUNT			4096
 
 #define QLC_83XX_GET_FUNC_MODE_FROM_NPAR_INFO(val)	(val & 0x80000000)
 #define QLC_83XX_GET_LRO_CAPABILITY(val)		(val & 0x20)
@@ -624,4 +626,5 @@ u32 qlcnic_83xx_mac_rcode(struct qlcnic_adapter *);
 u32 qlcnic_83xx_mbx_poll(struct qlcnic_adapter *, u32 *);
 void qlcnic_83xx_enable_mbx_poll(struct qlcnic_adapter *);
 void qlcnic_83xx_disable_mbx_poll(struct qlcnic_adapter *);
+void qlcnic_83xx_set_mac_filter_count(struct qlcnic_adapter *);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index c0f0c0d..d262211 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -672,6 +672,7 @@ enum {
 #define QLCNIC_HEARTBEAT_CHECK_RETRY_COUNT	10
 
 #define QLCNIC_MAX_MC_COUNT		38
+#define QLCNIC_MAX_UC_COUNT		512
 #define QLCNIC_WATCHDOG_TIMEOUTVALUE	5
 
 #define	ISR_MSI_INT_TRIGGER(FUNC) (QLCNIC_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 218978d..e7f305d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -499,6 +499,7 @@ int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, const u8 *addr, u16 vlan)
 void __qlcnic_set_multi(struct net_device *netdev, u16 vlan)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct netdev_hw_addr *ha;
 	static const u8 bcast_addr[ETH_ALEN] = {
 		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
@@ -515,25 +516,30 @@ void __qlcnic_set_multi(struct net_device *netdev, u16 vlan)
 	if (netdev->flags & IFF_PROMISC) {
 		if (!(adapter->flags & QLCNIC_PROMISC_DISABLED))
 			mode = VPORT_MISS_MODE_ACCEPT_ALL;
-		goto send_fw_cmd;
-	}
-
-	if ((netdev->flags & IFF_ALLMULTI) ||
-	    (netdev_mc_count(netdev) > adapter->ahw->max_mc_count)) {
-		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
-		goto send_fw_cmd;
+	} else if (netdev->flags & IFF_ALLMULTI) {
+		if (netdev_mc_count(netdev) > ahw->max_mc_count) {
+			mode = VPORT_MISS_MODE_ACCEPT_MULTI;
+		} else if (!netdev_mc_empty(netdev) &&
+			   !qlcnic_sriov_vf_check(adapter)) {
+				netdev_for_each_mc_addr(ha, netdev)
+					qlcnic_nic_add_mac(adapter, ha->addr,
+							   vlan);
+		}
+		if (mode != VPORT_MISS_MODE_ACCEPT_MULTI &&
+		    qlcnic_sriov_vf_check(adapter))
+			qlcnic_vf_add_mc_list(netdev, vlan);
 	}
 
-	if (!netdev_mc_empty(netdev) && !qlcnic_sriov_vf_check(adapter)) {
-		netdev_for_each_mc_addr(ha, netdev) {
+	/* configure unicast MAC address, if there is not sufficient space
+	 * to store all the unicast addresses then enable promiscuous mode
+	 */
+	if (netdev_uc_count(netdev) > ahw->max_uc_count) {
+		mode = VPORT_MISS_MODE_ACCEPT_ALL;
+	} else if (!netdev_uc_empty(netdev)) {
+		netdev_for_each_uc_addr(ha, netdev)
 			qlcnic_nic_add_mac(adapter, ha->addr, vlan);
-		}
 	}
 
-	if (qlcnic_sriov_vf_check(adapter))
-		qlcnic_vf_add_mc_list(netdev, vlan);
-
-send_fw_cmd:
 	if (!qlcnic_sriov_vf_check(adapter)) {
 		if (mode == VPORT_MISS_MODE_ACCEPT_ALL &&
 		    !adapter->fdb_mac_learn) {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 0ae8835..8e1453a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -360,12 +360,15 @@ static int qlcnic_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 		return ndo_dflt_fdb_del(ndm, tb, netdev, addr);
 
 	if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
-		if (is_unicast_ether_addr(addr))
-			err = qlcnic_nic_del_mac(adapter, addr);
-		else if (is_multicast_ether_addr(addr))
+		if (is_unicast_ether_addr(addr)) {
+			err = dev_uc_del(netdev, addr);
+			if (!err)
+				err = qlcnic_nic_del_mac(adapter, addr);
+		} else if (is_multicast_ether_addr(addr)) {
 			err = dev_mc_del(netdev, addr);
-		else
+		} else {
 			err =  -EINVAL;
+		}
 	}
 	return err;
 }
@@ -388,12 +391,16 @@ static int qlcnic_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (ether_addr_equal(addr, adapter->mac_addr))
 		return err;
 
-	if (is_unicast_ether_addr(addr))
-		err = qlcnic_nic_add_mac(adapter, addr, 0);
-	else if (is_multicast_ether_addr(addr))
+	if (is_unicast_ether_addr(addr)) {
+		if (netdev_uc_count(netdev) < adapter->ahw->max_uc_count)
+			err = dev_uc_add_excl(netdev, addr);
+		else
+			err = -ENOMEM;
+	} else if (is_multicast_ether_addr(addr)) {
 		err = dev_mc_add_excl(netdev, addr);
-	else
+	} else {
 		err = -EINVAL;
+	}
 
 	return err;
 }
@@ -505,6 +512,7 @@ static struct qlcnic_hardware_ops qlcnic_hw_ops = {
 	.config_promisc_mode		= qlcnic_82xx_nic_set_promisc,
 	.change_l2_filter		= qlcnic_82xx_change_filter,
 	.get_board_info			= qlcnic_82xx_get_board_info,
+	.set_mac_filter_count		= qlcnic_82xx_set_mac_filter_count,
 	.free_mac_list			= qlcnic_82xx_free_mac_list,
 };
 
@@ -1829,6 +1837,22 @@ qlcnic_reset_context(struct qlcnic_adapter *adapter)
 	return err;
 }
 
+void qlcnic_82xx_set_mac_filter_count(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	u16 act_pci_fn = ahw->act_pci_func;
+	u16 count;
+
+	ahw->max_mc_count = QLCNIC_MAX_MC_COUNT;
+	if (act_pci_fn <= 2)
+		count = (QLCNIC_MAX_UC_COUNT - QLCNIC_MAX_MC_COUNT) /
+			 act_pci_fn;
+	else
+		count = (QLCNIC_LB_MAX_FILTERS - QLCNIC_MAX_MC_COUNT) /
+			 act_pci_fn;
+	ahw->max_uc_count = count;
+}
+
 int
 qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 		    int pci_using_dac)
@@ -1838,7 +1862,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 
 	adapter->rx_csum = 1;
 	adapter->ahw->mc_enabled = 0;
-	adapter->ahw->max_mc_count = QLCNIC_MAX_MC_COUNT;
+	qlcnic_set_mac_filter_count(adapter);
 
 	netdev->netdev_ops	   = &qlcnic_netdev_ops;
 	netdev->watchdog_timeo     = QLCNIC_WATCHDOG_TIMEOUTVALUE * HZ;
@@ -1876,6 +1900,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 		netdev->features |= NETIF_F_LRO;
 
 	netdev->hw_features = netdev->features;
+	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->irq = adapter->msix_entries[0].vector;
 
 	err = register_netdev(netdev);
-- 
1.7.1
