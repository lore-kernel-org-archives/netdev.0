From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: shrinks struct net_device
Date: Thu, 16 Sep 2010 14:58:13 +0200
Message-ID: <1284641893.3352.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jpirko@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35434 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932Ab0IPM6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 08:58:19 -0400
Received: by bwz11 with SMTP id 11so1537026bwz.19
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 05:58:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ab95bfe01 (net: replace hooks in __netif_receive_skb) added
rx_handler at wrong place, between two cache line aligned objects,
creating a big hole (a full cache line)

Move rx_handler and rx_handler_data before rx_queue, filling existing
hole.

Move master field in the cache line(s) used in receive path.

This saves 64 bytes (or L1_CACHE_BYTES), and avoids two possible
cache misses in receive path.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8992fff..ec17887 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -918,10 +918,6 @@ struct net_device {
 	unsigned short		needed_headroom;
 	unsigned short		needed_tailroom;
 
-	struct net_device	*master; /* Pointer to master device of a group,
-					  * which this device is member of.
-					  */
-
 	/* Interface address info. */
 	unsigned char		perm_addr[MAX_ADDR_LEN]; /* permanent hw address */
 	unsigned char		addr_assign_type; /* hw address assignment type */
@@ -951,7 +947,7 @@ struct net_device {
 						   assign before registering */
 
 /*
- * Cache line mostly used on receive path (including eth_type_trans())
+ * Cache lines mostly used on receive path (including eth_type_trans())
  */
 	unsigned long		last_rx;	/* Time of last Rx
 						 * This should not be set in
@@ -961,6 +957,10 @@ struct net_device {
 						 * avoid dirtying this cache line.
 						 */
 
+	struct net_device	*master; /* Pointer to master device of a group,
+					  * which this device is member of.
+					  */
+
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		*dev_addr;	/* hw address, (before bcast
 						   because most packets are
@@ -980,10 +980,14 @@ struct net_device {
 	unsigned int		num_rx_queues;
 #endif
 
-	struct netdev_queue	rx_queue;
 	rx_handler_func_t	*rx_handler;
 	void			*rx_handler_data;
 
+	struct netdev_queue	rx_queue; /* use two cache lines */
+
+/*
+ * Cache lines mostly used on transmit path
+ */
 	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
 
 	/* Number of TX queues allocated at alloc_netdev_mq() time  */
@@ -997,9 +1001,7 @@ struct net_device {
 
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 	spinlock_t		tx_global_lock;
-/*
- * One part is mostly used on xmit path (device)
- */
+
 	/* These may be needed for future network-power-down code. */
 
 	/*


