From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] mlx4_en: add UFO support
Date: Thu,  2 Aug 2012 17:53:44 -0300
Message-ID: <1343940824-4720-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:42014 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab2HBUyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 16:54:21 -0400
Received: from /spool/local
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Thu, 2 Aug 2012 17:54:02 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id D1D661DC0050
	for <netdev@vger.kernel.org>; Thu,  2 Aug 2012 16:53:47 -0400 (EDT)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q72Ko3FS2621652
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2012 17:50:04 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q72Krkub014872
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2012 17:53:46 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mellanox Ethernet adapters support Large Segmentation Offload for UDP
packets. The only change needed is using the proper header size when the
packet is UDP instead of TCP.

This significantly increases performance for large UDP packets on
platforms which have an expensive dma_map call, like pseries.

On a simple test with 64000 payload size, throughput has increased from
about 6Gbps to 9.5Gbps, while CPU use dropped from about 600% to about
80% or less, on a 8-core Power7 machine.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    7 ++++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index edd9cb8..59e808a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1660,7 +1660,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	 */
 	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	if (mdev->LSO_support)
-		dev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
+		dev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_UFO;
 
 	dev->vlan_features = dev->hw_features;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 019d856..2aad5a4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -39,6 +39,7 @@
 #include <linux/if_vlan.h>
 #include <linux/vmalloc.h>
 #include <linux/tcp.h>
+#include <linux/udp.h>
 #include <linux/moduleparam.h>
 
 #include "mlx4_en.h"
@@ -455,7 +456,11 @@ static int get_real_size(struct sk_buff *skb, struct net_device *dev,
 	int real_size;
 
 	if (skb_is_gso(skb)) {
-		*lso_header_size = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		*lso_header_size = skb_transport_offset(skb);
+		if (skb_shinfo(skb)->gso_type == SKB_GSO_UDP)
+			*lso_header_size += sizeof(struct udphdr);
+		else
+			*lso_header_size += tcp_hdrlen(skb);
 		real_size = CTRL_SIZE + skb_shinfo(skb)->nr_frags * DS_SIZE +
 			ALIGN(*lso_header_size + 4, DS_SIZE);
 		if (unlikely(*lso_header_size != skb_headlen(skb))) {
-- 
1.7.4.4
