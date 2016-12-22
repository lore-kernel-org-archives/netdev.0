From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 5/6 net-next] inet: split inet_csk_get_port into two functions
Date: Thu, 22 Dec 2016 16:26:37 -0500
Message-ID: <1482441998-28359-6-git-send-email-jbacik@fb.com>
References: <1482441998-28359-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <hannes@stressinduktion.org>,
        <kraigatgoog@gmail.com>, <eric.dumazet@gmail.com>,
        <tom@herbertland.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58717 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932510AbcLVV1X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 16:27:23 -0500
In-Reply-To: <1482441998-28359-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_csk_get_port does two different things, it either scans for an open port,
or it tries to see if the specified port is available for use.  Since these two
operations have different rules and are basically independent lets split them
into two different functions to make them both more readable.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 net/ipv4/inet_connection_sock.c | 66 +++++++++++++++++++++++++++--------------
 1 file changed, 44 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index f6a34bc..923bd60 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -156,33 +156,21 @@ static int inet_csk_bind_conflict(const struct sock *sk,
 	return sk2 != NULL;
 }
 
-/* Obtain a reference to a local port for the given sock,
- * if snum is zero it means select any available local port.
- * We try to allocate an odd port (and leave even ports for connect())
+/*
+ * Find an open port number for the socket.  Returns with the
+ * inet_bind_hashbucket lock held.
  */
-int inet_csk_get_port(struct sock *sk, unsigned short snum)
+static struct inet_bind_hashbucket *
+inet_csk_find_open_port(struct sock *sk, struct inet_bind_bucket **tb_ret, int *port_ret)
 {
-	bool reuse = sk->sk_reuse && sk->sk_state != TCP_LISTEN;
 	struct inet_hashinfo *hinfo = sk->sk_prot->h.hashinfo;
-	int ret = 1, port = snum;
+	int port = 0;
 	struct inet_bind_hashbucket *head;
 	struct net *net = sock_net(sk);
 	int i, low, high, attempt_half;
 	struct inet_bind_bucket *tb;
-	kuid_t uid = sock_i_uid(sk);
 	u32 remaining, offset;
-	bool reuseport_ok = !!snum;
 
-	if (port) {
-		head = &hinfo->bhash[inet_bhashfn(net, port,
-						  hinfo->bhash_size)];
-		spin_lock_bh(&head->lock);
-		inet_bind_bucket_for_each(tb, &head->chain)
-			if (net_eq(ib_net(tb), net) && tb->port == port)
-				goto tb_found;
-
-		goto tb_not_found;
-	}
 	attempt_half = (sk->sk_reuse == SK_CAN_REUSE) ? 1 : 0;
 other_half_scan:
 	inet_get_local_port_range(net, &low, &high);
@@ -221,11 +209,12 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 			if (net_eq(ib_net(tb), net) && tb->port == port) {
 				if (hlist_empty(&tb->owners))
 					goto success;
-				if (!inet_csk_bind_conflict(sk, tb, false, reuseport_ok))
+				if (!inet_csk_bind_conflict(sk, tb, false, false))
 					goto success;
 				goto next_port;
 			}
-		goto tb_not_found;
+		tb = NULL;
+		goto success;
 next_port:
 		spin_unlock_bh(&head->lock);
 		cond_resched();
@@ -240,8 +229,41 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		attempt_half = 2;
 		goto other_half_scan;
 	}
-	return ret;
+	return NULL;
+success:
+	*port_ret = port;
+	*tb_ret = tb;
+	return head;
+}
+
+/* Obtain a reference to a local port for the given sock,
+ * if snum is zero it means select any available local port.
+ * We try to allocate an odd port (and leave even ports for connect())
+ */
+int inet_csk_get_port(struct sock *sk, unsigned short snum)
+{
+	bool reuse = sk->sk_reuse && sk->sk_state != TCP_LISTEN;
+	struct inet_hashinfo *hinfo = sk->sk_prot->h.hashinfo;
+	int ret = 1, port = snum;
+	struct inet_bind_hashbucket *head;
+	struct net *net = sock_net(sk);
+	struct inet_bind_bucket *tb = NULL;
+	kuid_t uid = sock_i_uid(sk);
 
+	if (!port) {
+		head = inet_csk_find_open_port(sk, &tb, &port);
+		if (!head)
+			return ret;
+		if (!tb)
+			goto tb_not_found;
+		goto success;
+	}
+	head = &hinfo->bhash[inet_bhashfn(net, port,
+					  hinfo->bhash_size)];
+	spin_lock_bh(&head->lock);
+	inet_bind_bucket_for_each(tb, &head->chain)
+		if (net_eq(ib_net(tb), net) && tb->port == port)
+			goto tb_found;
 tb_not_found:
 	tb = inet_bind_bucket_create(hinfo->bind_bucket_cachep,
 				     net, head, port);
@@ -257,7 +279,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		      !rcu_access_pointer(sk->sk_reuseport_cb) &&
 		      sk->sk_reuseport && uid_eq(tb->fastuid, uid)))
 			goto success;
-		if (inet_csk_bind_conflict(sk, tb, true, reuseport_ok))
+		if (inet_csk_bind_conflict(sk, tb, true, true))
 			goto fail_unlock;
 	}
 success:
-- 
2.5.5
