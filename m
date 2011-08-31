From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next-2.6] net: allow notifier subscribers to forbid
 device from closing
Date: Wed, 31 Aug 2011 16:25:51 +0100
Message-ID: <1314804352.2741.4.camel@bwh-desktop>
References: <1314803731-1222-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28008 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756642Ab1HaP0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 11:26:38 -0400
In-Reply-To: <1314803731-1222-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-08-31 at 17:15 +0200, Jiri Pirko wrote:
> In some situations, like when the device is used as slave device in
> bond/br/etc it is not nice if someone closes the device. This allows
> it's masters to forbid this closure.

No it doesn't.

[...]
> @@ -1269,9 +1282,12 @@ static int dev_close_many(struct list_head *head)
>  	struct net_device *dev, *tmp;
>  	LIST_HEAD(tmp_list);
>  
> -	list_for_each_entry_safe(dev, tmp, head, unreg_list)
> +	list_for_each_entry_safe(dev, tmp, head, unreg_list) {
>  		if (!(dev->flags & IFF_UP))
>  			list_move(&dev->unreg_list, &tmp_list);
> +		else
> +			__dev_pre_close(dev);
> +	}
>  
>  	__dev_close_many(head);

The return value is ignored here.

And this is called from dev_close(), where you are adding the
notification as well.  So the notifier will usually be called twice.

[...]
> @@ -1397,6 +1418,7 @@ rollback:
>  				break;
>  
>  			if (dev->flags & IFF_UP) {
> +				nb->notifier_call(nb, NETDEV_PRE_DOWN, dev);
>  				nb->notifier_call(nb, NETDEV_GOING_DOWN, dev);
>  				nb->notifier_call(nb, NETDEV_DOWN, dev);
>  			}
[...]

The return value has to be ignored here.  Not sure it makes any sense to
call the notifier at all.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
