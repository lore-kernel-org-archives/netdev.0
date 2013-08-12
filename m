From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next] net/mlx4_en: Advertise HIGH DMA support only if dma mask is 64 bit
Date: Mon, 12 Aug 2013 11:30:30 +0300
Message-ID: <1376296230-12276-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Alexander Guller <alexg@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:60720 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755215Ab3HLIbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Aug 2013 04:31:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to check that the pci device DMA mask was set to 64 bit support
(done by mlx4_core) before advertising HIGH DMA support in higher drivers.
Otherwise, may run into an issue that skb/frag/data is in high memory
and can't dma map it, thus packets are dropped.


Signed-off-by: Alexander Guller <alexg@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index fa37b7a..9568b77 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2317,9 +2317,13 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	dev->vlan_features = dev->hw_features;
 
 	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_RXHASH;
-	dev->features = dev->hw_features | NETIF_F_HIGHDMA |
+	dev->features = dev->hw_features |
 			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
 			NETIF_F_HW_VLAN_CTAG_FILTER;
+
+	if (mdev->dev->pdev->dma_mask == DMA_BIT_MASK(64))
+		dev->features |= NETIF_F_HIGHDMA;
+
 	dev->hw_features |= NETIF_F_LOOPBACK;
 
 	if (mdev->dev->caps.steering_mode ==
-- 
1.8.3.4
