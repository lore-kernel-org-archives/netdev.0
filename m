From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 1/4] tcp: fix too short FIN_WAIT2 time out
Date: Mon, 18 Mar 2013 21:39:04 +0900
Message-ID: <1363610344.7121.5.camel@ubuntu-vm-makita>
References: <1363610163.7121.2.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:41593 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab3CRMjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 08:39:10 -0400
In-Reply-To: <1363610163.7121.2.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tcp_fin_timeout is between 60 and 120, a FIN_WAIT2 socket
disappears in (tcp_fin_timeout - 60) * 2 sec, which is shorter
than expected.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/ipv4/tcp_timer.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index b78aac3..c20e474 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -576,12 +576,8 @@ static void tcp_keepalive_timer (unsigned long data)
 
 	if (sk->sk_state == TCP_FIN_WAIT2 && sock_flag(sk, SOCK_DEAD)) {
 		if (tp->linger2 >= 0) {
-			const int tmo = tcp_fin_time(sk) - TCP_TIMEWAIT_LEN;
-
-			if (tmo > 0) {
-				tcp_time_wait(sk, TCP_FIN_WAIT2, tmo);
-				goto out;
-			}
+			tcp_time_wait(sk, TCP_FIN_WAIT2, TCP_TIMEWAIT_LEN);
+			goto out;
 		}
 		tcp_send_active_reset(sk, GFP_ATOMIC);
 		goto death;
-- 
1.7.10.4
