From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH V2 07/14] ipv6: Separate ipv6 offload support
Date: Thu, 15 Nov 2012 13:49:16 -0500
Message-ID: <1353005363-6974-8-git-send-email-vyasevic@redhat.com>
References: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16682 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768708Ab2KOSte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 13:49:34 -0500
In-Reply-To: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separate IPv6 offload functionality into its own file
in preparation for the move out of the module

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/ipv6/Makefile      |    3 +
 net/ipv6/af_inet6.c    |  249 +-------------------------------------------
 net/ipv6/ip6_offload.c |  273 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_offload.h |   17 +++
 4 files changed, 296 insertions(+), 246 deletions(-)
 create mode 100644 net/ipv6/ip6_offload.c
 create mode 100644 net/ipv6/ip6_offload.h

diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index b6d3f79..45bd9cd 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -10,6 +10,8 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		raw.o protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o
 
+ipv6-offload :=	ip6_offload.o
+
 ipv6-$(CONFIG_SYSCTL) = sysctl_net_ipv6.o
 ipv6-$(CONFIG_IPV6_MROUTE) += ip6mr.o
 
@@ -21,6 +23,7 @@ ipv6-$(CONFIG_PROC_FS) += proc.o
 ipv6-$(CONFIG_SYN_COOKIES) += syncookies.o
 
 ipv6-objs += $(ipv6-y)
+ipv6-objs += $(ipv6-offload)
 
 obj-$(CONFIG_INET6_AH) += ah6.o
 obj-$(CONFIG_INET6_ESP) += esp6.o
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index eb63dac..c84d5ba 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -62,6 +62,7 @@
 
 #include <asm/uaccess.h>
 #include <linux/mroute6.h>
+#include "ip6_offload.h"
 
 MODULE_AUTHOR("Cast of dozens");
 MODULE_DESCRIPTION("IPv6 protocol stack for Linux");
@@ -699,266 +700,22 @@ bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(ipv6_opt_accepted);
 
-static int ipv6_gso_pull_exthdrs(struct sk_buff *skb, int proto)
-{
-	const struct net_offload *ops = NULL;
-
-	for (;;) {
-		struct ipv6_opt_hdr *opth;
-		int len;
-
-		if (proto != NEXTHDR_HOP) {
-			ops = rcu_dereference(inet6_offloads[proto]);
-
-			if (unlikely(!ops))
-				break;
-
-			if (!(ops->flags & INET6_PROTO_GSO_EXTHDR))
-				break;
-		}
-
-		if (unlikely(!pskb_may_pull(skb, 8)))
-			break;
-
-		opth = (void *)skb->data;
-		len = ipv6_optlen(opth);
-
-		if (unlikely(!pskb_may_pull(skb, len)))
-			break;
-
-		proto = opth->nexthdr;
-		__skb_pull(skb, len);
-	}
-
-	return proto;
-}
-
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
-	rcu_read_lock();
-	ops = rcu_dereference(inet6_offloads[
-		ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr)]);
-
-	if (likely(ops && ops->gso_send_check)) {
-		skb_reset_transport_header(skb);
-		err = ops->gso_send_check(skb);
-	}
-	rcu_read_unlock();
-
-out:
-	return err;
-}
-
-static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
-	netdev_features_t features)
-{
-	struct sk_buff *segs = ERR_PTR(-EINVAL);
-	struct ipv6hdr *ipv6h;
-	const struct net_offload *ops;
-	int proto;
-	struct frag_hdr *fptr;
-	unsigned int unfrag_ip6hlen;
-	u8 *prevhdr;
-	int offset = 0;
-
-	if (!(features & NETIF_F_V6_CSUM))
-		features &= ~NETIF_F_SG;
-
-	if (unlikely(skb_shinfo(skb)->gso_type &
-		     ~(SKB_GSO_UDP |
-		       SKB_GSO_DODGY |
-		       SKB_GSO_TCP_ECN |
-		       SKB_GSO_TCPV6 |
-		       0)))
-		goto out;
-
-	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
-		goto out;
-
-	ipv6h = ipv6_hdr(skb);
-	__skb_pull(skb, sizeof(*ipv6h));
-	segs = ERR_PTR(-EPROTONOSUPPORT);
-
-	proto = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
-	rcu_read_lock();
-	ops = rcu_dereference(inet6_offloads[proto]);
-	if (likely(ops && ops->gso_segment)) {
-		skb_reset_transport_header(skb);
-		segs = ops->gso_segment(skb, features);
-	}
-	rcu_read_unlock();
-
-	if (IS_ERR(segs))
-		goto out;
-
-	for (skb = segs; skb; skb = skb->next) {
-		ipv6h = ipv6_hdr(skb);
-		ipv6h->payload_len = htons(skb->len - skb->mac_len -
-					   sizeof(*ipv6h));
-		if (proto == IPPROTO_UDP) {
-			unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
-			fptr = (struct frag_hdr *)(skb_network_header(skb) +
-				unfrag_ip6hlen);
-			fptr->frag_off = htons(offset);
-			if (skb->next != NULL)
-				fptr->frag_off |= htons(IP6_MF);
-			offset += (ntohs(ipv6h->payload_len) -
-				   sizeof(struct frag_hdr));
-		}
-	}
-
-out:
-	return segs;
-}
-
-static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
-					 struct sk_buff *skb)
-{
-	const struct net_offload *ops;
-	struct sk_buff **pp = NULL;
-	struct sk_buff *p;
-	struct ipv6hdr *iph;
-	unsigned int nlen;
-	unsigned int hlen;
-	unsigned int off;
-	int flush = 1;
-	int proto;
-	__wsum csum;
-
-	off = skb_gro_offset(skb);
-	hlen = off + sizeof(*iph);
-	iph = skb_gro_header_fast(skb, off);
-	if (skb_gro_header_hard(skb, hlen)) {
-		iph = skb_gro_header_slow(skb, hlen, off);
-		if (unlikely(!iph))
-			goto out;
-	}
-
-	skb_gro_pull(skb, sizeof(*iph));
-	skb_set_transport_header(skb, skb_gro_offset(skb));
-
-	flush += ntohs(iph->payload_len) != skb_gro_len(skb);
-
-	rcu_read_lock();
-	proto = iph->nexthdr;
-	ops = rcu_dereference(inet6_offloads[proto]);
-	if (!ops || !ops->gro_receive) {
-		__pskb_pull(skb, skb_gro_offset(skb));
-		proto = ipv6_gso_pull_exthdrs(skb, proto);
-		skb_gro_pull(skb, -skb_transport_offset(skb));
-		skb_reset_transport_header(skb);
-		__skb_push(skb, skb_gro_offset(skb));
-
-		ops = rcu_dereference(inet6_offloads[proto]);
-		if (!ops || !ops->gro_receive)
-			goto out_unlock;
-
-		iph = ipv6_hdr(skb);
-	}
-
-	NAPI_GRO_CB(skb)->proto = proto;
-
-	flush--;
-	nlen = skb_network_header_len(skb);
-
-	for (p = *head; p; p = p->next) {
-		const struct ipv6hdr *iph2;
-		__be32 first_word; /* <Version:4><Traffic_Class:8><Flow_Label:20> */
-
-		if (!NAPI_GRO_CB(p)->same_flow)
-			continue;
-
-		iph2 = ipv6_hdr(p);
-		first_word = *(__be32 *)iph ^ *(__be32 *)iph2 ;
-
-		/* All fields must match except length and Traffic Class. */
-		if (nlen != skb_network_header_len(p) ||
-		    (first_word & htonl(0xF00FFFFF)) ||
-		    memcmp(&iph->nexthdr, &iph2->nexthdr,
-			   nlen - offsetof(struct ipv6hdr, nexthdr))) {
-			NAPI_GRO_CB(p)->same_flow = 0;
-			continue;
-		}
-		/* flush if Traffic Class fields are different */
-		NAPI_GRO_CB(p)->flush |= !!(first_word & htonl(0x0FF00000));
-		NAPI_GRO_CB(p)->flush |= flush;
-	}
-
-	NAPI_GRO_CB(skb)->flush |= flush;
-
-	csum = skb->csum;
-	skb_postpull_rcsum(skb, iph, skb_network_header_len(skb));
-
-	pp = ops->gro_receive(head, skb);
-
-	skb->csum = csum;
-
-out_unlock:
-	rcu_read_unlock();
-
-out:
-	NAPI_GRO_CB(skb)->flush |= flush;
-
-	return pp;
-}
-
-static int ipv6_gro_complete(struct sk_buff *skb)
-{
-	const struct net_offload *ops;
-	struct ipv6hdr *iph = ipv6_hdr(skb);
-	int err = -ENOSYS;
-
-	iph->payload_len = htons(skb->len - skb_network_offset(skb) -
-				 sizeof(*iph));
-
-	rcu_read_lock();
-	ops = rcu_dereference(inet6_offloads[NAPI_GRO_CB(skb)->proto]);
-	if (WARN_ON(!ops || !ops->gro_complete))
-		goto out_unlock;
-
-	err = ops->gro_complete(skb);
-
-out_unlock:
-	rcu_read_unlock();
-
-	return err;
-}
-
 static struct packet_type ipv6_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IPV6),
 	.func = ipv6_rcv,
 };
 
-static struct packet_offload ipv6_packet_offload __read_mostly = {
-	.type = cpu_to_be16(ETH_P_IPV6),
-	.gso_send_check = ipv6_gso_send_check,
-	.gso_segment = ipv6_gso_segment,
-	.gro_receive = ipv6_gro_receive,
-	.gro_complete = ipv6_gro_complete,
-};
-
 static int __init ipv6_packet_init(void)
 {
-	dev_add_offload(&ipv6_packet_offload);
+	ipv6_offload_init();
 	dev_add_pack(&ipv6_packet_type);
 	return 0;
 }
 
 static void ipv6_packet_cleanup(void)
 {
+	ipv6_offload_cleanup();
 	dev_remove_pack(&ipv6_packet_type);
-	dev_remove_offload(&ipv6_packet_offload);
 }
 
 static int __net_init ipv6_init_mibs(struct net *net)
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
new file mode 100644
index 0000000..01cf983
--- /dev/null
+++ b/net/ipv6/ip6_offload.c
@@ -0,0 +1,273 @@
+/*
+ *	IPV6 GSO/GRO offload support
+ *	Linux INET6 implementation
+ *
+ *	This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/socket.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+
+#include <net/protocol.h>
+#include <net/ipv6.h>
+
+#include "ip6_offload.h"
+
+static int ipv6_gso_pull_exthdrs(struct sk_buff *skb, int proto)
+{
+	const struct net_offload *ops = NULL;
+
+	for (;;) {
+		struct ipv6_opt_hdr *opth;
+		int len;
+
+		if (proto != NEXTHDR_HOP) {
+			ops = rcu_dereference(inet6_offloads[proto]);
+
+			if (unlikely(!ops))
+				break;
+
+			if (!(ops->flags & INET6_PROTO_GSO_EXTHDR))
+				break;
+		}
+
+		if (unlikely(!pskb_may_pull(skb, 8)))
+			break;
+
+		opth = (void *)skb->data;
+		len = ipv6_optlen(opth);
+
+		if (unlikely(!pskb_may_pull(skb, len)))
+			break;
+
+		proto = opth->nexthdr;
+		__skb_pull(skb, len);
+	}
+
+	return proto;
+}
+
+static int ipv6_gso_send_check(struct sk_buff *skb)
+{
+	const struct ipv6hdr *ipv6h;
+	const struct net_offload *ops;
+	int err = -EINVAL;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
+		goto out;
+
+	ipv6h = ipv6_hdr(skb);
+	__skb_pull(skb, sizeof(*ipv6h));
+	err = -EPROTONOSUPPORT;
+
+	rcu_read_lock();
+	ops = rcu_dereference(inet6_offloads[
+		ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr)]);
+
+	if (likely(ops && ops->gso_send_check)) {
+		skb_reset_transport_header(skb);
+		err = ops->gso_send_check(skb);
+	}
+	rcu_read_unlock();
+
+out:
+	return err;
+}
+
+static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
+	netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct ipv6hdr *ipv6h;
+	const struct net_offload *ops;
+	int proto;
+	struct frag_hdr *fptr;
+	unsigned int unfrag_ip6hlen;
+	u8 *prevhdr;
+	int offset = 0;
+
+	if (!(features & NETIF_F_V6_CSUM))
+		features &= ~NETIF_F_SG;
+
+	if (unlikely(skb_shinfo(skb)->gso_type &
+		     ~(SKB_GSO_UDP |
+		       SKB_GSO_DODGY |
+		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_TCPV6 |
+		       0)))
+		goto out;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
+		goto out;
+
+	ipv6h = ipv6_hdr(skb);
+	__skb_pull(skb, sizeof(*ipv6h));
+	segs = ERR_PTR(-EPROTONOSUPPORT);
+
+	proto = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
+	rcu_read_lock();
+	ops = rcu_dereference(inet6_offloads[proto]);
+	if (likely(ops && ops->gso_segment)) {
+		skb_reset_transport_header(skb);
+		segs = ops->gso_segment(skb, features);
+	}
+	rcu_read_unlock();
+
+	if (IS_ERR(segs))
+		goto out;
+
+	for (skb = segs; skb; skb = skb->next) {
+		ipv6h = ipv6_hdr(skb);
+		ipv6h->payload_len = htons(skb->len - skb->mac_len -
+					   sizeof(*ipv6h));
+		if (proto == IPPROTO_UDP) {
+			unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
+			fptr = (struct frag_hdr *)(skb_network_header(skb) +
+				unfrag_ip6hlen);
+			fptr->frag_off = htons(offset);
+			if (skb->next != NULL)
+				fptr->frag_off |= htons(IP6_MF);
+			offset += (ntohs(ipv6h->payload_len) -
+				   sizeof(struct frag_hdr));
+		}
+	}
+
+out:
+	return segs;
+}
+
+static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb)
+{
+	const struct net_offload *ops;
+	struct sk_buff **pp = NULL;
+	struct sk_buff *p;
+	struct ipv6hdr *iph;
+	unsigned int nlen;
+	unsigned int hlen;
+	unsigned int off;
+	int flush = 1;
+	int proto;
+	__wsum csum;
+
+	off = skb_gro_offset(skb);
+	hlen = off + sizeof(*iph);
+	iph = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, hlen)) {
+		iph = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!iph))
+			goto out;
+	}
+
+	skb_gro_pull(skb, sizeof(*iph));
+	skb_set_transport_header(skb, skb_gro_offset(skb));
+
+	flush += ntohs(iph->payload_len) != skb_gro_len(skb);
+
+	rcu_read_lock();
+	proto = iph->nexthdr;
+	ops = rcu_dereference(inet6_offloads[proto]);
+	if (!ops || !ops->gro_receive) {
+		__pskb_pull(skb, skb_gro_offset(skb));
+		proto = ipv6_gso_pull_exthdrs(skb, proto);
+		skb_gro_pull(skb, -skb_transport_offset(skb));
+		skb_reset_transport_header(skb);
+		__skb_push(skb, skb_gro_offset(skb));
+
+		ops = rcu_dereference(inet6_offloads[proto]);
+		if (!ops || !ops->gro_receive)
+			goto out_unlock;
+
+		iph = ipv6_hdr(skb);
+	}
+
+	NAPI_GRO_CB(skb)->proto = proto;
+
+	flush--;
+	nlen = skb_network_header_len(skb);
+
+	for (p = *head; p; p = p->next) {
+		const struct ipv6hdr *iph2;
+		__be32 first_word; /* <Version:4><Traffic_Class:8><Flow_Label:20> */
+
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		iph2 = ipv6_hdr(p);
+		first_word = *(__be32 *)iph ^ *(__be32 *)iph2 ;
+
+		/* All fields must match except length and Traffic Class. */
+		if (nlen != skb_network_header_len(p) ||
+		    (first_word & htonl(0xF00FFFFF)) ||
+		    memcmp(&iph->nexthdr, &iph2->nexthdr,
+			   nlen - offsetof(struct ipv6hdr, nexthdr))) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+		/* flush if Traffic Class fields are different */
+		NAPI_GRO_CB(p)->flush |= !!(first_word & htonl(0x0FF00000));
+		NAPI_GRO_CB(p)->flush |= flush;
+	}
+
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	csum = skb->csum;
+	skb_postpull_rcsum(skb, iph, skb_network_header_len(skb));
+
+	pp = ops->gro_receive(head, skb);
+
+	skb->csum = csum;
+
+out_unlock:
+	rcu_read_unlock();
+
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+static int ipv6_gro_complete(struct sk_buff *skb)
+{
+	const struct net_offload *ops;
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	int err = -ENOSYS;
+
+	iph->payload_len = htons(skb->len - skb_network_offset(skb) -
+				 sizeof(*iph));
+
+	rcu_read_lock();
+	ops = rcu_dereference(inet6_offloads[NAPI_GRO_CB(skb)->proto]);
+	if (WARN_ON(!ops || !ops->gro_complete))
+		goto out_unlock;
+
+	err = ops->gro_complete(skb);
+
+out_unlock:
+	rcu_read_unlock();
+
+	return err;
+}
+
+static struct packet_offload ipv6_packet_offload __read_mostly = {
+	.type = cpu_to_be16(ETH_P_IPV6),
+	.gso_send_check = ipv6_gso_send_check,
+	.gso_segment = ipv6_gso_segment,
+	.gro_receive = ipv6_gro_receive,
+	.gro_complete = ipv6_gro_complete,
+};
+
+void __init ipv6_offload_init(void)
+{
+	dev_add_offload(&ipv6_packet_offload);
+}
+
+void ipv6_offload_cleanup(void)
+{
+	dev_remove_offload(&ipv6_packet_offload);
+}
diff --git a/net/ipv6/ip6_offload.h b/net/ipv6/ip6_offload.h
new file mode 100644
index 0000000..c09614e
--- /dev/null
+++ b/net/ipv6/ip6_offload.h
@@ -0,0 +1,17 @@
+/*
+ *	IPV6 GSO/GRO offload support
+ *	Linux INET6 implementation
+ *
+ *	This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ */
+
+#ifndef __ip6_offload_h
+#define __ip6_offload_h
+
+extern void ipv6_offload_init(void);
+extern void ipv6_offload_cleanup(void);
+
+#endif
-- 
1.7.7.6
