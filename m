From: greearb@candelatech.com
Subject: [PATCH 2/2] e100:  Support RXFCS feature flag.
Date: Thu, 23 Jun 2011 16:13:39 -0700
Message-ID: <1308870819-15938-3-git-send-email-greearb@candelatech.com>
References: <1308870819-15938-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37372 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933284Ab1FWXOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 19:14:32 -0400
In-Reply-To: <1308870819-15938-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows e100 to be configured to append the
Ethernet FCS to the skb.

Useful for sniffing networks.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 c1352c6... 761f6f5... M	drivers/net/e100.c
 drivers/net/e100.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index c1352c6..761f6f5 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1089,6 +1089,7 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 {
 	struct config *config = &cb->u.config;
 	u8 *c = (u8 *)config;
+	struct net_device *netdev = nic->netdev;
 
 	cb->command = cpu_to_le16(cb_config);
 
@@ -1132,6 +1133,9 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
 	}
 
+	if (netdev->wanted_features & NETIF_F_RXFCS)
+		config->rx_crc_transfer = 0x1;	/* 1=save, 0=discard */
+
 	if (nic->flags & multicast_all)
 		config->multicast_all = 0x1;		/* 1=accept, 0=no */
 
@@ -1919,6 +1923,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	struct sk_buff *skb = rx->skb;
 	struct rfd *rfd = (struct rfd *)skb->data;
 	u16 rfd_status, actual_size;
+	u16 fcs_pad = 0;
 
 	if (unlikely(work_done && *work_done >= work_to_do))
 		return -EAGAIN;
@@ -1951,9 +1956,11 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	}
 
 	/* Get actual data size */
+	if (dev->wanted_features & NETIF_F_RXFCS)
+		fcs_pad = 4;
 	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
-	if (unlikely(actual_size > RFD_BUF_LEN - sizeof(struct rfd)))
-		actual_size = RFD_BUF_LEN - sizeof(struct rfd);
+	if (unlikely(actual_size > RFD_BUF_LEN + fcs_pad - sizeof(struct rfd)))
+		actual_size = RFD_BUF_LEN + fcs_pad - sizeof(struct rfd);
 
 	/* Get data */
 	pci_unmap_single(nic->pdev, rx->dma_addr,
@@ -1980,7 +1987,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	if (unlikely(!(rfd_status & cb_ok))) {
 		/* Don't indicate if hardware indicates errors */
 		dev_kfree_skb_any(skb);
-	} else if (actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN) {
+	} else if (actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN + fcs_pad) {
 		/* Don't indicate oversized frames */
 		nic->rx_over_length_errors++;
 		dev_kfree_skb_any(skb);
@@ -2761,6 +2768,8 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 		return -ENOMEM;
 	}
 
+	netdev->hw_features |= NETIF_F_RXFCS;
+
 	netdev->netdev_ops = &e100_netdev_ops;
 	SET_ETHTOOL_OPS(netdev, &e100_ethtool_ops);
 	netdev->watchdog_timeo = E100_WATCHDOG_PERIOD;
-- 
1.7.3.4

