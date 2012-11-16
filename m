From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: handle tcp_net_metrics_init() order-5 memory
 allocation failures
Date: Fri, 16 Nov 2012 07:31:53 -0800
Message-ID: <1353079913.10798.31.camel@edumazet-glaptop>
References: <1353022864.10798.6.camel@edumazet-glaptop>
	 <20121116.013940.813652515905883288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jln@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:50855 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226Ab2KPPb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 10:31:56 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so3742593iea.19
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2012 07:31:55 -0800 (PST)
In-Reply-To: <20121116.013940.813652515905883288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-16 at 01:39 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 15 Nov 2012 15:41:04 -0800
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > order-5 allocations can fail with current kernels, we should
> > try to reduce allocation sizes to allow network namespace
> > creation.
> > 
> > Reported-by: Julien Tinnes <jln@google.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Indeed, this has to be done better.
> 
> But this kind of retry solution results in non-deterministic behavior.
> Yes the tcp metrics cache is best effort, but it's size can influence
> behavior in a substantial way depending upon the workload.
> 
> I would suggest that we instead use different limits, ones which the
> page allocator will satisfy for us always with GFP_KERNEL.
> 
> 1) include linux/mmzone.h
> 
> 2) Make the two limits based upon PAGE_ALLOC_COSTLY_ORDER.
> 
> That is, make the larger table size PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER
> and the smaller one PAGE_SIZE << (PAGE_ALLOC_COSTLY_ORDER - 1).

Well, we dont really know what the size needs to be, and your proposal
reduces the size by a 4 factor, even for the initial namespace.

Julien report was about Chrome browser own netns, on a suspend/resume
cycle (or something like that)

If size can influence behavior, we could try a vmalloc() if kmalloc()
fails...

Thanks

[PATCH v3] tcp: handle tcp_net_metrics_init() order-5 memory allocation failures

order-5 allocations can fail with current kernels, we should
try vmalloc() as well.

Reported-by: Julien Tinnes <jln@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_metrics.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 53bc584..f696d7c 100644
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
+#include <linux/vmalloc.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/net_namespace.h>
@@ -1034,7 +1034,10 @@ static int __net_init tcp_net_metrics_init(struct net *net)
 	net->ipv4.tcp_metrics_hash_log = order_base_2(slots);
 	size = sizeof(struct tcpm_hash_bucket) << net->ipv4.tcp_metrics_hash_log;
 
-	net->ipv4.tcp_metrics_hash = kzalloc(size, GFP_KERNEL);
+	net->ipv4.tcp_metrics_hash = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
+	if (!net->ipv4.tcp_metrics_hash)
+		net->ipv4.tcp_metrics_hash = vzalloc(size);
+
 	if (!net->ipv4.tcp_metrics_hash)
 		return -ENOMEM;
 
@@ -1055,7 +1058,10 @@ static void __net_exit tcp_net_metrics_exit(struct net *net)
 			tm = next;
 		}
 	}
-	kfree(net->ipv4.tcp_metrics_hash);
+	if (is_vmalloc_addr(net->ipv4.tcp_metrics_hash))
+		vfree(net->ipv4.tcp_metrics_hash);
+	else
+		kfree(net->ipv4.tcp_metrics_hash);
 }
 
 static __net_initdata struct pernet_operations tcp_net_metrics_ops = {
