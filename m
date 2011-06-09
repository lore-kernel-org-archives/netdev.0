From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Thu, 09 Jun 2011 08:26:50 +0200
Message-ID: <1307600810.3980.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>,
	Tim Chen <tim.c.chen@linux.intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53792 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198Ab1FIG0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 02:26:55 -0400
Received: by wwa36 with SMTP id 36so1332061wwa.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 23:26:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Profiles show false sharing in addr_compare() because refcnt/dtime
changes dirty the first inet_peer cache line, where are lying the keys
used at lookup time. If many cpus are calling inet_getpeer() and
inet_putpeer(), or need frag ids, addr_compare() is in 2nd position in
"perf top".

Before patch, my udpflood bench (16 threads) on my 2x4x2 machine :

             5784.00  9.7% csum_partial_copy_generic [kernel]
             3356.00  5.6% addr_compare              [kernel]
             2638.00  4.4% fib_table_lookup          [kernel]
             2625.00  4.4% ip_fragment               [kernel]
             1934.00  3.2% neigh_lookup              [kernel]
             1617.00  2.7% udp_sendmsg               [kernel]
             1608.00  2.7% __ip_route_output_key     [kernel]
             1480.00  2.5% __ip_append_data          [kernel]
             1396.00  2.3% kfree                     [kernel]
             1195.00  2.0% kmem_cache_free           [kernel]
             1157.00  1.9% inet_getpeer              [kernel]
             1121.00  1.9% neigh_resolve_output      [kernel]
             1012.00  1.7% dev_queue_xmit            [kernel]
# time ./udpflood.sh

real	0m44.511s
user	0m20.020s
sys	11m22.780s

# time ./udpflood.sh

real	0m44.099s
user	0m20.140s
sys	11m15.870s

After patch, no more addr_compare() in profiles :

             4171.00 10.7% csum_partial_copy_generic   [kernel]
             1787.00  4.6% fib_table_lookup            [kernel]
             1756.00  4.5% ip_fragment                 [kernel]
             1234.00  3.2% udp_sendmsg                 [kernel]
             1191.00  3.0% neigh_lookup                [kernel]
             1118.00  2.9% __ip_append_data            [kernel]
             1022.00  2.6% kfree                       [kernel]
              993.00  2.5% __ip_route_output_key       [kernel]
              841.00  2.2% neigh_resolve_output        [kernel]
              816.00  2.1% kmem_cache_free             [kernel]
              658.00  1.7% ia32_sysenter_target        [kernel]
              632.00  1.6% kmem_cache_alloc_node       [kernel]

# time ./udpflood.sh

real	0m41.587s
user	0m19.190s
sys	10m36.370s

# time ./udpflood.sh

real	0m41.486s
user	0m19.290s
sys	10m33.650s

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/net/inetpeer.h |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 1f0966f..39d1230 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -32,12 +32,17 @@ struct inet_peer {
 	struct inet_peer __rcu	*avl_left, *avl_right;
 	struct inetpeer_addr	daddr;
 	__u32			avl_height;
-	__u32			dtime;		/* the time of last use of not
-						 * referenced entries */
-	atomic_t		refcnt;
+
+	u32			metrics[RTAX_MAX];
+	u32			rate_tokens;	/* rate limiting for ICMP */
+	unsigned long		rate_last;
+	unsigned long		pmtu_expires;
+	u32			pmtu_orig;
+	u32			pmtu_learned;
+	struct inetpeer_addr_base redirect_learned;
 	/*
 	 * Once inet_peer is queued for deletion (refcnt == -1), following fields
-	 * are not available: rid, ip_id_count, tcp_ts, tcp_ts_stamp, metrics
+	 * are not available: rid, ip_id_count, tcp_ts, tcp_ts_stamp
 	 * We can share memory with rcu_head to help keep inet_peer small.
 	 */
 	union {
@@ -46,17 +51,14 @@ struct inet_peer {
 			atomic_t			ip_id_count;	/* IP ID for the next packet */
 			__u32				tcp_ts;
 			__u32				tcp_ts_stamp;
-			u32				metrics[RTAX_MAX];
-			u32				rate_tokens;	/* rate limiting for ICMP */
-			unsigned long			rate_last;
-			unsigned long			pmtu_expires;
-			u32				pmtu_orig;
-			u32				pmtu_learned;
-			struct inetpeer_addr_base	redirect_learned;
 		};
 		struct rcu_head         rcu;
 		struct inet_peer	*gc_next;
 	};
+
+	/* following fields might be frequently dirtied */
+	__u32			dtime;	/* the time of last use of not referenced entries */
+	atomic_t		refcnt;
 };
 
 void			inet_initpeers(void) __init;


