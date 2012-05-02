From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: change tcp_adv_win_scale and tcp_rmem[2]
Date: Wed, 02 May 2012 14:28:41 +0200
Message-ID: <1335961721.22133.562.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47225 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab2EBM2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 08:28:47 -0400
Received: by eekc41 with SMTP id c41so154767eek.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 05:28:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_adv_win_scale default value is 2, meaning we expect a good citizen
skb to have skb->len / skb->truesize ratio of 75% (3/4)

In 2.6 kernels we (mis)accounted for typical MSS=1460 frame : 
1536 + 64 + 256 = 1856 'estimated truesize', and 1856 * 3/4 = 1392.
So these skbs were considered as not bloated.

With recent truesize fixes, a typical MSS=1460 frame truesize is now the
more precise :
2048 + 256 = 2304. But 2304 * 3/4 = 1728.
So these skb are not good citizen anymore, because 1460 < 1728

(GRO can escape this problem because it build skbs with a too low
truesize.)

This also means tcp advertises a too optimistic window for a given
allocated rcvspace : When receiving frames, sk_rmem_alloc can hit
sk_rcvbuf limit and we call tcp_prune_queue()/tcp_collapse() too often,
especially when application is slow to drain its receive queue or in
case of losses (netperf is fast, scp is slow). This is a major latency
source.

We should adjust the len/truesize ratio to 50% instead of 75%

This patch :

1) changes tcp_adv_win_scale default to 1 instead of 2

2) increase tcp_rmem[2] limit from 4MB to 6MB to take into account
better truesize tracking and to allow autotuning tcp receive window to
reach same value than before. Note that same amount of kernel memory is
consumed compared to 2.6 kernels.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
Sorry for this long delay, this issue is now old...

Neal is working on a per socket dynamic ratio (allowing to advertize
tcp window given the average ratio of incoming frames) 

 Documentation/networking/ip-sysctl.txt |    4 ++--
 net/ipv4/tcp.c                         |    9 +++++----
 net/ipv4/tcp_input.c                   |    2 +-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index bd80ba5..1619a8c 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -147,7 +147,7 @@ tcp_adv_win_scale - INTEGER
 	(if tcp_adv_win_scale > 0) or bytes-bytes/2^(-tcp_adv_win_scale),
 	if it is <= 0.
 	Possible values are [-31, 31], inclusive.
-	Default: 2
+	Default: 1
 
 tcp_allowed_congestion_control - STRING
 	Show/set the congestion control choices available to non-privileged
@@ -410,7 +410,7 @@ tcp_rmem - vector of 3 INTEGERs: min, default, max
 	net.core.rmem_max.  Calling setsockopt() with SO_RCVBUF disables
 	automatic tuning of that socket's receive buffer size, in which
 	case this value is ignored.
-	Default: between 87380B and 4MB, depending on RAM size.
+	Default: between 87380B and 6MB, depending on RAM size.
 
 tcp_sack - BOOLEAN
 	Enable select acknowledgments (SACKS).
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8bb6ade..1272a88 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3243,7 +3243,7 @@ void __init tcp_init(void)
 {
 	struct sk_buff *skb = NULL;
 	unsigned long limit;
-	int max_share, cnt;
+	int max_rshare, max_wshare, cnt;
 	unsigned int i;
 	unsigned long jiffy = jiffies;
 
@@ -3303,15 +3303,16 @@ void __init tcp_init(void)
 	tcp_init_mem(&init_net);
 	/* Set per-socket limits to no more than 1/128 the pressure threshold */
 	limit = nr_free_buffer_pages() << (PAGE_SHIFT - 7);
-	max_share = min(4UL*1024*1024, limit);
+	max_wshare = min(4UL*1024*1024, limit);
+	max_rshare = min(6UL*1024*1024, limit);
 
 	sysctl_tcp_wmem[0] = SK_MEM_QUANTUM;
 	sysctl_tcp_wmem[1] = 16*1024;
-	sysctl_tcp_wmem[2] = max(64*1024, max_share);
+	sysctl_tcp_wmem[2] = max(64*1024, max_wshare);
 
 	sysctl_tcp_rmem[0] = SK_MEM_QUANTUM;
 	sysctl_tcp_rmem[1] = 87380;
-	sysctl_tcp_rmem[2] = max(87380, max_share);
+	sysctl_tcp_rmem[2] = max(87380, max_rshare);
 
 	pr_info("Hash tables configured (established %u bind %u)\n",
 		tcp_hashinfo.ehash_mask + 1, tcp_hashinfo.bhash_size);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d99efd7..257b617 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -85,7 +85,7 @@ int sysctl_tcp_ecn __read_mostly = 2;
 EXPORT_SYMBOL(sysctl_tcp_ecn);
 int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
-int sysctl_tcp_adv_win_scale __read_mostly = 2;
+int sysctl_tcp_adv_win_scale __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 
 int sysctl_tcp_stdurg __read_mostly;
