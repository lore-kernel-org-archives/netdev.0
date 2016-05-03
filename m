From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCHv2 bluetooth-next 01/10] 6lowpan: add private neighbour
 data
Date: Tue, 3 May 2016 20:16:32 +0200
Message-ID: <5728EB00.3030405@osg.samsung.com>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-2-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:57878 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932543AbcECSQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 14:16:37 -0400
In-Reply-To: <1461140382-4784-2-git-send-email-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 20/04/16 10:19, Alexander Aring wrote:
> This patch will introduce a 6lowpan neighbour private data. Like the
> interface private data we handle private data for generic 6lowpan and
> for link-layer specific 6lowpan.
>
> The current first use case if to save the short address for a 802.15.4
> 6lowpan neighbour.
>
> Cc: David S. Miller<davem@davemloft.net>
> Signed-off-by: Alexander Aring<aar@pengutronix.de>
> ---
>   include/linux/netdevice.h     |  3 +--
>   include/net/6lowpan.h         | 24 ++++++++++++++++++++++++
>   net/bluetooth/6lowpan.c       |  2 ++
>   net/ieee802154/6lowpan/core.c | 12 ++++++++++++
>   4 files changed, 39 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 166402a..0052c42 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1487,8 +1487,7 @@ enum netdev_priv_flags {
>    * 	@perm_addr:		Permanent hw address
>    * 	@addr_assign_type:	Hw address assignment type
>    * 	@addr_len:		Hardware address length
> - * 	@neigh_priv_len;	Used in neigh_alloc(),
> - * 				initialized only in atm/clip.c
> + *	@neigh_priv_len;	Used in neigh_alloc()
>    * 	@dev_id:		Used to differentiate devices that share
>    * 				the same link layer address
>    * 	@dev_port:		Used to differentiate devices that share
> diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
> index da84cf9..61c6517 100644
> --- a/include/net/6lowpan.h
> +++ b/include/net/6lowpan.h
> @@ -98,6 +98,9 @@ static inline bool lowpan_is_iphc(u8 dispatch)
>   #define LOWPAN_PRIV_SIZE(llpriv_size)	\
>   	(sizeof(struct lowpan_dev) + llpriv_size)
>   
> +#define LOWPAN_NEIGH_PRIV_SIZE(llneigh_priv_size)	\
> +	(sizeof(struct lowpan_neigh) + llneigh_priv_size)
> +
>   enum lowpan_lltypes {
>   	LOWPAN_LLTYPE_BTLE,
>   	LOWPAN_LLTYPE_IEEE802154,
> @@ -141,6 +144,27 @@ struct lowpan_dev {
>   	u8 priv[0] __aligned(sizeof(void *));
>   };
>   
> +struct lowpan_neigh {
> +	/* 6LoWPAN neigh private data */
> +	/* must be last */
> +	u8 priv[0] __aligned(sizeof(void *));
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
> +
>   static inline
>   struct lowpan_dev *lowpan_dev(const struct net_device *dev)
>   {
> diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
> index 38e82dd..b7c4efa 100644
> --- a/net/bluetooth/6lowpan.c
> +++ b/net/bluetooth/6lowpan.c
> @@ -833,6 +833,8 @@ static int setup_netdev(struct l2cap_chan *chan, struct lowpan_btle_dev **dev)
>   	list_add_rcu(&(*dev)->list, &bt_6lowpan_devices);
>   	spin_unlock(&devices_lock);
>   
> +	netdev->neigh_priv_len = LOWPAN_NEIGH_PRIV_SIZE(0);
> +
>   	err = lowpan_register_netdev(netdev, LOWPAN_LLTYPE_BTLE);
>   	if (err < 0) {
>   		BT_INFO("register_netdev failed %d", err);
> diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
> index dd085db..3162632 100644
> --- a/net/ieee802154/6lowpan/core.c
> +++ b/net/ieee802154/6lowpan/core.c
> @@ -92,11 +92,21 @@ static int lowpan_stop(struct net_device *dev)
>   	return 0;
>   }
>   
> +static int lowpan_neigh_construct(struct neighbour *n)
> +{
> +	struct lowpan_802154_neigh *neigh = lowpan_802154_neigh(neighbour_priv(n));
> +
> +	/* default no short_addr is available for a neighbour */
> +	neigh->short_addr = cpu_to_le16(IEEE802154_ADDR_SHORT_UNSPEC);
> +	return 0;
> +}
> +
>   static const struct net_device_ops lowpan_netdev_ops = {
>   	.ndo_init		= lowpan_dev_init,
>   	.ndo_start_xmit		= lowpan_xmit,
>   	.ndo_open		= lowpan_open,
>   	.ndo_stop		= lowpan_stop,
> +	.ndo_neigh_construct    = lowpan_neigh_construct,
>   };
>   
>   static void lowpan_setup(struct net_device *ldev)
> @@ -161,6 +171,8 @@ static int lowpan_newlink(struct net *src_net, struct net_device *ldev,
>   				wdev->needed_headroom;
>   	ldev->needed_tailroom = wdev->needed_tailroom;
>   
> +	ldev->neigh_priv_len = LOWPAN_NEIGH_PRIV_SIZE(sizeof(struct lowpan_802154_neigh));
> +
>   	ret = lowpan_register_netdevice(ldev, LOWPAN_LLTYPE_IEEE802154);
>   	if (ret < 0) {
>   		dev_put(wdev);

Reviewed-by: Stefan Schmidt<stefan@osg.samsung.com>

regards
Stefan Schmidt
