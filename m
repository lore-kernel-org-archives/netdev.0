From: Daniele Lacamera <mlists@danielinux.net>
Subject: Re: [PATCH] select congestion control with one sysctl
Date: Thu, 24 Feb 2005 02:05:22 +0100
Message-ID: <200502240205.22972.mlists@danielinux.net>
References: <421CF5E5.1060606@ev-en.org> <20050223135732.39e62c6c.davem@davemloft.net>
Reply-To: mlists@danielinux.net
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_ShSHCpsn9pKjOO8"
Cc: Baruch Even <baruch@ev-en.org>, shemminger@osdl.org, netdev@oss.sgi.com,
        linux-net@vger.kernel.org, yee-ting.li@nuim.ie, doug.leith@nuim.ie
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050223135732.39e62c6c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Boundary-00=_ShSHCpsn9pKjOO8
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 23 February 2005 22:57, David S. Miller wrote:
> 
> For the millionth time, you can't just delete the existing sysctls.
> That is a user visisble interface.
> 
> Instead, you have to make them at least appear to select a
> single congestion control algorithm 
[..]

Maybe this could be a starting point.

This version of hybla patch makes our sysctls mutually exclusive by 
switching all off just before performing a "write" operation on one of 
them.

However, there should be more than one cleaner way to do it ...


-- 
Daniele Lacamera
root at danielinux.net

--Boundary-00=_ShSHCpsn9pKjOO8
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="tcp_hybla_exclusive-sysctl.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="tcp_hybla_exclusive-sysctl.patch"

diff -ruN linux-2.6.11-rc4/Documentation/networking/ip-sysctl.txt hybla-2.6.11-rc4/Documentation/networking/ip-sysctl.txt
--- linux-2.6.11-rc4/Documentation/networking/ip-sysctl.txt	2005-02-13 04:06:20.000000000 +0100
+++ hybla-2.6.11-rc4/Documentation/networking/ip-sysctl.txt	2005-02-22 13:50:38.000000000 +0100
@@ -349,6 +349,18 @@
 	window. Allows two flows sharing the same connection to converge
 	more rapidly.
 	Default: 1
+	
+tcp_hybla - BOOLEAN
+	Enable TCP-Hybla congestion control algorithm.
+	TCP-Hybla is a sender-side only change that eliminates penalization of
+	long-RTT, large-bandwidth connections, like when satellite legs are
+	involved, expecially when sharing a common bottleneck with normal 
+	terrestrial connections.
+	Default: 0
+	
+tcp_hybla_rtt0 - INTEGER
+	Divisor to set up rtt0 value for hybla congestion control.
+	Default: 40 (= 1/40 sec == 25ms)
 
 tcp_default_win_scale - INTEGER
 	Sets the minimum window scale TCP will negotiate for on all
diff -ruN linux-2.6.11-rc4/include/linux/sysctl.h hybla-2.6.11-rc4/include/linux/sysctl.h
--- linux-2.6.11-rc4/include/linux/sysctl.h	2005-02-13 04:06:53.000000000 +0100
+++ hybla-2.6.11-rc4/include/linux/sysctl.h	2005-02-24 01:41:45.000000000 +0100
@@ -344,6 +344,8 @@
 	NET_TCP_DEFAULT_WIN_SCALE=105,
 	NET_TCP_MODERATE_RCVBUF=106,
 	NET_TCP_TSO_WIN_DIVISOR=107,
+	NET_TCP_HYBLA=108,
+	NET_TCP_HYBLA_RTT0=109,
 };
 
 enum {
@@ -788,6 +790,8 @@
 			 void __user *, size_t *, loff_t *);
 extern int proc_dointvec(ctl_table *, int, struct file *,
 			 void __user *, size_t *, loff_t *);
+extern int proc_switch_congctl(ctl_table *, int, struct file *,
+			 void __user *, size_t *, loff_t *);
 extern int proc_dointvec_bset(ctl_table *, int, struct file *,
 			      void __user *, size_t *, loff_t *);
 extern int proc_dointvec_minmax(ctl_table *, int, struct file *,
diff -ruN linux-2.6.11-rc4/include/linux/tcp.h hybla-2.6.11-rc4/include/linux/tcp.h
--- linux-2.6.11-rc4/include/linux/tcp.h	2005-02-13 04:06:23.000000000 +0100
+++ hybla-2.6.11-rc4/include/linux/tcp.h	2005-02-22 13:04:53.000000000 +0100
@@ -434,6 +434,16 @@
 		__u32	last_cwnd;	/* the last snd_cwnd */
 		__u32   last_stamp;     /* time when updated last_cwnd */
 	} bictcp;
+	
+	/* Tcp Hybla structure. */
+        struct{
+                __u32   snd_cwnd_cents; /* Keeps increment values when it is <1, <<7 */
+                __u32   rho;            /* Rho parameter, integer part  */
+                __u32   rho2;           /* Rho * Rho, integer part */
+                __u32   rho_3ls;        /* Rho parameter, <<3 */
+                __u32   rho2_7ls;       /* Rho^2, <<7	*/
+                __u32   minrtt;         /* Minimum smoothed round trip time value seen  */
+        } hybla;
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff -ruN linux-2.6.11-rc4/include/net/tcp.h hybla-2.6.11-rc4/include/net/tcp.h
--- linux-2.6.11-rc4/include/net/tcp.h	2005-02-13 04:05:28.000000000 +0100
+++ hybla-2.6.11-rc4/include/net/tcp.h	2005-02-22 16:30:05.000000000 +0100
@@ -608,6 +608,8 @@
 extern int sysctl_tcp_bic_low_window;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
+extern int sysctl_tcp_hybla;
+extern int sysctl_tcp_hybla_rtt0;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
@@ -2017,4 +2019,37 @@
 
 	return (cwnd != 0);
 }
+
+/*
+ * TCP HYBLA Functions and constants
+ */
+/* Hybla reference round trip time (default= 1/40 sec = 25 ms), expressed in jiffies */
+#define RTT0 (__u32) ((HZ/sysctl_tcp_hybla_rtt0))
+/*
+ * This is called in tcp_ipv4.c and
+ * tcp_minisocks.c when connection starts
+ */
+static inline void init_hybla(struct tcp_sock *tp)
+{
+        tp->hybla.rho = 0;
+        tp->hybla.rho2 = 0;
+        tp->hybla.rho_3ls = 0;
+        tp->hybla.rho2_7ls = 0;
+        tp->hybla.snd_cwnd_cents = 0;
+}
+/* This is called to refresh values for hybla parameters */
+static inline void hybla_recalc_param (struct tcp_sock *tp)
+{
+
+        tp->hybla.rho_3ls = (tp->srtt / RTT0);
+        if(tp->hybla.rho_3ls < 8) 
+		tp->hybla.rho_3ls =8;
+	
+        tp->hybla.rho=(tp->hybla.rho_3ls >> 3);
+        tp->hybla.rho2_7ls = ((tp->hybla.rho_3ls * tp->hybla.rho_3ls)<<1);
+        tp->hybla.rho2=(tp->hybla.rho2_7ls >>7);
+
+        if (sysctl_tcp_hybla)
+                tp->snd_cwnd_clamp = min_t (__u32, tp->snd_cwnd_clamp, tp->hybla.rho<<16);
+}
 #endif	/* _TCP_H */
diff -ruN linux-2.6.11-rc4/kernel/sysctl.c hybla-2.6.11-rc4/kernel/sysctl.c
--- linux-2.6.11-rc4/kernel/sysctl.c	2005-02-13 04:05:27.000000000 +0100
+++ hybla-2.6.11-rc4/kernel/sysctl.c	2005-02-24 01:41:16.000000000 +0100
@@ -66,6 +66,11 @@
 extern int printk_ratelimit_burst;
 extern int pid_max_min, pid_max_max;
 
+extern int sysctl_tcp_vegas_cong_avoid;
+extern int sysctl_tcp_bic;
+extern int sysctl_tcp_westwood;
+extern int sysctl_tcp_hybla;
+
 #if defined(CONFIG_X86_LOCAL_APIC) && defined(CONFIG_X86)
 int unknown_nmi_panic;
 extern int proc_unknown_nmi_panic(ctl_table *, int, struct file *,
@@ -1595,6 +1600,23 @@
 		    	    NULL,NULL);
 }
 
+/**
+ * Used by tcp engine to realize a multi-switch for congestion
+ * control algorithm selection.
+ */
+int proc_switch_congctl(ctl_table *table, int write, struct file *filp,
+			void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	if(write){
+		sysctl_tcp_vegas_cong_avoid=0;
+		sysctl_tcp_westwood=0;
+		sysctl_tcp_bic=0;
+		sysctl_tcp_hybla=0;
+	}
+	return do_proc_dointvec(table,write,filp,buffer,lenp,ppos,
+				NULL,NULL);
+}
+
 #define OP_SET	0
 #define OP_AND	1
 #define OP_OR	2
@@ -2216,6 +2238,7 @@
  * exception granted :-)
  */
 EXPORT_SYMBOL(proc_dointvec);
+EXPORT_SYMBOL(proc_switch_congctl);
 EXPORT_SYMBOL(proc_dointvec_jiffies);
 EXPORT_SYMBOL(proc_dointvec_minmax);
 EXPORT_SYMBOL(proc_dointvec_userhz_jiffies);
diff -ruN linux-2.6.11-rc4/net/ipv4/sysctl_net_ipv4.c hybla-2.6.11-rc4/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6.11-rc4/net/ipv4/sysctl_net_ipv4.c	2005-02-13 04:07:01.000000000 +0100
+++ hybla-2.6.11-rc4/net/ipv4/sysctl_net_ipv4.c	2005-02-24 01:40:49.000000000 +0100
@@ -608,7 +608,7 @@
 		.data		= &sysctl_tcp_westwood,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_switch_congctl,
 	},
 	{
 		.ctl_name	= NET_TCP_VEGAS,
@@ -616,7 +616,7 @@
 		.data		= &sysctl_tcp_vegas_cong_avoid,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_switch_congctl,
 	},
 	{
 		.ctl_name	= NET_TCP_VEGAS_ALPHA,
@@ -648,7 +648,7 @@
 		.data		= &sysctl_tcp_bic,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_switch_congctl,
 	},
 	{
 		.ctl_name	= NET_TCP_BIC_FAST_CONVERGENCE,
@@ -682,6 +682,22 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name       = NET_TCP_HYBLA,
+		.procname       = "tcp_hybla",
+		.data           = &sysctl_tcp_hybla,
+		.maxlen         = sizeof(int),
+                .mode           = 0644,
+                .proc_handler   = &proc_switch_congctl,
+        },
+	{
+		.ctl_name       = NET_TCP_HYBLA_RTT0,
+		.procname       = "tcp_hybla_rtt0",
+		.data           = &sysctl_tcp_hybla_rtt0,
+		.maxlen         = sizeof(int),
+                .mode           = 0644,
+                .proc_handler   = &proc_dointvec,
+        },
 	{ .ctl_name = 0 }
 };
 
diff -ruN linux-2.6.11-rc4/net/ipv4/tcp.c hybla-2.6.11-rc4/net/ipv4/tcp.c
--- linux-2.6.11-rc4/net/ipv4/tcp.c	2005-02-13 04:05:50.000000000 +0100
+++ hybla-2.6.11-rc4/net/ipv4/tcp.c	2005-02-22 16:30:41.000000000 +0100
@@ -1813,6 +1813,10 @@
 
 	if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
 		inet_reset_saddr(sk);
+	
+	/* [TCP HYBLA] Reset values on disconnect */
+        if (sysctl_tcp_hybla)
+                init_hybla(tp);
 
 	sk->sk_shutdown = 0;
 	sock_reset_flag(sk, SOCK_DONE);
diff -ruN linux-2.6.11-rc4/net/ipv4/tcp_input.c hybla-2.6.11-rc4/net/ipv4/tcp_input.c
--- linux-2.6.11-rc4/net/ipv4/tcp_input.c	2005-02-13 04:07:01.000000000 +0100
+++ hybla-2.6.11-rc4/net/ipv4/tcp_input.c	2005-02-22 13:58:49.000000000 +0100
@@ -62,6 +62,7 @@
  *					engine. Lots of bugs are found.
  *		Pasi Sarolahti:		F-RTO for dealing with spurious RTOs
  *		Angelo Dell'Aera:	TCP Westwood+ support
+ *		Daniele Lacamera:	TCP Hybla Congestion control support
  */
 
 #include <linux/config.h>
@@ -89,6 +90,8 @@
 int sysctl_tcp_nometrics_save;
 int sysctl_tcp_westwood;
 int sysctl_tcp_vegas_cong_avoid;
+int sysctl_tcp_hybla=0;
+int sysctl_tcp_hybla_rtt0=40;
 
 int sysctl_tcp_moderate_rcvbuf = 1;
 
@@ -595,6 +598,29 @@
 	tp->vegas.cntRTT++;
 }
 
+/*
+ * [TCP HYBLA] Update Values, if necessary, when a new
+ * smoothed RTT Estimation becomes available
+ */
+static void hybla_update_rtt(struct tcp_sock *tp, long m)
+{
+        /* This sets rho to the smallest RTT received. */
+        if (tp->srtt!=0){
+                /*  Recalculate rho only if this srtt is the lowest */
+                if (tp->srtt < tp->hybla.minrtt){
+			hybla_recalc_param(tp);
+			/* update minimum rtt */
+			tp->hybla.minrtt = tp->srtt;
+                }
+        } else {
+                /* 1st Rho measurement */
+                hybla_recalc_param(tp);
+                /* set minimum rtt as this is the 1st ever seen */
+                tp->hybla.minrtt = tp->srtt;
+                tp->snd_cwnd=tp->hybla.rho;
+        }
+}
+
 /* Called to compute a smoothed rtt estimate. The data fed to this
  * routine either comes from timestamps, or from segments that were
  * known _not_ to have been retransmitted [see Karn/Partridge
@@ -669,6 +695,8 @@
 	}
 
 	tcp_westwood_update_rtt(tp, tp->srtt >> 3);
+	if(sysctl_tcp_hybla)
+		hybla_update_rtt(tp,mrtt);
 }
 
 /* Calculate rto without backoff.  This is the second half of Van Jacobson's
@@ -808,6 +836,11 @@
 		else
 			cwnd = (tp->mss_cache_std > 1095) ? 3 : 4;
 	}
+	/* Hybla initial Window value set. */
+        if (sysctl_tcp_hybla){
+                hybla_recalc_param(tp);
+                cwnd=max_t(__u32, 2U, tp->hybla.rho);
+        }
 	return min_t(__u32, cwnd, tp->snd_cwnd_clamp);
 }
 
@@ -2322,12 +2355,153 @@
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
+/***
+ ** TCP-HYBLA Congestion control algorithm, based on:
+ **   C.Caini, R.Firrincieli, "TCP-Hybla: A TCP Enhancement
+ **   for Heterogeneous Networks",
+ **   International Journal on satellite Communications,
+ **   					September 2004
+ ***/
+static __inline__ __u32 hybla_slowstart_fraction_increment(__u32 odds){
+	switch (odds) {
+		case 0:
+			return 128;
+		case 1:
+			return 139;
+		case 2:
+			return 152;
+		case 3:
+			return 165;
+		case 4:
+			return 181;
+		case 5:
+			return 197;
+		case 6:
+			return 215;
+		case 7:
+			return 234;
+		default:
+			return 128;
+		
+	}
+}
+static __inline__ void hybla_fractions_cong_avoid(struct tcp_sock *tp)
+{
+	__u32 increment;
+	__u32 odd;
+	__u32 rho_fractions;
+	//__u8 is_slowstart=0;
+	__u32 window, ssthresh;
+	
+	if (tp->hybla.rho==0)
+		hybla_recalc_param(tp);
+	
+	ssthresh = tp->snd_ssthresh;
+	window=tp->snd_cwnd;
+	rho_fractions=tp->hybla.rho_3ls - (tp->hybla.rho << 3);
+	
+	if (window < ssthresh){
+		return;
+	} else {
+		/*** congestion avoidance 	
+		 *** INC = RHO^2 / W		
+		 *** as long as increment is estimated as (rho<<7)/window
+		 *** it already is <<7 and we can easily count its fractions.
+		 ***/	
+		increment =(tp->hybla.rho2_7ls/window);
+		odd = increment % 128;
+		tp->snd_cwnd_cnt++;
+	}
+	tp->hybla.snd_cwnd_cents += odd;
+			
+}
+
+	/* TCP Hybla main routine.
+	 * This is the algorithm behavior:
+	 *	o Recalc Hybla parameters if min_rtt has changed
+	 *	o Give cwnd a new value based on the model proposed
+	 *	o remember increments <1	
+	 */
+static __inline__ void tcp_hybla_cong_avoid(struct tcp_sock *tp)
+{
+	__u32 increment;
+	__u32 odd;
+	__u32 rho_fractions;
+	__u32 window,clamp, ssthresh;
+	__u8 is_slowstart=0;
+	
+	if (tp->hybla.rho==0)
+		hybla_recalc_param(tp);
+	
+	clamp = tp->snd_cwnd_clamp ;
+	window = tp->snd_cwnd;
+	ssthresh = tp->snd_ssthresh;
+	rho_fractions=tp->hybla.rho_3ls - (tp->hybla.rho << 3);
+	
+	if (window < ssthresh){
+		/*** slow start 	
+		 ***	INC = 2^RHO - 1 
+		 *** This is done by splitting the rho parameter
+		 *** into 2 parts: an integer part and a fraction part.
+		 *** Inrement<<7 is estimated by doing:
+		 *** 		[2^(int+fract)]<<7
+		 *** that is equal to:
+		 ***		(2^int)  *  [(2^fract) <<7]
+		 *** 2^int is straightly computed as 1<<int,
+		 *** while we will use hybla_slowstart_fraction_increment() to 
+	 	 *** calculate 2^fract in a <<7 value.
+		 ***/
+		is_slowstart=1;
+		increment =( (1 << tp->hybla.rho) * hybla_slowstart_fraction_increment(rho_fractions) ) - 128;
+		odd = increment % 128;
+		window += (increment >> 7);
+	} else {
+		/*** congestion avoidance 	
+		 *** INC = RHO^2 / W		
+		 *** as long as increment is estimated as (rho<<7)/window
+		 *** it already is <<7 and we can easily count its fractions.
+		 ***/	
+		increment =(tp->hybla.rho2_7ls/window);
+		odd = increment % 128;
+		window += (increment >> 7);
+		
+		if (increment < 128)
+			tp->snd_cwnd_cnt++;
+	}
+	tp->hybla.snd_cwnd_cents += odd;
+	
+		/***
+		 *** check when fractions goes >=128
+		 *** and increase cwnd by 1.
+		 ***/
+	while(	tp->hybla.snd_cwnd_cents >= 128){
+		window++;
+		tp->hybla.snd_cwnd_cents -= 128;
+		tp->snd_cwnd_cnt = 0;
+	}
+		/***
+		 *** clamp down slowstart cwnd to ssthresh value.
+		 ***/
+	if (is_slowstart)
+		window = min_t(__u32, window, ssthresh);
+	
+	tp->snd_cwnd = min_t (__u32, window, clamp);
+	
+	tp->snd_cwnd_stamp=tcp_time_stamp;
+		
+}
+
 static inline void tcp_cong_avoid(struct tcp_sock *tp, u32 ack, u32 seq_rtt)
 {
-	if (tcp_vegas_enabled(tp))
+	if (tcp_vegas_enabled(tp)){
 		vegas_cong_avoid(tp, ack, seq_rtt);
-	else
-		reno_cong_avoid(tp);
+		return;
+	}
+	if (sysctl_tcp_hybla){
+		tcp_hybla_cong_avoid(tp);
+		return;
+	}
+	reno_cong_avoid(tp);
 }
 
 /* Restart timer after forward progress on connection.
diff -ruN linux-2.6.11-rc4/net/ipv4/tcp_ipv4.c hybla-2.6.11-rc4/net/ipv4/tcp_ipv4.c
--- linux-2.6.11-rc4/net/ipv4/tcp_ipv4.c	2005-02-13 04:05:51.000000000 +0100
+++ hybla-2.6.11-rc4/net/ipv4/tcp_ipv4.c	2005-02-22 13:19:02.000000000 +0100
@@ -2055,6 +2055,9 @@
 	 * efficiently to them.  -DaveM
 	 */
 	tp->snd_cwnd = 2;
+	
+	/* Reset hybla parameters on socket initialization.  */
+        init_hybla(tp);
 
 	/* See draft-stevens-tcpca-spec-01 for discussion of the
 	 * initialization of these values.
diff -ruN linux-2.6.11-rc4/net/ipv4/tcp_minisocks.c hybla-2.6.11-rc4/net/ipv4/tcp_minisocks.c
--- linux-2.6.11-rc4/net/ipv4/tcp_minisocks.c	2005-02-13 04:07:01.000000000 +0100
+++ hybla-2.6.11-rc4/net/ipv4/tcp_minisocks.c	2005-02-22 13:17:07.000000000 +0100
@@ -784,6 +784,9 @@
 
 		newtp->dsack = 0;
 		newtp->eff_sacks = 0;
+		
+		/* Reset hybla parameters on socket initialization.  */
+                init_hybla(newtp);
 
 		newtp->probes_out = 0;
 		newtp->num_sacks = 0;

--Boundary-00=_ShSHCpsn9pKjOO8--
