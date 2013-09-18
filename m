From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net] netpoll: fix NULL pointer dereference in
 netpoll_cleanup
Date: Wed, 18 Sep 2013 12:15:39 -0400 (EDT)
Message-ID: <20130918.121539.1213515779326200577.davem@davemloft.net>
References: <1379427155-8561-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635Ab3IRQPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 12:15:41 -0400
In-Reply-To: <1379427155-8561-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Tue, 17 Sep 2013 16:12:35 +0200

> @@ -1284,15 +1284,15 @@ EXPORT_SYMBOL_GPL(__netpoll_free_async);
>  
>  void netpoll_cleanup(struct netpoll *np)
>  {
> -	if (!np->dev)
> -		return;
> -
>  	rtnl_lock();
> +	if (!np->dev) {
> +		rtnl_unlock();
> +		return;
> +	}
>  	__netpoll_cleanup(np);
> -	rtnl_unlock();
> -
>  	dev_put(np->dev);
>  	np->dev = NULL;
> +	rtnl_unlock();
>  }
>  EXPORT_SYMBOL(netpoll_cleanup);

I know it seems arbitrary, but please do this like:

	lock();
	if (condition) {
		...
	}
	unlock();

rather than having multiple return/unlock code paths.

This style I am suggesting is easier to audit for locking problems.

Thanks.
