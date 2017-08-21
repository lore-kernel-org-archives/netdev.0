From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net] net: dsa: skb_put_padto() already frees nskb
Date: Mon, 21 Aug 2017 22:15:56 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B048CD@CHN-SV-EXMX02.mchp-main.com>
References: <20170821194143.27885-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>
To: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa4.microchip.iphmx.com ([68.232.154.123]:64986 "EHLO
        esa4.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754257AbdHUWQM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 18:16:12 -0400
In-Reply-To: <20170821194143.27885-1-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian,

> -----Original Message-----
> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: Monday, August 21, 2017 3:42 PM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; andrew@lunn.ch;
> vivien.didelot@savoirfairelinux.com; Woojung Huh - C21699; Florian Fainelli
> Subject: [PATCH net] net: dsa: skb_put_padto() already frees nskb
> 
> skb_put_padto() already frees the passed sk_buff reference upon error,
> so calling kfree_skb() on it again is not necessary.
> 
> Detected by CoverityScan, CID#1416687 ("USE_AFTER_FREE")
> 
> Fixes: e71cb9e00922 ("net: dsa: ksz: fix skb freeing")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  net/dsa/tag_ksz.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
> index de66ca8e6201..107172c82107 100644
> --- a/net/dsa/tag_ksz.c
> +++ b/net/dsa/tag_ksz.c
> @@ -60,10 +60,8 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb,
> struct net_device *dev)
>  					 skb_transport_header(skb) - skb-
> >head);
>  		skb_copy_and_csum_dev(skb, skb_put(nskb, skb->len));
> 
> -		if (skb_put_padto(nskb, nskb->len + padlen)) {
> -			kfree_skb(nskb);
> +		if (skb_put_padto(nskb, nskb->len + padlen))
>  			return NULL;
> -		}
> 
>  		kfree_skb(skb);
>  	}
> --

Because skb_put_padto() frees skb when it fails,  below lines in e71cb9e00922
("net: dsa: ksz: fix skb freeing") will be an issue to.

	if (skb_tailroom(skb) >= padlen + KSZ_INGRESS_TAG_LEN) {
+		if (skb_put_padto(skb, skb->len + padlen))
+			return NULL;
+

When it fails skb will be freed twice in skb_put_padto() and
caller of dsa_slave_xmit().

Woojung
