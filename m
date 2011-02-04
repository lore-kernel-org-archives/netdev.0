From: David Miller <davem@davemloft.net>
Subject: [PATCH] niu: Fix races between up/down and get_stats.
Date: Thu, 03 Feb 2011 16:25:29 -0800 (PST)
Message-ID: <20110203.162529.260086668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fleitner@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39529
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754714Ab1BDAYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 19:24:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As reported by Flavio Leitner, there is no synchronization to protect
NIU's get_stats method from seeing a NULL pointer in either
np->rx_rings or np->tx_rings.  In fact, as far as ->ndo_get_stats
is concerned, these values are set completely asynchronously.

Flavio attempted to fix this using a RW semaphore, which in fact
works most of the time.  However, dev_get_stats() can be invoked
from non-sleepable contexts in some cases, so this fix doesn't
work in all cases.

So instead, control the visibility of the np->{rx,tx}_ring pointers
when the device is being brough up, and use properties of the device
down sequence to our advantage.

In niu_get_stats(), return immediately if netif_running() is false.
The device shutdown sequence first marks the device as not running (by
clearing the __LINK_STATE_START bit), then it performans a
synchronize_rcu() (in dev_deactive_many()), and then finally it
invokes the driver ->ndo_stop() method.

This guarentees that all invocations of niu_get_stats() either see
netif_running() as false, or they see the channel pointers before
->ndo_stop() clears them out.

If netif_running() is true, protect against startup races by loading
the np->{rx,tx}_rings pointer into a local variable, and punting if
it is NULL.  Use ACCESS_ONCE to prevent the compiler from reloading
the pointer on us.

Also, during open, control the order in which the pointers and the
ring counts become visible globally using SMP write memory barriers.
We make sure the np->num_{rx,tx}_rings value is stable and visible
before np->{rx,tx}_rings is.

Such visibility control is not necessary on the niu_free_channels()
side because of the RCU sequencing that happens during device down as
described above.  We are always guarenteed that all niu_get_stats
calls are finished, or will see netif_running() false, by the time
->ndo_stop is invoked.

Reported-by: Flavio Leitner <fleitner@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |   61 +++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 45 insertions(+), 16 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2541321..9fb59d3 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -4489,6 +4489,9 @@ static int niu_alloc_channels(struct niu *np)
 {
 	struct niu_parent *parent = np->parent;
 	int first_rx_channel, first_tx_channel;
+	int num_rx_rings, num_tx_rings;
+	struct rx_ring_info *rx_rings;
+	struct tx_ring_info *tx_rings;
 	int i, port, err;
 
 	port = np->port;
@@ -4498,18 +4501,21 @@ static int niu_alloc_channels(struct niu *np)
 		first_tx_channel += parent->txchan_per_port[i];
 	}
 
-	np->num_rx_rings = parent->rxchan_per_port[port];
-	np->num_tx_rings = parent->txchan_per_port[port];
+	num_rx_rings = parent->rxchan_per_port[port];
+	num_tx_rings = parent->txchan_per_port[port];
 
-	netif_set_real_num_rx_queues(np->dev, np->num_rx_rings);
-	netif_set_real_num_tx_queues(np->dev, np->num_tx_rings);
-
-	np->rx_rings = kcalloc(np->num_rx_rings, sizeof(struct rx_ring_info),
-			       GFP_KERNEL);
+	rx_rings = kcalloc(num_rx_rings, sizeof(struct rx_ring_info),
+			   GFP_KERNEL);
 	err = -ENOMEM;
-	if (!np->rx_rings)
+	if (!rx_rings)
 		goto out_err;
 
+	np->num_rx_rings = num_rx_rings;
+	smp_wmb();
+	np->rx_rings = rx_rings;
+
+	netif_set_real_num_rx_queues(np->dev, num_rx_rings);
+
 	for (i = 0; i < np->num_rx_rings; i++) {
 		struct rx_ring_info *rp = &np->rx_rings[i];
 
@@ -4538,12 +4544,18 @@ static int niu_alloc_channels(struct niu *np)
 			return err;
 	}
 
-	np->tx_rings = kcalloc(np->num_tx_rings, sizeof(struct tx_ring_info),
-			       GFP_KERNEL);
+	tx_rings = kcalloc(num_tx_rings, sizeof(struct tx_ring_info),
+			   GFP_KERNEL);
 	err = -ENOMEM;
-	if (!np->tx_rings)
+	if (!tx_rings)
 		goto out_err;
 
+	np->num_tx_rings = num_tx_rings;
+	smp_wmb();
+	np->tx_rings = tx_rings;
+
+	netif_set_real_num_tx_queues(np->dev, num_tx_rings);
+
 	for (i = 0; i < np->num_tx_rings; i++) {
 		struct tx_ring_info *rp = &np->tx_rings[i];
 
@@ -6246,11 +6258,17 @@ static void niu_sync_mac_stats(struct niu *np)
 static void niu_get_rx_stats(struct niu *np)
 {
 	unsigned long pkts, dropped, errors, bytes;
+	struct rx_ring_info *rx_rings;
 	int i;
 
 	pkts = dropped = errors = bytes = 0;
+
+	rx_rings = ACCESS_ONCE(np->rx_rings);
+	if (!rx_rings)
+		goto no_rings;
+
 	for (i = 0; i < np->num_rx_rings; i++) {
-		struct rx_ring_info *rp = &np->rx_rings[i];
+		struct rx_ring_info *rp = &rx_rings[i];
 
 		niu_sync_rx_discard_stats(np, rp, 0);
 
@@ -6259,6 +6277,8 @@ static void niu_get_rx_stats(struct niu *np)
 		dropped += rp->rx_dropped;
 		errors += rp->rx_errors;
 	}
+
+no_rings:
 	np->dev->stats.rx_packets = pkts;
 	np->dev->stats.rx_bytes = bytes;
 	np->dev->stats.rx_dropped = dropped;
@@ -6268,16 +6288,24 @@ static void niu_get_rx_stats(struct niu *np)
 static void niu_get_tx_stats(struct niu *np)
 {
 	unsigned long pkts, errors, bytes;
+	struct tx_ring_info *tx_rings;
 	int i;
 
 	pkts = errors = bytes = 0;
+
+	tx_rings = ACCESS_ONCE(np->tx_rings);
+	if (!tx_rings)
+		goto no_rings;
+
 	for (i = 0; i < np->num_tx_rings; i++) {
-		struct tx_ring_info *rp = &np->tx_rings[i];
+		struct tx_ring_info *rp = &tx_rings[i];
 
 		pkts += rp->tx_packets;
 		bytes += rp->tx_bytes;
 		errors += rp->tx_errors;
 	}
+
+no_rings:
 	np->dev->stats.tx_packets = pkts;
 	np->dev->stats.tx_bytes = bytes;
 	np->dev->stats.tx_errors = errors;
@@ -6287,9 +6315,10 @@ static struct net_device_stats *niu_get_stats(struct net_device *dev)
 {
 	struct niu *np = netdev_priv(dev);
 
-	niu_get_rx_stats(np);
-	niu_get_tx_stats(np);
-
+	if (netif_running(dev)) {
+		niu_get_rx_stats(np);
+		niu_get_tx_stats(np);
+	}
 	return &dev->stats;
 }
 
-- 
1.7.4

