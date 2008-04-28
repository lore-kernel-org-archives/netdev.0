From: John Heffner <johnwheffner@gmail.com>
Subject: [PATCH 2/2] [NET]: Limit cwnd growth when deferring for GSO
Date: Mon, 28 Apr 2008 16:22:31 -0700
Message-ID: <1209424951-13450-2-git-send-email-johnwheffner@gmail.com>
References: <d1c2719f0804281344h4b8c98b9w6d7d4d2cbcdee857@mail.gmail.com>
 <1209424951-13450-1-git-send-email-johnwheffner@gmail.com>
Cc: netdev@vger.kernel.org, John Heffner <johnwheffner@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail172.messagelabs.com ([216.82.254.3]:24331 "HELO
	mail172.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932292AbYD1XWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 19:22:39 -0400
In-Reply-To: <1209424951-13450-1-git-send-email-johnwheffner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes inappropriately large cwnd growth on sender-limited flows
when GSO is enabled, limiting cwnd growth to 64k.

Signed-off-by: John Heffner <johnwheffner@gmail.com>
---
 net/ipv4/tcp_cong.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index bfb1996..6a25082 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -287,7 +287,8 @@ int tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
 
 	left = tp->snd_cwnd - in_flight;
 	if (sk_can_gso(sk) &&
-	    left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd)
+	    left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd &&
+	    left * tp->mss_cache < sk->sk_gso_max_size)
 		return 1;
 	return left <= tcp_max_burst(tp);
 }
-- 
1.5.2.5


______________________________________________________________________
This email has been scanned by the MessageLabs Email Security System.
For more information please visit http://www.messagelabs.com/email 
______________________________________________________________________
