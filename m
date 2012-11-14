From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH 04/13] ipv6: Add new offload registration infrastructure.
Date: Tue, 13 Nov 2012 20:24:05 -0500
Message-ID: <1352856254-29667-5-git-send-email-vyasevic@redhat.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Cc: eric.dumazet@gmail.com, davem@davemloft.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47246 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932376Ab2KNBYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 20:24:25 -0500
In-Reply-To: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a new data structure for IPv6 protocols that holds GRO/GSO
callbacks and a new array to track the protocols that register GRO/GSO.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/net/protocol.h |    4 ++++
 net/ipv6/exthdrs.c     |    8 ++++++++
 net/ipv6/protocol.c    |   21 +++++++++++++++++++++
 net/ipv6/tcp_ipv6.c    |    7 +++++++
 net/ipv6/udp.c         |    5 +++++
 5 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index d8ecb17..637e1bb 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -84,6 +84,7 @@ struct net_offload {
 	struct sk_buff	      **(*gro_receive)(struct sk_buff **head,
 					       struct sk_buff *skb);
 	int			(*gro_complete)(struct sk_buff *skb);
+	unsigned int		flags;	/* Flags used by IPv6 for now */
 };
 
 /* This is used to register socket interfaces for IP protocols.  */
@@ -109,6 +110,7 @@ extern const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS];
 
 #if IS_ENABLED(CONFIG_IPV6)
 extern const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS];
+extern const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS];
 #endif
 
 extern int	inet_add_protocol(const struct net_protocol *prot, unsigned char num);
@@ -121,6 +123,8 @@ extern void	inet_unregister_protosw(struct inet_protosw *p);
 #if IS_ENABLED(CONFIG_IPV6)
 extern int	inet6_add_protocol(const struct inet6_protocol *prot, unsigned char num);
 extern int	inet6_del_protocol(const struct inet6_protocol *prot, unsigned char num);
+extern int	inet6_add_offload(const struct net_offload *prot, unsigned char num);
+extern int	inet6_del_offload(const struct net_offload *prot, unsigned char num);
 extern int	inet6_register_protosw(struct inet_protosw *p);
 extern void	inet6_unregister_protosw(struct inet_protosw *p);
 #endif
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index fa3d9c3..8c01574 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -531,11 +531,19 @@ static const struct inet6_protocol rthdr_protocol = {
 	.flags		=	INET6_PROTO_NOPOLICY | INET6_PROTO_GSO_EXTHDR,
 };
 
+static const struct net_offload rthdr_offload = {
+	.flags		=	INET6_PROTO_GSO_EXTHDR,
+};
+
 static const struct inet6_protocol destopt_protocol = {
 	.handler	=	ipv6_destopt_rcv,
 	.flags		=	INET6_PROTO_NOPOLICY | INET6_PROTO_GSO_EXTHDR,
 };
 
+static const struct net_offload dstopt_offload = {
+	.flags		=	INET6_PROTO_GSO_EXTHDR,
+};
+
 static const struct inet6_protocol nodata_protocol = {
 	.handler	=	dst_discard,
 	.flags		=	INET6_PROTO_NOPOLICY,
diff --git a/net/ipv6/protocol.c b/net/ipv6/protocol.c
index 053082d..f7c53a7 100644
--- a/net/ipv6/protocol.c
+++ b/net/ipv6/protocol.c
@@ -26,6 +26,7 @@
 #include <net/protocol.h>
 
 const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS] __read_mostly;
+const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS] __read_mostly;
 
 int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char protocol)
 {
@@ -34,6 +35,13 @@ int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char protocol
 }
 EXPORT_SYMBOL(inet6_add_protocol);
 
+int inet6_add_offload(const struct net_offload *prot, unsigned char protocol)
+{
+	return !cmpxchg((const struct net_offload **)&inet6_offloads[protocol],
+			NULL, prot) ? 0 : -1;
+}
+EXPORT_SYMBOL(inet6_add_offload);
+
 /*
  *	Remove a protocol from the hash tables.
  */
@@ -50,3 +58,16 @@ int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char protocol
 	return ret;
 }
 EXPORT_SYMBOL(inet6_del_protocol);
+
+int inet6_del_offload(const struct net_offload *prot, unsigned char protocol)
+{
+	int ret;
+
+	ret = (cmpxchg((const struct net_offload **)&inet6_offloads[protocol],
+		       prot, NULL) == prot) ? 0 : -1;
+
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL(inet6_del_offload);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 26175bf..8ce2c30 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2070,6 +2070,13 @@ static const struct inet6_protocol tcpv6_protocol = {
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
+static const struct net_offload tcpv6_offload = {
+	.gso_send_check	=	tcp_v6_gso_send_check,
+	.gso_segment	=	tcp_tso_segment,
+	.gro_receive	=	tcp6_gro_receive,
+	.gro_complete	=	tcp6_gro_complete,
+};
+
 static struct inet_protosw tcpv6_protosw = {
 	.type		=	SOCK_STREAM,
 	.protocol	=	IPPROTO_TCP,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index fc99972..3ad44e1 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1443,6 +1443,11 @@ static const struct inet6_protocol udpv6_protocol = {
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
+static const struct net_offload udpv6_offload = {
+	.gso_send_check =	udp6_ufo_send_check,
+	.gso_segment	=	udp6_ufo_fragment,
+};
+
 /* ------------------------------------------------------------------------ */
 #ifdef CONFIG_PROC_FS
 
-- 
1.7.7.6
