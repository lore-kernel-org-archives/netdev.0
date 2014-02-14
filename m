From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V2 net-next 4/5] xen-netfront: Add support for multiple
 queues
Date: Fri, 14 Feb 2014 14:13:32 +0000
Message-ID: <20140214141332.GC18398@zion.uk.xensource.com>
References: <1392378624-6123-1-git-send-email-andrew.bennieston@citrix.com>
 <1392378624-6123-5-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:9987 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752637AbaBNONe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 09:13:34 -0500
Content-Disposition: inline
In-Reply-To: <1392378624-6123-5-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 11:50:23AM +0000, Andrew J. Bennieston wrote:
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> Build on the refactoring of the previous patch to implement multiple
> queues between xen-netfront and xen-netback.
> 
> Check XenStore for multi-queue support, and set up the rings and event
> channels accordingly.
> 
> Write ring references and event channels to XenStore in a queue
> hierarchy if appropriate, or flat when using only one queue.
> 
> Update the xennet_select_queue() function to choose the queue on which
> to transmit a packet based on the skb hash result.
> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> ---
>  drivers/net/xen-netfront.c |  176 ++++++++++++++++++++++++++++++++++----------
>  1 file changed, 138 insertions(+), 38 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index d4239b9..d584fa4 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -57,6 +57,10 @@
>  #include <xen/interface/memory.h>
>  #include <xen/interface/grant_table.h>
>  
> +/* Module parameters */
> +unsigned int xennet_max_queues;
> +module_param(xennet_max_queues, uint, 0644);
> +
>  static const struct ethtool_ops xennet_ethtool_ops;
>  
>  struct netfront_cb {
> @@ -565,10 +569,22 @@ static int xennet_count_skb_frag_slots(struct sk_buff *skb)
>  	return pages;
>  }
>  
> -static u16 xennet_select_queue(struct net_device *dev, struct sk_buff *skb)
> +static u16 xennet_select_queue(struct net_device *dev, struct sk_buff *skb,
> +							   void *accel_priv)

Indentation.

>  {
> -	/* Stub for later implementation of queue selection */
> -	return 0;
> +	struct netfront_info *info = netdev_priv(dev);
> +	u32 hash;
> +	u16 queue_idx;
> +
> +	/* First, check if there is only one queue */
> +	if (info->num_queues == 1)
> +		queue_idx = 0;

Coding style. Need to put braces around this single statement.

Wei.
