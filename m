From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Allow forwarding of ip_summed except CHECKSUM_COMPLETE
Date: Tue, 27 Mar 2007 15:38:21 +1000
Message-ID: <20070327053821.GA23596@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4092 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753043AbXC0Fia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 01:38:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[NET]: Allow forwarding of ip_summed except CHECKSUM_COMPLETE

Right now Xen has a horrible hack that lets it forward packets with
partial checksums.  One of the reasons that CHECKSUM_PARTIAL and
CHECKSUM_COMPLETE were added is so that we can get rid of this hack
(where it creates two extra bits in the skbuff to essentially mirror
ip_summed without being destroyed by the forwarding code).

I had forgotten that I've already gone through all the deivce drivers
last time around to make sure that they're looking at ip_summed ==
CHECKSUM_PARTIAL rather than ip_summed != 0 on transmit.  In any case,
I've now done that again so it should definitely be safe.

Unfortunately nobody has yet added any code to update CHECKSUM_COMPLETE
values on forward so we I'm setting that to CHECKSUM_NONE.  This should
be safe to remove for bridging but I'd like to check that code path
first.

So here is the patch that lets us get rid of the hack by preserving
ip_summed (mostly) on forwarded packets.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4ff3940..6d4243d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1481,5 +1481,12 @@ static inline int skb_is_gso(const struct sk_buff *skb)
 	return skb_shinfo(skb)->gso_size;
 }
 
+static inline void skb_forward_csum(struct sk_buff *skb)
+{
+	/* Unfortunately we don't support this one.  Any brave souls? */
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
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
