From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH V2 14/14] net: Remove code duplication between offload structures
Date: Thu, 15 Nov 2012 13:49:23 -0500
Message-ID: <1353005363-6974-15-git-send-email-vyasevic@redhat.com>
References: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768735Ab2KOStm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 13:49:42 -0500
In-Reply-To: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the offload callbacks into its own structure.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/netdevice.h |   10 +++++++---
 include/net/protocol.h    |   10 +++-------
 net/core/dev.c            |   14 +++++++-------
 net/ipv4/af_inet.c        |   44 +++++++++++++++++++++++++-------------------
 net/ipv6/ip6_offload.c    |   28 +++++++++++++++-------------
 net/ipv6/tcpv6_offload.c  |   10 ++++++----
 net/ipv6/udp_offload.c    |    6 ++++--
 7 files changed, 67 insertions(+), 55 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 12c217d..a91828a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1505,15 +1505,19 @@ struct packet_type {
 	struct list_head	list;
 };
 
-struct packet_offload {
-	__be16			type;	/* This is really htons(ether_type). */
+struct offload_callbacks {
 	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
 						netdev_features_t features);
 	int			(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
 					       struct sk_buff *skb);
 	int			(*gro_complete)(struct sk_buff *skb);
-	struct list_head	list;
+};
+
+struct packet_offload {
+	__be16			 type;	/* This is really htons(ether_type). */
+	struct offload_callbacks callbacks;
+	struct list_head	 list;
 };
 
 #include <linux/notifier.h>
diff --git a/include/net/protocol.h b/include/net/protocol.h
index 2c90794..047c047 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -29,6 +29,7 @@
 #if IS_ENABLED(CONFIG_IPV6)
 #include <linux/ipv6.h>
 #endif
+#include <linux/netdevice.h>
 
 /* This is one larger than the largest protocol value that can be
  * found in an ipv4 or ipv6 header.  Since in both cases the protocol
@@ -63,13 +64,8 @@ struct inet6_protocol {
 #endif
 
 struct net_offload {
-	int			(*gso_send_check)(struct sk_buff *skb);
-	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb,
-					       netdev_features_t features);
-	struct sk_buff	      **(*gro_receive)(struct sk_buff **head,
-					       struct sk_buff *skb);
-	int			(*gro_complete)(struct sk_buff *skb);
-	unsigned int		flags;	/* Flags used by IPv6 for now */
+	struct offload_callbacks callbacks;
+	unsigned int		 flags;	/* Flags used by IPv6 for now */
 };
 /* This should be set for any extension header which is compatible with GSO. */
 #define INET6_PROTO_GSO_EXTHDR	0x1
diff --git a/net/core/dev.c b/net/core/dev.c
index 13f9b85..3ee2cf1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2102,16 +2102,16 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &offload_base, list) {
-		if (ptype->type == type && ptype->gso_segment) {
+		if (ptype->type == type && ptype->callbacks.gso_segment) {
 			if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
-				err = ptype->gso_send_check(skb);
+				err = ptype->callbacks.gso_send_check(skb);
 				segs = ERR_PTR(err);
 				if (err || skb_gso_ok(skb, features))
 					break;
 				__skb_push(skb, (skb->data -
 						 skb_network_header(skb)));
 			}
-			segs = ptype->gso_segment(skb, features);
+			segs = ptype->callbacks.gso_segment(skb, features);
 			break;
 		}
 	}
@@ -3533,10 +3533,10 @@ static int napi_gro_complete(struct sk_buff *skb)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
-		if (ptype->type != type || !ptype->gro_complete)
+		if (ptype->type != type || !ptype->callbacks.gro_complete)
 			continue;
 
-		err = ptype->gro_complete(skb);
+		err = ptype->callbacks.gro_complete(skb);
 		break;
 	}
 	rcu_read_unlock();
@@ -3598,7 +3598,7 @@ enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
-		if (ptype->type != type || !ptype->gro_receive)
+		if (ptype->type != type || !ptype->callbacks.gro_receive)
 			continue;
 
 		skb_set_network_header(skb, skb_gro_offset(skb));
@@ -3608,7 +3608,7 @@ enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 		NAPI_GRO_CB(skb)->flush = 0;
 		NAPI_GRO_CB(skb)->free = 0;
 
-		pp = ptype->gro_receive(&napi->gro_list, skb);
+		pp = ptype->callbacks.gro_receive(&napi->gro_list, skb);
 		break;
 	}
 	rcu_read_unlock();
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9f2e7fd..3067e04 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1276,8 +1276,8 @@ static int inet_gso_send_check(struct sk_buff *skb)
 
 	rcu_read_lock();
 	ops = rcu_dereference(inet_offloads[proto]);
-	if (likely(ops && ops->gso_send_check))
-		err = ops->gso_send_check(skb);
+	if (likely(ops && ops->callbacks.gso_send_check))
+		err = ops->callbacks.gso_send_check(skb);
 	rcu_read_unlock();
 
 out:
@@ -1326,8 +1326,8 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 
 	rcu_read_lock();
 	ops = rcu_dereference(inet_offloads[proto]);
-	if (likely(ops && ops->gso_segment))
-		segs = ops->gso_segment(skb, features);
+	if (likely(ops && ops->callbacks.gso_segment))
+		segs = ops->callbacks.gso_segment(skb, features);
 	rcu_read_unlock();
 
 	if (!segs || IS_ERR(segs))
@@ -1379,7 +1379,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 
 	rcu_read_lock();
 	ops = rcu_dereference(inet_offloads[proto]);
-	if (!ops || !ops->gro_receive)
+	if (!ops || !ops->callbacks.gro_receive)
 		goto out_unlock;
 
 	if (*(u8 *)iph != 0x45)
@@ -1420,7 +1420,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	skb_gro_pull(skb, sizeof(*iph));
 	skb_set_transport_header(skb, skb_gro_offset(skb));
 
-	pp = ops->gro_receive(head, skb);
+	pp = ops->callbacks.gro_receive(head, skb);
 
 out_unlock:
 	rcu_read_unlock();
@@ -1444,10 +1444,10 @@ static int inet_gro_complete(struct sk_buff *skb)
 
 	rcu_read_lock();
 	ops = rcu_dereference(inet_offloads[proto]);
-	if (WARN_ON(!ops || !ops->gro_complete))
+	if (WARN_ON(!ops || !ops->callbacks.gro_complete))
 		goto out_unlock;
 
-	err = ops->gro_complete(skb);
+	err = ops->callbacks.gro_complete(skb);
 
 out_unlock:
 	rcu_read_unlock();
@@ -1563,11 +1563,13 @@ static const struct net_protocol tcp_protocol = {
 };
 
 static const struct net_offload tcp_offload = {
-	.gso_send_check	=	tcp_v4_gso_send_check,
-	.gso_segment	=	tcp_tso_segment,
-	.gro_receive	=	tcp4_gro_receive,
-	.gro_complete	=	tcp4_gro_complete,
-};
+	.callbacks = {
+		.gso_send_check	=	tcp_v4_gso_send_check,
+		.gso_segment	=	tcp_tso_segment,
+		.gro_receive	=	tcp4_gro_receive,
+		.gro_complete	=	tcp4_gro_complete,
+	},
+};	  
 
 static const struct net_protocol udp_protocol = {
 	.handler =	udp_rcv,
@@ -1577,8 +1579,10 @@ static const struct net_protocol udp_protocol = {
 };
 
 static const struct net_offload udp_offload = {
-	.gso_send_check = udp4_ufo_send_check,
-	.gso_segment = udp4_ufo_fragment,
+	.callbacks = {
+		.gso_send_check = udp4_ufo_send_check,
+		.gso_segment = udp4_ufo_fragment,
+	},
 };
 
 static const struct net_protocol icmp_protocol = {
@@ -1667,10 +1671,12 @@ static int ipv4_proc_init(void);
 
 static struct packet_offload ip_packet_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IP),
-	.gso_send_check = inet_gso_send_check,
-	.gso_segment = inet_gso_segment,
-	.gro_receive = inet_gro_receive,
-	.gro_complete = inet_gro_complete,
+	.callbacks = {
+		.gso_send_check = inet_gso_send_check,
+		.gso_segment = inet_gso_segment,
+		.gro_receive = inet_gro_receive,
+		.gro_complete = inet_gro_complete,
+	},
 };
 
 static int __init ipv4_offload_init(void)
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 63d79d9..f26f0da 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -70,9 +70,9 @@ static int ipv6_gso_send_check(struct sk_buff *skb)
 	ops = rcu_dereference(inet6_offloads[
 		ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr)]);
 
-	if (likely(ops && ops->gso_send_check)) {
+	if (likely(ops && ops->callbacks.gso_send_check)) {
 		skb_reset_transport_header(skb);
-		err = ops->gso_send_check(skb);
+		err = ops->callbacks.gso_send_check(skb);
 	}
 	rcu_read_unlock();
 
@@ -113,9 +113,9 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	proto = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
 	rcu_read_lock();
 	ops = rcu_dereference(inet6_offloads[proto]);
-	if (likely(ops && ops->gso_segment)) {
+	if (likely(ops && ops->callbacks.gso_segment)) {
 		skb_reset_transport_header(skb);
-		segs = ops->gso_segment(skb, features);
+		segs = ops->callbacks.gso_segment(skb, features);
 	}
 	rcu_read_unlock();
 
@@ -173,7 +173,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	rcu_read_lock();
 	proto = iph->nexthdr;
 	ops = rcu_dereference(inet6_offloads[proto]);
-	if (!ops || !ops->gro_receive) {
+	if (!ops || !ops->callbacks.gro_receive) {
 		__pskb_pull(skb, skb_gro_offset(skb));
 		proto = ipv6_gso_pull_exthdrs(skb, proto);
 		skb_gro_pull(skb, -skb_transport_offset(skb));
@@ -181,7 +181,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 		__skb_push(skb, skb_gro_offset(skb));
 
 		ops = rcu_dereference(inet6_offloads[proto]);
-		if (!ops || !ops->gro_receive)
+		if (!ops || !ops->callbacks.gro_receive)
 			goto out_unlock;
 
 		iph = ipv6_hdr(skb);
@@ -220,7 +220,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	csum = skb->csum;
 	skb_postpull_rcsum(skb, iph, skb_network_header_len(skb));
 
-	pp = ops->gro_receive(head, skb);
+	pp = ops->callbacks.gro_receive(head, skb);
 
 	skb->csum = csum;
 
@@ -244,10 +244,10 @@ static int ipv6_gro_complete(struct sk_buff *skb)
 
 	rcu_read_lock();
 	ops = rcu_dereference(inet6_offloads[NAPI_GRO_CB(skb)->proto]);
-	if (WARN_ON(!ops || !ops->gro_complete))
+	if (WARN_ON(!ops || !ops->callbacks.gro_complete))
 		goto out_unlock;
 
-	err = ops->gro_complete(skb);
+	err = ops->callbacks.gro_complete(skb);
 
 out_unlock:
 	rcu_read_unlock();
@@ -257,10 +257,12 @@ out_unlock:
 
 static struct packet_offload ipv6_packet_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IPV6),
-	.gso_send_check = ipv6_gso_send_check,
-	.gso_segment = ipv6_gso_segment,
-	.gro_receive = ipv6_gro_receive,
-	.gro_complete = ipv6_gro_complete,
+	.callbacks = {
+		.gso_send_check = ipv6_gso_send_check,
+		.gso_segment = ipv6_gso_segment,
+		.gro_receive = ipv6_gro_receive,
+		.gro_complete = ipv6_gro_complete,
+	},
 };
 
 static int __init ipv6_offload_init(void)
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index 3a27fe6..2ec6bf6 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -81,10 +81,12 @@ static int tcp6_gro_complete(struct sk_buff *skb)
 }
 
 static const struct net_offload tcpv6_offload = {
-	.gso_send_check	=	tcp_v6_gso_send_check,
-	.gso_segment	=	tcp_tso_segment,
-	.gro_receive	=	tcp6_gro_receive,
-	.gro_complete	=	tcp6_gro_complete,
+	.callbacks = {
+		.gso_send_check	=	tcp_v6_gso_send_check,
+		.gso_segment	=	tcp_tso_segment,
+		.gro_receive	=	tcp6_gro_receive,
+		.gro_complete	=	tcp6_gro_complete,
+	},
 };
 
 int __init tcpv6_offload_init(void)
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 979e4ab..8e01c44 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -107,8 +107,10 @@ out:
 	return segs;
 }
 static const struct net_offload udpv6_offload = {
-	.gso_send_check =	udp6_ufo_send_check,
-	.gso_segment	=	udp6_ufo_fragment,
+	.callbacks = {
+		.gso_send_check =	udp6_ufo_send_check,
+		.gso_segment	=	udp6_ufo_fragment,
+	},
 };
 
 int __init udp_offload_init(void)
-- 
1.7.7.6
