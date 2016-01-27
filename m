From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net 0/4] net: add rx_unhandled stat counter
Date: Wed, 27 Jan 2016 15:21:34 -0500
Message-ID: <1453926098-40181-1-git-send-email-jarod@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
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
In-Reply-To: <1453489882-57948-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The network core tries to keep track of dropped packets, but some packets
you wouldn't really call dropped, so much as intentionally ignored, under
certain circumstances. One such case is that of bonding and team device
slaves that are currently inactive. Their respective rx_handler functions
return RX_HANDLER_EXACT (the only places in the kernel that return that),
which ends up tracking into the network core's __netif_receive_skb_core()
function's drop path, with no pt_prev set. On a noisy network, this can
result in a very rapidly incrementing rx_dropped counter, not only on the
inactive slave(s), but also on the master device, such as the following:

Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
  p7p1: 14783346  140430    0 140428    0     0          0      2040      680       8    0    0    0     0       0          0
  p7p2: 14805198  140648    0    0    0     0          0      2034        0       0    0    0    0     0       0          0
 bond0: 53365248  532798    0 421160    0     0          0    115151     2040      24    0    0    0     0       0          0
    lo:    5420      54    0    0    0     0          0         0     5420      54    0    0    0     0       0          0
  p5p1: 19292195  196197    0 140368    0     0          0     56564      680       8    0    0    0     0       0          0
  p5p2: 19289707  196171    0 140364    0     0          0     56547      680       8    0    0    0     0       0          0
   em3: 20996626  158214    0    0    0     0          0       383        0       0    0    0    0     0       0          0
   em2: 14065122  138462    0    0    0     0          0       310        0       0    0    0    0     0       0          0
   em1: 14063162  138440    0    0    0     0          0       308        0       0    0    0    0     0       0          0
   em4: 21050830  158729    0    0    0     0          0       385    71662     469    0    0    0     0       0          0
   ib0:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0          0

In this scenario, p5p1, p5p2 and p7p1 are all inactive slaves in an
active-backup bond0, and you can see that all three have high drop counts,
with the master bond0 showing a tally of all three.

I know that this was previously discussed some here:

    http://www.spinics.net/lists/netdev/msg226341.html

It seems additional counters never came to fruition, so this is a first
attempt at creating one of them, so that we stop calling these drops,
which for users monitoring rx_dropped, causes great alarm, and renders the
counter much less useful for them.

This adds a sysfs statistics node and copies the counter out via netlink,
procfs additions will be handled separately, as I'm unsure if the current
output should be considered a stable interface...

Additionally, I'm not certain if this set qualifies for net, or if it
should be put aside and resubmitted for net-next after 4.5 is put to
bed, but I do have users who consider this an important bugfix.

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


Jarod Wilson (4):
  net: add rx_unhandled counter for tracking inactive slave drops
  net-procfs: show rx_unhandled counters
  team: track sum of rx_unhandled for all slaves
  bond: track sum of rx_unhandled for all slaves

 drivers/net/bonding/bond_main.c |  1 +
 drivers/net/team/team.c         | 10 +++++++---
 include/linux/if_team.h         |  1 +
 include/linux/netdevice.h       |  4 ++++
 include/uapi/linux/if_link.h    |  4 ++++
 net/core/dev.c                  |  6 +++++-
 net/core/net-procfs.c           | 11 ++++++-----
 net/core/net-sysfs.c            |  2 ++
 net/core/rtnetlink.c            |  2 ++
 9 files changed, 32 insertions(+), 9 deletions(-)

-- 
1.8.3.1
