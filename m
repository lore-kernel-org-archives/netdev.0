From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 2/2] net: dsa: skb_put_padto() already frees nskb
Date: Tue, 22 Aug 2017 15:12:15 -0700
Message-ID: <20170822221215.16305-3-f.fainelli@gmail.com>
References: <20170822221215.16305-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, UNGLinuxDriver@microchip.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36769 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752709AbdHVWMa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 18:12:30 -0400
Received: by mail-wm0-f68.google.com with SMTP id p17so470607wmd.3
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 15:12:29 -0700 (PDT)
In-Reply-To: <20170822221215.16305-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first call of skb_put_padto() will free up the SKB on error, but we
return NULL which tells dsa_slave_xmit() that the original SKB should be
freed so this would lead to a double free here.

The second skb_put_padto() already frees the passed sk_buff reference
upon error, so calling kfree_skb() on it again is not necessary.

Detected by CoverityScan, CID#1416687 ("USE_AFTER_FREE")

Fixes: e71cb9e00922 ("net: dsa: ksz: fix skb freeing")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/tag_ksz.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index de66ca8e6201..3bd6e2a83125 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -42,7 +42,8 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 	padlen = (skb->len >= ETH_ZLEN) ? 0 : ETH_ZLEN - skb->len;
 
 	if (skb_tailroom(skb) >= padlen + KSZ_INGRESS_TAG_LEN) {
-		if (skb_put_padto(skb, skb->len + padlen))
+		/* Let dsa_slave_xmit() free skb */
+		if (__skb_put_padto(skb, skb->len + padlen, false))
 			return NULL;
 
 		nskb = skb;
@@ -60,10 +61,11 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 					 skb_transport_header(skb) - skb->head);
 		skb_copy_and_csum_dev(skb, skb_put(nskb, skb->len));
 
-		if (skb_put_padto(nskb, nskb->len + padlen)) {
-			kfree_skb(nskb);
+		/* Let skb_put_padto() free nskb, and let dsa_slave_xmit() free
+		 * skb
+		 */
+		if (skb_put_padto(nskb, nskb->len + padlen))
 			return NULL;
-		}
 
 		kfree_skb(skb);
 	}
-- 
2.9.3
