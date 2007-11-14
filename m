From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 5/5] add udp_rmem_min and udp_wmem_min
Date: Tue, 13 Nov 2007 21:49:16 -0500
Message-ID: <473A622C.2040401@redhat.com>
References: <473A5FD6.5010209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hideo AOKI <haoki@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754851AbXKNCuj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 21:50:39 -0500
In-Reply-To: <473A5FD6.5010209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch added /proc/sys/net/ipv4/udp_rmem_min and
/proc/sys/net/ipv4/udp_rmem_min. Each UDP packet is drooped when the
number of pages for socket buffer is beyond the limit and the socket
already consumes minimum buffer.

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

  Documentation/networking/ip-sysctl.txt |   12 ++++++++++++
  include/net/udp.h                      |    4 ++++
  net/ipv4/ip_output.c                   |    4 +++-
  net/ipv4/sysctl_net_ipv4.c             |   20 ++++++++++++++++++++
  net/ipv4/udp.c                         |   13 +++++++++++--
  5 files changed, 50 insertions(+), 3 deletions(-)

diff -pruN net-2.6-udp-p4/Documentation/networking/ip-sysctl.txt net-2.6-udp-p5/Documentation/networking/ip-sysctl.txt
--- net-2.6-udp-p4/Documentation/networking/ip-sysctl.txt	2007-11-13 16:12:26.000000000 -0500
+++ net-2.6-udp-p5/Documentation/networking/ip-sysctl.txt	2007-11-13 16:12:35.000000000 -0500
@@ -452,6 +452,18 @@ udp_mem - INTEGER
  	Number of pages allowed for queueing by all UDP sockets.
  	Default is calculated at boot time from amount of available memory.

+udp_rmem_min - INTEGER
+	Minimal size of receive buffer used by UDP sockets. Each UDP socket
+	is able to use the size for receiving data, even if total pages of UDP
+	sockets exceed udp_mem. The unit is byte.
+	Default: 4096
+
+udp_wmem_min - INTEGER
+	Minimal size of send buffer used by UDP sockets. Each UDP socket is
+	able to use the size for sending data, even if total pages of UDP
+	sockets exceed udp_mem. The unit is byte.
+	Default: 4096
+
  CIPSOv4 Variables:

  cipso_cache_enable - BOOLEAN
diff -pruN net-2.6-udp-p4/include/net/udp.h net-2.6-udp-p5/include/net/udp.h
--- net-2.6-udp-p4/include/net/udp.h	2007-11-13 16:12:26.000000000 -0500
+++ net-2.6-udp-p5/include/net/udp.h	2007-11-13 16:12:35.000000000 -0500
@@ -66,7 +66,11 @@ extern rwlock_t udp_hash_lock;
  extern struct proto udp_prot;

  extern atomic_t udp_memory_allocated;
+
+/* sysctl variables for udp */
  extern int sysctl_udp_mem;
+extern int sysctl_udp_rmem_min;
+extern int sysctl_udp_wmem_min;

  struct sk_buff;

diff -pruN net-2.6-udp-p4/net/ipv4/ip_output.c net-2.6-udp-p5/net/ipv4/ip_output.c
--- net-2.6-udp-p4/net/ipv4/ip_output.c	2007-11-13 16:12:26.000000000 -0500
+++ net-2.6-udp-p5/net/ipv4/ip_output.c	2007-11-13 16:12:35.000000000 -0500
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
diff -pruN net-2.6-udp-p4/net/ipv4/sysctl_net_ipv4.c net-2.6-udp-p5/net/ipv4/sysctl_net_ipv4.c
--- net-2.6-udp-p4/net/ipv4/sysctl_net_ipv4.c	2007-11-13 16:12:26.000000000 -0500
+++ net-2.6-udp-p5/net/ipv4/sysctl_net_ipv4.c	2007-11-13 16:12:35.000000000 -0500
@@ -896,6 +896,26 @@ ctl_table ipv4_table[] = {
  		.strategy	= &sysctl_intvec,
  		.extra1		= &zero
  	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "udp_rmem_min",
+		.data		= &sysctl_udp_rmem_min,
+		.maxlen		= sizeof(sysctl_udp_rmem_min),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "udp_wmem_min",
+		.data		= &sysctl_udp_wmem_min,
+		.maxlen		= sizeof(sysctl_udp_wmem_min),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero
+	},
  	{ .ctl_name = 0 }
  };

diff -pruN net-2.6-udp-p4/net/ipv4/udp.c net-2.6-udp-p5/net/ipv4/udp.c
--- net-2.6-udp-p4/net/ipv4/udp.c	2007-11-13 16:12:26.000000000 -0500
+++ net-2.6-udp-p5/net/ipv4/udp.c	2007-11-13 16:12:35.000000000 -0500
@@ -117,6 +117,8 @@ DEFINE_RWLOCK(udp_hash_lock);

  atomic_t udp_memory_allocated;
  int sysctl_udp_mem __read_mostly;
+int sysctl_udp_rmem_min __read_mostly;
+int sysctl_udp_wmem_min __read_mostly;

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
@@ -1470,6 +1474,8 @@ struct proto udp_prot = {
  	.get_port	   = udp_v4_get_port,
  	.memory_allocated  = &udp_memory_allocated,
  	.sysctl_mem	   = &sysctl_udp_mem,
+	.sysctl_wmem	   = &sysctl_udp_wmem_min,
+	.sysctl_rmem	   = &sysctl_udp_rmem_min,
  	.obj_size	   = sizeof(struct udp_sock),
  #ifdef CONFIG_COMPAT
  	.compat_setsockopt = compat_udp_setsockopt,
@@ -1677,6 +1683,9 @@ void __init udp_init(void)
  	limit = (limit * (nr_all_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
  	limit = max(limit, 128UL);
  	sysctl_udp_mem = limit / 2 * 3;
+
+	sysctl_udp_rmem_min = SK_DATAGRAM_MEM_QUANTUM;
+	sysctl_udp_wmem_min = SK_DATAGRAM_MEM_QUANTUM;
  }

  EXPORT_SYMBOL(udp_disconnect);
--
Hideo Aoki
Hitachi Computer Products (America) Inc.
