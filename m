From: Eric Garver <e@erig.me>
Subject: [PATCH net] udp: inuse checks can quit early for reuseport
Date: Thu,  5 Jan 2017 20:22:36 -0500
Message-ID: <20170106012236.20078-1-e@erig.me>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751431AbdAFBcX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 20:32:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP lib inuse checks will walk the entire hash bucket to check if the
portaddr is in use. In the case of reuseport we can stop searching when
we find a matching reuseport.

On a 16-core VM a test program that spawns 16 threads that each bind to
1024 sockets (one per 10ms) takes 1m45s. With this change it takes 11s.

Also add a cond_resched() when the port is not specified.

Signed-off-by: Eric Garver <e@erig.me>
---
 net/ipv4/udp.c | 29 +++++++++++++++++++----------
 1 file changed, 19 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1307a7c2e544..4318d72e0248 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -153,13 +153,18 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
-		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
-		     rcu_access_pointer(sk->sk_reuseport_cb) ||
-		     !uid_eq(uid, sock_i_uid(sk2))) &&
 		    saddr_comp(sk, sk2, true)) {
-			if (!bitmap)
-				return 1;
-			__set_bit(udp_sk(sk2)->udp_port_hash >> log, bitmap);
+			if (sk2->sk_reuseport && sk->sk_reuseport &&
+			    !rcu_access_pointer(sk->sk_reuseport_cb) &&
+			    uid_eq(uid, sock_i_uid(sk2))) {
+				if (!bitmap)
+					return 0;
+			} else {
+				if (!bitmap)
+					return 1;
+				__set_bit(udp_sk(sk2)->udp_port_hash >> log,
+					  bitmap);
+			}
 		}
 	}
 	return 0;
@@ -188,11 +193,14 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
-		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
-		     rcu_access_pointer(sk->sk_reuseport_cb) ||
-		     !uid_eq(uid, sock_i_uid(sk2))) &&
 		    saddr_comp(sk, sk2, true)) {
-			res = 1;
+			if (sk2->sk_reuseport && sk->sk_reuseport &&
+			    !rcu_access_pointer(sk->sk_reuseport_cb) &&
+			    uid_eq(uid, sock_i_uid(sk2))) {
+				res = 0;
+			} else {
+				res = 1;
+			}
 			break;
 		}
 	}
@@ -285,6 +293,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 				snum += rand;
 			} while (snum != first);
 			spin_unlock_bh(&hslot->lock);
+			cond_resched();
 		} while (++first != last);
 		goto fail;
 	} else {
-- 
2.10.0
