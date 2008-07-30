From: akpm@linux-foundation.org
Subject: [patch 04/11] net: configure out IGMP support
Date: Wed, 30 Jul 2008 12:37:36 -0700
Message-ID: <200807301937.m6UJbafn012434@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	thomas.petazzoni@free-electrons.com, mpm@selenic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47148 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753836AbYG3TiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:38:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

tAdd adds the CONFIG_IGMP option which allows to remove support for the
Internet Group Management Protocol, used in multicast.  Multicast is not
necessarly used by applications, particularly on embedded devices.  As
this is a size-reduction option, it depends on CONFIG_EMBEDDED.  It allows
to save ~10 kilobytes of kernel code/data:

   text	   data	    bss	    dec	    hex	filename
1718857	 143672	 221184	2083713	 1fcb81	vmlinux
1708838	 143640	 221184	2073662	 1fa43e	vmlinux.new
 -10019     -32       0  -10051   -2743 +/-

This patch has been originally written by Matt Mackall <mpm@selenic.com>,
and is part of the Linux Tiny project.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Matt Mackall <mpm@selenic.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/igmp.h       |   20 ++++++++++++++++++++
 init/Kconfig               |    8 ++++++++
 net/ipv4/Makefile          |    3 ++-
 net/ipv4/af_inet.c         |    2 --
 net/ipv4/ip_sockglue.c     |    4 ++++
 net/ipv4/sysctl_net_ipv4.c |    2 ++
 6 files changed, 36 insertions(+), 3 deletions(-)

diff -puN include/linux/igmp.h~configure-out-igmp-support include/linux/igmp.h
--- a/include/linux/igmp.h~configure-out-igmp-support
+++ a/include/linux/igmp.h
@@ -215,6 +215,7 @@ struct ip_mc_list
 #define IGMPV3_QQIC(value) IGMPV3_EXP(0x80, 4, 3, value)
 #define IGMPV3_MRC(value) IGMPV3_EXP(0x80, 4, 3, value)
 
+#ifdef CONFIG_IGMP
 extern int ip_check_mc(struct in_device *dev, __be32 mc_addr, __be32 src_addr, u16 proto);
 extern int igmp_rcv(struct sk_buff *);
 extern int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
@@ -235,6 +236,25 @@ extern void ip_mc_down(struct in_device 
 extern void ip_mc_dec_group(struct in_device *in_dev, __be32 addr);
 extern void ip_mc_inc_group(struct in_device *in_dev, __be32 addr);
 extern void ip_mc_rejoin_group(struct ip_mc_list *im);
+#else /* !CONFIG_IGMP */
+#define ip_check_mc(a, b, c, d) (0)
+#define igmp_rcv(a) (0)
+#define ip_mc_join_group(a, b) (0)
+#define ip_mc_leave_group(a, b) (0)
+#define ip_mc_drop_socket(a)
+#define ip_mc_source(a, b, c, d, e) (0)
+#define ip_mc_msfilter(a, b, c) (0)
+#define ip_mc_msfget(a, b, c, d) (0)
+#define ip_mc_gsfget(a, b, c, d) (0)
+#define ip_mc_sf_allow(a, b, c, d) (0)
+#define ip_mc_init_dev(a)
+#define ip_mc_destroy_dev(a)
+#define ip_mc_up(a)
+#define ip_mc_down(a)
+#define ip_mc_dec_group(a)
+#define ip_mc_inc_group(a)
+#define ip_mc_rejoin_group(a)
+#endif /* CONFIG_IGMP */
 
 #endif
 #endif
diff -puN init/Kconfig~configure-out-igmp-support init/Kconfig
--- a/init/Kconfig~configure-out-igmp-support
+++ a/init/Kconfig
@@ -724,6 +724,14 @@ config SHMEM
 	  option replaces shmem and tmpfs with the much simpler ramfs code,
 	  which may be appropriate on small systems without swap.
 
+config IGMP
+	depends on INET
+	bool "Enable IGMP support" if EMBEDDED && !IP_MULTICAST
+	default y
+	help
+	  Disabling this option removes support for the Internet group
+          management protocol, used for multicast. Saves about 10k.
+
 config VM_EVENT_COUNTERS
 	default y
 	bool "Enable VM event counters for /proc/vmstat" if EMBEDDED
diff -puN net/ipv4/Makefile~configure-out-igmp-support net/ipv4/Makefile
--- a/net/ipv4/Makefile~configure-out-igmp-support
+++ a/net/ipv4/Makefile
@@ -9,13 +9,14 @@ obj-y     := route.o inetpeer.o protocol
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
 	     tcp_minisocks.o tcp_cong.o \
 	     datagram.o raw.o udp.o udplite.o \
-	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
+	     arp.o icmp.o devinet.o af_inet.o \
 	     fib_frontend.o fib_semantics.o \
 	     inet_fragment.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_ipv4.o
 obj-$(CONFIG_IP_FIB_HASH) += fib_hash.o
 obj-$(CONFIG_IP_FIB_TRIE) += fib_trie.o
+obj-$(CONFIG_IGMP) += igmp.o
 obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
diff -puN net/ipv4/af_inet.c~configure-out-igmp-support net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c~configure-out-igmp-support
+++ a/net/ipv4/af_inet.c
@@ -115,8 +115,6 @@
 #include <linux/mroute.h>
 #endif
 
-extern void ip_mc_drop_socket(struct sock *sk);
-
 /* The inetsw table contains everything that inet_create needs to
  * build a new socket.
  */
diff -puN net/ipv4/ip_sockglue.c~configure-out-igmp-support net/ipv4/ip_sockglue.c
--- a/net/ipv4/ip_sockglue.c~configure-out-igmp-support
+++ a/net/ipv4/ip_sockglue.c
@@ -640,6 +640,7 @@ static int do_ip_setsockopt(struct sock 
 			err = ip_mc_leave_group(sk, &mreq);
 		break;
 	}
+#ifdef CONFIG_IGMP
 	case IP_MSFILTER:
 	{
 		extern int sysctl_igmp_max_msf;
@@ -677,6 +678,7 @@ static int do_ip_setsockopt(struct sock 
 		kfree(msf);
 		break;
 	}
+#endif
 	case IP_BLOCK_SOURCE:
 	case IP_UNBLOCK_SOURCE:
 	case IP_ADD_SOURCE_MEMBERSHIP:
@@ -794,6 +796,7 @@ static int do_ip_setsockopt(struct sock 
 				   greqs.gsr_interface);
 		break;
 	}
+#ifdef CONFIG_IGMP
 	case MCAST_MSFILTER:
 	{
 		extern int sysctl_igmp_max_msf;
@@ -860,6 +863,7 @@ static int do_ip_setsockopt(struct sock 
 		kfree(gsf);
 		break;
 	}
+#endif
 	case IP_ROUTER_ALERT:
 		err = ip_ra_control(sk, val ? 1 : 0, NULL);
 		break;
diff -puN net/ipv4/sysctl_net_ipv4.c~configure-out-igmp-support net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c~configure-out-igmp-support
+++ a/net/ipv4/sysctl_net_ipv4.c
@@ -412,6 +412,7 @@ static struct ctl_table ipv4_table[] = {
 	},
 
 #endif
+#ifdef CONFIG_IGMP
 	{
 		.ctl_name	= NET_IPV4_IGMP_MAX_MSF,
 		.procname	= "igmp_max_msf",
@@ -420,6 +421,7 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+#endif
 	{
 		.ctl_name	= NET_IPV4_INET_PEER_THRESHOLD,
 		.procname	= "inet_peer_threshold",
_
