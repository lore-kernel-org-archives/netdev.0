From: greearb@candelatech.com
Subject: [PATCH v3 02/16] e100: Support RXFCS feature flag.
Date: Fri, 10 Feb 2012 17:04:20 -0800
Message-ID: <1328922274-23993-3-git-send-email-greearb@candelatech.com>
References: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55833 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761211Ab2BKBFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 20:05:09 -0500
In-Reply-To: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows e100 to be configured to append the
Ethernet FCS to the skb.

Useful for sniffing networks.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 485ab8c... 1fd4603... M	drivers/net/ethernet/intel/e100.c
 drivers/net/ethernet/intel/e100.c |   32 ++++++++++++++++++++++++++++----
 1 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 485ab8c..1fd4603 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1089,6 +1089,7 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 {
 	struct config *config = &cb->u.config;
 	u8 *c = (u8 *)config;
+	struct net_device *netdev = nic->netdev;
 
 	cb->command = cpu_to_le16(cb_config);
 
@@ -1132,6 +1133,9 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
 	}
 
+	if (unlikely(netdev->features & NETIF_F_RXFCS))
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
+	if (unlikely(dev->features & NETIF_F_RXFCS))
+		fcs_pad = 4;
 	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
-	if (unlikely(actual_size > RFD_BUF_LEN - sizeof(struct rfd)))
-		actual_size = RFD_BUF_LEN - sizeof(struct rfd);
+	if (unlikely(actual_size > RFD_BUF_LEN + fcs_pad - sizeof(struct rfd)))
+		actual_size = RFD_BUF_LEN + fcs_pad - sizeof(struct rfd);
 
 	/* Get data */
 	pci_unmap_single(nic->pdev, rx->dma_addr,
@@ -1980,13 +1987,13 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	if (unlikely(!(rfd_status & cb_ok))) {
 		/* Don't indicate if hardware indicates errors */
 		dev_kfree_skb_any(skb);
-	} else if (actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN) {
+	} else if (actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN + fcs_pad) {
 		/* Don't indicate oversized frames */
 		nic->rx_over_length_errors++;
 		dev_kfree_skb_any(skb);
 	} else {
 		dev->stats.rx_packets++;
-		dev->stats.rx_bytes += actual_size;
+		dev->stats.rx_bytes += (actual_size - fcs_pad);
 		netif_receive_skb(skb);
 		if (work_done)
 			(*work_done)++;
@@ -2729,6 +2736,20 @@ static int e100_close(struct net_device *netdev)
 	return 0;
 }
 
+static int e100_set_features(struct net_device *netdev,
+			     netdev_features_t features)
+{
+	struct nic *nic = netdev_priv(netdev);
+	netdev_features_t changed = features ^ netdev->features;
+
+	if (!(changed & (NETIF_F_RXFCS)))
+		return 0;
+
+	netdev->features = features;
+	e100_exec_cb(nic, NULL, e100_configure);
+	return 0;
+}
+
 static const struct net_device_ops e100_netdev_ops = {
 	.ndo_open		= e100_open,
 	.ndo_stop		= e100_close,
@@ -2742,6 +2763,7 @@ static const struct net_device_ops e100_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= e100_netpoll,
 #endif
+	.ndo_set_features	= e100_set_features,
 };
 
 static int __devinit e100_probe(struct pci_dev *pdev,
@@ -2754,6 +2776,8 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	if (!(netdev = alloc_etherdev(sizeof(struct nic))))
 		return -ENOMEM;
 
+	netdev->hw_features |= NETIF_F_RXFCS;
+
 	netdev->netdev_ops = &e100_netdev_ops;
 	SET_ETHTOOL_OPS(netdev, &e100_ethtool_ops);
 	netdev->watchdog_timeo = E100_WATCHDOG_PERIOD;
-- 
1.7.3.4
