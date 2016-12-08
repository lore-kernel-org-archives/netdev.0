From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 1/5] liquidio VF vlan support
Date: Thu, 8 Dec 2016 13:00:44 -0800
Message-ID: <1481230848-2393-2-git-send-email-rvatsavayi@caviumnetworks.com>
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
        id S1752254AbcLHVBP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 16:01:15 -0500
In-Reply-To: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF vlan features.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 80 ++++++++++++++++++++++
 1 file changed, 80 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 9989ac3..bcfc927 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1350,6 +1350,7 @@ static u16 select_q(struct net_device *dev, struct sk_buff *skb,
 		container_of(param, struct octeon_droq, napi);
 	struct net_device *netdev = (struct net_device *)arg;
 	struct sk_buff *skb = (struct sk_buff *)skbuff;
+	u16 vtag = 0;
 
 	if (netdev) {
 		struct lio *lio = GET_LIO(netdev);
@@ -1403,6 +1404,16 @@ static u16 select_q(struct net_device *dev, struct sk_buff *skb,
 		else
 			skb->ip_summed = CHECKSUM_NONE;
 
+		/* inbound VLAN tag */
+		if ((netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
+		    rh->r_dh.vlan) {
+			u16 priority = rh->r_dh.priority;
+			u16 vid = rh->r_dh.vlan;
+
+			vtag = (priority << VLAN_PRIO_SHIFT) | vid;
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vtag);
+		}
+
 		packet_was_received = (napi_gro_receive(napi, skb) != GRO_DROP);
 
 		if (packet_was_received) {
@@ -2025,6 +2036,12 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 		tx_info->s.gso_segs = skb_shinfo(skb)->gso_segs;
 	}
 
+	/* HW insert VLAN tag */
+	if (skb_vlan_tag_present(skb)) {
+		irh->priority = skb_vlan_tag_get(skb) >> VLAN_PRIO_SHIFT;
+		irh->vlan = skb_vlan_tag_get(skb) & VLAN_VID_MASK;
+	}
+
 	status = octnet_send_nic_data_pkt(oct, &ndata);
 	if (status == IQ_SEND_FAILED)
 		goto lio_xmit_failed;
@@ -2074,6 +2091,61 @@ static void liquidio_tx_timeout(struct net_device *netdev)
 	txqs_wake(netdev);
 }
 
+static int
+liquidio_vlan_rx_add_vid(struct net_device *netdev,
+			 __be16 proto __attribute__((unused)), u16 vid)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_ADD_VLAN_FILTER;
+	nctrl.ncmd.s.param1 = vid;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "Add VLAN filter failed in core (ret: 0x%x)\n",
+			ret);
+	}
+
+	return ret;
+}
+
+static int
+liquidio_vlan_rx_kill_vid(struct net_device *netdev,
+			  __be16 proto __attribute__((unused)), u16 vid)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_DEL_VLAN_FILTER;
+	nctrl.ncmd.s.param1 = vid;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "Add VLAN filter failed in core (ret: 0x%x)\n",
+			ret);
+	}
+	return ret;
+}
+
 /** Sending command to enable/disable RX checksum offload
  * @param netdev                pointer to network device
  * @param command               OCTNET_CMD_TNL_RX_CSUM_CTL
@@ -2180,6 +2252,8 @@ static int liquidio_set_features(struct net_device *netdev,
 	.ndo_set_mac_address	= liquidio_set_mac,
 	.ndo_set_rx_mode	= liquidio_set_mcast_list,
 	.ndo_tx_timeout		= liquidio_tx_timeout,
+	.ndo_vlan_rx_add_vid    = liquidio_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid   = liquidio_vlan_rx_kill_vid,
 	.ndo_change_mtu		= liquidio_change_mtu,
 	.ndo_fix_features	= liquidio_fix_features,
 	.ndo_set_features	= liquidio_set_features,
@@ -2388,6 +2462,12 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 				      | NETIF_F_LRO;
 		netif_set_gso_max_size(netdev, OCTNIC_GSO_MAX_SIZE);
 
+		netdev->vlan_features = lio->dev_capability;
+		/* Add any unchangeable hw features */
+		lio->dev_capability |= NETIF_F_HW_VLAN_CTAG_FILTER |
+				       NETIF_F_HW_VLAN_CTAG_RX |
+				       NETIF_F_HW_VLAN_CTAG_TX;
+
 		netdev->features = (lio->dev_capability & ~NETIF_F_LRO);
 
 		netdev->hw_features = lio->dev_capability;
-- 
1.8.3.1
