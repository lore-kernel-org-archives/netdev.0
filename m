From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [NET]: Get rid of NETIF_F_INTERNAL_STATS
Date: Sat, 28 Apr 2007 15:46:01 +1000
Message-ID: <1177739161.30071.165.camel@localhost.localdomain>
References: <20070411075602.GA17635@gondor.apana.org.au>
	 <1176293751.14322.14.camel@localhost.localdomain>
	 <20070411122317.GA21159@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>, buytenh@gnu.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37282 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932564AbXD1FqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 01:46:17 -0400
In-Reply-To: <20070411122317.GA21159@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-11 at 22:23 +1000, Herbert Xu wrote:
> On Wed, Apr 11, 2007 at 10:15:51PM +1000, Rusty Russell wrote:
> > 
> > Actually, I did this precisely because I really didn't want to start
> > exposing bogus stats in /proc/net/dev.  An audit might clarify if this
> > is an actual issue.
> 
> Fair enough.  Still returning zeros when get_stats isn't available
> would seem safe enough.  I wasn't able to find any drivers which
> didn't have get_stats.

OK, I did a quick check, and the only one I could find was br_if.c which
calls register_netdevice() and doesn't set get_stats.  I don't think
that zeroes in this case matters.

So here's a patch inspired by Herbert's patch, but also gets all those
places which I modified previously to check for get_stats returning
NULL.
==
Remove NETIF_F_INTERNAL_STATS: default to internal stats.

Herbert Xu conviced me that a new flag was overkill; every driver
currently overrides get_stats, so we might as well make the internal
one the default.  If someone did fail to set get_stats, they would now
get all 0 stats instead of "No statistics available".

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r ceab3c131ee5 arch/s390/appldata/appldata_net_sum.c
--- a/arch/s390/appldata/appldata_net_sum.c	Sat Apr 28 14:39:41 2007 +1000
+++ b/arch/s390/appldata/appldata_net_sum.c	Sat Apr 28 15:09:46 2007 +1000
@@ -109,9 +109,6 @@ static void appldata_get_net_sum_data(vo
 	read_lock(&dev_base_lock);
 	for (dev = dev_base; dev != NULL; dev = dev->next) {
 		stats = dev->get_stats(dev);
-		if (stats == NULL) {
-			continue;
-		}
 		rx_packets += stats->rx_packets;
 		tx_packets += stats->tx_packets;
 		rx_bytes   += stats->rx_bytes;
diff -r ceab3c131ee5 drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Sat Apr 28 14:39:41 2007 +1000
+++ b/drivers/net/bonding/bond_main.c	Sat Apr 28 15:10:24 2007 +1000
@@ -1360,13 +1360,6 @@ int bond_enslave(struct net_device *bond
 		goto err_undo_flags;
 	}
 
-	if (slave_dev->get_stats == NULL) {
-		printk(KERN_NOTICE DRV_NAME
-			": %s: the driver for slave device %s does not provide "
-			"get_stats function, network statistics will be "
-			"inaccurate.\n", bond_dev->name, slave_dev->name);
-	}
-
 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
 	if (!new_slave) {
 		res = -ENOMEM;
@@ -3641,33 +3634,31 @@ static struct net_device_stats *bond_get
 
 	bond_for_each_slave(bond, slave, i) {
 		sstats = slave->dev->get_stats(slave->dev);
-		if (sstats) {
-			stats->rx_packets += sstats->rx_packets;
-			stats->rx_bytes += sstats->rx_bytes;
-			stats->rx_errors += sstats->rx_errors;
-			stats->rx_dropped += sstats->rx_dropped;
-
-			stats->tx_packets += sstats->tx_packets;
-			stats->tx_bytes += sstats->tx_bytes;
-			stats->tx_errors += sstats->tx_errors;
-			stats->tx_dropped += sstats->tx_dropped;
-
-			stats->multicast += sstats->multicast;
-			stats->collisions += sstats->collisions;
-
-			stats->rx_length_errors += sstats->rx_length_errors;
-			stats->rx_over_errors += sstats->rx_over_errors;
-			stats->rx_crc_errors += sstats->rx_crc_errors;
-			stats->rx_frame_errors += sstats->rx_frame_errors;
-			stats->rx_fifo_errors += sstats->rx_fifo_errors;
-			stats->rx_missed_errors += sstats->rx_missed_errors;
-
-			stats->tx_aborted_errors += sstats->tx_aborted_errors;
-			stats->tx_carrier_errors += sstats->tx_carrier_errors;
-			stats->tx_fifo_errors += sstats->tx_fifo_errors;
-			stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors;
-			stats->tx_window_errors += sstats->tx_window_errors;
-		}
+		stats->rx_packets += sstats->rx_packets;
+		stats->rx_bytes += sstats->rx_bytes;
+		stats->rx_errors += sstats->rx_errors;
+		stats->rx_dropped += sstats->rx_dropped;
+
+		stats->tx_packets += sstats->tx_packets;
+		stats->tx_bytes += sstats->tx_bytes;
+		stats->tx_errors += sstats->tx_errors;
+		stats->tx_dropped += sstats->tx_dropped;
+
+		stats->multicast += sstats->multicast;
+		stats->collisions += sstats->collisions;
+
+		stats->rx_length_errors += sstats->rx_length_errors;
+		stats->rx_over_errors += sstats->rx_over_errors;
+		stats->rx_crc_errors += sstats->rx_crc_errors;
+		stats->rx_frame_errors += sstats->rx_frame_errors;
+		stats->rx_fifo_errors += sstats->rx_fifo_errors;
+		stats->rx_missed_errors += sstats->rx_missed_errors;
+
+		stats->tx_aborted_errors += sstats->tx_aborted_errors;
+		stats->tx_carrier_errors += sstats->tx_carrier_errors;
+		stats->tx_fifo_errors += sstats->tx_fifo_errors;
+		stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors;
+		stats->tx_window_errors += sstats->tx_window_errors;
 	}
 
 	read_unlock_bh(&bond->lock);
diff -r ceab3c131ee5 drivers/parisc/led.c
--- a/drivers/parisc/led.c	Sat Apr 28 14:39:41 2007 +1000
+++ b/drivers/parisc/led.c	Sat Apr 28 15:09:36 2007 +1000
@@ -373,8 +373,6 @@ static __inline__ int led_get_net_activi
 	    if (LOOPBACK(in_dev->ifa_list->ifa_local))
 		continue;
 	    stats = dev->get_stats(dev);
-	    if (!stats)
-		continue;
 	    rx_total += stats->rx_packets;
 	    tx_total += stats->tx_packets;
 	}
diff -r ceab3c131ee5 include/linux/netdevice.h
--- a/include/linux/netdevice.h	Sat Apr 28 14:39:41 2007 +1000
+++ b/include/linux/netdevice.h	Sat Apr 28 15:09:13 2007 +1000
@@ -325,7 +325,6 @@ struct net_device
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
-#define NETIF_F_INTERNAL_STATS	8192	/* Use stats structure in net_device */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
diff -r ceab3c131ee5 net/core/dev.c
--- a/net/core/dev.c	Sat Apr 28 14:39:41 2007 +1000
+++ b/net/core/dev.c	Sat Apr 28 15:09:02 2007 +1000
@@ -2105,26 +2105,23 @@ static void dev_seq_printf_stats(struct 
 {
 	struct net_device_stats *stats = dev->get_stats(dev);
 
-	if (stats) {
-		seq_printf(seq, "%6s:%8lu %7lu %4lu %4lu %4lu %5lu %10lu %9lu "
-				"%8lu %7lu %4lu %4lu %4lu %5lu %7lu %10lu\n",
-			   dev->name, stats->rx_bytes, stats->rx_packets,
-			   stats->rx_errors,
-			   stats->rx_dropped + stats->rx_missed_errors,
-			   stats->rx_fifo_errors,
-			   stats->rx_length_errors + stats->rx_over_errors +
-			     stats->rx_crc_errors + stats->rx_frame_errors,
-			   stats->rx_compressed, stats->multicast,
-			   stats->tx_bytes, stats->tx_packets,
-			   stats->tx_errors, stats->tx_dropped,
-			   stats->tx_fifo_errors, stats->collisions,
-			   stats->tx_carrier_errors +
-			     stats->tx_aborted_errors +
-			     stats->tx_window_errors +
-			     stats->tx_heartbeat_errors,
-			   stats->tx_compressed);
-	} else
-		seq_printf(seq, "%6s: No statistics available.\n", dev->name);
+	seq_printf(seq, "%6s:%8lu %7lu %4lu %4lu %4lu %5lu %10lu %9lu "
+		   "%8lu %7lu %4lu %4lu %4lu %5lu %7lu %10lu\n",
+		   dev->name, stats->rx_bytes, stats->rx_packets,
+		   stats->rx_errors,
+		   stats->rx_dropped + stats->rx_missed_errors,
+		   stats->rx_fifo_errors,
+		   stats->rx_length_errors + stats->rx_over_errors +
+		    stats->rx_crc_errors + stats->rx_frame_errors,
+		   stats->rx_compressed, stats->multicast,
+		   stats->tx_bytes, stats->tx_packets,
+		   stats->tx_errors, stats->tx_dropped,
+		   stats->tx_fifo_errors, stats->collisions,
+		   stats->tx_carrier_errors +
+		    stats->tx_aborted_errors +
+		    stats->tx_window_errors +
+		    stats->tx_heartbeat_errors,
+		   stats->tx_compressed);
 }
 
 /*
@@ -3287,11 +3284,9 @@ out:
 	mutex_unlock(&net_todo_run_mutex);
 }
 
-static struct net_device_stats *maybe_internal_stats(struct net_device *dev)
-{
-	if (dev->features & NETIF_F_INTERNAL_STATS)
-		return &dev->stats;
-	return NULL;
+static struct net_device_stats *internal_stats(struct net_device *dev)
+{
+	return &dev->stats;
 }
 
 /**
@@ -3329,7 +3324,7 @@ struct net_device *alloc_netdev(int size
 	if (sizeof_priv)
 		dev->priv = netdev_priv(dev);
 
-	dev->get_stats = maybe_internal_stats;
+	dev->get_stats = internal_stats;
 	setup(dev);
 	strcpy(dev->name, name);
 	return dev;


