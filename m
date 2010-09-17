From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 1/5] qlcnic: support vlan rx accleration
Date: Thu, 16 Sep 2010 22:14:39 -0700
Message-ID: <1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
References: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:56987 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750788Ab0IQFOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Sep 2010 01:14:44 -0400
In-Reply-To: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implemented vlan rx accleration in driver.
This helps in increasing significant performance and
reduces cpu utilization with GRO and LRO.

Eric Dumazet:
	"Its a bit strange you use dev_kfree_skb_any(skb) here."
	"We run in NAPI mode, so you can use dev_kfree_skb()."
Amit:
	Done. Using dev_kfree_skb();

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 +
 drivers/net/qlcnic/qlcnic_init.c |   59 ++++++++++++++++++++++----------------
 drivers/net/qlcnic/qlcnic_main.c |   10 ++++++-
 3 files changed, 44 insertions(+), 26 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index cc8385a..c8caec9 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1013,6 +1013,7 @@ struct qlcnic_adapter {
 
 	u64 dev_rst_time;
 
+	struct vlan_group *vlgrp;
 	struct qlcnic_npar_info *npars;
 	struct qlcnic_eswitch *eswitch;
 	struct qlcnic_nic_template *nic_ops;
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 26a7d6b..10cebb1 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1380,24 +1380,28 @@ static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 }
 
 static int
-qlcnic_check_rx_tagging(struct qlcnic_adapter *adapter, struct sk_buff *skb)
+qlcnic_check_rx_tagging(struct qlcnic_adapter *adapter, struct sk_buff *skb,
+			u16 *vlan_tag)
 {
-	u16 vlan_tag;
 	struct ethhdr *eth_hdr;
 
-	if (!__vlan_get_tag(skb, &vlan_tag)) {
-		if (vlan_tag == adapter->pvid) {
-			/* strip the tag from the packet and send it up */
-			eth_hdr = (struct ethhdr *) skb->data;
-			memmove(skb->data + VLAN_HLEN, eth_hdr, ETH_ALEN * 2);
-			skb_pull(skb, VLAN_HLEN);
-			return 0;
-		}
+	if (!__vlan_get_tag(skb, vlan_tag)) {
+		eth_hdr = (struct ethhdr *) skb->data;
+		memmove(skb->data + VLAN_HLEN, eth_hdr, ETH_ALEN * 2);
+		skb_pull(skb, VLAN_HLEN);
+	}
+	if (!adapter->pvid)
+		return 0;
+
+	if (*vlan_tag == adapter->pvid) {
+		/* Outer vlan tag. Packet should follow non-vlan path */
+		*vlan_tag = 0xffff;
+		return 0;
 	}
 	if (adapter->flags & QLCNIC_TAGGING_ENABLED)
 		return 0;
 
-	return -EIO;
+	return -EINVAL;
 }
 
 static struct qlcnic_rx_buffer *
@@ -1411,6 +1415,7 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 	struct sk_buff *skb;
 	struct qlcnic_host_rds_ring *rds_ring;
 	int index, length, cksum, pkt_offset;
+	u16 vid = 0xffff;
 
 	if (unlikely(ring >= adapter->max_rds_rings))
 		return NULL;
@@ -1441,17 +1446,18 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 
 	skb->truesize = skb->len + sizeof(struct sk_buff);
 
-	if (unlikely(adapter->pvid)) {
-		if (qlcnic_check_rx_tagging(adapter, skb)) {
-			adapter->stats.rxdropped++;
-			dev_kfree_skb_any(skb);
-			return buffer;
-		}
+	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
+		adapter->stats.rxdropped++;
+		dev_kfree_skb(skb);
+		return buffer;
 	}
 
 	skb->protocol = eth_type_trans(skb, netdev);
 
-	napi_gro_receive(&sds_ring->napi, skb);
+	if ((vid != 0xffff) && adapter->vlgrp)
+		vlan_hwaccel_receive_skb(skb, adapter->vlgrp, vid);
+	else
+		napi_gro_receive(&sds_ring->napi, skb);
 
 	adapter->stats.rx_pkts++;
 	adapter->stats.rxbytes += length;
@@ -1480,6 +1486,7 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 	int index;
 	u16 lro_length, length, data_offset;
 	u32 seq_number;
+	u16 vid = 0xffff;
 
 	if (unlikely(ring > adapter->max_rds_rings))
 		return NULL;
@@ -1514,13 +1521,12 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 
 	skb_pull(skb, l2_hdr_offset);
 
-	if (unlikely(adapter->pvid)) {
-		if (qlcnic_check_rx_tagging(adapter, skb)) {
-			adapter->stats.rxdropped++;
-			dev_kfree_skb_any(skb);
-			return buffer;
-		}
+	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
+		adapter->stats.rxdropped++;
+		dev_kfree_skb(skb);
+		return buffer;
 	}
+
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	iph = (struct iphdr *)skb->data;
@@ -1535,7 +1541,10 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 
 	length = skb->len;
 
-	netif_receive_skb(skb);
+	if ((vid != 0xffff) && adapter->vlgrp)
+		vlan_hwaccel_receive_skb(skb, adapter->vlgrp, vid);
+	else
+		netif_receive_skb(skb);
 
 	adapter->stats.lro_pkts++;
 	adapter->stats.lrobytes += length;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 5fd2abd..9eb0ced 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -371,6 +371,13 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }
 
+static void qlcnic_vlan_rx_register(struct net_device *netdev,
+		struct vlan_group *grp)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	adapter->vlgrp = grp;
+}
+
 static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_open	   = qlcnic_open,
 	.ndo_stop	   = qlcnic_close,
@@ -381,6 +388,7 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_set_mac_address    = qlcnic_set_mac,
 	.ndo_change_mtu	   = qlcnic_change_mtu,
 	.ndo_tx_timeout	   = qlcnic_tx_timeout,
+	.ndo_vlan_rx_register = qlcnic_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = qlcnic_poll_controller,
 #endif
@@ -1446,7 +1454,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_ops);
 
 	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
-		NETIF_F_IPV6_CSUM | NETIF_F_GRO);
+		NETIF_F_IPV6_CSUM | NETIF_F_GRO | NETIF_F_HW_VLAN_RX);
 	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
 		NETIF_F_IPV6_CSUM);
 
-- 
1.6.0.2

