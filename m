From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v1] ipvlan: Initial check-in of the IPVLAN
 driver.
Date: Thu, 13 Nov 2014 23:19:47 -0800
Message-ID: <1415949587.17262.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415946547-25811-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:40475 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754330AbaKNHTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 02:19:50 -0500
Received: by mail-ig0-f177.google.com with SMTP id hl2so1038602igb.10
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 23:19:49 -0800 (PST)
In-Reply-To: <1415946547-25811-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-13 at 22:29 -0800, Mahesh Bandewar wrote:

> +static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
> +{
> +	const struct ipvl_dev *ipvlan = netdev_priv(dev);
> +	struct ethhdr *eth = eth_hdr(skb);
> +	struct ipvl_addr *addr = NULL;
> +	void *lyr3h = NULL;
> +	int addr_type;
> +
> +	ipvlan_dbg(4, "L2:Xmit on dev %s,PROT=%x\n", dev->name,
> +		   ntohs(skb->protocol));
> +	if (ether_addr_equal(eth->h_dest, eth->h_source)) {
> +		ipvlan_dbg(4, "Comm betn 2 virt devs PROT=%x\n",
> +			   ntohs(skb->protocol));
> +		if ((lyr3h = ipvlan_get_L3_hdr(skb, &addr_type)) == NULL)
> +			goto to_default;
> +
> +		addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
> +		if (addr)
> +			return ipvlan_rcv_frame(addr, skb, true);
> +
> +		/* No matching ipvlan dev! Must be on the Physical device */
> +to_default:
> +		skb = skb_share_check(skb, GFP_ATOMIC);
> +		if (!skb)
> +			return RX_HANDLER_CONSUMED;

Same problem here. RX_HANDLER_CONSUMED makes no sense.

> +
> +		/* Packet definitely does not belong to any of the
> +		 * virtual devices, but the dest is local. So forward
> +		 * the skb for the main-dev. At the RX side we just return
> +		 * RX_PASS for it to be processed further on the stack.
> +		 */
> +		return dev_forward_skb(ipvlan->phy_dev, skb);
> +
> +	} else if (is_multicast_ether_addr(eth->h_dest)) {
> +		u8 ip_summed = skb->ip_summed;
> +		/* Packet needs to be multicast-ed. */
> +		skb->ip_summed = CHECKSUM_UNNECESSARY;
> +		ipvlan_dbg(4, "%s[%d] Mcast Xmit on [%s], PROT=[%x]\n",
> +			   __func__, __LINE__, dev->name,
> +			   ntohs(skb->protocol));
> +		ipvlan_multicast_frame(ipvlan->port, skb, ipvlan, true);
> +		skb->ip_summed = ip_summed;
> +	}
> +
> +	/* Send it out */
> +	skb->dev = ipvlan->phy_dev;
> +	return dev_queue_xmit(skb);
> +}
> +
