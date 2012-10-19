From: Li Yu <raise.sail@gmail.com>
Subject: [PATCH 3/3] skbtrace v2: TCP/IPv6 family support
Date: Fri, 19 Oct 2012 14:16:33 +0800
Message-ID: <5080F041.2050302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:56761 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917Ab2JSGQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 02:16:38 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so121597pad.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 23:16:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yu <bingtian.ly@taobao.com>

This patch contains skbtrace support for IPv4 mapped IPv6 protocol family.

The complete support for IPv6 still is a TODO yet.

Thanks.

Sign-off-by: Li Yu <bingtian.ly@taobao.com>
---
 include/net/ipv6.h       |    2
 net/ipv6/Kconfig         |    7 +
 net/ipv6/Makefile        |    1
 net/ipv6/af_inet6.c      |   37 ++++++---
 net/ipv6/skbtrace-ipv6.c |  192
+++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/tcp_ipv6.c      |    5 +
 6 files changed, 232 insertions(+), 12 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 01c34b3..b90f529 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -640,6 +640,8 @@ extern void			ipv6_local_rxpmtu(struct sock *sk,
struct flowi6 *fl6, u32 mtu);
 extern int inet6_release(struct socket *sock);
 extern int inet6_bind(struct socket *sock, struct sockaddr *uaddr,
 		      int addr_len);
+extern int inet6_sock_getname(struct sock *sk, struct sockaddr *uaddr,
+			 int *uaddr_len, int peer);
 extern int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 			 int *uaddr_len, int peer);
 extern int inet6_ioctl(struct socket *sock, unsigned int cmd,
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 5728695..2eba870 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -250,4 +250,11 @@ config IPV6_PIMSM_V2
 	  Support for IPv6 PIM multicast routing protocol PIM-SMv2.
 	  If unsure, say N.

+config SKBTRACE_IPV6
+	tristate "IPv6 protocol suite support for skbtrace"
+	depends on SKBTRACE
+	default m
+	---help---
+	  Support for IPv6 part of skbtrace.
+
 endif # IPV6
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 686934a..7d8acb6 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -36,6 +36,7 @@ obj-$(CONFIG_NETFILTER)	+= netfilter/

 obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
+obj-${CONFIG_SKBTRACE_IPV6} += skbtrace-ipv6.o

 obj-y += addrconf_core.o exthdrs_core.o

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e22e6d8..554b698 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -437,15 +437,10 @@ void inet6_destroy_sock(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(inet6_destroy_sock);

-/*
- *	This does both peername and sockname.
- */
-
-int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
+int inet6_sock_getname(struct sock *sk, struct sockaddr *uaddr,
 		 int *uaddr_len, int peer)
 {
 	struct sockaddr_in6 *sin = (struct sockaddr_in6 *)uaddr;
-	struct sock *sk = sock->sk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);

@@ -453,11 +448,6 @@ int inet6_getname(struct socket *sock, struct
sockaddr *uaddr,
 	sin->sin6_flowinfo = 0;
 	sin->sin6_scope_id = 0;
 	if (peer) {
-		if (!inet->inet_dport)
-			return -ENOTCONN;
-		if (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_SYN_SENT)) &&
-		    peer == 1)
-			return -ENOTCONN;
 		sin->sin6_port = inet->inet_dport;
 		sin->sin6_addr = np->daddr;
 		if (np->sndflow)
@@ -472,9 +462,32 @@ int inet6_getname(struct socket *sock, struct
sockaddr *uaddr,
 	}
 	if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
 		sin->sin6_scope_id = sk->sk_bound_dev_if;
-	*uaddr_len = sizeof(*sin);
+	if (uaddr_len)
+		*uaddr_len = sizeof(*sin);
 	return 0;
 }
+EXPORT_SYMBOL(inet6_sock_getname);
+
+/*
+ *	This does both peername and sockname.
+ */
+
+int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
+		 int *uaddr_len, int peer)
+{
+	struct sock *sk = sock->sk;
+	struct inet_sock *inet = inet_sk(sk);
+
+	if (peer) {
+		if (!inet->inet_dport)
+			return -ENOTCONN;
+		if (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_SYN_SENT)) &&
+		    peer == 1)
+			return -ENOTCONN;
+	}
+
+	return inet6_sock_getname(sk, uaddr, uaddr_len, peer);
+}
 EXPORT_SYMBOL(inet6_getname);

 int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
diff --git a/net/ipv6/skbtrace-ipv6.c b/net/ipv6/skbtrace-ipv6.c
new file mode 100644
index 0000000..3759738
--- /dev/null
+++ b/net/ipv6/skbtrace-ipv6.c
@@ -0,0 +1,192 @@
+/*
+ *  skbtrace - sk_buff trace for TCP/IPv6 protocol suite support
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.
+ *
+ * 2012 Li Yu <bingtian.ly@taobao.com>
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/relay.h>
+#include <linux/debugfs.h>
+#include <linux/slab.h>
+#include <linux/ctype.h>
+#include <linux/jhash.h>
+#include <linux/inet.h>
+
+#include <linux/skbtrace.h>
+#include <linux/tcp.h>
+#include <net/inet_common.h>
+#include <net/inet_connection_sock.h>
+#include <net/inet6_connection_sock.h>
+#include <net/ipv6.h>
+#include <net/tcp.h>
+
+static int is_mapped_ipv4(struct sock *sk)
+{
+	struct in6_addr mapped_prefix;
+	struct ipv6_pinfo *np = inet6_sk(sk);
+
+	if (sk->sk_gso_type == SKB_GSO_TCPV4 && sk->sk_state == TCP_SYN_RECV)
+		return 1;
+
+	ipv6_addr_set(&mapped_prefix, 0, 0, htonl(0x0000FFFF), 0);
+	return ipv6_prefix_equal(&mapped_prefix, &np->saddr, 96);
+}
+
+static int inetX_sock_getname(struct sock *sk, struct sockaddr *uaddr,
+			int *uaddr_len, int peer)
+{
+	if (is_mapped_ipv4(sk))
+		return inet_sock_getname(sk, uaddr, uaddr_len, peer);
+	return inet6_sock_getname(sk, uaddr, uaddr_len, peer);
+}
+
+static int __inet6_filter_skb(struct sock *sk, struct sk_buff *skb)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct ipv6hdr *iph;
+
+	skb_reset_network_header(skb);
+	iph = ipv6_hdr(skb);
+
+	*(__be32 *)iph = htonl(0x60000000);
+	iph->hop_limit = 0;
+	iph->nexthdr = sk->sk_protocol;
+        iph->saddr = np->saddr;
+	iph->daddr = np->daddr;
+	iph->payload_len = htons(sizeof(struct ipv6hdr) + sizeof(struct tcphdr));
+
+	return sizeof(struct ipv6hdr);
+}
+
+static int inetX_filter_skb(struct sock *sk, struct sk_buff *skb)
+{
+	int size, prot_size;
+
+	if (!skb || !sk->sk_prot->filter_skb) {
+		return -EINVAL;
+	}
+
+	if (is_mapped_ipv4(sk))
+		return inet_filter_skb(sk, skb);
+
+	size = __inet6_filter_skb(sk, skb);
+	if (size < 0)
+		return -EINVAL;
+	skb->len += size;
+	skb->data += size;
+	skb->tail += size;
+
+	prot_size = sk->sk_prot->filter_skb(sk, skb);
+	if (prot_size < 0)
+		return -EINVAL;
+	skb->len += prot_size;
+	skb->tail += prot_size;
+
+	skb->data -= size;
+	return 0;
+}
+
+static int inetX_tw_getname(struct inet_timewait_sock *tw,
+				struct sockaddr *addr, int peer)
+{
+	struct sockaddr_in6 *in6 = (struct sockaddr_in6*)addr;
+	struct inet6_timewait_sock *tw6;
+
+	if (tw->tw_family == AF_INET)
+		return inet_tw_getname(tw, addr, peer);
+
+	tw6 = inet6_twsk((struct sock *)tw);
+	in6->sin6_family = AF_INET6;
+	if (!peer) {
+		in6->sin6_port = tw->tw_sport;
+		in6->sin6_addr = tw6->tw_v6_rcv_saddr;
+	} else {
+		in6->sin6_port = tw->tw_dport;
+		in6->sin6_addr = tw6->tw_v6_daddr;
+	}
+	return 0;
+}
+
+static int __inet6_tw_filter_skb(struct inet_timewait_sock *tw,
+						struct sk_buff *skb)
+{
+	struct ipv6hdr *iph;
+	struct inet6_timewait_sock *tw6;
+
+	tw6 = inet6_twsk((struct sock *)tw);
+
+	skb_reset_network_header(skb);
+	iph = ipv6_hdr(skb);
+	*(__be32 *)iph = htonl(0x60000000);
+	iph->hop_limit = 0;
+	iph->nexthdr = IPPROTO_TCP;
+	iph->saddr = tw6->tw_v6_rcv_saddr;
+	iph->daddr = tw6->tw_v6_daddr;
+	iph->payload_len = htons(sizeof(struct ipv6hdr) + sizeof(struct tcphdr));
+
+	return sizeof(struct ipv6hdr);
+}
+
+static int inetX_tw_filter_skb(struct inet_timewait_sock *tw, struct
sk_buff *skb)
+{
+	int size, prot_size;
+
+	if (!skb)
+		return -EINVAL;
+
+	if (AF_INET == tw->tw_family)
+		return inet_tw_filter_skb(tw, skb);
+
+	size = __inet6_tw_filter_skb(tw, skb);
+	if (size < 0)
+		return -EINVAL;
+	skb->len += size;
+	skb->data += size;
+	skb->tail += size;
+
+	prot_size = tcp_tw_filter_skb(tw, skb);
+	if (prot_size < 0)
+		return -EINVAL;
+	skb->len += prot_size;
+	skb->tail += prot_size;
+
+	skb->data -= size;
+	return 0;
+}
+
+static struct skbtrace_ops ops_inet6 = {
+	.tw_getname = inetX_tw_getname,
+	.tw_filter_skb = inetX_tw_filter_skb,
+	.getname = inetX_sock_getname,
+	.filter_skb = inetX_filter_skb,
+};
+
+static int skbtrace_ipv6_init(void)
+{
+	return skbtrace_register_proto(AF_INET6, NULL, &ops_inet6);
+}
+
+static void skbtrace_ipv6_cleanup(void)
+{
+	skbtrace_unregister_proto(AF_INET6);
+}
+
+module_init(skbtrace_ipv6_init);
+module_exit(skbtrace_ipv6_cleanup);
+MODULE_ALIAS("skbtrace-af-" __stringify(AF_INET6));
+MODULE_LICENSE("GPL");
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index acd32e3..502af37 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -72,6 +72,8 @@
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>

+#include <linux/skbtrace.h>
+
 static void	tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb);
 static void	tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 				      struct request_sock *req);
@@ -2006,6 +2008,9 @@ void tcp6_proc_exit(struct net *net)
 struct proto tcpv6_prot = {
 	.name			= "TCPv6",
 	.owner			= THIS_MODULE,
+#if HAVE_SKBTRACE
+	.filter_skb		= tcp_filter_skb,
+#endif
 	.close			= tcp_close,
 	.connect		= tcp_v6_connect,
 	.disconnect		= tcp_disconnect,
