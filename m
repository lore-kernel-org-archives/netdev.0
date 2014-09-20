From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/3] net: Remove gso_send_check as an offload callback
Date: Sat, 20 Sep 2014 14:52:30 -0700
Message-ID: <1411249950-6795-4-git-send-email-therbert@google.com>
References: <1411249950-6795-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:55320 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbaITVxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 17:53:13 -0400
Received: by mail-pa0-f41.google.com with SMTP id ey11so2499162pad.28
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 14:53:12 -0700 (PDT)
In-Reply-To: <1411249950-6795-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The send_check logic was only interesting in cases of TCP offload and
UDP UFO where the checksum needed to be initialized to the pseudo
header checksum. Now we've moved that logic into the related
gso_segment functions so gso_send_check is no longer needed.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |  1 -
 net/core/dev.c            | 10 ----------
 net/ipv4/af_inet.c        | 36 ------------------------------------
 net/ipv4/gre_offload.c    | 11 +++--------
 net/ipv4/tcp_offload.c    |  6 ------
 net/ipv4/udp_offload.c    |  6 ------
 net/ipv6/ip6_offload.c    | 27 ---------------------------
 net/ipv6/tcpv6_offload.c  |  6 ------
 net/ipv6/udp_offload.c    |  6 ------
 net/mpls/mpls_gso.c       |  7 -------
 10 files changed, 3 insertions(+), 113 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4354b43..9f5d293 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1911,7 +1911,6 @@ struct packet_type {
 struct offload_callbacks {
 	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
 						netdev_features_t features);
-	int			(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
 					       struct sk_buff *skb);
 	int			(*gro_complete)(struct sk_buff *skb, int nhoff);
diff --git a/net/core/dev.c b/net/core/dev.c
index e916ba8..734bca4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2422,16 +2422,6 @@ struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &offload_base, list) {
 		if (ptype->type == type && ptype->callbacks.gso_segment) {
-			if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
-				int err;
-
-				err = ptype->callbacks.gso_send_check(skb);
-				segs = ERR_PTR(err);
-				if (err || skb_gso_ok(skb, features))
-					break;
-				__skb_push(skb, (skb->data -
-						 skb_network_header(skb)));
-			}
 			segs = ptype->callbacks.gso_segment(skb, features);
 			break;
 		}
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 72011cc..28e589c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1197,40 +1197,6 @@ int inet_sk_rebuild_header(struct sock *sk)
 }
 EXPORT_SYMBOL(inet_sk_rebuild_header);
 
-static int inet_gso_send_check(struct sk_buff *skb)
-{
-	const struct net_offload *ops;
-	const struct iphdr *iph;
-	int proto;
-	int ihl;
-	int err = -EINVAL;
-
-	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
-		goto out;
-
-	iph = ip_hdr(skb);
-	ihl = iph->ihl * 4;
-	if (ihl < sizeof(*iph))
-		goto out;
-
-	proto = iph->protocol;
-
-	/* Warning: after this point, iph might be no longer valid */
-	if (unlikely(!pskb_may_pull(skb, ihl)))
-		goto out;
-	__skb_pull(skb, ihl);
-
-	skb_reset_transport_header(skb);
-	err = -EPROTONOSUPPORT;
-
-	ops = rcu_dereference(inet_offloads[proto]);
-	if (likely(ops && ops->callbacks.gso_send_check))
-		err = ops->callbacks.gso_send_check(skb);
-
-out:
-	return err;
-}
-
 static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 					netdev_features_t features)
 {
@@ -1655,7 +1621,6 @@ static int ipv4_proc_init(void);
 static struct packet_offload ip_packet_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IP),
 	.callbacks = {
-		.gso_send_check = inet_gso_send_check,
 		.gso_segment = inet_gso_segment,
 		.gro_receive = inet_gro_receive,
 		.gro_complete = inet_gro_complete,
@@ -1664,7 +1629,6 @@ static struct packet_offload ip_packet_offload __read_mostly = {
 
 static const struct net_offload ipip_offload = {
 	.callbacks = {
-		.gso_send_check = inet_gso_send_check,
 		.gso_segment	= inet_gso_segment,
 		.gro_receive	= inet_gro_receive,
 		.gro_complete	= inet_gro_complete,
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index d3fe2ac..a777295 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -15,13 +15,6 @@
 #include <net/protocol.h>
 #include <net/gre.h>
 
-static int gre_gso_send_check(struct sk_buff *skb)
-{
-	if (!skb->encapsulation)
-		return -EINVAL;
-	return 0;
-}
-
 static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 				       netdev_features_t features)
 {
@@ -46,6 +39,9 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 				  SKB_GSO_IPIP)))
 		goto out;
 
+	if (!skb->encapsulation)
+		goto out;
+
 	if (unlikely(!pskb_may_pull(skb, sizeof(*greh))))
 		goto out;
 
@@ -256,7 +252,6 @@ static int gre_gro_complete(struct sk_buff *skb, int nhoff)
 
 static const struct net_offload gre_offload = {
 	.callbacks = {
-		.gso_send_check = gre_gso_send_check,
 		.gso_segment = gre_gso_segment,
 		.gro_receive = gre_gro_receive,
 		.gro_complete = gre_gro_complete,
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 7cd12b0..5b90f2f 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -288,11 +288,6 @@ int tcp_gro_complete(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(tcp_gro_complete);
 
-static int tcp_v4_gso_send_check(struct sk_buff *skb)
-{
-	return 0;
-}
-
 static struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
 	/* Don't bother verifying checksum if we're going to flush anyway. */
@@ -320,7 +315,6 @@ static int tcp4_gro_complete(struct sk_buff *skb, int thoff)
 
 static const struct net_offload tcpv4_offload = {
 	.callbacks = {
-		.gso_send_check	=	tcp_v4_gso_send_check,
 		.gso_segment	=	tcp4_gso_segment,
 		.gro_receive	=	tcp4_gro_receive,
 		.gro_complete	=	tcp4_gro_complete,
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 2918cc9..19ebe6a 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -25,11 +25,6 @@ struct udp_offload_priv {
 	struct udp_offload_priv __rcu *next;
 };
 
-static int udp4_ufo_send_check(struct sk_buff *skb)
-{
-	return 0;
-}
-
 struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 				       netdev_features_t features)
 {
@@ -346,7 +341,6 @@ static int udp4_gro_complete(struct sk_buff *skb, int nhoff)
 
 static const struct net_offload udpv4_offload = {
 	.callbacks = {
-		.gso_send_check = udp4_ufo_send_check,
 		.gso_segment = udp4_ufo_fragment,
 		.gro_receive  =	udp4_gro_receive,
 		.gro_complete =	udp4_gro_complete,
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 9952f3f..9034f76 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -53,31 +53,6 @@ static int ipv6_gso_pull_exthdrs(struct sk_buff *skb, int proto)
 	return proto;
 }
 
-static int ipv6_gso_send_check(struct sk_buff *skb)
-{
-	const struct ipv6hdr *ipv6h;
-	const struct net_offload *ops;
-	int err = -EINVAL;
-
-	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
-		goto out;
-
-	ipv6h = ipv6_hdr(skb);
-	__skb_pull(skb, sizeof(*ipv6h));
-	err = -EPROTONOSUPPORT;
-
-	ops = rcu_dereference(inet6_offloads[
-		ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr)]);
-
-	if (likely(ops && ops->callbacks.gso_send_check)) {
-		skb_reset_transport_header(skb);
-		err = ops->callbacks.gso_send_check(skb);
-	}
-
-out:
-	return err;
-}
-
 static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	netdev_features_t features)
 {
@@ -306,7 +281,6 @@ out_unlock:
 static struct packet_offload ipv6_packet_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IPV6),
 	.callbacks = {
-		.gso_send_check = ipv6_gso_send_check,
 		.gso_segment = ipv6_gso_segment,
 		.gro_receive = ipv6_gro_receive,
 		.gro_complete = ipv6_gro_complete,
@@ -315,7 +289,6 @@ static struct packet_offload ipv6_packet_offload __read_mostly = {
 
 static const struct net_offload sit_offload = {
 	.callbacks = {
-		.gso_send_check = ipv6_gso_send_check,
 		.gso_segment	= ipv6_gso_segment,
 		.gro_receive	= ipv6_gro_receive,
 		.gro_complete	= ipv6_gro_complete,
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index 9625315..c1ab771 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -15,11 +15,6 @@
 #include <net/ip6_checksum.h>
 #include "ip6_offload.h"
 
-static int tcp_v6_gso_send_check(struct sk_buff *skb)
-{
-	return 0;
-}
-
 static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
 {
@@ -71,7 +66,6 @@ struct sk_buff *tcp6_gso_segment(struct sk_buff *skb,
 }
 static const struct net_offload tcpv6_offload = {
 	.callbacks = {
-		.gso_send_check	=	tcp_v6_gso_send_check,
 		.gso_segment	=	tcp6_gso_segment,
 		.gro_receive	=	tcp6_gro_receive,
 		.gro_complete	=	tcp6_gro_complete,
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index e4af643..212ebfc 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -17,11 +17,6 @@
 #include <net/ip6_checksum.h>
 #include "ip6_offload.h"
 
-static int udp6_ufo_send_check(struct sk_buff *skb)
-{
-	return 0;
-}
-
 static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 					 netdev_features_t features)
 {
@@ -166,7 +161,6 @@ static int udp6_gro_complete(struct sk_buff *skb, int nhoff)
 
 static const struct net_offload udpv6_offload = {
 	.callbacks = {
-		.gso_send_check =	udp6_ufo_send_check,
 		.gso_segment	=	udp6_ufo_fragment,
 		.gro_receive	=	udp6_gro_receive,
 		.gro_complete	=	udp6_gro_complete,
diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index 6b38d08..e28ed2e 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -65,15 +65,9 @@ out:
 	return segs;
 }
 
-static int mpls_gso_send_check(struct sk_buff *skb)
-{
-	return 0;
-}
-
 static struct packet_offload mpls_mc_offload = {
 	.type = cpu_to_be16(ETH_P_MPLS_MC),
 	.callbacks = {
-		.gso_send_check =	mpls_gso_send_check,
 		.gso_segment    =	mpls_gso_segment,
 	},
 };
@@ -81,7 +75,6 @@ static struct packet_offload mpls_mc_offload = {
 static struct packet_offload mpls_uc_offload = {
 	.type = cpu_to_be16(ETH_P_MPLS_UC),
 	.callbacks = {
-		.gso_send_check =	mpls_gso_send_check,
 		.gso_segment    =	mpls_gso_segment,
 	},
 };
-- 
2.1.0.rc2.206.gedb03e5
