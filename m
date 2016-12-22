From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 3/6 net-next] inet: kill smallest_size and smallest_port
Date: Thu, 22 Dec 2016 16:26:35 -0500
Message-ID: <1482441998-28359-4-git-send-email-jbacik@fb.com>
References: <1482441998-28359-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <hannes@stressinduktion.org>,
        <kraigatgoog@gmail.com>, <eric.dumazet@gmail.com>,
        <tom@herbertland.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:59953 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S965894AbcLVV10 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 16:27:26 -0500
In-Reply-To: <1482441998-28359-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In inet_csk_get_port we seem to be using smallest_port to figure out where the
best place to look for a SO_REUSEPORT sk that matches with an existing set of
SO_REUSEPORT's.  However if we get to the logic

if (smallest_size != -1) {
	port = smallest_port;
	goto have_port;
}

we will do a useless search, because we would have already done the
inet_csk_bind_conflict for that port and it would have returned 1, otherwise we
would have gone to found_tb and succeeded.  Since this logic makes us do yet
another trip through inet_csk_bind_conflict for a port we know won't work just
delete this code and save us the time.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 net/ipv4/inet_connection_sock.c | 26 ++++----------------------
 1 file changed, 4 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index a1c9055..d352366 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -165,7 +165,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	bool reuse = sk->sk_reuse && sk->sk_state != TCP_LISTEN;
 	struct inet_hashinfo *hinfo = sk->sk_prot->h.hashinfo;
 	int ret = 1, attempts = 5, port = snum;
-	int smallest_size = -1, smallest_port;
 	struct inet_bind_hashbucket *head;
 	struct net *net = sock_net(sk);
 	int i, low, high, attempt_half;
@@ -175,7 +174,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	bool reuseport_ok = !!snum;
 
 	if (port) {
-have_port:
 		head = &hinfo->bhash[inet_bhashfn(net, port,
 						  hinfo->bhash_size)];
 		spin_lock_bh(&head->lock);
@@ -209,8 +207,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	 * We do the opposite to not pollute connect() users.
 	 */
 	offset |= 1U;
-	smallest_size = -1;
-	smallest_port = low; /* avoid compiler warning */
 
 other_parity_scan:
 	port = low + offset;
@@ -224,15 +220,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		spin_lock_bh(&head->lock);
 		inet_bind_bucket_for_each(tb, &head->chain)
 			if (net_eq(ib_net(tb), net) && tb->port == port) {
-				if (((tb->fastreuse > 0 && reuse) ||
-				     (tb->fastreuseport > 0 &&
-				      sk->sk_reuseport &&
-				      !rcu_access_pointer(sk->sk_reuseport_cb) &&
-				      uid_eq(tb->fastuid, uid))) &&
-				    (tb->num_owners < smallest_size || smallest_size == -1)) {
-					smallest_size = tb->num_owners;
-					smallest_port = port;
-				}
 				if (!inet_csk_bind_conflict(sk, tb, false, reuseport_ok))
 					goto tb_found;
 				goto next_port;
@@ -243,10 +230,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		cond_resched();
 	}
 
-	if (smallest_size != -1) {
-		port = smallest_port;
-		goto have_port;
-	}
 	offset--;
 	if (!(offset & 1))
 		goto other_parity_scan;
@@ -268,19 +251,18 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		if (sk->sk_reuse == SK_FORCE_REUSE)
 			goto success;
 
-		if (((tb->fastreuse > 0 && reuse) ||
+		if ((tb->fastreuse > 0 && reuse) ||
 		     (tb->fastreuseport > 0 &&
 		      !rcu_access_pointer(sk->sk_reuseport_cb) &&
-		      sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
-		    smallest_size == -1)
+		      sk->sk_reuseport && uid_eq(tb->fastuid, uid)))
 			goto success;
 		if (inet_csk_bind_conflict(sk, tb, true, reuseport_ok)) {
 			if ((reuse ||
 			     (tb->fastreuseport > 0 &&
 			      sk->sk_reuseport &&
 			      !rcu_access_pointer(sk->sk_reuseport_cb) &&
-			      uid_eq(tb->fastuid, uid))) &&
-			    !snum && smallest_size != -1 && --attempts >= 0) {
+			      uid_eq(tb->fastuid, uid))) && !snum &&
+			    --attempts >= 0) {
 				spin_unlock_bh(&head->lock);
 				goto again;
 			}
-- 
2.5.5
