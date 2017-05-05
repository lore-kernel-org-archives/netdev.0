From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/5] dsa: add support for Microchip KSZ tail
 tagging
Date: Fri, 5 May 2017 16:34:15 -0700
Message-ID: <e2858cf1-45ed-f661-6699-cb0c4d439a93@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D40A5BFEC@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35494 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751344AbdEEXeT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 19:34:19 -0400
Received: by mail-qt0-f193.google.com with SMTP id r58so2777576qtb.2
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 16:34:18 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A5BFEC@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/2017 04:17 PM, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <Woojung.Huh@microchip.com>
> 
> Adding support for the Microchip KSZ switch family tail tagging.
> 
> Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>
> ---
>  include/net/dsa.h  |  1 +
>  net/dsa/Kconfig    |  3 ++
>  net/dsa/Makefile   |  1 +
>  net/dsa/dsa.c      |  3 ++
>  net/dsa/dsa_priv.h |  3 ++
>  net/dsa/tag_ksz.c  | 98 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 109 insertions(+)
>  create mode 100644 net/dsa/tag_ksz.c
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 8e24677..c92204a 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -34,6 +34,7 @@ enum dsa_tag_protocol {
>  	DSA_TAG_PROTO_QCA,
>  	DSA_TAG_PROTO_MTK,
>  	DSA_TAG_PROTO_LAN9303,
> +	DSA_TAG_PROTO_KSZ,
>  	DSA_TAG_LAST,		/* MUST BE LAST */
>  };
>  
> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
> index 81a0868..ce31428 100644
> --- a/net/dsa/Kconfig
> +++ b/net/dsa/Kconfig
> @@ -37,4 +37,7 @@ config NET_DSA_TAG_MTK
>  config NET_DSA_TAG_LAN9303
>  	bool
>  
> +config NET_DSA_TAG_KSZ
> +	bool
> +
>  endif
> diff --git a/net/dsa/Makefile b/net/dsa/Makefile
> index 0b747d7..8becb26 100644
> --- a/net/dsa/Makefile
> +++ b/net/dsa/Makefile
> @@ -10,3 +10,4 @@ dsa_core-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
>  dsa_core-$(CONFIG_NET_DSA_TAG_QCA) += tag_qca.o
>  dsa_core-$(CONFIG_NET_DSA_TAG_MTK) += tag_mtk.o
>  dsa_core-$(CONFIG_NET_DSA_TAG_LAN9303) += tag_lan9303.o
> +dsa_core-$(CONFIG_NET_DSA_TAG_KSZ) += tag_ksz.o
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 26130ae..6340323 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -61,6 +61,9 @@ const struct dsa_device_ops *dsa_device_ops[DSA_TAG_LAST] = {
>  #ifdef CONFIG_NET_DSA_TAG_LAN9303
>  	[DSA_TAG_PROTO_LAN9303] = &lan9303_netdev_ops,
>  #endif
> +#ifdef CONFIG_NET_DSA_TAG_KSZ
> +	[DSA_TAG_PROTO_KSZ] = &ksz_netdev_ops,
> +#endif
>  	[DSA_TAG_PROTO_NONE] = &none_ops,
>  };
>  
> diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
> index f4a88e4..70183ac 100644
> --- a/net/dsa/dsa_priv.h
> +++ b/net/dsa/dsa_priv.h
> @@ -96,4 +96,7 @@ extern const struct dsa_device_ops mtk_netdev_ops;
>  /* tag_lan9303.c */
>  extern const struct dsa_device_ops lan9303_netdev_ops;
>  
> +/* tag_ksz.c */
> +extern const struct dsa_device_ops ksz_netdev_ops;
> +
>  #endif
> diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
> new file mode 100644
> index 0000000..270bfb9
> --- /dev/null
> +++ b/net/dsa/tag_ksz.c
> @@ -0,0 +1,98 @@
> +/*
> + * net/dsa/tag_ksz.c - Microchip KSZ Switch tag format handling
> + * Copyright (c) 2017 Microchip Technology
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/etherdevice.h>
> +#include <linux/list.h>
> +#include <linux/slab.h>
> +#include <net/dsa.h>
> +#include "dsa_priv.h"
> +
> +/* For Ingress (Host -> KSZ), 2 bytes are added before FCS.
> + * ---------------------------------------------------------------------------
> + * DA(6bytes)|SA(6bytes)|....|Data(nbytes)|tag0(1byte)|tag1(1byte)|FCS(4bytes)
> + * ---------------------------------------------------------------------------
> + * tag0 : Prioritization (not used now)
> + * tag1 : each bit represents port (eg, 0x01=port1, 0x02=port2, 0x10=port5)
> + *
> + * For Egress (KSZ -> Host), 1 byte is added before FCS.
> + * ---------------------------------------------------------------------------
> + * DA(6bytes)|SA(6bytes)|....|Data(nbytes)|tag0(1byte)|FCS(4bytes)
> + * ---------------------------------------------------------------------------
> + * tag0 : zero-based value represents port
> + *	  (eg, 0x00=port1, 0x02=port3, 0x06=port7)
> + */
> +
> +static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	struct sk_buff *nskb;
> +	int padlen;
> +	u8 *tag;
> +
> +	padlen = 0;
> +	if (skb->len < 60)
> +		padlen = 60 - skb->len;

Can you use ETH_ZLEN instead of 60 such that it is clear this is padding
to a minimum packet size (minus FCS)?

> +
> +	nskb = alloc_skb(NET_IP_ALIGN + skb->len + padlen + 2, GFP_ATOMIC);

Can you also define the "2" at the beginning of the file as being e.g:
TAG_KSZ_LEN?

> +	if (!nskb) {
> +		kfree_skb(skb);
> +		return NULL;
> +	}
> +	skb_reserve(nskb, NET_IP_ALIGN);
> +
> +	skb_reset_mac_header(nskb);
> +	skb_set_network_header(nskb, skb_network_header(skb) - skb->head);
> +	skb_set_transport_header(nskb, skb_transport_header(skb) - skb->head);
> +	skb_copy_and_csum_dev(skb, skb_put(nskb, skb->len));
> +	kfree_skb(skb);
> +
> +	if (padlen) {
> +		u8 *pad = skb_put(nskb, padlen);
> +
> +		memset(pad, 0, padlen);
> +	}
> +
> +	tag = skb_put(nskb, 2);
> +	tag[0] = 0;
> +	tag[1] = 1 << p->dp->index; /* destnation port */
> +
> +	return nskb;
> +}
> +
> +struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
> +			struct packet_type *pt, struct net_device *orig_dev)
> +{
> +	struct dsa_switch_tree *dst = dev->dsa_ptr;
> +	struct dsa_switch *ds;
> +	u8 *tag;
> +	int source_port;
> +
> +	ds = dst->cpu_switch;
> +
> +	if (skb_linearize(skb))
> +		return NULL;

Is that really necessary?

> +
> +	tag = skb_tail_pointer(skb) - 1;
> +
> +	source_port = tag[0] & 7;
> +	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
> +		return NULL;
> +
> +	pskb_trim_rcsum(skb, skb->len - 1);

Humm, so we are still keeping tag[1] at the end of the frame?

> +
> +	skb->dev = ds->ports[source_port].netdev;
> +
> +	return skb;
> +}
> +
> +const struct dsa_device_ops ksz_netdev_ops = {
> +	.xmit	= ksz_xmit,
> +	.rcv	= ksz_rcv,
> +};
> 


-- 
Florian
