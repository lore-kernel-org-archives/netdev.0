From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: use hash_32() in tcp_metrics
Date: Fri, 20 Jul 2012 11:02:34 +0200
Message-ID: <1342774954.2626.6290.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57446 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939Ab2GTJCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 05:02:40 -0400
Received: by bkwj10 with SMTP id j10so3148543bkw.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 02:02:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fix a missing roundup_pow_of_two(), since tcpmhash_entries is not
guaranteed to be a power of two.

Uses hash_32() instead of custom hash.

tcpmhash_entries should be an unsigned int.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h |    2 +-
 net/ipv4/tcp_metrics.c   |   25 ++++++++++---------------
 2 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index d909c7f..0ffb8e3 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -40,7 +40,7 @@ struct netns_ipv4 {
 	struct sock		**icmp_sk;
 	struct inet_peer_base	*peers;
 	struct tcpm_hash_bucket	*tcp_metrics_hash;
-	unsigned int		tcp_metrics_hash_mask;
+	unsigned int		tcp_metrics_hash_log;
 	struct netns_frags	frags;
 #ifdef CONFIG_NETFILTER
 	struct xt_table		*iptable_filter;
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 99779ae..992f1bf 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -7,6 +7,7 @@
 #include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/tcp.h>
+#include <linux/hash.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/net_namespace.h>
@@ -228,10 +229,8 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 		return NULL;
 	}
 
-	hash ^= (hash >> 24) ^ (hash >> 16) ^ (hash >> 8);
-
 	net = dev_net(dst->dev);
-	hash &= net->ipv4.tcp_metrics_hash_mask;
+	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
@@ -265,10 +264,8 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 		return NULL;
 	}
 
-	hash ^= (hash >> 24) ^ (hash >> 16) ^ (hash >> 8);
-
 	net = twsk_net(tw);
-	hash &= net->ipv4.tcp_metrics_hash_mask;
+	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
@@ -302,10 +299,8 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 		return NULL;
 	}
 
-	hash ^= (hash >> 24) ^ (hash >> 16) ^ (hash >> 8);
-
 	net = dev_net(dst->dev);
-	hash &= net->ipv4.tcp_metrics_hash_mask;
+	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 
 	tm = __tcp_get_metrics(&addr, net, hash);
 	reclaim = false;
@@ -694,7 +689,7 @@ void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
 	rcu_read_unlock();
 }
 
-static unsigned long tcpmhash_entries;
+static unsigned int tcpmhash_entries;
 static int __init set_tcpmhash_entries(char *str)
 {
 	ssize_t ret;
@@ -702,7 +697,7 @@ static int __init set_tcpmhash_entries(char *str)
 	if (!str)
 		return 0;
 
-	ret = kstrtoul(str, 0, &tcpmhash_entries);
+	ret = kstrtouint(str, 0, &tcpmhash_entries);
 	if (ret)
 		return 0;
 
@@ -712,7 +707,8 @@ __setup("tcpmhash_entries=", set_tcpmhash_entries);
 
 static int __net_init tcp_net_metrics_init(struct net *net)
 {
-	int slots, size;
+	size_t size;
+	unsigned int slots;
 
 	slots = tcpmhash_entries;
 	if (!slots) {
@@ -722,14 +718,13 @@ static int __net_init tcp_net_metrics_init(struct net *net)
 			slots = 8 * 1024;
 	}
 
-	size = slots * sizeof(struct tcpm_hash_bucket);
+	net->ipv4.tcp_metrics_hash_log = order_base_2(slots);
+	size = sizeof(struct tcpm_hash_bucket) << net->ipv4.tcp_metrics_hash_log;
 
 	net->ipv4.tcp_metrics_hash = kzalloc(size, GFP_KERNEL);
 	if (!net->ipv4.tcp_metrics_hash)
 		return -ENOMEM;
 
-	net->ipv4.tcp_metrics_hash_mask = (slots - 1);
-
 	return 0;
 }
 
