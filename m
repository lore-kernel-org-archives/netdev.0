From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [PATCH net] xen-netfront: reset skb network header before checksum
Date: Wed, 19 Feb 2014 20:25:51 +0100
Message-ID: <1533842338.20140219202551@eikelenboom.it>
References: <1392835714-26480-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Paul Durrant <paul.durrant@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:42147 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754542AbaBSTZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 14:25:55 -0500
In-Reply-To: <1392835714-26480-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Wednesday, February 19, 2014, 7:48:34 PM, you wrote:

> In ed1f50c3a ("net: add skb_checksum_setup") we introduced some checksum
> functions in core driver. Subsequent change b5cf66cd1 ("xen-netfront:
> use new skb_checksum_setup function") made use of those functions to
> replace its own implementation.

> However with that change netfront is broken. It sees a lot of checksum
> error. That's because its own implementation of checksum function was a
> bit hacky (dereferencing skb->data directly) while the new function was
> implemented using ip_hdr(). The network header is not reset before skb
> is passed to the new function. When the new function tries to do its
> job, it's confused and reports error.

> The fix is simple, we need to reset network header before passing skb to
> checksum function. Netback is not affected as it already does the right
> thing.

> Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Paul Durrant <paul.durrant@citrix.com>
> ---
>  drivers/net/xen-netfront.c |    1 +
>  1 file changed, 1 insertion(+)

> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index ff04d4f..95041b6 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -907,6 +907,7 @@ static int handle_incoming_queue(struct net_device *dev,
>  
>                 /* Ethernet work: Delayed to here as it peeks the header. */
>                 skb->protocol = eth_type_trans(skb, dev);
> +               skb_reset_network_header(skb);
>  
>                 if (checksum_setup(dev, skb)) {
>                         kfree_skb(skb);

Ah that also explains why ICMP was not affected :-)
Just tested and this patch indeed fixes my problem, so:

Tested-By: Sander Eikelenboom <linux@eikelenboom.it>

Thanks Wei !

--
Sander
