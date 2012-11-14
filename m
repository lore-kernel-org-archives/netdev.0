From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH 03/13] net: Add net protocol offload registration infrustructure
Date: Tue, 13 Nov 2012 20:24:04 -0500
Message-ID: <1352856254-29667-4-git-send-email-vyasevic@redhat.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Cc: eric.dumazet@gmail.com, davem@davemloft.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25236 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932315Ab2KNBYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 20:24:24 -0500
In-Reply-To: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a new data structure for IPv4 protocols that holds GRO/GSO
callbacks and a new array to track the protocols that register GRO/GSO.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/net/protocol.h |   12 ++++++++++++
 net/ipv4/af_inet.c     |   12 ++++++++++++
 net/ipv4/protocol.c    |   22 +++++++++++++++++++++-
 3 files changed, 45 insertions(+), 1 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 929528c..d8ecb17 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -77,6 +77,15 @@ struct inet6_protocol {
 #define INET6_PROTO_GSO_EXTHDR	0x4
 #endif
 
+struct net_offload {
+	int			(*gso_send_check)(struct sk_buff *skb);
+	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb,
+					       netdev_features_t features);
+	struct sk_buff	      **(*gro_receive)(struct sk_buff **head,
+					       struct sk_buff *skb);
+	int			(*gro_complete)(struct sk_buff *skb);
+};
+
 /* This is used to register socket interfaces for IP protocols.  */
 struct inet_protosw {
 	struct list_head list;
@@ -96,6 +105,7 @@ struct inet_protosw {
 #define INET_PROTOSW_ICSK      0x04  /* Is this an inet_connection_sock? */
 
 extern const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS];
+extern const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS];
 
 #if IS_ENABLED(CONFIG_IPV6)
 extern const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS];
@@ -103,6 +113,8 @@ extern const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS];
 
 extern int	inet_add_protocol(const struct net_protocol *prot, unsigned char num);
 extern int	inet_del_protocol(const struct net_protocol *prot, unsigned char num);
+extern int	inet_add_offload(const struct net_offload *prot, unsigned char num);
+extern int	inet_del_offload(const struct net_offload *prot, unsigned char num);
 extern void	inet_register_protosw(struct inet_protosw *p);
 extern void	inet_unregister_protosw(struct inet_protosw *p);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 4c99c5f..3918d86 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1566,6 +1566,13 @@ static const struct net_protocol tcp_protocol = {
 	.netns_ok	=	1,
 };
 
+static const struct net_offload tcp_offload = {
+	.gso_send_check	=	tcp_v4_gso_send_check,
+	.gso_segment	=	tcp_tso_segment,
+	.gro_receive	=	tcp4_gro_receive,
+	.gro_complete	=	tcp4_gro_complete,
+};
+
 static const struct net_protocol udp_protocol = {
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
@@ -1575,6 +1582,11 @@ static const struct net_protocol udp_protocol = {
 	.netns_ok =	1,
 };
 
+static const struct net_offload udp_offload = {
+	.gso_send_check = udp4_ufo_send_check,
+	.gso_segment = udp4_ufo_fragment,
+};
+
 static const struct net_protocol icmp_protocol = {
 	.handler =	icmp_rcv,
 	.err_handler =	ping_err,
diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index 8918eff..1278db8 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -29,6 +29,7 @@
 #include <net/protocol.h>
 
 const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS] __read_mostly;
+const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS] __read_mostly;
 
 /*
  *	Add a protocol handler to the hash tables
@@ -41,6 +42,13 @@ int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
 }
 EXPORT_SYMBOL(inet_add_protocol);
 
+int inet_add_offload(const struct net_offload *prot, unsigned char protocol)
+{
+	return !cmpxchg((const struct net_offload **)&inet_offloads[protocol],
+			NULL, prot) ? 0 : -1;
+}
+EXPORT_SYMBOL(inet_add_offload);
+
 /*
  *	Remove a protocol from the hash tables.
  */
@@ -56,4 +64,16 @@ int inet_del_protocol(const struct net_protocol *prot, unsigned char protocol)
 
 	return ret;
 }
-EXPORT_SYMBOL(inet_del_protocol);
+
+int inet_del_offload(const struct net_offload *prot, unsigned char protocol)
+{
+	int ret;
+
+	ret = (cmpxchg((const struct net_offload **)&inet_offloads[protocol],
+		       prot, NULL) == prot) ? 0 : -1;
+
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL(inet_del_offload);
-- 
1.7.7.6
