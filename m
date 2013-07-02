From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] net: fec: Add VLAN receive HW support.
Date: Mon, 01 Jul 2013 17:09:29 -0700 (PDT)
Message-ID: <20130701.170929.2145379004044730481.davem@davemloft.net>
References: <Jim_Baxter_<jim_baxter@mentor.com>
	<1372428503-13744-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, B38611@freescale.com,
	fabio.estevam@freescale.com, l.stach@pengutronix.de,
	shawn.guo@linaro.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: jim_baxter@mentor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45633 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755656Ab3GBAJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 20:09:34 -0400
In-Reply-To: <1372428503-13744-1-git-send-email-jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Baxter <jim_baxter@mentor.com>
Date: Fri, 28 Jun 2013 15:08:23 +0100

> @@ -803,6 +807,9 @@ fec_enet_rx(struct net_device *ndev, int budget)
>  	ushort	pkt_len;
>  	__u8 *data;
>  	int	pkt_received = 0;
> +	struct	bufdesc_ex *ebdp = NULL;
> +	bool	vlan_packet_rcvd = false;
> +	u16	vlan_tag;
>  
>  #ifdef CONFIG_M532x
>  	flush_cache_all();
> @@ -866,6 +873,24 @@ fec_enet_rx(struct net_device *ndev, int budget)
>  		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
>  			swap_buffer(data, pkt_len);
>  
> +		/* Extract the enhanced buffer descriptor */
> +		ebdp = NULL;
> +		if (fep->bufdesc_ex)
> +			ebdp = (struct bufdesc_ex *)bdp;

I would use a union here, so you'd have something like:

	union {
		struct bufdesc		*bdp;
		struct bufdesc_ex	*bdp_ex;
	} *p;

Alternatively, you can always use "struct bufdesc_ex *p", along with
the boolean saying if the extended descriptors are in use.

> +		if ((ndev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
> +				ebdp && (ebdp->cbd_esc & BD_ENET_RX_VLAN)) {

This is not indented properly.   The "ebp" on that second line must line
up exactly with the first column after the openning parenthesis on the
first line.

I see what you're trying to do, purely using TAB characters to indent
that second line.  But you must take the care and time to use the
appropriate number of TAB and space characters to place things at the
proper column.

> +			skb_copy_to_linear_data_offset(skb, (2 * ETH_ALEN),
> +					data + payload_offset,
> +					pkt_len - 4 - (2 * ETH_ALEN));

Again, line up the first non-space character on the second and third
lines of this function call so that they line up to the first column
after the openning parenthesis of the first line.

> +				__vlan_hwaccel_put_tag(skb,
> +						htons(ETH_P_8021Q), vlan_tag);

Likewise.
