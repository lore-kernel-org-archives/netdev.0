From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH] niu: fix SMP race protecting rx_rings and tx_rings
Date: Thu,  3 Feb 2011 16:45:17 -0200
Message-ID: <1296758717-18406-1-git-send-email-fleitner@redhat.com>
Cc: Flavio Leitner <fleitner@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44169 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932149Ab1BCSp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 13:45:26 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p13IjPcA003563
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 3 Feb 2011 13:45:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's possible to trigger a crash if one CPU is opening
the device while another CPU gets its statistics.

It happens because niu_alloc_channels() called from
niu_open() sets num_tx/rx_rings before allocating the
ring, so the other thread crashes when accessing
np->tx_rings[i].tx_packets at niu_get_tx_stats().

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 drivers/net/niu.c |   29 ++++++++++++++++++++++++++---
 drivers/net/niu.h |    1 +
 2 files changed, 27 insertions(+), 3 deletions(-)

Compile tested only because I don't have the hardware.

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2541321..bfa494e 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -4328,7 +4328,7 @@ static void niu_free_tx_ring_info(struct niu *np, struct tx_ring_info *rp)
 	}
 }
 
-static void niu_free_channels(struct niu *np)
+static void __niu_free_channels(struct niu *np)
 {
 	int i;
 
@@ -4355,6 +4355,13 @@ static void niu_free_channels(struct niu *np)
 	}
 }
 
+static void niu_free_channels(struct niu *np)
+{
+	down_write(&np->rings_rwlock);
+	__niu_free_channels(np);
+	up_write(&np->rings_rwlock);
+}
+
 static int niu_alloc_rx_ring_info(struct niu *np,
 				  struct rx_ring_info *rp)
 {
@@ -4485,7 +4492,7 @@ static void niu_size_rbr(struct niu *np, struct rx_ring_info *rp)
 	rp->rbr_sizes[3] = rp->rbr_block_size;
 }
 
-static int niu_alloc_channels(struct niu *np)
+static int __niu_alloc_channels(struct niu *np)
 {
 	struct niu_parent *parent = np->parent;
 	int first_rx_channel, first_tx_channel;
@@ -4558,10 +4565,21 @@ static int niu_alloc_channels(struct niu *np)
 	return 0;
 
 out_err:
-	niu_free_channels(np);
+	__niu_free_channels(np);
 	return err;
 }
 
+static int niu_alloc_channels(struct niu *np)
+{
+	int ret;
+
+	down_write(&np->rings_rwlock);
+	ret = __niu_alloc_channels(np);
+	up_write(&np->rings_rwlock);
+
+	return ret;
+}
+
 static int niu_tx_cs_sng_poll(struct niu *np, int channel)
 {
 	int limit = 1000;
@@ -6249,6 +6267,7 @@ static void niu_get_rx_stats(struct niu *np)
 	int i;
 
 	pkts = dropped = errors = bytes = 0;
+	down_read(&np->rings_rwlock);
 	for (i = 0; i < np->num_rx_rings; i++) {
 		struct rx_ring_info *rp = &np->rx_rings[i];
 
@@ -6259,6 +6278,7 @@ static void niu_get_rx_stats(struct niu *np)
 		dropped += rp->rx_dropped;
 		errors += rp->rx_errors;
 	}
+	up_read(&np->rings_rwlock);
 	np->dev->stats.rx_packets = pkts;
 	np->dev->stats.rx_bytes = bytes;
 	np->dev->stats.rx_dropped = dropped;
@@ -6271,6 +6291,7 @@ static void niu_get_tx_stats(struct niu *np)
 	int i;
 
 	pkts = errors = bytes = 0;
+	down_read(&np->rings_rwlock);
 	for (i = 0; i < np->num_tx_rings; i++) {
 		struct tx_ring_info *rp = &np->tx_rings[i];
 
@@ -6278,6 +6299,7 @@ static void niu_get_tx_stats(struct niu *np)
 		bytes += rp->tx_bytes;
 		errors += rp->tx_errors;
 	}
+	up_read(&np->rings_rwlock);
 	np->dev->stats.tx_packets = pkts;
 	np->dev->stats.tx_bytes = bytes;
 	np->dev->stats.tx_errors = errors;
@@ -9680,6 +9702,7 @@ static struct net_device * __devinit niu_alloc_and_init(
 
 	np->msg_enable = niu_debug;
 
+	init_rwsem(&np->rings_rwlock);
 	spin_lock_init(&np->lock);
 	INIT_WORK(&np->reset_task, niu_reset_task);
 
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index a41fa8e..555bae1 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -3265,6 +3265,7 @@ struct niu {
 	const struct niu_ops		*ops;
 	union niu_mac_stats		mac_stats;
 
+	struct rw_semaphore		rings_rwlock;
 	struct rx_ring_info		*rx_rings;
 	struct tx_ring_info		*tx_rings;
 	int				num_rx_rings;
-- 
1.7.3.1

