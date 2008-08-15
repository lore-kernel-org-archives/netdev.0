From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for	iptables nat routing
Date: Fri, 15 Aug 2008 15:35:48 +1000
Message-ID: <20080815053548.GA6366@gondor.apana.org.au>
References: <1218726484.23510.20.camel@2710p.home> <E1KTrAo-0001YG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57197 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750867AbYHOFgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 01:36:01 -0400
Content-Disposition: inline
In-Reply-To: <E1KTrAo-0001YG-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2008 at 02:44:26PM +1000, Herbert Xu wrote:
> 
> Actually, I think know what's going on but a raw packet dump should
> confirm whether we're getting a partial checksum.

Nevermind, I think I've found the problem.

loopback: Drop obsolete ip_summed setting

Now that the network stack can handle inbound packets with partial
checksums, we should no longer clobber the ip_summed field in the
loopback driver.  This is because CHECKSUM_UNNECESSARY implies that
the checksum field is actually valid which is not true for loopback
packets since it's only partial (and thus complemented).

This allows packets from lo to then be SNATed to an external source
while still preserving the checksum's validity.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 49f6bc0..810e292 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -137,9 +137,6 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_orphan(skb);
 
 	skb->protocol = eth_type_trans(skb,dev);
-#ifndef LOOPBACK_MUST_CHECKSUM
-	skb->ip_summed = CHECKSUM_UNNECESSARY;
-#endif
 
 #ifdef LOOPBACK_TSO
 	if (skb_is_gso(skb)) {
