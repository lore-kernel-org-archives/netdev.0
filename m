From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 11/11] [NET] Reorder struct tcp_options_received
Date: Wed, 9 Mar 2005 20:52:16 +0100
Message-ID: <20050309195216.GS31837@postel.suug.ch>
References: <20050309194521.GH31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050309194521.GH31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Reorders struct tcp_options_received to avoid padding and shrinks the
following fields to more appropriate sizes saving 8 bytes.

saw_tstamp: char -> 1 bit
tstamp_ok: char -> 1 bit
sack_ok: char -> 4 bits
wscale_ok: char -> 1 bit
snd_wscale: u8 -> 4 bits
rcv_wscale: u8 -> 4 bits
dsack: u8 -> 1 bit

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.11-rc4.orig/include/linux/tcp.h linux-2.6.11-rc4/include/linux/tcp.h
--- linux-2.6.11-rc4.orig/include/linux/tcp.h	2005-03-09 14:16:28.000000000 +0100
+++ linux-2.6.11-rc4/include/linux/tcp.h	2005-03-09 17:07:48.000000000 +0100
@@ -216,17 +216,16 @@
 	__u32	ts_recent;	/* Time stamp to echo next		*/
 	__u32	rcv_tsval;	/* Time stamp value             	*/
 	__u32	rcv_tsecr;	/* Time stamp echo reply        	*/
-	char	saw_tstamp;	/* Saw TIMESTAMP on last packet		*/
-	char	tstamp_ok;	/* TIMESTAMP seen on SYN packet		*/
-	char	sack_ok;	/* SACK seen on SYN packet		*/
-	char	wscale_ok;	/* Wscale seen on SYN packet		*/
-	__u8	snd_wscale;	/* Window scaling received from sender	*/
-	__u8	rcv_wscale;	/* Window scaling to send to receiver	*/
+	__u16 	saw_tstamp : 1,	/* Saw TIMESTAMP on last packet		*/
+		tstamp_ok : 1,	/* TIMESTAMP seen on SYN packet		*/
+		dsack : 1,	/* D-SACK is scheduled			*/
+		wscale_ok : 1,	/* Wscale seen on SYN packet		*/
+		sack_ok : 4,	/* SACK seen on SYN packet		*/
+		snd_wscale : 4,	/* Window scaling received from sender	*/
+		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
 /*	SACKs data	*/
-	__u8	dsack;		/* D-SACK is scheduled			*/
 	__u8	eff_sacks;	/* Size of SACK array to send with next packet */
 	__u8	num_sacks;	/* Number of SACK blocks		*/
-	__u8	__pad;
 	__u16	user_mss;  	/* mss requested by user in ioctl */
 	__u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
 };
diff -Nru linux-2.6.11-rc4.orig/net/ipv4/tcp_input.c linux-2.6.11-rc4/net/ipv4/tcp_input.c
--- linux-2.6.11-rc4.orig/net/ipv4/tcp_input.c	2005-03-09 15:22:43.000000000 +0100
+++ linux-2.6.11-rc4/net/ipv4/tcp_input.c	2005-03-09 16:59:40.000000000 +0100
@@ -3018,15 +3018,16 @@
 				case TCPOPT_WINDOW:
 					if(opsize==TCPOLEN_WINDOW && th->syn && !estab)
 						if (sysctl_tcp_window_scaling) {
+							__u8 snd_wscale = *(__u8 *) ptr;
 							opt_rx->wscale_ok = 1;
-							opt_rx->snd_wscale = *(__u8 *)ptr;
-							if(opt_rx->snd_wscale > 14) {
+							if (snd_wscale > 14) {
 								if(net_ratelimit())
 									printk(KERN_INFO "tcp_parse_options: Illegal window "
 									       "scaling value %d >14 received.\n",
-									       opt_rx->snd_wscale);
-								opt_rx->snd_wscale = 14;
+									       snd_wscale);
+								snd_wscale = 14;
 							}
+							opt_rx->snd_wscale = snd_wscale;
 						}
 					break;
 				case TCPOPT_TIMESTAMP:
diff -Nru linux-2.6.11-rc4.orig/net/ipv4/tcp_output.c linux-2.6.11-rc4/net/ipv4/tcp_output.c
--- linux-2.6.11-rc4.orig/net/ipv4/tcp_output.c	2005-03-09 15:22:43.000000000 +0100
+++ linux-2.6.11-rc4/net/ipv4/tcp_output.c	2005-03-09 16:44:59.000000000 +0100
@@ -1427,6 +1427,7 @@
 {
 	struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	__u8 rcv_wscale;
 
 	/* We'll fix this up when we get a response from the other end.
 	 * See tcp_input.c:tcp_rcv_state_process case TCP_SYN_SENT.
@@ -1451,8 +1452,9 @@
 				  &tp->rcv_wnd,
 				  &tp->window_clamp,
 				  sysctl_tcp_window_scaling,
-				  &tp->rx_opt.rcv_wscale);
+				  &rcv_wscale);
 
+	tp->rx_opt.rcv_wscale = rcv_wscale;
 	tp->rcv_ssthresh = tp->rcv_wnd;
 
 	sk->sk_err = 0;
