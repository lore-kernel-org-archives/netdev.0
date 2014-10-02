From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: add a new xmit_more counter
Date: Thu, 02 Oct 2014 08:24:21 -0700
Message-ID: <1412263461.16704.107.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001203345.3321.99675.stgit@dragon>
	 <CA+mtBx8ecpd+S+E2o8A+Hzp3i2SO7XO0+F_DYA0ng+fjta7G5A@mail.gmail.com>
	 <1412262270.16704.103.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	TomHerbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:48103 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbaJBPYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 11:24:24 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so2675263pab.2
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 08:24:24 -0700 (PDT)
In-Reply-To: <1412262270.16704.103.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ethtool -S reports a new counter, tracking number of time doorbell
was not triggered, because skb->xmit_more was set.

$ ethtool -S eth0 | egrep "tx_packet|xmit_more"
     tx_packets: 2413288400
     xmit_more: 666121277

I merged the tso_packet false sharing avoidance in this patch as well.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    1 
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |   17 +++++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |    4 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    5 +++-
 4 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 35ff2925110a..42c9f8b09a6e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -112,6 +112,7 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 
 	/* port statistics */
 	"tso_packets",
+	"xmit_more",
 	"queue_stopped", "wake_queue", "tx_timeout", "rx_alloc_failed",
 	"rx_csum_good", "rx_csum_none", "tx_chksum_offload",
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index c2cfb05e7290..0a0261d128b9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -150,14 +150,19 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	priv->port_stats.tx_chksum_offload = 0;
 	priv->port_stats.queue_stopped = 0;
 	priv->port_stats.wake_queue = 0;
+	priv->port_stats.tso_packets = 0;
+	priv->port_stats.xmit_more = 0;
 
 	for (i = 0; i < priv->tx_ring_num; i++) {
-		stats->tx_packets += priv->tx_ring[i]->packets;
-		stats->tx_bytes += priv->tx_ring[i]->bytes;
-		priv->port_stats.tx_chksum_offload += priv->tx_ring[i]->tx_csum;
-		priv->port_stats.queue_stopped +=
-			priv->tx_ring[i]->queue_stopped;
-		priv->port_stats.wake_queue += priv->tx_ring[i]->wake_queue;
+		const struct mlx4_en_tx_ring *ring = priv->tx_ring[i];
+
+		stats->tx_packets += ring->packets;
+		stats->tx_bytes += ring->bytes;
+		priv->port_stats.tx_chksum_offload += ring->tx_csum;
+		priv->port_stats.queue_stopped     += ring->queue_stopped;
+		priv->port_stats.wake_queue        += ring->wake_queue;
+		priv->port_stats.tso_packets       += ring->tso_packets;
+		priv->port_stats.xmit_more         += ring->xmit_more;
 	}
 
 	stats->rx_errors = be64_to_cpu(mlx4_en_stats->PCS) +
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index adedc47e947d..0c501253fdab 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -840,7 +840,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * note that we already verified that it is linear */
 		memcpy(tx_desc->lso.header, skb->data, lso_header_size);
 
-		priv->port_stats.tso_packets++;
+		ring->tso_packets++;
 		i = ((skb->len - lso_header_size) / skb_shinfo(skb)->gso_size) +
 			!!((skb->len - lso_header_size) % skb_shinfo(skb)->gso_size);
 		tx_info->nr_bytes = skb->len + (i - 1) * lso_header_size;
@@ -910,6 +910,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 			wmb();
 			iowrite32be(ring->doorbell_qpn,
 				    ring->bf.uar->map + MLX4_SEND_DOORBELL);
+		} else {
+			ring->xmit_more++;
 		}
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 6a4fc2394cf2..84c9d5dbfa4f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -279,6 +279,8 @@ struct mlx4_en_tx_ring {
 	unsigned long tx_csum;
 	unsigned long queue_stopped;
 	unsigned long wake_queue;
+	unsigned long tso_packets;
+	unsigned long xmit_more;
 	struct mlx4_bf bf;
 	bool bf_enabled;
 	bool bf_alloced;
@@ -426,6 +428,7 @@ struct mlx4_en_pkt_stats {
 
 struct mlx4_en_port_stats {
 	unsigned long tso_packets;
+	unsigned long xmit_more;
 	unsigned long queue_stopped;
 	unsigned long wake_queue;
 	unsigned long tx_timeout;
@@ -433,7 +436,7 @@ struct mlx4_en_port_stats {
 	unsigned long rx_chksum_good;
 	unsigned long rx_chksum_none;
 	unsigned long tx_chksum_offload;
-#define NUM_PORT_STATS		8
+#define NUM_PORT_STATS		9
 };
 
 struct mlx4_en_perf_stats {
