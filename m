From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 9/14] gro: Avoid unnecessary comparison after skb_gro_header
Date: Wed, 27 May 2009 14:50:28 +1000
Message-ID: <E1M9B5w-0001Sn-Oi@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49801 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751228AbZE0FHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 01:07:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Avoid unnecessary comparison after skb_gro_header

For the overwhelming majority of cases, skb_gro_header's return
value cannot be NULL.  Yet we must check it because of its current
form.  This patch splits it up into multiple functions in order
to avoid this.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netdevice.h |   23 ++++++++++++++---------
 net/core/dev.c            |   17 ++++++++++++-----
 net/ipv4/af_inet.c        |   13 ++++++++++---
 net/ipv4/tcp.c            |   22 ++++++++++++++++------
 net/ipv6/af_inet6.c       |   13 ++++++++++---
 5 files changed, 62 insertions(+), 26 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 966c413..d2b1561 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1132,18 +1132,23 @@ static inline void skb_gro_pull(struct sk_buff *skb, unsigned int len)
 	NAPI_GRO_CB(skb)->data_offset += len;
 }
 
-static inline void *skb_gro_header(struct sk_buff *skb, unsigned int hlen)
+static inline void *skb_gro_header_fast(struct sk_buff *skb,
+					unsigned int offset)
 {
-	unsigned int offset = skb_gro_offset(skb);
+	return NAPI_GRO_CB(skb)->frag0 + offset;
+}
 
-	hlen += offset;
-	if (NAPI_GRO_CB(skb)->frag0_len < hlen) {
-		NAPI_GRO_CB(skb)->frag0 = NULL;
-		NAPI_GRO_CB(skb)->frag0_len = 0;
-		return pskb_may_pull(skb, hlen) ? skb->data + offset : NULL;
-	}
+static inline int skb_gro_header_hard(struct sk_buff *skb, unsigned int hlen)
+{
+	return NAPI_GRO_CB(skb)->frag0_len < hlen;
+}
 
-	return NAPI_GRO_CB(skb)->frag0 + offset;
+static inline void *skb_gro_header_slow(struct sk_buff *skb, unsigned int hlen,
+					unsigned int offset)
+{
+	NAPI_GRO_CB(skb)->frag0 = NULL;
+	NAPI_GRO_CB(skb)->frag0_len = 0;
+	return pskb_may_pull(skb, hlen) ? skb->data + offset : NULL;
 }
 
 static inline void *skb_gro_mac_header(struct sk_buff *skb)
diff --git a/net/core/dev.c b/net/core/dev.c
index e634c8a..5a81302 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2587,17 +2587,24 @@ struct sk_buff *napi_frags_skb(struct napi_struct *napi)
 {
 	struct sk_buff *skb = napi->skb;
 	struct ethhdr *eth;
+	unsigned int hlen;
+	unsigned int off;
 
 	napi->skb = NULL;
 
 	skb_reset_mac_header(skb);
 	skb_gro_reset_offset(skb);
 
-	eth = skb_gro_header(skb, sizeof(*eth));
-	if (!eth) {
-		napi_reuse_skb(napi, skb);
-		skb = NULL;
-		goto out;
+	off = skb_gro_offset(skb);
+	hlen = off + sizeof(*eth);
+	eth = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, hlen)) {
+		eth = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!eth)) {
+			napi_reuse_skb(napi, skb);
+			skb = NULL;
+			goto out;
+		}
 	}
 
 	skb_gro_pull(skb, sizeof(*eth));
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1706896..644cc55 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1246,13 +1246,20 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	struct sk_buff **pp = NULL;
 	struct sk_buff *p;
 	struct iphdr *iph;
+	unsigned int hlen;
+	unsigned int off;
 	int flush = 1;
 	int proto;
 	int id;
 
-	iph = skb_gro_header(skb, sizeof(*iph));
-	if (unlikely(!iph))
-		goto out;
+	off = skb_gro_offset(skb);
+	hlen = off + sizeof(*iph);
+	iph = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, hlen)) {
+		iph = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!iph))
+			goto out;
+	}
 
 	proto = iph->protocol & (MAX_INET_PROTOS - 1);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 68342d4..c3dcec5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2518,20 +2518,30 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	unsigned int thlen;
 	unsigned int flags;
 	unsigned int mss = 1;
+	unsigned int hlen;
+	unsigned int off;
 	int flush = 1;
 	int i;
 
-	th = skb_gro_header(skb, sizeof(*th));
-	if (unlikely(!th))
-		goto out;
+	off = skb_gro_offset(skb);
+	hlen = off + sizeof(*th);
+	th = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, hlen)) {
+		th = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!th))
+			goto out;
+	}
 
 	thlen = th->doff * 4;
 	if (thlen < sizeof(*th))
 		goto out;
 
-	th = skb_gro_header(skb, thlen);
-	if (unlikely(!th))
-		goto out;
+	hlen = off + thlen;
+	if (skb_gro_header_hard(skb, hlen)) {
+		th = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!th))
+			goto out;
+	}
 
 	skb_gro_pull(skb, thlen);
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 61f5538..b6215be 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -817,13 +817,20 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	struct sk_buff *p;
 	struct ipv6hdr *iph;
 	unsigned int nlen;
+	unsigned int hlen;
+	unsigned int off;
 	int flush = 1;
 	int proto;
 	__wsum csum;
 
-	iph = skb_gro_header(skb, sizeof(*iph));
-	if (unlikely(!iph))
-		goto out;
+	off = skb_gro_offset(skb);
+	hlen = off + sizeof(*iph);
+	iph = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, hlen)) {
+		iph = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!iph))
+			goto out;
+	}
 
 	skb_gro_pull(skb, sizeof(*iph));
 	skb_set_transport_header(skb, skb_gro_offset(skb));
