From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 10/14] mlx4: add rx_alloc_pages counter in ethtool -S
Date: Thu,  9 Feb 2017 05:58:34 -0800
Message-ID: <20170209135838.16487-11-edumazet@google.com>
References: <20170209135838.16487-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33906 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752284AbdBIOGY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:06:24 -0500
Received: by mail-pf0-f170.google.com with SMTP id e4so1008508pfg.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:06:19 -0800 (PST)
In-Reply-To: <20170209135838.16487-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new counter tracks number of pages that we allocated for one port.

lpaa24:~# ethtool -S eth0 | egrep 'rx_alloc_pages|rx_packets'
     rx_packets: 306755183
     rx_alloc_pages: 932897

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |  2 ++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 11 +++++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h |  2 +-
 5 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index c4d714fcc7dae759998a49a1f90f9ab1ee9b..ffbcb27c05e55f43630a812249bab2160988 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -117,7 +117,7 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 	/* port statistics */
 	"tso_packets",
 	"xmit_more",
-	"queue_stopped", "wake_queue", "tx_timeout", "rx_alloc_failed",
+	"queue_stopped", "wake_queue", "tx_timeout", "rx_alloc_pages",
 	"rx_csum_good", "rx_csum_none", "rx_csum_complete", "tx_chksum_offload",
 
 	/* pf statistics */
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 9166d90e732858610b1407fe85cbf6cbe27f..e0eb695318e64ebcaf58d6edb5f9a57be6f9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -213,6 +213,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	priv->port_stats.rx_chksum_good = 0;
 	priv->port_stats.rx_chksum_none = 0;
 	priv->port_stats.rx_chksum_complete = 0;
+	priv->port_stats.rx_alloc_pages = 0;
 	priv->xdp_stats.rx_xdp_drop    = 0;
 	priv->xdp_stats.rx_xdp_tx      = 0;
 	priv->xdp_stats.rx_xdp_tx_full = 0;
@@ -223,6 +224,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 		priv->port_stats.rx_chksum_good += READ_ONCE(ring->csum_ok);
 		priv->port_stats.rx_chksum_none += READ_ONCE(ring->csum_none);
 		priv->port_stats.rx_chksum_complete += READ_ONCE(ring->csum_complete);
+		priv->port_stats.rx_alloc_pages += READ_ONCE(ring->rx_alloc_pages);
 		priv->xdp_stats.rx_xdp_drop	+= READ_ONCE(ring->xdp_drop);
 		priv->xdp_stats.rx_xdp_tx	+= READ_ONCE(ring->xdp_tx);
 		priv->xdp_stats.rx_xdp_tx_full	+= READ_ONCE(ring->xdp_tx_full);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index e737372a9b87428c4bab55a812274fbe4110..db2bceeb7e6405db0dbf45fdd20d47faae77 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -72,6 +72,7 @@ static int mlx4_alloc_page(struct mlx4_en_priv *priv,
 }
 
 static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
+			       struct mlx4_en_rx_ring *ring,
 			       struct mlx4_en_rx_desc *rx_desc,
 			       struct mlx4_en_rx_alloc *frags,
 			       gfp_t gfp)
@@ -79,8 +80,11 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
 	int i;
 
 	for (i = 0; i < priv->num_frags; i++, frags++) {
-		if (!frags->page && mlx4_alloc_page(priv, frags, gfp))
-			return -ENOMEM;
+		if (!frags->page) {
+			if (mlx4_alloc_page(priv, frags, gfp))
+				return -ENOMEM;
+			ring->rx_alloc_pages++;
+		}
 		rx_desc->data[i].addr = cpu_to_be64(frags->dma +
 						    frags->page_offset);
 	}
@@ -133,7 +137,6 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
 	struct mlx4_en_rx_desc *rx_desc = ring->buf + (index * ring->stride);
 	struct mlx4_en_rx_alloc *frags = ring->rx_info +
 					(index << priv->log_rx_info);
-
 	if (ring->page_cache.index > 0) {
 		/* XDP uses a single page per frame */
 		if (!frags->page) {
@@ -147,7 +150,7 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
 		return 0;
 	}
 
-	return mlx4_en_alloc_frags(priv, rx_desc, frags, gfp);
+	return mlx4_en_alloc_frags(priv, ring, rx_desc, frags, gfp);
 }
 
 static bool mlx4_en_is_ring_empty(const struct mlx4_en_rx_ring *ring)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 3c93b9614e0674e904d33b83e041f348d4f2..52f157cea7765ad6907c59aead357a158848 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -346,6 +346,7 @@ struct mlx4_en_rx_ring {
 	unsigned long csum_ok;
 	unsigned long csum_none;
 	unsigned long csum_complete;
+	unsigned long rx_alloc_pages;
 	unsigned long xdp_drop;
 	unsigned long xdp_tx;
 	unsigned long xdp_tx_full;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
index 48641cb0367f251a07537b82d0a16bf50d84..926f3c3f3665c5d28fe5d35c41afaa0e5917 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
@@ -37,7 +37,7 @@ struct mlx4_en_port_stats {
 	unsigned long queue_stopped;
 	unsigned long wake_queue;
 	unsigned long tx_timeout;
-	unsigned long rx_alloc_failed;
+	unsigned long rx_alloc_pages;
 	unsigned long rx_chksum_good;
 	unsigned long rx_chksum_none;
 	unsigned long rx_chksum_complete;
-- 
2.11.0.483.g087da7b7c-goog
