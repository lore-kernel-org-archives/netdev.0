From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 30 Sep 2004 20:40:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930204005.69115c0e.davem@davemloft.net>
References: <20040929162923.796d142e.davem@davemloft.net>
	<Pine.NEB.4.33.0409291945100.3434-100000@dexter.psc.edu>
	<20040929170310.46c58095.davem@davemloft.net>
	<20040930001007.GB10496@gondor.apana.org.au>
	<20040930173439.3e0d2799.davem@davemloft.net>
	<20040930181248.48185e41.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jheffner@psc.edu, ak@suse.de, niv@us.ibm.com,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040930181248.48185e41.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Sep 2004 18:12:48 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> Ok, here is something to play with.  This adds a sysctl
> to moderate the percentage of the congestion window we'll
> limit TSO segmenting to.

I've done some tweaking and this is the patch I actually
checked into my tree.  I made it a divisor and the default
is 8.

I tried to play around with taking the send window and the
congestion window both into account, but that did not help
at all.

My current setup is Ultra-III 750Mhz w/tg3 sending to
Ultra-II 360Mhz w/tg3 through a D-Link DGS 1008-T gigabit
switch.  I'm using 32-bit binaries of netperf 2.3pl1
built with -DUSE_PROC_STAT and -DHAVE_SENDFILE.

The MTU being used is 1500.

Each run is made via "netperf -fM -H ${IP_OF_ULTRA-II}".
I did 3 runs each for 4 different configurations.  The
parameters are "TSO on/off" (sender side) and "TCP rcvbuf
moderation on/off" (receiver side).

With this patch I'm seeing these results:

TSO off + rbuf off:	63.15 MBytes/sec
			64.78 MBytes/sec
			64.53 MBytes/sec

TSO on  + rbuf off:	62.76 MBytes/sec
			63.36 MBytes/sec
			63.79 MBytes/sec

TSO off + rbuf on:	71.98 MBytes/sec
			73.52 MBytes/sec
			73.57 MBytes/sec

TSO on  + rbuf on:	75.70 MBytes/sec
			76.05 MBytes/sec
			75.42 MBytes/sec

The "rbuf off" cases are meant to emulate Andi's 2.6.5
case, and "rbuf on" is current 2.6.x.

How do things look for you with this change Andi?
If things are still out of whack, play around with
different values of /proc/sys/net/ipv4/tcp_tso_win_divisor

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/30 20:09:28-07:00 davem@nuts.davemloft.net 
#   [TCP]: Add tcp_tso_win_divisor sysctl.
#   
#   This allows control over what percentage of
#   the congestion window can be consumed by a
#   single TSO frame.
#   
#   The setting of this parameter is a choice
#   between burstiness and building larger TSO
#   frames.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/tcp_output.c
#   2004/09/30 20:07:20-07:00 davem@nuts.davemloft.net +19 -7
#   [TCP]: Add tcp_tso_win_divisor sysctl.
# 
# net/ipv4/sysctl_net_ipv4.c
#   2004/09/30 20:07:20-07:00 davem@nuts.davemloft.net +8 -0
#   [TCP]: Add tcp_tso_win_divisor sysctl.
# 
# include/net/tcp.h
#   2004/09/30 20:07:20-07:00 davem@nuts.davemloft.net +1 -0
#   [TCP]: Add tcp_tso_win_divisor sysctl.
# 
# include/linux/sysctl.h
#   2004/09/30 20:07:20-07:00 davem@nuts.davemloft.net +1 -0
#   [TCP]: Add tcp_tso_win_divisor sysctl.
# 
diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	2004-09-30 20:19:49 -07:00
+++ b/include/linux/sysctl.h	2004-09-30 20:19:49 -07:00
@@ -341,6 +341,7 @@
 	NET_TCP_BIC_LOW_WINDOW=104,
 	NET_TCP_DEFAULT_WIN_SCALE=105,
 	NET_TCP_MODERATE_RCVBUF=106,
+	NET_TCP_TSO_WIN_DIVISOR=107,
 };
 
 enum {
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-09-30 20:19:49 -07:00
+++ b/include/net/tcp.h	2004-09-30 20:19:49 -07:00
@@ -609,6 +609,7 @@
 extern int sysctl_tcp_bic_fast_convergence;
 extern int sysctl_tcp_bic_low_window;
 extern int sysctl_tcp_moderate_rcvbuf;
+extern int sysctl_tcp_tso_win_divisor;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
diff -Nru a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c	2004-09-30 20:19:49 -07:00
+++ b/net/ipv4/sysctl_net_ipv4.c	2004-09-30 20:19:49 -07:00
@@ -674,6 +674,14 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_TCP_TSO_WIN_DIVISOR,
+		.procname	= "tcp_tso_win_divisor",
+		.data		= &sysctl_tcp_tso_win_divisor,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-09-30 20:19:49 -07:00
+++ b/net/ipv4/tcp_output.c	2004-09-30 20:19:49 -07:00
@@ -45,6 +45,12 @@
 /* People can turn this off for buggy TCP's found in printers etc. */
 int sysctl_tcp_retrans_collapse = 1;
 
+/* This limits the percentage of the congestion window which we
+ * will allow a single TSO frame to consume.  Building TSO frames
+ * which are too large can cause TCP streams to be bursty.
+ */
+int sysctl_tcp_tso_win_divisor = 8;
+
 static __inline__
 void update_send_head(struct sock *sk, struct tcp_opt *tp, struct sk_buff *skb)
 {
@@ -658,7 +664,7 @@
 {
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
-	int do_large, mss_now;
+	unsigned int do_large, mss_now;
 
 	mss_now = tp->mss_cache_std;
 	if (dst) {
@@ -673,7 +679,7 @@
 		    !tp->urg_mode);
 
 	if (do_large) {
-		int large_mss, factor;
+		unsigned int large_mss, factor, limit;
 
 		large_mss = 65535 - tp->af_specific->net_header_len -
 			tp->ext_header_len - tp->ext2_header_len -
@@ -683,13 +689,19 @@
 			large_mss = max((tp->max_window>>1),
 					68U - tp->tcp_header_len);
 
+		factor = large_mss / mss_now;
+
 		/* Always keep large mss multiple of real mss, but
-		 * do not exceed 1/4 of the congestion window so we
-		 * can keep the ACK clock ticking.
+		 * do not exceed 1/tso_win_divisor of the congestion window
+		 * so we can keep the ACK clock ticking and minimize
+		 * bursting.
 		 */
-		factor = large_mss / mss_now;
-		if (factor > (tp->snd_cwnd >> 2))
-			factor = max(1, tp->snd_cwnd >> 2);
+		limit = tp->snd_cwnd;
+		if (sysctl_tcp_tso_win_divisor)
+			limit /= sysctl_tcp_tso_win_divisor;
+		limit = max(1U, limit);
+		if (factor > limit)
+			factor = limit;
 
 		tp->mss_cache = mss_now * factor;
 
