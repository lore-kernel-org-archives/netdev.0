From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/6] inet: get rid of last __inet_hash_connect() argument
Date: Wed, 18 Mar 2015 14:05:37 -0700
Message-ID: <1426712738-23395-6-git-send-email-edumazet@google.com>
References: <1426712738-23395-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:34714 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933605AbbCRVGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 17:06:12 -0400
Received: by padet14 with SMTP id et14so3446066pad.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 14:06:12 -0700 (PDT)
In-Reply-To: <1426712738-23395-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We now always call __inet_hash_nolisten(), no need to pass it
as an argument.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_hashtables.h | 4 +---
 net/ipv4/inet_hashtables.c    | 9 ++++-----
 net/ipv6/inet6_hashtables.c   | 2 +-
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index eee6c3399990..73fe0f9525d9 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -409,9 +409,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			struct sock *sk, u32 port_offset,
 			int (*check_established)(struct inet_timewait_death_row *,
 						 struct sock *, __u16,
-						 struct inet_timewait_sock **),
-			int (*hash)(struct sock *sk,
-				    struct inet_timewait_sock *twp));
+						 struct inet_timewait_sock **));
 
 int inet_hash_connect(struct inet_timewait_death_row *death_row,
 		      struct sock *sk);
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 82753bd57e79..0fb841b9d834 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -488,8 +488,7 @@ EXPORT_SYMBOL_GPL(inet_unhash);
 int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 		struct sock *sk, u32 port_offset,
 		int (*check_established)(struct inet_timewait_death_row *,
-			struct sock *, __u16, struct inet_timewait_sock **),
-		int (*hash)(struct sock *sk, struct inet_timewait_sock *twp))
+			struct sock *, __u16, struct inet_timewait_sock **))
 {
 	struct inet_hashinfo *hinfo = death_row->hashinfo;
 	const unsigned short snum = inet_sk(sk)->inet_num;
@@ -559,7 +558,7 @@ ok:
 		inet_bind_hash(sk, tb, port);
 		if (sk_unhashed(sk)) {
 			inet_sk(sk)->inet_sport = htons(port);
-			twrefcnt += hash(sk, tw);
+			twrefcnt += __inet_hash_nolisten(sk, tw);
 		}
 		if (tw)
 			twrefcnt += inet_twsk_bind_unhash(tw, hinfo);
@@ -581,7 +580,7 @@ ok:
 	tb  = inet_csk(sk)->icsk_bind_hash;
 	spin_lock_bh(&head->lock);
 	if (sk_head(&tb->owners) == sk && !sk->sk_bind_node.next) {
-		hash(sk, NULL);
+		__inet_hash_nolisten(sk, NULL);
 		spin_unlock_bh(&head->lock);
 		return 0;
 	} else {
@@ -601,7 +600,7 @@ int inet_hash_connect(struct inet_timewait_death_row *death_row,
 		      struct sock *sk)
 {
 	return __inet_hash_connect(death_row, sk, inet_sk_port_offset(sk),
-			__inet_check_established, __inet_hash_nolisten);
+				   __inet_check_established);
 }
 EXPORT_SYMBOL_GPL(inet_hash_connect);
 
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index b86b429f5f81..033f17816ef4 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -270,6 +270,6 @@ int inet6_hash_connect(struct inet_timewait_death_row *death_row,
 		       struct sock *sk)
 {
 	return __inet_hash_connect(death_row, sk, inet6_sk_port_offset(sk),
-			__inet6_check_established, __inet_hash_nolisten);
+				   __inet6_check_established);
 }
 EXPORT_SYMBOL_GPL(inet6_hash_connect);
-- 
2.2.0.rc0.207.ga3a616c
