From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: A possible bug in reqsk_queue_hash_req()
Date: Tue, 20 Apr 2010 23:29:13 +0200
Message-ID: <1271798953.7895.358.camel@edumazet-laptop>
References: <i2x9b948ee41004200335vc229a59cvc0a08c35c949d7dd@mail.gmail.com>
	 <1271761611.3845.223.camel@edumazet-laptop>
	 <20100420.142405.228805796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: raise.sail@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:47675 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755360Ab0DTV3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 17:29:25 -0400
In-Reply-To: <20100420.142405.228805796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 14:24 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 20 Apr 2010 13:06:51 +0200
>=20
> > I believe its not really necessary, because we are the only possibl=
e
> > writer at this stage.
> >=20
> > The write_lock() ... write_unlock() is there only to enforce a
> > synchronisation with readers.
> >=20
> > All callers of this reqsk_queue_hash_req() must have the socket loc=
ked
>=20
> Right.
>=20
> In fact there are quite a few snippets around the networking
> where we use this trick of only locking around the single
> pointer assignment that puts the object into the list.
>=20
> And they were all written by Alexey Kuznetsov, so they must
> be correct :-)

We could convert to RCU, but given this read_lock is only taken by
inet_diag, its not really necessary.

Something like the following, but I have no plan to complete this work.


diff --git a/include/net/inet_connection_sock.h b/include/net/inet_conn=
ection_sock.h
index b6d3b55..5f3373a 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -278,7 +278,9 @@ static inline void inet_csk_reqsk_queue_added(struc=
t sock *sk,
=20
 static inline int inet_csk_reqsk_queue_len(const struct sock *sk)
 {
-	return reqsk_queue_len(&inet_csk(sk)->icsk_accept_queue);
+	struct listen_sock * lopt =3D reqsk_lopt_get(&inet_csk(sk)->icsk_acce=
pt_queue);
+
+	return reqsk_queue_len(lopt);
 }
=20
 static inline int inet_csk_reqsk_queue_young(const struct sock *sk)
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 99e6e19..b665103 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -65,6 +65,7 @@ struct request_sock {
 	struct sock			*sk;
 	u32				secid;
 	u32				peer_secid;
+	struct rcu_head			rcu;
 };
=20
 static inline struct request_sock *reqsk_alloc(const struct request_so=
ck_ops *ops)
@@ -77,10 +78,7 @@ static inline struct request_sock *reqsk_alloc(const=
 struct request_sock_ops *op
 	return req;
 }
=20
-static inline void __reqsk_free(struct request_sock *req)
-{
-	kmem_cache_free(req->rsk_ops->slab, req);
-}
+extern void __reqsk_free(struct request_sock *req);
=20
 static inline void reqsk_free(struct request_sock *req)
 {
@@ -110,23 +108,13 @@ struct listen_sock {
  * @rskq_accept_head - FIFO head of established children
  * @rskq_accept_tail - FIFO tail of established children
  * @rskq_defer_accept - User waits for some data after accept()
- * @syn_wait_lock - serializer
- *
- * %syn_wait_lock is necessary only to avoid proc interface having to =
grab the main
- * lock sock while browsing the listening hash (otherwise it's deadloc=
k prone).
  *
- * This lock is acquired in read mode only from listening_get_next() s=
eq_file
- * op and it's acquired in write mode _only_ from code that is activel=
y
- * changing rskq_accept_head. All readers that are holding the master =
sock lock
- * don't need to grab this lock in read mode too as rskq_accept_head. =
writes
- * are always protected from the main sock lock.
  */
 struct request_sock_queue {
 	struct request_sock	*rskq_accept_head;
 	struct request_sock	*rskq_accept_tail;
-	rwlock_t		syn_wait_lock;
 	u8			rskq_defer_accept;
-	/* 3 bytes hole, try to pack */
+	/* 3-7 bytes hole, try to pack */
 	struct listen_sock	*listen_opt;
 };
=20
@@ -154,9 +142,7 @@ static inline void reqsk_queue_unlink(struct reques=
t_sock_queue *queue,
 				      struct request_sock *req,
 				      struct request_sock **prev_req)
 {
-	write_lock(&queue->syn_wait_lock);
-	*prev_req =3D req->dl_next;
-	write_unlock(&queue->syn_wait_lock);
+	rcu_assign_pointer(*prev_req, req->dl_next);
 }
=20
 static inline void reqsk_queue_add(struct request_sock_queue *queue,
@@ -167,13 +153,13 @@ static inline void reqsk_queue_add(struct request=
_sock_queue *queue,
 	req->sk =3D child;
 	sk_acceptq_added(parent);
=20
+	req->dl_next =3D NULL;
 	if (queue->rskq_accept_head =3D=3D NULL)
 		queue->rskq_accept_head =3D req;
 	else
 		queue->rskq_accept_tail->dl_next =3D req;
=20
 	queue->rskq_accept_tail =3D req;
-	req->dl_next =3D NULL;
 }
=20
 static inline struct request_sock *reqsk_queue_remove(struct request_s=
ock_queue *queue)
@@ -223,9 +209,16 @@ static inline int reqsk_queue_added(struct request=
_sock_queue *queue)
 	return prev_qlen;
 }
=20
-static inline int reqsk_queue_len(const struct request_sock_queue *que=
ue)
+static inline struct listen_sock *reqsk_lopt_get(const struct request_=
sock_queue *queue)
 {
-	return queue->listen_opt !=3D NULL ? queue->listen_opt->qlen : 0;
+	return rcu_dereference_check(queue->listen_opt,
+		rcu_read_lock_bh_held() ||
+		sock_owned_by_user(sk));
+}
+
+static inline int reqsk_queue_len(struct listen_sock *lopt)
+{
+	return lopt !=3D NULL ? lopt->qlen : 0;
 }
=20
 static inline int reqsk_queue_len_young(const struct request_sock_queu=
e *queue)
@@ -247,11 +240,9 @@ static inline void reqsk_queue_hash_req(struct req=
uest_sock_queue *queue,
 	req->expires =3D jiffies + timeout;
 	req->retrans =3D 0;
 	req->sk =3D NULL;
-	req->dl_next =3D lopt->syn_table[hash];
=20
-	write_lock(&queue->syn_wait_lock);
-	lopt->syn_table[hash] =3D req;
-	write_unlock(&queue->syn_wait_lock);
+	req->dl_next =3D lopt->syn_table[hash];
+	rcu_assign_pointer(lopt->syn_table[hash], req);
 }
=20
 #endif /* _REQUEST_SOCK_H */
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 7552495..e4c333e 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -58,13 +58,10 @@ int reqsk_queue_alloc(struct request_sock_queue *qu=
eue,
 	     lopt->max_qlen_log++);
=20
 	get_random_bytes(&lopt->hash_rnd, sizeof(lopt->hash_rnd));
-	rwlock_init(&queue->syn_wait_lock);
 	queue->rskq_accept_head =3D NULL;
 	lopt->nr_table_entries =3D nr_table_entries;
=20
-	write_lock_bh(&queue->syn_wait_lock);
-	queue->listen_opt =3D lopt;
-	write_unlock_bh(&queue->syn_wait_lock);
+	rcu_assign_pointer(queue->listen_opt, lopt);
=20
 	return 0;
 }
@@ -94,10 +91,8 @@ static inline struct listen_sock *reqsk_queue_yank_l=
isten_sk(
 {
 	struct listen_sock *lopt;
=20
-	write_lock_bh(&queue->syn_wait_lock);
 	lopt =3D queue->listen_opt;
 	queue->listen_opt =3D NULL;
-	write_unlock_bh(&queue->syn_wait_lock);
=20
 	return lopt;
 }
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index 8da6429..2b2cb80 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -49,6 +49,19 @@ void inet_get_local_port_range(int *low, int *high)
 }
 EXPORT_SYMBOL(inet_get_local_port_range);
=20
+static void reqsk_rcu_free(struct rcu_head *head)
+{
+	struct request_sock *req =3D container_of(head, struct request_sock, =
rcu);
+
+	kmem_cache_free(req->rsk_ops->slab, req);
+}
+
+void __reqsk_free(struct request_sock *req)
+{
+	call_rcu_bh(&req->rcu, reqsk_rcu_free);
+}
+EXPORT_SYMBOL(__reqsk_free);
+
 int inet_csk_bind_conflict(const struct sock *sk,
 			   const struct inet_bind_bucket *tb)
 {
@@ -420,7 +433,7 @@ struct request_sock *inet_csk_search_req(const stru=
ct sock *sk,
 		    ireq->loc_addr =3D=3D laddr &&
 		    AF_INET_FAMILY(req->rsk_ops->family)) {
 			WARN_ON(req->sk);
-			*prevp =3D prev;
+			rcu_assign_pointer(*prevp, prev);
 			break;
 		}
 	}
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index e5fa2dd..4da8365 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -632,9 +632,9 @@ static int inet_diag_dump_reqs(struct sk_buff *skb,=
 struct sock *sk,
=20
 	entry.family =3D sk->sk_family;
=20
-	read_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+	rcu_read_lock_bh();
=20
-	lopt =3D icsk->icsk_accept_queue.listen_opt;
+	lopt =3D rcu_dereference_bh(icsk->icsk_accept_queue.listen_opt);
 	if (!lopt || !lopt->qlen)
 		goto out;
=20
@@ -648,7 +648,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb,=
 struct sock *sk,
 		struct request_sock *req, *head =3D lopt->syn_table[j];
=20
 		reqnum =3D 0;
-		for (req =3D head; req; reqnum++, req =3D req->dl_next) {
+		for (req =3D head; req; reqnum++, req =3D rcu_dereference_bh(req->dl=
_next)) {
 			struct inet_request_sock *ireq =3D inet_rsk(req);
=20
 			if (reqnum < s_reqnum)
@@ -691,7 +691,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb,=
 struct sock *sk,
 	}
=20
 out:
-	read_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+	rcu_read_unlock_bh();
=20
 	return err;
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ad08392..cd6a042 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1985,6 +1985,7 @@ static void *listening_get_next(struct seq_file *=
seq, void *cur)
 	struct inet_listen_hashbucket *ilb;
 	struct tcp_iter_state *st =3D seq->private;
 	struct net *net =3D seq_file_net(seq);
+	struct listen_sock *lopt;
=20
 	if (!sk) {
 		st->bucket =3D 0;
@@ -2009,20 +2010,21 @@ static void *listening_get_next(struct seq_file=
 *seq, void *cur)
 				}
 				req =3D req->dl_next;
 			}
-			if (++st->sbucket >=3D icsk->icsk_accept_queue.listen_opt->nr_table=
_entries)
+			if (++st->sbucket >=3D lopt->nr_table_entries)
 				break;
 get_req:
-			req =3D icsk->icsk_accept_queue.listen_opt->syn_table[st->sbucket];
+			req =3D lopt->syn_table[st->sbucket];
 		}
 		sk	  =3D sk_next(st->syn_wait_sk);
 		st->state =3D TCP_SEQ_STATE_LISTENING;
-		read_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+		rcu_read_unlock_bh();
 	} else {
 		icsk =3D inet_csk(sk);
-		read_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
-		if (reqsk_queue_len(&icsk->icsk_accept_queue))
+		rcu_read_lock_bh();
+		lopt =3D rcu_dereference_bh(icsk->icsk_accept_queue.listen_opt);
+		if (reqsk_queue_len(lopt))
 			goto start_req;
-		read_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+		rcu_read_unlock_bh();
 		sk =3D sk_next(sk);
 	}
 get_sk:
@@ -2032,8 +2034,9 @@ get_sk:
 			goto out;
 		}
 		icsk =3D inet_csk(sk);
-		read_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
-		if (reqsk_queue_len(&icsk->icsk_accept_queue)) {
+		rcu_read_lock_bh();
+		lopt =3D rcu_dereference_bh(icsk->icsk_accept_queue.listen_opt);
+		if (reqsk_queue_len(lopt)) {
 start_req:
 			st->uid		=3D sock_i_uid(sk);
 			st->syn_wait_sk =3D sk;
@@ -2041,7 +2044,7 @@ start_req:
 			st->sbucket	=3D 0;
 			goto get_req;
 		}
-		read_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+		rcu_read_unlock_bh();
 	}
 	spin_unlock_bh(&ilb->lock);
 	if (++st->bucket < INET_LHTABLE_SIZE) {
@@ -2235,10 +2238,8 @@ static void tcp_seq_stop(struct seq_file *seq, v=
oid *v)
=20
 	switch (st->state) {
 	case TCP_SEQ_STATE_OPENREQ:
-		if (v) {
-			struct inet_connection_sock *icsk =3D inet_csk(st->syn_wait_sk);
-			read_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
-		}
+		if (v)
+			rcu_read_unlock_bh();
 	case TCP_SEQ_STATE_LISTENING:
 		if (v !=3D SEQ_START_TOKEN)
 			spin_unlock_bh(&tcp_hashinfo.listening_hash[st->bucket].lock);


