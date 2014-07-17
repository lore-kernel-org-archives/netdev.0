From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/9] gue: Support for Generic UDP Encapsulation RX
 path
Date: Wed, 16 Jul 2014 21:14:30 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407162058200.2128@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:34467 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbaGQEOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 00:14:32 -0400
Received: by mail-ie0-f202.google.com with SMTP id rl12so630390iec.3
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 21:14:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides a Generic UDP Encapsulation receive path
using the XFRM framework (udp_encap_rcv).

This adds support for both direct encapsulation of IP protocols over
UDP. The bound destination port is used to map to an IP protocol.
This should support GRE over UDP encapsulation, see
http://tools.ietf.org/html/draft-yong-tsvwg-gre-in-udp-encap-02,
as will as the other IP tunneling protocols (IPIP, SIT).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/gue.h |  49 +++++++++++++++++
 net/ipv4/Kconfig  |  10 ++++
 net/ipv4/Makefile |   1 +
 net/ipv4/gue.c    | 159 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 219 insertions(+)
 create mode 100644 include/net/gue.h
 create mode 100644 net/ipv4/gue.c

diff --git a/include/net/gue.h b/include/net/gue.h
new file mode 100644
index 0000000..86b91bc
--- /dev/null
+++ b/include/net/gue.h
@@ -0,0 +1,49 @@
+#ifndef __NET_GUE_H
+#define __NET_GUE_H
+
+#if defined(CONFIG_NET_GUE) || defined(CONFIG_NET_GUE_MODULE)
+
+#include <net/udp_tunnel.h>
+
+struct gue_port_cfg {
+	u8			protocol;
+	struct udp_port_cfg	udp_config;
+};
+
+int gue_port_create(struct net *net, struct gue_port_cfg *cfg,
+		    struct socket **sockp);
+int gue_open_direct_port(unsigned short port, unsigned char proto,
+			 struct socket **sockp);
+void gue_close_port(struct socket *sock);
+
+/* Tunnel protocols can use GUE_TUNNEL_PARMS to set up per module static
+ * variables that are used with the common GUE functions (open_gue_port,
+ * close_gue_port).
+ */
+#define GUE_TUNNEL_PARMS(name, default_port)			\
+static int gue_udp_port = default_port;				\
+module_param(gue_udp_port, int, 0);				\
+MODULE_PARM_DESC(gue_udp_port, name "/UDP port");		\
+static struct socket *gue_sock;
+
+#define open_gue_port(proto)					\
+	(gue_udp_port ?						\
+	 gue_open_direct_port(gue_udp_port, proto, &gue_sock) :	\
+	 0)
+
+#define close_gue_port() do {					\
+	if (gue_sock) {						\
+		gue_close_port(gue_sock);			\
+		gue_sock = NULL;				\
+	}							\
+} while (0)
+
+#else /* defined(CONFIG_NET_GUE) || defined(CONFIG_NET_GUE_MODULE) */
+
+#define GUE_TUNNEL_PARMS(name, default_port)
+#define open_gue_port(proto) (0)
+#define close_gue_port()
+
+#endif
+
+#endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index dbc10d8..0551acb 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -311,6 +311,16 @@ config NET_UDP_TUNNEL
 	tristate
 	default n
 
+config NET_GUE
+	tristate "IP: Generic UDP Encapsulation"
+	select XFRM
+	select NET_UDP_TUNNEL
+	---help---
+	  Generic UDP Encapsulation is a method to encapsulate IP
+	  tunnels (IPIP, GRE, SIT) over UDP. By encapsulating in UDP
+	  network mechanisms and optimizations for UDP (such as ECMP
+	  and RSS) can be leveraged to provide better service.
+
 config INET_AH
 	tristate "IP: AH transformation"
 	select XFRM_ALGO
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 8ee1cd4..2044a14 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
 gre-y := gre_demux.o
+obj-$(CONFIG_NET_GUE) += gue.o
 obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
 obj-$(CONFIG_NET_UDP_TUNNEL) += udp_tunnel.o
diff --git a/net/ipv4/gue.c b/net/ipv4/gue.c
new file mode 100644
index 0000000..17265bc
--- /dev/null
+++ b/net/ipv4/gue.c
@@ -0,0 +1,159 @@
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
+struct gue {
+	struct sock *sock;
+	u8 protocol;
+	void (*old_sk_destruct)(struct sock *sk);
+};
+
+static inline struct gue *gue_from_sock(struct sock *sk)
+{
+	return (struct gue *)sk->sk_user_data;
+}
+
+static int gue_udp_encap_recv_deliver(struct sk_buff *skb,
+				      u8 protocol, size_t len)
+{
+	struct iphdr *iph = ip_hdr(skb);
+
+	/* Remove 'len' bytes from the packet (UDP header and
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
+	struct gue *gue = gue_from_sock(sk);
+
+	if (!gue)
+		return 1;
+
+	return gue_udp_encap_recv_deliver(skb, gue->protocol,
+					  sizeof(struct udphdr));
+}
+
+void gue_sock_destruct(struct sock *sk)
+{
+	struct gue *gue = gue_from_sock(sk);
+
+	if (!gue)
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
+	err = udp_sock_create(net, &cfg->udp_config, &sock);
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
+	gue->protocol = cfg->protocol;
+	udp_sk(sk)->encap_rcv = gue_udp_direct_recv;
+
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
+int gue_open_direct_port(unsigned short port, u8 proto,
+			 struct socket **sockp)
+{
+	struct gue_port_cfg cfg;
+
+	memset(&cfg, 0, sizeof(cfg));
+
+	cfg.udp_config.family = AF_INET;
+	cfg.udp_config.local_ip.s_addr = INADDR_ANY;
+	cfg.udp_config.local_udp_port = htons(port);
+	cfg.protocol = proto;
+
+	return gue_port_create(&init_net, &cfg, sockp);
+}
+EXPORT_SYMBOL_GPL(gue_open_direct_port);
+
+void gue_close_port(struct socket *sock)
+{
+	sock_release(sock);
+}
+EXPORT_SYMBOL_GPL(gue_close_port);
+
+static int __init gue_init(void)
+{
+	return 0;
+}
+
+static void __exit gue_fini(void)
+{
+}
+
+module_init(gue_init);
+module_exit(gue_fini);
+MODULE_AUTHOR("Tom Herbert <therbert@google.com>");
+MODULE_LICENSE("GPL");
-- 
2.0.0.526.g5318336
