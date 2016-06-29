From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 01/10] liquidio: Vxlan support
Date: Tue, 28 Jun 2016 17:54:23 -0700
Message-ID: <1467161672-21063-2-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0059.outbound.protection.outlook.com ([207.46.100.59]:46448
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752449AbcF2AzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 20:55:07 -0400
In-Reply-To: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for Vxaln offloads in liquidio driver.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |  29 +++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 233 ++++++++++++++++++++-
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  12 ++
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |   3 +
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |   1 +
 .../net/ethernet/cavium/liquidio/octeon_network.h  |   8 +
 6 files changed, 278 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 03bfa97..a060586 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -106,6 +106,7 @@ static const char oct_stats_strings[][ETH_GSTRING_LEN] = {
 	"tx_tso",
 	"tx_tso_packets",
 	"tx_tso_err",
+	"tx_vxlan",
 
 	"mac_tx_total_pkts",
 	"mac_tx_total_bytes",
@@ -129,6 +130,9 @@ static const char oct_stats_strings[][ETH_GSTRING_LEN] = {
 	"rx_err_link",
 	"rx_err_drop",
 
+	"rx_vxlan",
+	"rx_vxlan_err",
+
 	"rx_lro_pkts",
 	"rx_lro_bytes",
 	"rx_total_lro",
@@ -167,6 +171,7 @@ static const char oct_iq_stats_strings[][ETH_GSTRING_LEN] = {
 	"fw_bytes_sent",
 
 	"tso",
+	"vxlan",
 	"txq_restart",
 };
 
@@ -186,6 +191,7 @@ static const char oct_droq_stats_strings[][ETH_GSTRING_LEN] = {
 	"fw_bytes_received",
 	"fw_dropped_nodispatch",
 
+	"vxlan",
 	"buffer_alloc_failure",
 };
 
@@ -675,6 +681,10 @@ lio_get_ethtool_stats(struct net_device *netdev,
 	 *fw_err_tso
 	 */
 	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_err_tso);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
+	 *fw_tx_vxlan
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_tx_vxlan);
 
 	/* mac tx statistics */
 	/*CVMX_BGXX_CMRX_TX_STAT5 */
@@ -729,6 +739,15 @@ lio_get_ethtool_stats(struct net_device *netdev,
 	 */
 	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_err_drop);
 
+	/*per_core_stats[cvmx_get_core_num()].link_stats[lro_ctx->ifidx].
+	 *fromwire.fw_rx_vxlan
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_rx_vxlan);
+	/*per_core_stats[cvmx_get_core_num()].link_stats[lro_ctx->ifidx].
+	 *fromwire.fw_rx_vxlan_err
+	 */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromwire.fw_rx_vxlan_err);
+
 	/* LRO */
 	/*per_core_stats[cvmx_get_core_num()].link_stats[ifidx].fromwire.
 	 *fw_lro_pkts
@@ -822,6 +841,8 @@ lio_get_ethtool_stats(struct net_device *netdev,
 
 		/*tso request*/
 		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_gso);
+		/*vxlan request*/
+		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_vxlan);
 		/*txq restart*/
 		data[i++] =
 			CVM_CAST64(oct_dev->instr_queue[j]->stats.tx_restart);
@@ -858,6 +879,9 @@ lio_get_ethtool_stats(struct net_device *netdev,
 			CVM_CAST64(oct_dev->droq[j]->stats.bytes_received);
 		data[i++] =
 			CVM_CAST64(oct_dev->droq[j]->stats.dropped_nodispatch);
+
+		data[i++] =
+			CVM_CAST64(oct_dev->droq[j]->stats.rx_vxlan);
 		data[i++] =
 			CVM_CAST64(oct_dev->droq[j]->stats.rx_alloc_failure);
 	}
@@ -1083,6 +1107,9 @@ octnet_nic_stats_callback(struct octeon_device *oct_dev,
 		rstats->fw_err_pko = rsp_rstats->fw_err_pko;
 		rstats->fw_err_link = rsp_rstats->fw_err_link;
 		rstats->fw_err_drop = rsp_rstats->fw_err_drop;
+		rstats->fw_rx_vxlan = rsp_rstats->fw_rx_vxlan;
+		rstats->fw_rx_vxlan_err = rsp_rstats->fw_rx_vxlan_err;
+
 		/* Number of packets that are LROed      */
 		rstats->fw_lro_pkts = rsp_rstats->fw_lro_pkts;
 		/* Number of octets that are LROed       */
@@ -1127,6 +1154,8 @@ octnet_nic_stats_callback(struct octeon_device *oct_dev,
 		tstats->fw_tso = rsp_tstats->fw_tso;
 		tstats->fw_tso_fwd = rsp_tstats->fw_tso_fwd;
 		tstats->fw_err_tso = rsp_tstats->fw_err_tso;
+		tstats->fw_tx_vxlan = rsp_tstats->fw_tx_vxlan;
+
 		resp->status = 1;
 	} else {
 		resp->status = -1;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 1a584eb..9530df8 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2001,12 +2001,31 @@ liquidio_push_packet(u32 octeon_id,
 
 		skb->protocol = eth_type_trans(skb, skb->dev);
 
+#ifdef CONFIG_VXLAN
 		if ((netdev->features & NETIF_F_RXCSUM) &&
-		    (rh->r_dh.csum_verified == CNNIC_CSUM_VERIFIED))
-			/* checksum has already been verified */
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
-		else
-			skb->ip_summed = CHECKSUM_NONE;
+		    (((rh->r_dh.encap_on) &&
+		      (rh->r_dh.csum_verified & CNNIC_TUN_CSUM_VERIFIED)) ||
+		     (!(rh->r_dh.encap_on) &&
+		      (rh->r_dh.csum_verified & CNNIC_CSUM_VERIFIED))))
+#else
+			if ((netdev->features & NETIF_F_RXCSUM) &&
+			    (rh->r_dh.csum_verified & CNNIC_CSUM_VERIFIED))
+#endif
+				/* checksum has already been verified */
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+			else
+				skb->ip_summed = CHECKSUM_NONE;
+
+#ifdef CONFIG_VXLAN
+		/* Setting Encapsulation field on basis of status received
+		 * from the firmware
+		 */
+		if (rh->r_dh.encap_on) {
+			skb->encapsulation = 1;
+			skb->csum_level = 1;
+			droq->stats.rx_vxlan++;
+		}
+#endif
 
 		/* inbound VLAN tag */
 		if ((netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
@@ -2411,6 +2430,58 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 
 		break;
 
+#ifdef CONFIG_VXLAN
+		/* Case to handle "OCTNET_CMD_TNL_RX_CSUM_CTL"
+		 * Command passed by NIC driver
+		 */
+	case OCTNET_CMD_TNL_RX_CSUM_CTL:
+		if (nctrl->ncmd.s.param1 == OCTNET_CMD_RXCSUM_ENABLE) {
+			netif_info(lio, probe, lio->netdev,
+				   "%s RX Checksum Offload Enabled\n",
+				   netdev->name);
+		} else if (nctrl->ncmd.s.param1 ==
+			   OCTNET_CMD_RXCSUM_DISABLE) {
+			netif_info(lio, probe, lio->netdev,
+				   "%s RX Checksum Offload Disabled\n",
+				   netdev->name);
+		}
+		break;
+
+		/* Case to handle "OCTNET_CMD_TNL_TX_CSUM_CTL"
+		 * Command passed by NIC driver
+		 */
+	case OCTNET_CMD_TNL_TX_CSUM_CTL:
+		if (nctrl->ncmd.s.param1 == OCTNET_CMD_TXCSUM_ENABLE) {
+			netif_info(lio, probe, lio->netdev,
+				   "%s TX Checksum Offload Enabled\n",
+				   netdev->name);
+		} else if (nctrl->ncmd.s.param1 ==
+			   OCTNET_CMD_TXCSUM_DISABLE) {
+			netif_info(lio, probe, lio->netdev,
+				   "%s TX Checksum Offload Disabled\n",
+				   netdev->name);
+		}
+		break;
+
+		/* Case to handle "OCTNET_CMD_VXLAN_PORT_CONFIG"
+		 * Command passed by NIC driver
+		 */
+	case OCTNET_CMD_VXLAN_PORT_CONFIG:
+		if (nctrl->ncmd.s.more == OCTNET_CMD_VXLAN_PORT_ADD) {
+			netif_info(lio, probe, lio->netdev,
+				   "%s VxLAN Destination UDP PORT:%d ADDED\n",
+				   netdev->name,
+				   nctrl->ncmd.s.param1);
+		} else if (nctrl->ncmd.s.more ==
+			   OCTNET_CMD_VXLAN_PORT_DEL) {
+			netif_info(lio, probe, lio->netdev,
+				   "%s VxLAN Destination UDP PORT:%d DELETED\n",
+				   netdev->name,
+				   nctrl->ncmd.s.param1);
+		}
+		break;
+#endif
+
 	case OCTNET_CMD_SET_FLOW_CTL:
 		netif_info(lio, probe, lio->netdev, "Set RX/TX flow control parameters\n");
 		break;
@@ -2899,9 +2970,15 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	cmdsetup.u64 = 0;
 	cmdsetup.s.iq_no = iq_no;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		cmdsetup.s.transport_csum = 1;
-
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+#ifdef CONFIG_VXLAN
+		if (skb->encapsulation) {
+			cmdsetup.s.tnl_csum = 1;
+			stats->tx_vxlan++;
+		} else
+#endif
+			cmdsetup.s.transport_csum = 1;
+	}
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		cmdsetup.s.timestamp = 1;
@@ -3124,6 +3201,74 @@ static int liquidio_vlan_rx_kill_vid(struct net_device *netdev,
 	return ret;
 }
 
+#ifdef CONFIG_VXLAN
+/** Sending command to enable/disable RX checksum offload
+ * @param netdev                pointer to network device
+ * @param command               OCTNET_CMD_TNL_RX_CSUM_CTL
+ * @param rx_cmd_bit            OCTNET_CMD_RXCSUM_ENABLE/
+ *                              OCTNET_CMD_RXCSUM_DISABLE
+ * @returns                     SUCCESS or FAILURE
+ */
+int liquidio_set_rxcsum_command(struct net_device *netdev, int command,
+				u8 rx_cmd)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = command;
+	nctrl.ncmd.s.param1 = rx_cmd;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev,
+			"DEVFLAGS RXCSUM change failed in core(ret:0x%x)\n",
+			ret);
+	}
+	return ret;
+}
+
+/** Sending command to add/delete VxLAN UDP port to firmware
+ * @param netdev                pointer to network device
+ * @param command               OCTNET_CMD_VXLAN_PORT_CONFIG
+ * @param vxlan_port            VxLAN port to be added or deleted
+ * @param vxlan_cmd_bit         OCTNET_CMD_VXLAN_PORT_ADD,
+ *                              OCTNET_CMD_VXLAN_PORT_DEL
+ * @returns                     SUCCESS or FAILURE
+ */
+static int liquidio_vxlan_port_command(struct net_device *netdev, int command,
+				       u16 vxlan_port, u8 vxlan_cmd_bit)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = command;
+	nctrl.ncmd.s.more = vxlan_cmd_bit;
+	nctrl.ncmd.s.param1 = vxlan_port;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev,
+			"VxLAN port add/delete failed in core (ret:0x%x)\n",
+			ret);
+	}
+	return ret;
+}
+#endif
+
 int liquidio_set_feature(struct net_device *netdev, int cmd, u16 param1)
 {
 	struct lio *lio = GET_LIO(netdev);
@@ -3204,9 +3349,48 @@ static int liquidio_set_features(struct net_device *netdev,
 		liquidio_set_feature(netdev, OCTNET_CMD_LRO_DISABLE,
 				     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 
+	/* Sending command to firmware to enable/disable RX checksum
+	 * offload settings using ethtool
+	 */
+#ifdef CONFIG_VXLAN
+	if (!(netdev->features & NETIF_F_RXCSUM) &&
+	    (lio->enc_dev_capability & NETIF_F_RXCSUM) &&
+	    (features & NETIF_F_RXCSUM))
+		liquidio_set_rxcsum_command(netdev,
+					    OCTNET_CMD_TNL_RX_CSUM_CTL,
+					    OCTNET_CMD_RXCSUM_ENABLE);
+	else if ((netdev->features & NETIF_F_RXCSUM) &&
+		 (lio->enc_dev_capability & NETIF_F_RXCSUM) &&
+		 !(features & NETIF_F_RXCSUM))
+		liquidio_set_rxcsum_command(netdev, OCTNET_CMD_TNL_RX_CSUM_CTL,
+					    OCTNET_CMD_RXCSUM_DISABLE);
+#endif
+
 	return 0;
 }
 
+#ifdef CONFIG_VXLAN
+static void liquidio_add_vxlan_port(struct net_device *netdev,
+				    sa_family_t sa_family
+				    __attribute__((unused)), __be16 port)
+{
+	liquidio_vxlan_port_command(netdev,
+				    OCTNET_CMD_VXLAN_PORT_CONFIG,
+				    htons(port),
+				    OCTNET_CMD_VXLAN_PORT_ADD);
+}
+
+static void liquidio_del_vxlan_port(struct net_device *netdev,
+				    sa_family_t sa_family
+				    __attribute__((unused)), __be16 port)
+{
+	liquidio_vxlan_port_command(netdev,
+				    OCTNET_CMD_VXLAN_PORT_CONFIG,
+				    htons(port),
+				    OCTNET_CMD_VXLAN_PORT_DEL);
+}
+#endif
+
 static struct net_device_ops lionetdevops = {
 	.ndo_open		= liquidio_open,
 	.ndo_stop		= liquidio_stop,
@@ -3222,6 +3406,10 @@ static struct net_device_ops lionetdevops = {
 	.ndo_do_ioctl		= liquidio_ioctl,
 	.ndo_fix_features	= liquidio_fix_features,
 	.ndo_set_features	= liquidio_set_features,
+#ifdef CONFIG_VXLAN
+	.ndo_add_vxlan_port	= liquidio_add_vxlan_port,
+	.ndo_del_vxlan_port	= liquidio_del_vxlan_port,
+#endif
 };
 
 /** \brief Entry point for the liquidio module
@@ -3479,6 +3667,24 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 				| NETIF_F_LRO;
 		netif_set_gso_max_size(netdev, OCTNIC_GSO_MAX_SIZE);
 
+#ifdef CONFIG_VXLAN
+		/*  Copy of transmit encapsulation capabilities:
+		 *  TSO, TSO6, Checksums for this device
+		 */
+		lio->enc_dev_capability = NETIF_F_IP_CSUM
+					  | NETIF_F_IPV6_CSUM
+					  | NETIF_F_GSO_UDP_TUNNEL
+					  | NETIF_F_HW_CSUM | NETIF_F_SG
+					  | NETIF_F_RXCSUM
+					  | NETIF_F_TSO | NETIF_F_TSO6
+					  | NETIF_F_LRO;
+
+		netdev->hw_enc_features = (lio->enc_dev_capability &
+					   ~NETIF_F_LRO);
+
+		lio->dev_capability |= NETIF_F_GSO_UDP_TUNNEL;
+#endif
+
 		netdev->vlan_features = lio->dev_capability;
 		/* Add any unchangeable hw features */
 		lio->dev_capability |=  NETIF_F_HW_VLAN_CTAG_FILTER |
@@ -3561,6 +3767,17 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		ifstate_set(lio, LIO_IFSTATE_REGISTERED);
 
+#ifdef CONFIG_VXLAN
+		/* Sending command to firmware to enable Rx checksum offload
+		 * by default at the time of setup of Liquidio driver for
+		 * this device
+		 */
+		liquidio_set_rxcsum_command(netdev, OCTNET_CMD_TNL_RX_CSUM_CTL,
+					    OCTNET_CMD_RXCSUM_ENABLE);
+		liquidio_set_feature(netdev, OCTNET_CMD_TNL_TX_CSUM_CTL,
+				     OCTNET_CMD_TXCSUM_ENABLE);
+#endif
+
 		dev_dbg(&octeon_dev->pci_dev->dev,
 			"NIC ifidx:%d Setup successful\n", i);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 5aa01f4..c6e3d57 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -216,6 +216,13 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 #define   OCTNET_CMD_ENABLE_VLAN_FILTER 0x16
 #define   OCTNET_CMD_ADD_VLAN_FILTER  0x17
 #define   OCTNET_CMD_DEL_VLAN_FILTER  0x18
+#define   OCTNET_CMD_VXLAN_PORT_CONFIG 0x19
+#define   OCTNET_CMD_VXLAN_PORT_ADD    0x0
+#define   OCTNET_CMD_VXLAN_PORT_DEL    0x1
+#define   OCTNET_CMD_RXCSUM_ENABLE     0x0
+#define   OCTNET_CMD_RXCSUM_DISABLE    0x1
+#define   OCTNET_CMD_TXCSUM_ENABLE     0x0
+#define   OCTNET_CMD_TXCSUM_DISABLE    0x1
 
 /* RX(packets coming from wire) Checksum verification flags */
 /* TCP/UDP csum */
@@ -533,6 +540,7 @@ union octeon_rh {
 		u64 priority:3;
 		u64 csum_verified:3;     /** checksum verified. */
 		u64 has_hwtstamp:1;      /** Has hardware timestamp. 1 = yes. */
+		u64 encap_on:1;
 	} r_dh;
 	struct {
 		u64 opcode:4;
@@ -562,6 +570,7 @@ union octeon_rh {
 		u64 opcode:4;
 	} r;
 	struct {
+		u64 encap_on:1;
 		u64 has_hwtstamp:1;      /** 1 = has hwtstamp */
 		u64 csum_verified:3;     /** checksum verified. */
 		u64 priority:3;
@@ -736,6 +745,8 @@ struct nic_rx_stats {
 	u64 fw_err_pko;
 	u64 fw_err_link;
 	u64 fw_err_drop;
+	u64 fw_rx_vxlan;
+	u64 fw_rx_vxlan_err;
 
 	/* LRO */
 	u64 fw_lro_pkts;   /* Number of packets that are LROed      */
@@ -776,6 +787,7 @@ struct nic_tx_stats {
 	u64 fw_err_tso;
 	u64 fw_tso;		/* number of tso requests */
 	u64 fw_tso_fwd;		/* number of packets segmented in tso */
+	u64 fw_tx_vxlan;
 };
 
 struct oct_link_stats {
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
index 1ca9c4f..886772c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
@@ -121,6 +121,9 @@ struct oct_droq_stats {
 	/** Num of Packets dropped due to receive path failures. */
 	u64 rx_dropped;
 
+	/** Num of vxlan packets received; */
+	u64 rx_vxlan;
+
 	/** Num of failures of recv_buffer_alloc() */
 	u64 rx_alloc_failure;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index caa2b4f..5ac7e66 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -66,6 +66,7 @@ struct oct_iq_stats {
 	u64 tx_dropped;/**< Numof pkts dropped dueto xmitpath errors. */
 	u64 tx_tot_bytes;/**< Total count of bytes sento to network. */
 	u64 tx_gso;  /* count of tso */
+	u64 tx_vxlan; /* tunnel */
 	u64 tx_dmamap_fail;
 	u64 tx_restart;
 	/*u64 tx_timeout_count;*/
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index b481edc..d0581e6 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -96,6 +96,14 @@ struct lio {
 	/** Copy of Interface capabilities: TSO, TSO6, LRO, Chescksums . */
 	u64 dev_capability;
 
+#ifdef CONFIG_VXLAN
+	/* Copy of transmit encapsulation capabilities:
+	 * TSO, TSO6, Checksums for this device for Kernel
+	 * 3.10.0 onwards
+	 */
+	u64 enc_dev_capability;
+#endif
+
 	/** Copy of beacaon reg in phy */
 	u32 phy_beacon_val;
 
-- 
1.8.3.1
