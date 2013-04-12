From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH V4 5/7] xen-netfront: reduce gso_max_size to account for
 max TCP header
Date: Fri, 12 Apr 2013 15:44:59 +0100
Message-ID: <1365777899.15783.77.camel@zakaz.uk.xensource.com>
References: <1365776646-10796-1-git-send-email-wei.liu2@citrix.com>
	 <1365776646-10796-6-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:11298 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180Ab3DLOpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 10:45:02 -0400
In-Reply-To: <1365776646-10796-6-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 15:24 +0100, Wei Liu wrote:
> The maximum packet including header that can be handled by netfront / netback
> wire format is 65535. Reduce gso_max_size accordingly.
> 
> Drop skb and print warning when skb->len > 65535. This can 1) save the effort
> to send malformed packet to netback, 2) help spotting misconfiguration of
> netfront in the future.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netfront.c |   14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 1bb2e20..9c2eca1 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -547,6 +547,16 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	unsigned int len = skb_headlen(skb);
>  	unsigned long flags;
>  
> +	/* If skb->len is too big for wire format, drop skb and alert
> +	 * user about misconfiguration.
> +	 */
> +	if (unlikely(skb->len > (typeof(tx->size))(~0))) {

This seems rather a complicated way of saying... er, something!

Perhaps we could have a #define in netif.h to compare against?

I'm not 100% convinced that the case and the ~ are in the right order to
have the behaviour you want unless perhaps sizeof(tx->size) <
sizeof(int). In any case it's too obfuscated for me ;-)

> +		net_alert_ratelimited(
> +			"xennet: skb->len = %u, too big for wire format\n",
> +			skb->len);
> +		goto drop;
> +	}
> +
>  	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>  		xennet_count_skb_frag_slots(skb);
>  	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> @@ -1058,7 +1068,7 @@ err:
>  
>  static int xennet_change_mtu(struct net_device *dev, int mtu)
>  {
> -	int max = xennet_can_sg(dev) ? 65535 - ETH_HLEN : ETH_DATA_LEN;
> +	int max = xennet_can_sg(dev) ? 65535 - MAX_TCP_HEADER : ETH_DATA_LEN;
>  
>  	if (mtu > max)
>  		return -EINVAL;
> @@ -1362,6 +1372,8 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
>  	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
>  	SET_NETDEV_DEV(netdev, &dev->dev);
>  
> +	netif_set_gso_max_size(netdev, 65535 - MAX_TCP_HEADER);
> +
>  	np->netdev = netdev;
>  
>  	netif_carrier_off(netdev);
