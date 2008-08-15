From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for
 iptables nat routing
Date: Fri, 15 Aug 2008 14:54:34 -0700 (PDT)
Message-ID: <20080815.145434.259306809.davem@davemloft.net>
References: <20080815073343.GA20644@gondor.apana.org.au>
	<20080815081442.GA20971@gondor.apana.org.au>
	<20080815103235.GA31963@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, kaber@trash.net, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54093
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751995AbYHOVyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 17:54:35 -0400
In-Reply-To: <20080815103235.GA31963@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 15 Aug 2008 20:32:35 +1000

> loopback: Enable TSO
> 
> This patch enables TSO since the loopback device is naturally
> capable of handling packets of any size.  This also means that
> we won't enable GSO on lo which is good until GSO is fixed to
> preserve netfilter state as netfilter treats loopback packets
> in a special way.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Meanwhile I applied this and I took the liberty of applying
the following right afterwards:

loopback: Remove rest of LOOPBACK_TSO code.

It hasn't been enabled for a long time and the generic GSO
engine is better documentation of what is expected of a
device implementing TSO.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/loopback.c |   62 ------------------------------------------------
 1 files changed, 0 insertions(+), 62 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 46e87cc..489d53b 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -64,68 +64,6 @@ struct pcpu_lstats {
 	unsigned long bytes;
 };
 
-/* KISS: just allocate small chunks and copy bits.
- *
- * So, in fact, this is documentation, explaining what we expect
- * of largesending device modulo TCP checksum, which is ignored for loopback.
- */
-
-#ifdef LOOPBACK_TSO
-static void emulate_large_send_offload(struct sk_buff *skb)
-{
-	struct iphdr *iph = ip_hdr(skb);
-	struct tcphdr *th = (struct tcphdr *)(skb_network_header(skb) +
-					      (iph->ihl * 4));
-	unsigned int doffset = (iph->ihl + th->doff) * 4;
-	unsigned int mtu = skb_shinfo(skb)->gso_size + doffset;
-	unsigned int offset = 0;
-	u32 seq = ntohl(th->seq);
-	u16 id  = ntohs(iph->id);
-
-	while (offset + doffset < skb->len) {
-		unsigned int frag_size = min(mtu, skb->len - offset) - doffset;
-		struct sk_buff *nskb = alloc_skb(mtu + 32, GFP_ATOMIC);
-
-		if (!nskb)
-			break;
-		skb_reserve(nskb, 32);
-		skb_set_mac_header(nskb, -ETH_HLEN);
-		skb_reset_network_header(nskb);
-		iph = ip_hdr(nskb);
-		skb_copy_to_linear_data(nskb, skb_network_header(skb),
-					doffset);
-		if (skb_copy_bits(skb,
-				  doffset + offset,
-				  nskb->data + doffset,
-				  frag_size))
-			BUG();
-		skb_put(nskb, doffset + frag_size);
-		nskb->ip_summed = CHECKSUM_UNNECESSARY;
-		nskb->dev = skb->dev;
-		nskb->priority = skb->priority;
-		nskb->protocol = skb->protocol;
-		nskb->dst = dst_clone(skb->dst);
-		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
-		nskb->pkt_type = skb->pkt_type;
-
-		th = (struct tcphdr *)(skb_network_header(nskb) + iph->ihl * 4);
-		iph->tot_len = htons(frag_size + doffset);
-		iph->id = htons(id);
-		iph->check = 0;
-		iph->check = ip_fast_csum((unsigned char *) iph, iph->ihl);
-		th->seq = htonl(seq);
-		if (offset + doffset + frag_size < skb->len)
-			th->fin = th->psh = 0;
-		netif_rx(nskb);
-		offset += frag_size;
-		seq += frag_size;
-		id++;
-	}
-
-	dev_kfree_skb(skb);
-}
-#endif /* LOOPBACK_TSO */
-
 /*
  * The higher levels take care of making this non-reentrant (it's
  * called with bh's disabled).
-- 
1.5.6.5.GIT

