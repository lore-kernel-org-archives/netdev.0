From: "David S. Miller" <davem@davemloft.net>
Subject: Re: way of figuring out total number of retransmitted packets on a
 TCP socket?
Date: Wed, 20 Oct 2004 21:37:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020213739.6e669fdd.davem@davemloft.net>
References: <20041020130134.GC24757@xi.wantstofly.org>
	<20041020151448.51209278.davem@davemloft.net>
	<20041020223547.GJ29583@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041020223547.GJ29583@xi.wantstofly.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please give this 2.6.x patch a spin:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/20 21:21:01-07:00 davem@nuts.davemloft.net 
#   [TCP]: Add total num retransmits accounting.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/tcp_output.c
#   2004/10/20 21:20:29-07:00 davem@nuts.davemloft.net +2 -0
#   [TCP]: Add total num retransmits accounting.
# 
# net/ipv4/tcp_diag.c
#   2004/10/20 21:20:29-07:00 davem@nuts.davemloft.net +2 -0
#   [TCP]: Add total num retransmits accounting.
# 
# include/linux/tcp.h
#   2004/10/20 21:20:29-07:00 davem@nuts.davemloft.net +4 -0
#   [TCP]: Add total num retransmits accounting.
# 
diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	2004-10-20 21:21:21 -07:00
+++ b/include/linux/tcp.h	2004-10-20 21:21:21 -07:00
@@ -186,6 +186,8 @@
 
 	__u32	tcpi_rcv_rtt;
 	__u32	tcpi_rcv_space;
+
+	__u32	tcpi_total_retrans;
 };
 
 #ifdef __KERNEL__
@@ -363,6 +365,8 @@
 	__u8	pending;	/* Scheduled timer event	*/
 	__u8	urg_mode;	/* In urgent mode		*/
 	__u32	snd_up;		/* Urgent pointer		*/
+
+	__u32	total_retrans;	/* Total retransmits for entire connection */
 
 	/* The syn_wait_lock is necessary only to avoid proc interface having
 	 * to grab the main lock sock while browsing the listening hash
diff -Nru a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c	2004-10-20 21:21:21 -07:00
+++ b/net/ipv4/tcp_diag.c	2004-10-20 21:21:21 -07:00
@@ -105,6 +105,8 @@
 
 	info->tcpi_rcv_rtt = jiffies_to_usecs(tp->rcv_rtt_est.rtt)>>3;
 	info->tcpi_rcv_space = tp->rcvq_space.space;
+
+	info->tcpi_total_retrans = tp->total_retrans;
 }
 
 static int tcpdiag_fill(struct sk_buff *skb, struct sock *sk,
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-10-20 21:21:21 -07:00
+++ b/net/ipv4/tcp_output.c	2004-10-20 21:21:22 -07:00
@@ -1106,6 +1106,8 @@
 		/* Update global TCP statistics. */
 		TCP_INC_STATS(TCP_MIB_RETRANSSEGS);
 
+		tp->total_retrans++;
+
 #if FASTRETRANS_DEBUG > 0
 		if (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) {
 			if (net_ratelimit())
