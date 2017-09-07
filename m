From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 6/6] Modify tag_ksz.c to support other KSZ switch
 drivers
Date: Thu, 7 Sep 2017 23:48:34 +0200
Message-ID: <20170907214834.GT11248@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121901@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121A22@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121A22@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 07, 2017 at 09:09:30PM +0000, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
> 
> The KSZ tail tag code can be used by different KSZ switch drivers.
> 
> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> ---
> diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c index 010ca0a..d5faf14 100644
> --- a/net/dsa/tag_ksz.c
> +++ b/net/dsa/tag_ksz.c
> @@ -13,35 +13,21 @@
>  #include <linux/slab.h>
>  #include <net/dsa.h>
>  #include "dsa_priv.h"
> -
> -/* For Ingress (Host -> KSZ), 2 bytes are added before FCS.
> - * ---------------------------------------------------------------------------
> - * DA(6bytes)|SA(6bytes)|....|Data(nbytes)|tag0(1byte)|tag1(1byte)|FCS(4bytes)
> - * ---------------------------------------------------------------------------
> - * tag0 : Prioritization (not used now)
> - * tag1 : each bit represents port (eg, 0x01=port1, 0x02=port2, 0x10=port5)
> - *
> - * For Egress (KSZ -> Host), 1 byte is added before FCS.
> - * ---------------------------------------------------------------------------
> - * DA(6bytes)|SA(6bytes)|....|Data(nbytes)|tag0(1byte)|FCS(4bytes)
> - * ---------------------------------------------------------------------------
> - * tag0 : zero-based value represents port
> - *	  (eg, 0x00=port1, 0x02=port3, 0x06=port7)
> - */
> -
> -#define	KSZ_INGRESS_TAG_LEN	2
> -#define	KSZ_EGRESS_TAG_LEN	1
> +#include "../../drivers/net/dsa/microchip/ksz_priv.h"

No.

Move the header file to somewhere under include/linux. You can split
it into private and public parts if you want, and just put the public
bits in include/linux.

>  static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
> +	struct dsa_switch *ds = p->dp->ds;
> +	struct ksz_device *swdev = ds->priv;
>  	struct sk_buff *nskb;
> +	int len;
>  	int padlen;
> -	u8 *tag;
>  
>  	padlen = (skb->len >= ETH_ZLEN) ? 0 : ETH_ZLEN - skb->len;
>  
> -	if (skb_tailroom(skb) >= padlen + KSZ_INGRESS_TAG_LEN) {
> +	len = swdev->dev_ops->get_tx_len(swdev);

This is ugly. We have a clean separation between a switch driver and a
tag driver. Here you are mixing them together. Don't. Look at the
mailing lists for what Florian and I suggested to Pavel. It will also
solve your include file issue above.

	 Andrew
