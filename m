From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Fix Rx stall during network stress and
 OOM
Date: Thu, 12 Jan 2017 15:17:06 -0500 (EST)
Message-ID: <20170112.151706.1389870722624942785.davem@davemloft.net>
References: <1484176637-2869-1-git-send-email-vineethp@amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: boris.ostrovsky@oracle.com, jgross@suse.com,
        xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kamatam@amazon.com,
        aliguori@amazon.com
To: vineethp@amazon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56470 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750746AbdALURI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:17:08 -0500
In-Reply-To: <1484176637-2869-1-git-send-email-vineethp@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vineeth Remanan Pillai <vineethp@amazon.com>
Date: Wed, 11 Jan 2017 23:17:17 +0000

> @@ -1054,7 +1059,11 @@ static int xennet_poll(struct napi_struct *napi, int budget)
>  		napi_complete(napi);
>  
>  		RING_FINAL_CHECK_FOR_RESPONSES(&queue->rx, more_to_do);
> -		if (more_to_do)
> +
> +		/* If there is more work to do or could not allocate
> +		 * rx buffers, re-enable polling.
> +		 */
> +		if (more_to_do || err != 0)
>  			napi_schedule(napi);

Just polling endlessly in a loop retrying the SKB allocation over and over
again until it succeeds is not very nice behavior.

You already have that refill timer, so please use that to retry instead
of wasting cpu cycles looping in NAPI poll.

Thanks.
