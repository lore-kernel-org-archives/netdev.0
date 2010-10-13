From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fib: avoid false sharing on fib_table_hash
Date: Wed, 13 Oct 2010 20:22:03 +0200
Message-ID: <1286994123.3876.1137.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:48666 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab0JMSWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 14:22:51 -0400
Received: by wwi14 with SMTP id 14so175021wwi.1
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 11:22:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While doing profile analysis, I found fib_hash_table was sometime in a
cache line shared by a possibly often written kernel structure.

(CONFIG_IP_ROUTE_MULTIPATH || !CONFIG_IPV6_MULTIPLE_TABLES)

It's hard to detect because not easily reproductible.

Make sure we allocate a full cache line to keep this shared in all cpus
caches.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
We probably need a generic kernel function, but it might take time...

 net/ipv4/fib_frontend.c |   11 +++++------
 net/ipv6/ip6_fib.c      |    9 ++++++---
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 919f2ad..3df057e 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1016,16 +1016,15 @@ static struct notifier_block fib_netdev_notifier = {
 static int __net_init ip_fib_net_init(struct net *net)
 {
 	int err;
-	unsigned int i;
+	size_t size = sizeof(struct hlist_head) * FIB_TABLE_HASHSZ;
+
+	/* Avoid false sharing : Use at least a full cache line */
+	size = max_t(size_t, size, L1_CACHE_BYTES);
 
-	net->ipv4.fib_table_hash = kzalloc(
-			sizeof(struct hlist_head)*FIB_TABLE_HASHSZ, GFP_KERNEL);
+	net->ipv4.fib_table_hash = kzalloc(size, GFP_KERNEL);
 	if (net->ipv4.fib_table_hash == NULL)
 		return -ENOMEM;
 
-	for (i = 0; i < FIB_TABLE_HASHSZ; i++)
-		INIT_HLIST_HEAD(&net->ipv4.fib_table_hash[i]);
-
 	err = fib4_rules_init(net);
 	if (err < 0)
 		goto fail;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index b6a5859..de38211 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1500,15 +1500,18 @@ static void fib6_gc_timer_cb(unsigned long arg)
 
 static int __net_init fib6_net_init(struct net *net)
 {
+	size_t size = sizeof(struct hlist_head) * FIB6_TABLE_HASHSZ;
+
 	setup_timer(&net->ipv6.ip6_fib_timer, fib6_gc_timer_cb, (unsigned long)net);
 
 	net->ipv6.rt6_stats = kzalloc(sizeof(*net->ipv6.rt6_stats), GFP_KERNEL);
 	if (!net->ipv6.rt6_stats)
 		goto out_timer;
 
-	net->ipv6.fib_table_hash = kcalloc(FIB6_TABLE_HASHSZ,
-					   sizeof(*net->ipv6.fib_table_hash),
-					   GFP_KERNEL);
+	/* Avoid false sharing : Use at least a full cache line */
+	size = max_t(size_t, size, L1_CACHE_BYTES);
+
+	net->ipv6.fib_table_hash = kzalloc(size, GFP_KERNEL);
 	if (!net->ipv6.fib_table_hash)
 		goto out_rt6_stats;
 


