From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 3/8] udp: Add GRO functions to UDP socket
Date: Tue, 5 Apr 2016 08:22:51 -0700
Message-ID: <1459869776-2090500-4-git-send-email-tom@herbertland.com>
References: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39824 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758973AbcDEPXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:23:15 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u35FKvkn028939
	for <netdev@vger.kernel.org>; Tue, 5 Apr 2016 08:23:14 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 224d629bfp-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 08:23:14 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 4dc456fefb4211e5b9fc24be05956610-e6fc13f0 for <netdev@vger.kernel.org>;	Tue,
 05 Apr 2016 08:23:09 -0700
In-Reply-To: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds GRO functions (gro_receive and gro_complete) to UDP
sockets. udp_gro_receive is changed to perform socket lookup on a
packet. If a socket is found the related GRO functions are called.

This features obsoletes using UDP offload infrastructure for GRO
(udp_offload). This has the advantage of not being limited to provide
offload on a per port basis, GRO is now applied to whatever individual
UDP sockets are bound to.  This also allows the possbility of
"application defined GRO"-- that is we can attach something like
a BPF program to a UDP socket to perfrom GRO on an application
layer protocol.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/udp.h    |  8 ++++++++
 include/net/udp.h      |  7 +++++--
 net/ipv4/udp_offload.c | 52 +++++++++++++++++++-------------------------------
 net/ipv6/Makefile      |  5 +++--
 net/ipv6/af_inet6.c    |  8 ++++++++
 net/ipv6/ip6_offload.c |  2 --
 net/ipv6/ip6_offload.h |  3 ++-
 net/ipv6/udp_offload.c | 11 ++++++++---
 8 files changed, 54 insertions(+), 42 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 3234275..d1fd8cd 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -71,6 +71,14 @@ struct udp_sock {
 	 */
 	int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
 	void (*encap_destroy)(struct sock *sk);
+
+	/* GRO functions for UDP socket */
+	struct sk_buff **	(*gro_receive)(struct sock *sk,
+					       struct sk_buff **head,
+					       struct sk_buff *skb);
+	int			(*gro_complete)(struct sock *sk,
+						struct sk_buff *skb,
+						int nhoff);
 };
 
 static inline struct udp_sock *udp_sk(const struct sock *sk)
diff --git a/include/net/udp.h b/include/net/udp.h
index e2e3803..e245a1d 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -158,9 +158,12 @@ static inline __sum16 udp_v4_check(int len, __be32 saddr,
 void udp_set_csum(bool nocheck, struct sk_buff *skb,
 		  __be32 saddr, __be32 daddr, int len);
 
+typedef struct sock *(*udp_lookup_t)(struct sk_buff *skb, __be16 sport,
+				     __be16 dport);
+
 struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
-				 struct udphdr *uh);
-int udp_gro_complete(struct sk_buff *skb, int nhoff);
+				 struct udphdr *uh, udp_lookup_t lookup);
+int udp_gro_complete(struct sk_buff *skb, int nhoff, udp_lookup_t lookup);
 
 static inline struct udphdr *udp_gro_udphdr(struct sk_buff *skb)
 {
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 0ed2daf..65c3fd3 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -179,6 +179,7 @@ out_unlock:
 
 	return segs;
 }
+EXPORT_SYMBOL(skb_udp_tunnel_segment);
 
 static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 					 netdev_features_t features)
@@ -304,13 +305,13 @@ unlock:
 EXPORT_SYMBOL(udp_del_offload);
 
 struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
-				 struct udphdr *uh)
+				 struct udphdr *uh, udp_lookup_t lookup)
 {
-	struct udp_offload_priv *uo_priv;
 	struct sk_buff *p, **pp = NULL;
 	struct udphdr *uh2;
 	unsigned int off = skb_gro_offset(skb);
 	int flush = 1;
+	struct sock *sk;
 
 	if (NAPI_GRO_CB(skb)->encap_mark ||
 	    (skb->ip_summed != CHECKSUM_PARTIAL &&
@@ -322,13 +323,11 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 	NAPI_GRO_CB(skb)->encap_mark = 1;
 
 	rcu_read_lock();
-	uo_priv = rcu_dereference(udp_offload_base);
-	for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
-		if (net_eq(read_pnet(&uo_priv->net), dev_net(skb->dev)) &&
-		    uo_priv->offload->port == uh->dest &&
-		    uo_priv->offload->callbacks.gro_receive)
-			goto unflush;
-	}
+	sk = (*lookup)(skb, uh->source, uh->dest);
+
+	if (sk && udp_sk(sk)->gro_receive)
+		goto unflush;
+
 	goto out_unlock;
 
 unflush:
@@ -352,9 +351,7 @@ unflush:
 
 	skb_gro_pull(skb, sizeof(struct udphdr)); /* pull encapsulating udp header */
 	skb_gro_postpull_rcsum(skb, uh, sizeof(struct udphdr));
-	NAPI_GRO_CB(skb)->proto = uo_priv->offload->ipproto;
-	pp = uo_priv->offload->callbacks.gro_receive(head, skb,
-						     uo_priv->offload);
+	pp = udp_sk(sk)->gro_receive(sk, head, skb);
 
 out_unlock:
 	rcu_read_unlock();
@@ -362,6 +359,7 @@ out:
 	NAPI_GRO_CB(skb)->flush |= flush;
 	return pp;
 }
+EXPORT_SYMBOL(udp_gro_receive);
 
 static struct sk_buff **udp4_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
@@ -383,39 +381,28 @@ static struct sk_buff **udp4_gro_receive(struct sk_buff **head,
 					     inet_gro_compute_pseudo);
 skip:
 	NAPI_GRO_CB(skb)->is_ipv6 = 0;
-	return udp_gro_receive(head, skb, uh);
+	return udp_gro_receive(head, skb, uh, udp4_lib_lookup_skb);
 
 flush:
 	NAPI_GRO_CB(skb)->flush = 1;
 	return NULL;
 }
 
-int udp_gro_complete(struct sk_buff *skb, int nhoff)
+int udp_gro_complete(struct sk_buff *skb, int nhoff,
+		     udp_lookup_t lookup)
 {
-	struct udp_offload_priv *uo_priv;
 	__be16 newlen = htons(skb->len - nhoff);
 	struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
 	int err = -ENOSYS;
+	struct sock *sk;
 
 	uh->len = newlen;
 
 	rcu_read_lock();
-
-	uo_priv = rcu_dereference(udp_offload_base);
-	for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
-		if (net_eq(read_pnet(&uo_priv->net), dev_net(skb->dev)) &&
-		    uo_priv->offload->port == uh->dest &&
-		    uo_priv->offload->callbacks.gro_complete)
-			break;
-	}
-
-	if (uo_priv) {
-		NAPI_GRO_CB(skb)->proto = uo_priv->offload->ipproto;
-		err = uo_priv->offload->callbacks.gro_complete(skb,
-				nhoff + sizeof(struct udphdr),
-				uo_priv->offload);
-	}
-
+	sk = (*lookup)(skb, uh->source, uh->dest);
+	if (sk && udp_sk(sk)->gro_complete)
+		err = udp_sk(sk)->gro_complete(sk, skb,
+				nhoff + sizeof(struct udphdr));
 	rcu_read_unlock();
 
 	if (skb->remcsum_offload)
@@ -426,6 +413,7 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
 
 	return err;
 }
+EXPORT_SYMBOL(udp_gro_complete);
 
 static int udp4_gro_complete(struct sk_buff *skb, int nhoff)
 {
@@ -440,7 +428,7 @@ static int udp4_gro_complete(struct sk_buff *skb, int nhoff)
 		skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;
 	}
 
-	return udp_gro_complete(skb, nhoff);
+	return udp_gro_complete(skb, nhoff, udp4_lib_lookup_skb);
 }
 
 static const struct net_offload udpv4_offload = {
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 2fbd90b..5e9d6bf 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -8,9 +8,10 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		addrlabel.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
 		raw.o icmp.o mcast.o reassembly.o tcp_ipv6.o ping.o \
-		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o
+		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o \
+		udp_offload.o
 
-ipv6-offload :=	ip6_offload.o tcpv6_offload.o udp_offload.o exthdrs_offload.o
+ipv6-offload :=	ip6_offload.o tcpv6_offload.o exthdrs_offload.o
 
 ipv6-$(CONFIG_SYSCTL) = sysctl_net_ipv6.o
 ipv6-$(CONFIG_IPV6_MROUTE) += ip6mr.o
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index b11c37c..9a2fec5 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -64,6 +64,8 @@
 #include <asm/uaccess.h>
 #include <linux/mroute6.h>
 
+#include "ip6_offload.h"
+
 MODULE_AUTHOR("Cast of dozens");
 MODULE_DESCRIPTION("IPv6 protocol stack for Linux");
 MODULE_LICENSE("GPL");
@@ -958,6 +960,10 @@ static int __init inet6_init(void)
 	if (err)
 		goto udplitev6_fail;
 
+	err = udpv6_offload_init();
+	if (err)
+		goto udpv6_offload_fail;
+
 	err = tcpv6_init();
 	if (err)
 		goto tcpv6_fail;
@@ -987,6 +993,8 @@ pingv6_fail:
 ipv6_packet_fail:
 	tcpv6_exit();
 tcpv6_fail:
+	udpv6_offload_exit();
+udpv6_offload_fail:
 	udplitev6_exit();
 udplitev6_fail:
 	udpv6_exit();
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 82e9f30..204af22 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -325,8 +325,6 @@ static int __init ipv6_offload_init(void)
 
 	if (tcpv6_offload_init() < 0)
 		pr_crit("%s: Cannot add TCP protocol offload\n", __func__);
-	if (udp_offload_init() < 0)
-		pr_crit("%s: Cannot add UDP protocol offload\n", __func__);
 	if (ipv6_exthdrs_offload_init() < 0)
 		pr_crit("%s: Cannot add EXTHDRS protocol offload\n", __func__);
 
diff --git a/net/ipv6/ip6_offload.h b/net/ipv6/ip6_offload.h
index 2e155c6..96b40e4 100644
--- a/net/ipv6/ip6_offload.h
+++ b/net/ipv6/ip6_offload.h
@@ -12,7 +12,8 @@
 #define __ip6_offload_h
 
 int ipv6_exthdrs_offload_init(void);
-int udp_offload_init(void);
+int udpv6_offload_init(void);
+int udpv6_offload_exit(void);
 int tcpv6_offload_init(void);
 
 #endif
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 2b0fbe6..5429f6b 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -153,7 +153,7 @@ static struct sk_buff **udp6_gro_receive(struct sk_buff **head,
 
 skip:
 	NAPI_GRO_CB(skb)->is_ipv6 = 1;
-	return udp_gro_receive(head, skb, uh);
+	return udp_gro_receive(head, skb, uh, udp6_lib_lookup_skb);
 
 flush:
 	NAPI_GRO_CB(skb)->flush = 1;
@@ -173,7 +173,7 @@ static int udp6_gro_complete(struct sk_buff *skb, int nhoff)
 		skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;
 	}
 
-	return udp_gro_complete(skb, nhoff);
+	return udp_gro_complete(skb, nhoff, udp6_lib_lookup_skb);
 }
 
 static const struct net_offload udpv6_offload = {
@@ -184,7 +184,12 @@ static const struct net_offload udpv6_offload = {
 	},
 };
 
-int __init udp_offload_init(void)
+int udpv6_offload_init(void)
 {
 	return inet6_add_offload(&udpv6_offload, IPPROTO_UDP);
 }
+
+int udpv6_offload_exit(void)
+{
+	return inet6_del_offload(&udpv6_offload, IPPROTO_UDP);
+}
-- 
2.8.0.rc2
