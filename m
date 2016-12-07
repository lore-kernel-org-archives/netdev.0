From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 2/4] mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs
Date: Tue, 6 Dec 2016 21:31:52 -0800
Message-ID: <1481088714-54512-3-git-send-email-kafai@fb.com>
References: <1481088714-54512-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46825 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932110AbcLGFb6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 00:31:58 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB75U8Kl012485
        for <netdev@vger.kernel.org>; Tue, 6 Dec 2016 21:31:58 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 27648f6aup-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 21:31:58 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 778b8526bc3e11e6aad20002c992ebde-625faa50 for <netdev@vger.kernel.org>;        Tue,
 06 Dec 2016 21:31:56 -0800
In-Reply-To: <1481088714-54512-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When XDP is active in mlx4, mlx4 is using one page/pkt.
At the same time (i.e. when XDP is active), it is currently
limiting MTU to be FRAG_SZ0 - ETH_HLEN - (2 * VLAN_HLEN)
which is 1514 in x86.  AFAICT, we can at least raise the MTU
limit up to PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN) which this
patch is doing.  It will be useful in the next patch which
allows XDP program to extend the packet by adding new header(s).

Note: In the earlier XDP patches, there is already existing guard
to ensure the page/pkt scheme only applies when XDP is active
in mlx4.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 28 +++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 46 ++++++++++++++------------
 2 files changed, 44 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 6261157f444e..5482591688f8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -51,6 +51,8 @@
 #include "mlx4_en.h"
 #include "en_port.h"
 
+#define MLX4_EN_MAX_XDP_MTU ((int)(PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN)))
+
 int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -2249,6 +2251,19 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	free_netdev(dev);
 }
 
+static bool mlx4_en_check_xdp_mtu(struct net_device *dev, int mtu)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	if (mtu > MLX4_EN_MAX_XDP_MTU) {
+		en_err(priv, "mtu:%d > max:%d when XDP prog is attached\n",
+		       mtu, MLX4_EN_MAX_XDP_MTU);
+		return false;
+	}
+
+	return true;
+}
+
 static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -2258,11 +2273,10 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 	en_dbg(DRV, priv, "Change MTU called - current:%d new:%d\n",
 		 dev->mtu, new_mtu);
 
-	if (priv->tx_ring_num[TX_XDP] && MLX4_EN_EFF_MTU(new_mtu) > FRAG_SZ0) {
-		en_err(priv, "MTU size:%d requires frags but XDP running\n",
-		       new_mtu);
-		return -EOPNOTSUPP;
-	}
+	if (priv->tx_ring_num[TX_XDP] &&
+	    !mlx4_en_check_xdp_mtu(dev, new_mtu))
+		return -ENOTSUPP;
+
 	dev->mtu = new_mtu;
 
 	if (netif_running(dev)) {
@@ -2710,10 +2724,8 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		return 0;
 	}
 
-	if (priv->num_frags > 1) {
-		en_err(priv, "Cannot set XDP if MTU requires multiple frags\n");
+	if (!mlx4_en_check_xdp_mtu(dev, dev->mtu))
 		return -EOPNOTSUPP;
-	}
 
 	tmp = kzalloc(sizeof(*tmp), GFP_KERNEL);
 	if (!tmp)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 6562f78b07f4..23e9d04d1ef4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1164,37 +1164,39 @@ static const int frag_sizes[] = {
 
 void mlx4_en_calc_rx_buf(struct net_device *dev)
 {
-	enum dma_data_direction dma_dir = PCI_DMA_FROMDEVICE;
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int eff_mtu = MLX4_EN_EFF_MTU(dev->mtu);
-	int order = MLX4_EN_ALLOC_PREFER_ORDER;
-	u32 align = SMP_CACHE_BYTES;
-	int buf_size = 0;
 	int i = 0;
 
 	/* bpf requires buffers to be set up as 1 packet per page.
 	 * This only works when num_frags == 1.
 	 */
 	if (priv->tx_ring_num[TX_XDP]) {
-		dma_dir = PCI_DMA_BIDIRECTIONAL;
-		/* This will gain efficient xdp frame recycling at the expense
-		 * of more costly truesize accounting
+		priv->frag_info[0].order = 0;
+		priv->frag_info[0].frag_size = eff_mtu;
+		priv->frag_info[0].frag_prefix_size = 0;
+		/* This will gain efficient xdp frame recycling at the
+		 * expense of more costly truesize accounting
 		 */
-		align = PAGE_SIZE;
-		order = 0;
-	}
-
-	while (buf_size < eff_mtu) {
-		priv->frag_info[i].order = order;
-		priv->frag_info[i].frag_size =
-			(eff_mtu > buf_size + frag_sizes[i]) ?
-				frag_sizes[i] : eff_mtu - buf_size;
-		priv->frag_info[i].frag_prefix_size = buf_size;
-		priv->frag_info[i].frag_stride =
-				ALIGN(priv->frag_info[i].frag_size, align);
-		priv->frag_info[i].dma_dir = dma_dir;
-		buf_size += priv->frag_info[i].frag_size;
-		i++;
+		priv->frag_info[0].frag_stride = PAGE_SIZE;
+		priv->frag_info[0].dma_dir = PCI_DMA_BIDIRECTIONAL;
+		i = 1;
+	} else {
+		int buf_size = 0;
+
+		while (buf_size < eff_mtu) {
+			priv->frag_info[i].order = MLX4_EN_ALLOC_PREFER_ORDER;
+			priv->frag_info[i].frag_size =
+				(eff_mtu > buf_size + frag_sizes[i]) ?
+					frag_sizes[i] : eff_mtu - buf_size;
+			priv->frag_info[i].frag_prefix_size = buf_size;
+			priv->frag_info[i].frag_stride =
+				ALIGN(priv->frag_info[i].frag_size,
+				      SMP_CACHE_BYTES);
+			priv->frag_info[i].dma_dir = PCI_DMA_FROMDEVICE;
+			buf_size += priv->frag_info[i].frag_size;
+			i++;
+		}
 	}
 
 	priv->num_frags = i;
-- 
2.5.1
