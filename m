From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: make IPV6_RECVPKTINFO work for ipv4 datagrams
Date: Mon, 20 Jan 2014 03:43:08 +0100
Message-ID: <20140120024308.GE16462@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: gert@space.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50560 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217AbaATCnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 21:43:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently don't report IPV6_RECVPKTINFO in cmsg access ancillary data
for IPv4 datagrams on IPv6 sockets.

This patch splits the ip6_datagram_recv_ctl into two functions, one
which handles both protocol families, AF_INET and AF_INET6, while the
ip6_datagram_recv_specific_ctl only handles IPv6 cmsg data.

ip6_datagram_recv_*_ctl never reported back any errors, so we can make
them return void. Also provide a helper for protocols which don't offer dual
personality to further use ip6_datagram_recv_ctl, which is exported to
modules.

I needed to shuffle the code for ping around a bit to make it easier to
implement dual personality for ping ipv6 sockets in future.

Reported-by: Gert Doering <gert@space.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/ipv6.h     |  3 +++
 include/net/ip.h         |  1 +
 include/net/ping.h       |  8 ++++++--
 include/net/transp_v6.h  |  9 +++++++--
 net/ipv4/ip_sockglue.c   |  6 +++---
 net/ipv4/ping.c          |  7 ++++++-
 net/ipv6/datagram.c      | 38 ++++++++++++++++++++++++++++++--------
 net/ipv6/ipv6_sockglue.c |  4 +---
 net/ipv6/ping.c          | 10 ++++++----
 net/ipv6/udp.c           |  6 +++++-
 10 files changed, 68 insertions(+), 24 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 7e1ded0..ea81e7a 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -283,6 +283,8 @@ static inline void inet_sk_copy_descendant(struct sock *sk_to,
 
 #define __ipv6_only_sock(sk)	(inet6_sk(sk)->ipv6only)
 #define ipv6_only_sock(sk)	((sk)->sk_family == PF_INET6 && __ipv6_only_sock(sk))
+#define ipv6_sk_rxinfo(sk)	((sk)->sk_family == PF_INET6 && \
+				 inet6_sk(sk)->rxopt.bits.rxinfo)
 
 static inline const struct in6_addr *inet6_rcv_saddr(const struct sock *sk)
 {
@@ -299,6 +301,7 @@ static inline int inet_v6_ipv6only(const struct sock *sk)
 #else
 #define __ipv6_only_sock(sk)	0
 #define ipv6_only_sock(sk)	0
+#define ipv6_sk_rxinfo(sk)	0
 
 static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
 {
diff --git a/include/net/ip.h b/include/net/ip.h
index 7876e3b..23be0fd 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -63,6 +63,7 @@ struct ipcm_cookie {
 };
 
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
+#define PKTINFO_SKB_CB(skb) ((struct in_pktinfo *)((skb)->cb))
 
 struct ip_ra_chain {
 	struct ip_ra_chain __rcu *next;
diff --git a/include/net/ping.h b/include/net/ping.h
index 7601365..026479b 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -33,8 +33,12 @@
 struct pingv6_ops {
 	int (*ipv6_recv_error)(struct sock *sk, struct msghdr *msg, int len,
 			       int *addr_len);
-	int (*ip6_datagram_recv_ctl)(struct sock *sk, struct msghdr *msg,
-				     struct sk_buff *skb);
+	void (*ip6_datagram_recv_common_ctl)(struct sock *sk,
+					     struct msghdr *msg,
+					     struct sk_buff *skb);
+	void (*ip6_datagram_recv_specific_ctl)(struct sock *sk,
+					       struct msghdr *msg,
+					       struct sk_buff *skb);
 	int (*icmpv6_err_convert)(u8 type, u8 code, int *err);
 	void (*ipv6_icmp_error)(struct sock *sk, struct sk_buff *skb, int err,
 				__be16 port, u32 info, u8 *payload);
diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 48660e5..b927413 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -32,8 +32,13 @@ void tcpv6_exit(void);
 
 int udpv6_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 
-int ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
-			  struct sk_buff *skb);
+/* this does all the common and the specific ctl work */
+void ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
+			   struct sk_buff *skb);
+void ip6_datagram_recv_common_ctl(struct sock *sk, struct msghdr *msg,
+				  struct sk_buff *skb);
+void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
+				    struct sk_buff *skb);
 
 int ip6_datagram_send_ctl(struct net *net, struct sock *sk, struct msghdr *msg,
 			  struct flowi6 *fl6, struct ipv6_txoptions *opt,
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 22f15eb..580dd96 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -56,7 +56,6 @@
 /*
  *	SOL_IP control messages.
  */
-#define PKTINFO_SKB_CB(__skb) ((struct in_pktinfo *)((__skb)->cb))
 
 static void ip_cmsg_recv_pktinfo(struct msghdr *msg, struct sk_buff *skb)
 {
@@ -1055,9 +1054,10 @@ e_inval:
 void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
 {
 	struct in_pktinfo *pktinfo = PKTINFO_SKB_CB(skb);
+	bool prepare = (inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO) ||
+		       ipv6_sk_rxinfo(sk);
 
-	if ((inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO) &&
-	    skb_rtable(skb)) {
+	if (prepare && skb_rtable(skb)) {
 		pktinfo->ipi_ifindex = inet_iif(skb);
 		pktinfo->ipi_spec_dst.s_addr = fib_compute_spec_dst(skb);
 	} else {
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index e09e883..4a9e426 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -906,7 +906,12 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		}
 
 		if (inet6_sk(sk)->rxopt.all)
-			pingv6_ops.ip6_datagram_recv_ctl(sk, msg, skb);
+			pingv6_ops.ip6_datagram_recv_common_ctl(sk, msg, skb);
+		if (skb->protocol == htons(ETH_P_IPV6) &&
+		    inet6_sk(sk)->rxopt.all)
+			pingv6_ops.ip6_datagram_recv_specific_ctl(sk, msg, skb);
+		else if (skb->protocol == htons(ETH_P_IP) && isk->cmsg_flags)
+			ip_cmsg_recv(msg, skb);
 #endif
 	} else {
 		BUG();
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index bce73cb..cd8699b 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -377,10 +377,12 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
 		sin->sin6_port = 0;
+		if (np->rxopt.all)
+			ip6_datagram_recv_common_ctl(sk, msg, skb);
 		if (skb->protocol == htons(ETH_P_IPV6)) {
 			sin->sin6_addr = ipv6_hdr(skb)->saddr;
 			if (np->rxopt.all)
-				ip6_datagram_recv_ctl(sk, msg, skb);
+				ip6_datagram_recv_specific_ctl(sk, msg, skb);
 			sin->sin6_scope_id =
 				ipv6_iface_scope_id(&sin->sin6_addr,
 						    IP6CB(skb)->iif);
@@ -471,20 +473,34 @@ out:
 }
 
 
-int ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
-			  struct sk_buff *skb)
+void ip6_datagram_recv_common_ctl(struct sock *sk, struct msghdr *msg,
+				 struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct inet6_skb_parm *opt = IP6CB(skb);
-	unsigned char *nh = skb_network_header(skb);
+	bool is_ipv6 = skb->protocol == htons(ETH_P_IPV6);
 
 	if (np->rxopt.bits.rxinfo) {
 		struct in6_pktinfo src_info;
 
-		src_info.ipi6_ifindex = opt->iif;
-		src_info.ipi6_addr = ipv6_hdr(skb)->daddr;
+		if (is_ipv6) {
+			src_info.ipi6_ifindex = IP6CB(skb)->iif;
+			src_info.ipi6_addr = ipv6_hdr(skb)->daddr;
+		} else {
+			src_info.ipi6_ifindex =
+				PKTINFO_SKB_CB(skb)->ipi_ifindex;
+			ipv6_addr_set_v4mapped(ip_hdr(skb)->daddr,
+					       &src_info.ipi6_addr);
+		}
 		put_cmsg(msg, SOL_IPV6, IPV6_PKTINFO, sizeof(src_info), &src_info);
 	}
+}
+
+void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
+				    struct sk_buff *skb)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct inet6_skb_parm *opt = IP6CB(skb);
+	unsigned char *nh = skb_network_header(skb);
 
 	if (np->rxopt.bits.rxhlim) {
 		int hlim = ipv6_hdr(skb)->hop_limit;
@@ -602,7 +618,13 @@ int ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
 			put_cmsg(msg, SOL_IPV6, IPV6_ORIGDSTADDR, sizeof(sin6), &sin6);
 		}
 	}
-	return 0;
+}
+
+void ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
+			  struct sk_buff *skb)
+{
+	ip6_datagram_recv_common_ctl(sk, msg, skb);
+	ip6_datagram_recv_specific_ctl(sk, msg, skb);
 }
 EXPORT_SYMBOL_GPL(ip6_datagram_recv_ctl);
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 2855b00..663b731 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1002,10 +1002,8 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		release_sock(sk);
 
 		if (skb) {
-			int err = ip6_datagram_recv_ctl(sk, &msg, skb);
+			ip6_datagram_recv_ctl(sk, &msg, skb);
 			kfree_skb(skb);
-			if (err)
-				return err;
 		} else {
 			if (np->rxopt.bits.rxinfo) {
 				struct in6_pktinfo src_info;
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index cd71f3a..94a3d04 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -62,10 +62,9 @@ static int dummy_ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len,
 {
 	return -EAFNOSUPPORT;
 }
-static int dummy_ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
+static void dummy_ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
 				       struct sk_buff *skb)
 {
-	return -EAFNOSUPPORT;
 }
 static int dummy_icmpv6_err_convert(u8 type, u8 code, int *err)
 {
@@ -254,7 +253,9 @@ int __init pingv6_init(void)
 		return ret;
 #endif
 	pingv6_ops.ipv6_recv_error = ipv6_recv_error;
-	pingv6_ops.ip6_datagram_recv_ctl = ip6_datagram_recv_ctl;
+	pingv6_ops.ip6_datagram_recv_common_ctl = ip6_datagram_recv_common_ctl;
+	pingv6_ops.ip6_datagram_recv_specific_ctl =
+		ip6_datagram_recv_specific_ctl;
 	pingv6_ops.icmpv6_err_convert = icmpv6_err_convert;
 	pingv6_ops.ipv6_icmp_error = ipv6_icmp_error;
 	pingv6_ops.ipv6_chk_addr = ipv6_chk_addr;
@@ -267,7 +268,8 @@ int __init pingv6_init(void)
 void pingv6_exit(void)
 {
 	pingv6_ops.ipv6_recv_error = dummy_ipv6_recv_error;
-	pingv6_ops.ip6_datagram_recv_ctl = dummy_ip6_datagram_recv_ctl;
+	pingv6_ops.ip6_datagram_recv_common_ctl = dummy_ip6_datagram_recv_ctl;
+	pingv6_ops.ip6_datagram_recv_specific_ctl = dummy_ip6_datagram_recv_ctl;
 	pingv6_ops.icmpv6_err_convert = dummy_icmpv6_err_convert;
 	pingv6_ops.ipv6_icmp_error = dummy_ipv6_icmp_error;
 	pingv6_ops.ipv6_chk_addr = dummy_ipv6_chk_addr;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 233c3ab..1e586d9 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -477,12 +477,16 @@ try_again:
 		}
 		*addr_len = sizeof(*sin6);
 	}
+
+	if (np->rxopt.all)
+		ip6_datagram_recv_common_ctl(sk, msg, skb);
+
 	if (is_udp4) {
 		if (inet->cmsg_flags)
 			ip_cmsg_recv(msg, skb);
 	} else {
 		if (np->rxopt.all)
-			ip6_datagram_recv_ctl(sk, msg, skb);
+			ip6_datagram_recv_specific_ctl(sk, msg, skb);
 	}
 
 	err = copied;
-- 
1.8.4.2
