From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 3/3] mlx4: Call skb_csum_offload_check to check offloadability
Date: Mon, 5 Oct 2015 16:39:24 -0700
Message-ID: <1444088364-2839440-4-git-send-email-tom@herbertland.com>
References: <1444088364-2839440-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <dwmw2@infradead.org>,
	<ogerlitz@mellanox.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46771 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750780AbbJEXnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 19:43:16 -0400
Received: from pps.filterd (m0001303 [127.0.0.1])
	by m0001303.ppops.net (8.14.5/8.14.5) with SMTP id t95NcYdl007314
	for <netdev@vger.kernel.org>; Mon, 5 Oct 2015 16:43:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1xc2ujg1jc-8
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 16:43:15 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 620201066bba11e58e6a24be05956610-edbfa240 for <netdev@vger.kernel.org>;	Mon,
 05 Oct 2015 16:39:56 -0700
In-Reply-To: <1444088364-2839440-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides an example of a driver calling the skb_csum_offload_check.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 20 +++++++++++++++-----
 2 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 4726122..f2ed8d0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2360,7 +2360,7 @@ out:
 	}
 
 	/* set offloads */
-	priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+	priv->dev->hw_enc_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
 				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL;
 	priv->dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
 	priv->dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
@@ -2372,7 +2372,7 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
 	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
 						 vxlan_del_task);
 	/* unset offloads */
-	priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+	priv->dev->hw_enc_features &= ~(NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
 				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL);
 	priv->dev->hw_features &= ~NETIF_F_GSO_UDP_TUNNEL;
 	priv->dev->features    &= ~NETIF_F_GSO_UDP_TUNNEL;
@@ -2943,7 +2943,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	/*
 	 * Set driver features
 	 */
-	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
 	if (mdev->LSO_support)
 		dev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 494e776..f364ffd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -702,6 +702,14 @@ static void mlx4_bf_copy(void __iomem *dst, const void *src,
 	__iowrite64_copy(dst, src, bytecnt / 8);
 }
 
+static const struct skb_csum_offl_spec csum_offl_spec = {
+	.ipv4_okay = 1,
+	.ipv6_okay = 1,
+	.encap_okay = 1,
+	.tcp_okay = 1,
+	.udp_okay = 1,
+};
+
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
@@ -727,6 +735,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	bool stop_queue;
 	bool inline_ok;
 	u32 ring_cons;
+	struct skb_csum_offl_params offl_params;
 
 	if (!priv->port_up)
 		goto tx_drop;
@@ -853,8 +862,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Prepare ctrl segement apart opcode+ownership, which depends on
 	 * whether LSO is used */
 	tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
-	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
-		if (!skb->encapsulation)
+	if (skb_csum_offload_chk(skb, &csum_offl_spec,
+				 &offl_params, true)) {
+		if (!offl_params.encapped_csum)
 			tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
 								 MLX4_WQE_CTRL_TCP_UDP_CSUM);
 		else
@@ -912,9 +922,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		build_inline_wqe(tx_desc, skb, shinfo, real_size, &vlan_tag,
 				 tx_ind, fragptr);
 
-	if (skb->encapsulation) {
-		struct iphdr *ipv4 = (struct iphdr *)skb_inner_network_header(skb);
-		if (ipv4->protocol == IPPROTO_TCP || ipv4->protocol == IPPROTO_UDP)
+	if (!offl_params.encapped_csum) {
+		if (offl_params.ip_proto == IPPROTO_TCP ||
+		    offl_params.ip_proto == IPPROTO_UDP)
 			op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP | MLX4_WQE_CTRL_ILP);
 		else
 			op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP);
-- 
2.4.6
