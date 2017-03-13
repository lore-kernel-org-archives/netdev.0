From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 2/4] net-next: dsa: add Mediatek tag RX/TX handler
Date: Mon, 13 Mar 2017 09:35:31 -0700
Message-ID: <fd097ac1-e9bf-c278-9f76-8a38331b7174@gmail.com>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com>
 <1489421488-300-3-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
 vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org, matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1489421488-300-3-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 09:11 AM, sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org wrote:
> From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> 
> Add the support for the 4-bytes tag for DSA port distinguishing inserted
> allowing receiving and transmitting the packet via the particular port.
> The tag is being added after the source MAC address in the ethernet
> header.
> 
> Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Landen Chao <Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> ---
>  include/net/dsa.h  |   1 +
>  net/dsa/Kconfig    |   2 +
>  net/dsa/Makefile   |   1 +
>  net/dsa/dsa.c      |   3 ++
>  net/dsa/dsa_priv.h |   3 ++
>  net/dsa/tag_mtk.c  | 121 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 131 insertions(+)
>  create mode 100644 net/dsa/tag_mtk.c
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index b122196..954cff2 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -27,6 +27,7 @@ enum dsa_tag_protocol {
>  	DSA_TAG_PROTO_EDSA,
>  	DSA_TAG_PROTO_BRCM,
>  	DSA_TAG_PROTO_QCA,
> +	DSA_TAG_PROTO_MTK,
>  	DSA_TAG_LAST,		/* MUST BE LAST */
>  };
>  
> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
> index 96e47c5..43b67e8 100644
> --- a/net/dsa/Kconfig
> +++ b/net/dsa/Kconfig
> @@ -41,4 +41,6 @@ config NET_DSA_TAG_TRAILER
>  config NET_DSA_TAG_QCA
>  	bool
>  
> +config NET_DSA_TAG_MTK
> +	bool
>  endif
> diff --git a/net/dsa/Makefile b/net/dsa/Makefile
> index a3380ed..97c9891 100644
> --- a/net/dsa/Makefile
> +++ b/net/dsa/Makefile
> @@ -8,3 +8,4 @@ dsa_core-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
>  dsa_core-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
>  dsa_core-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
>  dsa_core-$(CONFIG_NET_DSA_TAG_QCA) += tag_qca.o
> +dsa_core-$(CONFIG_NET_DSA_TAG_MTK) += tag_mtk.o
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 7899919..3586b1e 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -57,6 +57,9 @@ static struct sk_buff *dsa_slave_notag_xmit(struct sk_buff *skb,
>  #ifdef CONFIG_NET_DSA_TAG_QCA
>  	[DSA_TAG_PROTO_QCA] = &qca_netdev_ops,
>  #endif
> +#ifdef CONFIG_NET_DSA_TAG_MTK
> +	[DSA_TAG_PROTO_MTK] = &mtk_dsa_netdev_ops,
> +#endif
>  	[DSA_TAG_PROTO_NONE] = &none_ops,
>  };
>  
> diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
> index 6cfd738..de61e8f 100644
> --- a/net/dsa/dsa_priv.h
> +++ b/net/dsa/dsa_priv.h
> @@ -84,4 +84,7 @@ int dsa_slave_netdevice_event(struct notifier_block *unused,
>  /* tag_qca.c */
>  extern const struct dsa_device_ops qca_netdev_ops;
>  
> +/* tag_mtk.c */
> +extern const struct dsa_device_ops mtk_dsa_netdev_ops;
> +
>  #endif
> diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
> new file mode 100644
> index 0000000..a2dc014
> --- /dev/null
> +++ b/net/dsa/tag_mtk.c
> @@ -0,0 +1,121 @@
> +/*
> + * Mediatek DSA Tag support
> + * Copyright (C) 2017 Landen Chao <landen.chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> + *		      Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/etherdevice.h>
> +#include "dsa_priv.h"
> +
> +#define MTK_HDR_LEN		4
> +#define MTK_HDR_RECV_SOURCE_PORT_MASK	GENMASK(2, 0)
> +#define MTK_HDR_XMIT_DP_BIT_MASK	GENMASK(5, 0)
> +
> +static struct sk_buff *mtk_tag_xmit(struct sk_buff *skb,
> +				    struct net_device *dev)
> +{
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	u8 *mtk_tag;
> +
> +	if (skb_cow_head(skb, MTK_HDR_LEN) < 0)
> +		goto out_free;
> +
> +	skb_push(skb, MTK_HDR_LEN);
> +
> +	memmove(skb->data, skb->data + MTK_HDR_LEN, 2 * ETH_ALEN);
> +
> +	/* Build the tag after the MAC Source Address */
> +	mtk_tag = skb->data + 2 * ETH_ALEN;
> +
> +	/* Set the ingress opcode, traffic class, tag enforcment is
> +	 * deprecated
> +	 */

Sounds like this comment came from tag_brcm.c does it really apply here
as well?

Other than that:

Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
-- 
Florian
