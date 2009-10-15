From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [PATCH 5/5] net: Encapsulate inner code of __sk_dst_reset
Date: Thu, 15 Oct 2009 11:27:58 +0530
Message-ID: <20091015055758.30145.77495.sendpatchset@localhost.localdomain>
References: <20091015055602.30145.65852.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:55006 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933015AbZJOF6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 01:58:51 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9F5w2Ju004147
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 11:28:02 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9F5w1oM2429078
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 11:28:01 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9F5w1s8016623
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:58:01 +1100
In-Reply-To: <20091015055602.30145.65852.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Reuse code by adding ___sk_dst_reset() which is called by
__sk_dst_reset() and __sk_dst_check(). This new API is also
called from IPv6 to hide the internals of __sk_dst_reset
and the setting of sk_tx_queue_mapping.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/net/sock.h               |   13 +++++++++----
 net/core/sock.c                  |    4 +---
 net/ipv6/inet6_connection_sock.c |    4 +---
 3 files changed, 11 insertions(+), 10 deletions(-)

diff -ruNp org/include/net/sock.h new/include/net/sock.h
--- org/include/net/sock.h	2009-10-14 18:00:17.000000000 +0530
+++ new/include/net/sock.h	2009-10-14 18:00:30.000000000 +0530
@@ -1186,17 +1186,22 @@ sk_dst_set(struct sock *sk, struct dst_e
 }
 
 static inline void
-__sk_dst_reset(struct sock *sk)
+___sk_dst_reset(struct sock *sk, struct dst_entry *old_dst)
 {
-	struct dst_entry *old_dst;
-
 	sk_record_tx_queue(sk, -1);
-	old_dst = sk->sk_dst_cache;
 	sk->sk_dst_cache = NULL;
 	dst_release(old_dst);
 }
 
 static inline void
+__sk_dst_reset(struct sock *sk)
+{
+	struct dst_entry *old_dst = sk->sk_dst_cache;
+
+	___sk_dst_reset(sk, old_dst);
+}
+
+static inline void
 sk_dst_reset(struct sock *sk)
 {
 	write_lock(&sk->sk_dst_lock);
diff -ruNp org/net/core/sock.c new/net/core/sock.c
--- org/net/core/sock.c	2009-10-14 18:00:22.000000000 +0530
+++ new/net/core/sock.c	2009-10-14 18:00:30.000000000 +0530
@@ -364,9 +364,7 @@ struct dst_entry *__sk_dst_check(struct 
 	struct dst_entry *dst = sk->sk_dst_cache;
 
 	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
-		sk_record_tx_queue(sk, -1);
-		sk->sk_dst_cache = NULL;
-		dst_release(dst);
+		___sk_dst_reset(sk, dst);
 		return NULL;
 	}
 
diff -ruNp org/net/ipv6/inet6_connection_sock.c new/net/ipv6/inet6_connection_sock.c
--- org/net/ipv6/inet6_connection_sock.c	2009-10-14 18:00:17.000000000 +0530
+++ new/net/ipv6/inet6_connection_sock.c	2009-10-14 18:00:30.000000000 +0530
@@ -168,9 +168,7 @@ struct dst_entry *__inet6_csk_dst_check(
 	if (dst) {
 		struct rt6_info *rt = (struct rt6_info *)dst;
 		if (rt->rt6i_flow_cache_genid != atomic_read(&flow_cache_genid)) {
-			sk_record_tx_queue(sk, -1);
-			sk->sk_dst_cache = NULL;
-			dst_release(dst);
+			___sk_dst_reset(sk, dst);
 			dst = NULL;
 		}
 	}
