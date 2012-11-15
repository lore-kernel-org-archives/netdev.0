From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH V2 13/14] ipv6: Pull IPv6 GSO registration out of the module
Date: Thu, 15 Nov 2012 13:49:22 -0500
Message-ID: <1353005363-6974-14-git-send-email-vyasevic@redhat.com>
References: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60797 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768734Ab2KOStk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 13:49:40 -0500
In-Reply-To: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sing GSO support is now separate, pull it out of the module
and make it its own init call.
Remove the cleanup functions as they are no longer called.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/net/protocol.h     |   11 ++++++-----
 net/ipv6/Makefile          |    6 +++---
 net/ipv6/af_inet6.c        |    3 ---
 net/ipv6/exthdrs.c         |   10 +---------
 net/ipv6/exthdrs_offload.c |    6 ------
 net/ipv6/ip6_offload.c     |   17 ++++++++++++-----
 net/ipv6/ip6_offload.h     |    8 --------
 net/ipv6/protocol.c        |   20 ++++++++++++--------
 net/ipv6/tcp_ipv6.c        |   10 +---------
 net/ipv6/tcpv6_offload.c   |    5 -----
 net/ipv6/udp.c             |   10 +---------
 net/ipv6/udp_offload.c     |    5 -----
 12 files changed, 36 insertions(+), 75 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 7019c16..2c90794 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -25,6 +25,7 @@
 #define _PROTOCOL_H
 
 #include <linux/in6.h>
+#include <linux/skbuff.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <linux/ipv6.h>
 #endif
@@ -59,8 +60,6 @@ struct inet6_protocol {
 
 #define INET6_PROTO_NOPOLICY	0x1
 #define INET6_PROTO_FINAL	0x2
-/* This should be set for any extension header which is compatible with GSO. */
-#define INET6_PROTO_GSO_EXTHDR	0x4
 #endif
 
 struct net_offload {
@@ -72,6 +71,8 @@ struct net_offload {
 	int			(*gro_complete)(struct sk_buff *skb);
 	unsigned int		flags;	/* Flags used by IPv6 for now */
 };
+/* This should be set for any extension header which is compatible with GSO. */
+#define INET6_PROTO_GSO_EXTHDR	0x1
 
 /* This is used to register socket interfaces for IP protocols.  */
 struct inet_protosw {
@@ -93,10 +94,10 @@ struct inet_protosw {
 
 extern const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS];
 extern const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS];
+extern const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS];
 
 #if IS_ENABLED(CONFIG_IPV6)
 extern const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS];
-extern const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS];
 #endif
 
 extern int	inet_add_protocol(const struct net_protocol *prot, unsigned char num);
@@ -109,10 +110,10 @@ extern void	inet_unregister_protosw(struct inet_protosw *p);
 #if IS_ENABLED(CONFIG_IPV6)
 extern int	inet6_add_protocol(const struct inet6_protocol *prot, unsigned char num);
 extern int	inet6_del_protocol(const struct inet6_protocol *prot, unsigned char num);
-extern int	inet6_add_offload(const struct net_offload *prot, unsigned char num);
-extern int	inet6_del_offload(const struct net_offload *prot, unsigned char num);
 extern int	inet6_register_protosw(struct inet_protosw *p);
 extern void	inet6_unregister_protosw(struct inet_protosw *p);
 #endif
+extern int	inet6_add_offload(const struct net_offload *prot, unsigned char num);
+extern int	inet6_del_offload(const struct net_offload *prot, unsigned char num);
 
 #endif	/* _PROTOCOL_H */
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index cdca302..04a475d 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -7,7 +7,7 @@ obj-$(CONFIG_IPV6) += ipv6.o
 ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		addrlabel.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
-		raw.o protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
+		raw.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o
 
 ipv6-offload :=	ip6_offload.o tcpv6_offload.o udp_offload.o exthdrs_offload.o
@@ -23,7 +23,6 @@ ipv6-$(CONFIG_PROC_FS) += proc.o
 ipv6-$(CONFIG_SYN_COOKIES) += syncookies.o
 
 ipv6-objs += $(ipv6-y)
-ipv6-objs += $(ipv6-offload)
 
 obj-$(CONFIG_INET6_AH) += ah6.o
 obj-$(CONFIG_INET6_ESP) += esp6.o
@@ -41,6 +40,7 @@ obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 
-obj-y += addrconf_core.o exthdrs_core.o output_core.o
+obj-y += addrconf_core.o exthdrs_core.o output_core.o protocol.o
+obj-y += $(ipv6-offload)
 
 obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index c84d5ba..7bafc51 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -62,7 +62,6 @@
 
 #include <asm/uaccess.h>
 #include <linux/mroute6.h>
-#include "ip6_offload.h"
 
 MODULE_AUTHOR("Cast of dozens");
 MODULE_DESCRIPTION("IPv6 protocol stack for Linux");
@@ -707,14 +706,12 @@ static struct packet_type ipv6_packet_type __read_mostly = {
 
 static int __init ipv6_packet_init(void)
 {
-	ipv6_offload_init();
 	dev_add_pack(&ipv6_packet_type);
 	return 0;
 }
 
 static void ipv6_packet_cleanup(void)
 {
-	ipv6_offload_cleanup();
 	dev_remove_pack(&ipv6_packet_type);
 }
 
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index e9b5b33..bb02d2a 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -48,7 +48,6 @@
 #endif
 
 #include <asm/uaccess.h>
-#include "ip6_offload.h"
 
 /*
  *	Parsing tlv encoded headers.
@@ -502,13 +501,9 @@ int __init ipv6_exthdrs_init(void)
 {
 	int ret;
 
-	ret = ipv6_exthdrs_offload_init();
-	if (ret)
-		goto out;
-
 	ret = inet6_add_protocol(&rthdr_protocol, IPPROTO_ROUTING);
 	if (ret)
-		goto out_offload;
+		goto out;
 
 	ret = inet6_add_protocol(&destopt_protocol, IPPROTO_DSTOPTS);
 	if (ret)
@@ -524,14 +519,11 @@ out_destopt:
 	inet6_del_protocol(&destopt_protocol, IPPROTO_DSTOPTS);
 out_rthdr:
 	inet6_del_protocol(&rthdr_protocol, IPPROTO_ROUTING);
-out_offload:
-	ipv6_exthdrs_offload_exit();
 	goto out;
 };
 
 void ipv6_exthdrs_exit(void)
 {
-	ipv6_exthdrs_offload_exit();
 	inet6_del_protocol(&nodata_protocol, IPPROTO_NONE);
 	inet6_del_protocol(&destopt_protocol, IPPROTO_DSTOPTS);
 	inet6_del_protocol(&rthdr_protocol, IPPROTO_ROUTING);
diff --git a/net/ipv6/exthdrs_offload.c b/net/ipv6/exthdrs_offload.c
index 271bf4a..cf77f3a 100644
--- a/net/ipv6/exthdrs_offload.c
+++ b/net/ipv6/exthdrs_offload.c
@@ -39,9 +39,3 @@ out_rt:
 	inet_del_offload(&rthdr_offload, IPPROTO_ROUTING);
 	goto out;
 }
-
-void ipv6_exthdrs_offload_exit(void)
-{
-	inet_del_offload(&rthdr_offload, IPPROTO_ROUTING);
-	inet_del_offload(&rthdr_offload, IPPROTO_DSTOPTS);
-}
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 01cf983..63d79d9 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -12,6 +12,7 @@
 #include <linux/socket.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
+#include <linux/printk.h>
 
 #include <net/protocol.h>
 #include <net/ipv6.h>
@@ -262,12 +263,18 @@ static struct packet_offload ipv6_packet_offload __read_mostly = {
 	.gro_complete = ipv6_gro_complete,
 };
 
-void __init ipv6_offload_init(void)
+static int __init ipv6_offload_init(void)
 {
+
+	if (tcpv6_offload_init() < 0)
+		pr_crit("%s: Cannot add TCP protocol offload\n", __func__);
+	if (udp_offload_init() < 0)
+		pr_crit("%s: Cannot add UDP protocol offload\n", __func__);
+	if (ipv6_exthdrs_offload_init() < 0)
+		pr_crit("%s: Cannot add EXTHDRS protocol offload\n", __func__);
+
 	dev_add_offload(&ipv6_packet_offload);
+	return 0;
 }
 
-void ipv6_offload_cleanup(void)
-{
-	dev_remove_offload(&ipv6_packet_offload);
-}
+fs_initcall(ipv6_offload_init);
diff --git a/net/ipv6/ip6_offload.h b/net/ipv6/ip6_offload.h
index 4e88ddb..2e155c6 100644
--- a/net/ipv6/ip6_offload.h
+++ b/net/ipv6/ip6_offload.h
@@ -12,15 +12,7 @@
 #define __ip6_offload_h
 
 int ipv6_exthdrs_offload_init(void);
-void ipv6_exthdrs_offload_exit(void);
-
 int udp_offload_init(void);
-void udp_offload_cleanup(void);
-
 int tcpv6_offload_init(void);
-void tcpv6_offload_cleanup(void);
-
-extern void ipv6_offload_init(void);
-extern void ipv6_offload_cleanup(void);
 
 #endif
diff --git a/net/ipv6/protocol.c b/net/ipv6/protocol.c
index f7c53a7..22d1bd4 100644
--- a/net/ipv6/protocol.c
+++ b/net/ipv6/protocol.c
@@ -25,8 +25,9 @@
 #include <linux/spinlock.h>
 #include <net/protocol.h>
 
+#if IS_ENABLED(CONFIG_IPV6)
 const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS] __read_mostly;
-const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS] __read_mostly;
+EXPORT_SYMBOL(inet6_protos);
 
 int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char protocol)
 {
@@ -35,13 +36,6 @@ int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char protocol
 }
 EXPORT_SYMBOL(inet6_add_protocol);
 
-int inet6_add_offload(const struct net_offload *prot, unsigned char protocol)
-{
-	return !cmpxchg((const struct net_offload **)&inet6_offloads[protocol],
-			NULL, prot) ? 0 : -1;
-}
-EXPORT_SYMBOL(inet6_add_offload);
-
 /*
  *	Remove a protocol from the hash tables.
  */
@@ -58,6 +52,16 @@ int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char protocol
 	return ret;
 }
 EXPORT_SYMBOL(inet6_del_protocol);
+#endif
+
+const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS] __read_mostly;
+
+int inet6_add_offload(const struct net_offload *prot, unsigned char protocol)
+{
+	return !cmpxchg((const struct net_offload **)&inet6_offloads[protocol],
+			NULL, prot) ? 0 : -1;
+}
+EXPORT_SYMBOL(inet6_add_offload);
 
 int inet6_del_offload(const struct net_offload *prot, unsigned char protocol)
 {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 58fabc5..c5d2d61 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -71,7 +71,6 @@
 
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>
-#include "ip6_offload.h"
 
 static void	tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb);
 static void	tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
@@ -2004,13 +2003,9 @@ int __init tcpv6_init(void)
 {
 	int ret;
 
-	ret = tcpv6_offload_init();
-	if (ret)
-		goto out;
-
 	ret = inet6_add_protocol(&tcpv6_protocol, IPPROTO_TCP);
 	if (ret)
-		goto out_offload;
+		goto out;
 
 	/* register inet6 protocol */
 	ret = inet6_register_protosw(&tcpv6_protosw);
@@ -2027,8 +2022,6 @@ out_tcpv6_protosw:
 	inet6_unregister_protosw(&tcpv6_protosw);
 out_tcpv6_protocol:
 	inet6_del_protocol(&tcpv6_protocol, IPPROTO_TCP);
-out_offload:
-	tcpv6_offload_cleanup();
 	goto out;
 }
 
@@ -2037,5 +2030,4 @@ void tcpv6_exit(void)
 	unregister_pernet_subsys(&tcpv6_net_ops);
 	inet6_unregister_protosw(&tcpv6_protosw);
 	inet6_del_protocol(&tcpv6_protocol, IPPROTO_TCP);
-	tcpv6_offload_cleanup();
 }
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index edeafed..3a27fe6 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -91,8 +91,3 @@ int __init tcpv6_offload_init(void)
 {
 	return inet6_add_offload(&tcpv6_offload, IPPROTO_TCP);
 }
-
-void tcpv6_offload_cleanup(void)
-{
-	inet6_del_offload(&tcpv6_offload, IPPROTO_TCP);
-}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 013fef7..dfaa29b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -50,7 +50,6 @@
 #include <linux/seq_file.h>
 #include <trace/events/skb.h>
 #include "udp_impl.h"
-#include "ip6_offload.h"
 
 int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 {
@@ -1472,13 +1471,9 @@ int __init udpv6_init(void)
 {
 	int ret;
 
-	ret = udp_offload_init();
-	if (ret)
-		goto out;
-
 	ret = inet6_add_protocol(&udpv6_protocol, IPPROTO_UDP);
 	if (ret)
-		goto out_offload;
+		goto out;
 
 	ret = inet6_register_protosw(&udpv6_protosw);
 	if (ret)
@@ -1488,8 +1483,6 @@ out:
 
 out_udpv6_protocol:
 	inet6_del_protocol(&udpv6_protocol, IPPROTO_UDP);
-out_offload:
-	udp_offload_cleanup();
 	goto out;
 }
 
@@ -1497,5 +1490,4 @@ void udpv6_exit(void)
 {
 	inet6_unregister_protosw(&udpv6_protosw);
 	inet6_del_protocol(&udpv6_protocol, IPPROTO_UDP);
-	udp_offload_cleanup();
 }
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index f964d2b..979e4ab 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -115,8 +115,3 @@ int __init udp_offload_init(void)
 {
 	return inet6_add_offload(&udpv6_offload, IPPROTO_UDP);
 }
-
-void udp_offload_cleanup(void)
-{
-	inet6_del_offload(&udpv6_offload, IPPROTO_UDP);
-}
-- 
1.7.7.6
