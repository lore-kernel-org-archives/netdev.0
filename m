From: John Heffner <johnwheffner@gmail.com>
Subject: [PATCH 1/2] [NET]: Allow send-limited cwnd to grow up to max_burst when gso disabled
Date: Mon, 28 Apr 2008 16:22:30 -0700
Message-ID: <1209424951-13450-1-git-send-email-johnwheffner@gmail.com>
References: <d1c2719f0804281344h4b8c98b9w6d7d4d2cbcdee857@mail.gmail.com>
Cc: netdev@vger.kernel.org, John Heffner <johnwheffner@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail172.messagelabs.com ([216.82.254.3]:19245 "HELO
	mail172.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753328AbYD1XWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 19:22:38 -0400
In-Reply-To: <d1c2719f0804281344h4b8c98b9w6d7d4d2cbcdee857@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes the logic in tcp_is_cwnd_limited() so that cwnd may grow
up to tcp_max_burst() even when sk_can_gso() is false, or when
sysctl_tcp_tso_win_divisor != 0.

Signed-off-by: John Heffner <johnwheffner@gmail.com>
---
 net/ipv4/tcp_cong.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 3a6be23..bfb1996 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -285,14 +285,11 @@ int tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
 	if (in_flight >= tp->snd_cwnd)
 		return 1;
 
-	if (!sk_can_gso(sk))
-		return 0;
-
 	left = tp->snd_cwnd - in_flight;
-	if (sysctl_tcp_tso_win_divisor)
-		return left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd;
-	else
-		return left <= tcp_max_burst(tp);
+	if (sk_can_gso(sk) &&
+	    left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd)
+		return 1;
+	return left <= tcp_max_burst(tp);
 }
 EXPORT_SYMBOL_GPL(tcp_is_cwnd_limited);
 
-- 
1.5.2.5


______________________________________________________________________
This email has been scanned by the MessageLabs Email Security System.
For more information please visit http://www.messagelabs.com/email 
______________________________________________________________________
