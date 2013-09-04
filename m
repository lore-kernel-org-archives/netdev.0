From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 2/5] driver/net: enic: record q_number and rss_hash for skb
Date: Wed,  4 Sep 2013 11:17:15 +0530
Message-ID: <1378273638-7780-3-git-send-email-govindarajulu90@gmail.com>
References: <1378273638-7780-1-git-send-email-govindarajulu90@gmail.com>
Cc: benve@cisco.com, ssujith@cisco.com, nistrive@cisco.com,
	umalhi@cisco.com,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378273638-7780-1-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patch sets the skb->rxhash and skb->q_number.
This is used by RPS and RFS. Kernel can make use of hw provided hash
instead of calculating the hash.

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 1ab3f18..93898ba 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1034,6 +1034,14 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 		skb_put(skb, bytes_written);
 		skb->protocol = eth_type_trans(skb, netdev);
+		skb_record_rx_queue(skb, q_number);
+		if (netdev->features & NETIF_F_RXHASH) {
+			skb->rxhash = rss_hash;
+			if (rss_type & (NIC_CFG_RSS_HASH_TYPE_TCP_IPV6_EX |
+					NIC_CFG_RSS_HASH_TYPE_TCP_IPV6 |
+					NIC_CFG_RSS_HASH_TYPE_TCP_IPV4))
+				skb->l4_rxhash = true;
+		}
 
 		if ((netdev->features & NETIF_F_RXCSUM) && !csum_not_calc) {
 			skb->csum = htons(checksum);
@@ -2209,6 +2217,7 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	netif_set_real_num_tx_queues(netdev, enic->wq_count);
+	netif_set_real_num_rx_queues(netdev, enic->rq_count);
 
 	/* Setup notification timer, HW reset task, and wq locks
 	 */
@@ -2258,6 +2267,8 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (ENIC_SETTING(enic, TSO))
 		netdev->hw_features |= NETIF_F_TSO |
 			NETIF_F_TSO6 | NETIF_F_TSO_ECN;
+	if (ENIC_SETTING(enic, RSS))
+		netdev->hw_features |= NETIF_F_RXHASH;
 	if (ENIC_SETTING(enic, RXCSUM))
 		netdev->hw_features |= NETIF_F_RXCSUM;
 
-- 
1.8.4
