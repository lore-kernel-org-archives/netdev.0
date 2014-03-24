From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: disable rogue vif in kthread context
Date: Mon, 24 Mar 2014 15:29:45 -0400 (EDT)
Message-ID: <20140324.152945.1082990562317636743.davem@davemloft.net>
References: <1395663214-14133-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	paul.durrant@citrix.com, zoltan.kiss@citrix.com, edwin@etorok.net,
	ian.campbell@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747AbaCXT3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 15:29:48 -0400
In-Reply-To: <1395663214-14133-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 24 Mar 2014 12:13:34 +0000

> @@ -62,6 +62,13 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
>  	struct xenvif *vif = container_of(napi, struct xenvif, napi);
>  	int work_done;
>  
> +	/* This vif is rogue, we pretend we've used up all budget to
> +	 * deschedule it from NAPI. But this interface will be turned
> +	 * off in thread context later.
> +	 */
> +	if (unlikely(vif->disabled))
> +		return budget;
> +

As mentioned by others, this makes NAPI poll forever.

The following comment was referenced:

		/* Drivers must not modify the NAPI state if they
		 * consume the entire weight.  In such cases this code
		 * still "owns" the NAPI instance and therefore can
		 * move the instance around on the list at-will.
		 */
		if (unlikely(work == weight)) {

WHICH MEANS, if you return that you used the full budget, the NAPI instance
is still owned by the core.

Why?  Becuase if you used the entire budget, it's going to put you back onto
the polling list and invoke you again some time soon.

If the interface is disabled, you should return zero from the poll and do a
NAPI completion.
