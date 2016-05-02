From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCHv2 bluetooth-next 01/10] 6lowpan: add private neighbour
 data
Date: Mon, 2 May 2016 20:59:13 +0200
Message-ID: <c7717a50-7818-f409-1fb4-35e1ec5ebde0@stressinduktion.org>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-2-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, stefan@osg.samsung.com,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:51283 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932113AbcEBS7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 14:59:18 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id C188920C62
	for <netdev@vger.kernel.org>; Mon,  2 May 2016 14:59:17 -0400 (EDT)
In-Reply-To: <1461140382-4784-2-git-send-email-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 20.04.2016 10:19, Alexander Aring wrote:
> This patch will introduce a 6lowpan neighbour private data. Like the
> interface private data we handle private data for generic 6lowpan and
> for link-layer specific 6lowpan.
> 
> The current first use case if to save the short address for a 802.15.4
> 6lowpan neighbour.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Alexander Aring <aar@pengutronix.de>
> ---
>  include/linux/netdevice.h     |  3 +--
>  include/net/6lowpan.h         | 24 ++++++++++++++++++++++++
>  net/bluetooth/6lowpan.c       |  2 ++
>  net/ieee802154/6lowpan/core.c | 12 ++++++++++++
>  4 files changed, 39 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 166402a..0052c42 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1487,8 +1487,7 @@ enum netdev_priv_flags {
>   * 	@perm_addr:		Permanent hw address
>   * 	@addr_assign_type:	Hw address assignment type
>   * 	@addr_len:		Hardware address length
> - * 	@neigh_priv_len;	Used in neigh_alloc(),
> - * 				initialized only in atm/clip.c
> + *	@neigh_priv_len;	Used in neigh_alloc()
>   * 	@dev_id:		Used to differentiate devices that share
>   * 				the same link layer address
>   * 	@dev_port:		Used to differentiate devices that share
> diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
> index da84cf9..61c6517 100644
> --- a/include/net/6lowpan.h
> +++ b/include/net/6lowpan.h
> @@ -98,6 +98,9 @@ static inline bool lowpan_is_iphc(u8 dispatch)
>  #define LOWPAN_PRIV_SIZE(llpriv_size)	\
>  	(sizeof(struct lowpan_dev) + llpriv_size)
>  
> +#define LOWPAN_NEIGH_PRIV_SIZE(llneigh_priv_size)	\
> +	(sizeof(struct lowpan_neigh) + llneigh_priv_size)
> +
>  enum lowpan_lltypes {
>  	LOWPAN_LLTYPE_BTLE,
>  	LOWPAN_LLTYPE_IEEE802154,
> @@ -141,6 +144,27 @@ struct lowpan_dev {
>  	u8 priv[0] __aligned(sizeof(void *));
>  };
>  
> +struct lowpan_neigh {
> +	/* 6LoWPAN neigh private data */
> +	/* must be last */
> +	u8 priv[0] __aligned(sizeof(void *));

Are you sure this declaration is correct? You take its size above, which
should result in zero. Looks a little bit strange. :)

> +};
> +
> +struct lowpan_802154_neigh {
> +	__le16 short_addr;
> +};
> +
> +static inline struct lowpan_neigh *lowpan_neigh(void *neigh_priv)
> +{
> +	return neigh_priv;
> +}
> +
> +static inline
> +struct lowpan_802154_neigh *lowpan_802154_neigh(void *neigh_priv)
> +{
> +	return (struct lowpan_802154_neigh *)lowpan_neigh(neigh_priv)->priv;
> +}

Can't you remove lowpan_neigh completely and just use 802154_neigh at
this point?

Bye,
Hannes
