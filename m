From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net 1/4] net: add rx_unhandled stat counter
Date: Wed, 27 Jan 2016 15:21:35 -0500
Message-ID: <1453926098-40181-2-git-send-email-jarod@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <1453926098-40181-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453926098-40181-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds an rx_unhandled stat counter, along with a sysfs statistics
node, and copies the counter out via netlink as well.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@mellanox.com>
CC: Daniel Borkmann <daniel@iogearbox.net>
CC: Tom Herbert <tom@herbertland.com>
CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 include/linux/netdevice.h    | 4 ++++
 include/uapi/linux/if_link.h | 4 ++++
 net/core/dev.c               | 6 +++++-
 net/core/net-sysfs.c         | 2 ++
 net/core/rtnetlink.c         | 2 ++
 5 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 289c231..7973ab5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -180,6 +180,7 @@ struct net_device_stats {
 	unsigned long	tx_window_errors;
 	unsigned long	rx_compressed;
 	unsigned long	tx_compressed;
+	unsigned long	rx_unhandled;
 };
 
 
@@ -1397,6 +1398,8 @@ enum netdev_priv_flags {
  *			do not use this in drivers
  *	@tx_dropped:	Dropped packets by core network,
  *			do not use this in drivers
+ *	@rx_unhandled:	Unhandled dropped packets by core network on
+ *			inactive devices, do not use this in drivers
  *
  *	@wireless_handlers:	List of functions to handle Wireless Extensions,
  *				instead of ioctl,
@@ -1611,6 +1614,7 @@ struct net_device {
 
 	atomic_long_t		rx_dropped;
 	atomic_long_t		tx_dropped;
+	atomic_long_t		rx_unhandled;
 
 #ifdef CONFIG_WIRELESS_EXT
 	const struct iw_handler_def *	wireless_handlers;
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index a30b780..533639d 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -35,6 +35,8 @@ struct rtnl_link_stats {
 	/* for cslip etc */
 	__u32	rx_compressed;
 	__u32	tx_compressed;
+
+	__u32	rx_unhandled;		/* dropped, no handler found	*/
 };
 
 /* The main device statistics structure */
@@ -68,6 +70,8 @@ struct rtnl_link_stats64 {
 	/* for cslip etc */
 	__u64	rx_compressed;
 	__u64	tx_compressed;
+
+	__u64	rx_unhandled;		/* dropped, no handler found	*/
 };
 
 /* The struct should be in sync with struct ifmap */
diff --git a/net/core/dev.c b/net/core/dev.c
index 8cba3d8..7700ca6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4154,7 +4154,10 @@ ncls:
 			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 	} else {
 drop:
-		atomic_long_inc(&skb->dev->rx_dropped);
+		if (!deliver_exact)
+			atomic_long_inc(&skb->dev->rx_dropped);
+		else
+			atomic_long_inc(&skb->dev->rx_unhandled);
 		kfree_skb(skb);
 		/* Jamal, now you will not able to escape explaining
 		 * me how you were going to use this. :-)
@@ -7300,6 +7303,7 @@ struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 	}
 	storage->rx_dropped += atomic_long_read(&dev->rx_dropped);
 	storage->tx_dropped += atomic_long_read(&dev->tx_dropped);
+	storage->rx_unhandled += atomic_long_read(&dev->rx_unhandled);
 	return storage;
 }
 EXPORT_SYMBOL(dev_get_stats);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b6c8a66..fd22276 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -574,6 +574,7 @@ NETSTAT_ENTRY(tx_heartbeat_errors);
 NETSTAT_ENTRY(tx_window_errors);
 NETSTAT_ENTRY(rx_compressed);
 NETSTAT_ENTRY(tx_compressed);
+NETSTAT_ENTRY(rx_unhandled);
 
 static struct attribute *netstat_attrs[] = {
 	&dev_attr_rx_packets.attr,
@@ -599,6 +600,7 @@ static struct attribute *netstat_attrs[] = {
 	&dev_attr_tx_window_errors.attr,
 	&dev_attr_rx_compressed.attr,
 	&dev_attr_tx_compressed.attr,
+	&dev_attr_rx_unhandled.attr,
 	NULL
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d735e85..2e0f656 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -804,6 +804,8 @@ static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
 
 	a->rx_compressed = b->rx_compressed;
 	a->tx_compressed = b->tx_compressed;
+
+	a->rx_unhandled = b->rx_unhandled;
 }
 
 static void copy_rtnl_link_stats64(void *v, const struct rtnl_link_stats64 *b)
-- 
1.8.3.1
