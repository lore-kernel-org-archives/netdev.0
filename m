From: Yee-Ting Li <Yee-Ting.Li@nuim.ie>
Subject: Re: [RFT] BIC TCP delayed ack compensation
Date: Wed, 23 Feb 2005 01:04:50 +0000
Message-ID: <aba19f09a13718465b3e72debe0c406e@may.ie>
References: <050QTJA12@server5.heliogroup.fr>
 <20050209105909.17da40a9@dxpl.pdx.osdl.net>
 <20050222135046.23f7ec7d@dxpl.pdx.osdl.net> <421BC278.90400@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Doug Leith <doug.leith@nuim.ie>, "David S. Miller" <davem@davemloft.net>,
        Injong Rhee <rhee@eos.ncsu.edu>, Yee-Ting Li <yee-ting.li@nuim.ie>,
        Baruch Even <baruch@ev-en.org>,
        Hubert Tonneau <hubert.tonneau@fullpliant.org>,
        cliff white <cliffw@osdl.org>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Stephen Hemminger <shemminger@osdl.org>
In-reply-to: <421BC278.90400@ev-en.org>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Feb 22, 2005, at 23:38, Baruch Even wrote:
> We have a version of ABC (Appropriate Byte Counting) implementation of 
> RFC 3465, which we hope to submit soon for inclusion in the kernel 
> which should be a more appropriate solution for this. The RFC is a 
> well defined standard whereas this patch has not received any 
> reviewing by the networking community.

Please find enclosed a version of our implementation of RFC3465 ABC for 
Linux 2.6.11-rc4.

There is in-built protection, as defined by the RFC, to prevent large 
bursts of packets should acks arrive acknowledging more than abc_L 
packets (sysctl_tcp_abc_L). The entire abc patch can be switched on or 
off using sysctl_tcp_abc={1|0} respectively. As this is also a RFT, it 
is switched ON by default and has the abc_L value of 2 which MAY be 
used (according to the RFC).

Note that an abc_L of 1 will be more conservative than what is 
available with normal clocking of delayed acks. Note that there is 
currently no built in mechanism to prevent abc_L being set to over 2; 
the RFC defines that abc_L MUST NOT be greater than 2.

This patch also has the advantage of working for all protocols 
currently in the kernel (except vegas which doesn't require it).



Signed-off-by: Yee-Ting Li <Yee-Ting.Li@may.ie>

Index: linux-2.6.11-rc4/include/linux/sysctl.h
===================================================================
--- linux-2.6.11-rc4.orig/include/linux/sysctl.h	Sun Feb 13 03:06:53 
2005
+++ linux-2.6.11-rc4/include/linux/sysctl.h	Tue Feb 22 23:48:30 2005
@@ -344,6 +344,8 @@
  	NET_TCP_DEFAULT_WIN_SCALE=105,
  	NET_TCP_MODERATE_RCVBUF=106,
  	NET_TCP_TSO_WIN_DIVISOR=107,
+	NET_TCP_ABC=108,
+	NET_TCP_ABC_L=109,
  };

  enum {
Index: linux-2.6.11-rc4/include/linux/tcp.h
===================================================================
--- linux-2.6.11-rc4.orig/include/linux/tcp.h	Sun Feb 13 03:06:23 2005
+++ linux-2.6.11-rc4/include/linux/tcp.h	Tue Feb 22 23:39:41 2005
@@ -366,6 +366,8 @@

  	__u32	total_retrans;	/* Total retransmits for entire connection */

+	__u32	bytes_acked;	/* Appropiate Byte Counting - RFC3465 */
+	
  	/* The syn_wait_lock is necessary only to avoid proc interface having
  	 * to grab the main lock sock while browsing the listening hash
  	 * (otherwise it's deadlock prone).
Index: linux-2.6.11-rc4/include/net/tcp.h
===================================================================
--- linux-2.6.11-rc4.orig/include/net/tcp.h	Sun Feb 13 03:05:28 2005
+++ linux-2.6.11-rc4/include/net/tcp.h	Tue Feb 22 23:47:59 2005
@@ -609,6 +609,10 @@
  extern int sysctl_tcp_moderate_rcvbuf;
  extern int sysctl_tcp_tso_win_divisor;

+/* RFC3465 - ABC */
+extern int sysctl_tcp_abc;
+extern int sysctl_tcp_abc_L;
+
  extern atomic_t tcp_memory_allocated;
  extern atomic_t tcp_sockets_allocated;
  extern int tcp_memory_pressure;
@@ -1366,6 +1370,7 @@
  static inline void tcp_enter_cwr(struct tcp_sock *tp)
  {
  	tp->prior_ssthresh = 0;
+	tp->bytes_acked=0;
  	if (tp->ca_state < TCP_CA_CWR) {
  		__tcp_enter_cwr(tp);
  		tcp_set_ca_state(tp, TCP_CA_CWR);
Index: linux-2.6.11-rc4/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- linux-2.6.11-rc4.orig/net/ipv4/sysctl_net_ipv4.c	Sun Feb 13 
03:07:01 2005
+++ linux-2.6.11-rc4/net/ipv4/sysctl_net_ipv4.c	Tue Feb 22 23:46:18 2005
@@ -682,6 +682,22 @@
  		.mode		= 0644,
  		.proc_handler	= &proc_dointvec,
  	},
+    	{
+		.ctl_name	= NET_TCP_ABC,
+		.procname	= "tcp_abc",
+		.data		= &sysctl_tcp_abc,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+    	{
+		.ctl_name	= NET_TCP_ABC_L,
+		.procname	= "tcp_abc_L",
+		.data		= &sysctl_tcp_abc_L,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
  	{ .ctl_name = 0 }
  };

Index: linux-2.6.11-rc4/net/ipv4/tcp.c
===================================================================
--- linux-2.6.11-rc4.orig/net/ipv4/tcp.c	Sun Feb 13 03:05:50 2005
+++ linux-2.6.11-rc4/net/ipv4/tcp.c	Tue Feb 22 23:28:28 2005
@@ -1825,6 +1825,7 @@
  	tp->packets_out = 0;
  	tp->snd_ssthresh = 0x7fffffff;
  	tp->snd_cwnd_cnt = 0;
+	tp->bytes_acked = 0;
  	tcp_set_ca_state(tp, TCP_CA_Open);
  	tcp_clear_retrans(tp);
  	tcp_delack_init(tp);
Index: linux-2.6.11-rc4/net/ipv4/tcp_input.c
===================================================================
--- linux-2.6.11-rc4.orig/net/ipv4/tcp_input.c	Tue Feb 22 23:27:44 2005
+++ linux-2.6.11-rc4/net/ipv4/tcp_input.c	Wed Feb 23 00:25:44 2005
@@ -92,6 +92,11 @@

  int sysctl_tcp_moderate_rcvbuf = 1;

+/* RFC 3465 - ABC */
+int sysctl_tcp_abc = 1;
+int sysctl_tcp_abc_L = 2;   /* The RFC definess 1 as being a more 
conservative value */
+			    /* that SHOULD be used, however, we use 2 as it MAY be used */
+
  /* Default values of the Vegas variables, in fixed-point representation
   * with V_PARAM_SHIFT bits to the right of the binary point.
   */
@@ -1287,6 +1292,7 @@
  	tp->snd_cwnd_cnt   = 0;
  	tp->snd_cwnd_stamp = tcp_time_stamp;

+	tp->bytes_acked = 0;
  	tcp_clear_retrans(tp);

  	/* Push undo marker, if it was plain RTO and nothing
@@ -1945,6 +1951,8 @@
  			TCP_ECN_queue_cwr(tp);
  		}

+		tp->bytes_acked = 0;
+			
  		tp->snd_cwnd_cnt = 0;
  		tcp_set_ca_state(tp, TCP_CA_Recovery);
  	}
@@ -2100,6 +2108,24 @@
  	tp->snd_cwnd_stamp = tcp_time_stamp;
  }

+/* This is a wrapper function to handle RFC3465 - ABC. As per the RFC, 
the abc_L
+ * value defines a burst moderation to prevent sending large bursts of 
packets
+ * should an ack acknowledge many packets. abc_L MUST NOT be larger 
than 2. */
+static __inline__ void reno_cong_avoid_abc( struct tcp_sock *tp, int 
mss_now )
+{
+	int incrs_applied = 0;
+	
+	if (sysctl_tcp_abc && !tp->nonagle)
+	{
+		while (tp->bytes_acked > mss_now && incrs_applied < 
sysctl_tcp_abc_L) {
+			tp->bytes_acked -= mss_now;
+			reno_cong_avoid( tp );
+		}
+	} else
+		reno_cong_avoid( tp );
+}
+
+
  /* This is based on the congestion detection/avoidance scheme 
described in
   *    Lawrence S. Brakmo and Larry L. Peterson.
   *    "TCP Vegas: End to end congestion avoidance on a global 
internet."
@@ -2322,12 +2348,15 @@
  	tp->snd_cwnd_stamp = tcp_time_stamp;
  }

-static inline void tcp_cong_avoid(struct tcp_sock *tp, u32 ack, u32 
seq_rtt)
+static inline void tcp_cong_avoid(struct sock *sk, u32 ack, u32 
seq_rtt)
  {
+    	struct tcp_sock *tp = tcp_sk(sk);
+	int mss_now = tcp_current_mss(sk,1);
+
  	if (tcp_vegas_enabled(tp))
  		vegas_cong_avoid(tp, ack, seq_rtt);
  	else
-		reno_cong_avoid(tp);
+		reno_cong_avoid_abc(tp, mss_now);
  }

  /* Restart timer after forward progress on connection.
@@ -2890,6 +2919,9 @@
  	if (before(ack, prior_snd_una))
  		goto old_ack;

+	if ( sysctl_tcp_abc && tp->ca_state < TCP_CA_CWR )
+	    tp->bytes_acked += ack - prior_snd_una;	
+	
  	if (!(flag&FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
  		/* Window is constant, pure forward advance.
  		 * No more checks are required.
@@ -2940,12 +2972,12 @@
  		if ((flag & FLAG_DATA_ACKED) &&
  		    (tcp_vegas_enabled(tp) || prior_in_flight >= tp->snd_cwnd) &&
  		    tcp_may_raise_cwnd(tp, flag))
-			tcp_cong_avoid(tp, ack, seq_rtt);
+			tcp_cong_avoid(sk, ack, seq_rtt);
  		tcp_fastretrans_alert(sk, prior_snd_una, prior_packets, flag);
  	} else {
  		if ((flag & FLAG_DATA_ACKED) &&
  		    (tcp_vegas_enabled(tp) || prior_in_flight >= tp->snd_cwnd))
-			tcp_cong_avoid(tp, ack, seq_rtt);
+			tcp_cong_avoid(sk, ack, seq_rtt);
  	}

  	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag&FLAG_NOT_DUP))
Index: linux-2.6.11-rc4/net/ipv4/tcp_minisocks.c
===================================================================
--- linux-2.6.11-rc4.orig/net/ipv4/tcp_minisocks.c	Sun Feb 13 03:07:01 
2005
+++ linux-2.6.11-rc4/net/ipv4/tcp_minisocks.c	Tue Feb 22 23:28:28 2005
@@ -769,6 +769,8 @@
  		newtp->snd_cwnd = 2;
  		newtp->snd_cwnd_cnt = 0;

+		newtp->bytes_acked = 0;
+
  		newtp->frto_counter = 0;
  		newtp->frto_highmark = 0;
