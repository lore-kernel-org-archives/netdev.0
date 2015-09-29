From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 11/14] tcp: cookie_init_sequence() cleanups
Date: Tue, 29 Sep 2015 07:42:49 -0700
Message-ID: <1443537772-15305-12-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33646 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932584AbbI2Orv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:47:51 -0400
Received: by pacex6 with SMTP id ex6so8502523pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:47:50 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some common IPv4/IPv6 code can be factorized.
Also constify cookie_init_sequence() socket argument.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     | 19 ++++++++++---------
 net/ipv4/syncookies.c |  6 +-----
 net/ipv6/syncookies.c |  5 +----
 3 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index a1d2f5d6a430..5aa6672c6f5b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -491,8 +491,9 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb);
 
 /* syncookies: remember time of last synqueue overflow
  * But do not dirty this field too often (once per second is enough)
+ * It is racy as we do not hold a lock, but race is very minor.
  */
-static inline void tcp_synq_overflow(struct sock *sk)
+static inline void tcp_synq_overflow(const struct sock *sk)
 {
 	unsigned long last_overflow = tcp_sk(sk)->rx_opt.ts_recent_stamp;
 	unsigned long now = jiffies;
@@ -519,8 +520,7 @@ static inline u32 tcp_cookie_time(void)
 
 u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
 			      u16 *mssp);
-__u32 cookie_v4_init_sequence(struct sock *sk, const struct sk_buff *skb,
-			      __u16 *mss);
+__u32 cookie_v4_init_sequence(const struct sk_buff *skb, __u16 *mss);
 __u32 cookie_init_timestamp(struct request_sock *req);
 bool cookie_timestamp_decode(struct tcp_options_received *opt);
 bool cookie_ecn_ok(const struct tcp_options_received *opt,
@@ -533,8 +533,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
 
 u32 __cookie_v6_init_sequence(const struct ipv6hdr *iph,
 			      const struct tcphdr *th, u16 *mssp);
-__u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb,
-			      __u16 *mss);
+__u32 cookie_v6_init_sequence(const struct sk_buff *skb, __u16 *mss);
 #endif
 /* tcp_output.c */
 
@@ -1709,7 +1708,7 @@ struct tcp_request_sock_ops {
 			 const struct sock *sk_listener,
 			 struct sk_buff *skb);
 #ifdef CONFIG_SYN_COOKIES
-	__u32 (*cookie_init_seq)(struct sock *sk, const struct sk_buff *skb,
+	__u32 (*cookie_init_seq)(const struct sk_buff *skb,
 				 __u16 *mss);
 #endif
 	struct dst_entry *(*route_req)(struct sock *sk, struct flowi *fl,
@@ -1725,14 +1724,16 @@ struct tcp_request_sock_ops {
 
 #ifdef CONFIG_SYN_COOKIES
 static inline __u32 cookie_init_sequence(const struct tcp_request_sock_ops *ops,
-					 struct sock *sk, struct sk_buff *skb,
+					 const struct sock *sk, struct sk_buff *skb,
 					 __u16 *mss)
 {
-	return ops->cookie_init_seq(sk, skb, mss);
+	tcp_synq_overflow(sk);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
+	return ops->cookie_init_seq(skb, mss);
 }
 #else
 static inline __u32 cookie_init_sequence(const struct tcp_request_sock_ops *ops,
-					 struct sock *sk, struct sk_buff *skb,
+					 const struct sock *sk, struct sk_buff *skb,
 					 __u16 *mss)
 {
 	return 0;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 6595affded20..6b97b5f6457c 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -192,15 +192,11 @@ u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
 }
 EXPORT_SYMBOL_GPL(__cookie_v4_init_sequence);
 
-__u32 cookie_v4_init_sequence(struct sock *sk, const struct sk_buff *skb,
-			      __u16 *mssp)
+__u32 cookie_v4_init_sequence(const struct sk_buff *skb, __u16 *mssp)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	const struct tcphdr *th = tcp_hdr(skb);
 
-	tcp_synq_overflow(sk);
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
-
 	return __cookie_v4_init_sequence(iph, th, mssp);
 }
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 2461b3ff9551..7606eba83e7b 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -114,14 +114,11 @@ u32 __cookie_v6_init_sequence(const struct ipv6hdr *iph,
 }
 EXPORT_SYMBOL_GPL(__cookie_v6_init_sequence);
 
-__u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb, __u16 *mssp)
+__u32 cookie_v6_init_sequence(const struct sk_buff *skb, __u16 *mssp)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	const struct tcphdr *th = tcp_hdr(skb);
 
-	tcp_synq_overflow(sk);
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
-
 	return __cookie_v6_init_sequence(iph, th, mssp);
 }
 
-- 
2.6.0.rc2.230.g3dd15c0
