From: Tom Herbert <therbert@google.com>
Subject: [PATCH RFC 2/7] net: Support for GUE RX via xfrm
Date: Thu, 2 Jan 2014 14:12:52 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401021401200.32160@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hkchu@google.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:37895 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbaABWMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:12:53 -0500
Received: by mail-oa0-f73.google.com with SMTP id i4so3334085oah.2
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 14:12:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides a Generic Receive Encapsulation receive path
using the XFRM framework (udp_encap_rcv).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/gue.h |  50 +++++++++
 net/ipv4/Kconfig  |   6 +
 net/ipv4/Makefile |   1 +
 net/ipv4/gue.c    | 322 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 379 insertions(+)
 create mode 100644 include/net/gue.h
 create mode 100644 net/ipv4/gue.c

diff --git a/include/net/gue.h b/include/net/gue.h
new file mode 100644
index 0000000..247274d
--- /dev/null
+++ b/include/net/gue.h
@@ -0,0 +1,50 @@
+#ifndef GUEHDR
+#define GUEHDR
+
+struct guehdr {
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	__u8    hlen:4,
+		version:4;
+#elif defined (__BIG_ENDIAN_BITFIELD)
+	__u8    version:4,
+		hlen:4;
+#else
+#error  "Please fix <asm/byteorder.h>"
+#endif
+	__u8    next_hdr;
+	__u16   flags;
+};
+
+#if defined(CONFIG_NET_GUE) || defined(CONFIG_NET_GUE_MODULE)
+
+struct gue_port_cfg {
+	u8			protocol;
+	int			encap_type;
+
+	/* Used only for kernel-created sockets */
+	struct in_addr		local_ip;
+	struct in_addr		peer_ip;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct in6_addr		*local_ip6;
+	struct in6_addr		*peer_ip6;
+#endif
+	u16			local_udp_port;
+	u16			peer_udp_port;
+	unsigned int		use_udp_checksums:1;
+};
+
+enum gue_encap_types {
+	GUE_ENCAP_DIRECT,
+	GUE_ENCAP_GUEHDR
+};
+
+int gue_port_create(struct net *net, struct gue_port_cfg *cfg,
+		    struct socket **sockp);
+int gue_open_direct_port(unsigned short port, unsigned char proto,
+			 struct socket **sockp);
+int gue_open_guehdr_port(unsigned short port, struct socket **sockp);
+void gue_close_port(struct socket *sock);
+
+#endif /* defined(CONFIG_NET_GUE) || defined(CONFIG_NET_GUE_MODULE) */
+
+#endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 05c57f0..12b1e46 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -307,6 +307,12 @@ config NET_IPVTI
 	  the notion of a secure tunnel for IPSEC and then use routing protocol
 	  on top.
 
+config NET_GUE
+	tristate "IP: Generic UDP Encpasulation"
+	select XFRM
+	help
+	 This is helper module to decapsulate GUE packets.
+
 config INET_AH
 	tristate "IP: AH transformation"
 	select XFRM_ALGO
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 4b81e91..14430a7 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -19,6 +19,7 @@ obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
+obj-$(CONFIG_NET_GUE) += gue.o
 gre-y := gre_demux.o gre_offload.o
 obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
diff --git a/net/ipv4/gue.c b/net/ipv4/gue.c
new file mode 100644
index 0000000..04c31ff
--- /dev/null
+++ b/net/ipv4/gue.c
@@ -0,0 +1,322 @@
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/socket.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <net/ip.h>
+#include <net/udp.h>
+#include <net/gue.h>
+#include <net/xfrm.h>
+
+static int gue_port __read_mostly = 0;
+MODULE_PARM_DESC(gue_port, "GUE header port");
+module_param(gue_port, int, 0);
+
+struct socket *gue_sock = NULL;
+
+struct gue {
+	struct sock *sock;
+	void (*old_sk_destruct)(struct sock *sk);
+	unsigned char  protocol;
+};
+
+static inline struct gue *gue_from_sock(struct sock *sk)
+{
+	return (struct gue *)sk->sk_user_data;
+}
+
+static int gue_udp_encap_recv_deliver(struct sk_buff *skb,
+				      unsigned char protocol, size_t len,
+				      int encap_type)
+{
+	struct iphdr *iph = ip_hdr(skb);
+
+	/*
+	 * Remove 'len' bytes from the packet (UDP header and
+	 * GUE header if present), modify the protocol to the one
+	 * we found, and then call rcv_encap.
+	 */
+	iph->tot_len = htons(ntohs(iph->tot_len) - len);
+	__skb_pull(skb, len);
+	skb_reset_transport_header(skb);
+
+	return -protocol;
+}
+
+int gue_udp_direct_recv(struct sock *sk, struct sk_buff *skb)
+{
+	struct gue *gue;
+	struct udp_sock *up = udp_sk(sk);
+
+	if (!(gue = gue_from_sock(sk)))
+		return 1;
+
+	return gue_udp_encap_recv_deliver(skb, gue->protocol,
+					  sizeof(struct udphdr),
+					  up->encap_type);
+}
+
+int gue_udp_guehdr_recv(struct sock *sk, struct sk_buff *skb)
+{
+	struct gue *gue;
+	size_t len;
+	struct guehdr *guehdr;
+	struct udp_sock *up = udp_sk(sk);
+
+	if (!(gue = gue_from_sock(sk)))
+		return 1;
+
+	len = sizeof(struct udphdr) + sizeof(struct guehdr);
+	if (!pskb_may_pull(skb, len))
+		goto drop;
+
+	guehdr = (struct guehdr *)(skb->data + sizeof(struct udphdr));;
+
+	len += guehdr->hlen << 2;
+	if (!pskb_may_pull(skb, len))
+		goto drop;
+
+	if (guehdr->version != 0)
+		goto drop;
+
+	if (guehdr->flags) {
+		/* No support yet */
+		goto drop;
+	}
+
+	return gue_udp_encap_recv_deliver(skb, guehdr->next_hdr, len,
+					  up->encap_type);
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+
+static int gue_sock_create(struct net *net,
+			   struct gue_port_cfg *cfg,
+			   struct socket **sockp)
+{
+	int err = -EINVAL;
+	struct socket *sock = NULL;
+	struct sockaddr_in udp_addr = {0};
+#if IS_ENABLED(CONFIG_IPV6)
+	struct sockaddr_in6 udp6_addr = {0};
+#endif
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (cfg->local_ip6 && cfg->peer_ip6) {
+		err = sock_create_kern(AF_INET6, SOCK_DGRAM, 0, &sock);
+		if (err < 0)
+			goto error;
+
+		sk_change_net(sock->sk, net);
+
+		udp6_addr.sin6_family = AF_INET6;
+		memcpy(&udp6_addr.sin6_addr, cfg->local_ip6,
+		       sizeof(udp6_addr.sin6_addr));
+		udp6_addr.sin6_port = htons(cfg->local_udp_port);
+		err = kernel_bind(sock, (struct sockaddr *) &udp6_addr,
+					  sizeof(udp6_addr));
+		if (err < 0)
+			goto error;
+
+		if (cfg->peer_udp_port) {
+			udp6_addr.sin6_family = AF_INET6;
+			memcpy(&udp6_addr.sin6_addr, cfg->peer_ip6,
+			       sizeof(udp6_addr.sin6_addr));
+			udp6_addr.sin6_port = htons(cfg->peer_udp_port);
+			err = kernel_connect(sock,
+					     (struct sockaddr *) &udp6_addr,
+					     sizeof(udp6_addr), 0);
+		}
+		if (err < 0)
+			goto error;
+	} else
+#endif
+	{
+		err = sock_create_kern(AF_INET, SOCK_DGRAM, 0, &sock);
+		if (err < 0)
+			goto error;
+
+		sk_change_net(sock->sk, net);
+
+		udp_addr.sin_family = AF_INET;
+		udp_addr.sin_addr = cfg->local_ip;
+		udp_addr.sin_port = htons(cfg->local_udp_port);
+		err = kernel_bind(sock, (struct sockaddr *) &udp_addr,
+				  sizeof(udp_addr));
+		if (err < 0)
+			goto error;
+
+		if (cfg->peer_udp_port) {
+			udp_addr.sin_family = AF_INET;
+			udp_addr.sin_addr = cfg->peer_ip;
+			udp_addr.sin_port = htons(cfg->peer_udp_port);
+			err = kernel_connect(sock,
+					     (struct sockaddr *) &udp_addr,
+					     sizeof(udp_addr), 0);
+			if (err < 0)
+				goto error;
+		}
+	}
+
+	if (!cfg->use_udp_checksums)
+		sock->sk->sk_no_check = UDP_CSUM_NOXMIT;
+
+	*sockp = sock;
+
+	return 0;
+
+error:
+	if (sock) {
+		kernel_sock_shutdown(sock, SHUT_RDWR);
+		sk_release_kernel(sock->sk);
+	}
+	*sockp = NULL;
+	return err;
+}
+
+void gue_sock_destruct(struct sock *sk)
+{
+	struct gue *gue;
+	if (!(gue = gue_from_sock(sk)))
+		return;
+
+	/* Remove hooks into tunnel socket */
+	sk->sk_destruct = gue->old_sk_destruct;
+	sk->sk_user_data = NULL;
+	gue->sock = NULL;
+
+	if (sk->sk_destruct)
+		sk->sk_destruct(sk);
+
+	kfree(gue);
+}
+
+
+int
+gue_port_create(struct net *net, struct gue_port_cfg *cfg,
+		struct socket **sockp)
+{
+	struct gue *gue = NULL;
+	int err;
+	struct socket *sock = NULL;
+	struct sock *sk;
+
+	/* Open UDP socket */
+	err = gue_sock_create(net, cfg, &sock);
+	if (err < 0)
+		goto error;
+
+	sk = sock->sk;
+
+	/* Allocate GUE port structure */
+	gue = kzalloc(sizeof(*gue), GFP_KERNEL);
+	if (!gue) {
+		err = -ENOMEM;
+		goto error;
+	}
+
+	/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
+	switch (cfg->encap_type) {
+	case GUE_ENCAP_DIRECT:
+		gue->protocol = cfg->protocol;
+		udp_sk(sk)->encap_rcv = gue_udp_direct_recv;
+		break;
+	case GUE_ENCAP_GUEHDR:
+		udp_sk(sk)->encap_rcv = gue_udp_guehdr_recv;
+		break;
+	default:
+		err = -EINVAL;
+		goto error;
+	}
+
+	/* Mark socket as an encapsulation socket. */
+	udp_sk(sk)->encap_type = 1;
+	udp_encap_enable();
+
+	sk->sk_user_data = gue;
+	gue->sock = sk;
+
+	sk->sk_allocation = GFP_ATOMIC;
+
+	/* Hook on the gue_port socket destructor so that we can cleanup
+	 * if the tunnel socket goes away.
+	 */
+	sk->sk_destruct = &gue_sock_destruct;
+	gue->old_sk_destruct = sk->sk_destruct;
+
+	if (sockp)
+		*sockp = sock;
+
+	return 0;
+
+error:
+	kfree(gue);
+	if (sock)
+		sock_release(sock);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(gue_port_create);
+
+int gue_open_direct_port(unsigned short port, unsigned char proto,
+			 struct socket **sockp)
+{
+        struct gue_port_cfg cfg;
+
+        memset(&cfg, 0, sizeof(cfg));
+
+        cfg.local_ip.s_addr = INADDR_ANY;
+        cfg.local_udp_port = port;
+        cfg.encap_type = GUE_ENCAP_DIRECT;
+        cfg.protocol = proto;
+
+        return gue_port_create(&init_net, &cfg, sockp);
+}
+EXPORT_SYMBOL_GPL(gue_open_direct_port);
+
+int gue_open_guehdr_port(unsigned short port, struct socket **sockp)
+{
+	struct gue_port_cfg cfg;
+
+	memset(&cfg, 0, sizeof(cfg));
+
+	cfg.local_ip.s_addr = INADDR_ANY;
+	cfg.local_udp_port = port;
+	cfg.encap_type = GUE_ENCAP_GUEHDR;
+
+	return gue_port_create(&init_net, &cfg, NULL);
+}
+EXPORT_SYMBOL_GPL(gue_open_guehdr_port);
+
+void gue_close_port(struct socket *sock)
+{
+	sock_release(sock);
+}
+EXPORT_SYMBOL_GPL(gue_close_port);
+
+static int __init gue_init(void)
+{
+	int err = 0;
+
+	if (gue_port)
+		err = gue_open_guehdr_port(gue_port, &gue_sock);
+
+	return err;
+}
+
+static void __exit gue_fini(void)
+{
+	if (gue_sock) {
+		gue_close_port(gue_sock);
+		gue_sock = NULL;
+	}
+}
+
+module_init(gue_init);
+module_exit(gue_fini);
+MODULE_AUTHOR("Tom Herbert <therbert@google.com>");
+MODULE_LICENSE("GPL");
-- 
1.8.5.1
