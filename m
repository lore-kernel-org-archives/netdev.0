From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 10/11] netxen: enable GRO support
Date: Wed,  8 Apr 2009 01:50:47 -0700
Message-ID: <1239180648-29842-11-git-send-email-dhananjay@netxen.com>
References: <1239180648-29842-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net, Amit Kumar Salecha <amit@dut4146 (none) >,
	Amit Kumar Salecha <amit@netxen.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:49853 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761221AbZDHIvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2009 04:51:05 -0400
In-Reply-To: <1239180648-29842-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@dut4146.(none)>

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_init.c |    7 ++++---
 drivers/net/netxen/netxen_nic_main.c |    1 +
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 0c91238..8893a97 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -923,7 +923,8 @@ no_skb:
 
 static struct netxen_rx_buffer *
 netxen_process_rcv(struct netxen_adapter *adapter,
-		int ring, int index, int length, int cksum, int pkt_offset)
+		int ring, int index, int length, int cksum, int pkt_offset,
+		struct nx_host_sds_ring *sds_ring)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
@@ -951,7 +952,7 @@ netxen_process_rcv(struct netxen_adapter *adapter,
 
 	skb->protocol = eth_type_trans(skb, netdev);
 
-	netif_receive_skb(skb);
+	napi_gro_receive(&sds_ring->napi, skb);
 
 	adapter->stats.no_rcv++;
 	adapter->stats.rxbytes += length;
@@ -1011,7 +1012,7 @@ netxen_process_rcv_ring(struct nx_host_sds_ring *sds_ring, int max)
 		pkt_offset = netxen_get_sts_pkt_offset(sts_data);
 
 		rxbuf = netxen_process_rcv(adapter, ring, index,
-				length, cksum, pkt_offset);
+				length, cksum, pkt_offset, sds_ring);
 
 		if (rxbuf)
 			list_add_tail(&rxbuf->list, &sds_ring->free_list[ring]);
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 56c16c7..7080050 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -981,6 +981,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
 
 	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
+	netdev->features |= (NETIF_F_GRO);
 	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
 
 	if (NX_IS_REVISION_P3(revision_id)) {
-- 
1.6.0.2

