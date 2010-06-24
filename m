From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: use this_cpu_ptr()
Date: Thu, 24 Jun 2010 12:52:37 +0200
Message-ID: <1277376757.2816.272.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:45008 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754559Ab0FXKwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 06:52:42 -0400
Received: by wwi17 with SMTP id 17so92006wwi.19
        for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 03:52:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use this_cpu_ptr(p) instead of per_cpu_ptr(p, smp_processor_id())

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/flow.c     |    4 ++--
 net/ipv4/ip_input.c |    2 +-
 net/ipv4/tcp.c      |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index 1619006..8c7c91a 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -222,7 +222,7 @@ flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
 	unsigned int hash;
 
 	local_bh_disable();
-	fcp = per_cpu_ptr(fc->percpu, smp_processor_id());
+	fcp = this_cpu_ptr(fc->percpu);
 
 	fle = NULL;
 	flo = NULL;
@@ -302,7 +302,7 @@ static void flow_cache_flush_tasklet(unsigned long data)
 	LIST_HEAD(gc_list);
 	int i, deleted = 0;
 
-	fcp = per_cpu_ptr(fc->percpu, smp_processor_id());
+	fcp = this_cpu_ptr(fc->percpu);
 	for (i = 0; i < flow_cache_hash_size(fc); i++) {
 		hlist_for_each_entry_safe(fle, entry, tmp,
 					  &fcp->hash_table[i], u.hlist) {
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index db47a5a..d859bcc 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -342,7 +342,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 
 #ifdef CONFIG_NET_CLS_ROUTE
 	if (unlikely(skb_dst(skb)->tclassid)) {
-		struct ip_rt_acct *st = per_cpu_ptr(ip_rt_acct, smp_processor_id());
+		struct ip_rt_acct *st = this_cpu_ptr(ip_rt_acct);
 		u32 idx = skb_dst(skb)->tclassid;
 		st[idx&0xFF].o_packets++;
 		st[idx&0xFF].o_bytes += skb->len;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 779d40c..b9e721c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2958,7 +2958,7 @@ struct tcp_md5sig_pool *tcp_get_md5sig_pool(void)
 	spin_unlock(&tcp_md5sig_pool_lock);
 
 	if (p)
-		return *per_cpu_ptr(p, smp_processor_id());
+		return *this_cpu_ptr(p);
 
 	local_bh_enable();
 	return NULL;


