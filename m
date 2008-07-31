From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [patch 4/4] Configure out IGMP support
Date: Thu, 31 Jul 2008 11:27:07 +0200
Message-ID: <20080731093221.565015353@free-electrons.com>
References: <20080731092703.661994657@free-electrons.com>
Cc: michael@free-electrons.com,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Matt Mackall <mpm@selenic.com>, netdev@vger.kernel.org,
	davem@davemloft.net, akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org
Return-path: <linux-embedded-owner@vger.kernel.org>
Content-Disposition: inline; filename=configure-out-igmp-support
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchs adds the CONFIG_IGMP option which allows to remove support
for the Internet Group Management Protocol, used in
multicast. Multicast is not necessarly used by applications,
particularly on embedded devices. As this is a size-reduction option,
it depends on CONFIG_EMBEDDED. It allows to save ~10 kilobytes of
kernel code/data:

   text	   data	    bss	    dec	    hex	filename
1718857	 143672	 221184	2083713	 1fcb81	vmlinux
1708838	 143640	 221184	2073662	 1fa43e	vmlinux.new
 -10019     -32       0  -10051   -2743 +/-

This patch has been originally written by Matt Mackall
<mpm@selenic.com>, and is part of the Linux Tiny project.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Signed-off-by: Matt Mackall <mpm@selenic.com>
Cc: netdev@vger.kernel.org
Cc: davem@davemloft.net
Cc: mpm@selenic.com
Cc: akpm@linux-foundation.org

---
 include/linux/igmp.h       |   20 ++++++++++++++++++++
 init/Kconfig               |    8 ++++++++
 net/ipv4/Makefile          |    3 ++-
 net/ipv4/af_inet.c         |    2 --
 net/ipv4/ip_sockglue.c     |    4 ++++
 net/ipv4/sysctl_net_ipv4.c |    2 ++
 6 files changed, 36 insertions(+), 3 deletions(-)

Index: linuxdev/include/linux/igmp.h
===================================================================
--- linuxdev.orig/include/linux/igmp.h
+++ linuxdev/include/linux/igmp.h
@@ -215,6 +215,7 @@
 #define IGMPV3_QQIC(value) IGMPV3_EXP(0x80, 4, 3, value)
 #define IGMPV3_MRC(value) IGMPV3_EXP(0x80, 4, 3, value)
 
+#ifdef CONFIG_IGMP
 extern int ip_check_mc(struct in_device *dev, __be32 mc_addr, __be32 src_addr, u16 proto);
 extern int igmp_rcv(struct sk_buff *);
 extern int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
@@ -235,6 +236,25 @@
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
Index: linuxdev/init/Kconfig
===================================================================
--- linuxdev.orig/init/Kconfig
+++ linuxdev/init/Kconfig
@@ -748,6 +748,14 @@
 	  Disabling this option removes support for configuring
 	  ethernet device features via ethtool. Saves about 6k.
 
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
Index: linuxdev/net/ipv4/Makefile
===================================================================
--- linuxdev.orig/net/ipv4/Makefile
+++ linuxdev/net/ipv4/Makefile
@@ -9,13 +9,14 @@
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
Index: linuxdev/net/ipv4/af_inet.c
===================================================================
--- linuxdev.orig/net/ipv4/af_inet.c
+++ linuxdev/net/ipv4/af_inet.c
@@ -115,8 +115,6 @@
 #include <linux/mroute.h>
 #endif
 
-extern void ip_mc_drop_socket(struct sock *sk);
-
 /* The inetsw table contains everything that inet_create needs to
  * build a new socket.
  */
Index: linuxdev/net/ipv4/ip_sockglue.c
===================================================================
--- linuxdev.orig/net/ipv4/ip_sockglue.c
+++ linuxdev/net/ipv4/ip_sockglue.c
@@ -640,6 +640,7 @@
 			err = ip_mc_leave_group(sk, &mreq);
 		break;
 	}
+#ifdef CONFIG_IGMP
 	case IP_MSFILTER:
 	{
 		extern int sysctl_igmp_max_msf;
@@ -677,6 +678,7 @@
 		kfree(msf);
 		break;
 	}
+#endif
 	case IP_BLOCK_SOURCE:
 	case IP_UNBLOCK_SOURCE:
 	case IP_ADD_SOURCE_MEMBERSHIP:
@@ -794,6 +796,7 @@
 				   greqs.gsr_interface);
 		break;
 	}
+#ifdef CONFIG_IGMP
 	case MCAST_MSFILTER:
 	{
 		extern int sysctl_igmp_max_msf;
@@ -860,6 +863,7 @@
 		kfree(gsf);
 		break;
 	}
+#endif
 	case IP_ROUTER_ALERT:
 		err = ip_ra_control(sk, val ? 1 : 0, NULL);
 		break;
Index: linuxdev/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- linuxdev.orig/net/ipv4/sysctl_net_ipv4.c
+++ linuxdev/net/ipv4/sysctl_net_ipv4.c
@@ -412,6 +412,7 @@
 	},
 
 #endif
+#ifdef CONFIG_IGMP
 	{
 		.ctl_name	= NET_IPV4_IGMP_MAX_MSF,
 		.procname	= "igmp_max_msf",
@@ -420,6 +421,7 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+#endif
 	{
 		.ctl_name	= NET_IPV4_INET_PEER_THRESHOLD,
 		.procname	= "inet_peer_threshold",

-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers and embedded Linux development,
consulting, training and support.
http://free-electrons.com
