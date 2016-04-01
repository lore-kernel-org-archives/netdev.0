From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 04/11] tcp/dccp: use rcu locking in inet_diag_find_one_icsk()
Date: Fri,  1 Apr 2016 08:52:15 -0700
Message-ID: <1459525942-30399-5-git-send-email-edumazet@google.com>
References: <1459525942-30399-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33569 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932736AbcDAPwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:52:34 -0400
Received: by mail-pa0-f48.google.com with SMTP id zm5so94037470pac.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:52:34 -0700 (PDT)
In-Reply-To: <1459525942-30399-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX packet processing holds rcu_read_lock(), so we can remove
pairs of rcu_read_lock()/rcu_read_unlock() in lookup functions
if inet_diag also holds rcu before calling them.

This is needed anyway as __inet_lookup_listener() and
inet6_lookup_listener() will soon no longer increment
refcount on the found listener.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c        | 7 +++++--
 net/ipv4/inet_hashtables.c  | 4 ----
 net/ipv6/inet6_hashtables.c | 4 ----
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 5fdb02f5598e..ea8df527b279 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -356,6 +356,7 @@ struct sock *inet_diag_find_one_icsk(struct net *net,
 {
 	struct sock *sk;
 
+	rcu_read_lock();
 	if (req->sdiag_family == AF_INET)
 		sk = inet_lookup(net, hashinfo, NULL, 0, req->id.idiag_dst[0],
 				 req->id.idiag_dport, req->id.idiag_src[0],
@@ -376,9 +377,11 @@ struct sock *inet_diag_find_one_icsk(struct net *net,
 					  req->id.idiag_if);
 	}
 #endif
-	else
+	else {
+		rcu_read_unlock();
 		return ERR_PTR(-EINVAL);
-
+	}
+	rcu_read_unlock();
 	if (!sk)
 		return ERR_PTR(-ENOENT);
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index bc68eced0105..387338d71dcd 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -220,7 +220,6 @@ struct sock *__inet_lookup_listener(struct net *net,
 	bool select_ok = true;
 	u32 phash = 0;
 
-	rcu_read_lock();
 begin:
 	result = NULL;
 	hiscore = 0;
@@ -269,7 +268,6 @@ found:
 			goto begin;
 		}
 	}
-	rcu_read_unlock();
 	return result;
 }
 EXPORT_SYMBOL_GPL(__inet_lookup_listener);
@@ -312,7 +310,6 @@ struct sock *__inet_lookup_established(struct net *net,
 	unsigned int slot = hash & hashinfo->ehash_mask;
 	struct inet_ehash_bucket *head = &hashinfo->ehash[slot];
 
-	rcu_read_lock();
 begin:
 	sk_nulls_for_each_rcu(sk, node, &head->chain) {
 		if (sk->sk_hash != hash)
@@ -339,7 +336,6 @@ begin:
 out:
 	sk = NULL;
 found:
-	rcu_read_unlock();
 	return sk;
 }
 EXPORT_SYMBOL_GPL(__inet_lookup_established);
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index d253f32874c9..e6ef6ce1ed74 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -69,7 +69,6 @@ struct sock *__inet6_lookup_established(struct net *net,
 	struct inet_ehash_bucket *head = &hashinfo->ehash[slot];
 
 
-	rcu_read_lock();
 begin:
 	sk_nulls_for_each_rcu(sk, node, &head->chain) {
 		if (sk->sk_hash != hash)
@@ -90,7 +89,6 @@ begin:
 out:
 	sk = NULL;
 found:
-	rcu_read_unlock();
 	return sk;
 }
 EXPORT_SYMBOL(__inet6_lookup_established);
@@ -138,7 +136,6 @@ struct sock *inet6_lookup_listener(struct net *net,
 	unsigned int hash = inet_lhashfn(net, hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
 
-	rcu_read_lock();
 begin:
 	result = NULL;
 	hiscore = 0;
@@ -187,7 +184,6 @@ found:
 			goto begin;
 		}
 	}
-	rcu_read_unlock();
 	return result;
 }
 EXPORT_SYMBOL_GPL(inet6_lookup_listener);
-- 
2.8.0.rc3.226.g39d4020
