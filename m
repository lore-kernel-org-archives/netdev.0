From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: optimize xmit path
Date: Sun, 28 Sep 2014 09:03:07 -0700
Message-ID: <1411920187.15768.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
	 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>
	 <1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMiVXonPkJsve2UuWtTs2wqBnV_jrYMuJ1yvccBTeAFM2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>, saeedm@mellanox.com,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, idos@mellanox.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33714 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbaI1QDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 12:03:09 -0400
Received: by mail-pd0-f170.google.com with SMTP id ft15so68348pdb.1
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 09:03:08 -0700 (PDT)
In-Reply-To: <CAJ3xEMiVXonPkJsve2UuWtTs2wqBnV_jrYMuJ1yvccBTeAFM2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-09-28 at 17:35 +0300, Or Gerlitz wrote:
> On Sun, Sep 28, 2014 at 1:56 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > First I implemented skb->xmit_more support, and pktgen throughput
> > went from ~5Mpps to ~10Mpps.
> >
> > Then, looking closely at this driver I found false sharing problems that
> > should be addressed by this patch, as my pktgen now reaches 14.7 Mpps
> > on a single TX queue, with a burst factor of 8.
> >
> > So this patch in a whole permits to improve raw performance on a single
> > TX queue from about 5 Mpps to 14.7 Mpps.
> 
> Eric,
> 
> cool!! the team here will take a look this week. I assume we might
> want to break the fifteen changes into multiple patches...
> 
> Thanks again for all your great work

Another problem I noticed is the false sharing on
prot_stats.tso_packets.

Please add following fix to your queue.

Thanks !

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index c2cfb05e7290..5bd33e580b22 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -150,14 +150,17 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	priv->port_stats.tx_chksum_offload = 0;
 	priv->port_stats.queue_stopped = 0;
 	priv->port_stats.wake_queue = 0;
+	priv->port_stats.tso_packets = 0;
 
 	for (i = 0; i < priv->tx_ring_num; i++) {
-		stats->tx_packets += priv->tx_ring[i]->packets;
-		stats->tx_bytes += priv->tx_ring[i]->bytes;
-		priv->port_stats.tx_chksum_offload += priv->tx_ring[i]->tx_csum;
-		priv->port_stats.queue_stopped +=
-			priv->tx_ring[i]->queue_stopped;
-		priv->port_stats.wake_queue += priv->tx_ring[i]->wake_queue;
+		struct mlx4_en_tx_ring *ring = priv->tx_ring[i];
+
+		stats->tx_packets += ring->packets;
+		stats->tx_bytes += ring->bytes;
+		priv->port_stats.tx_chksum_offload += ring->tx_csum;
+		priv->port_stats.queue_stopped += ring->queue_stopped;
+		priv->port_stats.wake_queue += ring->wake_queue;
+		priv->port_stats.tso_packets += ring->tso_packets;
 	}
 
 	stats->rx_errors = be64_to_cpu(mlx4_en_stats->PCS) +
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index c44f4237b9be..7bb156e99894 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -839,7 +839,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * note that we already verified that it is linear */
 		memcpy(tx_desc->lso.header, skb->data, lso_header_size);
 
-		priv->port_stats.tso_packets++;
+		ring->tso_packets++;
+
 		i = ((skb->len - lso_header_size) / skb_shinfo(skb)->gso_size) +
 			!!((skb->len - lso_header_size) % skb_shinfo(skb)->gso_size);
 		tx_info->nr_bytes = skb->len + (i - 1) * lso_header_size;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 6a4fc2394cf2..007645c4edc0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -277,6 +277,7 @@ struct mlx4_en_tx_ring {
 	unsigned long bytes;
 	unsigned long packets;
 	unsigned long tx_csum;
+	unsigned long tso_packets;
 	unsigned long queue_stopped;
 	unsigned long wake_queue;
 	struct mlx4_bf bf;
