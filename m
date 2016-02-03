From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: do not drop syn_recv on all icmp reports
Date: Tue, 02 Feb 2016 19:31:12 -0800
Message-ID: <1454470272.7627.223.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160203115616.5549851a@samsung9>
	 <1454466952.7627.211.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Petr Novopashenniy <pety@rusnet.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35003 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932929AbcBCDbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 22:31:15 -0500
Received: by mail-pf0-f180.google.com with SMTP id 65so5690156pfd.2
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 19:31:15 -0800 (PST)
In-Reply-To: <1454466952.7627.211.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Petr Novopashenniy reported that ICMP redirects on SYN_RECV sockets
were leading to RST.

This is of course incorrect.

A specific list of ICMP messages should be able to drop a SYN_RECV.

For instance, a REDIRECT on SYN_RECV shall be ignored, as we do
not hold a dst per SYN_RECV pseudo request.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=111751
Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
Reported-by: Petr Novopashenniy <pety@rusnet.ru>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
A similar patch will be needed for DCCP.
Petr, please test if this patch solves your issue ? Thanks !

 include/net/tcp.h   |    2 +-
 net/ipv4/tcp_ipv4.c |   11 ++++++++---
 net/ipv6/tcp_ipv6.c |    5 +++--
 3 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f6f8f032c73e..ae6468f5c9f3 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -447,7 +447,7 @@ const u8 *tcp_parse_md5sig_option(const struct tcphdr *th);
 
 void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb);
 void tcp_v4_mtu_reduced(struct sock *sk);
-void tcp_req_err(struct sock *sk, u32 seq);
+void tcp_req_err(struct sock *sk, u32 seq, bool abort);
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
 struct sock *tcp_create_openreq_child(const struct sock *sk,
 				      struct request_sock *req,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a4d523709ab3..7f6ff037adaf 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -311,7 +311,7 @@ static void do_redirect(struct sk_buff *skb, struct sock *sk)
 
 
 /* handle ICMP messages on TCP_NEW_SYN_RECV request sockets */
-void tcp_req_err(struct sock *sk, u32 seq)
+void tcp_req_err(struct sock *sk, u32 seq, bool abort)
 {
 	struct request_sock *req = inet_reqsk(sk);
 	struct net *net = sock_net(sk);
@@ -323,7 +323,7 @@ void tcp_req_err(struct sock *sk, u32 seq)
 
 	if (seq != tcp_rsk(req)->snt_isn) {
 		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
-	} else {
+	} else if (abort) {
 		/*
 		 * Still in SYN_RECV, just remove it silently.
 		 * There is no good way to pass the error to the newly
@@ -383,7 +383,12 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	}
 	seq = ntohl(th->seq);
 	if (sk->sk_state == TCP_NEW_SYN_RECV)
-		return tcp_req_err(sk, seq);
+		return tcp_req_err(sk, seq,
+				  type == ICMP_PARAMETERPROB ||
+				  type == ICMP_TIME_EXCEEDED ||
+				  (type == ICMP_DEST_UNREACH &&
+				   (code == ICMP_NET_UNREACH ||
+				    code == ICMP_HOST_UNREACH)));
 
 	bh_lock_sock(sk);
 	/* If too many ICMPs get dropped on busy
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 006396e31cb0..01caceccb528 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -327,6 +327,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct tcp_sock *tp;
 	__u32 seq, snd_una;
 	struct sock *sk;
+	bool fatal;
 	int err;
 
 	sk = __inet6_lookup_established(net, &tcp_hashinfo,
@@ -345,8 +346,9 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 	}
 	seq = ntohl(th->seq);
+	fatal = icmpv6_err_convert(type, code, &err);
 	if (sk->sk_state == TCP_NEW_SYN_RECV)
-		return tcp_req_err(sk, seq);
+		return tcp_req_err(sk, seq, fatal);
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk) && type != ICMPV6_PKT_TOOBIG)
@@ -400,7 +402,6 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		goto out;
 	}
 
-	icmpv6_err_convert(type, code, &err);
 
 	/* Might be for an request_sock */
 	switch (sk->sk_state) {
