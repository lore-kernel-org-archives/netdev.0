From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [IPSEC] flow : NUMA aware hash table allocation
Date: Tue, 01 Jan 2008 13:44:15 +0100
Message-ID: <477A359F.20902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080700010801040008090602"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44863 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321AbYAAMo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 07:44:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080700010801040008090602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Using __get_free_pages() has some drawbacks :

1) Not NUMA aware

2) 2^X page granularity :
On arches with big PAGE_SIZE, we waste some ram for each cpu.

(We currently use 1024 pointers, that is at most 8192 bytes, but
PAGE_SIZE can be 65536 for example : With say 64 possible cpus,
thats about 56*64 Kbytes that are wasted)

Using kmalloc_node() can help to solve these two points.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

  net/core/flow.c |   15 +++++----------
  1 files changed, 5 insertions(+), 10 deletions(-)


--------------080700010801040008090602
Content-Type: text/plain;
 name="flow.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="flow.patch"

diff --git a/net/core/flow.c b/net/core/flow.c
index a618f89..bcbbe2d 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -311,18 +311,13 @@ void flow_cache_flush(void)
 static void __devinit flow_cache_cpu_prepare(int cpu)
 {
 	struct tasklet_struct *tasklet;
-	unsigned long order;
 
-	for (order = 0;
-	     (PAGE_SIZE << order) <
-		     (sizeof(struct flow_cache_entry *)*flow_hash_size);
-	     order++)
-		/* NOTHING */;
-
-	flow_table(cpu) = (struct flow_cache_entry **)
-		__get_free_pages(GFP_KERNEL|__GFP_ZERO, order);
+	flow_table(cpu) = kmalloc_node(
+		sizeof(struct flow_cache_entry *) * flow_hash_size,
+		GFP_KERNEL | __GFP_ZERO,
+		cpu_to_node(cpu));
 	if (!flow_table(cpu))
-		panic("NET: failed to allocate flow cache order %lu\n", order);
+		panic("NET: failed to allocate flow cache for cpu %d\n", cpu);
 
 	flow_hash_rnd_recalc(cpu) = 1;
 	flow_count(cpu) = 0;

--------------080700010801040008090602--
