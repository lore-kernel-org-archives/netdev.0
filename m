From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: handle tcp_net_metrics_init() order-5 memory
 allocation failures
Date: Fri, 16 Nov 2012 01:39:40 -0500 (EST)
Message-ID: <20121116.013940.813652515905883288.davem@davemloft.net>
References: <1353022864.10798.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jln@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620Ab2KPGjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 01:39:42 -0500
In-Reply-To: <1353022864.10798.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Nov 2012 15:41:04 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> order-5 allocations can fail with current kernels, we should
> try to reduce allocation sizes to allow network namespace
> creation.
> 
> Reported-by: Julien Tinnes <jln@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Indeed, this has to be done better.

But this kind of retry solution results in non-deterministic behavior.
Yes the tcp metrics cache is best effort, but it's size can influence
behavior in a substantial way depending upon the workload.

I would suggest that we instead use different limits, ones which the
page allocator will satisfy for us always with GFP_KERNEL.

1) include linux/mmzone.h

2) Make the two limits based upon PAGE_ALLOC_COSTLY_ORDER.

That is, make the larger table size PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER
and the smaller one PAGE_SIZE << (PAGE_ALLOC_COSTLY_ORDER - 1).

How about something like this?

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 53bc584..d4b2d42 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1,7 +1,6 @@
 #include <linux/rcupdate.h>
 #include <linux/spinlock.h>
 #include <linux/jiffies.h>
-#include <linux/bootmem.h>
 #include <linux/module.h>
 #include <linux/cache.h>
 #include <linux/slab.h>
@@ -9,6 +8,7 @@
 #include <linux/tcp.h>
 #include <linux/hash.h>
 #include <linux/tcp_metrics.h>
+#include <linux/mmzone.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/net_namespace.h>
@@ -1025,10 +1025,12 @@ static int __net_init tcp_net_metrics_init(struct net *net)
 
 	slots = tcpmhash_entries;
 	if (!slots) {
-		if (totalram_pages >= 128 * 1024)
-			slots = 16 * 1024;
-		else
-			slots = 8 * 1024;
+		int order = PAGE_ALLOC_COSTLY_ORDER;
+
+		if (totalram_pages < 128 * 1024)
+			order--;
+		slots = (PAGE_SIZE << order) /
+			sizeof(struct tcpm_hash_bucket);
 	}
 
 	net->ipv4.tcp_metrics_hash_log = order_base_2(slots);
