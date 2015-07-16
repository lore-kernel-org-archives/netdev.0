From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: sit: Set SKB_GSO_SIT bit when performing GRO
Date: Thu, 16 Jul 2015 08:23:50 +0800
Message-ID: <20150716002350.GA7529@gondor.apana.org.au>
References: <17762800.UBb5paxXY3@h2o.as.studentenwerk.mhn.de>
 <8145949.lUzHGl5xdY@h2o.as.studentenwerk.mhn.de>
 <20150715095019.GA881@gondor.apana.org.au>
 <2477915.Hv2mXUtnDZ@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:47114 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977AbbGPAYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 20:24:16 -0400
Content-Disposition: inline
In-Reply-To: <2477915.Hv2mXUtnDZ@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 02:25:59PM +0200, Wolfgang Walter wrote:
>
> Yes. Switching TSO off and leaving GRO on works, too.

OK, could you please try this patch?

---8<---
We need to set the SKB_GSO_SIT bit if we detect a 6-in-4 tunnel
when doing GRO.  Otherwise we may throw a packet at TSO hardware
that doesn't know what to do with it.

Fixes: 19424e052fb4 ("sit: Add gro callbacks to sit_offload")
Reported-by: Wolfgang Walter <linux@stwm.de>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index e893cd1..1252eac 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -289,11 +289,21 @@ static struct packet_offload ipv6_packet_offload __read_mostly = {
 	},
 };
 
+static int sit_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	int err = ipv6_gro_complete(skb, nhoff);
+
+	skb->encapsulation = 1;
+	skb_shinfo(skb)->gso_type |= SKB_GSO_SIT;
+
+	return err;
+}
+
 static const struct net_offload sit_offload = {
 	.callbacks = {
 		.gso_segment	= ipv6_gso_segment,
 		.gro_receive	= ipv6_gro_receive,
-		.gro_complete	= ipv6_gro_complete,
+		.gro_complete	= sit_gro_complete,
 	},
 };
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
