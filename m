From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [GIT/PATCH v3] xen network backend driver
Date: Mon, 28 Feb 2011 18:53:18 +0000
Message-ID: <1298919198.2569.14.camel@bwh-desktop>
References: <1298914061.5034.996.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:37146 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695Ab1B1SxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 13:53:23 -0500
In-Reply-To: <1298914061.5034.996.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-02-28 at 17:27 +0000, Ian Campbell wrote:
> The following patch is the third iteration of the Xen network backend
> driver for upstream Linux.
> 
> This driver ("netback") is the host side counterpart to the frontend
> driver in drivers/net/xen-netfront.c. The PV protocol is also
> implemented by frontend drivers in other OSes too, such as the BSDs and
> even Windows.
> 
> Since this is the third posting I think it is time I started posting
> actual pull requests. The complete patch is still appended for ease of
> review.
[...]
> --- /dev/null
> +++ b/drivers/net/xen-netback/common.h
[...]
> +	/* Statistics */
> +	int rx_gso_checksum_fixup;

This should be defined as unsigned long (ideally it would be u64, but
that can't be updated atomically on 32-bit systems).

[...]
> --- /dev/null
> +++ b/drivers/net/xen-netback/interface.c
[...]
> +void xenvif_receive_skb(struct xenvif *vif, struct sk_buff *skb)
> +{
> +	netif_rx_ni(skb);
> +	vif->dev->last_rx = jiffies;
> +}

Don't update last_rx; it's only needed on slave devices of a bond, and
the bonding driver takes care of it now.

[...]
> +static int xenvif_change_mtu(struct net_device *dev, int mtu)
> +{
> +	struct xenvif *vif = netdev_priv(dev);
> +	int max = vif->can_sg ? 65535 - ETH_HLEN : ETH_DATA_LEN;
> +	if (mtu > max)
> +		return -EINVAL;
> +	dev->mtu = mtu;
> +	return 0;
> +}
[...]

Since any VLAN tag must be inserted inline, shouldn't the MTU limit be
65535 - VLAN_ETH_HLEN?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

