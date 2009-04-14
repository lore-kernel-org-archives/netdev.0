From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: tun: Fix crash with non-GSO users
Date: Tue, 14 Apr 2009 12:22:58 +0800
Message-ID: <20090414042258.GA27159@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51612 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750746AbZDNEXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 00:23:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

tun: Fix crash with non-GSO users

When I made the tun driver use non-linear packets as the preferred
option, it broke non-GSO users because they would end up allocating
a completely non-linear packet, which triggers a crash when we call
eth_type_trans.

This patch reverts non-GSO users to using linear packets and adds
a check to ensure that GSO users can't cause crashes in the same
way.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a1b0697..16716ae 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -518,7 +518,7 @@ static inline struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
 	int err;
 
 	/* Under a page?  Don't bother with paged skb. */
-	if (prepad + len < PAGE_SIZE)
+	if (prepad + len < PAGE_SIZE || !linear)
 		linear = len;
 
 	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
@@ -565,7 +565,8 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 
 	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
 		align = NET_IP_ALIGN;
-		if (unlikely(len < ETH_HLEN))
+		if (unlikely(len < ETH_HLEN ||
+			     (gso.hdr_len && gso.hdr_len < ETH_HLEN)))
 			return -EINVAL;
 	}

 Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
