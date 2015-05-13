From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH net-next 3/3] be2net: Support for OS2BMC.
Date: Wed, 13 May 2015 13:00:14 +0530
Message-ID: <1431502214-11810-4-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
References: <1431502214-11810-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:49883 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753402AbbEMHwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 03:52:03 -0400
In-Reply-To: <1431502214-11810-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OS2BMC feature will allow the server to communicate with the on-board
BMC/idrac (Baseboard Management Controller) over the LOM via
standard Ethernet.

When OS2BMC feature is enabled, the LOM will filter traffic coming
from the host. If the destination MAC address matches the iDRAC MAC
address, it will forward the packet to the NC-SI side band interface
for iDRAC processing. Otherwise, it would send it out on the wire to
the external network. Broadcast and multicast packets are sent on the
side-band NC-SI channel and on the wire as well. Some of the packet
filters are not supported in the NIC and hence driver will identify
such packets and will hint the NIC to send those packets to the BMC.
This is done by duplicating packets on the management ring. Packets
are sent to the management ring, by setting mgmt bit in the wrb header.
The NIC will forward the packets on the management ring to the BMC
through the side-band NC-SI channel.

Please refer to this online document for more details,
http://www.dell.com/downloads/global/products/pedge/
os_to_bmc_passthrough_a_new_chapter_in_system_management.pdf

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    8 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.c |   19 ++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |   17 ++++
 drivers/net/ethernet/emulex/benet/be_main.c |  138 +++++++++++++++++++++++++++
 4 files changed, 181 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 63922d4..8d12b41 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -384,6 +384,7 @@ enum vf_state {
 #define BE_FLAGS_SETUP_DONE			BIT(9)
 #define BE_FLAGS_EVT_INCOMPATIBLE_SFP		BIT(10)
 #define BE_FLAGS_ERR_DETECTION_SCHEDULED	BIT(11)
+#define BE_FLAGS_OS2BMC				BIT(12)
 
 #define BE_UC_PMAC_COUNT			30
 #define BE_VF_UC_PMAC_COUNT			2
@@ -428,6 +429,8 @@ struct be_resources {
 	u32 vf_if_cap_flags;	/* VF if capability flags */
 };
 
+#define be_is_os2bmc_enabled(adapter) (adapter->flags & BE_FLAGS_OS2BMC)
+
 struct rss_info {
 	u64 rss_flags;
 	u8 rsstable[RSS_INDIR_TABLE_LEN];
@@ -461,7 +464,8 @@ enum {
 	BE_WRB_F_LSO_BIT,		/* LSO */
 	BE_WRB_F_LSO6_BIT,		/* LSO6 */
 	BE_WRB_F_VLAN_BIT,		/* VLAN */
-	BE_WRB_F_VLAN_SKIP_HW_BIT	/* Skip VLAN tag (workaround) */
+	BE_WRB_F_VLAN_SKIP_HW_BIT,	/* Skip VLAN tag (workaround) */
+	BE_WRB_F_OS2BMC_BIT		/* Send packet to the management ring */
 };
 
 /* The structure below provides a HW-agnostic abstraction of WRB params
@@ -584,6 +588,8 @@ struct be_adapter {
 	struct be_hwmon hwmon_info;
 	u8 pf_number;
 	struct rss_info rss_info;
+	/* Filters for packets that need to be sent to BMC */
+	u32 bmc_filt_mask;
 };
 
 #define be_physfn(adapter)		(!adapter->virtfn)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index dce8786..4115054 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -333,6 +333,21 @@ static void be_async_grp5_pvid_state_process(struct be_adapter *adapter,
 	}
 }
 
+#define MGMT_ENABLE_MASK	0x4
+static void be_async_grp5_fw_control_process(struct be_adapter *adapter,
+					     struct be_mcc_compl *compl)
+{
+	struct be_async_fw_control *evt = (struct be_async_fw_control *)compl;
+	u32 evt_dw1 = le32_to_cpu(evt->event_data_word1);
+
+	if (evt_dw1 & MGMT_ENABLE_MASK) {
+		adapter->flags |= BE_FLAGS_OS2BMC;
+		adapter->bmc_filt_mask = le32_to_cpu(evt->event_data_word2);
+	} else {
+		adapter->flags &= ~BE_FLAGS_OS2BMC;
+	}
+}
+
 static void be_async_grp5_evt_process(struct be_adapter *adapter,
 				      struct be_mcc_compl *compl)
 {
@@ -349,6 +364,10 @@ static void be_async_grp5_evt_process(struct be_adapter *adapter,
 	case ASYNC_EVENT_PVID_STATE:
 		be_async_grp5_pvid_state_process(adapter, compl);
 		break;
+	/* Async event to disable/enable os2bmc and/or mac-learning */
+	case ASYNC_EVENT_FW_CONTROL:
+		be_async_grp5_fw_control_process(adapter, compl);
+		break;
 	default:
 		break;
 	}
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index c713d51..2716e6f 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -105,6 +105,7 @@ struct be_mcc_compl {
 #define ASYNC_DEBUG_EVENT_TYPE_QNQ	1
 #define ASYNC_EVENT_CODE_SLIPORT	0x11
 #define ASYNC_EVENT_PORT_MISCONFIG	0x9
+#define ASYNC_EVENT_FW_CONTROL		0x5
 
 enum {
 	LINK_DOWN	= 0x0,
@@ -181,6 +182,22 @@ struct be_async_event_misconfig_port {
 	u32 flags;
 } __packed;
 
+#define BMC_FILT_BROADCAST_ARP				BIT(0)
+#define BMC_FILT_BROADCAST_DHCP_CLIENT			BIT(1)
+#define BMC_FILT_BROADCAST_DHCP_SERVER			BIT(2)
+#define BMC_FILT_BROADCAST_NET_BIOS			BIT(3)
+#define BMC_FILT_BROADCAST				BIT(7)
+#define BMC_FILT_MULTICAST_IPV6_NEIGH_ADVER		BIT(8)
+#define BMC_FILT_MULTICAST_IPV6_RA			BIT(9)
+#define BMC_FILT_MULTICAST_IPV6_RAS			BIT(10)
+#define BMC_FILT_MULTICAST				BIT(15)
+struct be_async_fw_control {
+	u32 event_data_word1;
+	u32 event_data_word2;
+	u32 evt_tag;
+	u32 event_data_word4;
+} __packed;
+
 struct be_mcc_mailbox {
 	struct be_mcc_wrb wrb;
 	struct be_mcc_compl compl;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 79fca82..dc7c0fd 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -820,6 +820,8 @@ static void wrb_fill_hdr(struct be_adapter *adapter,
 
 	SET_TX_WRB_HDR_BITS(num_wrb, hdr, skb_wrb_cnt(skb));
 	SET_TX_WRB_HDR_BITS(len, hdr, skb->len);
+	SET_TX_WRB_HDR_BITS(mgmt, hdr,
+			    BE_WRB_F_GET(wrb_params->features, OS2BMC));
 }
 
 static void unmap_tx_frag(struct device *dev, struct be_eth_wrb *wrb,
@@ -1156,6 +1158,130 @@ static void be_xmit_flush(struct be_adapter *adapter, struct be_tx_obj *txo)
 	txo->pend_wrb_cnt = 0;
 }
 
+/* OS2BMC related */
+
+#define DHCP_CLIENT_PORT	68
+#define DHCP_SERVER_PORT	67
+#define NET_BIOS_PORT1		137
+#define NET_BIOS_PORT2		138
+#define DHCPV6_RAS_PORT		547
+
+#define is_mc_allowed_on_bmc(adapter, eh)	\
+	(!is_multicast_filt_enabled(adapter) &&	\
+	 is_multicast_ether_addr(eh->h_dest) &&	\
+	 !is_broadcast_ether_addr(eh->h_dest))
+
+#define is_bc_allowed_on_bmc(adapter, eh)	\
+	(!is_broadcast_filt_enabled(adapter) &&	\
+	 is_broadcast_ether_addr(eh->h_dest))
+
+#define is_arp_allowed_on_bmc(adapter, skb)	\
+	(is_arp(skb) && is_arp_filt_enabled(adapter))
+
+#define is_broadcast_packet(eh, adapter)	\
+		(is_multicast_ether_addr(eh->h_dest) && \
+		!compare_ether_addr(eh->h_dest, adapter->netdev->broadcast))
+
+#define is_arp(skb)	(skb->protocol == htons(ETH_P_ARP))
+
+#define is_arp_filt_enabled(adapter)	\
+		(adapter->bmc_filt_mask & (BMC_FILT_BROADCAST_ARP))
+
+#define is_dhcp_client_filt_enabled(adapter)	\
+		(adapter->bmc_filt_mask & BMC_FILT_BROADCAST_DHCP_CLIENT)
+
+#define is_dhcp_srvr_filt_enabled(adapter)	\
+		(adapter->bmc_filt_mask & BMC_FILT_BROADCAST_DHCP_SERVER)
+
+#define is_nbios_filt_enabled(adapter)	\
+		(adapter->bmc_filt_mask & BMC_FILT_BROADCAST_NET_BIOS)
+
+#define is_ipv6_na_filt_enabled(adapter)	\
+		(adapter->bmc_filt_mask &	\
+			BMC_FILT_MULTICAST_IPV6_NEIGH_ADVER)
+
+#define is_ipv6_ra_filt_enabled(adapter)	\
+		(adapter->bmc_filt_mask & BMC_FILT_MULTICAST_IPV6_RA)
+
+#define is_ipv6_ras_filt_enabled(adapter)	\
+		(adapter->bmc_filt_mask & BMC_FILT_MULTICAST_IPV6_RAS)
+
+#define is_broadcast_filt_enabled(adapter)	\
+		(adapter->bmc_filt_mask & BMC_FILT_BROADCAST)
+
+#define is_multicast_filt_enabled(adapter)	\
+		(adapter->bmc_filt_mask & BMC_FILT_MULTICAST)
+
+static bool be_send_pkt_to_bmc(struct be_adapter *adapter,
+			       struct sk_buff **skb)
+{
+	struct ethhdr *eh = (struct ethhdr *)(*skb)->data;
+	bool os2bmc = false;
+
+	if (!be_is_os2bmc_enabled(adapter))
+		goto done;
+
+	if (!is_multicast_ether_addr(eh->h_dest))
+		goto done;
+
+	if (is_mc_allowed_on_bmc(adapter, eh) ||
+	    is_bc_allowed_on_bmc(adapter, eh) ||
+	    is_arp_allowed_on_bmc(adapter, (*skb))) {
+		os2bmc = true;
+		goto done;
+	}
+
+	if ((*skb)->protocol == htons(ETH_P_IPV6)) {
+		struct ipv6hdr *hdr = ipv6_hdr((*skb));
+		u8 nexthdr = hdr->nexthdr;
+
+		if (nexthdr == IPPROTO_ICMPV6) {
+			struct icmp6hdr *icmp6 = icmp6_hdr((*skb));
+
+			switch (icmp6->icmp6_type) {
+			case NDISC_ROUTER_ADVERTISEMENT:
+				os2bmc = is_ipv6_ra_filt_enabled(adapter);
+				goto done;
+			case NDISC_NEIGHBOUR_ADVERTISEMENT:
+				os2bmc = is_ipv6_na_filt_enabled(adapter);
+				goto done;
+			default:
+				break;
+			}
+		}
+	}
+
+	if (is_udp_pkt((*skb))) {
+		struct udphdr *udp = udp_hdr((*skb));
+
+		switch (udp->dest) {
+		case DHCP_CLIENT_PORT:
+			os2bmc = is_dhcp_client_filt_enabled(adapter);
+			goto done;
+		case DHCP_SERVER_PORT:
+			os2bmc = is_dhcp_srvr_filt_enabled(adapter);
+			goto done;
+		case NET_BIOS_PORT1:
+		case NET_BIOS_PORT2:
+			os2bmc = is_nbios_filt_enabled(adapter);
+			goto done;
+		case DHCPV6_RAS_PORT:
+			os2bmc = is_ipv6_ras_filt_enabled(adapter);
+			goto done;
+		default:
+			break;
+		}
+	}
+done:
+	/* For packets over a vlan, which are destined
+	 * to BMC, asic expects the vlan to be inline in the packet.
+	 */
+	if (os2bmc)
+		*skb = be_insert_vlan_in_pkt(adapter, *skb, NULL);
+
+	return os2bmc;
+}
+
 static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -1177,6 +1303,18 @@ static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
 		goto drop;
 	}
 
+	/* if os2bmc is enabled and if the pkt is destined to bmc,
+	 * enqueue the pkt a 2nd time with mgmt bit set.
+	 */
+	if (be_send_pkt_to_bmc(adapter, &skb)) {
+		BE_WRB_F_SET(wrb_params.features, OS2BMC, 1);
+		wrb_cnt = be_xmit_enqueue(adapter, txo, skb, &wrb_params);
+		if (unlikely(!wrb_cnt))
+			goto drop;
+		else
+			skb_get(skb);
+	}
+
 	if (be_is_txq_full(txo)) {
 		netif_stop_subqueue(netdev, q_idx);
 		tx_stats(txo)->tx_stops++;
-- 
1.7.1
