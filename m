From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 3/5 net-next] inet: don't check for bind conflicts twice when searching for a port
Date: Tue, 20 Dec 2016 15:07:02 -0500
Message-ID: <1482264424-15439-4-git-send-email-jbacik@fb.com>
References: <1482264424-15439-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <hannes@stressinduktion.org>,
        <kraigatgoog@gmail.com>, <eric.dumazet@gmail.com>,
        <tom@herbertland.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45592 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755310AbcLTUHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 15:07:40 -0500
In-Reply-To: <1482264424-15439-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is just wasted time, we've already found a tb that doesn't have a bind
conflict, and we don't drop the head lock so scanning again isn't going to give
us a different answer.  Instead move the tb->reuse setting logic outside of the
found_tb path and put it in the success: path.  Then make it so that we don't
goto again if we find a bind conflict in the found_tb path as we won't reach
this anymore when we are scanning for an ephemeral port.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 net/ipv4/inet_connection_sock.c | 39 ++++++++++++++++++---------------------
 1 file changed, 18 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 1a1a94bd..fc9bfe1 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -92,7 +92,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 {
 	bool reuse = sk->sk_reuse && sk->sk_state != TCP_LISTEN;
 	struct inet_hashinfo *hinfo = sk->sk_prot->h.hashinfo;
-	int ret = 1, attempts = 5, port = snum;
+	int ret = 1, port = snum;
 	struct inet_bind_hashbucket *head;
 	struct net *net = sock_net(sk);
 	int i, low, high, attempt_half;
@@ -100,6 +100,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	kuid_t uid = sock_i_uid(sk);
 	u32 remaining, offset;
 	bool reuseport_ok = !!snum;
+	bool empty_tb = true;
 
 	if (port) {
 		head = &hinfo->bhash[inet_bhashfn(net, port,
@@ -111,7 +112,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 
 		goto tb_not_found;
 	}
-again:
 	attempt_half = (sk->sk_reuse == SK_CAN_REUSE) ? 1 : 0;
 other_half_scan:
 	inet_get_local_port_range(net, &low, &high);
@@ -148,8 +148,12 @@ other_parity_scan:
 		spin_lock_bh(&head->lock);
 		inet_bind_bucket_for_each(tb, &head->chain)
 			if (net_eq(ib_net(tb), net) && tb->port == port) {
-				if (!inet_csk_bind_conflict(sk, tb, false, reuseport_ok))
-					goto tb_found;
+				if (hlist_empty(&tb->owners))
+					goto success;
+				if (!inet_csk_bind_conflict(sk, tb, false, reuseport_ok)) {
+					empty_tb = false;
+					goto success;
+				}
 				goto next_port;
 			}
 		goto tb_not_found;
@@ -184,23 +188,12 @@ tb_found:
 		      !rcu_access_pointer(sk->sk_reuseport_cb) &&
 		      sk->sk_reuseport && uid_eq(tb->fastuid, uid)))
 			goto success;
-		if (inet_csk_bind_conflict(sk, tb, true, reuseport_ok)) {
-			if ((reuse ||
-			     (tb->fastreuseport > 0 &&
-			      sk->sk_reuseport &&
-			      !rcu_access_pointer(sk->sk_reuseport_cb) &&
-			      uid_eq(tb->fastuid, uid))) && !snum &&
-			    --attempts >= 0) {
-				spin_unlock_bh(&head->lock);
-				goto again;
-			}
+		if (inet_csk_bind_conflict(sk, tb, true, reuseport_ok))
 			goto fail_unlock;
-		}
-		if (!reuse)
-			tb->fastreuse = 0;
-		if (!sk->sk_reuseport || !uid_eq(tb->fastuid, uid))
-			tb->fastreuseport = 0;
-	} else {
+		empty_tb = false;
+	}
+success:
+	if (empty_tb) {
 		tb->fastreuse = reuse;
 		if (sk->sk_reuseport) {
 			tb->fastreuseport = 1;
@@ -208,8 +201,12 @@ tb_found:
 		} else {
 			tb->fastreuseport = 0;
 		}
+	} else {
+		if (!reuse)
+			tb->fastreuse = 0;
+		if (!sk->sk_reuseport || !uid_eq(tb->fastuid, uid))
+			tb->fastreuseport = 0;
 	}
-success:
 	if (!inet_csk(sk)->icsk_bind_hash)
 		inet_bind_hash(sk, tb, port);
 	WARN_ON(inet_csk(sk)->icsk_bind_hash != tb);
-- 
2.9.3
