From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: sr: static percpu allocation for hmac_ring
Date: Thu, 12 Jan 2017 08:50:10 -0800
Message-ID: <1484239810.15816.47.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        David Lebrun <david.lebrun@uclouvain.be>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36689 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750753AbdALQuM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 11:50:12 -0500
Received: by mail-pf0-f195.google.com with SMTP id b22so4232477pfd.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 08:50:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Current allocations are not NUMA aware, and lack proper
cleanup in case of error.

It is perfectly fine to use static per cpu allocations for 256 bytes
per cpu.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6_hmac.c |   43 ++---------------------------------------
 1 file changed, 3 insertions(+), 40 deletions(-)

diff --git a/net/ipv6/seg6_hmac.c b/net/ipv6/seg6_hmac.c
index ef1c8a46e7aceee45b2044d4b4338dc3aed88807..6389bf3e9c9f28cdd3e30175f2880b74e099e273 100644
--- a/net/ipv6/seg6_hmac.c
+++ b/net/ipv6/seg6_hmac.c
@@ -45,7 +45,7 @@
 #include <net/seg6_hmac.h>
 #include <linux/random.h>
 
-static char * __percpu *hmac_ring;
+static DEFINE_PER_CPU(char [SEG6_HMAC_RING_SIZE], hmac_ring);
 
 static int seg6_hmac_cmpfn(struct rhashtable_compare_arg *arg, const void *obj)
 {
@@ -192,7 +192,7 @@ int seg6_hmac_compute(struct seg6_hmac_info *hinfo, struct ipv6_sr_hdr *hdr,
 	 */
 
 	local_bh_disable();
-	ring = *this_cpu_ptr(hmac_ring);
+	ring = this_cpu_ptr(hmac_ring);
 	off = ring;
 
 	/* source address */
@@ -353,27 +353,6 @@ int seg6_push_hmac(struct net *net, struct in6_addr *saddr,
 }
 EXPORT_SYMBOL(seg6_push_hmac);
 
-static int seg6_hmac_init_ring(void)
-{
-	int i;
-
-	hmac_ring = alloc_percpu(char *);
-
-	if (!hmac_ring)
-		return -ENOMEM;
-
-	for_each_possible_cpu(i) {
-		char *ring = kzalloc(SEG6_HMAC_RING_SIZE, GFP_KERNEL);
-
-		if (!ring)
-			return -ENOMEM;
-
-		*per_cpu_ptr(hmac_ring, i) = ring;
-	}
-
-	return 0;
-}
-
 static int seg6_hmac_init_algo(void)
 {
 	struct seg6_hmac_algo *algo;
@@ -422,16 +401,7 @@ static int seg6_hmac_init_algo(void)
 
 int __init seg6_hmac_init(void)
 {
-	int ret;
-
-	ret = seg6_hmac_init_ring();
-	if (ret < 0)
-		goto out;
-
-	ret = seg6_hmac_init_algo();
-
-out:
-	return ret;
+	return seg6_hmac_init_algo();
 }
 EXPORT_SYMBOL(seg6_hmac_init);
 
@@ -450,13 +420,6 @@ void seg6_hmac_exit(void)
 	struct seg6_hmac_algo *algo = NULL;
 	int i, alg_count, cpu;
 
-	for_each_possible_cpu(i) {
-		char *ring = *per_cpu_ptr(hmac_ring, i);
-
-		kfree(ring);
-	}
-	free_percpu(hmac_ring);
-
 	alg_count = sizeof(hmac_algos) / sizeof(struct seg6_hmac_algo);
 	for (i = 0; i < alg_count; i++) {
 		algo = &hmac_algos[i];
