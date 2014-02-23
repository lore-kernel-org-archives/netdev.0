From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] tcp: reduce the bloat caused by tcp_is_cwnd_limited()
Date: Sat, 22 Feb 2014 22:25:57 -0800
Message-ID: <1393136757.2316.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393105959.2316.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:53809 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbaBWGZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 01:25:59 -0500
Received: by mail-pa0-f46.google.com with SMTP id rd3so5158229pab.5
        for <netdev@vger.kernel.org>; Sat, 22 Feb 2014 22:25:58 -0800 (PST)
In-Reply-To: <1393105959.2316.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_is_cwnd_limited() allows GSO/TSO enabled flows to increase
their cwnd to allow a full size (64KB) TSO packet to be sent.

Non GSO flows only allow an extra room of 3 MSS.

For most flows with a BDP below 10 MSS, this results in a bloat
of cwnd reaching 90, and an inflate of RTT.

Thanks to TSO auto sizing, we can restrict the bloat to the number
of MSS contained in a TSO packet (tp->xmit_size_goal_segs), to keep
original intent without performance impact.

Because we keep cwnd small, it helps to keep TSO packet size to their
optimal value.

Example for a 10Mbit flow, with low TCP Small queue limits (no more than
2 skb in qdisc/device tx ring)

Before patch :

lpk51:~# ./ss -i dst lpk52:44862 | grep cwnd
         cubic wscale:6,6 rto:215 rtt:15.875/2.5 mss:1448 cwnd:96
ssthresh:96
send 70.1Mbps unacked:14 rcv_space:29200

After patch :

lpk51:~# ./ss -i dst lpk52:52916 | grep cwnd
         cubic wscale:6,6 rto:206 rtt:5.206/0.036 mss:1448 cwnd:15
ssthresh:14
send 33.4Mbps unacked:4 rcv_space:29200

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Van Jacobson <vanj@google.com> 
---
v2: addressed Neal point about keeping first condition.

 net/ipv4/tcp_cong.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index ad37bf18ae4b..2388275adb9b 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -290,8 +290,7 @@ bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
 	left = tp->snd_cwnd - in_flight;
 	if (sk_can_gso(sk) &&
 	    left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd &&
-	    left * tp->mss_cache < sk->sk_gso_max_size &&
-	    left < sk->sk_gso_max_segs)
+	    left < tp->xmit_size_goal_segs)
 		return true;
 	return left <= tcp_max_tso_deferred_mss(tp);
 }
