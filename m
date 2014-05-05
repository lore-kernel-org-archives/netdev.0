From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 18/24] net, diet: Make raw sockets optional
Date: Mon,  5 May 2014 15:26:07 -0700
Message-ID: <1399328773-6531-19-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Not really needed on small embedded systems.  Saves about 5k text,
more with IPv6.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/net/ip.h        |  5 +++++
 include/net/ipv6.h      |  5 +++++
 include/net/raw.h       | 15 +++++++++------
 include/net/rawv6.h     |  8 ++++++++
 include/net/transp_v6.h |  5 +++++
 net/ipv4/Kconfig        |  5 +++++
 net/ipv4/Makefile       |  3 ++-
 net/ipv4/af_inet.c      |  8 ++++++++
 net/ipv4/ip_input.c     |  2 ++
 net/ipv4/proc.c         |  2 ++
 net/ipv6/Kconfig        |  1 +
 net/ipv6/Makefile       |  3 ++-
 net/ipv6/af_inet6.c     |  4 ++++
 net/ipv6/ip6_output.c   |  4 ++++
 net/ipv6/proc.c         |  2 ++
 15 files changed, 64 insertions(+), 8 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 6764e30..bc878f3 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -445,7 +445,12 @@ static inline int sk_mc_loop(struct sock *sk)
 	return 1;
 }
 
+#ifdef CONFIG_INET_RAW
 bool ip_call_ra_chain(struct sk_buff *skb);
+#else
+static inline bool ip_call_ra_chain(struct sk_buff *skb)
+{ return false; }
+#endif
 
 /*
  *	Functions provided by ip_fragment.c
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 3c4c041..f4dae3a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -822,8 +822,13 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 #ifdef CONFIG_PROC_FS
 int ac6_proc_init(struct net *net);
 void ac6_proc_exit(struct net *net);
+#ifdef CONFIG_INET_RAW
 int raw6_proc_init(void);
 void raw6_proc_exit(void);
+#else
+static inline int raw6_proc_init(void) { return 0; }
+static inline void raw6_proc_exit(void) {}
+#endif
 int tcp6_proc_init(struct net *net);
 void tcp6_proc_exit(struct net *net);
 int udp6_proc_init(struct net *net);
diff --git a/include/net/raw.h b/include/net/raw.h
index 6a40c65..5ece765 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -23,8 +23,17 @@
 
 extern struct proto raw_prot;
 
+#ifdef CONFIG_INET_RAW
 void raw_icmp_error(struct sk_buff *, int, u32);
 int raw_local_deliver(struct sk_buff *, int);
+int raw_proc_init(void);
+void raw_proc_exit(void);
+#else
+static inline void raw_icmp_error(struct sk_buff *skb, int a, u32 b) {}
+static inline int raw_local_deliver(struct sk_buff *skb, int s) { return 0; }
+static inline int raw_proc_init(void) { return 0; }
+static inline void raw_proc_exit(void) {}
+#endif
 
 int raw_rcv(struct sock *, struct sk_buff *);
 
@@ -35,10 +44,6 @@ struct raw_hashinfo {
 	struct hlist_head ht[RAW_HTABLE_SIZE];
 };
 
-#ifdef CONFIG_PROC_FS
-int raw_proc_init(void);
-void raw_proc_exit(void);
-
 struct raw_iter_state {
 	struct seq_net_private p;
 	int bucket;
@@ -55,8 +60,6 @@ void raw_seq_stop(struct seq_file *seq, void *v);
 int raw_seq_open(struct inode *ino, struct file *file,
 		 struct raw_hashinfo *h, const struct seq_operations *ops);
 
-#endif
-
 void raw_hash_sk(struct sock *sk);
 void raw_unhash_sk(struct sock *sk);
 
diff --git a/include/net/rawv6.h b/include/net/rawv6.h
index 87783de..acb81dc 100644
--- a/include/net/rawv6.h
+++ b/include/net/rawv6.h
@@ -3,9 +3,17 @@
 
 #include <net/protocol.h>
 
+
+#ifdef CONFIG_INET_RAW
 void raw6_icmp_error(struct sk_buff *, int nexthdr,
 		u8 type, u8 code, int inner_offset, __be32);
 bool raw6_local_deliver(struct sk_buff *, int);
+#else
+static inline void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
+		u8 type, u8 code, int inner_offset, __be32 x) {}
+static inline bool raw6_local_deliver(struct sk_buff *skb, int x)
+{ return false; }
+#endif
 
 int rawv6_rcv(struct sock *sk, struct sk_buff *skb);
 
diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 7a0e229..801267c 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -19,8 +19,13 @@ int ipv6_frag_init(void);
 void ipv6_frag_exit(void);
 
 /* transport protocols */
+#ifdef CONFIG_INET_RAW
 int rawv6_init(void);
 void rawv6_exit(void);
+#else
+static inline int rawv6_init(void) { return 0; }
+static inline void rawv6_exit(void) {}
+#endif
 int udpv6_init(void);
 void udpv6_exit(void);
 int udplitev6_init(void);
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index df5c569..cdb4f57 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -62,6 +62,10 @@ config IP_FIB_TRIE_STATS
 	  Keep track of statistics on structure of FIB TRIE table.
 	  Useful for testing and measuring TRIE performance.
 
+config INET_RAW
+       bool "IP: Support raw sockets"
+       default y
+
 config IP_MULTIPLE_TABLES
 	bool "IP: policy routing"
 	depends on IP_ADVANCED_ROUTER
@@ -218,6 +222,7 @@ config NET_IPGRE_BROADCAST
 config IP_MROUTE
 	bool "IP: multicast routing"
 	depends on IP_MULTICAST
+	select INET_RAW
 	help
 	  This is used if you want your machine to act as a router for IP
 	  packets that have several destination addresses. It is needed on the
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index addecef..9353beb 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -8,7 +8,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     inet_timewait_sock.o inet_connection_sock.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
 	     tcp_minisocks.o tcp_cong.o \
-	     datagram.o raw.o udp.o udplite.o \
+	     datagram.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
 	     inet_fragment.o ip_tunnel_core.o gre_offload.o
@@ -58,6 +58,7 @@ obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
 obj-$(CONFIG_TCP_FASTOPEN) += tcp_fastopen.o
 obj-$(CONFIG_MEMCG_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
+obj-$(CONFIG_INET_RAW) += raw.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o xfrm4_protocol.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 46b1815..cdcf1e8 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -956,6 +956,7 @@ const struct proto_ops inet_dgram_ops = {
 };
 EXPORT_SYMBOL(inet_dgram_ops);
 
+#ifdef CONFIG_INET_RAW
 /*
  * For SOCK_RAW sockets; should be the same as inet_dgram_ops but without
  * udp_poll
@@ -985,6 +986,7 @@ static const struct proto_ops inet_sockraw_ops = {
 	.compat_ioctl	   = inet_compat_ioctl,
 #endif
 };
+#endif
 
 static const struct net_proto_family inet_family_ops = {
 	.family = PF_INET,
@@ -1026,6 +1028,7 @@ static struct inet_protosw inetsw_array[] =
        },
 #endif
 
+#ifdef CONFIG_INET_RAW
        {
 	       .type =       SOCK_RAW,
 	       .protocol =   IPPROTO_IP,	/* wild card */
@@ -1034,6 +1037,7 @@ static struct inet_protosw inetsw_array[] =
 	       .no_check =   UDP_CSUM_DEFAULT,
 	       .flags =      INET_PROTOSW_REUSE,
        }
+#endif
 };
 
 #define INETSW_ARRAY_LEN ARRAY_SIZE(inetsw_array)
@@ -1737,9 +1741,11 @@ static int __init inet_init(void)
 	if (rc)
 		goto out_unregister_tcp_proto;
 
+#ifdef CONFIG_INET_RAW
 	rc = proto_register(&raw_prot, 1);
 	if (rc)
 		goto out_unregister_udp_proto;
+#endif
 
 #ifdef CONFIG_IP_PING
 	rc = proto_register(&ping_prot, 1);
@@ -1835,8 +1841,10 @@ static int __init inet_init(void)
 out:
 	return rc;
 out_unregister_raw_proto:
+#ifdef CONFIG_INET_RAW
 	proto_unregister(&raw_prot);
 out_unregister_udp_proto:
+#endif
 	proto_unregister(&udp_prot);
 out_unregister_tcp_proto:
 	proto_unregister(&tcp_prot);
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 3d4da2c..8497bc1 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -147,6 +147,7 @@
 #include <linux/mroute.h>
 #include <linux/netlink.h>
 
+#ifdef CONFIG_INET_RAW
 /*
  *	Process Router Attention IP option (RFC 2113)
  */
@@ -186,6 +187,7 @@ bool ip_call_ra_chain(struct sk_buff *skb)
 	}
 	return false;
 }
+#endif
 
 static int ip_local_deliver_finish(struct sk_buff *skb)
 {
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index ad737fa..5f040eb 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -69,8 +69,10 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 		   proto_memory_allocated(&udp_prot));
 	seq_printf(seq, "UDPLITE: inuse %d\n",
 		   sock_prot_inuse_get(net, &udplite_prot));
+#ifdef CONFIG_INET_RAW
 	seq_printf(seq, "RAW: inuse %d\n",
 		   sock_prot_inuse_get(net, &raw_prot));
+#endif
 	seq_printf(seq,  "FRAG: inuse %d memory %d\n",
 			ip_frag_nqueues(net), ip_frag_mem(net));
 	return 0;
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 438a73a..bb3ffec 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -88,6 +88,7 @@ config INET6_IPCOMP
 config IPV6_MIP6
 	tristate "IPv6: Mobility"
 	select XFRM
+	select INET_RAW
 	---help---
 	  Support for IPv6 Mobility described in RFC 3775.
 
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 7ce7aa0..19f0e00 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -7,13 +7,14 @@ obj-$(CONFIG_IPV6) += ipv6.o
 ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		addrlabel.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
-		raw.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
+		icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o
 
 ipv6-offload-$(CONFIG_IP_OFFLOAD) := ip6_offload.o tcpv6_offload.o \
 		udp_offload.o exthdrs_offload.o
 
 ipv6-$(CONFIG_SYSCTL) = sysctl_net_ipv6.o
+ipv6-$(CONFIG_INET_RAW) += raw.o
 ipv6-$(CONFIG_IPV6_MROUTE) += ip6mr.o
 ipv6-$(CONFIG_IP_PING) += ping.o
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 327042a..fc36df6 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -865,9 +865,11 @@ static int __init inet6_init(void)
 	if (err)
 		goto out_unregister_udp_proto;
 
+#ifdef CONFIG_INET_RAW
 	err = proto_register(&rawv6_prot, 1);
 	if (err)
 		goto out_unregister_udplite_proto;
+#endif
 
 #ifdef CONFIG_IP_PING
 	err = proto_register(&pingv6_prot, 1);
@@ -1036,8 +1038,10 @@ out_unregister_ping_proto:
 	proto_unregister(&pingv6_prot);
 out_unregister_raw_proto:
 #endif
+#ifdef CONFIG_INET_RAW
 	proto_unregister(&rawv6_prot);
 out_unregister_udplite_proto:
+#endif
 	proto_unregister(&udplitev6_prot);
 out_unregister_udp_proto:
 	proto_unregister(&udpv6_prot);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 40e7581..fb21dde 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -235,6 +235,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 
 EXPORT_SYMBOL(ip6_xmit);
 
+#ifdef CONFIG_INET_RAW
 static int ip6_call_ra_chain(struct sk_buff *skb, int sel)
 {
 	struct ip6_ra_chain *ra;
@@ -263,6 +264,7 @@ static int ip6_call_ra_chain(struct sk_buff *skb, int sel)
 	read_unlock(&ip6_ra_lock);
 	return 0;
 }
+#endif
 
 static int ip6_forward_proxy_check(struct sk_buff *skb)
 {
@@ -394,10 +396,12 @@ int ip6_forward(struct sk_buff *skb)
 	 *	cannot be fragmented, because there is no warranty
 	 *	that different fragments will go along one path. --ANK
 	 */
+#ifdef CONFIG_INET_RAW
 	if (unlikely(opt->flags & IP6SKB_ROUTERALERT)) {
 		if (ip6_call_ra_chain(skb, ntohs(opt->ra)))
 			return 0;
 	}
+#endif
 
 	/*
 	 *	check and decrement ttl
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 091d066..af0d18a 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -40,8 +40,10 @@ static int sockstat6_seq_show(struct seq_file *seq, void *v)
 		       sock_prot_inuse_get(net, &udpv6_prot));
 	seq_printf(seq, "UDPLITE6: inuse %d\n",
 			sock_prot_inuse_get(net, &udplitev6_prot));
+#ifdef CONFIG_INET_RAW
 	seq_printf(seq, "RAW6: inuse %d\n",
 		       sock_prot_inuse_get(net, &rawv6_prot));
+#endif
 	seq_printf(seq, "FRAG6: inuse %d memory %d\n",
 		       ip6_frag_nqueues(net), ip6_frag_mem(net));
 	return 0;
-- 
1.9.0
