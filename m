From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 13/24] net, diet: Make GRO offload optional
Date: Mon,  5 May 2014 15:26:02 -0700
Message-ID: <1399328773-6531-14-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Make the GRO offload code optional.  It's not needed on small systems.
Since it's not a single file there are a couple of ifdefs.

Some code is still there (not ifdef'ed) but can be removed now with LTO.

Without LTO it gives about 3K.

   text    data     bss     dec     hex filename
 432712   18689   12616  464017   71491 net/built-in.o-with-offload
 429737   17665   12616  460018   704f2 net/built-in.o-wo-offload

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/net/protocol.h | 10 ++++++++++
 include/net/tcp.h      |  5 +++++
 net/ipv4/Kconfig       |  4 ++++
 net/ipv4/Makefile      |  5 +++--
 net/ipv4/af_inet.c     |  9 +++++++++
 net/ipv4/protocol.c    |  8 +++++++-
 net/ipv6/Makefile      |  5 +++--
 net/ipv6/protocol.c    |  2 ++
 8 files changed, 43 insertions(+), 5 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index a7e986b..63f5b0c 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -103,8 +103,18 @@ extern const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS];
 
 int inet_add_protocol(const struct net_protocol *prot, unsigned char num);
 int inet_del_protocol(const struct net_protocol *prot, unsigned char num);
+#ifdef CONFIG_IP_OFFLOAD
 int inet_add_offload(const struct net_offload *prot, unsigned char num);
 int inet_del_offload(const struct net_offload *prot, unsigned char num);
+#else
+static inline int
+inet_add_offload(const struct net_offload *prot, unsigned char num)
+{ return 0; }
+static inline int
+inet_del_offload(const struct net_offload *prot, unsigned char num)
+{ return 0; }
+#endif
+
 void inet_register_protosw(struct inet_protosw *p);
 void inet_unregister_protosw(struct inet_protosw *p);
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index d741d2f..ac9f6bd 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1567,7 +1567,12 @@ void tcp_v4_destroy_sock(struct sock *sk);
 struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 				netdev_features_t features);
 struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb);
+#ifdef CONFIG_IP_OFFLOAD
 int tcp_gro_complete(struct sk_buff *skb);
+#else
+/* For the benefit of one driver who really shouldn't be using this. */
+static inline int tcp_gro_complete(struct sk_buff *skb) { return -EIO; }
+#endif
 
 void __tcp_v4_send_check(struct sk_buff *skb, __be32 saddr, __be32 daddr);
 
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index db2dada..00a7f76 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -306,6 +306,10 @@ config SYN_COOKIES
 
 	  If unsure, say N.
 
+config IP_OFFLOAD
+	bool "Support for IP GRO/offload"
+	default y
+
 config NET_IPVTI
 	tristate "Virtual (secure) IP: tunneling"
 	select INET_TUNNEL
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 8b17b83..784a782 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -8,8 +8,8 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     inet_timewait_sock.o inet_connection_sock.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
 	     tcp_minisocks.o tcp_cong.o tcp_fastopen.o \
-	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
-	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
+	     datagram.o raw.o udp.o udplite.o \
+	     arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
 	     inet_fragment.o ip_tunnel_core.o gre_offload.o
 
@@ -26,6 +26,7 @@ obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
 obj-$(CONFIG_NET_IPVTI) += ip_vti.o
 obj-$(CONFIG_SYN_COOKIES) += syncookies.o
+obj-$(CONFIG_IP_OFFLOAD) += tcp_offload.o udp_offload.o
 obj-$(CONFIG_INET_AH) += ah4.o
 obj-$(CONFIG_INET_ESP) += esp4.o
 obj-$(CONFIG_INET_IPCOMP) += ipcomp.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c275ce5..e65e750 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1209,6 +1209,9 @@ int inet_sk_rebuild_header(struct sock *sk)
 }
 EXPORT_SYMBOL(inet_sk_rebuild_header);
 
+#ifdef CONFIG_IP_OFFLOAD
+/* Should move to a new file */
+
 static int inet_gso_send_check(struct sk_buff *skb)
 {
 	const struct net_offload *ops;
@@ -1455,6 +1458,8 @@ out_unlock:
 	return err;
 }
 
+#endif
+
 int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 			 unsigned short type, unsigned char protocol,
 			 struct net *net)
@@ -1653,6 +1658,9 @@ static int __init init_ipv4_mibs(void)
 
 static int ipv4_proc_init(void);
 
+#ifdef CONFIG_IP_OFFLOAD
+/* Move elsewhere? */
+
 /*
  *	IP protocol layer initialiser
  */
@@ -1690,6 +1698,7 @@ static int __init ipv4_offload_init(void)
 }
 
 fs_initcall(ipv4_offload_init);
+#endif
 
 static struct packet_type ip_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IP),
diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index 46d6a1c..0a33a12 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -29,7 +29,6 @@
 #include <net/protocol.h>
 
 const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS] __read_mostly;
-const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS] __read_mostly;
 
 int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
@@ -44,6 +43,9 @@ int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
 }
 EXPORT_SYMBOL(inet_add_protocol);
 
+#ifdef CONFIG_IP_OFFLOAD
+const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS] __read_mostly;
+
 int inet_add_offload(const struct net_offload *prot, unsigned char protocol)
 {
 	return !cmpxchg((const struct net_offload **)&inet_offloads[protocol],
@@ -51,6 +53,8 @@ int inet_add_offload(const struct net_offload *prot, unsigned char protocol)
 }
 EXPORT_SYMBOL(inet_add_offload);
 
+#endif
+
 int inet_del_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
 	int ret;
@@ -64,6 +68,7 @@ int inet_del_protocol(const struct net_protocol *prot, unsigned char protocol)
 }
 EXPORT_SYMBOL(inet_del_protocol);
 
+#ifdef CONFIG_IP_OFFLOAD
 int inet_del_offload(const struct net_offload *prot, unsigned char protocol)
 {
 	int ret;
@@ -76,3 +81,4 @@ int inet_del_offload(const struct net_offload *prot, unsigned char protocol)
 	return ret;
 }
 EXPORT_SYMBOL(inet_del_offload);
+#endif
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 6ff7cfd..7ce7aa0 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -10,7 +10,8 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		raw.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o
 
-ipv6-offload :=	ip6_offload.o tcpv6_offload.o udp_offload.o exthdrs_offload.o
+ipv6-offload-$(CONFIG_IP_OFFLOAD) := ip6_offload.o tcpv6_offload.o \
+		udp_offload.o exthdrs_offload.o
 
 ipv6-$(CONFIG_SYSCTL) = sysctl_net_ipv6.o
 ipv6-$(CONFIG_IPV6_MROUTE) += ip6mr.o
@@ -43,6 +44,6 @@ obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 
 obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o
-obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
+obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload-y)
 
 obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
diff --git a/net/ipv6/protocol.c b/net/ipv6/protocol.c
index e048cf1..bae02e1 100644
--- a/net/ipv6/protocol.c
+++ b/net/ipv6/protocol.c
@@ -50,6 +50,7 @@ int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char protocol
 EXPORT_SYMBOL(inet6_del_protocol);
 #endif
 
+#ifdef CONFIG_IP_OFFLOAD
 const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS] __read_mostly;
 
 int inet6_add_offload(const struct net_offload *prot, unsigned char protocol)
@@ -71,3 +72,4 @@ int inet6_del_offload(const struct net_offload *prot, unsigned char protocol)
 	return ret;
 }
 EXPORT_SYMBOL(inet6_del_offload);
+#endif
-- 
1.9.0
