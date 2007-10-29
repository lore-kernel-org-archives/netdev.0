From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 5/5] introduce udp_rmem and udp_wmem
Date: Mon, 29 Oct 2007 17:23:43 -0400
Message-ID: <47264F5F.6040905@redhat.com>
References: <47264E2D.4080109@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090905010503070506070908"
Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56999 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197AbXJ2V27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 17:28:59 -0400
In-Reply-To: <47264E2D.4080109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090905010503070506070908
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch added /proc/sys/net/udp_rmem and /proc/sys/net/udp_rmem.
Each UDP packet is drooped when the number of pages for socket buffer
is beyond the limit and the socket already consumes minimum buffer.

--
Hideo Aoki
Hitachi Computer Products (America) Inc.

--------------090905010503070506070908
Content-Type: text/x-patch;
 name="add_udp_rmem_wmem.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="add_udp_rmem_wmem.patch"


Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
Signed-off-by: Hideo Aoki <haoki@redhat.com>

 Documentation/networking/ip-sysctl.txt |   12 ++++++++++++
 include/net/udp.h                      |    4 ++++
 net/ipv4/ip_output.c                   |    4 +++-
 net/ipv4/sysctl_net_ipv4.c             |   20 ++++++++++++++++++++
 net/ipv4/udp.c                         |   13 +++++++++++--
 5 files changed, 50 insertions(+), 3 deletions(-)

diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p4/Documentation/networking/ip-sysctl.txt linux-2.6.24-rc1-mem003-ipv4-dev-p5/Documentation/networking/ip-sysctl.txt
--- linux-2.6.24-rc1-mem003-ipv4-dev-p4/Documentation/networking/ip-sysctl.txt	2007-10-26 20:35:52.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p5/Documentation/networking/ip-sysctl.txt	2007-10-29 09:44:05.000000000 -0400
@@ -452,6 +452,18 @@ udp_mem - INTEGER
 	Number of pages allowed for queueing by all UDP sockets.
 	Default is calculated at boot time from amount of available memory.
 
+udp_rmem - INTEGER
+	Minimal size of receive buffer used by UDP sockets. Each UDP socket
+	is able to use the size for receiving data, even if total pages of UDP
+	sockets exceed udp_mem. The unit is byte.
+	Default: 4096
+
+udp_wmem - INTEGER
+	Minimal size of send buffer used by UDP sockets. Each UDP socket is
+	able to use the size for sending data, even if total pages of UDP
+	sockets exceed udp_mem. The unit is byte.
+	Default: 4096
+
 CIPSOv4 Variables:
 
 cipso_cache_enable - BOOLEAN
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p4/include/net/udp.h linux-2.6.24-rc1-mem003-ipv4-dev-p5/include/net/udp.h
--- linux-2.6.24-rc1-mem003-ipv4-dev-p4/include/net/udp.h	2007-10-26 20:35:52.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p5/include/net/udp.h	2007-10-29 09:44:05.000000000 -0400
@@ -66,7 +66,11 @@ extern rwlock_t udp_hash_lock;
 extern struct proto udp_prot;
 
 extern atomic_t udp_memory_allocated;
+
+/* sysctl variables for udp */
 extern int sysctl_udp_mem;
+extern int sysctl_udp_rmem;
+extern int sysctl_udp_wmem;
 
 struct sk_buff;
 
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/ip_output.c linux-2.6.24-rc1-mem003-ipv4-dev-p5/net/ipv4/ip_output.c
--- linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/ip_output.c	2007-10-29 09:36:32.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p5/net/ipv4/ip_output.c	2007-10-29 09:44:05.000000000 -0400
@@ -705,7 +705,9 @@ static inline int __ip_check_max_skb_pag
 	switch(sk->sk_protocol) {
 	case IPPROTO_UDP:
 		if (atomic_read(sk->sk_prot->memory_allocated) + size
-		    > sk->sk_prot->sysctl_mem[0])
+		    > sk->sk_prot->sysctl_mem[0] &&
+		    atomic_read(&sk->sk_wmem_alloc) + size
+		    > sk->sk_prot->sysctl_wmem[0])
 			return -ENOBUFS;
 		/* Fall through */	
 	default:
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/sysctl_net_ipv4.c linux-2.6.24-rc1-mem003-ipv4-dev-p5/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/sysctl_net_ipv4.c	2007-10-26 20:35:52.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p5/net/ipv4/sysctl_net_ipv4.c	2007-10-29 09:44:05.000000000 -0400
@@ -896,6 +896,26 @@ ctl_table ipv4_table[] = {
 		.strategy	= &sysctl_intvec,
 		.extra1		= &zero
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "udp_rmem",
+		.data		= &sysctl_udp_rmem,
+		.maxlen		= sizeof(sysctl_udp_rmem),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "udp_wmem",
+		.data		= &sysctl_udp_wmem,
+		.maxlen		= sizeof(sysctl_udp_wmem),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero
+	},
 	{ .ctl_name = 0 }
 };
 
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/udp.c linux-2.6.24-rc1-mem003-ipv4-dev-p5/net/ipv4/udp.c
--- linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/udp.c	2007-10-26 20:35:52.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p5/net/ipv4/udp.c	2007-10-29 09:44:05.000000000 -0400
@@ -117,6 +117,8 @@ DEFINE_RWLOCK(udp_hash_lock);
 
 atomic_t udp_memory_allocated;
 int sysctl_udp_mem __read_mostly;
+int sysctl_udp_rmem __read_mostly;
+int sysctl_udp_wmem __read_mostly;
 
 static inline int __udp_lib_lport_inuse(__u16 num,
 					const struct hlist_head udptable[])
@@ -1026,8 +1028,10 @@ int udp_queue_rcv_skb(struct sock * sk, 
 	}
 
 	if ((atomic_read(sk->sk_prot->memory_allocated)
-		       + sk_datagram_pages(skb->truesize))
-		> sk->sk_prot->sysctl_mem[0]) {
+	     + sk_datagram_pages(skb->truesize))
+	    > sk->sk_prot->sysctl_mem[0] &&
+	    atomic_read(&sk->sk_rmem_alloc) + skb->truesize 
+	    > sk->sk_prot->sysctl_rmem[0]) {
 		UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
 		goto drop;
 	}
@@ -1468,6 +1472,8 @@ struct proto udp_prot = {
 	.get_port	   = udp_v4_get_port,
 	.memory_allocated  = &udp_memory_allocated,
 	.sysctl_mem	   = &sysctl_udp_mem,
+	.sysctl_wmem	   = &sysctl_udp_wmem,
+	.sysctl_rmem	   = &sysctl_udp_rmem,
 	.obj_size	   = sizeof(struct udp_sock),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
@@ -1674,6 +1680,9 @@ void __init udp_init(void)
 	limit = (limit * (nr_all_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
 	limit = max(limit, 128UL);
 	sysctl_udp_mem = limit / 2 * 3;
+
+	sysctl_udp_rmem = SK_DATAGRAM_MEM_QUANTUM;
+	sysctl_udp_wmem = SK_DATAGRAM_MEM_QUANTUM;
 }
 
 EXPORT_SYMBOL(udp_disconnect);

--------------090905010503070506070908--
