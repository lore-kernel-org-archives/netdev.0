From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH 6/7] xen-netback: coalesce slots and
 fix regressions
Date: Tue, 09 Apr 2013 13:13:39 +0100
Message-ID: <5164221302000078000CBBF2@nat28.tlf.novell.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
 <1365505655-8021-7-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <ian.campbell@citrix.com>,
	<wdauchy@gmail.com>, <xen-devel@lists.xen.org>,
	<annie.li@oracle.com>, <konrad.wilk@oracle.com>,
	<netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:36889 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759009Ab3DIMNn convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Tue, 9 Apr 2013 08:13:43 -0400
In-Reply-To: <1365505655-8021-7-git-send-email-wei.liu2@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 09.04.13 at 13:07, Wei Liu <wei.liu2@citrix.com> wrote:
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -47,11 +47,47 @@
>  #include <asm/xen/hypercall.h>
>  #include <asm/xen/page.h>
>  
> +/*
> + * This is the maximum slots a skb can have. If a guest sends a skb
> + * which exceeds this limit it is considered malicious.
> + */
> +#define MAX_SKB_SLOTS_DEFAULT 20
> +static unsigned int max_skb_slots = MAX_SKB_SLOTS_DEFAULT;
> +
> +static int max_skb_slots_set(const char *val, const struct kernel_param *kp)
> +{
> +	int ret;
> +	unsigned long param = 0;
> +
> +	ret = kstrtoul(val, 10, &param);
> +
> +	if (ret < 0 || param < XEN_NETIF_NR_SLOTS_MIN)
> +		return -EINVAL;
> +
> +	max_skb_slots = param;
> +
> +	return 0;
> +}
> +
> +static struct kernel_param_ops max_skb_slots_param_ops = {

__moduleparam_const

> +	.set = max_skb_slots_set,
> +	.get = param_get_ulong,

param_get_uint

> @@ -251,7 +291,7 @@ static int max_required_rx_slots(struct xenvif *vif)
>  	int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
>  
>  	if (vif->can_sg || vif->gso || vif->gso_prefix)
> -		max += MAX_SKB_FRAGS + 1; /* extra_info + frags */
> +		max += XEN_NETIF_NR_SLOTS_MIN + 1; /* extra_info + frags */
>  
>  	return max;
>  }
> @@ -657,7 +697,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
>  		__skb_queue_tail(&rxq, skb);
>  
>  		/* Filled the batch queue? */
> -		if (count + MAX_SKB_FRAGS >= XEN_NETIF_RX_RING_SIZE)
> +		if (count + XEN_NETIF_NR_SLOTS_MIN >= XEN_NETIF_RX_RING_SIZE)
>  			break;
>  	}
>  

Are the two changes above really correct? You're having an skb as
input here, and hence you want to use all the frags, and nothing
beyond. Another question is whether the frontend can handle
those, but that aspect isn't affected by the code being modified
here.

> @@ -904,38 +944,56 @@ static void netbk_fatal_tx_err(struct xenvif *vif)
>  
>  static int netbk_count_requests(struct xenvif *vif,
>  				struct xen_netif_tx_request *first,
> +				RING_IDX first_idx,
>  				struct xen_netif_tx_request *txp,
>  				int work_to_do)
>  {
>  	RING_IDX cons = vif->tx.req_cons;
> -	int frags = 0;
> +	int slots = 0;
> +	int drop_err = 0;
>  
>  	if (!(first->flags & XEN_NETTXF_more_data))
>  		return 0;
>  
>  	do {
> -		if (frags >= work_to_do) {
> -			netdev_err(vif->dev, "Need more frags\n");
> +		if (slots >= work_to_do) {
> +			netdev_err(vif->dev, "Need more slots\n");
>  			netbk_fatal_tx_err(vif);
>  			return -ENODATA;
>  		}
>  
> -		if (unlikely(frags >= MAX_SKB_FRAGS)) {
> -			netdev_err(vif->dev, "Too many frags\n");
> +		/* Xen network protocol had implicit dependency on
> +		 * MAX_SKB_FRAGS. XEN_NETIF_NR_SLOTS_MIN is set to the
> +		 * historical MAX_SKB_FRAGS value 18 to honor the same
> +		 * behavior as before. Any packet using more than 18
> +		 * slots but less than max_skb_slots slots is dropped
> +		 */
> +		if (!drop_err && slots >= XEN_NETIF_NR_SLOTS_MIN) {
> +			if (net_ratelimit())
> +				netdev_dbg(vif->dev, "Too many slots\n");
> +			drop_err = -E2BIG;
> +		}
> +
> +		/* This guest is really using too many slots and
> +		 * considered malicious.
> +		 */
> +		if (unlikely(slots >= max_skb_slots)) {
> +			netdev_err(vif->dev,
> +				   "Malicious frontend using too many slots\n");

Wouldn't you better swap this and the previous if?

>  			netbk_fatal_tx_err(vif);
>  			return -E2BIG;
>  		}
>  
> -		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
> +		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
>  		       sizeof(*txp));
>  		if (txp->size > first->size) {
> -			netdev_err(vif->dev, "Frag is bigger than frame.\n");
> +			netdev_err(vif->dev, "Packet is bigger than frame.\n");

I don't think "packet" is the right term here.

Jan
