From: Rao Shoaib <rao.shoaib@oracle.com>
Subject: [PATCH] TCP_USER_TIMEOUT and tcp_keepalive should conform to RFC5482
Date: Mon, 7 Aug 2017 10:51:25 -0700
Message-ID: <20170807175125.GA16602@caduceus5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45479 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751453AbdHGRwA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 13:52:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rao Shoaib <rao.shoaib@oracle.com>
---
 net/ipv4/tcp.c       | 10 ++++++++--
 net/ipv4/tcp_timer.c |  9 +--------
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 71ce33d..f2af44d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2628,7 +2628,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		break;
 
 	case TCP_KEEPIDLE:
-		if (val < 1 || val > MAX_TCP_KEEPIDLE)
+		/* Per RFC5482 keepalive_time must be > user_timeout */
+		if (val < 1 || val > MAX_TCP_KEEPIDLE ||
+		    ((val * HZ) <= icsk->icsk_user_timeout))
 			err = -EINVAL;
 		else {
 			tp->keepalive_time = val * HZ;
@@ -2724,8 +2726,12 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_USER_TIMEOUT:
 		/* Cap the max time in ms TCP will retry or probe the window
 		 * before giving up and aborting (ETIMEDOUT) a connection.
+		 * Per RFC5482 TCP user timeout must be < keepalive_time.
+		 * If the default value changes later -- all bets are off.
 		 */
-		if (val < 0)
+		if (val < 0 || (tp->keepalive_time &&
+				tp->keepalive_time <= msecs_to_jiffies(val)) ||
+		   net->ipv4.sysctl_tcp_keepalive_time <= msecs_to_jiffies(val))
 			err = -EINVAL;
 		else
 			icsk->icsk_user_timeout = msecs_to_jiffies(val);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index c0feeee..d39fe60 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -664,14 +664,7 @@ static void tcp_keepalive_timer (unsigned long data)
 	elapsed = keepalive_time_elapsed(tp);
 
 	if (elapsed >= keepalive_time_when(tp)) {
-		/* If the TCP_USER_TIMEOUT option is enabled, use that
-		 * to determine when to timeout instead.
-		 */
-		if ((icsk->icsk_user_timeout != 0 &&
-		    elapsed >= icsk->icsk_user_timeout &&
-		    icsk->icsk_probes_out > 0) ||
-		    (icsk->icsk_user_timeout == 0 &&
-		    icsk->icsk_probes_out >= keepalive_probes(tp))) {
+		if (icsk->icsk_probes_out >= keepalive_probes(tp)) {
 			tcp_send_active_reset(sk, GFP_ATOMIC);
 			tcp_write_err(sk);
 			goto out;
-- 
2.7.4
