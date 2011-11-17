From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] Don't allow sharing of tx skbs on xen-netfront
Date: Thu, 17 Nov 2011 15:20:38 +0000
Message-ID: <1321543238.3664.278.camel@zakaz.uk.xensource.com>
References: <1321298544-16434-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	"Jeremy Fitzhardinge" <jeremy.fitzhardinge@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	<xen-devel@lists.xensource.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:39528 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757004Ab1KQPVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 10:21:07 -0500
In-Reply-To: <1321298544-16434-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-14 at 14:22 -0500, Neil Horman wrote:
> It was pointed out to me recently that the xen-netfront driver can't safely
> support shared skbs on transmit, since, while it doesn't maintain skb state
> directly, it does pass a pointer to the skb to the hypervisor via a list, and
> the hypervisor may expect the contents of the skb to remain stable.  Clearing
> the IFF_TX_SKB_SHARING flag after the call to alloc_etherdev to make it safe.

What are the actual constraints here? The skb is used as a handle to the
skb->data and shinfo (frags) and to complete at the end. It's actually
those which are passed to the hypervisor (effectively the same as
passing those addresses to the h/w for DMA).

Which parts of the skb are expected/allowed to not remain stable?

(Appologies if the above seems naive, I seem to have missed the
introduction of shared tx skbs and IFF_TX_SKB_SHARING)

Ian.

> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
> CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> CC: xen-devel@lists.xensource.com
> ---
>  drivers/net/xen-netfront.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 226faab..fb1077b 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1252,6 +1252,12 @@ static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev
>  		return ERR_PTR(-ENOMEM);
>  	}
>  
> +	/*
> +	 * Since frames remain on a queue after a return from xennet_start_xmit,
> +	 * we can't support tx shared skbs
> +	 */
> +	netdev->priv_flags &= ~IFF_TX_SKB_SHARING;
> +
>  	np                   = netdev_priv(netdev);
>  	np->xbdev            = dev;
>  
