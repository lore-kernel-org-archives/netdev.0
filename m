From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: fix skb traversing races during unlink
Date: Sat, 28 Apr 2012 22:18:32 -0400 (EDT)
Message-ID: <20120428.221832.360259077795872366.davem@davemloft.net>
References: <1335522095-9012-1-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, huajun.li.lee@gmail.com,
	oneukum@suse.de, stable@kernel.org
To: tom.leiming@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755222Ab2D2CSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 22:18:46 -0400
In-Reply-To: <1335522095-9012-1-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei <tom.leiming@gmail.com>
Date: Fri, 27 Apr 2012 18:21:35 +0800

> +/*The caller must hold list->lock*/

Please put spaces in your comments, like this:

/* The caller must hold list->lock */

> +
> +		/*speedup unlink by blocking resubmit*/

Same here.
>  
> -		entry = (struct skb_data *) skb->cb;
> +		skb_queue_walk(q, skb) {
> +			entry = (struct skb_data *) skb->cb;
> +			if (entry->state != unlink_start)
> +				break;
> +		}
> +		if (skb == (struct sk_buff *)q)
> +			break;

Please do not expose the internal details of SKB lists
with a test like this.  Eventually this will all be
converted to struct list_head and this kind of test
will cause unnecessary pain for such a conversion.

Instead, code it like this, as you would for a loop
using list_for_each*() or similar:

	skb_queue_walk(q, skb) {
		if (condition)
			goto found;
	}
	/* No matching entry. */
	break;
found:

Thanks.
