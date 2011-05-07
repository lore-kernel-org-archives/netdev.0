From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 4/5] ixgbe: add rxhash support
Date: Sat,  7 May 2011 03:25:22 -0700
Message-ID: <1304763923-6839-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304763923-6839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3197 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754486Ab1EGKZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 06:25:30 -0400
In-Reply-To: <1304763923-6839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

feed RSS hash into skb->rxhash

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |    7 ++++++-
 drivers/net/ixgbe/ixgbe_main.c    |   14 +++++++++++++-
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index f2efa32..545b231 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2253,8 +2253,13 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 	need_reset = (data & ETH_FLAG_RXVLAN) !=
 		     (netdev->features & NETIF_F_HW_VLAN_RX);
 
+	if ((data & ETH_FLAG_RXHASH) &&
+	    !(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
+		return -EOPNOTSUPP;
+
 	rc = ethtool_op_set_flags(netdev, data, ETH_FLAG_LRO | ETH_FLAG_NTUPLE |
-					ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN);
+				  ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN |
+				  ETH_FLAG_RXHASH);
 	if (rc)
 		return rc;
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index eebb192..56cc9a1 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1063,8 +1063,14 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 
 	return 0;
 }
-
 #endif /* CONFIG_IXGBE_DCA */
+
+static inline void ixgbe_rx_hash(union ixgbe_adv_rx_desc *rx_desc,
+				 struct sk_buff *skb)
+{
+	skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
+}
+
 /**
  * ixgbe_receive_skb - Send a completed packet up the stack
  * @adapter: board private structure
@@ -1456,6 +1462,8 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		}
 
 		ixgbe_rx_checksum(adapter, rx_desc, skb);
+		if (adapter->netdev->features & NETIF_F_RXHASH)
+			ixgbe_rx_hash(rx_desc, skb);
 
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
@@ -7361,6 +7369,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
 	netdev->features |= NETIF_F_GRO;
+	netdev->features |= NETIF_F_RXHASH;
 
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82599EB:
@@ -7441,6 +7450,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
+	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
+		netdev->features &= ~NETIF_F_RXHASH;
+
 	switch (pdev->device) {
 	case IXGBE_DEV_ID_82599_SFP:
 		/* Only this subdevice supports WOL */
-- 
1.7.4.4

