From: "Jun.Kondo" <jun.kondo@ctc-g.co.jp>
Subject: [PATCH] net: configurable sysctl parameter "net.core.tcp_lowat" for
 sk_stream_min_wspace()
Date: Mon, 15 Aug 2011 14:38:11 +0900
Message-ID: <4E48B0C3.2010203@ctc-g.co.jp>
Reply-To: jun.kondo@ctc-g.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "omega-g1@ctc-g.co.jp" <omega-g1@ctc-g.co.jp>, notsuki@redhat.com,
	"Kozaki, Motokazu" <motokazu.kozaki@hp.com>,
	Hajime Taira <htaira@redhat.com>, netdev@vger.kernel.org,
	TomohikoTAKAHASHI <tomohiko.takahashi@ctc-g.co.jp>,
	Kotaro Sakai <kotaro.sakai@ctc-g.co.jp>,
	ken sugawara <ken.sugawara@ctc-g.co.jp>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CTC had the following demand;

1. to ensure high throughput from the beginning of
tcp connection at normal times by acquiring large
default transmission buffer value

2. to limit the block time of the write in order to
prevent the timeout of upper layer applications
even when the connection has low throughput, such
as low rate streaming


The root of the issue;

2 can not be achieved with the configuration that
satisfies 1.

The current behavior is as follows;

Write is blocked when tcp transmission buffer (wmem)
becomes full.
In order to write again after that, one third of the
transmission buffer (sk_wmem_queued/2) must be freed.

When the throughput is low, timeout occurs by the time
when the free buffer space is created, which affects
streaming service.


The effect of the patch;

By putting xxx into the variable yyy, the portion of
the transmission buffer becomes zzz, thus timeout will
not occur in the low throughput network environment.

xxx → integer(e.g. 4)
yyy → "sysctl_tcp_lowat"
zzz → "sk_wmem_queued >> 4"

Also, we think one third of the transmission buffer
(sk_wmem_queued/2) is too deterministic, and it should
be configurable.

--------------------------------------------------
--- linux-mainline/include/net/sock.h.orig	2011-07-27 14:26:43.000000000 +0900
+++ linux-mainline/include/net/sock.h	2011-08-15 11:40:20.000000000 +0900
@@ -604,9 +604,11 @@ static inline int sk_acceptq_is_full(str
 /*
  * Compute minimal free write space needed to queue new packets.
  */
+extern __u32 sysctl_tcp_lowat;
+
 static inline int sk_stream_min_wspace(struct sock *sk)
 {
-	return sk->sk_wmem_queued >> 1;
+	return sk->sk_wmem_queued >> sysctl_tcp_lowat;
 }
 
 static inline int sk_stream_wspace(struct sock *sk)
--- linux-mainline/net/core/sock.c.orig	2011-07-24 05:04:06.000000000 +0900
+++ linux-mainline/net/core/sock.c	2011-08-15 11:34:27.000000000 +0900
@@ -217,6 +217,9 @@ __u32 sysctl_rmem_max __read_mostly = SK
 __u32 sysctl_wmem_default __read_mostly = SK_WMEM_MAX;
 __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 
+__u32 sysctl_tcp_lowat = 1;
+EXPORT_SYMBOL(sysctl_tcp_lowat);
+
 /* Maximal space eaten by iovec or ancillary data plus some space */
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
@@ -1330,6 +1333,8 @@ void __init sk_init(void)
 		sysctl_wmem_max = 131071;
 		sysctl_rmem_max = 131071;
 	}
+
+	sysctl_tcp_lowat = 1;
 }
 
 /*
--- linux-mainline/net/core/sysctl_net_core.c.orig	2011-05-29 06:01:16.000000000 +0900
+++ linux-mainline/net/core/sysctl_net_core.c	2011-08-15 11:05:38.000000000 +0900
@@ -168,6 +168,13 @@ static struct ctl_table net_core_table[]
 		.proc_handler	= rps_sock_flow_sysctl
 	},
 #endif
+	{
+		.procname	= "tcp_lowat",
+		.data		= &sysctl_tcp_lowat,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
 #endif /* CONFIG_NET */
 	{
 		.procname	= "netdev_budget",

--------------------------------------------------

------------------------------------------
Jun.Kondo
ITOCHU TECHNO-SOLUTIONS Corporation(CTC)
tel:+81-3-6238-6607
fax:+81-3-5226-2369
------------------------------------------
