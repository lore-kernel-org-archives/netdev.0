From: Tom Herbert <therbert@google.com>
Subject: [PATCH 5/5] udp: additional GRO support
Date: Fri, 20 Jun 2014 16:38:04 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406201631360.11831@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:56680 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbaFTXiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 19:38:06 -0400
Received: by mail-ie0-f202.google.com with SMTP id tr6so1104367ieb.3
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 16:38:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement GRO for UDPv6. Add UDP checksum verification in gro_receive
for both UDP4 and UDP6 calling skb_gro_checksum_validate_zero_check.
Also, remove check for CHECKSUM_COMPLETE in udp_gro_receive, any
checksum type should be handled now.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/udp.h      | 18 +++++++++++++++
 net/ipv4/udp.c         |  1 +
 net/ipv4/udp_offload.c | 61 +++++++++++++++++++++++++++++++++++---------------
 net/ipv6/udp_offload.c | 33 +++++++++++++++++++++++++++
 4 files changed, 95 insertions(+), 18 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 68a1fef..fb7bfe7 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -158,6 +158,24 @@ static inline __sum16 udp_v4_check(int len, __be32 saddr,
 void udp_set_csum(bool nocheck, struct sk_buff *skb,
 		  __be32 saddr, __be32 daddr, int len);
 
+struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
+				 struct udphdr *uh);
+int udp_gro_complete(struct sk_buff *skb, int nhoff);
+
+static inline struct udphdr *udp_gro_udphdr(struct sk_buff *skb)
+{
+	struct udphdr *uh;
+	unsigned int hlen, off;
+
+	off  = skb_gro_offset(skb);
+	hlen = off + sizeof(*uh);
+	uh   = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, hlen))
+		uh = skb_gro_header_slow(skb, hlen, off);
+
+	return uh;
+}
+
 /* hash routines shared between UDPv4/6 and UDP-Litev4/6 */
 static inline void udp_lib_hash(struct sock *sk)
 {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d92f94b..b6355f6 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -99,6 +99,7 @@
 #include <linux/slab.h>
 #include <net/tcp_states.h>
 #include <linux/skbuff.h>
+#include <linux/netdevice.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <net/net_namespace.h>
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index fb8e6ba..2ab9051 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -152,30 +152,21 @@ unlock:
 }
 EXPORT_SYMBOL(udp_del_offload);
 
-static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
+				 struct udphdr *uh)
 {
 	struct udp_offload_priv *uo_priv;
 	struct sk_buff *p, **pp = NULL;
-	struct udphdr *uh, *uh2;
-	unsigned int hlen, off;
+	struct udphdr *uh2;
+	unsigned int off = skb_gro_offset(skb);
 	int flush = 1;
 
-	if (NAPI_GRO_CB(skb)->udp_mark ||
-	    (!skb->encapsulation && skb->ip_summed != CHECKSUM_COMPLETE))
+	if (NAPI_GRO_CB(skb)->udp_mark)
 		goto out;
 
 	/* mark that this skb passed once through the udp gro layer */
 	NAPI_GRO_CB(skb)->udp_mark = 1;
 
-	off  = skb_gro_offset(skb);
-	hlen = off + sizeof(*uh);
-	uh   = skb_gro_header_fast(skb, off);
-	if (skb_gro_header_hard(skb, hlen)) {
-		uh = skb_gro_header_slow(skb, hlen, off);
-		if (unlikely(!uh))
-			goto out;
-	}
-
 	NAPI_GRO_CB(skb)->encapsulation = 1;
 
 	rcu_read_lock();
@@ -195,7 +186,12 @@ unflush:
 			continue;
 
 		uh2 = (struct udphdr   *)(p->data + off);
-		if ((*(u32 *)&uh->source != *(u32 *)&uh2->source)) {
+
+		/* Match ports and either checksums are either both zero
+		 * or nonzero.
+		 */
+		if ((*(u32 *)&uh->source != *(u32 *)&uh2->source) ||
+		    (!uh->check ^ !uh2->check)) {
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
@@ -212,7 +208,24 @@ out:
 	return pp;
 }
 
-static int udp_gro_complete(struct sk_buff *skb, int nhoff)
+static struct sk_buff **udp4_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb)
+{
+	struct udphdr *uh = udp_gro_udphdr(skb);
+
+	/* Don't bother verifying checksum if we're going to flush anyway. */
+	if (unlikely(!uh) ||
+	    (!NAPI_GRO_CB(skb)->flush &&
+	     skb_gro_checksum_validate_zero_check(skb, IPPROTO_UDP, uh->check,
+						  inet_gro_compute_pseudo))) {
+		NAPI_GRO_CB(skb)->flush = 1;
+		return NULL;
+	}
+
+	return udp_gro_receive(head, skb, uh);
+}
+
+int udp_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	struct udp_offload_priv *uo_priv;
 	__be16 newlen = htons(skb->len - nhoff);
@@ -237,12 +250,24 @@ static int udp_gro_complete(struct sk_buff *skb, int nhoff)
 	return err;
 }
 
+int udp4_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
+
+	if (uh->check)
+		uh->check = ~udp_v4_check(skb->len - nhoff, iph->saddr,
+					  iph->daddr, 0);
+
+	return udp_gro_complete(skb, nhoff);
+}
+
 static const struct net_offload udpv4_offload = {
 	.callbacks = {
 		.gso_send_check = udp4_ufo_send_check,
 		.gso_segment = udp4_ufo_fragment,
-		.gro_receive  =	udp_gro_receive,
-		.gro_complete =	udp_gro_complete,
+		.gro_receive  =	udp4_gro_receive,
+		.gro_complete =	udp4_gro_complete,
 	},
 };
 
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 0ae3d98..b13e377 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -10,6 +10,7 @@
  *      UDPv6 GSO support
  */
 #include <linux/skbuff.h>
+#include <linux/netdevice.h>
 #include <net/protocol.h>
 #include <net/ipv6.h>
 #include <net/udp.h>
@@ -127,10 +128,42 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 out:
 	return segs;
 }
+
+static struct sk_buff **udp6_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb)
+{
+	struct udphdr *uh = udp_gro_udphdr(skb);
+
+	/* Don't bother verifying checksum if we're going to flush anyway. */
+	if (unlikely(!uh) ||
+	    (!NAPI_GRO_CB(skb)->flush &&
+	     skb_gro_checksum_validate_zero_check(skb, IPPROTO_UDP, uh->check,
+						  ip6_gro_compute_pseudo))) {
+		NAPI_GRO_CB(skb)->flush = 1;
+		return NULL;
+	}
+
+	return udp_gro_receive(head, skb, uh);
+}
+
+int udp6_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+	struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
+
+	if (uh->check)
+		uh->check = ~udp_v6_check(skb->len - nhoff, &ipv6h->saddr,
+					  &ipv6h->daddr, 0);
+
+	return udp_gro_complete(skb, nhoff);
+}
+
 static const struct net_offload udpv6_offload = {
 	.callbacks = {
 		.gso_send_check =	udp6_ufo_send_check,
 		.gso_segment	=	udp6_ufo_fragment,
+		.gro_receive	=	udp6_gro_receive,
+		.gro_complete	=	udp6_gro_complete,
 	},
 };
 
-- 
2.0.0.526.g5318336
