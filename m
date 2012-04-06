From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [PATCH net-next v2] tcp: bind() use stronger condition for bind_conflict
Date: Fri,  6 Apr 2012 10:47:24 +0300
Message-ID: <1333698444-24144-1-git-send-email-alex.mihai.c@gmail.com>
Cc: fbl@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	Alex Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:54149 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588Ab2DFHtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 03:49:08 -0400
Received: by wibhj6 with SMTP id hj6so326053wib.1
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 00:49:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Copot <alex.mihai.c@gmail.com>

We must try harder to get unique (addr, port) pairs when
doing port autoselection for sockets with SO_REUSEADDR
option set.

We achieve this by adding a relaxation parameter to
inet_csk_bind_conflict. When 'relax' parameter is off
we return a conflict whenever the current searched
pair (addr, port) is not unique.

This tries to address the problems reported in patch:
	8d238b25b1ec22a73b1c2206f111df2faaff8285
	Revert "tcp: bind() fix when many ports are bound"

Tests where ran for creating and binding(0) many sockets
on 100 IPs. The results are, on average:

	* 60000 sockets, 600 ports / IP:
		* 0.210 s, 620 (IP, port) duplicates without patch
		* 0.219 s, no duplicates with patch
	* 100000 sockets, 1000 ports / IP:
		* 0.371 s, 1720 duplicates without patch
		* 0.373 s, no duplicates with patch
	* 200000 sockets, 2000 ports / IP:
		* 0.766 s, 6900 duplicates without patch
		* 0.768 s, no duplicates with patch
	* 500000 sockets, 5000 ports / IP:
		* 2.227 s, 41500 duplicates without patch
		* 2.284 s, no duplicates with patch

Signed-off-by: Alex Copot <alex.mihai.c@gmail.com>
Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>

---
Changes from v1:
 - Fixed coding style
 - Replaced int flag with bool
 - Added test results
---
 include/net/inet6_connection_sock.h |    2 +-
 include/net/inet_connection_sock.h  |    4 ++--
 net/ipv4/inet_connection_sock.c     |   17 +++++++++++++----
 net/ipv6/inet6_connection_sock.c    |    2 +-
 4 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index 3207e58..1866a67 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -23,7 +23,7 @@ struct sock;
 struct sockaddr;
 
 extern int inet6_csk_bind_conflict(const struct sock *sk,
-				   const struct inet_bind_bucket *tb);
+				   const struct inet_bind_bucket *tb, bool relax);
 
 extern struct dst_entry* inet6_csk_route_req(struct sock *sk,
 					     const struct request_sock *req);
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index dbf9aab..46c9e2c 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -60,7 +60,7 @@ struct inet_connection_sock_af_ops {
 #endif
 	void	    (*addr2sockaddr)(struct sock *sk, struct sockaddr *);
 	int	    (*bind_conflict)(const struct sock *sk,
-				     const struct inet_bind_bucket *tb);
+				     const struct inet_bind_bucket *tb, bool relax);
 };
 
 /** inet_connection_sock - INET connection oriented sock
@@ -245,7 +245,7 @@ extern struct request_sock *inet_csk_search_req(const struct sock *sk,
 						const __be32 raddr,
 						const __be32 laddr);
 extern int inet_csk_bind_conflict(const struct sock *sk,
-				  const struct inet_bind_bucket *tb);
+				  const struct inet_bind_bucket *tb, bool relax);
 extern int inet_csk_get_port(struct sock *sk, unsigned short snum);
 
 extern struct dst_entry* inet_csk_route_req(struct sock *sk,
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 19d66ce..13ef772 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -53,7 +53,7 @@ void inet_get_local_port_range(int *low, int *high)
 EXPORT_SYMBOL(inet_get_local_port_range);
 
 int inet_csk_bind_conflict(const struct sock *sk,
-			   const struct inet_bind_bucket *tb)
+			   const struct inet_bind_bucket *tb, bool relax)
 {
 	struct sock *sk2;
 	struct hlist_node *node;
@@ -79,6 +79,13 @@ int inet_csk_bind_conflict(const struct sock *sk,
 				    sk2_rcv_saddr == sk_rcv_saddr(sk))
 					break;
 			}
+			if (!relax && reuse && sk2->sk_reuse &&
+				sk2->sk_state != TCP_LISTEN) {
+				const __be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
+				if (!sk2_rcv_saddr || !sk_rcv_saddr(sk) ||
+				    sk2_rcv_saddr == sk_rcv_saddr(sk))
+					break;
+			}
 		}
 	}
 	return node != NULL;
@@ -122,12 +129,13 @@ again:
 					    (tb->num_owners < smallest_size || smallest_size == -1)) {
 						smallest_size = tb->num_owners;
 						smallest_rover = rover;
-						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) {
+						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1 &&
+						    !inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false)) {
 							snum = smallest_rover;
 							goto tb_found;
 						}
 					}
-					if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
+					if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false)) {
 						snum = rover;
 						goto tb_found;
 					}
@@ -178,12 +186,13 @@ tb_found:
 			goto success;
 		} else {
 			ret = 1;
-			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
+			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true)) {
 				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN &&
 				    smallest_size != -1 && --attempts >= 0) {
 					spin_unlock(&head->lock);
 					goto again;
 				}
+
 				goto fail_unlock;
 			}
 		}
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 02dd203..e6cee52 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -28,7 +28,7 @@
 #include <net/inet6_connection_sock.h>
 
 int inet6_csk_bind_conflict(const struct sock *sk,
-			    const struct inet_bind_bucket *tb)
+			    const struct inet_bind_bucket *tb, bool relax)
 {
 	const struct sock *sk2;
 	const struct hlist_node *node;
-- 
1.7.9.6
