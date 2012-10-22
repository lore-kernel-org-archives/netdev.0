From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: speedup SIOCINQ ioctl
Date: Mon, 22 Oct 2012 08:06:56 +0200
Message-ID: <1350886016.8609.266.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:58719 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146Ab2JVGHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 02:07:00 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so804744eek.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 23:06:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

SIOCINQ can use the lock_sock_fast() version to avoid double acquisition
of socket lock.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b7c2f43..eace049 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -536,13 +536,14 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int answ;
+	bool slow;
 
 	switch (cmd) {
 	case SIOCINQ:
 		if (sk->sk_state == TCP_LISTEN)
 			return -EINVAL;
 
-		lock_sock(sk);
+		slow = lock_sock_fast(sk);
 		if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV))
 			answ = 0;
 		else if (sock_flag(sk, SOCK_URGINLINE) ||
@@ -557,7 +558,7 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 				answ--;
 		} else
 			answ = tp->urg_seq - tp->copied_seq;
-		release_sock(sk);
+		unlock_sock_fast(sk, slow);
 		break;
 	case SIOCATMARK:
 		answ = tp->urg_data && tp->urg_seq == tp->copied_seq;
