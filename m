From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: icmp: use percpu allocation
Date: Thu, 29 Jan 2015 15:58:09 -0800
Message-ID: <1422575889.21689.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:58952 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759180AbbA2X6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 18:58:15 -0500
Received: by mail-ie0-f175.google.com with SMTP id ar1so456578iec.6
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 15:58:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Get rid of nr_cpu_ids and use modern percpu allocation.

Note that the sockets themselves are not yet allocated
using NUMA affinity.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h |    3 ++-
 net/ipv4/icmp.c          |   17 ++++++++---------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 24945cefc4fd..7283f4d39ae2 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -48,7 +48,8 @@ struct netns_ipv4 {
 	struct hlist_head	*fib_table_hash;
 	struct sock		*fibnl;
 
-	struct sock		**icmp_sk;
+	struct sock  * __percpu	*icmp_sk;
+
 	struct inet_peer_base	*peers;
 	struct tcpm_hash_bucket	*tcp_metrics_hash;
 	unsigned int		tcp_metrics_hash_log;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 36f5584d93c5..5e564014a0b7 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -205,7 +205,7 @@ static const struct icmp_control icmp_pointers[NR_ICMP_TYPES+1];
  */
 static struct sock *icmp_sk(struct net *net)
 {
-	return net->ipv4.icmp_sk[smp_processor_id()];
+	return *this_cpu_ptr(net->ipv4.icmp_sk);
 }
 
 static inline struct sock *icmp_xmit_lock(struct net *net)
@@ -1140,8 +1140,8 @@ static void __net_exit icmp_sk_exit(struct net *net)
 	int i;
 
 	for_each_possible_cpu(i)
-		inet_ctl_sock_destroy(net->ipv4.icmp_sk[i]);
-	kfree(net->ipv4.icmp_sk);
+		inet_ctl_sock_destroy(*per_cpu_ptr(net->ipv4.icmp_sk, i));
+	free_percpu(net->ipv4.icmp_sk);
 	net->ipv4.icmp_sk = NULL;
 }
 
@@ -1149,9 +1149,8 @@ static int __net_init icmp_sk_init(struct net *net)
 {
 	int i, err;
 
-	net->ipv4.icmp_sk =
-		kzalloc(nr_cpu_ids * sizeof(struct sock *), GFP_KERNEL);
-	if (net->ipv4.icmp_sk == NULL)
+	net->ipv4.icmp_sk = alloc_percpu(struct sock *);
+	if (!net->ipv4.icmp_sk)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
@@ -1162,7 +1161,7 @@ static int __net_init icmp_sk_init(struct net *net)
 		if (err < 0)
 			goto fail;
 
-		net->ipv4.icmp_sk[i] = sk;
+		*per_cpu_ptr(net->ipv4.icmp_sk, i) = sk;
 
 		/* Enough space for 2 64K ICMP packets, including
 		 * sk_buff/skb_shared_info struct overhead.
@@ -1203,8 +1202,8 @@ static int __net_init icmp_sk_init(struct net *net)
 
 fail:
 	for_each_possible_cpu(i)
-		inet_ctl_sock_destroy(net->ipv4.icmp_sk[i]);
-	kfree(net->ipv4.icmp_sk);
+		inet_ctl_sock_destroy(*per_cpu_ptr(net->ipv4.icmp_sk, i));
+	free_percpu(net->ipv4.icmp_sk);
 	return err;
 }
 
