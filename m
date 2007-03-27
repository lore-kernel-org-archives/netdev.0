From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Allow ip_summed to be forwarded as is
Date: Tue, 27 Mar 2007 15:22:43 +1000
Message-ID: <20070327052243.GA22442@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3998 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933994AbXC0FWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 01:22:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[NET]: Allow ip_summed to be forwarded as is

Right now Xen has a horrible hack that lets it forward packets with
partial checksums.  One of the reasons that CHECKSUM_PARTIAL and
CHECKSUM_COMPLETE were added is so that we can get rid of this hack
(where it creates two extra bits in the skbuff to essentially mirror
ip_summed without being destroyed by the forwarding code).

I had forgotten that I've already gone through all the deivce drivers
last time around to make sure that they're looking at ip_summed ==
CHECKSUM_PARTIAL rather than ip_summed != 0 on transmit.  In any case,
I've now done that again so it should definitely be safe.

So here is the patch that lets us get rid of the hack by preserving
ip_summed on forwarded packets.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 3e45c1a..f0a270a 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -71,7 +71,6 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 
 	indev = skb->dev;
 	skb->dev = to->dev;
-	skb->ip_summed = CHECKSUM_NONE;
 
 	NF_HOOK(PF_BRIDGE, NF_BR_FORWARD, skb, indev, skb->dev,
 			br_forward_finish);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 369e721..1c65ff9 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -67,8 +67,6 @@ int ip_forward(struct sk_buff *skb)
 	if (skb->pkt_type != PACKET_HOST)
 		goto drop;
 
-	skb->ip_summed = CHECKSUM_NONE;
-
 	/*
 	 *	According to the RFC, we must first decrease the TTL field. If
 	 *	that reaches zero, we must reply an ICMP control message telling
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 3055169..a6fe803 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -372,8 +372,6 @@ int ip6_forward(struct sk_buff *skb)
 		goto drop;
 	}
 
-	skb->ip_summed = CHECKSUM_NONE;
-
 	/*
 	 *	We DO NOT make any processing on
 	 *	RA packets, pushing them to user level AS IS
