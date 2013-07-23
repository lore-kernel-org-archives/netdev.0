From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC 2/2] tun: allow overriding statistics
Date: Tue, 23 Jul 2013 10:29:50 -0700
Message-ID: <20130723102950.519f6891@nehalam.linuxnetplumber.net>
References: <2F174B03-5074-4BA0-B91A-8F2F62C2B082@cygnusnetworks.de>
	<5192BDD6.6060703@qti.qualcomm.com>
	<3E916AF0-C587-443D-B653-C968A96C8751@cygnusnetworks.de>
	<48A2F278-A32C-47C6-AD2D-1FC15EC73B88@cygnusnetworks.de>
	<51E5BE27.3060207@qti.qualcomm.com>
	<E4A37B97-95FE-42C3-AD78-119BA406A44A@cygnusnetworks.de>
	<20130723102815.079bfe4a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Helmut Grohne <h.grohne@cygnusnetworks.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Max Krasnyansky <maxk@qti.qualcomm.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:58627 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933220Ab3GWR37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 13:29:59 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp1so4292305pab.7
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 10:29:58 -0700 (PDT)
In-Reply-To: <20130723102815.079bfe4a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds new ioctl to allow overrriding the link statistics
returned by the TUN device. This is useful when using tun device as a surrogate
for hardware or other software emulation. 

The application perodically uses ioctl(TUNSETSTTS) to periodically update statistics.
Exchange and RCU is used to make this operation atomic.

If TUNSETSTATS is not used the original software based statistics
are used.

This version compile tested only, to show how API works.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/tun.c	2013-07-23 10:17:04.335800821 -0700
+++ b/drivers/net/tun.c	2013-07-23 10:22:10.903948347 -0700
@@ -189,6 +189,10 @@ struct tun_struct {
 	u32 flow_count;
 
 	struct tun_info info;
+	struct tun_stats __rcu {
+		struct rtnl_link_stats64 link_stats;
+		struct rcu_head rcu;
+	} *stats;
 };
 
 static inline u32 tun_hashfn(u32 rxhash)
@@ -802,6 +806,32 @@ static netdev_features_t tun_net_fix_fea
 
 	return (features & tun->set_features) | (features & ~TUN_USER_FEATURES);
 }
+
+static struct rtnl_link_stats64 *
+tun_net_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *storage)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	struct tun_stats __rcu *stats;
+
+	rcu_read_lock();
+	stats = rcu_dereference(tun->stats);
+	if (stats) {
+		/* Stats received from device */
+		*storage = stats->link_stats;
+		rcu_read_unlock();
+
+		/* Add tunnel detected errors to mix */
+		storage->tx_dropped += dev->stats.tx_dropped;
+		storage->rx_dropped += dev->stats.rx_dropped;
+		storage->rx_frame_errors += dev->stats.rx_frame_errors;
+		return storage;
+	}
+	rcu_read_unlock();
+
+	netdev_stats_to_stats64(storage, &dev->stats);
+	return storage;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void tun_poll_controller(struct net_device *dev)
 {
@@ -824,6 +854,7 @@ static const struct net_device_ops tun_n
 	.ndo_open		= tun_net_open,
 	.ndo_stop		= tun_net_close,
 	.ndo_start_xmit		= tun_net_xmit,
+	.ndo_get_stats64	= tun_net_get_stats64,
 	.ndo_change_mtu		= tun_net_change_mtu,
 	.ndo_fix_features	= tun_net_fix_features,
 	.ndo_select_queue	= tun_select_queue,
@@ -837,6 +868,7 @@ static const struct net_device_ops tap_n
 	.ndo_open		= tun_net_open,
 	.ndo_stop		= tun_net_close,
 	.ndo_start_xmit		= tun_net_xmit,
+	.ndo_get_stats64	= tun_net_get_stats64,
 	.ndo_change_mtu		= tun_net_change_mtu,
 	.ndo_fix_features	= tun_net_fix_features,
 	.ndo_set_rx_mode	= tun_net_mclist,
@@ -1420,9 +1452,13 @@ out:
 static void tun_free_netdev(struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
+	struct tun_stats *stats;
 
 	BUG_ON(!(list_empty(&tun->disabled)));
 	tun_flow_uninit(tun);
+	stats = xchg(&tun->stats, NULL);
+	if (stats)
+		kfree_rcu(stats, rcu);
 	security_tun_dev_free_security(tun->security);
 	free_netdev(dev);
 }
@@ -1885,6 +1921,28 @@ unlock:
 	return ret;
 }
 
+static int tun_set_stats(struct tun_struct *tun, struct ifreq *ifr)
+{
+	struct tun_stats *stats, *old;
+
+	stats = kmalloc(sizeof(struct tun_stats), GFP_KERNEL);
+	if (!stats)
+		return -ENOMEM;
+
+	if (copy_from_user(&stats->link_stats,
+			   ifr->ifr_ifru.ifru_data,
+			   sizeof(struct rtnl_link_stats64))) {
+		kfree(stats);
+		return -EFAULT;
+	}
+
+	old = xchg(&tun->stats, stats);
+	if (old)
+		kfree_rcu(old, rcu);
+
+	return 0;
+}
+
 static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 			    unsigned long arg, int ifreq_len)
 {
@@ -2107,6 +2165,10 @@ static long __tun_chr_ioctl(struct file
 		break;
 	}
 
+	case TUNSETSTATS:
+		ret = tun_set_stats(tun, &ifr);
+		break;
+
 	default:
 		ret = -EINVAL;
 		break;
--- a/include/uapi/linux/if_tun.h	2013-07-23 10:17:04.335800821 -0700
+++ b/include/uapi/linux/if_tun.h	2013-07-23 10:19:09.358230639 -0700
@@ -57,6 +57,7 @@
 #define TUNSETVNETHDRSZ _IOW('T', 216, int)
 #define TUNSETQUEUE  _IOW('T', 217, int)
 #define TUNSETINFO     _IOW('T', 219, struct tun_info)
+#define TUNSETSTATS    _IOW('T', 220, struct rtnl_link_stats64)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
