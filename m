From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] tcp/dccp: better use of ephemeral ports in bind()
Date: Fri,  5 Feb 2016 18:08:58 -0800
Message-ID: <1454724538-13556-3-git-send-email-edumazet@google.com>
References: <1454724538-13556-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35829 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbcBFCJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 21:09:10 -0500
Received: by mail-pf0-f169.google.com with SMTP id c10so11600383pfc.2
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 18:09:10 -0800 (PST)
In-Reply-To: <1454724538-13556-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement strategy used in __inet_hash_connect() in opposite way :

Try to find a candidate using odd ports, then fallback to even ports.

We no longer disable BH for whole traversal, but one bucket at a time.
We also use cond_resched() to yield cpu to other tasks if needed.

I removed one indentation level and tried to mirror the loop we have
in __inet_hash_connect() and variable names to ease code maintenance.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_connection_sock.c | 231 +++++++++++++++++++---------------------
 1 file changed, 110 insertions(+), 121 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 46b9c887bede..dbc14e02cb25 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -89,161 +89,150 @@ EXPORT_SYMBOL_GPL(inet_csk_bind_conflict);
 
 /* Obtain a reference to a local port for the given sock,
  * if snum is zero it means select any available local port.
+ * We try to allocate an odd port (and leave even ports for connect())
  */
 int inet_csk_get_port(struct sock *sk, unsigned short snum)
 {
-	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
+	bool reuse = sk->sk_reuse && sk->sk_state != TCP_LISTEN;
+	struct inet_hashinfo *hinfo = sk->sk_prot->h.hashinfo;
+	int ret = 1, attempts = 5, port = snum;
+	int smallest_size = -1, smallest_port;
 	struct inet_bind_hashbucket *head;
-	struct inet_bind_bucket *tb;
-	int ret, attempts = 5;
 	struct net *net = sock_net(sk);
-	int smallest_size = -1, smallest_rover;
+	int i, low, high, attempt_half;
+	struct inet_bind_bucket *tb;
 	kuid_t uid = sock_i_uid(sk);
-	int attempt_half = (sk->sk_reuse == SK_CAN_REUSE) ? 1 : 0;
+	u32 remaining, offset;
 
-	local_bh_disable();
-	if (!snum) {
-		int remaining, rover, low, high;
+	if (port) {
+have_port:
+		head = &hinfo->bhash[inet_bhashfn(net, port,
+						  hinfo->bhash_size)];
+		spin_lock_bh(&head->lock);
+		inet_bind_bucket_for_each(tb, &head->chain)
+			if (net_eq(ib_net(tb), net) && tb->port == port)
+				goto tb_found;
 
+		goto tb_not_found;
+	}
 again:
-		inet_get_local_port_range(net, &low, &high);
-		if (attempt_half) {
-			int half = low + ((high - low) >> 1);
-
-			if (attempt_half == 1)
-				high = half;
-			else
-				low = half;
-		}
-		remaining = (high - low) + 1;
-		smallest_rover = rover = prandom_u32() % remaining + low;
-
-		smallest_size = -1;
-		do {
-			if (inet_is_local_reserved_port(net, rover))
-				goto next_nolock;
-			head = &hashinfo->bhash[inet_bhashfn(net, rover,
-					hashinfo->bhash_size)];
-			spin_lock(&head->lock);
-			inet_bind_bucket_for_each(tb, &head->chain)
-				if (net_eq(ib_net(tb), net) && tb->port == rover) {
-					if (((tb->fastreuse > 0 &&
-					      sk->sk_reuse &&
-					      sk->sk_state != TCP_LISTEN) ||
-					     (tb->fastreuseport > 0 &&
-					      sk->sk_reuseport &&
-					      uid_eq(tb->fastuid, uid))) &&
-					    (tb->num_owners < smallest_size || smallest_size == -1)) {
-						smallest_size = tb->num_owners;
-						smallest_rover = rover;
-					}
-					if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false)) {
-						snum = rover;
-						goto tb_found;
-					}
-					goto next;
+	attempt_half = (sk->sk_reuse == SK_CAN_REUSE) ? 1 : 0;
+other_half_scan:
+	inet_get_local_port_range(net, &low, &high);
+	high++; /* [32768, 60999] -> [32768, 61000[ */
+	if (high - low < 4)
+		attempt_half = 0;
+	if (attempt_half) {
+		int half = low + (((high - low) >> 2) << 1);
+
+		if (attempt_half == 1)
+			high = half;
+		else
+			low = half;
+	}
+	remaining = high - low;
+	if (likely(remaining > 1))
+		remaining &= ~1U;
+
+	offset = prandom_u32() % remaining;
+	/* __inet_hash_connect() favors ports having @low parity
+	 * We do the opposite to not pollute connect() users.
+	 */
+	offset |= 1U;
+	smallest_size = -1;
+	smallest_port = low; /* avoid compiler warning */
+
+other_parity_scan:
+	port = low + offset;
+	for (i = 0; i < remaining; i += 2, port += 2) {
+		if (unlikely(port >= high))
+			port -= remaining;
+		if (inet_is_local_reserved_port(net, port))
+			continue;
+		head = &hinfo->bhash[inet_bhashfn(net, port,
+						  hinfo->bhash_size)];
+		spin_lock_bh(&head->lock);
+		inet_bind_bucket_for_each(tb, &head->chain)
+			if (net_eq(ib_net(tb), net) && tb->port == port) {
+				if (((tb->fastreuse > 0 && reuse) ||
+				     (tb->fastreuseport > 0 &&
+				      sk->sk_reuseport &&
+				      uid_eq(tb->fastuid, uid))) &&
+				    (tb->num_owners < smallest_size || smallest_size == -1)) {
+					smallest_size = tb->num_owners;
+					smallest_port = port;
 				}
-			break;
-		next:
-			spin_unlock(&head->lock);
-		next_nolock:
-			if (++rover > high)
-				rover = low;
-		} while (--remaining > 0);
-
-		/* Exhausted local port range during search?  It is not
-		 * possible for us to be holding one of the bind hash
-		 * locks if this test triggers, because if 'remaining'
-		 * drops to zero, we broke out of the do/while loop at
-		 * the top level, not from the 'break;' statement.
-		 */
-		ret = 1;
-		if (remaining <= 0) {
-			if (smallest_size != -1) {
-				snum = smallest_rover;
-				goto have_snum;
-			}
-			if (attempt_half == 1) {
-				/* OK we now try the upper half of the range */
-				attempt_half = 2;
-				goto again;
+				if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false))
+					goto tb_found;
+				goto next_port;
 			}
-			goto fail;
-		}
-		/* OK, here is the one we will use.  HEAD is
-		 * non-NULL and we hold it's mutex.
-		 */
-		snum = rover;
-	} else {
-have_snum:
-		head = &hashinfo->bhash[inet_bhashfn(net, snum,
-				hashinfo->bhash_size)];
-		spin_lock(&head->lock);
-		inet_bind_bucket_for_each(tb, &head->chain)
-			if (net_eq(ib_net(tb), net) && tb->port == snum)
-				goto tb_found;
+		goto tb_not_found;
+next_port:
+		spin_unlock_bh(&head->lock);
+		cond_resched();
 	}
-	tb = NULL;
-	goto tb_not_found;
+
+	if (smallest_size != -1) {
+		port = smallest_port;
+		goto have_port;
+	}
+	offset--;
+	if (!(offset & 1))
+		goto other_parity_scan;
+
+	if (attempt_half == 1) {
+		/* OK we now try the upper half of the range */
+		attempt_half = 2;
+		goto other_half_scan;
+	}
+	return ret;
+
+tb_not_found:
+	tb = inet_bind_bucket_create(hinfo->bind_bucket_cachep,
+				     net, head, port);
+	if (!tb)
+		goto fail_unlock;
 tb_found:
 	if (!hlist_empty(&tb->owners)) {
 		if (sk->sk_reuse == SK_FORCE_REUSE)
 			goto success;
 
-		if (((tb->fastreuse > 0 &&
-		      sk->sk_reuse && sk->sk_state != TCP_LISTEN) ||
+		if (((tb->fastreuse > 0 && reuse) ||
 		     (tb->fastreuseport > 0 &&
 		      sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
-		    smallest_size == -1) {
+		    smallest_size == -1)
 			goto success;
-		} else {
-			ret = 1;
-			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true)) {
-				if (((sk->sk_reuse && sk->sk_state != TCP_LISTEN) ||
-				     (tb->fastreuseport > 0 &&
-				      sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
-				    smallest_size != -1 && --attempts >= 0) {
-					spin_unlock(&head->lock);
-					goto again;
-				}
-
-				goto fail_unlock;
+		if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true)) {
+			if ((reuse ||
+			     (tb->fastreuseport > 0 &&
+			      sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
+			    smallest_size != -1 && --attempts >= 0) {
+				spin_unlock_bh(&head->lock);
+				goto again;
 			}
+			goto fail_unlock;
 		}
-	}
-tb_not_found:
-	ret = 1;
-	if (!tb && (tb = inet_bind_bucket_create(hashinfo->bind_bucket_cachep,
-					net, head, snum)) == NULL)
-		goto fail_unlock;
-	if (hlist_empty(&tb->owners)) {
-		if (sk->sk_reuse && sk->sk_state != TCP_LISTEN)
-			tb->fastreuse = 1;
-		else
+		if (!reuse)
 			tb->fastreuse = 0;
+		if (!sk->sk_reuseport || !uid_eq(tb->fastuid, uid))
+			tb->fastreuseport = 0;
+	} else {
+		tb->fastreuse = reuse;
 		if (sk->sk_reuseport) {
 			tb->fastreuseport = 1;
 			tb->fastuid = uid;
-		} else
-			tb->fastreuseport = 0;
-	} else {
-		if (tb->fastreuse &&
-		    (!sk->sk_reuse || sk->sk_state == TCP_LISTEN))
-			tb->fastreuse = 0;
-		if (tb->fastreuseport &&
-		    (!sk->sk_reuseport || !uid_eq(tb->fastuid, uid)))
+		} else {
 			tb->fastreuseport = 0;
+		}
 	}
 success:
 	if (!inet_csk(sk)->icsk_bind_hash)
-		inet_bind_hash(sk, tb, snum);
+		inet_bind_hash(sk, tb, port);
 	WARN_ON(inet_csk(sk)->icsk_bind_hash != tb);
 	ret = 0;
 
 fail_unlock:
-	spin_unlock(&head->lock);
-fail:
-	local_bh_enable();
+	spin_unlock_bh(&head->lock);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(inet_csk_get_port);
-- 
2.7.0.rc3.207.g0ac5344
