From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH V2 08/14] ipv6: Separate tcp offload functionality
Date: Thu, 15 Nov 2012 13:49:17 -0500
Message-ID: <1353005363-6974-9-git-send-email-vyasevic@redhat.com>
References: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35000 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768722Ab2KOStg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 13:49:36 -0500
In-Reply-To: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pull TCPv6 offload functionality into its won file in preparation
for moving it out of the module.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/net/ip6_checksum.h |   35 ++++++++++++++
 net/ipv6/Makefile          |    2 +-
 net/ipv6/ip6_offload.h     |    3 +
 net/ipv6/tcp_ipv6.c        |  113 ++------------------------------------------
 net/ipv6/tcpv6_offload.c   |   98 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 141 insertions(+), 110 deletions(-)
 create mode 100644 net/ipv6/tcpv6_offload.c

diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index bc1b0fd..652d3d3 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -31,6 +31,8 @@
 #include <net/ip.h>
 #include <asm/checksum.h>
 #include <linux/in6.h>
+#include <linux/tcp.h>
+#include <linux/ipv6.h>
 
 #ifndef _HAVE_ARCH_IPV6_CSUM
 
@@ -91,4 +93,37 @@ static __inline__ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 }
 
 #endif
+
+static __inline__ __sum16 tcp_v6_check(int len,
+				   const struct in6_addr *saddr,
+				   const struct in6_addr *daddr,
+				   __wsum base)
+{
+	return csum_ipv6_magic(saddr, daddr, len, IPPROTO_TCP, base);
+}
+
+static inline void __tcp_v6_send_check(struct sk_buff *skb,
+				       const struct in6_addr *saddr,
+				       const struct in6_addr *daddr)
+{
+	struct tcphdr *th = tcp_hdr(skb);
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		th->check = ~tcp_v6_check(skb->len, saddr, daddr, 0);
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct tcphdr, check);
+	} else {
+		th->check = tcp_v6_check(skb->len, saddr, daddr,
+					 csum_partial(th, th->doff << 2,
+						      skb->csum));
+	}
+}
+
+static inline void tcp_v6_send_check(struct sock *sk, struct sk_buff *skb)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+
+	__tcp_v6_send_check(skb, &np->saddr, &np->daddr);
+}
+
 #endif
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 45bd9cd..f47ad9f 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -10,7 +10,7 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		raw.o protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o
 
-ipv6-offload :=	ip6_offload.o
+ipv6-offload :=	ip6_offload.o tcpv6_offload.o
 
 ipv6-$(CONFIG_SYSCTL) = sysctl_net_ipv6.o
 ipv6-$(CONFIG_IPV6_MROUTE) += ip6mr.o
diff --git a/net/ipv6/ip6_offload.h b/net/ipv6/ip6_offload.h
index c09614e..1891946 100644
--- a/net/ipv6/ip6_offload.h
+++ b/net/ipv6/ip6_offload.h
@@ -11,6 +11,9 @@
 #ifndef __ip6_offload_h
 #define __ip6_offload_h
 
+int tcpv6_offload_init(void);
+void tcpv6_offload_cleanup(void);
+
 extern void ipv6_offload_init(void);
 extern void ipv6_offload_cleanup(void);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ac59c84..58fabc5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -71,15 +71,13 @@
 
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>
+#include "ip6_offload.h"
 
 static void	tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb);
 static void	tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 				      struct request_sock *req);
 
 static int	tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb);
-static void	__tcp_v6_send_check(struct sk_buff *skb,
-				    const struct in6_addr *saddr,
-				    const struct in6_addr *daddr);
 
 static const struct inet_connection_sock_af_ops ipv6_mapped;
 static const struct inet_connection_sock_af_ops ipv6_specific;
@@ -119,14 +117,6 @@ static void tcp_v6_hash(struct sock *sk)
 	}
 }
 
-static __inline__ __sum16 tcp_v6_check(int len,
-				   const struct in6_addr *saddr,
-				   const struct in6_addr *daddr,
-				   __wsum base)
-{
-	return csum_ipv6_magic(saddr, daddr, len, IPPROTO_TCP, base);
-}
-
 static __u32 tcp_v6_init_sequence(const struct sk_buff *skb)
 {
 	return secure_tcpv6_sequence_number(ipv6_hdr(skb)->daddr.s6_addr32,
@@ -719,94 +709,6 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 };
 #endif
 
-static void __tcp_v6_send_check(struct sk_buff *skb,
-				const struct in6_addr *saddr, const struct in6_addr *daddr)
-{
-	struct tcphdr *th = tcp_hdr(skb);
-
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		th->check = ~tcp_v6_check(skb->len, saddr, daddr, 0);
-		skb->csum_start = skb_transport_header(skb) - skb->head;
-		skb->csum_offset = offsetof(struct tcphdr, check);
-	} else {
-		th->check = tcp_v6_check(skb->len, saddr, daddr,
-					 csum_partial(th, th->doff << 2,
-						      skb->csum));
-	}
-}
-
-static void tcp_v6_send_check(struct sock *sk, struct sk_buff *skb)
-{
-	struct ipv6_pinfo *np = inet6_sk(sk);
-
-	__tcp_v6_send_check(skb, &np->saddr, &np->daddr);
-}
-
-static int tcp_v6_gso_send_check(struct sk_buff *skb)
-{
-	const struct ipv6hdr *ipv6h;
-	struct tcphdr *th;
-
-	if (!pskb_may_pull(skb, sizeof(*th)))
-		return -EINVAL;
-
-	ipv6h = ipv6_hdr(skb);
-	th = tcp_hdr(skb);
-
-	th->check = 0;
-	skb->ip_summed = CHECKSUM_PARTIAL;
-	__tcp_v6_send_check(skb, &ipv6h->saddr, &ipv6h->daddr);
-	return 0;
-}
-
-static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
-					 struct sk_buff *skb)
-{
-	const struct ipv6hdr *iph = skb_gro_network_header(skb);
-	__wsum wsum;
-	__sum16 sum;
-
-	switch (skb->ip_summed) {
-	case CHECKSUM_COMPLETE:
-		if (!tcp_v6_check(skb_gro_len(skb), &iph->saddr, &iph->daddr,
-				  skb->csum)) {
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
-			break;
-		}
-flush:
-		NAPI_GRO_CB(skb)->flush = 1;
-		return NULL;
-
-	case CHECKSUM_NONE:
-		wsum = ~csum_unfold(csum_ipv6_magic(&iph->saddr, &iph->daddr,
-						    skb_gro_len(skb),
-						    IPPROTO_TCP, 0));
-		sum = csum_fold(skb_checksum(skb,
-					     skb_gro_offset(skb),
-					     skb_gro_len(skb),
-					     wsum));
-		if (sum)
-			goto flush;
-
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		break;
-	}
-
-	return tcp_gro_receive(head, skb);
-}
-
-static int tcp6_gro_complete(struct sk_buff *skb)
-{
-	const struct ipv6hdr *iph = ipv6_hdr(skb);
-	struct tcphdr *th = tcp_hdr(skb);
-
-	th->check = ~tcp_v6_check(skb->len - skb_transport_offset(skb),
-				  &iph->saddr, &iph->daddr, 0);
-	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
-
-	return tcp_gro_complete(skb);
-}
-
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 				 u32 ts, struct tcp_md5sig_key *key, int rst, u8 tclass)
 {
@@ -2066,13 +1968,6 @@ static const struct inet6_protocol tcpv6_protocol = {
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
-static const struct net_offload tcpv6_offload = {
-	.gso_send_check	=	tcp_v6_gso_send_check,
-	.gso_segment	=	tcp_tso_segment,
-	.gro_receive	=	tcp6_gro_receive,
-	.gro_complete	=	tcp6_gro_complete,
-};
-
 static struct inet_protosw tcpv6_protosw = {
 	.type		=	SOCK_STREAM,
 	.protocol	=	IPPROTO_TCP,
@@ -2109,7 +2004,7 @@ int __init tcpv6_init(void)
 {
 	int ret;
 
-	ret = inet6_add_offload(&tcpv6_offload, IPPROTO_TCP);
+	ret = tcpv6_offload_init();
 	if (ret)
 		goto out;
 
@@ -2133,7 +2028,7 @@ out_tcpv6_protosw:
 out_tcpv6_protocol:
 	inet6_del_protocol(&tcpv6_protocol, IPPROTO_TCP);
 out_offload:
-	inet6_del_offload(&tcpv6_offload, IPPROTO_TCP);
+	tcpv6_offload_cleanup();
 	goto out;
 }
 
@@ -2142,5 +2037,5 @@ void tcpv6_exit(void)
 	unregister_pernet_subsys(&tcpv6_net_ops);
 	inet6_unregister_protosw(&tcpv6_protosw);
 	inet6_del_protocol(&tcpv6_protocol, IPPROTO_TCP);
-	inet6_del_offload(&tcpv6_offload, IPPROTO_TCP);
+	tcpv6_offload_cleanup();
 }
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
new file mode 100644
index 0000000..edeafed
--- /dev/null
+++ b/net/ipv6/tcpv6_offload.c
@@ -0,0 +1,98 @@
+/*
+ *	IPV6 GSO/GRO offload support
+ *	Linux INET6 implementation
+ *
+ *	This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ *
+ *      TCPv6 GSO/GRO support
+ */
+#include <linux/skbuff.h>
+#include <net/protocol.h>
+#include <net/tcp.h>
+#include <net/ip6_checksum.h>
+#include "ip6_offload.h"
+
+static int tcp_v6_gso_send_check(struct sk_buff *skb)
+{
+	const struct ipv6hdr *ipv6h;
+	struct tcphdr *th;
+
+	if (!pskb_may_pull(skb, sizeof(*th)))
+		return -EINVAL;
+
+	ipv6h = ipv6_hdr(skb);
+	th = tcp_hdr(skb);
+
+	th->check = 0;
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	__tcp_v6_send_check(skb, &ipv6h->saddr, &ipv6h->daddr);
+	return 0;
+}
+
+static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb)
+{
+	const struct ipv6hdr *iph = skb_gro_network_header(skb);
+	__wsum wsum;
+	__sum16 sum;
+
+	switch (skb->ip_summed) {
+	case CHECKSUM_COMPLETE:
+		if (!tcp_v6_check(skb_gro_len(skb), &iph->saddr, &iph->daddr,
+				  skb->csum)) {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			break;
+		}
+flush:
+		NAPI_GRO_CB(skb)->flush = 1;
+		return NULL;
+
+	case CHECKSUM_NONE:
+		wsum = ~csum_unfold(csum_ipv6_magic(&iph->saddr, &iph->daddr,
+						    skb_gro_len(skb),
+						    IPPROTO_TCP, 0));
+		sum = csum_fold(skb_checksum(skb,
+					     skb_gro_offset(skb),
+					     skb_gro_len(skb),
+					     wsum));
+		if (sum)
+			goto flush;
+
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		break;
+	}
+
+	return tcp_gro_receive(head, skb);
+}
+
+static int tcp6_gro_complete(struct sk_buff *skb)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct tcphdr *th = tcp_hdr(skb);
+
+	th->check = ~tcp_v6_check(skb->len - skb_transport_offset(skb),
+				  &iph->saddr, &iph->daddr, 0);
+	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+
+	return tcp_gro_complete(skb);
+}
+
+static const struct net_offload tcpv6_offload = {
+	.gso_send_check	=	tcp_v6_gso_send_check,
+	.gso_segment	=	tcp_tso_segment,
+	.gro_receive	=	tcp6_gro_receive,
+	.gro_complete	=	tcp6_gro_complete,
+};
+
+int __init tcpv6_offload_init(void)
+{
+	return inet6_add_offload(&tcpv6_offload, IPPROTO_TCP);
+}
+
+void tcpv6_offload_cleanup(void)
+{
+	inet6_del_offload(&tcpv6_offload, IPPROTO_TCP);
+}
-- 
1.7.7.6
