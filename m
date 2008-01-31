From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/6][IPV6]: Introduce the INET6_TW_MATCH macro.
Date: Thu, 31 Jan 2008 15:29:20 +0300
Message-ID: <47A1BF20.7070509@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:59126 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758386AbYAaM3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 07:29:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have INET_MATCH, INET_TW_MATCH and INET6_MATCH to test
sockets and twbuckets for matching, but ipv6 twbuckets are
tested manually.

Here's the INET6_TW_MATCH to help with it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/linux/ipv6.h        |    8 ++++++++
 net/ipv6/inet6_hashtables.c |   21 +++------------------
 2 files changed, 11 insertions(+), 18 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 5d35a4c..c347860 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -465,6 +465,14 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&& \
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 
+#define INET6_TW_MATCH(__sk, __hash, __saddr, __daddr, __ports, __dif) \
+	(((__sk)->sk_hash == (__hash))					&& \
+	 (*((__portpair *)&(inet_twsk(__sk)->tw_dport)) == (__ports))	&& \
+	 ((__sk)->sk_family	       == PF_INET6)			&& \
+	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_daddr, (__saddr)))	&& \
+	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_rcv_saddr, (__daddr))) && \
+	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
+
 #endif /* __KERNEL__ */
 
 #endif /* _IPV6_H */
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index a66a7d8..06b01be 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -80,17 +80,8 @@ struct sock *__inet6_lookup_established(struct inet_hashinfo *hashinfo,
 	}
 	/* Must check for a TIME_WAIT'er before going to listener hash. */
 	sk_for_each(sk, node, &head->twchain) {
-		const struct inet_timewait_sock *tw = inet_twsk(sk);
-
-		if(*((__portpair *)&(tw->tw_dport))	== ports	&&
-		   sk->sk_family		== PF_INET6) {
-			const struct inet6_timewait_sock *tw6 = inet6_twsk(sk);
-
-			if (ipv6_addr_equal(&tw6->tw_v6_daddr, saddr)	&&
-			    ipv6_addr_equal(&tw6->tw_v6_rcv_saddr, daddr)	&&
-			    (!sk->sk_bound_dev_if || sk->sk_bound_dev_if == dif))
-				goto hit;
-		}
+		if (INET6_TW_MATCH(sk, hash, saddr, daddr, ports, dif))
+			goto hit;
 	}
 	read_unlock(lock);
 	return NULL;
@@ -185,15 +176,9 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 
 	/* Check TIME-WAIT sockets first. */
 	sk_for_each(sk2, node, &head->twchain) {
-		const struct inet6_timewait_sock *tw6 = inet6_twsk(sk2);
-
 		tw = inet_twsk(sk2);
 
-		if(*((__portpair *)&(tw->tw_dport)) == ports		 &&
-		   sk2->sk_family	       == PF_INET6	 &&
-		   ipv6_addr_equal(&tw6->tw_v6_daddr, saddr)	 &&
-		   ipv6_addr_equal(&tw6->tw_v6_rcv_saddr, daddr) &&
-		   (!sk2->sk_bound_dev_if || sk2->sk_bound_dev_if == dif)) {
+		if (INET6_TW_MATCH(sk2, hash, saddr, daddr, ports, dif)) {
 			if (twsk_unique(sk, sk2, twp))
 				goto unique;
 			else
-- 
1.5.3.4

