From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP connection stops after high load.
Date: Thu, 12 Apr 2007 09:12:16 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704120903320.28337@kivilampi-30.cs.helsinki.fi>
References: <461D2DEA.4010806@candelatech.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-3358595-1176358336=:28337"
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45124 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945909AbXDLGMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 02:12:19 -0400
In-Reply-To: <461D2DEA.4010806@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-3358595-1176358336=:28337
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 11 Apr 2007, Ben Greear wrote:

> The problem is that I set up a TCP connection with bi-directional traffic
> of around 800Mbps, doing large (20k - 64k writes and reads) between two ports
> on
> the same machine (this 2.6.18.2 kernel is tainted with my full patch set,
> but I also reproduced with only the non-tainted send-to-self patch applied
> last may on the 2.6.16 kernel, so I assume the bug is not particular to my
> patch
> set).
> 
> At first, all is well, but within 5-10 minutes, the TCP connection will stall
> and I only see a massive amount of duplicate ACKs on the link.  Before,
> I sometimes saw OOM messages, but this time there are no OOM messages.  The
> system
> has a two-port pro/1000 fibre NIC, 1GB RAM, kernel 2.6.18.2 + hacks, etc.
> Stopping and starting the connection allows traffic to flow again (if
> briefly).
> Starting a new connection works fine even if the old one is still stalled,
> so it's not a global memory exhaustion problem.
>
> So, I would like to dig into this problem myself since no one else
> is reporting this type of problem, but I am quite ignorant of the TCP
> stack implementation.  Based on the dup-acks I see on the wire, I assume
> the TCP state machine is messed up somehow.  Could anyone point me to
> likely places in the TCP stack to start looking for this bug?

Since your doing bidirectional, try this patch below (probably you'll have 
apply it manually to 2.6.18 series due to space changes that were made 
after it in net/ hierarchy). I suspect it's a part of the problem but 
there could be other things as well because this should only hinder TCP
before RTO occurs:

[PATCH] [TCP]: Fix ratehalving with bidirectional flows

Actually, the ratehalving seems to work too well, as cwnd is
reduced on every second ACK even though the packets in flight
remains unchanged. Recoveries in a bidirectional flows suffer
quite badly because of this, both NewReno and SACK are affected.

After this patch, rate halving is performed per ACK only if
packets in flight was supposedly changed too.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 322e43c..bf0f74c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1823,19 +1823,22 @@ static inline u32 tcp_cwnd_min(const str
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
@@ -2020,7 +2023,7 @@ static void tcp_try_to_open(struct sock 
 		}
 		tcp_moderate_cwnd(tp);
 	} else {
-		tcp_cwnd_down(sk);
+		tcp_cwnd_down(sk, flag);
 	}
 }
 
@@ -2220,7 +2223,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 
 	if (is_dupack || tcp_head_timedout(sk, tp))
 		tcp_update_scoreboard(sk, tp);
-	tcp_cwnd_down(sk);
+	tcp_cwnd_down(sk, flag);
 	tcp_xmit_retransmit_queue(sk);
 }
 
-- 
1.4.2

---696243703-3358595-1176358336=:28337--
