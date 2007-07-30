From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6 1/2] [TCP]: Fix ratehalving with bidirectional flows
Date: Mon, 30 Jul 2007 20:18:45 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707302017290.8788@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0707301947210.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1303777718-1185815925=:8788"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48420 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933040AbXG3RSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 13:18:46 -0400
In-Reply-To: <Pine.LNX.4.64.0707301947210.8788@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1303777718-1185815925=:8788
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Actually, the ratehalving seems to work too well, as cwnd is
reduced on every second ACK even though the packets in flight
remains unchanged. Recoveries in a bidirectional flows suffer
quite badly because of this, both NewReno and SACK are affected.

After this patch, rate halving is performed for ACK only if
packets in flight was supposedly changed too.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0163051..767f92c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1848,19 +1848,22 @@ static inline u32 tcp_cwnd_min(const struct sock *sk)
 }
 
 /* Decrease cwnd each second ack. */
-static void tcp_cwnd_down(struct sock *sk)
+static void tcp_cwnd_down(struct sock *sk, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int decr = tp->snd_cwnd_cnt + 1;
+	
+	if ((flag&FLAG_FORWARD_PROGRESS) ||
+	    (IsReno(tp) && !(flag&FLAG_NOT_DUP))) {
+		tp->snd_cwnd_cnt = decr&1;
+		decr >>= 1;
 
-	tp->snd_cwnd_cnt = decr&1;
-	decr >>= 1;
+		if (decr && tp->snd_cwnd > tcp_cwnd_min(sk))
+			tp->snd_cwnd -= decr;
 
-	if (decr && tp->snd_cwnd > tcp_cwnd_min(sk))
-		tp->snd_cwnd -= decr;
-
-	tp->snd_cwnd = min(tp->snd_cwnd, tcp_packets_in_flight(tp)+1);
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+		tp->snd_cwnd = min(tp->snd_cwnd, tcp_packets_in_flight(tp)+1);
+		tp->snd_cwnd_stamp = tcp_time_stamp;
+	}
 }
 
 /* Nothing was retransmitted or returned timestamp is less
@@ -2057,7 +2060,7 @@ static void tcp_try_to_open(struct sock *sk, int flag)
 		}
 		tcp_moderate_cwnd(tp);
 	} else {
-		tcp_cwnd_down(sk);
+		tcp_cwnd_down(sk, flag);
 	}
 }
 
@@ -2257,7 +2260,7 @@ tcp_fastretrans_alert(struct sock *sk, u32 prior_snd_una,
 
 	if (is_dupack || tcp_head_timedout(sk))
 		tcp_update_scoreboard(sk);
-	tcp_cwnd_down(sk);
+	tcp_cwnd_down(sk, flag);
 	tcp_xmit_retransmit_queue(sk);
 }
 
-- 
1.5.0.6

---696243703-1303777718-1185815925=:8788--
