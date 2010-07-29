From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] bridge leaks 3 references on lo per up&down
Date: Thu, 29 Jul 2010 19:12:31 +0800
Message-ID: <20100729111231.GA30021@gondor.apana.org.au>
References: <20100727152514.GA13413@jupiter.n2.diac24.net> <20100727100249.51ffc893@nehalam> <20100728074428.GB13413@jupiter.n2.diac24.net> <20100728095825.GC13413@jupiter.n2.diac24.net> <20100728120336.GD13413@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bridge@lists.linux-foundation.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54513 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731Ab0G2LMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 07:12:38 -0400
Content-Disposition: inline
In-Reply-To: <20100728120336.GD13413@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 28, 2010 at 02:03:36PM +0200, David Lamparter wrote:
> 
> Herbert, you implemented bridge multicast support, maybe you can figure
> out where these references are taken?

OK this patch should fix it.

However, it also means that the IPv6 membership report parsing is
broken and we still need look into it.

bridge: Fix skb leak when multicast parsing fails on TX

On the bridge TX path we're leaking an skb when br_multicast_rcv
returns an error.

Reported-by: David Lamparter <equinox@diac24.net>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 753fc42..f49f20b 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -47,8 +47,10 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_pull(skb, ETH_HLEN);
 
 	if (is_multicast_ether_addr(dest)) {
-		if (br_multicast_rcv(br, NULL, skb))
+		if (br_multicast_rcv(br, NULL, skb)) {
+			kfree_skb(skb);
 			goto out;
+		}
 
 		mdst = br_mdb_get(br, skb);
 		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb))

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
