From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [PATCH 2.6.5] Re: Fw: Stack sends SYN/ACKs even though accept queue
 is full
Date: Fri, 30 Apr 2004 17:09:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4092EAD7.5080207@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jan Olderdissen <jan@ixiacom.com>,
        David Miller <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:

>Begin forwarded message:
>
>Date: Thu, 29 Apr 2004 14:53:36 -0700
>From: Jan Olderdissen <jan@ixiacom.com>
>To: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>
>Subject: Stack sends SYN/ACKs even though accept queue is full
>
Attaching a patch which adds a sysctl to turn off this
behaviour.   Could you test this, please?  Patch against
2.6.5 vanilla kernel.  If you need a 2.4 version, let me
know.

>Because newly accepted connections are considered 'young', two such
>connections put on the synq will cause additional SYNs to be dropped until
>young connections age and additional connections are SYN/ACKed , etc. Since
>the initial TCP timeout is three seconds, you would expect two additional
>connections to be accepted every three seconds. However, experiments with
>2.4.25 show that number to be two connections every four seconds for unclear
>reasons.
>
Normally, I think the expected behaviour was that connections
would be short-lived. This is a reasonable expectation for most
web-servers etc.   In which case, the accept queue would free
up frequently, and having the syn request right there would save
a full timeout and round trip over the Internet. i.e. useful in the
common case.

I don't think it is worthwhile for environments where connections
are long-lived and turnover is infrequent, added to a heavily
congested network.   I'd prefer to have this be a tunable option.

thanks,
Nivedita

diff -urN linux-2.6.5/include/linux/sysctl.h
linux-2.6.5synq/include/linux/sysctl.h
--- linux-2.6.5/include/linux/sysctl.h	2004-04-03 19:37:23.000000000
-0800
+++ linux-2.6.5synq/include/linux/sysctl.h	2004-04-30 15:24:12.000000000
-0700
@@ -323,6 +323,7 @@
 	NET_IPV4_IPFRAG_SECRET_INTERVAL=94,
 	NET_TCP_WESTWOOD=95,
 	NET_IPV4_IGMP_MAX_MSF=96,
+	NET_TCP_PRELOAD_SYNQ=97,
 };
 
 enum {
diff -urN linux-2.6.5/include/net/tcp.h
linux-2.6.5synq/include/net/tcp.h
--- linux-2.6.5/include/net/tcp.h	2004-04-03 19:36:18.000000000 -0800
+++ linux-2.6.5synq/include/net/tcp.h	2004-04-30 13:55:18.000000000
-0700
@@ -583,6 +583,7 @@
 extern int sysctl_tcp_frto;
 extern int sysctl_tcp_low_latency;
 extern int sysctl_tcp_westwood;
+extern int sysctl_tcp_preload_synq;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
diff -urN linux-2.6.5/net/ipv4/sysctl_net_ipv4.c
linux-2.6.5synq/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6.5/net/ipv4/sysctl_net_ipv4.c	2004-04-03 19:37:37.000000000
-0800
+++ linux-2.6.5synq/net/ipv4/sysctl_net_ipv4.c	2004-04-30
16:16:57.000000000 -0700
@@ -601,6 +601,14 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_TCP_PRELOAD_SYNQ, 
+		.procname	= "tcp_preload_synq",
+		.data		= &sysctl_tcp_preload_synq,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
diff -urN linux-2.6.5/net/ipv4/tcp_ipv4.c
linux-2.6.5synq/net/ipv4/tcp_ipv4.c
--- linux-2.6.5/net/ipv4/tcp_ipv4.c	2004-04-03 19:36:55.000000000 -0800
+++ linux-2.6.5synq/net/ipv4/tcp_ipv4.c	2004-04-30 15:51:38.000000000
-0700
@@ -78,6 +78,7 @@
 extern int sysctl_ip_dynaddr;
 int sysctl_tcp_tw_reuse;
 int sysctl_tcp_low_latency;
+int sysctl_tcp_preload_synq = 1;
 
 /* Check TCP sequence numbers in ICMP packets. */
 #define ICMP_MIN_LENGTH 8
@@ -1442,8 +1443,11 @@
 	 * clogging syn queue with openreqs with exponentially increasing
 	 * timeout.
 	 */
-	if (tcp_acceptq_is_full(sk) && tcp_synq_young(sk) > 1)
-		goto drop;
+	if (tcp_acceptq_is_full(sk)) {
+		if (!sysctl_tcp_preload_synq ||
+		   (sysctl_tcp_preload_synq && (tcp_synq_young(sk) > 1)))
+			goto drop;
+	}
 
 	req = tcp_openreq_alloc();
 	if (!req)
@@ -2683,4 +2687,5 @@
 EXPORT_SYMBOL(sysctl_local_port_range);
 EXPORT_SYMBOL(sysctl_max_syn_backlog);
 EXPORT_SYMBOL(sysctl_tcp_low_latency);
+EXPORT_SYMBOL(sysctl_tcp_preload_synq);
 #endif
