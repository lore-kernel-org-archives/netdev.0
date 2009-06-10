From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: virtio-net header alignment
Date: Wed, 10 Jun 2009 15:12:27 +1000
Message-ID: <20090610051227.GB16563@gondor.apana.org.au>
References: <OF1B881599.F1B4A2EF-ON802575BB.0036EA40-802575BC.0041BFB5@au1.ibm.com> <200905251601.29327.rusty@rustcorp.com.au> <1243268223.32745.25.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Danielius Kudinskas <kudinskas@uk.ibm.com>,
	aliguori@linux.vnet.ibm.com, Paul T Knowles <pablo@uk.ibm.com>,
	netdev@vger.kernel.org
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37040 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753658AbZFJFMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 01:12:39 -0400
Content-Disposition: inline
In-Reply-To: <1243268223.32745.25.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 25, 2009 at 05:17:03PM +0100, Mark McLoughlin wrote:
> 
> Perhaps; would padding struct virtio_net_hdr_mrg_rxbuf have avoided it?
> 
> Cc-ing Herbert, he initially wrote the guest side of this.

Does this fix it?

virtio_net: Fix IP alignment on mergeable RX path

We need to enforce the IP alignment on the mergeable RX path just
like the other RX path.  Not doing so results in misaligned IP
headers.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4d1d479..52fba8e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -283,10 +283,11 @@ static void try_fill_recv_maxbufs(struct virtnet_info *vi)
 	for (;;) {
 		struct virtio_net_hdr *hdr;
 
-		skb = netdev_alloc_skb(vi->dev, MAX_PACKET_LEN);
+		skb = netdev_alloc_skb(vi->dev, MAX_PACKET_LEN + NET_IP_ALIGN);
 		if (unlikely(!skb))
 			break;
 
+		skb_reserve(skb, NET_IP_ALIGN);
 		skb_put(skb, MAX_PACKET_LEN);
 
 		hdr = skb_vnet_hdr(skb);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
