From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 08/17] tcp: get_openreq[46]() changes
Date: Fri,  2 Oct 2015 11:43:30 -0700
Message-ID: <1443811419-4798-9-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36674 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221AbbJBSoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:44:08 -0400
Received: by pablk4 with SMTP id lk4so112689912pab.3
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:44:07 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When request sockets are no longer in a per listener hash table
but on regular TCP ehash, we need to access listener uid
through req->rsk_listener

get_openreq6() also gets a const for its request socket argument.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h   | 1 -
 net/ipv4/tcp_ipv4.c | 8 ++++----
 net/ipv6/tcp_ipv6.c | 7 ++++---
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2c7dfe52f473..a26341d2ad67 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1637,7 +1637,6 @@ struct tcp_iter_state {
 	enum tcp_seq_states	state;
 	struct sock		*syn_wait_sk;
 	int			bucket, offset, sbucket, num;
-	kuid_t			uid;
 	loff_t			last_pos;
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 56f8c6395966..a33101616215 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1871,7 +1871,6 @@ get_sk:
 		spin_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 		if (reqsk_queue_len(&icsk->icsk_accept_queue)) {
 start_req:
-			st->uid		= sock_i_uid(sk);
 			st->syn_wait_sk = sk;
 			st->state	= TCP_SEQ_STATE_OPENREQ;
 			st->sbucket	= 0;
@@ -2151,7 +2150,7 @@ void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo)
 EXPORT_SYMBOL(tcp_proc_unregister);
 
 static void get_openreq4(const struct request_sock *req,
-			 struct seq_file *f, int i, kuid_t uid)
+			 struct seq_file *f, int i)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	long delta = req->rsk_timer.expires - jiffies;
@@ -2168,7 +2167,8 @@ static void get_openreq4(const struct request_sock *req,
 		1,    /* timers active (only the expire timer) */
 		jiffies_delta_to_clock_t(delta),
 		req->num_timeout,
-		from_kuid_munged(seq_user_ns(f), uid),
+		from_kuid_munged(seq_user_ns(f),
+				 sock_i_uid(req->rsk_listener)),
 		0,  /* non standard timer */
 		0, /* open_requests have no inode */
 		0,
@@ -2278,7 +2278,7 @@ static int tcp4_seq_show(struct seq_file *seq, void *v)
 			get_tcp4_sock(v, seq, st->num);
 		break;
 	case TCP_SEQ_STATE_OPENREQ:
-		get_openreq4(v, seq, st->num, st->uid);
+		get_openreq4(v, seq, st->num);
 		break;
 	}
 out:
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 65e797dba504..cadb44a2d34e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1635,7 +1635,7 @@ static void tcp_v6_destroy_sock(struct sock *sk)
 #ifdef CONFIG_PROC_FS
 /* Proc filesystem TCPv6 sock list dumping. */
 static void get_openreq6(struct seq_file *seq,
-			 struct request_sock *req, int i, kuid_t uid)
+			 const struct request_sock *req, int i)
 {
 	long ttd = req->rsk_timer.expires - jiffies;
 	const struct in6_addr *src = &inet_rsk(req)->ir_v6_loc_addr;
@@ -1659,7 +1659,8 @@ static void get_openreq6(struct seq_file *seq,
 		   1,   /* timers active (only the expire timer) */
 		   jiffies_to_clock_t(ttd),
 		   req->num_timeout,
-		   from_kuid_munged(seq_user_ns(seq), uid),
+		   from_kuid_munged(seq_user_ns(seq),
+				    sock_i_uid(req->rsk_listener)),
 		   0,  /* non standard timer */
 		   0, /* open_requests have no inode */
 		   0, req);
@@ -1773,7 +1774,7 @@ static int tcp6_seq_show(struct seq_file *seq, void *v)
 			get_tcp6_sock(seq, v, st->num);
 		break;
 	case TCP_SEQ_STATE_OPENREQ:
-		get_openreq6(seq, v, st->num, st->uid);
+		get_openreq6(seq, v, st->num);
 		break;
 	}
 out:
-- 
2.6.0.rc2.230.g3dd15c0
