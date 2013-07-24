From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/3] tuntap: allow overriding link statistics
Date: Wed, 24 Jul 2013 16:15:19 -0700
Message-ID: <20130724161519.2bdbe528@nehalam.linuxnetplumber.net>
References: <20130724161156.4a8cf02b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Helmut Grohne <h.grohne@cygnusnetworks.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:51882 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740Ab3GXXPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 19:15:30 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so1242721pab.6
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 16:15:30 -0700 (PDT)
In-Reply-To: <20130724161156.4a8cf02b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds new ioctl to allow overriding the link statistics
returned by the TUN device. This is useful when using tun device as a surrogate
for hardware or other software emulation. To use this application periodically
makes ioctl(TUNSETSTATS) to update statistics.

If TUNSETSTATS is not used the original software based statistics
are used.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
v2 - don't use exchange, use regular RCU

--- a/drivers/net/tun.c	2013-07-24 12:47:37.344206628 -0700
+++ b/drivers/net/tun.c	2013-07-24 16:14:00.964658040 -0700
@@ -152,6 +152,11 @@ struct tun_flow_entry {
 	unsigned long updated;
 };
 
+struct tun_link_stats {
+	struct rtnl_link_stats64 link_stats;
+	struct rcu_head rcu;
+};
+
 #define TUN_NUM_FLOW_ENTRIES 1024
 
 /* Since the socket were moved to tun_file, to preserve the behavior of persist
@@ -190,6 +195,7 @@ struct tun_struct {
 	u32 speed;
 	u8 duplex;
 	struct tun_info info;
+	struct tun_link_stats __rcu *stats;
 };
 
 static inline u32 tun_hashfn(u32 rxhash)
@@ -803,6 +809,32 @@ static netdev_features_t tun_net_fix_fea
 
 	return (features & tun->set_features) | (features & ~TUN_USER_FEATURES);
 }
+
+static struct rtnl_link_stats64 *
+tun_net_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *storage)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	struct tun_link_stats *stats;
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
@@ -825,6 +857,7 @@ static const struct net_device_ops tun_n
 	.ndo_open		= tun_net_open,
 	.ndo_stop		= tun_net_close,
 	.ndo_start_xmit		= tun_net_xmit,
+	.ndo_get_stats64	= tun_net_get_stats64,
 	.ndo_change_mtu		= tun_net_change_mtu,
 	.ndo_fix_features	= tun_net_fix_features,
 	.ndo_select_queue	= tun_select_queue,
@@ -838,6 +871,7 @@ static const struct net_device_ops tap_n
 	.ndo_open		= tun_net_open,
 	.ndo_stop		= tun_net_close,
 	.ndo_start_xmit		= tun_net_xmit,
+	.ndo_get_stats64	= tun_net_get_stats64,
 	.ndo_change_mtu		= tun_net_change_mtu,
 	.ndo_fix_features	= tun_net_fix_features,
 	.ndo_set_rx_mode	= tun_net_mclist,
@@ -1422,9 +1456,13 @@ out:
 static void tun_free_netdev(struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
+	struct tun_link_stats *stats;
 
 	BUG_ON(!(list_empty(&tun->disabled)));
 	tun_flow_uninit(tun);
+	stats = rtnl_dereference(tun->stats);
+	if (stats)
+		kfree_rcu(stats, rcu);
 	security_tun_dev_free_security(tun->security);
 	free_netdev(dev);
 }
@@ -1886,6 +1924,28 @@ unlock:
 	return ret;
 }
 
+static int tun_set_stats(struct tun_struct *tun, void __user *argp)
+{
+	struct tun_link_stats *stats, *old;
+
+	stats = kmalloc(sizeof(struct tun_link_stats), GFP_KERNEL);
+	if (!stats)
+		return -ENOMEM;
+
+	if (copy_from_user(&stats->link_stats, argp,
+			   sizeof(struct rtnl_link_stats64))) {
+		kfree(stats);
+		return -EFAULT;
+	}
+
+	old = rtnl_dereference(tun->stats);
+	rcu_assign_pointer(tun->stats, stats);
+	if (old)
+		kfree_rcu(old, rcu);
+
+	return 0;
+}
+
 static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 			    unsigned long arg, int ifreq_len)
 {
@@ -2108,6 +2168,11 @@ static long __tun_chr_ioctl(struct file
 		tun->info = info;
 		break;
 	}
+
+	case TUNSETSTATS:
+		ret = tun_set_stats(tun, argp);
+		break;
+
 	default:
 		ret = -EINVAL;
 		break;
@@ -2137,6 +2202,7 @@ static long tun_chr_compat_ioctl(struct
 	case TUNGETSNDBUF:
 	case TUNSETSNDBUF:
 	case TUNSETINFO:
+	case TUNSETSTATS:
 	case SIOCGIFHWADDR:
 	case SIOCSIFHWADDR:
 		arg = (unsigned long)compat_ptr(arg);
--- a/include/uapi/linux/if_tun.h	2013-07-24 12:47:37.344206628 -0700
+++ b/include/uapi/linux/if_tun.h	2013-07-24 12:47:37.352206531 -0700
@@ -57,6 +57,7 @@
 #define TUNSETVNETHDRSZ _IOW('T', 216, int)
 #define TUNSETQUEUE  _IOW('T', 217, int)
 #define TUNSETINFO     _IOW('T', 219, struct tun_info)
+#define TUNSETSTATS    _IOW('T', 220, struct rtnl_link_stats64)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
