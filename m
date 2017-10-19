From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net] soreuseport: fix initialization race
Date: Thu, 19 Oct 2017 15:00:29 -0400
Message-ID: <20171019190029.163693-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:44465 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752866AbdJSTAc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 15:00:32 -0400
Received: by mail-io0-f196.google.com with SMTP id m16so10924709iod.1
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 12:00:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

Syzkaller stumbled upon a way to trigger
WARNING: CPU: 1 PID: 13881 at net/core/sock_reuseport.c:41
reuseport_alloc+0x306/0x3b0 net/core/sock_reuseport.c:39

There are two initialization paths for the sock_reuseport structure in a
socket: Through the udp/tcp bind paths of SO_REUSEPORT sockets or through
SO_ATTACH_REUSEPORT_[CE]BPF before bind.  The existing implementation
assumedthat the socket lock protected both of these paths when it actually
only protects the SO_ATTACH_REUSEPORT path.  Syzkaller triggered this
double allocation by running these paths concurrently.

This patch moves the check for double allocation into the reuseport_alloc
function which is protected by a global spin lock.

Fixes: e32ea7e74727 ("soreuseport: fast reuseport UDP socket selection")
Fixes: c125e80b8868 ("soreuseport: fast reuseport TCP socket selection")
Signed-off-by: Craig Gallek <kraig@google.com>
---
 net/core/sock_reuseport.c  | 12 +++++++++---
 net/ipv4/inet_hashtables.c |  5 +----
 net/ipv4/udp.c             |  5 +----
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/core/sock_reuseport.c b/net/core/sock_reuseport.c
index eed1ebf7f29d..b1e0dbea1e8c 100644
--- a/net/core/sock_reuseport.c
+++ b/net/core/sock_reuseport.c
@@ -36,9 +36,14 @@ int reuseport_alloc(struct sock *sk)
 	 * soft irq of receive path or setsockopt from process context
 	 */
 	spin_lock_bh(&reuseport_lock);
-	WARN_ONCE(rcu_dereference_protected(sk->sk_reuseport_cb,
-					    lockdep_is_held(&reuseport_lock)),
-		  "multiple allocations for the same socket");
+
+	/* Allocation attempts can occur concurrently via the setsockopt path
+	 * and the bind/hash path.  Nothing to do when we lose the race.
+	 */
+	if (rcu_dereference_protected(sk->sk_reuseport_cb,
+				      lockdep_is_held(&reuseport_lock)))
+		goto out;
+
 	reuse = __reuseport_alloc(INIT_SOCKS);
 	if (!reuse) {
 		spin_unlock_bh(&reuseport_lock);
@@ -49,6 +54,7 @@ int reuseport_alloc(struct sock *sk)
 	reuse->num_socks = 1;
 	rcu_assign_pointer(sk->sk_reuseport_cb, reuse);
 
+out:
 	spin_unlock_bh(&reuseport_lock);
 
 	return 0;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 597bb4cfe805..e7d15fb0d94d 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -456,10 +456,7 @@ static int inet_reuseport_add_sock(struct sock *sk,
 			return reuseport_add_sock(sk, sk2);
 	}
 
-	/* Initial allocation may have already happened via setsockopt */
-	if (!rcu_access_pointer(sk->sk_reuseport_cb))
-		return reuseport_alloc(sk);
-	return 0;
+	return reuseport_alloc(sk);
 }
 
 int __inet_hash(struct sock *sk, struct sock *osk)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e45177ceb0ee..3cd8103bab2c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -231,10 +231,7 @@ static int udp_reuseport_add_sock(struct sock *sk, struct udp_hslot *hslot)
 		}
 	}
 
-	/* Initial allocation may have already happened via setsockopt */
-	if (!rcu_access_pointer(sk->sk_reuseport_cb))
-		return reuseport_alloc(sk);
-	return 0;
+	return reuseport_alloc(sk);
 }
 
 /**
-- 
2.15.0.rc1.287.g2b38de12cc-goog
