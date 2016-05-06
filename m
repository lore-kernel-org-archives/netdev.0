From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v3 net-next 06/11] fou: Add encap ops for IPv6 tunnels
Date: Fri, 6 May 2016 15:12:01 -0700
Message-ID: <1462572726-566137-7-git-send-email-tom@herbertland.com>
References: <1462572726-566137-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49938 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758408AbcEFWMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 18:12:22 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u46MBM8A007808
	for <netdev@vger.kernel.org>; Fri, 6 May 2016 15:12:21 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22rxqt1fm8-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 06 May 2016 15:12:21 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 99d208c213d711e6ae7d0002c9521c9e-807fcc50 for <netdev@vger.kernel.org>;	Fri,
 06 May 2016 15:12:20 -0700
In-Reply-To: <1462572726-566137-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thsi packet adds IP tunnel encapsulation operations for IPv6. This
includes the infrastructure to add and delete operations. IPv6 variants
for fou6_build_header and gue6_build_header are added in a new
fou6 module. These encapsulation operations for fou and gue are
automatically added when the fou6 module loads.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/fou.h          |   2 +-
 include/net/ip6_tunnel.h   |  14 +++++
 net/ipv6/Makefile          |   4 +-
 net/ipv6/fou6.c            | 140 +++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_tunnel_core.c |  44 ++++++++++++++
 5 files changed, 202 insertions(+), 2 deletions(-)
 create mode 100644 net/ipv6/fou6.c
 create mode 100644 net/ipv6/ip6_tunnel_core.c

diff --git a/include/net/fou.h b/include/net/fou.h
index 7d2fda2..f5cc691 100644
--- a/include/net/fou.h
+++ b/include/net/fou.h
@@ -9,7 +9,7 @@
 #include <net/udp.h>
 
 size_t fou_encap_hlen(struct ip_tunnel_encap *e);
-static size_t gue_encap_hlen(struct ip_tunnel_encap *e);
+size_t gue_encap_hlen(struct ip_tunnel_encap *e);
 
 int __fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		       u8 *protocol, __be16 *sport, int type);
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index fb9e015..1c14c27 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -34,6 +34,20 @@ struct __ip6_tnl_parm {
 	__be32			o_key;
 };
 
+struct ip6_tnl_encap_ops {
+	size_t (*encap_hlen)(struct ip_tunnel_encap *e);
+	int (*build_header)(struct sk_buff *skb, struct ip_tunnel_encap *e,
+			    u8 *protocol, struct flowi6 *fl6);
+};
+
+extern const struct ip6_tnl_encap_ops __rcu *
+		ip6tun_encaps[MAX_IPTUN_ENCAP_OPS];
+
+int ip6_tnl_encap_add_ops(const struct ip6_tnl_encap_ops *op,
+			  unsigned int num);
+int ip6_tnl_encap_del_ops(const struct ip6_tnl_encap_ops *op,
+			  unsigned int num);
+
 /* IPv6 tunnel */
 struct ip6_tnl {
 	struct ip6_tnl __rcu *next;	/* next tunnel in list */
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 5e9d6bf..5cf4a1f 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -9,7 +9,7 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
 		raw.o icmp.o mcast.o reassembly.o tcp_ipv6.o ping.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o \
-		udp_offload.o
+		udp_offload.o ip6_tunnel_core.o
 
 ipv6-offload :=	ip6_offload.o tcpv6_offload.o exthdrs_offload.o
 
@@ -43,6 +43,8 @@ obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 
+obj-$(CONFIG_NET_FOU) += fou6.o
+
 obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o
 obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
 
diff --git a/net/ipv6/fou6.c b/net/ipv6/fou6.c
new file mode 100644
index 0000000..c972d0b
--- /dev/null
+++ b/net/ipv6/fou6.c
@@ -0,0 +1,140 @@
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/socket.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <net/fou.h>
+#include <net/ip.h>
+#include <net/ip6_tunnel.h>
+#include <net/ip6_checksum.h>
+#include <net/protocol.h>
+#include <net/udp.h>
+#include <net/udp_tunnel.h>
+
+static void fou6_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
+			   struct flowi6 *fl6, u8 *protocol, __be16 sport)
+{
+	struct udphdr *uh;
+
+	skb_push(skb, sizeof(struct udphdr));
+	skb_reset_transport_header(skb);
+
+	uh = udp_hdr(skb);
+
+	uh->dest = e->dport;
+	uh->source = sport;
+	uh->len = htons(skb->len);
+	udp6_set_csum(!(e->flags & TUNNEL_ENCAP_FLAG_CSUM6), skb,
+		      &fl6->saddr, &fl6->daddr, skb->len);
+
+	*protocol = IPPROTO_UDP;
+}
+
+int fou6_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+		      u8 *protocol, struct flowi6 *fl6)
+{
+	__be16 sport;
+	int err;
+	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM6 ?
+		SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+
+	err = __fou_build_header(skb, e, protocol, &sport, type);
+	if (err)
+		return err;
+
+	fou6_build_udp(skb, e, fl6, protocol, sport);
+
+	return 0;
+}
+EXPORT_SYMBOL(fou6_build_header);
+
+int gue6_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+		      u8 *protocol, struct flowi6 *fl6)
+{
+	__be16 sport;
+	int err;
+	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM6 ?
+		SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+
+	err = __gue_build_header(skb, e, protocol, &sport, type);
+	if (err)
+		return err;
+
+	fou6_build_udp(skb, e, fl6, protocol, sport);
+
+	return 0;
+}
+EXPORT_SYMBOL(gue6_build_header);
+
+#ifdef CONFIG_NET_FOU_IP_TUNNELS
+
+static const struct ip6_tnl_encap_ops fou_ip6tun_ops = {
+	.encap_hlen = fou_encap_hlen,
+	.build_header = fou6_build_header,
+};
+
+static const struct ip6_tnl_encap_ops gue_ip6tun_ops = {
+	.encap_hlen = gue_encap_hlen,
+	.build_header = gue6_build_header,
+};
+
+static int ip6_tnl_encap_add_fou_ops(void)
+{
+	int ret;
+
+	ret = ip6_tnl_encap_add_ops(&fou_ip6tun_ops, TUNNEL_ENCAP_FOU);
+	if (ret < 0) {
+		pr_err("can't add fou6 ops\n");
+		return ret;
+	}
+
+	ret = ip6_tnl_encap_add_ops(&gue_ip6tun_ops, TUNNEL_ENCAP_GUE);
+	if (ret < 0) {
+		pr_err("can't add gue6 ops\n");
+		ip6_tnl_encap_del_ops(&fou_ip6tun_ops, TUNNEL_ENCAP_FOU);
+		return ret;
+	}
+
+	return 0;
+}
+
+static void ip6_tnl_encap_del_fou_ops(void)
+{
+	ip6_tnl_encap_del_ops(&fou_ip6tun_ops, TUNNEL_ENCAP_FOU);
+	ip6_tnl_encap_del_ops(&gue_ip6tun_ops, TUNNEL_ENCAP_GUE);
+}
+
+#else
+
+static int ip6_tnl_encap_add_fou_ops(void)
+{
+	return 0;
+}
+
+static void ip6_tnl_encap_del_fou_ops(void)
+{
+}
+
+#endif
+
+static int __init fou6_init(void)
+{
+	int ret;
+
+	ret = ip6_tnl_encap_add_fou_ops();
+
+	return ret;
+}
+
+static void __exit fou6_fini(void)
+{
+	ip6_tnl_encap_del_fou_ops();
+}
+
+module_init(fou6_init);
+module_exit(fou6_fini);
+MODULE_AUTHOR("Tom Herbert <therbert@google.com>");
+MODULE_LICENSE("GPL");
diff --git a/net/ipv6/ip6_tunnel_core.c b/net/ipv6/ip6_tunnel_core.c
new file mode 100644
index 0000000..5f5b79e
--- /dev/null
+++ b/net/ipv6/ip6_tunnel_core.c
@@ -0,0 +1,44 @@
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/if.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/net.h>
+#include <linux/in6.h>
+#include <net/ip6_tunnel.h>
+
+const struct ip6_tnl_encap_ops __rcu *
+		ip6tun_encaps[MAX_IPTUN_ENCAP_OPS] __read_mostly;
+EXPORT_SYMBOL(ip6tun_encaps);
+
+int ip6_tnl_encap_add_ops(const struct ip6_tnl_encap_ops *ops,
+			  unsigned int num)
+{
+	if (num >= MAX_IPTUN_ENCAP_OPS)
+		return -ERANGE;
+
+	return !cmpxchg((const struct ip6_tnl_encap_ops **)
+			&ip6tun_encaps[num],
+			NULL, ops) ? 0 : -1;
+}
+EXPORT_SYMBOL(ip6_tnl_encap_add_ops);
+
+int ip6_tnl_encap_del_ops(const struct ip6_tnl_encap_ops *ops,
+			  unsigned int num)
+{
+	int ret;
+
+	if (num >= MAX_IPTUN_ENCAP_OPS)
+		return -ERANGE;
+
+	ret = (cmpxchg((const struct ip6_tnl_encap_ops **)
+		       &ip6tun_encaps[num],
+		       ops, NULL) == ops) ? 0 : -1;
+
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL(ip6_tnl_encap_del_ops);
+
-- 
2.8.0.rc2
