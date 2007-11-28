From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 3/4] udp: add udp_mem, udp_rmem_min and udp_wmem_min
Date: Wed, 28 Nov 2007 13:53:22 -0500
Message-ID: <474DB922.2040105@redhat.com>
References: <474DB80E.5070403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46552 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756031AbXK1Syj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 13:54:39 -0500
In-Reply-To: <474DB80E.5070403@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds sysctl parameters for customizing UDP memory accounting:
     /proc/sys/net/ipv4/udp_mem
     /proc/sys/net/ipv4/udp_rmem_min
     /proc/sys/net/ipv4/udp_wmem_min

Udp_mem indicates number of pages which can be used for all UDP sockets.
Each UDP packet is dropped, when the number of pages for socket buffer is
beyond udp_mem and the socket already consumes minimum buffer.

This patch is also introduced memory_allocated variable for UDP protocol.

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 Documentation/networking/ip-sysctl.txt |   18 ++++++++++++++++++
 include/net/udp.h                      |    9 +++++++++
 net/ipv4/af_inet.c                     |    3 +++
 net/ipv4/proc.c                        |    3 ++-
 net/ipv4/sysctl_net_ipv4.c             |   31 +++++++++++++++++++++++++++++++
 net/ipv4/udp.c                         |   27 +++++++++++++++++++++++++++
 6 files changed, 90 insertions(+), 1 deletion(-)

diff -pruN net-2.6-udp-take9a2-p2/Documentation/networking/ip-sysctl.txt net-2.6-udp-take9a2-p3/Documentation/networking/ip-sysctl.txt
--- net-2.6-udp-take9a2-p2/Documentation/networking/ip-sysctl.txt	2007-11-14 10:48:49.000000000 -0500
+++ net-2.6-udp-take9a2-p3/Documentation/networking/ip-sysctl.txt	2007-11-28 12:11:02.000000000 -0500
@@ -446,6 +446,24 @@ tcp_dma_copybreak - INTEGER
 	and CONFIG_NET_DMA is enabled.
 	Default: 4096

+UDP variables:
+
+udp_mem - INTEGER
+	Number of pages allowed for queueing by all UDP sockets.
+	Default is calculated at boot time from amount of available memory.
+
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
diff -pruN net-2.6-udp-take9a2-p2/include/net/udp.h net-2.6-udp-take9a2-p3/include/net/udp.h
--- net-2.6-udp-take9a2-p2/include/net/udp.h	2007-11-14 10:49:05.000000000 -0500
+++ net-2.6-udp-take9a2-p3/include/net/udp.h	2007-11-28 12:11:02.000000000 -0500
@@ -65,6 +65,13 @@ extern rwlock_t udp_hash_lock;

 extern struct proto udp_prot;

+extern atomic_t udp_memory_allocated;
+
+/* sysctl variables for udp */
+extern int sysctl_udp_mem;
+extern int sysctl_udp_rmem_min;
+extern int sysctl_udp_wmem_min;
+
 struct sk_buff;

 /*
@@ -173,4 +180,6 @@ extern void udp_proc_unregister(struct u
 extern int  udp4_proc_init(void);
 extern void udp4_proc_exit(void);
 #endif
+
+extern void udp_init(void);
 #endif	/* _UDP_H */
diff -pruN net-2.6-udp-take9a2-p2/net/ipv4/af_inet.c net-2.6-udp-take9a2-p3/net/ipv4/af_inet.c
--- net-2.6-udp-take9a2-p2/net/ipv4/af_inet.c	2007-11-14 10:49:06.000000000 -0500
+++ net-2.6-udp-take9a2-p3/net/ipv4/af_inet.c	2007-11-28 12:11:02.000000000 -0500
@@ -1418,6 +1418,9 @@ static int __init inet_init(void)
 	/* Setup TCP slab cache for open requests. */
 	tcp_init();

+	/* Setup UDP memory threshold */
+	udp_init();
+
 	/* Add UDP-Lite (RFC 3828) */
 	udplite4_register();

diff -pruN net-2.6-udp-take9a2-p2/net/ipv4/proc.c net-2.6-udp-take9a2-p3/net/ipv4/proc.c
--- net-2.6-udp-take9a2-p2/net/ipv4/proc.c	2007-11-14 10:49:07.000000000 -0500
+++ net-2.6-udp-take9a2-p3/net/ipv4/proc.c	2007-11-28 12:11:02.000000000 -0500
@@ -56,7 +56,8 @@ static int sockstat_seq_show(struct seq_
 		   sock_prot_inuse(&tcp_prot), atomic_read(&tcp_orphan_count),
 		   tcp_death_row.tw_count, atomic_read(&tcp_sockets_allocated),
 		   atomic_read(&tcp_memory_allocated));
-	seq_printf(seq, "UDP: inuse %d\n", sock_prot_inuse(&udp_prot));
+	seq_printf(seq, "UDP: inuse %d mem %d\n", sock_prot_inuse(&udp_prot),
+		   atomic_read(&udp_memory_allocated));
 	seq_printf(seq, "UDPLITE: inuse %d\n", sock_prot_inuse(&udplite_prot));
 	seq_printf(seq, "RAW: inuse %d\n", sock_prot_inuse(&raw_prot));
 	seq_printf(seq,  "FRAG: inuse %d memory %d\n",
diff -pruN net-2.6-udp-take9a2-p2/net/ipv4/sysctl_net_ipv4.c net-2.6-udp-take9a2-p3/net/ipv4/sysctl_net_ipv4.c
--- net-2.6-udp-take9a2-p2/net/ipv4/sysctl_net_ipv4.c	2007-11-20 10:29:40.000000000 -0500
+++ net-2.6-udp-take9a2-p3/net/ipv4/sysctl_net_ipv4.c	2007-11-28 12:11:02.000000000 -0500
@@ -18,6 +18,7 @@
 #include <net/ip.h>
 #include <net/route.h>
 #include <net/tcp.h>
+#include <net/udp.h>
 #include <net/cipso_ipv4.h>
 #include <net/inet_frag.h>

@@ -885,6 +886,36 @@ ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "udp_mem",
+		.data		= &sysctl_udp_mem,
+		.maxlen		= sizeof(sysctl_udp_mem),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero
+	},
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

diff -pruN net-2.6-udp-take9a2-p2/net/ipv4/udp.c net-2.6-udp-take9a2-p3/net/ipv4/udp.c
--- net-2.6-udp-take9a2-p2/net/ipv4/udp.c	2007-11-14 10:49:07.000000000 -0500
+++ net-2.6-udp-take9a2-p3/net/ipv4/udp.c	2007-11-28 12:11:02.000000000 -0500
@@ -82,6 +82,7 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
+#include <linux/bootmem.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
 #include <linux/module.h>
@@ -114,6 +115,11 @@ DEFINE_SNMP_STAT(struct udp_mib, udp_sta
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 DEFINE_RWLOCK(udp_hash_lock);

+atomic_t udp_memory_allocated;
+int sysctl_udp_mem __read_mostly;
+int sysctl_udp_rmem_min __read_mostly;
+int sysctl_udp_wmem_min __read_mostly;
+
 static inline int __udp_lib_lport_inuse(__u16 num,
 					const struct hlist_head udptable[])
 {
@@ -1449,6 +1455,10 @@ struct proto udp_prot = {
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
+	.memory_allocated  = &udp_memory_allocated,
+	.sysctl_mem	   = &sysctl_udp_mem,
+	.sysctl_wmem	   = &sysctl_udp_wmem_min,
+	.sysctl_rmem	   = &sysctl_udp_rmem_min,
 	.obj_size	   = sizeof(struct udp_sock),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
@@ -1644,6 +1654,23 @@ void udp4_proc_exit(void)
 }
 #endif /* CONFIG_PROC_FS */

+void __init udp_init(void)
+{
+	unsigned long limit;
+
+	/* Set the pressure threshold up by the same strategy of TCP. It is a
+	 * fraction of global memory that is up to 1/2 at 256 MB, decreasing
+	 * toward zero with the amount of memory, with a floor of 128 pages.
+	 */
+	limit = min(nr_all_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
+	limit = (limit * (nr_all_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
+	limit = max(limit, 128UL);
+	sysctl_udp_mem = limit / 2 * 3;
+
+	sysctl_udp_rmem_min = SK_DATAGRAM_MEM_QUANTUM;
+	sysctl_udp_wmem_min = SK_DATAGRAM_MEM_QUANTUM;
+}
+
 EXPORT_SYMBOL(udp_disconnect);
 EXPORT_SYMBOL(udp_hash);
 EXPORT_SYMBOL(udp_hash_lock);
-- 
Hitachi Computer Products (America) Inc.
