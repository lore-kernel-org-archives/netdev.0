From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 2/7] inet: create IPv6-equivalent inet_hash function
Date: Thu,  4 Feb 2016 10:34:31 -0500
Message-ID: <1454600076-30067-3-git-send-email-kraigatgoog@gmail.com>
References: <1454600076-30067-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, cgallek@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:33527 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964943AbcBDPeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 10:34:44 -0500
Received: by mail-qk0-f173.google.com with SMTP id s5so22312533qkd.0
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 07:34:43 -0800 (PST)
In-Reply-To: <1454600076-30067-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

In order to support fast lookups for TCP sockets with SO_REUSEPORT,
the function that adds sockets to the listening hash set needs
to be able to check receive address equality.  Since this equality
check is different for IPv4 and IPv6, we will need two different
socket hashing functions.

This patch adds inet6_hash identical to the existing inet_hash function
and updates the appropriate references.  A following patch will
differentiate the two by passing different comparison functions to
__inet_hash.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/net/inet6_hashtables.h |  2 ++
 net/dccp/ipv6.c                |  2 +-
 net/ipv6/inet6_hashtables.c    | 12 ++++++++++++
 net/ipv6/tcp_ipv6.c            |  2 +-
 net/l2tp/l2tp_ip6.c            |  2 +-
 5 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index 7ff588ca6817..b3c28a9dfbf1 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -96,6 +96,8 @@ struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 			  const struct in6_addr *saddr, const __be16 sport,
 			  const struct in6_addr *daddr, const __be16 dport,
 			  const int dif);
+
+int inet6_hash(struct sock *sk);
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 
 #define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	\
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9c6d0508e63a..90a8269b28d0 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -993,7 +993,7 @@ static struct proto dccp_v6_prot = {
 	.sendmsg	   = dccp_sendmsg,
 	.recvmsg	   = dccp_recvmsg,
 	.backlog_rcv	   = dccp_v6_do_rcv,
-	.hash		   = inet_hash,
+	.hash		   = inet6_hash,
 	.unhash		   = inet_unhash,
 	.accept		   = inet_csk_accept,
 	.get_port	   = inet_csk_get_port,
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 21ace5a2bf7c..3521b15b8b85 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -274,3 +274,15 @@ int inet6_hash_connect(struct inet_timewait_death_row *death_row,
 				   __inet6_check_established);
 }
 EXPORT_SYMBOL_GPL(inet6_hash_connect);
+
+int inet6_hash(struct sock *sk)
+{
+	if (sk->sk_state != TCP_CLOSE) {
+		local_bh_disable();
+		__inet_hash(sk, NULL);
+		local_bh_enable();
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(inet6_hash);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 006396e31cb0..d72bcfb326d8 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1865,7 +1865,7 @@ struct proto tcpv6_prot = {
 	.sendpage		= tcp_sendpage,
 	.backlog_rcv		= tcp_v6_do_rcv,
 	.release_cb		= tcp_release_cb,
-	.hash			= inet_hash,
+	.hash			= inet6_hash,
 	.unhash			= inet_unhash,
 	.get_port		= inet_csk_get_port,
 	.enter_memory_pressure	= tcp_enter_memory_pressure,
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index a2c8747d2936..77adffd227e4 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -718,7 +718,7 @@ static struct proto l2tp_ip6_prot = {
 	.sendmsg	   = l2tp_ip6_sendmsg,
 	.recvmsg	   = l2tp_ip6_recvmsg,
 	.backlog_rcv	   = l2tp_ip6_backlog_recv,
-	.hash		   = inet_hash,
+	.hash		   = inet6_hash,
 	.unhash		   = inet_unhash,
 	.obj_size	   = sizeof(struct l2tp_ip6_sock),
 #ifdef CONFIG_COMPAT
-- 
2.7.0.rc3.207.g0ac5344
