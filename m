From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 30 Sep 2004 18:12:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930181248.48185e41.davem@davemloft.net>
References: <20040929162923.796d142e.davem@davemloft.net>
	<Pine.NEB.4.33.0409291945100.3434-100000@dexter.psc.edu>
	<20040929170310.46c58095.davem@davemloft.net>
	<20040930001007.GB10496@gondor.apana.org.au>
	<20040930173439.3e0d2799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jheffner@psc.edu, ak@suse.de, niv@us.ibm.com,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040930173439.3e0d2799.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Sep 2004 17:34:39 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> If I disable /proc/sys/net/tcp_moderate_rcvbuf performance
> goes down from ~634Mbit/sec to ~495Mbit/sec.
> 
> Andi, I know you said that with TSO disabled things go 
> more smoothly.  But could you try upping the TCP socket
> receive buffer sizes on the 2.6.5 box to see if that gives
> you the performance back with TSO enabled?

Ok, here is something to play with.  This adds a sysctl
to moderate the percentage of the congestion window we'll
limit TSO segmenting to.

It defaults to 2, but setting of 3 or 4 seem to make
Andi's case behave much better.

With such small receive buffers, netperf simply can't clear
the receive queue fast enough when a burst of TSO created
frames come in.

This is also where the stretch ACKs come from.  We defer
the ACK to recvmsg making progress, because we cannot
advertise a larger window and thus the connection is
application limited.

I'm also thinking about whether this sysctl should be
a divisor instead of a shift, and also whether it should
be in terms of the snd_cwnd or the advertised receiver
window whichever is smaller.

Basically, receivers with too small socket receive buffers
crap out if TSO bursts are too large.  This effect is
minimized the further the receiver is (rtt wise) from
the sender since the path tends to smooth out the bursts.
But on local gigabit lans, the effect is quite pronounced.

Ironically, this case is a great example of how powerful
and incredibly effective John's receive buffer moderation
code is.  2.6.5 performance is severely hampered due to lack
of this code.

===== include/linux/sysctl.h 1.88 vs edited =====
--- 1.88/include/linux/sysctl.h	2004-09-23 14:34:12 -07:00
+++ edited/include/linux/sysctl.h	2004-09-30 17:17:49 -07:00
@@ -341,6 +341,7 @@
 	NET_TCP_BIC_LOW_WINDOW=104,
 	NET_TCP_DEFAULT_WIN_SCALE=105,
 	NET_TCP_MODERATE_RCVBUF=106,
+	NET_TCP_TSO_CWND_SHIFT=107,
 };
 
 enum {
===== include/net/tcp.h 1.92 vs edited =====
--- 1.92/include/net/tcp.h	2004-09-29 21:11:52 -07:00
+++ edited/include/net/tcp.h	2004-09-30 17:18:02 -07:00
@@ -609,6 +609,7 @@
 extern int sysctl_tcp_bic_fast_convergence;
 extern int sysctl_tcp_bic_low_window;
 extern int sysctl_tcp_moderate_rcvbuf;
+extern int sysctl_tcp_tso_cwnd_shift;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
===== net/ipv4/sysctl_net_ipv4.c 1.25 vs edited =====
--- 1.25/net/ipv4/sysctl_net_ipv4.c	2004-08-26 13:55:36 -07:00
+++ edited/net/ipv4/sysctl_net_ipv4.c	2004-09-30 17:19:32 -07:00
@@ -674,6 +674,14 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_TCP_TSO_CWND_SHIFT,
+		.procname	= "tcp_tso_cwnd_shift",
+		.data		= &sysctl_tcp_tso_cwnd_shift,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
===== net/ipv4/tcp_output.c 1.65 vs edited =====
--- 1.65/net/ipv4/tcp_output.c	2004-09-29 21:11:53 -07:00
+++ edited/net/ipv4/tcp_output.c	2004-09-30 17:27:32 -07:00
@@ -44,6 +44,7 @@
 
 /* People can turn this off for buggy TCP's found in printers etc. */
 int sysctl_tcp_retrans_collapse = 1;
+int sysctl_tcp_tso_cwnd_shift = 2;
 
 static __inline__
 void update_send_head(struct sock *sk, struct tcp_opt *tp, struct sk_buff *skb)
@@ -673,7 +674,7 @@
 		    !tp->urg_mode);
 
 	if (do_large) {
-		int large_mss, factor;
+		int large_mss, factor, limit;
 
 		large_mss = 65535 - tp->af_specific->net_header_len -
 			tp->ext_header_len - tp->ext2_header_len -
@@ -688,8 +689,10 @@
 		 * can keep the ACK clock ticking.
 		 */
 		factor = large_mss / mss_now;
-		if (factor > (tp->snd_cwnd >> 2))
-			factor = max(1, tp->snd_cwnd >> 2);
+		limit = tp->snd_cwnd >> sysctl_tcp_tso_cwnd_shift;
+		limit = max(1, limit);
+		if (factor > limit)
+			factor = limit;
 
 		tp->mss_cache = mss_now * factor;
 
