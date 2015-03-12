From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 7/8] inet: get_openreq4() & get_openreq6() do not need listener
Date: Thu, 12 Mar 2015 16:44:09 -0700
Message-ID: <1426203850-11034-8-git-send-email-edumazet@google.com>
References: <1426203850-11034-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:34151 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755478AbbCLXpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 19:45:16 -0400
Received: by obcwp18 with SMTP id wp18so5094860obc.1
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 16:45:15 -0700 (PDT)
In-Reply-To: <1426203850-11034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ireq->ir_num contains local port, use it.

Also, get_openreq4() dumping listen_sk->refcnt makes litle sense.

inet_diag_fill_req() can also use ireq->ir_num

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c | 3 +--
 net/ipv4/tcp_ipv4.c  | 8 ++++----
 net/ipv6/tcp_ipv6.c  | 4 ++--
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 29317ff4a007..c55a6fa3162d 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -718,7 +718,6 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 			      const struct nlmsghdr *unlh)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
-	struct inet_sock *inet = inet_sk(sk);
 	struct inet_diag_msg *r;
 	struct nlmsghdr *nlh;
 	long tmo;
@@ -744,7 +743,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	if (tmo < 0)
 		tmo = 0;
 
-	r->id.idiag_sport = inet->inet_sport;
+	r->id.idiag_sport = htons(ireq->ir_num);
 	r->id.idiag_dport = ireq->ir_rmt_port;
 
 	memset(&r->id.idiag_src, 0, sizeof(r->id.idiag_src));
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f0c6fc32bfa8..70b0f701bbdb 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2204,7 +2204,7 @@ void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo)
 }
 EXPORT_SYMBOL(tcp_proc_unregister);
 
-static void get_openreq4(const struct sock *sk, const struct request_sock *req,
+static void get_openreq4(const struct request_sock *req,
 			 struct seq_file *f, int i, kuid_t uid)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
@@ -2214,7 +2214,7 @@ static void get_openreq4(const struct sock *sk, const struct request_sock *req,
 		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %u %d %pK",
 		i,
 		ireq->ir_loc_addr,
-		ntohs(inet_sk(sk)->inet_sport),
+		ireq->ir_num,
 		ireq->ir_rmt_addr,
 		ntohs(ireq->ir_rmt_port),
 		TCP_SYN_RECV,
@@ -2225,7 +2225,7 @@ static void get_openreq4(const struct sock *sk, const struct request_sock *req,
 		from_kuid_munged(seq_user_ns(f), uid),
 		0,  /* non standard timer */
 		0, /* open_requests have no inode */
-		atomic_read(&sk->sk_refcnt),
+		0,
 		req);
 }
 
@@ -2332,7 +2332,7 @@ static int tcp4_seq_show(struct seq_file *seq, void *v)
 			get_tcp4_sock(v, seq, st->num);
 		break;
 	case TCP_SEQ_STATE_OPENREQ:
-		get_openreq4(st->syn_wait_sk, v, seq, st->num, st->uid);
+		get_openreq4(v, seq, st->num, st->uid);
 		break;
 	}
 out:
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5d46832c6f72..1ccfede7d55f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1689,7 +1689,7 @@ static void tcp_v6_destroy_sock(struct sock *sk)
 #ifdef CONFIG_PROC_FS
 /* Proc filesystem TCPv6 sock list dumping. */
 static void get_openreq6(struct seq_file *seq,
-			 const struct sock *sk, struct request_sock *req, int i, kuid_t uid)
+			 struct request_sock *req, int i, kuid_t uid)
 {
 	int ttd = req->expires - jiffies;
 	const struct in6_addr *src = &inet_rsk(req)->ir_v6_loc_addr;
@@ -1827,7 +1827,7 @@ static int tcp6_seq_show(struct seq_file *seq, void *v)
 			get_tcp6_sock(seq, v, st->num);
 		break;
 	case TCP_SEQ_STATE_OPENREQ:
-		get_openreq6(seq, st->syn_wait_sk, v, st->num, st->uid);
+		get_openreq6(seq, v, st->num, st->uid);
 		break;
 	}
 out:
-- 
2.2.0.rc0.207.ga3a616c
