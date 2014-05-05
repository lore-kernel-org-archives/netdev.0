From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 15/24] net, diet: Make igmp and mcast ioctls depend on IP_MULTICAST
Date: Mon,  5 May 2014 15:26:04 -0700
Message-ID: <1399328773-6531-16-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

There was already a CONFIG_IP_MULTICAST, but it didn't control
the multicasting code (like igmp) in the IP stack, only some
driver code.  Change this.

This disables some multi cast filters in TCP/UDP too, but
that should be ok because we never joing multicast groups
without this options, so the packets should never arrive up-stack.

Worth ~20k when disabled

   text	   data	    bss	    dec	    hex	filename
 420363	  17509	  11624	 449496	  6dbd8	net/built-in.o-with-mcast
 399649	  17381	  11624	 428654	  68a6e	net/built-in.o-wo-mcast

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/igmp.h       | 31 +++++++++++++++++++++++--------
 net/ipv4/Kconfig           |  8 +++-----
 net/ipv4/Makefile          |  3 ++-
 net/ipv4/devinet.c         |  2 ++
 net/ipv4/ip_sockglue.c     |  4 ++++
 net/ipv4/sysctl_net_ipv4.c |  2 ++
 6 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index f47550d..1a1a044 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -108,11 +108,7 @@ struct ip_mc_list {
 #define IGMPV3_QQIC(value) IGMPV3_EXP(0x80, 4, 3, value)
 #define IGMPV3_MRC(value) IGMPV3_EXP(0x80, 4, 3, value)
 
-extern int ip_check_mc_rcu(struct in_device *dev, __be32 mc_addr, __be32 src_addr, u16 proto);
 extern int igmp_rcv(struct sk_buff *);
-extern int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
-extern int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr);
-extern void ip_mc_drop_socket(struct sock *sk);
 extern int ip_mc_source(int add, int omode, struct sock *sk,
 		struct ip_mreq_source *mreqs, int ifindex);
 extern int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf,int ifindex);
@@ -120,14 +116,33 @@ extern int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 		struct ip_msfilter __user *optval, int __user *optlen);
 extern int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 		struct group_filter __user *optval, int __user *optlen);
-extern int ip_mc_sf_allow(struct sock *sk, __be32 local, __be32 rmt, int dif);
-extern void ip_mc_init_dev(struct in_device *);
-extern void ip_mc_destroy_dev(struct in_device *);
-extern void ip_mc_up(struct in_device *);
 extern void ip_mc_down(struct in_device *);
 extern void ip_mc_unmap(struct in_device *);
 extern void ip_mc_remap(struct in_device *);
 extern void ip_mc_dec_group(struct in_device *in_dev, __be32 addr);
 extern void ip_mc_inc_group(struct in_device *in_dev, __be32 addr);
 
+#ifdef CONFIG_IP_MULTICAST
+extern int ip_mc_sf_allow(struct sock *sk, __be32 local, __be32 rmt, int dif);
+extern int ip_check_mc_rcu(struct in_device *dev, __be32 mc_addr, __be32 src_addr, u16 proto);
+extern void ip_mc_up(struct in_device *);
+extern void ip_mc_destroy_dev(struct in_device *);
+extern void ip_mc_init_dev(struct in_device *);
+extern void ip_mc_drop_socket(struct sock *sk);
+extern int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
+extern int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr);
+#else
+static inline int ip_mc_sf_allow(struct sock *sk, __be32 local, __be32 rmt, int dif)
+{ return 0; }
+static inline int ip_check_mc_rcu(struct in_device *dev, __be32 mc_addr, __be32 src_addr, u16 proto)
+{ return 0; }
+static inline void ip_mc_up(struct in_device *d) {}
+static inline void ip_mc_destroy_dev(struct in_device *d) {}
+static inline void ip_mc_init_dev(struct in_device *d) {}
+static inline void ip_mc_drop_socket(struct sock *sk) {}
+static inline int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr)
+{ return -EINVAL; }
+static inline int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
+{ return -EINVAL; }
+#endif
 #endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 00a7f76..c1f9899 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -5,11 +5,9 @@ config IP_MULTICAST
 	bool "IP: multicasting"
 	help
 	  This is code for addressing several networked computers at once,
-	  enlarging your kernel by about 2 KB. You need multicasting if you
-	  intend to participate in the MBONE, a high bandwidth network on top
-	  of the Internet which carries audio and video broadcasts. More
-	  information about the MBONE is on the WWW at
-	  <http://www.savetz.com/mbone/>. For most people, it's safe to say N.
+	  enlarging your kernel by about 20 KB. This is needed for many
+	  modern networking services on the local network, so you should
+	  probably say Y.
 
 config IP_ADVANCED_ROUTER
 	bool "IP: advanced router"
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 784a782..eb129a4 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -9,7 +9,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
 	     tcp_minisocks.o tcp_cong.o tcp_fastopen.o \
 	     datagram.o raw.o udp.o udplite.o \
-	     arp.o icmp.o devinet.o af_inet.o igmp.o \
+	     arp.o icmp.o devinet.o af_inet.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
 	     inet_fragment.o ip_tunnel_core.o gre_offload.o
 
@@ -37,6 +37,7 @@ obj-$(CONFIG_INET_TUNNEL) += tunnel4.o
 obj-$(CONFIG_INET_XFRM_MODE_TRANSPORT) += xfrm4_mode_transport.o
 obj-$(CONFIG_INET_XFRM_MODE_TUNNEL) += xfrm4_mode_tunnel.o
 obj-$(CONFIG_IP_PNP) += ipconfig.o
+obj-$(CONFIG_IP_MULTICAST) += igmp.o
 obj-$(CONFIG_NETFILTER)	+= netfilter.o netfilter/
 obj-$(CONFIG_INET_DIAG) += inet_diag.o 
 obj-$(CONFIG_INET_TCP_DIAG) += tcp_diag.o
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index bdbf68b..c19266d 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1402,6 +1402,7 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 		/* Send gratuitous ARP to notify of link change */
 		inetdev_send_gratuitous_arp(dev, in_dev);
 		break;
+#ifdef CONFIG_IP_MULTICAST
 	case NETDEV_DOWN:
 		ip_mc_down(in_dev);
 		break;
@@ -1411,6 +1412,7 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	case NETDEV_POST_TYPE_CHANGE:
 		ip_mc_remap(in_dev);
 		break;
+#endif
 	case NETDEV_CHANGEMTU:
 		if (inetdev_valid_mtu(dev->mtu))
 			break;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 64741b9..ed5c7bd 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -652,6 +652,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		if (!val)
 			skb_queue_purge(&sk->sk_error_queue);
 		break;
+#ifdef CONFIG_IP_MULTICAST
 	case IP_MULTICAST_TTL:
 		if (sk->sk_type == SOCK_STREAM)
 			goto e_inval;
@@ -1010,6 +1011,7 @@ mc_msf_out:
 			goto e_inval;
 		inet->mc_all = val;
 		break;
+#endif
 	case IP_ROUTER_ALERT:
 		err = ip_ra_control(sk, val ? 1 : 0, NULL);
 		break;
@@ -1248,6 +1250,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_RECVERR:
 		val = inet->recverr;
 		break;
+#ifdef CONFIG_IP_MULTICAST
 	case IP_MULTICAST_TTL:
 		val = inet->mc_ttl;
 		break;
@@ -1310,6 +1313,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_MULTICAST_ALL:
 		val = inet->mc_all;
 		break;
+#endif
 	case IP_PKTOPTIONS:
 	{
 		struct msghdr msg;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 2110d2e..fe5823a 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -443,6 +443,7 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_do_large_bitmap,
 	},
+#ifdef CONFIG_IP_MULTICAST
 	{
 		.procname	= "igmp_max_memberships",
 		.data		= &sysctl_igmp_max_memberships,
@@ -457,6 +458,7 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+#endif
 	{
 		.procname	= "inet_peer_threshold",
 		.data		= &inet_peer_threshold,
-- 
1.9.0
