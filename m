From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH 1/2] tcp: fix too short FIN_WAIT2 time out
Date: Tue, 12 Feb 2013 21:52:01 +0900
Message-ID: <1360673521.10638.12.camel@ubuntu-vm-makita>
References: <1360673384.10638.10.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:54146 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933128Ab3BLMwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 07:52:06 -0500
In-Reply-To: <1360673384.10638.10.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tcp_fin_timeout is between 60 and 120, FIN_WAIT2 socket
disappears in (tcp_fin_timeout - 60) * 2 sec, which is shorter
than expected.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/ipv4/tcp_timer.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

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
1.7.1
