From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 5/5 net-next] inet: reset tb->fastreuseport when adding a reuseport sk
Date: Tue, 20 Dec 2016 15:07:04 -0500
Message-ID: <1482264424-15439-6-git-send-email-jbacik@fb.com>
References: <1482264424-15439-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <hannes@stressinduktion.org>,
        <kraigatgoog@gmail.com>, <eric.dumazet@gmail.com>,
        <tom@herbertland.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37249 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933152AbcLTUHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 15:07:51 -0500
In-Reply-To: <1482264424-15439-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we have non reuseport sockets on a tb we will set tb->fastreuseport to 0 and
never set it again.  Which means that in the future if we end up adding a bunch
of reuseport sk's to that tb we'll have to do the expensive scan every time.
Instead add a sock_common to the tb so we know what reuseport sk succeeded last.
Once one sk has made it onto the list we know that there are no potential bind
conflicts on the owners list that match that sk's rcv_addr.  So copy the sk's
common into our tb->fastsock and set tb->fastruseport to FASTREUSESOCK_STRICT so
we know we have to do an extra check for subsequent reuseport sockets and skip
the expensive bind conflict check.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 include/net/inet_hashtables.h   |  4 ++++
 net/ipv4/inet_connection_sock.c | 53 +++++++++++++++++++++++++++++++++++++----
 2 files changed, 53 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 50f635c..b776401 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -74,12 +74,16 @@ struct inet_ehash_bucket {
  * users logged onto your box, isn't it nice to know that new data
  * ports are created in O(1) time?  I thought so. ;-)	-DaveM
  */
+#define FASTREUSEPORT_ANY	1
+#define FASTREUSEPORT_STRICT	2
+
 struct inet_bind_bucket {
 	possible_net_t		ib_net;
 	unsigned short		port;
 	signed char		fastreuse;
 	signed char		fastreuseport;
 	kuid_t			fastuid;
+	struct sock_common	fastsock;
 	int			num_owners;
 	struct hlist_node	node;
 	struct hlist_head	owners;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index d3ccf62..9e29fad 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -164,6 +164,32 @@ success:
 	return head;
 }
 
+static inline int sk_reuseport_match(struct inet_bind_bucket *tb,
+				     struct sock *sk)
+{
+	struct sock *sk2 = (struct sock *)&tb->fastsock;
+	kuid_t uid = sock_i_uid(sk);
+
+	if (tb->fastreuseport <= 0)
+		return 0;
+	if (!sk->sk_reuseport)
+		return 0;
+	if (rcu_access_pointer(sk->sk_reuseport_cb))
+		return 0;
+	if (!uid_eq(tb->fastuid, uid))
+		return 0;
+	/* We only need to check the rcv_saddr if this tb was once marked
+	 * without fastreuseport and then was reset, as we can only know that
+	 * the fastsock has no potential bind conflicts with the rest of the
+	 * possible socks on the owners list.
+	 */
+	if (tb->fastreuseport == FASTREUSEPORT_ANY)
+		return 1;
+	if (!inet_csk(sk)->icsk_af_ops->rcv_saddr_equal(sk, sk2, true))
+		return 0;
+	return 1;
+}
+
 /* Obtain a reference to a local port for the given sock,
  * if snum is zero it means select any available local port.
  * We try to allocate an odd port (and leave even ports for connect())
@@ -206,9 +232,7 @@ tb_found:
 			goto success;
 
 		if ((tb->fastreuse > 0 && reuse) ||
-		     (tb->fastreuseport > 0 &&
-		      !rcu_access_pointer(sk->sk_reuseport_cb) &&
-		      sk->sk_reuseport && uid_eq(tb->fastuid, uid)))
+		    sk_reuseport_match(tb, sk))
 			goto success;
 		if (inet_csk_bind_conflict(sk, tb, true, true))
 			goto fail_unlock;
@@ -220,14 +244,35 @@ success:
 		if (sk->sk_reuseport) {
 			tb->fastreuseport = 1;
 			tb->fastuid = uid;
+			memcpy(&tb->fastsock, &sk->__sk_common,
+			       sizeof(struct sock_common));
 		} else {
 			tb->fastreuseport = 0;
 		}
 	} else {
 		if (!reuse)
 			tb->fastreuse = 0;
-		if (!sk->sk_reuseport || !uid_eq(tb->fastuid, uid))
+		if (sk->sk_reuseport) {
+			/* We didn't match or we don't have fastreuseport set on
+			 * the tb, but we have sk_reuseport set on this socket
+			 * and we know that there are no bind conflicts with
+			 * this socket in this tb, so reset our tb's reuseport
+			 * settings so that any subsequent sockets that match
+			 * our current socket will be put on the fast path.
+			 *
+			 * If we reset we need to set FASTREUSEPORT_STRICT so we
+			 * do extra checking for all subsequent sk_reuseport
+			 * socks.
+			 */
+			if (!sk_reuseport_match(tb, sk)) {
+				tb->fastreuseport = FASTREUSEPORT_STRICT;
+				tb->fastuid = uid;
+				memcpy(&tb->fastsock, &sk->__sk_common,
+				       sizeof(struct sock_common));
+			}
+		} else {
 			tb->fastreuseport = 0;
+		}
 	}
 	if (!inet_csk(sk)->icsk_bind_hash)
 		inet_bind_hash(sk, tb, port);
-- 
2.9.3
