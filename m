From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix various issues for sockets morphing to listen
 state
Date: Fri, 03 Mar 2017 14:08:21 -0800
Message-ID: <1488578901.9415.353.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+Y+dL6EzkfDahjQUyyT4YMhDin7UPY5RQYbNH0n0DJ5xA@mail.gmail.com>
         <CANn89iLNQKyywwLAdJsQDOpGDtEs6S-4BZkZYmwT39ENZyqLTg@mail.gmail.com>
         <1488574561.9415.336.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35540 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751869AbdCCWIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 17:08:24 -0500
Received: by mail-pg0-f67.google.com with SMTP id 187so134085pgb.2
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 14:08:23 -0800 (PST)
In-Reply-To: <1488574561.9415.336.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Dmitry Vyukov reported a divide by 0 triggered by syzkaller, exploiting
tcp_disconnect() path that was never really considered and/or used
before syzkaller ;)

I was not able to reproduce the bug, but it seems issues here are the
three possible actions that assumed they would never trigger on a
listener.

1) tcp_write_timer_handler
2) tcp_delack_timer_handler
3) MTU reduction

Only IPv6 MTU reduction was properly testing TCP_CLOSE and TCP_LISTEN
 states from tcp_v6_mtu_reduced()


Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
---
 net/ipv4/tcp_ipv4.c  |    7 +++++--
 net/ipv4/tcp_timer.c |    6 ++++--
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9a89b8deafae1e9b2e8d1d9bc211c9c30b8dd8ec..8f3ec1365497a58972d31d419f88b34457b5ae39 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -279,10 +279,13 @@ EXPORT_SYMBOL(tcp_v4_connect);
  */
 void tcp_v4_mtu_reduced(struct sock *sk)
 {
-	struct dst_entry *dst;
 	struct inet_sock *inet = inet_sk(sk);
-	u32 mtu = tcp_sk(sk)->mtu_info;
+	struct dst_entry *dst;
+	u32 mtu;
 
+	if ((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE))
+		return;
+	mtu = tcp_sk(sk)->mtu_info;
 	dst = inet_csk_update_pmtu(sk, mtu);
 	if (!dst)
 		return;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 40d893556e6701ace6a02903e53c45822d6fa56d..b2ab411c6d3728fa7dbdebde045532a7317f5166 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -249,7 +249,8 @@ void tcp_delack_timer_handler(struct sock *sk)
 
 	sk_mem_reclaim_partial(sk);
 
-	if (sk->sk_state == TCP_CLOSE || !(icsk->icsk_ack.pending & ICSK_ACK_TIMER))
+	if (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_LISTEN)) ||
+	    !(icsk->icsk_ack.pending & ICSK_ACK_TIMER))
 		goto out;
 
 	if (time_after(icsk->icsk_ack.timeout, jiffies)) {
@@ -552,7 +553,8 @@ void tcp_write_timer_handler(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int event;
 
-	if (sk->sk_state == TCP_CLOSE || !icsk->icsk_pending)
+	if (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_LISTEN)) ||
+	    !icsk->icsk_pending)
 		goto out;
 
 	if (time_after(icsk->icsk_timeout, jiffies)) {
