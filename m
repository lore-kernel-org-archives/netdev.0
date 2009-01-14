From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gro: Check for GSO packets and packets with frag_list
Date: Thu, 15 Jan 2009 08:56:39 +1100
Message-ID: <20090114215639.GA25069@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57454 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758293AbZANV4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 16:56:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

Here's a patch for GRO allowing it to be used on more drivers.

gro: Check for GSO packets and packets with frag_list

As GRO cannot be applied to packets with frag_list we need to
make sure that we reject such packets if they are fed to us,
e.g., through a tunnel device.

Also there is no point in applying GRO on GSO packets so they
too should be rejected.  This allows GRO to be used in virtio-net
which may produce GSO packets directly but may still benefit
from GRO if the other end of it doesn't support GSO.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index 5f736f1..972a47d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2382,6 +2382,9 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	if (!(skb->dev->features & NETIF_F_GRO))
 		goto normal;
 
+	if (skb_is_gso(skb) || skb_shinfo(skb)->frag_list)
+		goto normal;
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
 		struct sk_buff *p;

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
