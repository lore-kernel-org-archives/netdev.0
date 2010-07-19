From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: 64bit stats for netdev_queue
Date: Mon, 19 Jul 2010 15:33:42 +0200
Message-ID: <1279546422.2553.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59701 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760678Ab0GSNdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 09:33:46 -0400
Received: by wyb42 with SMTP id 42so4387035wyb.19
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 06:33:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since struct netdev_queue tx_bytes/tx_packets/tx_dropped are already
protected by _xmit_lock, its easy to convert these fields to u64 instead
of unsigned long.
This completes 64bit stats for devices using them (vlan, macvlan, ...)

Strictly, we could avoid the locking in dev_txq_stats_fold() on 64bit
arches, but its slow path and we prefer keep it simple.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    6 +++---
 net/core/dev.c            |    4 +++-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fdc3f29..b626289 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -501,9 +501,9 @@ struct netdev_queue {
 	 * please use this field instead of dev->trans_start
 	 */
 	unsigned long		trans_start;
-	unsigned long		tx_bytes;
-	unsigned long		tx_packets;
-	unsigned long		tx_dropped;
+	u64			tx_bytes;
+	u64			tx_packets;
+	u64			tx_dropped;
 } ____cacheline_aligned_in_smp;
 
 #ifdef CONFIG_RPS
diff --git a/net/core/dev.c b/net/core/dev.c
index 1c002c7..9de75cd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5282,15 +5282,17 @@ void netdev_run_todo(void)
 void dev_txq_stats_fold(const struct net_device *dev,
 			struct rtnl_link_stats64 *stats)
 {
-	unsigned long tx_bytes = 0, tx_packets = 0, tx_dropped = 0;
+	u64 tx_bytes = 0, tx_packets = 0, tx_dropped = 0;
 	unsigned int i;
 	struct netdev_queue *txq;
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		txq = netdev_get_tx_queue(dev, i);
+		spin_lock_bh(&txq->_xmit_lock);
 		tx_bytes   += txq->tx_bytes;
 		tx_packets += txq->tx_packets;
 		tx_dropped += txq->tx_dropped;
+		spin_unlock_bh(&txq->_xmit_lock);
 	}
 	if (tx_bytes || tx_packets || tx_dropped) {
 		stats->tx_bytes   = tx_bytes;


