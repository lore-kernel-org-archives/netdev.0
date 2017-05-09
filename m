From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH] net: qca_spi: Fix alignment issues in rx path
Date: Tue,  9 May 2017 15:40:38 +0200
Message-ID: <1494337238-1699-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:62578 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753992AbdEINlQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 09:41:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qca_spi driver causes alignment issues on ARM devices.
So fix this by using netdev_alloc_skb_ip_align().

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
Fixes: 291ab06ecf67 ("net: qualcomm: new Ethernet over SPI driver for QCA7000")
---
 drivers/net/ethernet/qualcomm/qca_spi.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 513e6c7..24ca7df 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -296,8 +296,9 @@ qcaspi_receive(struct qcaspi *qca)
 
 	/* Allocate rx SKB if we don't have one available. */
 	if (!qca->rx_skb) {
-		qca->rx_skb = netdev_alloc_skb(net_dev,
-					       net_dev->mtu + VLAN_ETH_HLEN);
+		qca->rx_skb = netdev_alloc_skb_ip_align(net_dev,
+							net_dev->mtu +
+							VLAN_ETH_HLEN);
 		if (!qca->rx_skb) {
 			netdev_dbg(net_dev, "out of RX resources\n");
 			qca->stats.out_of_mem++;
@@ -377,7 +378,7 @@ qcaspi_receive(struct qcaspi *qca)
 					qca->rx_skb, qca->rx_skb->dev);
 				qca->rx_skb->ip_summed = CHECKSUM_UNNECESSARY;
 				netif_rx_ni(qca->rx_skb);
-				qca->rx_skb = netdev_alloc_skb(net_dev,
+				qca->rx_skb = netdev_alloc_skb_ip_align(net_dev,
 					net_dev->mtu + VLAN_ETH_HLEN);
 				if (!qca->rx_skb) {
 					netdev_dbg(net_dev, "out of RX resources\n");
@@ -759,7 +760,8 @@ qcaspi_netdev_init(struct net_device *dev)
 	if (!qca->rx_buffer)
 		return -ENOBUFS;
 
-	qca->rx_skb = netdev_alloc_skb(dev, qca->net_dev->mtu + VLAN_ETH_HLEN);
+	qca->rx_skb = netdev_alloc_skb_ip_align(dev, qca->net_dev->mtu +
+						VLAN_ETH_HLEN);
 	if (!qca->rx_skb) {
 		kfree(qca->rx_buffer);
 		netdev_info(qca->net_dev, "Failed to allocate RX sk_buff.\n");
-- 
2.1.4
