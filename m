From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 1/2] net: dsa: introduce STPID switch tagging handling code
Date: Wed, 21 Jul 2010 17:02:51 +0200
Message-ID: <20100721150251.GL21121@mail.wantstofly.org>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Karl Beldan <karl.beldan@gmail.com>,
	Graf Yang <graf.yang@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:52567 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab0GUPCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 11:02:53 -0400
Content-Disposition: inline
In-Reply-To: <1279719442-10174-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 21, 2010 at 09:37:21AM -0400, Mike Frysinger wrote:

> diff --git a/net/dsa/tag_stpid.c b/net/dsa/tag_stpid.c
> new file mode 100644
> index 0000000..b5d9829
> --- /dev/null
> +++ b/net/dsa/tag_stpid.c
> @@ -0,0 +1,147 @@
> +/*
> + * net/dsa/tag_stpid.c - special tag identifier,
> + * 0x810 + 4 bit "port mask" + 3 bit 8021p + 1 bit CFI + 12 bit VLAN ID
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/etherdevice.h>
> +#include <linux/list.h>
> +#include <linux/netdevice.h>
> +#include "dsa_priv.h"
> +
> +#define ETH_P_8021QH      (ETH_P_8021Q >> 8)
> +#define ETH_P_8021QL      (ETH_P_8021Q & 0xFF)
> +#define STPID_HLEN        4
> +
> +#define ZERO_VID          0
> +#define RESERVED_VID      0xFFF
> +#define STPID_VID         ZERO_VID
> +
> +int stpid_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	u8 *dsa_header;
> +
> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes += skb->len;

Everything up to this point looks OK, but..


> +	/*
> +	 * For 802.1Q frames, convert to STPID tagged frames,
> +	 * do nothing for common frames.
> +	 */
> +	if (skb->protocol == htons(ETH_P_8021Q)) {
> +		if (skb_cow_head(skb, 0) < 0)
> +			goto out_free;
> +
> +		dsa_header = skb->data + 2 * ETH_ALEN;
> +		dsa_header[1] = p->port & 0x03;
> +	}

This is almost certainly wrong -- according to the KSZ8893ML datasheet,
this means that VLAN tagged frames will be switched explicitly (by
sending them to p->port), but non-VLAN tagged frames will be switched
according to the switch's MAC address database.  You want explicit (i.e.
host kernel-side MAC address database lookup) switching in both cases.


> +{
> +	struct dsa_switch_tree *dst = dev->dsa_ptr;
> +	struct dsa_switch *ds = dst->ds[0];
> +	u8 *dsa_header;
> +	int source_port;
> +	int vid;
> +
> +	if (unlikely(ds == NULL))
> +		goto out_drop;
> +
> +	skb = skb_unshare(skb, GFP_ATOMIC);
> +	if (skb == NULL)
> +		goto out;
> +
> +	/* The ether_head has been pulled by master driver */
> +	dsa_header = skb->data - 2;
> +
> +	vid = ((dsa_header[2] & 0x0f)<<8 | dsa_header[3]);

Coding style (need spaces around '<<').


> +
> +	source_port = dsa_header[1] & 0x03;
> +	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
> +		goto out_drop;
> +
> +	if (((dsa_header[0] & ETH_P_8021QH) == ETH_P_8021QH) &&

This is bogus -- what it does is:

	if ((dsa_header[0] & 0x81) == 0x81)

It doesn't look like you need to mask here at all.
