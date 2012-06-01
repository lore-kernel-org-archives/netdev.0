From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: do not create inetpeer on SYNACK message
Date: Fri, 01 Jun 2012 09:00:26 +0200
Message-ID: <1338534026.2760.1451.camel@edumazet-glaptop>
References: <1338501397.2760.1395.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58862 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803Ab2FAHAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 03:00:31 -0400
Received: by bkcji2 with SMTP id ji2so1546572bkc.19
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2012 00:00:30 -0700 (PDT)
In-Reply-To: <1338501397.2760.1395.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Another problem on SYNFLOOD/DDOS attack is the inetpeer cache getting
larger and larger, using lots of memory and cpu time.

tcp_v4_send_synack()
->inet_csk_route_req()
 ->ip_route_output_flow()
  ->rt_set_nexthop()
   ->rt_init_metrics()
    ->inet_getpeer( create = true)

This is a side effect of commit a4daad6b09230 (net: Pre-COW metrics for
TCP) added in 2.6.39

Possible solution : 

Instruct inet_csk_route_req() to remove FLOWI_FLAG_PRECOW_METRICS 

Before patch :

# grep peer /proc/slabinfo 
inet_peer_cache   4175430 4175430    192   42    2 : tunables    0    0    0 : slabdata  99415  99415      0

Samples: 41K of event 'cycles', Event count (approx.): 30716565122                                          
+  20,24%      ksoftirqd/0  [kernel.kallsyms]           [k] inet_getpeer
+   8,19%      ksoftirqd/0  [kernel.kallsyms]           [k] peer_avl_rebalance.isra.1
+   4,81%      ksoftirqd/0  [kernel.kallsyms]           [k] sha_transform
+   3,64%      ksoftirqd/0  [kernel.kallsyms]           [k] fib_table_lookup
+   2,36%      ksoftirqd/0  [ixgbe]                     [k] ixgbe_poll
+   2,16%      ksoftirqd/0  [kernel.kallsyms]           [k] __ip_route_output_key
+   2,11%      ksoftirqd/0  [kernel.kallsyms]           [k] kernel_map_pages
+   2,11%      ksoftirqd/0  [kernel.kallsyms]           [k] ip_route_input_common
+   2,01%      ksoftirqd/0  [kernel.kallsyms]           [k] __inet_lookup_established
+   1,83%      ksoftirqd/0  [kernel.kallsyms]           [k] md5_transform
+   1,75%      ksoftirqd/0  [kernel.kallsyms]           [k] check_leaf.isra.9
+   1,49%      ksoftirqd/0  [kernel.kallsyms]           [k] ipt_do_table
+   1,46%      ksoftirqd/0  [kernel.kallsyms]           [k] hrtimer_interrupt
+   1,45%      ksoftirqd/0  [kernel.kallsyms]           [k] kmem_cache_alloc
+   1,29%      ksoftirqd/0  [kernel.kallsyms]           [k] inet_csk_search_req
+   1,29%      ksoftirqd/0  [kernel.kallsyms]           [k] __netif_receive_skb
+   1,16%      ksoftirqd/0  [kernel.kallsyms]           [k] copy_user_generic_string
+   1,15%      ksoftirqd/0  [kernel.kallsyms]           [k] kmem_cache_free
+   1,02%      ksoftirqd/0  [kernel.kallsyms]           [k] tcp_make_synack
+   0,93%      ksoftirqd/0  [kernel.kallsyms]           [k] _raw_spin_lock_bh
+   0,87%      ksoftirqd/0  [kernel.kallsyms]           [k] __call_rcu
+   0,84%      ksoftirqd/0  [kernel.kallsyms]           [k] rt_garbage_collect
+   0,84%      ksoftirqd/0  [kernel.kallsyms]           [k] fib_rules_lookup

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
---
 net/ipv4/inet_connection_sock.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 95e61596..f9ee741 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -377,7 +377,8 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 
 	flowi4_init_output(fl4, sk->sk_bound_dev_if, sk->sk_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
-			   sk->sk_protocol, inet_sk_flowi_flags(sk),
+			   sk->sk_protocol,
+			   inet_sk_flowi_flags(sk) & ~FLOWI_FLAG_PRECOW_METRICS,
 			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->rmt_addr,
 			   ireq->loc_addr, ireq->rmt_port, inet_sk(sk)->inet_sport);
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
