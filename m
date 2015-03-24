From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/4] tcp: md5: input path is run under rcu protected sections
Date: Mon, 23 Mar 2015 21:34:24 -0700
Message-ID: <1427171666-30585-3-git-send-email-edumazet@google.com>
References: <1427171666-30585-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:34158 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbbCXEen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 00:34:43 -0400
Received: by yhaf10 with SMTP id f10so3600581yha.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 21:34:42 -0700 (PDT)
In-Reply-To: <1427171666-30585-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is guaranteed that both tcp_v4_rcv() and tcp_v6_rcv()
run from rcu read locked sections :

ip_local_deliver_finish() and ip6_input_finish() both
use rcu_read_lock()

Also align tcp_v6_inbound_md5_hash() on tcp_v4_inbound_md5_hash()
by returning a boolean.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c | 17 +++--------------
 net/ipv6/tcp_ipv6.c | 25 ++++++-------------------
 2 files changed, 9 insertions(+), 33 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4e90217003e8..d339a0488f51 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1153,8 +1153,9 @@ clear_hash_noput:
 }
 EXPORT_SYMBOL(tcp_v4_md5_hash_skb);
 
-static bool __tcp_v4_inbound_md5_hash(struct sock *sk,
-				      const struct sk_buff *skb)
+/* Called with rcu_read_lock() */
+static bool tcp_v4_inbound_md5_hash(struct sock *sk,
+				    const struct sk_buff *skb)
 {
 	/*
 	 * This gets called for each TCP segment that arrives
@@ -1206,18 +1207,6 @@ static bool __tcp_v4_inbound_md5_hash(struct sock *sk,
 	}
 	return false;
 }
-
-static bool tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
-{
-	bool ret;
-
-	rcu_read_lock();
-	ret = __tcp_v4_inbound_md5_hash(sk, skb);
-	rcu_read_unlock();
-
-	return ret;
-}
-
 #endif
 
 static void tcp_v4_init_req(struct request_sock *req, struct sock *sk_listener,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4a4e6d30c448..078e7d0f4cd8 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -633,8 +633,7 @@ clear_hash_noput:
 	return 1;
 }
 
-static int __tcp_v6_inbound_md5_hash(struct sock *sk,
-				     const struct sk_buff *skb)
+static bool tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 {
 	const __u8 *hash_location = NULL;
 	struct tcp_md5sig_key *hash_expected;
@@ -648,16 +647,16 @@ static int __tcp_v6_inbound_md5_hash(struct sock *sk,
 
 	/* We've parsed the options - do we have a hash? */
 	if (!hash_expected && !hash_location)
-		return 0;
+		return false;
 
 	if (hash_expected && !hash_location) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPMD5NOTFOUND);
-		return 1;
+		return true;
 	}
 
 	if (!hash_expected && hash_location) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPMD5UNEXPECTED);
-		return 1;
+		return true;
 	}
 
 	/* check the signature */
@@ -670,22 +669,10 @@ static int __tcp_v6_inbound_md5_hash(struct sock *sk,
 				     genhash ? "failed" : "mismatch",
 				     &ip6h->saddr, ntohs(th->source),
 				     &ip6h->daddr, ntohs(th->dest));
-		return 1;
+		return true;
 	}
-	return 0;
-}
-
-static int tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
-{
-	int ret;
-
-	rcu_read_lock();
-	ret = __tcp_v6_inbound_md5_hash(sk, skb);
-	rcu_read_unlock();
-
-	return ret;
+	return false;
 }
-
 #endif
 
 static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
-- 
2.2.0.rc0.207.ga3a616c
