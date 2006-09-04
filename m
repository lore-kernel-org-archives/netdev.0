From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: [PATCH][RFC] Re: high latency with TCP connections
Date: Mon, 4 Sep 2006 20:00:45 +0400
Message-ID: <20060904160045.GA15599@ms2.inr.ac.ru>
References: <20060830100734.GA22235@isil.ipib.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:19142 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S964899AbWIDQAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 12:00:52 -0400
To: Alexander Vodomerov <alex@sectorb.msk.ru>
Content-Disposition: inline
In-Reply-To: <20060830100734.GA22235@isil.ipib.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Some people reported that this program runs in 9.997 sec when run on
> FreeBSD.

Try enclosed patch. I have no idea why 9.997 sec is so magic, but I
get exactly this number on my notebook. :-)

Alexey

=================

This patch enables sending ACKs each 2d received segment.
It does not affect either mss-sized connections (obviously) or connections
controlled by Nagle (because there is only one small segment in flight).

The idea is to record the fact that a small segment arrives
on a connection, where one small segment has already been received
and still not-ACKed. In this case ACK is forced after tcp_recvmsg()
drains receive buffer.

In other words, it is a "soft" each-2d-segment ACK, which is enough
to preserve ACK clock even when ABC is enabled.

Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>



diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 9bf73fe..de4e83b 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -147,7 +147,8 @@ extern struct sock *inet_csk_clone(struc
 enum inet_csk_ack_state_t {
 	ICSK_ACK_SCHED	= 1,
 	ICSK_ACK_TIMER  = 2,
-	ICSK_ACK_PUSHED = 4
+	ICSK_ACK_PUSHED = 4,
+	ICSK_ACK_PUSHED2 = 8
 };
 
 extern void inet_csk_init_xmit_timers(struct sock *sk,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 934396b..4f3b76f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -955,8 +955,11 @@ #endif
 		     * receive buffer and there was a small segment
 		     * in queue.
 		     */
-		    (copied > 0 && (icsk->icsk_ack.pending & ICSK_ACK_PUSHED) &&
-		     !icsk->icsk_ack.pingpong && !atomic_read(&sk->sk_rmem_alloc)))
+		    (copied > 0 &&
+		     ((icsk->icsk_ack.pending & ICSK_ACK_PUSHED2) ||
+		      ((icsk->icsk_ack.pending & ICSK_ACK_PUSHED) &&
+		       !icsk->icsk_ack.pingpong) &&
+		      !atomic_read(&sk->sk_rmem_alloc)))
 			time_to_ack = 1;
 	}
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 111ff39..5877920 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -156,6 +156,8 @@ static void tcp_measure_rcv_mss(struct s
 				return;
 			}
 		}
+		if (icsk->icsk_ack.pending & ICSK_ACK_PUSHED)
+			icsk->icsk_ack.pending |= ICSK_ACK_PUSHED2;
 		icsk->icsk_ack.pending |= ICSK_ACK_PUSHED;
 	}
 }
