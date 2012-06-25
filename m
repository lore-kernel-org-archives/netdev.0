From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 5/6] tuntap: per queue 64 bit stats
Date: Mon, 25 Jun 2012 19:59:22 +0800
Message-ID: <1340625563-9300-6-git-send-email-jasowang@redhat.com>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
Cc: shemminger@vyatta.com, edumazet@google.com,
	Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, akong@redhat.com, habanero@linux.vnet.ibm.com,
	tahm@linux.vnet.ibm.com, haixiao@juniper.net,
	jwhan@filewood.snu.ac.kr, ernesto.martin@viasat.com,
	mashirle@us.ibm.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, krkumar2@in.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As we've added multiqueue support for tun/tap, this patch convert the statistics
to use per-queue 64 bit statistics.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |  105 ++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 83 insertions(+), 22 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 5c26757..37e62d3 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -64,6 +64,7 @@
 #include <linux/nsproxy.h>
 #include <linux/virtio_net.h>
 #include <linux/rcupdate.h>
+#include <linux/u64_stats_sync.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
@@ -109,6 +110,19 @@ struct tap_filter {
 
 #define MAX_TAP_QUEUES (NR_CPUS < 16 ? NR_CPUS : 16)
 
+struct tun_queue_stats {
+	u64			rx_packets;
+	u64			rx_bytes;
+	u64			tx_packets;
+	u64			tx_bytes;
+	struct u64_stats_sync	rx_syncp;
+	struct u64_stats_sync	tx_syncp;
+	u32			rx_dropped;
+	u32			tx_dropped;
+	u32			rx_frame_errors;
+	u32			tx_fifo_errors;
+};
+
 struct tun_file {
 	struct sock sk;
 	struct socket socket;
@@ -119,6 +133,7 @@ struct tun_file {
 	struct tun_struct __rcu *tun;
 	struct net *net;
 	struct fasync_struct *fasync;
+	struct tun_queue_stats stats;
 	unsigned int flags;
 	u16 queue_index;
 };
@@ -134,6 +149,7 @@ struct tun_struct {
 
 	struct net_device	*dev;
 	netdev_features_t	set_features;
+	struct tun_queue_stats	stats;
 #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
 			  NETIF_F_TSO6|NETIF_F_UFO)
 
@@ -463,7 +479,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 
 			/* We won't see all dropped packets individually, so overrun
 			 * error is more appropriate. */
-			dev->stats.tx_fifo_errors++;
+			tfile->stats.tx_fifo_errors++;
 		} else {
 			/* Single queue mode or multi queue mode.
 			 * Driver handles dropping of all packets itself. */
@@ -488,7 +504,8 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 
 drop:
 	rcu_read_unlock();
-	dev->stats.tx_dropped++;
+	if (tfile)
+		tfile->stats.tx_dropped++;
 	kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
@@ -538,6 +555,56 @@ static void tun_poll_controller(struct net_device *dev)
 	return;
 }
 #endif
+
+static struct rtnl_link_stats64 *tun_net_stats(struct net_device *dev,
+					       struct rtnl_link_stats64 *stats)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	struct tun_file *tfile;
+	struct tun_queue_stats *qstats;
+	u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+	u32 rx_dropped = 0, tx_dropped = 0,
+	    rx_frame_errors = 0, tx_fifo_errors = 0;
+	unsigned int start;
+	int i;
+
+	rcu_read_lock();
+	for (i = 0; i < tun->numqueues; i++) {
+		tfile = rcu_dereference(tun->tfiles[i]);
+		qstats = &tfile->stats;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&qstats->rx_syncp);
+			rx_packets = qstats->rx_packets;
+			rx_bytes = qstats->rx_bytes;
+		} while (u64_stats_fetch_retry_bh(&qstats->rx_syncp, start));
+
+		do {
+			start = u64_stats_fetch_begin_bh(&qstats->tx_syncp);
+			tx_packets = qstats->tx_packets;
+			tx_bytes = qstats->tx_bytes;
+		} while (u64_stats_fetch_retry_bh(&qstats->tx_syncp, start));
+
+		stats->rx_packets += rx_packets;
+		stats->rx_bytes	+= rx_bytes;
+		stats->tx_packets += tx_packets;
+		stats->tx_bytes	+= tx_bytes;
+		/* following fileds are u32, no need syncp */
+		rx_dropped += qstats->rx_dropped;
+		tx_dropped += qstats->tx_dropped;
+		rx_frame_errors += qstats->rx_frame_errors;
+		tx_fifo_errors += qstats->tx_fifo_errors;
+	}
+	rcu_read_unlock();
+
+	stats->rx_dropped = rx_dropped;
+	stats->tx_dropped = tx_dropped;
+	stats->rx_frame_errors = rx_frame_errors;
+	stats->tx_fifo_errors = tx_fifo_errors;
+
+	return stats;
+}
+
 static const struct net_device_ops tun_netdev_ops = {
 	.ndo_uninit		= tun_net_uninit,
 	.ndo_open		= tun_net_open,
@@ -545,6 +612,7 @@ static const struct net_device_ops tun_netdev_ops = {
 	.ndo_start_xmit		= tun_net_xmit,
 	.ndo_change_mtu		= tun_net_change_mtu,
 	.ndo_fix_features	= tun_net_fix_features,
+	.ndo_get_stats64	= tun_net_stats,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tun_poll_controller,
 #endif
@@ -560,6 +628,7 @@ static const struct net_device_ops tap_netdev_ops = {
 	.ndo_set_rx_mode	= tun_net_mclist,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_get_stats64	= tun_net_stats,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tun_poll_controller,
 #endif
@@ -808,30 +877,25 @@ static ssize_t tun_get_user(struct tun_file *tfile,
 		skb->protocol = eth_type_trans(skb, tun->dev);
 		break;
 	}
-	tun->dev->stats.rx_packets++;
-	tun->dev->stats.rx_bytes += len;
 	rcu_read_unlock();
 
 	netif_rx_ni(skb);
 
+	u64_stats_update_begin(&tfile->stats.rx_syncp);
+	tfile->stats.rx_packets++;
+	tfile->stats.rx_bytes += len;
+	u64_stats_update_end(&tfile->stats.rx_syncp);
+
 	return count;
 
 err_free:
 	count = -EINVAL;
 	kfree_skb(skb);
 err:
-	rcu_read_lock();
-	tun = rcu_dereference(tfile->tun);
-	if (!tun) {
-		rcu_read_unlock();
-		return -EBADFD;
-	}
-
 	if (drop)
-		tun->dev->stats.rx_dropped++;
+		tfile->stats.rx_dropped++;
 	if (error)
-		tun->dev->stats.rx_frame_errors++;
-	rcu_read_unlock();
+		tfile->stats.rx_frame_errors++;
 	return count;
 }
 
@@ -853,7 +917,6 @@ static ssize_t tun_put_user(struct tun_file *tfile,
 			    struct sk_buff *skb,
 			    const struct iovec *iv, int len)
 {
-	struct tun_struct *tun = NULL;
 	struct tun_pi pi = { 0, skb->protocol };
 	ssize_t total = 0;
 
@@ -925,13 +988,10 @@ static ssize_t tun_put_user(struct tun_file *tfile,
 	skb_copy_datagram_const_iovec(skb, 0, iv, total, len);
 	total += skb->len;
 
-	rcu_read_lock();
-	tun = rcu_dereference(tfile->tun);
-	if (tun) {
-		tun->dev->stats.tx_packets++;
-		tun->dev->stats.tx_bytes += len;
-	}
-	rcu_read_unlock();
+	u64_stats_update_begin(&tfile->stats.tx_syncp);
+	tfile->stats.tx_packets++;
+	tfile->stats.tx_bytes += total;
+	u64_stats_update_end(&tfile->stats.tx_syncp);
 
 	return total;
 }
@@ -1650,6 +1710,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 	tfile->socket.file = file;
 	tfile->socket.ops = &tun_socket_ops;
 	sock_init_data(&tfile->socket, &tfile->sk);
+	memset(&tfile->stats, 0, sizeof(struct tun_queue_stats));
 
 	tfile->sk.sk_write_space = tun_sock_write_space;
 	tfile->sk.sk_destruct = tun_sock_destruct;
-- 
1.7.1
