From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH 6/6] xen-netback: don't disconnect
 frontend when seeing oversize frame
Date: Mon, 25 Mar 2013 12:53:57 +0000
Message-ID: <515056F502000078000C8184@nat28.tlf.novell.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
 <1364209702-12437-7-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xen.org>, <annie.li@oracle.com>,
	<konrad.wilk@oracle.com>, <netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:45252 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757114Ab3CYMxN convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Mon, 25 Mar 2013 08:53:13 -0400
In-Reply-To: <1364209702-12437-7-git-send-email-wei.liu2@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 25.03.13 at 12:08, Wei Liu <wei.liu2@citrix.com> wrote:
> @@ -947,10 +949,21 @@ static int netbk_count_requests(struct xenvif *vif,
>  
>  		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
>  		       sizeof(*txp));
> -		if (txp->size > first->size) {
> -			netdev_err(vif->dev, "Packet is bigger than frame.\n");
> -			netbk_fatal_tx_err(vif);
> -			return -EIO;
> +
> +		/* If the guest submitted a frame >= 64 KiB then
> +		 * first->size overflowed and following slots will
> +		 * appear to be larger than the frame.
> +		 *
> +		 * This cannot be fatal error as there are buggy
> +		 * frontends that do this.
> +		 *
> +		 * Consume all slots and drop the packet.
> +		 */
> +		if (!drop && txp->size > first->size) {
> +			if (net_ratelimit())
> +				netdev_dbg(vif->dev,
> +					   "Packet is bigger than frame.\n");
> +			drop = true;

So this deals with one half of the problem, but shouldn't we also
revert the disconnect when slots would exceed MAX_SKB_FRAGS
(or max_skb_slots after patch 5)? Afaict you could trivially extend
this patch to also cover that case...

Jan
