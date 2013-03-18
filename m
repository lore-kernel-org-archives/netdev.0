From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 2/4] tcp: fix FIN_WAIT2 timer expression in /proc/net/tcp
Date: Mon, 18 Mar 2013 21:43:35 +0900
Message-ID: <1363610615.7791.2.camel@ubuntu-vm-makita>
References: <1363610163.7121.2.camel@ubuntu-vm-makita>
	 <1363610344.7121.5.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:41627 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab3CRMnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 08:43:40 -0400
In-Reply-To: <1363610344.7121.5.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tcp_fin_timeout is greater than 60 and a socket is half-closed,
/proc/net/tcp shows a FIN_WAIT2 keepalive timer. This is confusing
because keepalive probes will never be sent in this case.
Keepalive probes will really be sent with a FIN_WAIT2 keepalive timer
shown when a socket is not closed but shutdown and SO_KEEPALIVE is set.

Even without this change, a keepalive timer for an orphaned FIN_WAIT2
socket will eventually turn to a timewait timer, and by default,
or when tcp_fin_timeout is 60, there will be no keepalive timer for
orphaned FIN_WAIT2 sockets. Therefore, this change will hardly affect
a bad influence to userspace.

This patch changes the expression to show only timewait timer for
orphaned FIN_WAIT2 sockets.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/ipv4/tcp_ipv4.c |   11 +++++++++--
 net/ipv6/tcp_ipv6.c |   11 +++++++++--
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4a8ec45..86a0685 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2666,8 +2666,15 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		timer_active	= 4;
 		timer_expires	= icsk->icsk_timeout;
 	} else if (timer_pending(&sk->sk_timer)) {
-		timer_active	= 2;
-		timer_expires	= sk->sk_timer.expires;
+		if (sk->sk_state == TCP_FIN_WAIT2 && sock_flag(sk, SOCK_DEAD)) {
+			timer_active	= 3;
+			timer_expires	= sk->sk_timer.expires +
+					  (tp->linger2 >= 0 ?
+					   TCP_TIMEWAIT_LEN : 0);
+		} else {
+			timer_active	= 2;
+			timer_expires	= sk->sk_timer.expires;
+		}
 	} else {
 		timer_active	= 0;
 		timer_expires = jiffies;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9b64600..b74b133 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1811,8 +1811,15 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 		timer_active	= 4;
 		timer_expires	= icsk->icsk_timeout;
 	} else if (timer_pending(&sp->sk_timer)) {
-		timer_active	= 2;
-		timer_expires	= sp->sk_timer.expires;
+		if (sp->sk_state == TCP_FIN_WAIT2 && sock_flag(sp, SOCK_DEAD)) {
+			timer_active	= 3;
+			timer_expires	= sp->sk_timer.expires +
+					  (tp->linger2 >= 0 ?
+					   TCP_TIMEWAIT_LEN : 0);
+		} else {
+			timer_active	= 2;
+			timer_expires	= sp->sk_timer.expires;
+		}
 	} else {
 		timer_active	= 0;
 		timer_expires = jiffies;
-- 
1.7.10.4
