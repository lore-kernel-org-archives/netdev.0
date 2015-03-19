From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH v1 net-next] tuntap: convert to 64-bit interface statistics
Date: Thu, 19 Mar 2015 12:51:29 -0700
Message-ID: <1426794689-29943-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, Curt Brune <curt@cumulusnetworks.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34840 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbbCSUDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 16:03:39 -0400
Received: by pdbop1 with SMTP id op1so85716870pdb.2
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 13:03:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Curt Brune <curt@cumulusnetworks.com>
Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 drivers/net/tun.c |   54 ++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 43 insertions(+), 11 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b96b94c..be8941a 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -65,6 +65,7 @@
 #include <linux/nsproxy.h>
 #include <linux/virtio_net.h>
 #include <linux/rcupdate.h>
+#include <linux/u64_stats_sync.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
@@ -204,6 +205,9 @@ struct tun_struct {
 	struct list_head disabled;
 	void *security;
 	u32 flow_count;
+	spinlock_t			stat_lock;
+	struct u64_stats_sync		stat_sync;
+	struct rtnl_link_stats64	stats64;
 };
 
 static inline u16 tun16_to_cpu(struct tun_struct *tun, __virtio16 val)
@@ -751,6 +755,16 @@ static int tun_net_close(struct net_device *dev)
 	return 0;
 }
 
+static __always_inline void tun_stat64_inc(struct tun_struct *tun, u64 *stat,
+					   size_t val)
+{
+	spin_lock_bh(&tun->stat_lock);
+	u64_stats_update_begin(&tun->stat_sync);
+	(*stat) += val;
+	u64_stats_update_end(&tun->stat_sync);
+	spin_unlock_bh(&tun->stat_lock);
+}
+
 /* Net device start xmit */
 static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -831,7 +845,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 
 drop:
-	dev->stats.tx_dropped++;
+	tun_stat64_inc(tun, &tun->stats64.tx_dropped, 1);
 	skb_tx_error(skb);
 	kfree_skb(skb);
 	rcu_read_unlock();
@@ -883,6 +897,21 @@ static void tun_poll_controller(struct net_device *dev)
 	return;
 }
 #endif
+
+struct rtnl_link_stats64* tun_net_get_stats64(struct net_device        *dev,
+					      struct rtnl_link_stats64 *stats)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	unsigned int start;
+
+	do {
+		start = u64_stats_fetch_begin(&tun->stat_sync);
+		memcpy(stats, &tun->stats64, sizeof(*stats));
+	} while (u64_stats_fetch_retry(&tun->stat_sync, start));
+
+	return stats;
+}
+
 static const struct net_device_ops tun_netdev_ops = {
 	.ndo_uninit		= tun_net_uninit,
 	.ndo_open		= tun_net_open,
@@ -894,6 +923,7 @@ static const struct net_device_ops tun_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tun_poll_controller,
 #endif
+	.ndo_get_stats64        = tun_net_get_stats64,
 };
 
 static const struct net_device_ops tap_netdev_ops = {
@@ -910,6 +940,7 @@ static const struct net_device_ops tap_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tun_poll_controller,
 #endif
+	.ndo_get_stats64        = tun_net_get_stats64,
 };
 
 static void tun_flow_init(struct tun_struct *tun)
@@ -1107,7 +1138,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	skb = tun_alloc_skb(tfile, align, copylen, linear, noblock);
 	if (IS_ERR(skb)) {
 		if (PTR_ERR(skb) != -EAGAIN)
-			tun->dev->stats.rx_dropped++;
+			tun_stat64_inc(tun, &tun->stats64.rx_dropped, 1);
 		return PTR_ERR(skb);
 	}
 
@@ -1122,7 +1153,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	}
 
 	if (err) {
-		tun->dev->stats.rx_dropped++;
+		tun_stat64_inc(tun, &tun->stats64.rx_dropped, 1);
 		kfree_skb(skb);
 		return -EFAULT;
 	}
@@ -1130,7 +1161,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	if (gso.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
 		if (!skb_partial_csum_set(skb, tun16_to_cpu(tun, gso.csum_start),
 					  tun16_to_cpu(tun, gso.csum_offset))) {
-			tun->dev->stats.rx_frame_errors++;
+			tun_stat64_inc(tun, &tun->stats64.rx_frame_errors, 1);
 			kfree_skb(skb);
 			return -EINVAL;
 		}
@@ -1147,7 +1178,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 				pi.proto = htons(ETH_P_IPV6);
 				break;
 			default:
-				tun->dev->stats.rx_dropped++;
+				tun_stat64_inc(tun, &tun->stats64.rx_dropped, 1);
 				kfree_skb(skb);
 				return -EINVAL;
 			}
@@ -1175,7 +1206,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 			break;
 		default:
-			tun->dev->stats.rx_frame_errors++;
+			tun_stat64_inc(tun, &tun->stats64.rx_frame_errors, 1);
 			kfree_skb(skb);
 			return -EINVAL;
 		}
@@ -1185,7 +1216,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 
 		skb_shinfo(skb)->gso_size = tun16_to_cpu(tun, gso.gso_size);
 		if (skb_shinfo(skb)->gso_size == 0) {
-			tun->dev->stats.rx_frame_errors++;
+			tun_stat64_inc(tun, &tun->stats64.rx_frame_errors, 1);
 			kfree_skb(skb);
 			return -EINVAL;
 		}
@@ -1208,8 +1239,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	rxhash = skb_get_hash(skb);
 	netif_rx_ni(skb);
 
-	tun->dev->stats.rx_packets++;
-	tun->dev->stats.rx_bytes += len;
+	tun_stat64_inc(tun, &tun->stats64.rx_packets, 1);
+	tun_stat64_inc(tun, &tun->stats64.rx_bytes, len);
 
 	tun_flow_update(tun, rxhash, tfile);
 	return total_len;
@@ -1338,8 +1369,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 	skb_copy_datagram_iter(skb, vlan_offset, iter, skb->len - vlan_offset);
 
 done:
-	tun->dev->stats.tx_packets++;
-	tun->dev->stats.tx_bytes += skb->len + vlan_hlen;
+	tun_stat64_inc(tun, &tun->stats64.tx_packets, 1);
+	tun_stat64_inc(tun, &tun->stats64.tx_bytes, skb->len + vlan_hlen);
 
 	return total;
 }
@@ -1651,6 +1682,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		tun->sndbuf = tfile->socket.sk->sk_sndbuf;
 
 		spin_lock_init(&tun->lock);
+		spin_lock_init(&tun->stat_lock);
 
 		err = security_tun_dev_alloc_security(&tun->security);
 		if (err < 0)
-- 
1.7.10.4
