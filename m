From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] BIC TCP delayed ack compensation
Date: Tue, 22 Feb 2005 13:50:46 -0800
Message-ID: <20050222135046.23f7ec7d@dxpl.pdx.osdl.net>
References: <050QTJA12@server5.heliogroup.fr>
	<20050209105909.17da40a9@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        Injong Rhee
 <rhee@eos.ncsu.edu>,
        "David S. Miller" <davem@davemloft.net>
To: Hubert Tonneau <hubert.tonneau@fullpliant.org>,
        cliff white
 <cliffw@osdl.org>
In-Reply-To: <20050209105909.17da40a9@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch which was extracted from BIC TCP 1.1 compensates
for systems (like MaxOSX) that don't ACK every other packet.
It has no impact for normal transfers, but might help with problems
with Mac like Hubert found.


diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	2005-02-22 13:44:12 -08:00
+++ b/include/linux/tcp.h	2005-02-22 13:44:12 -08:00
@@ -433,6 +433,7 @@
 		__u32 	last_max_cwnd;	/* last maximium snd_cwnd */
 		__u32	last_cwnd;	/* the last snd_cwnd */
 		__u32   last_stamp;     /* time when updated last_cwnd */
+		__u32	delayed_ack;	/* ratio of packets/ACKs */
 	} bictcp;
 };
 
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2005-02-22 13:44:12 -08:00
+++ b/include/net/tcp.h	2005-02-22 13:44:12 -08:00
@@ -508,6 +508,8 @@
 #define BICTCP_BETA_SCALE    1024	/* Scale factor beta calculation
 					 * max_cwnd = snd_cwnd * beta
 					 */
+#define BICTCP_DELAY_SCALE   1024	/* Scale for delayed_ack ratio */
+
 #define BICTCP_MAX_INCREMENT 32		/*
 					 * Limit on the amount of
 					 * increment allowed during
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2005-02-22 13:44:12 -08:00
+++ b/net/ipv4/tcp_input.c	2005-02-22 13:44:12 -08:00
@@ -339,6 +339,7 @@
 	tp->bictcp.last_max_cwnd = 0;
 	tp->bictcp.last_cwnd = 0;
 	tp->bictcp.last_stamp = 0;
+	tp->bictcp.delayed_ack = 2 * BICTCP_DELAY_SCALE;
 }
 
 /* 5. Recalculate window clamp after socket hit its memory bounds. */
@@ -2075,6 +2076,13 @@
 			/* linear increase */
 			tp->bictcp.cnt = tp->snd_cwnd / BICTCP_MAX_INCREMENT;
 	}
+
+	/* compensate for delayed ack's */
+	tp->bictcp.cnt = (tp->bictcp.cnt * BICTCP_DELAY_SCALE)
+		/ tp->bictcp.delayed_ack;
+	if (tp->bictcp.cnt == 0)
+		tp->bictcp.cnt = 1;
+
 	return tp->bictcp.cnt;
 }
 
@@ -2418,6 +2426,7 @@
 	__u32 now = tcp_time_stamp;
 	int acked = 0;
 	__s32 seq_rtt = -1;
+	__u32 cnt = 0;
 
 	while ((skb = skb_peek(&sk->sk_write_queue)) &&
 	       skb != sk->sk_send_head) {
@@ -2472,7 +2481,13 @@
 		tcp_packets_out_dec(tp, skb);
 		__skb_unlink(skb, skb->list);
 		sk_stream_free_skb(sk, skb);
+		++cnt;
 	}
+
+	/* compute average packets per ACK (scaled by 1024) */
+	if (cnt > 0 && tcp_is_bic(tp) && tp->ca_state == TCP_CA_Open)
+		tp->bictcp.delayed_ack = (15 * tp->bictcp.delayed_ack) / 16
+			+ (BICTCP_DELAY_SCALE/16) * cnt;
 
 	if (acked&FLAG_ACKED) {
 		tcp_ack_update_rtt(tp, acked, seq_rtt);
