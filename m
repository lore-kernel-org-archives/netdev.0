From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH 14/15] mlx4: Convert to advertise NETIF_F_HW_CSUM
Date: Thu, 19 Nov 2015 11:56:00 -0800
Message-ID: <1447962961-2106059-15-git-send-email-tom@herbertland.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:30358 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964803AbbKST4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:23 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tAJJrARk032537
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:22 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1y8rtt6ncs-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:22 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 9ae99eec8ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:21 -0800
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb_csum_offload_chk is used to resolve checksums that are unable
to be offloaded to the device.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 16 ++++++++++++++--
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 659209f..7bc2b90 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2339,7 +2339,7 @@ out:
 	}
 
 	/* set offloads */
-	priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+	priv->dev->hw_enc_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
 				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL;
 	priv->dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
 	priv->dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
@@ -2351,7 +2351,7 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
 	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
 						 vxlan_del_task);
 	/* unset offloads */
-	priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+	priv->dev->hw_enc_features &= ~(NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
 				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL);
 	priv->dev->hw_features &= ~NETIF_F_GSO_UDP_TUNNEL;
 	priv->dev->features    &= ~NETIF_F_GSO_UDP_TUNNEL;
@@ -2918,7 +2918,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	/*
 	 * Set driver features
 	 */
-	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
 	if (mdev->LSO_support)
 		dev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 4421bf5..34929d5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -702,6 +702,17 @@ static void mlx4_bf_copy(void __iomem *dst, const void *src,
 	__iowrite64_copy(dst, src, bytecnt / 8);
 }
 
+static const struct skb_csum_offl_spec csum_offl_spec = {
+	.ipv4_okay = 1,
+	.ip_options_okay = 1,
+	.ipv6_okay = 1,
+	.encap_okay = 1,
+	.no_encapped_ipv6 = 1,
+	.vlan_okay = 1,
+	.tcp_okay = 1,
+	.udp_okay = 1,
+};
+
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
@@ -727,6 +738,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	bool stop_queue;
 	bool inline_ok;
 	u32 ring_cons;
+	bool csum_encapped;
 
 	if (!priv->port_up)
 		goto tx_drop;
@@ -853,8 +865,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Prepare ctrl segement apart opcode+ownership, which depends on
 	 * whether LSO is used */
 	tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
-	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
-		if (!skb->encapsulation)
+	if (skb_csum_offload_chk(skb, &csum_offl_spec, &csum_encapped, true)) {
+		if (!csum_encapped)
 			tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
 								 MLX4_WQE_CTRL_TCP_UDP_CSUM);
 		else
-- 
2.4.6
