From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: Set CHECKSUM_UNNECESSARY in tcp_init_nondata_skb
Date: Thu, 8 Apr 2010 21:57:15 +0800
Message-ID: <20100408135715.GA24890@gondor.apana.org.au>
References: <20100408.012617.98660541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:36133 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758490Ab0DHN5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 09:57:19 -0400
Content-Disposition: inline
In-Reply-To: <20100408.012617.98660541.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 01:26:17AM -0700, David Miller wrote:
> 
> Back in commit 04a0551c87363f100b04d28d7a15a632b70e18e7
> ("loopback: Drop obsolete ip_summed setting") we stopped
> setting CHECKSUM_UNNECESSARY in the loopback xmit.
> 
> This is because such a setting was a lie since it implies that the
> checksum field of the packet is properly filled in.
> 
> Instead what happens normally is that CHECKSUM_PARTIAL is set and
> skb->csum is calculated as needed.
> 
> But this was only happening for TCP data packets (via the
> skb->ip_summed assignment done in tcp_sendmsg()).  It doesn't
> happen for non-data packets like ACKs etc.

Actually, the checksum is still calculated in this case as otherwise
people would've screamed murder since their TCP connections would
have stopped working :)

However, it is suboptimal for loopback because we'll end up doing
an unnecessary verification for non-data packets.

> Fix this by setting skb->ip_summed in the common non-data packet
> constructor.  It already is setting skb->csum to zero.

The problem here is that for non-data packets CHECKSUM_PARTIAL
can actually end up being worse if we wind up going out through
an interface that doesn't support checksums.

The crux of the matter is to how to distinguish between those
packets where we have computed the checksum ourselves (such as
these non-data TCP packets), vs. packets from other sources where
we don't trust the checksum to be correct.

Since using CHECKSUM_PARTIAL is problematic, another possibility
is to use CHECKSUM_UNNECESSARY to indicate this.

I've gone through the core TX paths and it would appear that
all of them can handle packets with CHECKSUM_UNNECESSARY.  They
will be treated in the same way as CHECKSUM_NONE.

In fact most drivers can handle this too, since they just do
skb->ip_summed == CHECKSUM_PARTIAL and treat everything else
as the same.  Unfortunately, some drivers do the opposite check.

So for the time being, we need to ensure that by the time the skb
hits the driver ip_summed is either CHECKSUM_PARTIAL or CHECKSUM_NONE.

net: Sanitise ip_summed before ndo_start_xmit

We would like to use CHECKSUM_UNNECESSARY on the TX path to mark
packets that are known to have a correct checksum.  However, some
drivers cannot handle this value.

This patch ensures that the value of ip_summed is one that all
drivers can handle before calling ndo_start_xmit.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index 1c8a0ce..2784298 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1877,6 +1877,13 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(skb);
 
+		/*
+		 * When drivers are ready for all possible values of
+		 * ip_summed we can remove this.
+		 */
+		if (skb->ip_summed != CHECKSUM_PARTIAL)
+			skb->ip_summed = CHECKSUM_NONE;
+
 		rc = ops->ndo_start_xmit(skb, dev);
 		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
