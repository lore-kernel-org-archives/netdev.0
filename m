From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: fix race that causes invalid statistics
Date: Mon, 28 Jan 2008 19:38:13 -0500
Message-ID: <20080129003813.GB21912@gospo.usersys.redhat.com>
References: <20080128233825.GA21912@gospo.usersys.redhat.com> <23624.1201564743@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, csnook@redhat.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59432 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755524AbYA2Akb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 19:40:31 -0500
Content-Disposition: inline
In-Reply-To: <23624.1201564743@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 28, 2008 at 03:59:03PM -0800, Jay Osbourn wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >+	memcpy(stats,&local_stats,sizeof(net_device_stats));
> 
> 	FYI, this generates a compiler error (missing the word "struct"
> in here).  Other than not compiling, the patch seems reasonable.  I'll
> fix it up and include it in the series I'll post tomorrow or so.
> 
> 	-J
> 

Crap.  Here's the one I intended to send.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Chris Snook <csnook@redhat.com>

---

 bond_main.c |   57 ++++++++++++++++++++++++++++++---------------------------
 1 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 49a1982..901de6d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3769,41 +3769,44 @@ static struct net_device_stats *bond_get_stats(struct net_device *bond_dev)
 {
 	struct bonding *bond = bond_dev->priv;
 	struct net_device_stats *stats = &(bond->stats), *sstats;
+	struct net_device_stats local_stats;
 	struct slave *slave;
 	int i;
 
-	memset(stats, 0, sizeof(struct net_device_stats));
+	memset(&local_stats, 0, sizeof(struct net_device_stats));
 
 	read_lock_bh(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		sstats = slave->dev->get_stats(slave->dev);
-		stats->rx_packets += sstats->rx_packets;
-		stats->rx_bytes += sstats->rx_bytes;
-		stats->rx_errors += sstats->rx_errors;
-		stats->rx_dropped += sstats->rx_dropped;
-
-		stats->tx_packets += sstats->tx_packets;
-		stats->tx_bytes += sstats->tx_bytes;
-		stats->tx_errors += sstats->tx_errors;
-		stats->tx_dropped += sstats->tx_dropped;
-
-		stats->multicast += sstats->multicast;
-		stats->collisions += sstats->collisions;
-
-		stats->rx_length_errors += sstats->rx_length_errors;
-		stats->rx_over_errors += sstats->rx_over_errors;
-		stats->rx_crc_errors += sstats->rx_crc_errors;
-		stats->rx_frame_errors += sstats->rx_frame_errors;
-		stats->rx_fifo_errors += sstats->rx_fifo_errors;
-		stats->rx_missed_errors += sstats->rx_missed_errors;
-
-		stats->tx_aborted_errors += sstats->tx_aborted_errors;
-		stats->tx_carrier_errors += sstats->tx_carrier_errors;
-		stats->tx_fifo_errors += sstats->tx_fifo_errors;
-		stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors;
-		stats->tx_window_errors += sstats->tx_window_errors;
-	}
+		local_stats.rx_packets += sstats->rx_packets;
+		local_stats.rx_bytes += sstats->rx_bytes;
+		local_stats.rx_errors += sstats->rx_errors;
+		local_stats.rx_dropped += sstats->rx_dropped;
+
+		local_stats.tx_packets += sstats->tx_packets;
+		local_stats.tx_bytes += sstats->tx_bytes;
+		local_stats.tx_errors += sstats->tx_errors;
+		local_stats.tx_dropped += sstats->tx_dropped;
+
+		local_stats.multicast += sstats->multicast;
+		local_stats.collisions += sstats->collisions;
+
+		local_stats.rx_length_errors += sstats->rx_length_errors;
+		local_stats.rx_over_errors += sstats->rx_over_errors;
+		local_stats.rx_crc_errors += sstats->rx_crc_errors;
+		local_stats.rx_frame_errors += sstats->rx_frame_errors;
+		local_stats.rx_fifo_errors += sstats->rx_fifo_errors;
+		local_stats.rx_missed_errors += sstats->rx_missed_errors;
+
+		local_stats.tx_aborted_errors += sstats->tx_aborted_errors;
+		local_stats.tx_carrier_errors += sstats->tx_carrier_errors;
+		local_stats.tx_fifo_errors += sstats->tx_fifo_errors;
+		local_stats.tx_heartbeat_errors += sstats->tx_heartbeat_errors;
+		local_stats.tx_window_errors += sstats->tx_window_errors;
+	}
+
+	memcpy(stats,&local_stats,sizeof(struct net_device_stats));
 
 	read_unlock_bh(&bond->lock);
 
