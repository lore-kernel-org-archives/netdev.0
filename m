From: dev.srinivasulu@gmail.com
Subject: [PATCH] net: thunderx: Enable TSO and checksum offloads for ipv6
Date: Thu,  6 Apr 2017 16:12:26 +0530
Message-ID: <1491475346-7809-1-git-send-email-tsrinivasulu@cavium.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        sgoutham@cavium.com, tsrinivasulu@cavium.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thanneeru Srinivasulu <tsrinivasulu@cavium.com>

Adding support for TSO and checksum hardware offloads for ipv6.

Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@cavium.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |    8 +++++---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |   10 +++++++++-
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index bfaf858..81a2fcb 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1643,8 +1643,9 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_unregister_interrupts;
 
-	netdev->hw_features = (NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
-			       NETIF_F_TSO | NETIF_F_GRO |
+	netdev->hw_features = (NETIF_F_RXCSUM | NETIF_F_SG |
+			       NETIF_F_TSO | NETIF_F_GRO | NETIF_F_TSO6 |
+			       NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			       NETIF_F_HW_VLAN_CTAG_RX);
 
 	netdev->hw_features |= NETIF_F_RXHASH;
@@ -1652,7 +1653,8 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->features |= netdev->hw_features;
 	netdev->hw_features |= NETIF_F_LOOPBACK;
 
-	netdev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
+	netdev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM |
+				NETIF_F_IPV6_CSUM | NETIF_F_TSO | NETIF_F_TSO6;
 
 	netdev->netdev_ops = &nicvf_netdev_ops;
 	netdev->watchdog_timeo = NICVF_TX_TIMEOUT;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index f13289f..7b0fd8d 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -1094,7 +1094,13 @@ static int nicvf_sq_subdesc_required(struct nicvf *nic, struct sk_buff *skb)
 {
 	int proto;
 	struct sq_hdr_subdesc *hdr;
+	union {
+		struct iphdr *v4;
+		struct ipv6hdr *v6;
+		unsigned char *hdr;
+	} ip;
 
+	ip.hdr = skb_network_header(skb);
 	hdr = (struct sq_hdr_subdesc *)GET_SQ_DESC(sq, qentry);
 	memset(hdr, 0, SND_QUEUE_DESC_SIZE);
 	hdr->subdesc_type = SQ_DESC_TYPE_HEADER;
@@ -1119,7 +1125,9 @@ static int nicvf_sq_subdesc_required(struct nicvf *nic, struct sk_buff *skb)
 		hdr->l3_offset = skb_network_offset(skb);
 		hdr->l4_offset = skb_transport_offset(skb);
 
-		proto = ip_hdr(skb)->protocol;
+		proto = (ip.v4->version == 4) ? ip.v4->protocol :
+			ip.v6->nexthdr;
+
 		switch (proto) {
 		case IPPROTO_TCP:
 			hdr->csum_l4 = SEND_L4_CSUM_TCP;
-- 
1.7.1
