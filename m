From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/14] mac802154: monitor device support
Date: Mon, 19 Dec 2011 14:47:04 -0500 (EST)
Message-ID: <20111219.144704.1132849710000837906.davem@davemloft.net>
References: <20111219163117.GA13123@avtobot.cybertron>
	<1324312434-13151-12-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, alexander@Lenovo
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556Ab1LSTrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 14:47:18 -0500
In-Reply-To: <1324312434-13151-12-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Mon, 19 Dec 2011 19:33:52 +0300

> +	IEEE802154_DEV_MONITOR = 1, /* for compatibility with WireShark */

What's this "compatability" all about?  Explain it.

> +		dev = alloc_netdev(sizeof(struct mac802154_sub_if_data),
> +					name, mac802154_monitor_setup);

Line up the arguments properly.

> +		break;
>  	default:
>  		dev = NULL;
>  		err = -EINVAL;
> diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
> index f6f6f0a..2a301d0 100644
> --- a/net/mac802154/mac802154.h
> +++ b/net/mac802154/mac802154.h
> @@ -90,6 +90,9 @@ extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
>  int mac802154_slave_open(struct net_device *dev);
>  int mac802154_slave_close(struct net_device *dev);
>  
> +void mac802154_monitors_rx(struct mac802154_priv *priv, struct sk_buff *skb);
> +void mac802154_monitor_setup(struct net_device *dev);
> +
>  netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
>  							u8 page, u8 chan);
>  
> diff --git a/net/mac802154/monitor.c b/net/mac802154/monitor.c
> new file mode 100644
> index 0000000..ccc5e81
> --- /dev/null
> +++ b/net/mac802154/monitor.c
> @@ -0,0 +1,115 @@
> +/*
> + * Copyright 2007, 2008, 2009 Siemens AG
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program; if not, write to the Free Software Foundation, Inc.,
> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + * Written by:
> + * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
> + * Sergey Lapin <slapin@ossfans.org>
> + * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
> + */
> +
> +#include <linux/netdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/if_arp.h>
> +#include <linux/crc-ccitt.h>
> +#include <linux/nl802154.h>
> +#include <net/ieee802154.h>
> +#include <net/mac802154.h>
> +#include <net/wpan-phy.h>
> +
> +#include "mac802154.h"
> +
> +static netdev_tx_t mac802154_monitor_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct mac802154_sub_if_data *priv;
> +	u8 chan, page;
> +
> +	priv = netdev_priv(dev);
> +
> +	/* FIXME: locking */
> +	chan = priv->hw->phy->current_channel;
> +	page = priv->hw->phy->current_page;
> +
> +	if (chan == (u8)-1) /* not init */
 ...
> +	priv->chan = -1; /* not initialized */

This mixing of the integer "-1" value with a "u8" type is asking for trouble.
Define something like:

#define MAC802154_CHAN_NONE 0xff

or

#define MAC802154_CHAN_NONE (~(u8)0)

and use it consistently.
