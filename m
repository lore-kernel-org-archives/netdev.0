From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH V5 6/7] xen-netback: coalesce slots in TX path and fix
 regressions
Date: Sun, 21 Apr 2013 18:06:10 -0400
Message-ID: <517462D2.8040209@oracle.com>
References: <1366045581-31349-1-git-send-email-wei.liu2@citrix.com> <1366045581-31349-7-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	konrad.wilk@oracle.com, jbeulich@suse.com, ian.campbell@citrix.com,
	wdauchy@gmail.com, david.vrabel@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44160 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331Ab3DUWGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 18:06:31 -0400
In-Reply-To: <1366045581-31349-7-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-4-15 13:06, Wei Liu wrote:
>   
>   static int netbk_count_requests(struct xenvif *vif,
>   				struct xen_netif_tx_request *first,
> +				RING_IDX first_idx,
>   				struct xen_netif_tx_request *txp,
>   				int work_to_do)
>   {
>   	RING_IDX cons = vif->tx.req_cons;
> -	int frags = 0;
> +	int slots = 0;
> +	int drop_err = 0;
>   
>   	if (!(first->flags & XEN_NETTXF_more_data))
>   		return 0;
>   
>   	do {
> -		if (frags >= work_to_do) {
> -			netdev_err(vif->dev, "Need more frags\n");
> +		if (slots >= work_to_do) {
> +			netdev_err(vif->dev,
> +				   "Asked for %d slots but exceeds this limit\n",
> +				   work_to_do);
>   			netbk_fatal_tx_err(vif);
>   			return -ENODATA;
>   		}
>   
> -		if (unlikely(frags >= MAX_SKB_FRAGS)) {
> -			netdev_err(vif->dev, "Too many frags\n");
> +		/* This guest is really using too many slots and
> +		 * considered malicious.
> +		 */
> +		if (unlikely(slots >= max_skb_slots)) {
> +			netdev_err(vif->dev,
> +				   "Malicious frontend using %d slots, threshold %u\n",
> +				   slots, max_skb_slots);
>   			netbk_fatal_tx_err(vif);
>   			return -E2BIG;

It is possible that vif is freed when packet size is less than 64K here 
but slots required >= max_skb_slots. Alough max_skb_slots can be 
configured, this kind of packets would be dropped in following if 
(!drop_err && slots >= XEN_NETIF_NR_SLOTS_MIN).

>   		}
>   
> -		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
> +		/* Xen network protocol had implicit dependency on
> +		 * MAX_SKB_FRAGS. XEN_NETIF_NR_SLOTS_MIN is set to the
> +		 * historical MAX_SKB_FRAGS value 18 to honor the same
> +		 * behavior as before. Any packet using more than 18
> +		 * slots but less than max_skb_slots slots is dropped
> +		 */
> +		if (!drop_err && slots >= XEN_NETIF_NR_SLOTS_MIN) {
> +			if (net_ratelimit())
> +				netdev_dbg(vif->dev,
> +					   "Too many slots (%d) exceeding limit (%d), dropping packet\n",
> +					   slots, XEN_NETIF_NR_SLOTS_MIN);
> +			drop_err = -E2BIG;

It is possible to drop packets like above(size < 64K && slot >= 
XEN_NETIF_NR_SLOTS_MIN). I do not know how frequently this kind of 
packets appear, maybe some SKBs with compound page(size < 64K && slot >= 
XEN_NETIF_NR_SLOTS_MIN) are dropped here?


Thanks
Annie
