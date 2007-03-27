From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Allow partial checksums to be forwarded
Date: Tue, 27 Mar 2007 14:36:48 +1000
Message-ID: <20070327043648.GA21558@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3789 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932396AbXC0Egy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 00:36:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

Looks like I forgot to finish the checksum stuff for Xen last time around.

[NET]: Allow partial checksums to be forwarded

Right now Xen has a horrible hack that lets it forward packets with
partial checksums.  One of the reasons that CHECKSUM_PARTIAL was added
is so that we can get rid of this hack (where it creates an extra bit
in the skbuff to essentially mirror ip_summed without being destroyed
by the forwarding code).

So here is the patch that lets us get rid of the hack by preserving
CHECKSUM_PARTIAL on forwarded packets.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4ff3940..ecea1a0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -33,6 +33,10 @@
 
 #define CHECKSUM_NONE 0
 #define CHECKSUM_PARTIAL 1
+
+/* Values larger than this are invalid for TX. */
+#define CHECKSUM_TX_MAX 1
+
 #define CHECKSUM_UNNECESSARY 2
 #define CHECKSUM_COMPLETE 3
 
@@ -1481,5 +1485,11 @@ static inline int skb_is_gso(const struct sk_buff *skb)
 	return skb_shinfo(skb)->gso_size;
 }
 
+static inline void skb_forward_csum(struct sk_buff *skb)
+{
+	if (skb->ip_summed > CHECKSUM_TX_MAX)
+		skb->ip_summed = CHECKSUM_NONE;
+}
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 3e45c1a..ada7f49 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -71,7 +71,7 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 
 	indev = skb->dev;
 	skb->dev = to->dev;
-	skb->ip_summed = CHECKSUM_NONE;
+	skb_forward_csum(skb);
 
 	NF_HOOK(PF_BRIDGE, NF_BR_FORWARD, skb, indev, skb->dev,
 			br_forward_finish);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 369e721..a38037b 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -67,7 +67,7 @@ int ip_forward(struct sk_buff *skb)
 	if (skb->pkt_type != PACKET_HOST)
 		goto drop;
 
-	skb->ip_summed = CHECKSUM_NONE;
+	skb_forward_csum(skb);
 
 	/*
 	 *	According to the RFC, we must first decrease the TTL field. If
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 3055169..ba0143c 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -372,7 +372,7 @@ int ip6_forward(struct sk_buff *skb)
 		goto drop;
 	}
 
-	skb->ip_summed = CHECKSUM_NONE;
+	skb_forward_csum(skb);
 
 	/*
 	 *	We DO NOT make any processing on
