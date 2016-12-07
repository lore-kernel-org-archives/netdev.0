From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 3/7] liquidio CN23XX: VF mac address
Date: Wed, 7 Dec 2016 08:54:33 -0800
Message-ID: <1481129677-10586-4-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1481129677-10586-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0084.outbound.protection.outlook.com ([104.47.37.84]:43712
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932685AbcLGQzG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 11:55:06 -0500
In-Reply-To: <1481129677-10586-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for configuring mtu, multicast and mac address.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 195 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/liquidio_common.h |   1 +
 .../net/ethernet/cavium/liquidio/octeon_network.h  |   1 +
 3 files changed, 197 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 07e4864..6f23944 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -864,6 +864,194 @@ static int liquidio_stop(struct net_device *netdev)
 	return 0;
 }
 
+/**
+ * \brief Converts a mask based on net device flags
+ * @param netdev network device
+ *
+ * This routine generates a octnet_ifflags mask from the net device flags
+ * received from the OS.
+ */
+static enum octnet_ifflags get_new_flags(struct net_device *netdev)
+{
+	enum octnet_ifflags f = OCTNET_IFFLAG_UNICAST;
+
+	if (netdev->flags & IFF_PROMISC)
+		f |= OCTNET_IFFLAG_PROMISC;
+
+	if (netdev->flags & IFF_ALLMULTI)
+		f |= OCTNET_IFFLAG_ALLMULTI;
+
+	if (netdev->flags & IFF_MULTICAST) {
+		f |= OCTNET_IFFLAG_MULTICAST;
+
+		/* Accept all multicast addresses if there are more than we
+		 * can handle
+		 */
+		if (netdev_mc_count(netdev) > MAX_OCTEON_MULTICAST_ADDR)
+			f |= OCTNET_IFFLAG_ALLMULTI;
+	}
+
+	if (netdev->flags & IFF_BROADCAST)
+		f |= OCTNET_IFFLAG_BROADCAST;
+
+	return f;
+}
+
+static void liquidio_set_uc_list(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	struct netdev_hw_addr *ha;
+	u64 *mac;
+
+	if (lio->netdev_uc_count == netdev_uc_count(netdev))
+		return;
+
+	if (netdev_uc_count(netdev) > MAX_NCTRL_UDD) {
+		dev_err(&oct->pci_dev->dev, "too many MAC addresses in netdev uc list\n");
+		return;
+	}
+
+	lio->netdev_uc_count = netdev_uc_count(netdev);
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+	nctrl.ncmd.s.cmd = OCTNET_CMD_SET_UC_LIST;
+	nctrl.ncmd.s.more = lio->netdev_uc_count;
+	nctrl.ncmd.s.param1 = oct->vf_num;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	/* copy all the addresses into the udd */
+	mac = &nctrl.udd[0];
+	netdev_for_each_uc_addr(ha, netdev) {
+		ether_addr_copy(((u8 *)mac) + 2, ha->addr);
+		mac++;
+	}
+
+	octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+}
+
+/**
+ * \brief Net device set_multicast_list
+ * @param netdev network device
+ */
+static void liquidio_set_mcast_list(struct net_device *netdev)
+{
+	int mc_count = min(netdev_mc_count(netdev), MAX_OCTEON_MULTICAST_ADDR);
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	struct netdev_hw_addr *ha;
+	u64 *mc;
+	int ret;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	/* Create a ctrl pkt command to be sent to core app. */
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_SET_MULTI_LIST;
+	nctrl.ncmd.s.param1 = get_new_flags(netdev);
+	nctrl.ncmd.s.param2 = mc_count;
+	nctrl.ncmd.s.more = mc_count;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	/* copy all the addresses into the udd */
+	mc = &nctrl.udd[0];
+	netdev_for_each_mc_addr(ha, netdev) {
+		*mc = 0;
+		ether_addr_copy(((u8 *)mc) + 2, ha->addr);
+		/* no need to swap bytes */
+		if (++mc > &nctrl.udd[mc_count])
+			break;
+	}
+
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+
+	/* Apparently, any activity in this call from the kernel has to
+	 * be atomic. So we won't wait for response.
+	 */
+	nctrl.wait_time = 0;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "DEVFLAGS change failed in core (ret: 0x%x)\n",
+			ret);
+	}
+
+	liquidio_set_uc_list(netdev);
+}
+
+/**
+ * \brief Net device set_mac_address
+ * @param netdev network device
+ */
+static int liquidio_set_mac(struct net_device *netdev, void *p)
+{
+	struct sockaddr *addr = (struct sockaddr *)p;
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	if (ether_addr_equal(addr->sa_data, netdev->dev_addr))
+		return 0;
+
+	if (lio->linfo.macaddr_is_admin_asgnd)
+		return -EPERM;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_CHANGE_MACADDR;
+	nctrl.ncmd.s.param1 = 0;
+	nctrl.ncmd.s.more = 1;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+	nctrl.wait_time = 100;
+
+	nctrl.udd[0] = 0;
+	/* The MAC Address is presented in network byte order. */
+	ether_addr_copy((u8 *)&nctrl.udd[0] + 2, addr->sa_data);
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "MAC Address change failed\n");
+		return -ENOMEM;
+	}
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	ether_addr_copy(((u8 *)&lio->linfo.hw_addr) + 2, addr->sa_data);
+
+	return 0;
+}
+
+/**
+ * \brief Net device change_mtu
+ * @param netdev network device
+ */
+static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	lio->mtu = new_mtu;
+
+	netif_info(lio, probe, lio->netdev, "MTU Changed from %d to %d\n",
+		   netdev->mtu, new_mtu);
+	dev_info(&oct->pci_dev->dev, "%s MTU Changed from %d to %d\n",
+		 netdev->name, netdev->mtu, new_mtu);
+
+	netdev->mtu = new_mtu;
+
+	return 0;
+}
+
 /** Sending command to enable/disable RX checksum offload
  * @param netdev                pointer to network device
  * @param command               OCTNET_CMD_TNL_RX_CSUM_CTL
@@ -966,6 +1154,9 @@ static int liquidio_set_features(struct net_device *netdev,
 static const struct net_device_ops lionetdevops = {
 	.ndo_open		= liquidio_open,
 	.ndo_stop		= liquidio_stop,
+	.ndo_set_mac_address	= liquidio_set_mac,
+	.ndo_set_rx_mode	= liquidio_set_mcast_list,
+	.ndo_change_mtu		= liquidio_change_mtu,
 	.ndo_fix_features	= liquidio_fix_features,
 	.ndo_set_features	= liquidio_set_features,
 	.ndo_select_queue	= select_q,
@@ -1165,6 +1356,10 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		netdev->hw_features = lio->dev_capability;
 
+		/* MTU range: 68 - 16000 */
+		netdev->min_mtu = LIO_MIN_MTU_SIZE;
+		netdev->max_mtu = LIO_MAX_MTU_SIZE;
+
 		/* Point to the  properties for octeon device to which this
 		 * interface belongs.
 		 */
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index f308ee4..ba329f6 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -212,6 +212,7 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 
 #define   OCTNET_CMD_ID_ACTIVE         0x1a
 
+#define   OCTNET_CMD_SET_UC_LIST       0x1b
 #define   OCTNET_CMD_SET_VF_LINKSTATE  0x1c
 #define   OCTNET_CMD_VXLAN_PORT_ADD    0x0
 #define   OCTNET_CMD_VXLAN_PORT_DEL    0x1
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index e94edc8..6bb8941 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -123,6 +123,7 @@ struct lio {
 	/* work queue for  link status */
 	struct cavium_wq	link_status_wq;
 
+	int netdev_uc_count;
 };
 
 #define LIO_SIZE         (sizeof(struct lio))
-- 
1.8.3.1
