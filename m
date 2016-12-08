From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 2/5] liquidio VF vxlan
Date: Thu, 8 Dec 2016 13:00:45 -0800
Message-ID: <1481230848-2393-3-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2nam03on0072.outbound.protection.outlook.com ([104.47.42.72]:2178
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753427AbcLHVBR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 16:01:17 -0500
In-Reply-To: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds VF vxlan offload support.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 97 +++++++++++++++++++++-
 1 file changed, 94 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index bcfc927..5d1023b 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1398,12 +1398,24 @@ static u16 select_q(struct net_device *dev, struct sk_buff *skb,
 		skb->protocol = eth_type_trans(skb, skb->dev);
 
 		if ((netdev->features & NETIF_F_RXCSUM) &&
-		    (rh->r_dh.csum_verified & CNNIC_CSUM_VERIFIED))
+		    (((rh->r_dh.encap_on) &&
+		      (rh->r_dh.csum_verified & CNNIC_TUN_CSUM_VERIFIED)) ||
+		     (!(rh->r_dh.encap_on) &&
+		      (rh->r_dh.csum_verified & CNNIC_CSUM_VERIFIED))))
 			/* checksum has already been verified */
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		else
 			skb->ip_summed = CHECKSUM_NONE;
 
+		/* Setting Encapsulation field on basis of status received
+		 * from the firmware
+		 */
+		if (rh->r_dh.encap_on) {
+			skb->encapsulation = 1;
+			skb->csum_level = 1;
+			droq->stats.rx_vxlan++;
+		}
+
 		/* inbound VLAN tag */
 		if ((netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
 		    rh->r_dh.vlan) {
@@ -1916,8 +1928,14 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	cmdsetup.u64 = 0;
 	cmdsetup.s.iq_no = iq_no;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		cmdsetup.s.transport_csum = 1;
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		if (skb->encapsulation) {
+			cmdsetup.s.tnl_csum = 1;
+			stats->tx_vxlan++;
+		} else {
+			cmdsetup.s.transport_csum = 1;
+		}
+	}
 
 	if (!skb_shinfo(skb)->nr_frags) {
 		cmdsetup.s.u.datasize = skb->len;
@@ -2177,6 +2195,40 @@ static int liquidio_set_rxcsum_command(struct net_device *netdev, int command,
 	return ret;
 }
 
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
+			"DEVFLAGS VxLAN port add/delete failed in core (ret : 0x%x)\n",
+			ret);
+	}
+	return ret;
+}
+
 /** \brief Net device fix features
  * @param netdev  pointer to network device
  * @param request features requested
@@ -2245,6 +2297,30 @@ static int liquidio_set_features(struct net_device *netdev,
 	return 0;
 }
 
+static void liquidio_add_vxlan_port(struct net_device *netdev,
+				    struct udp_tunnel_info *ti)
+{
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
+	liquidio_vxlan_port_command(netdev,
+				    OCTNET_CMD_VXLAN_PORT_CONFIG,
+				    htons(ti->port),
+				    OCTNET_CMD_VXLAN_PORT_ADD);
+}
+
+static void liquidio_del_vxlan_port(struct net_device *netdev,
+				    struct udp_tunnel_info *ti)
+{
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
+	liquidio_vxlan_port_command(netdev,
+				    OCTNET_CMD_VXLAN_PORT_CONFIG,
+				    htons(ti->port),
+				    OCTNET_CMD_VXLAN_PORT_DEL);
+}
+
 static const struct net_device_ops lionetdevops = {
 	.ndo_open		= liquidio_open,
 	.ndo_stop		= liquidio_stop,
@@ -2257,6 +2333,8 @@ static int liquidio_set_features(struct net_device *netdev,
 	.ndo_change_mtu		= liquidio_change_mtu,
 	.ndo_fix_features	= liquidio_fix_features,
 	.ndo_set_features	= liquidio_set_features,
+	.ndo_udp_tunnel_add     = liquidio_add_vxlan_port,
+	.ndo_udp_tunnel_del     = liquidio_del_vxlan_port,
 	.ndo_select_queue	= select_q,
 };
 
@@ -2462,6 +2540,19 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 				      | NETIF_F_LRO;
 		netif_set_gso_max_size(netdev, OCTNIC_GSO_MAX_SIZE);
 
+		/* Copy of transmit encapsulation capabilities:
+		 * TSO, TSO6, Checksums for this device
+		 */
+		lio->enc_dev_capability = NETIF_F_IP_CSUM
+					  | NETIF_F_IPV6_CSUM
+					  | NETIF_F_GSO_UDP_TUNNEL
+					  | NETIF_F_HW_CSUM | NETIF_F_SG
+					  | NETIF_F_RXCSUM
+					  | NETIF_F_TSO | NETIF_F_TSO6
+					  | NETIF_F_LRO;
+
+		netdev->hw_enc_features =
+		    (lio->enc_dev_capability & ~NETIF_F_LRO);
 		netdev->vlan_features = lio->dev_capability;
 		/* Add any unchangeable hw features */
 		lio->dev_capability |= NETIF_F_HW_VLAN_CTAG_FILTER |
-- 
1.8.3.1
