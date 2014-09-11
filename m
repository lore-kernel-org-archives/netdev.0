From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/7] fou: Support for foo-over-udp RX path
Date: Thu, 11 Sep 2014 13:07:31 -0700
Message-ID: <1410466056-30239-3-git-send-email-therbert@google.com>
References: <1410466056-30239-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:49522 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525AbaIKUIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 16:08:06 -0400
Received: by mail-pa0-f44.google.com with SMTP id kx10so10654785pab.3
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 13:08:04 -0700 (PDT)
In-Reply-To: <1410466056-30239-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides a receive path for foo-over-udp. This allows
direct encapsulation of IP protocols over UDP. The bound destination
port is used to map to an IP protocol, and the XFRM framework
(udp_encap_rcv) is used to receive encapsulated packets. Upon
reception, the encapsulation header is logically removed (pointer
to transport header is advanced) and the packet is reinjected into
the receive path with the IP protocol indicated by the mapping.

Netlink is used to configure FOU ports. The configuration information
includes the port number to bind to and the IP protocol corresponding
to that port.

This should support GRE/UDP
(http://tools.ietf.org/html/draft-yong-tsvwg-gre-in-udp-encap-02),
as will as the other IP tunneling protocols (IPIP, SIT).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/fou.h        |  31 ++++++
 include/uapi/linux/fou.h |  34 ++++++
 net/ipv4/Kconfig         |  10 ++
 net/ipv4/Makefile        |   1 +
 net/ipv4/fou.c           | 274 +++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 350 insertions(+)
 create mode 100644 include/net/fou.h
 create mode 100644 include/uapi/linux/fou.h
 create mode 100644 net/ipv4/fou.c

diff --git a/include/net/fou.h b/include/net/fou.h
new file mode 100644
index 0000000..509cd61
--- /dev/null
+++ b/include/net/fou.h
@@ -0,0 +1,31 @@
+#ifndef __NET_FOU_H
+#define __NET_FOU_H
+
+#include <net/udp_tunnel.h>
+
+struct fou_cfg {
+	u8			protocol;
+	struct udp_port_cfg	udp_config;
+};
+
+#if defined(CONFIG_NET_FOU) || defined(CONFIG_NET_FOU_MODULE)
+
+int fou_create(struct net *net, struct fou_cfg *cfg,
+	       struct socket **sockp);
+int fou_destroy(struct net *net, struct fou_cfg *cfg);
+
+#else
+static inline int fou_create(struct net *net, struct fou_cfg *cfg,
+			     struct socket **sockp)
+{
+	return 0;
+}
+
+static inline int fou_destroy(struct net *net, struct fou_cfg *cfg)
+{
+	return 0;
+}
+
+#endif
+
+#endif /* __NET_FOU_H */
diff --git a/include/uapi/linux/fou.h b/include/uapi/linux/fou.h
new file mode 100644
index 0000000..f1a756b
--- /dev/null
+++ b/include/uapi/linux/fou.h
@@ -0,0 +1,34 @@
+/* fou.h - FOU Interface */
+
+#ifndef _UAPI_LINUX_FOU_H
+#define _UAPI_LINUX_FOU_H
+
+#include <linux/types.h>
+
+/* NETLINK_GENERIC related info
+ */
+#define FOU_GENL_NAME		"fou"
+#define FOU_GENL_VERSION	0x1
+
+enum {
+	FOU_ATTR_UNSPEC,
+	FOU_ATTR_PORT,				/* u16 */
+	FOU_ATTR_AF,				/* u8 */
+	FOU_ATTR_IPPROTO,			/* u8 */
+
+	__FOU_ATTR_MAX,
+};
+
+#define FOU_ATTR_MAX		(__FOU_ATTR_MAX - 1)
+
+enum {
+	FOU_CMD_UNSPEC,
+	FOU_CMD_ADD,
+	FOU_CMD_DEL,
+
+	__FOU_CMD_MAX,
+};
+
+#define FOU_CMD_MAX	(__FOU_CMD_MAX - 1)
+
+#endif /* _UAPI_LINUX_FOU_H */
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index dbc10d8..84f710b 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -311,6 +311,16 @@ config NET_UDP_TUNNEL
 	tristate
 	default n
 
+config NET_FOU
+	tristate "IP: Foo (IP protocols) over UDP"
+	select XFRM
+	select NET_UDP_TUNNEL
+	---help---
+	  Foo over UDP allows any IP protocol to be directly encapsulated
+	  over UDP include tunnels (IPIP, GRE, SIT). By encapsulating in UDP
+	  network mechanisms and optimizations for UDP (such as ECMP
+	  and RSS) can be leveraged to provide better service.
+
 config INET_AH
 	tristate "IP: AH transformation"
 	select XFRM_ALGO
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 8ee1cd4..d78d404 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
 gre-y := gre_demux.o
+obj-$(CONFIG_NET_FOU) += fou.o
 obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
 obj-$(CONFIG_NET_UDP_TUNNEL) += udp_tunnel.o
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
new file mode 100644
index 0000000..f69df75
--- /dev/null
+++ b/net/ipv4/fou.c
@@ -0,0 +1,274 @@
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/socket.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <net/fou.h>
+#include <net/genetlink.h>
+#include <net/ip.h>
+#include <net/udp.h>
+#include <net/xfrm.h>
+#include <uapi/linux/fou.h>
+#include <uapi/linux/genetlink.h>
+
+static DEFINE_SPINLOCK(fou_lock);
+static LIST_HEAD(fou_list);
+
+struct fou {
+	struct socket *sock;
+	u8 protocol;
+	u16 port;
+	struct list_head list;
+};
+
+static inline struct fou *fou_from_sock(struct sock *sk)
+{
+	return (struct fou *)sk->sk_user_data;
+}
+
+static int fou_udp_encap_recv_deliver(struct sk_buff *skb,
+				      u8 protocol, size_t len)
+{
+	struct iphdr *iph = ip_hdr(skb);
+
+	/* Remove 'len' bytes from the packet (UDP header and
+	 * FOU header if present), modify the protocol to the one
+	 * we found, and then call rcv_encap.
+	 */
+	iph->tot_len = htons(ntohs(iph->tot_len) - len);
+	__skb_pull(skb, len);
+	skb_postpull_rcsum(skb, udp_hdr(skb), len);
+	skb_reset_transport_header(skb);
+
+	return -protocol;
+}
+
+static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
+{
+	struct fou *fou = fou_from_sock(sk);
+
+	if (!fou)
+		return 1;
+
+	return fou_udp_encap_recv_deliver(skb, fou->protocol,
+					  sizeof(struct udphdr));
+}
+
+static int fou_add_to_port_list(struct fou *fou)
+{
+	struct fou *fout;
+
+	spin_lock(&fou_lock);
+	list_for_each_entry(fout, &fou_list, list) {
+		if (fou->port == fout->port) {
+			spin_unlock(&fou_lock);
+			return -EALREADY;
+		}
+	}
+
+	list_add(&fou->list, &fou_list);
+	spin_unlock(&fou_lock);
+
+	return 0;
+}
+
+static void fou_release(struct fou *fou)
+{
+	struct socket *sock = fou->sock;
+	struct sock *sk = sock->sk;
+
+	udp_del_offload(&fou->udp_offloads);
+
+	list_del(&fou->list);
+
+	/* Remove hooks into tunnel socket */
+	sk->sk_user_data = NULL;
+
+	sock_release(sock);
+
+	kfree(fou);
+}
+
+int fou_create(struct net *net, struct fou_cfg *cfg,
+	       struct socket **sockp)
+{
+	struct fou *fou = NULL;
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
+	/* Allocate FOU port structure */
+	fou = kzalloc(sizeof(*fou), GFP_KERNEL);
+	if (!fou) {
+		err = -ENOMEM;
+		goto error;
+	}
+
+	/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
+	fou->protocol = cfg->protocol;
+	fou->port =  cfg->udp_config.local_udp_port;
+	udp_sk(sk)->encap_rcv = fou_udp_recv;
+
+	udp_sk(sk)->encap_type = 1;
+	udp_encap_enable();
+
+	sk->sk_user_data = fou;
+	fou->sock = sock;
+
+	udp_set_convert_csum(sock->sk, true);
+
+	sk->sk_allocation = GFP_ATOMIC;
+
+	err = fou_add_to_port_list(fou);
+	if (err)
+		goto error;
+
+	if (sockp)
+		*sockp = sock;
+
+	return 0;
+
+error:
+	kfree(fou);
+	if (sock)
+		sock_release(sock);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(fou_create);
+
+int fou_destroy(struct net *net, struct fou_cfg *cfg)
+{
+	struct fou *fou;
+	u16 port = htons(cfg->udp_config.local_udp_port);
+	int err = -EINVAL;
+
+	spin_lock(&fou_lock);
+	list_for_each_entry(fou, &fou_list, list) {
+		if (fou->port == port) {
+			fou_release(fou);
+			err = 0;
+			break;
+		}
+	}
+	spin_unlock(&fou_lock);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(fou_destroy);
+
+static struct genl_family fou_nl_family = {
+	.id		= GENL_ID_GENERATE,
+	.hdrsize	= 0,
+	.name		= FOU_GENL_NAME,
+	.version	= FOU_GENL_VERSION,
+	.maxattr	= FOU_ATTR_MAX,
+	.netnsok	= true,
+};
+
+static struct nla_policy fou_nl_policy[FOU_ATTR_MAX + 1] = {
+	[FOU_ATTR_PORT] = { .type = NLA_U16, },
+	[FOU_ATTR_AF] = { .type = NLA_U8, },
+	[FOU_ATTR_IPPROTO] = { .type = NLA_U8, },
+};
+
+static int parse_nl_config(struct genl_info *info,
+			   struct fou_cfg *cfg)
+{
+	memset(cfg, 0, sizeof(*cfg));
+
+	cfg->udp_config.family = AF_INET;
+
+	if (info->attrs[FOU_ATTR_AF]) {
+		u8 family = nla_get_u8(info->attrs[FOU_ATTR_AF]);
+
+		if (family != AF_INET && family != AF_INET6)
+			return -EINVAL;
+
+		cfg->udp_config.family = family;
+	}
+
+	if (info->attrs[FOU_ATTR_PORT]) {
+		u16 port = nla_get_u16(info->attrs[FOU_ATTR_PORT]);
+
+		cfg->udp_config.local_udp_port = port;
+	}
+
+	if (info->attrs[FOU_ATTR_IPPROTO])
+		cfg->protocol = nla_get_u8(info->attrs[FOU_ATTR_IPPROTO]);
+}
+
+static int fou_nl_cmd_add_port(struct sk_buff *skb, struct genl_info *info)
+{
+	struct fou_cfg cfg;
+	int err;
+
+	err = parse_nl_config(info, &cfg);
+	if (err)
+		return err;
+
+	return fou_create(&init_net, &cfg, NULL);
+}
+
+static int fou_nl_cmd_rm_port(struct sk_buff *skb, struct genl_info *info)
+{
+	struct fou_cfg cfg;
+
+	parse_nl_config(info, &cfg);
+
+	return fou_destroy(&init_net, &cfg);
+}
+
+static const struct genl_ops fou_nl_ops[] = {
+	{
+		.cmd = FOU_CMD_ADD,
+		.doit = fou_nl_cmd_add_port,
+		.policy = fou_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = FOU_CMD_DEL,
+		.doit = fou_nl_cmd_rm_port,
+		.policy = fou_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+};
+
+static int __init fou_init(void)
+{
+	int ret;
+
+	ret = genl_register_family_with_ops(&fou_nl_family,
+					    fou_nl_ops);
+
+	return ret;
+}
+
+static void __exit fou_fini(void)
+{
+	struct fou *fou, *next;
+
+	genl_unregister_family(&fou_nl_family);
+
+	/* Close all the FOU sockets */
+
+	spin_lock(&fou_lock);
+	list_for_each_entry_safe(fou, next, &fou_list, list)
+		fou_release(fou);
+	spin_unlock(&fou_lock);
+}
+
+module_init(fou_init);
+module_exit(fou_fini);
+MODULE_AUTHOR("Tom Herbert <therbert@google.com>");
+MODULE_LICENSE("GPL");
-- 
2.1.0.rc2.206.gedb03e5
