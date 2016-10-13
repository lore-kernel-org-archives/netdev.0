From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: Require exact match for TCP socket lookups if dif is l3mdev
Date: Thu, 13 Oct 2016 13:14:50 -0700
Message-ID: <1476389690-31211-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35924 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752277AbcJMUO7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 16:14:59 -0400
Received: by mail-pa0-f53.google.com with SMTP id ry6so41223142pac.3
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 13:14:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, socket lookups for l3mdev (vrf) use cases can match a socket
that is bound to a port but not a device (ie., a global socket). If the
sysctl tcp_l3mdev_accept is not set this leads to ack packets going out
based on the main table even though the packet came in from an L3 domain.
The end result is that the connection does not establish creating
confusion for users since the service is running and a socket shows in
ss output. Fix by requiring an exact dif to sk_bound_dev_if match if the
dif is an l3mdev device and the tcp_l3mdev_accept is not set.

Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/inet_sock.h     | 10 ++++++++++
 net/ipv4/inet_hashtables.c  |  7 ++++---
 net/ipv6/inet6_hashtables.c |  7 ++++---
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 236a81034fef..abb4e720a769 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -132,6 +132,16 @@ static inline int inet_request_bound_dev_if(const struct sock *sk,
 	return sk->sk_bound_dev_if;
 }
 
+static inline bool inet_exact_dif_match(struct net *net, int dif)
+{
+#ifdef CONFIG_NET_L3_MASTER_DEV
+	if (netif_index_is_l3_master(net, dif) &&
+	    !net->ipv4.sysctl_tcp_l3mdev_accept)
+		return true;
+#endif
+	return false;
+}
+
 struct inet_cork {
 	unsigned int		flags;
 	__be32			addr;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 77c20a489218..08b3598c43f9 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -172,7 +172,7 @@ EXPORT_SYMBOL_GPL(__inet_inherit_port);
 
 static inline int compute_score(struct sock *sk, struct net *net,
 				const unsigned short hnum, const __be32 daddr,
-				const int dif)
+				const int dif, bool exact_dif)
 {
 	int score = -1;
 	struct inet_sock *inet = inet_sk(sk);
@@ -186,7 +186,7 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score += 4;
 		}
-		if (sk->sk_bound_dev_if) {
+		if (sk->sk_bound_dev_if || exact_dif) {
 			if (sk->sk_bound_dev_if != dif)
 				return -1;
 			score += 4;
@@ -215,11 +215,12 @@ struct sock *__inet_lookup_listener(struct net *net,
 	unsigned int hash = inet_lhashfn(net, hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
 	int score, hiscore = 0, matches = 0, reuseport = 0;
+	bool exact_dif = inet_exact_dif_match(net, dif);
 	struct sock *sk, *result = NULL;
 	u32 phash = 0;
 
 	sk_for_each_rcu(sk, &ilb->head) {
-		score = compute_score(sk, net, hnum, daddr, dif);
+		score = compute_score(sk, net, hnum, daddr, dif, exact_dif);
 		if (score > hiscore) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 00cf28ad4565..f85924883056 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -96,7 +96,7 @@ EXPORT_SYMBOL(__inet6_lookup_established);
 static inline int compute_score(struct sock *sk, struct net *net,
 				const unsigned short hnum,
 				const struct in6_addr *daddr,
-				const int dif)
+				const int dif, bool exact_dif)
 {
 	int score = -1;
 
@@ -109,7 +109,7 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score++;
 		}
-		if (sk->sk_bound_dev_if) {
+		if (sk->sk_bound_dev_if || exact_dif) {
 			if (sk->sk_bound_dev_if != dif)
 				return -1;
 			score++;
@@ -131,11 +131,12 @@ struct sock *inet6_lookup_listener(struct net *net,
 	unsigned int hash = inet_lhashfn(net, hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
 	int score, hiscore = 0, matches = 0, reuseport = 0;
+	bool exact_dif = inet_exact_dif_match(net, dif);
 	struct sock *sk, *result = NULL;
 	u32 phash = 0;
 
 	sk_for_each(sk, &ilb->head) {
-		score = compute_score(sk, net, hnum, daddr, dif);
+		score = compute_score(sk, net, hnum, daddr, dif, exact_dif);
 		if (score > hiscore) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-- 
2.1.4
