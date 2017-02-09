From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: [PATCH 2/3 v2 net-next] enic: add udp_tunnel ndo for vxlan offload
Date: Wed,  8 Feb 2017 16:43:08 -0800
Message-ID: <20170209004309.1225-3-gvaradar@cisco.com>
References: <20170209004309.1225-1-gvaradar@cisco.com>
Cc: benve@cisco.com, Govindarajulu Varadarajan <gvaradar@cisco.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-7.cisco.com ([173.37.86.78]:61652 "EHLO
        rcdn-iport-7.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbdBIBY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 20:24:58 -0500
In-Reply-To: <20170209004309.1225-1-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defines enic_udp_tunnel_add/del for configuring vxlan tunnel offload.
enic supports offload of only one ipv4/udp port.

There are two modes that fw supports for vxlan offload.

mode 0: fcoe bit is set for encapsulated packet. fcoe_fc_crc_ok is set
if checksum of csum is ok. This bit is or of ip_csum_ok and
tcp_udp_csum_ok

mode 2: BIT(0) in rss_hash is set if it is encapsulated packet.
	BIT(1) is set if outer_ip_csum_ok/
	BIT(2) is set if outer_tcp_csum_ok

tcp_udp_csum_ok/ipv4_csum_ok is set if inner csum is OK.

Signed-off-by: Govindarajulu Varadarajan <gvaradar@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |   6 ++
 drivers/net/ethernet/cisco/enic/enic_main.c | 156 +++++++++++++++++++++++++++-
 2 files changed, 159 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 9023c858715d..2b23f46b34d3 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -135,6 +135,11 @@ struct enic_rfs_flw_tbl {
 	struct timer_list rfs_may_expire;
 };
 
+struct vxlan_offload {
+	u16 vxlan_udp_port_number;
+	u8 patch_level;
+};
+
 /* Per-instance private data structure */
 struct enic {
 	struct net_device *netdev;
@@ -175,6 +180,7 @@ struct enic {
 	/* receive queue cache line section */
 	____cacheline_aligned struct vnic_rq rq[ENIC_RQ_MAX];
 	unsigned int rq_count;
+	struct vxlan_offload vxlan;
 	u64 rq_truncated_pkts;
 	u64 rq_bad_fcs;
 	struct napi_struct napi[ENIC_RQ_MAX + ENIC_WQ_MAX];
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index c009f6ddabf7..7e56bf95cfc7 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -45,6 +45,7 @@
 #endif
 #include <linux/crash_dump.h>
 #include <net/busy_poll.h>
+#include <net/vxlan.h>
 
 #include "cq_enet_desc.h"
 #include "vnic_dev.h"
@@ -176,6 +177,92 @@ static void enic_unset_affinity_hint(struct enic *enic)
 		irq_set_affinity_hint(enic->msix_entry[i].vector, NULL);
 }
 
+static void enic_udp_tunnel_add(struct net_device *netdev,
+				struct udp_tunnel_info *ti)
+{
+	struct enic *enic = netdev_priv(netdev);
+	__be16 port = ti->port;
+	int err;
+
+	spin_lock_bh(&enic->devcmd_lock);
+
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN) {
+		netdev_info(netdev, "udp_tnl: only vxlan tunnel offload supported");
+		goto error;
+	}
+
+	if (ti->sa_family != AF_INET) {
+		netdev_info(netdev, "vxlan: only IPv4 offload supported");
+		goto error;
+	}
+
+	if (enic->vxlan.vxlan_udp_port_number) {
+		if (ntohs(port) == enic->vxlan.vxlan_udp_port_number)
+			netdev_warn(netdev, "vxlan: udp port already offloaded");
+		else
+			netdev_info(netdev, "vxlan: offload supported for only one UDP port");
+
+		goto error;
+	}
+
+	err = vnic_dev_overlay_offload_cfg(enic->vdev,
+					   OVERLAY_CFG_VXLAN_PORT_UPDATE,
+					   ntohs(port));
+	if (err)
+		goto error;
+
+	err = vnic_dev_overlay_offload_ctrl(enic->vdev, OVERLAY_FEATURE_VXLAN,
+					    enic->vxlan.patch_level);
+	if (err)
+		goto error;
+
+	enic->vxlan.vxlan_udp_port_number = ntohs(port);
+
+	netdev_info(netdev, "vxlan fw-vers-%d: offload enabled for udp port: %d, sa_family: %d ",
+		    (int)enic->vxlan.patch_level, ntohs(port), ti->sa_family);
+
+	goto unlock;
+
+error:
+	netdev_info(netdev, "failed to offload udp port: %d, sa_family: %d, type: %d",
+		    ntohs(port), ti->sa_family, ti->type);
+unlock:
+	spin_unlock_bh(&enic->devcmd_lock);
+}
+
+static void enic_udp_tunnel_del(struct net_device *netdev,
+				struct udp_tunnel_info *ti)
+{
+	struct enic *enic = netdev_priv(netdev);
+	int err;
+
+	spin_lock_bh(&enic->devcmd_lock);
+
+	if ((ti->sa_family != AF_INET) ||
+	    ((ntohs(ti->port) != enic->vxlan.vxlan_udp_port_number)) ||
+	    (ti->type != UDP_TUNNEL_TYPE_VXLAN)) {
+		netdev_info(netdev, "udp_tnl: port:%d, sa_family: %d, type: %d not offloaded",
+			    ntohs(ti->port), ti->sa_family, ti->type);
+		goto unlock;
+	}
+
+	err = vnic_dev_overlay_offload_ctrl(enic->vdev, OVERLAY_FEATURE_VXLAN,
+					    OVERLAY_OFFLOAD_DISABLE);
+	if (err) {
+		netdev_err(netdev, "vxlan: del offload udp port: %d failed",
+			   ntohs(ti->port));
+		goto unlock;
+	}
+
+	enic->vxlan.vxlan_udp_port_number = 0;
+
+	netdev_info(netdev, "vxlan: del offload udp port %d, family %d\n",
+		    ntohs(ti->port), ti->sa_family);
+
+unlock:
+	spin_unlock_bh(&enic->devcmd_lock);
+}
+
 int enic_is_dynamic(struct enic *enic)
 {
 	return enic->pdev->device == PCI_DEVICE_ID_CISCO_VIC_ENET_DYN;
@@ -1113,6 +1200,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 	u8 packet_error;
 	u16 q_number, completed_index, bytes_written, vlan_tci, checksum;
 	u32 rss_hash;
+	bool outer_csum_ok = true, encap = false;
 
 	if (skipped)
 		return;
@@ -1161,7 +1249,8 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 		skb_put(skb, bytes_written);
 		skb->protocol = eth_type_trans(skb, netdev);
 		skb_record_rx_queue(skb, q_number);
-		if (netdev->features & NETIF_F_RXHASH) {
+		if ((netdev->features & NETIF_F_RXHASH) && rss_hash &&
+		    (type == 3)) {
 			switch (rss_type) {
 			case CQ_ENET_RQ_DESC_RSS_TYPE_TCP_IPv4:
 			case CQ_ENET_RQ_DESC_RSS_TYPE_TCP_IPv6:
@@ -1175,15 +1264,39 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 				break;
 			}
 		}
+		if (enic->vxlan.vxlan_udp_port_number) {
+			switch (enic->vxlan.patch_level) {
+			case 0:
+				if (fcoe) {
+					encap = true;
+					outer_csum_ok = fcoe_fc_crc_ok;
+				}
+				break;
+			case 2:
+				if ((type == 7) &&
+				    (rss_hash & BIT(0))) {
+					encap = true;
+					outer_csum_ok = (rss_hash & BIT(1)) &&
+							(rss_hash & BIT(2));
+				}
+				break;
+			}
+		}
 
 		/* Hardware does not provide whole packet checksum. It only
 		 * provides pseudo checksum. Since hw validates the packet
 		 * checksum but not provide us the checksum value. use
 		 * CHECSUM_UNNECESSARY.
+		 *
+		 * In case of encap pkt tcp_udp_csum_ok/tcp_udp_csum_ok is
+		 * inner csum_ok. outer_csum_ok is set by hw when outer udp
+		 * csum is correct or is zero.
 		 */
-		if ((netdev->features & NETIF_F_RXCSUM) && tcp_udp_csum_ok &&
-		    ipv4_csum_ok)
+		if ((netdev->features & NETIF_F_RXCSUM) && !csum_not_calc &&
+		    tcp_udp_csum_ok && ipv4_csum_ok && outer_csum_ok) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			skb->csum_level = encap;
+		}
 
 		if (vlan_stripped)
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tci);
@@ -2285,6 +2398,8 @@ static const struct net_device_ops enic_netdev_dynamic_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= enic_rx_flow_steer,
 #endif
+	.ndo_udp_tunnel_add	= enic_udp_tunnel_add,
+	.ndo_udp_tunnel_del	= enic_udp_tunnel_del,
 };
 
 static const struct net_device_ops enic_netdev_ops = {
@@ -2308,6 +2423,8 @@ static const struct net_device_ops enic_netdev_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= enic_rx_flow_steer,
 #endif
+	.ndo_udp_tunnel_add	= enic_udp_tunnel_add,
+	.ndo_udp_tunnel_del	= enic_udp_tunnel_del,
 };
 
 static void enic_dev_deinit(struct enic *enic)
@@ -2683,6 +2800,39 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->hw_features |= NETIF_F_RXHASH;
 	if (ENIC_SETTING(enic, RXCSUM))
 		netdev->hw_features |= NETIF_F_RXCSUM;
+	if (ENIC_SETTING(enic, VXLAN)) {
+		u64 patch_level;
+
+		netdev->hw_enc_features |= NETIF_F_RXCSUM		|
+					   NETIF_F_TSO			|
+					   NETIF_F_TSO_ECN		|
+					   NETIF_F_GSO_UDP_TUNNEL	|
+					   NETIF_F_HW_CSUM		|
+					   NETIF_F_GSO_UDP_TUNNEL_CSUM;
+		netdev->hw_features |= netdev->hw_enc_features;
+		/* get bit mask from hw about supported offload bit level
+		 * BIT(0) = fw supports patch_level 0
+		 *	    fcoe bit = encap
+		 *	    fcoe_fc_crc_ok = outer csum ok
+		 * BIT(1) = always set by fw
+		 * BIT(2) = fw supports patch_level 2
+		 *	    BIT(0) in rss_hash = encap
+		 *	    BIT(1,2) in rss_hash = outer_ip_csum_ok/
+		 *				   outer_tcp_csum_ok
+		 * used in enic_rq_indicate_buf
+		 */
+		err = vnic_dev_get_supported_feature_ver(enic->vdev,
+							 VIC_FEATURE_VXLAN,
+							 &patch_level);
+		if (err)
+			patch_level = 0;
+		/* mask bits that are supported by driver
+		 */
+		patch_level &= BIT_ULL(0) | BIT_ULL(2);
+		patch_level = fls(patch_level);
+		patch_level = patch_level ? patch_level - 1 : 0;
+		enic->vxlan.patch_level = patch_level;
+	}
 
 	netdev->features |= netdev->hw_features;
 	netdev->vlan_features |= netdev->features;
-- 
2.11.0
