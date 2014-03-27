From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: dummy: make use of multi-queues
Date: Thu, 27 Mar 2014 01:37:56 +0100
Message-ID: <1395880676-4472-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59889 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbaC0Ah7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 20:37:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quite often it can be useful to just use the dummy device as a blackhole
sink for skbs, e.g. for packet sockets or pktgen tests. Therefore, make
use of multiqueues, so that we can simulate for that. trafgen mmap/TX_RING
example against dummy device with config foo: { fill(0xff, 64) } results
in the following performance improvements on an ordinary Core i7/2.80GHz
as we don't need to take a single queue/lock anymore:

Before:

 Performance counter stats for 'trafgen -i foo -o du0 -n100000000' (10 runs):

   160,975,944,159 instructions:k            #    0.55  insns per cycle          ( +-  0.09% )
   293,319,390,278 cycles:k                  #    0.000 GHz                      ( +-  0.35% )
       192,501,104 branch-misses:k                                               ( +-  1.63% )
               831 context-switches:k                                            ( +-  9.18% )
                 7 cpu-migrations:k                                              ( +-  7.40% )
            69,382 cache-misses:k            #    0.010 % of all cache refs      ( +-  2.18% )
       671,552,021 cache-references:k                                            ( +-  1.29% )

      22.856401569 seconds time elapsed                                          ( +-  0.33% )

After:

 Performance counter stats for 'trafgen -i foo -o du0 -n100000000' (10 runs):

   138,669,108,882 instructions:k            #    0.92  insns per cycle          ( +-  0.02% )
   151,222,621,155 cycles:k                  #    0.000 GHz                      ( +-  0.11% )
        57,667,395 branch-misses:k                                               ( +-  6.15% )
               400 context-switches:k                                            ( +-  2.73% )
                 6 cpu-migrations:k                                              ( +-  7.51% )
            67,414 cache-misses:k            #    0.075 % of all cache refs      ( +-  1.64% )
        90,479,875 cache-references:k                                            ( +-  0.75% )

      12.080331543 seconds time elapsed                                          ( +-  0.13% )

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/dummy.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 0932ffb..b3f78a9 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -35,6 +35,7 @@
 #include <linux/init.h>
 #include <linux/moduleparam.h>
 #include <linux/rtnetlink.h>
+#include <linux/cpumask.h>
 #include <net/rtnetlink.h>
 #include <linux/u64_stats_sync.h>
 
@@ -162,9 +163,10 @@ MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
 static int __init dummy_init_one(void)
 {
 	struct net_device *dev_dummy;
+	unsigned int numqueues = min(num_possible_cpus(), 32U);
 	int err;
 
-	dev_dummy = alloc_netdev(0, "dummy%d", dummy_setup);
+	dev_dummy = alloc_netdev_mq(0, "dummy%d", dummy_setup, numqueues);
 	if (!dev_dummy)
 		return -ENOMEM;
 
-- 
1.7.11.7
