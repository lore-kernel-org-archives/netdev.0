From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Thu, 26 Feb 2009 11:01:41 -0800
Message-ID: <m1ab89m38q.fsf@fess.ebiederm.org>
References: <49A4D5D5.5090602@trash.net>
	<20090225061902.GA32430@gondor.apana.org.au>
	<49A4E3F8.4050406@trash.net> <49A4F0D7.20304@trash.net>
	<20090225084321.GA1101@gondor.apana.org.au>
	<m163ixk9t2.fsf@fess.ebiederm.org>
	<20090226062257.GA11511@gondor.apana.org.au>
	<m14oyhis31.fsf@fess.ebiederm.org> <20090226084924.16cb3e08@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33575 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757372AbZBZTBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 14:01:12 -0500
In-Reply-To: <20090226084924.16cb3e08@nehalam> (Stephen Hemminger's message of "Thu\, 26 Feb 2009 08\:49\:24 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> What about something like this:
>
> Subject: [PATCH] Avoid race between network down and sysfs

As far as solutions go.  That looks like the easiest correct solution.
So.  
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>


Will -ERESTARTSYS trigger the in kernel restart logic in this case?

There are a lot more cases to cover, and I don't I like it long
term.  Spinning waiting for rtnl_lock feels wrong.  Plus it does
not help with discovering the problem in new sysfs, sysctl, or
proc files.

It has the major advantage that we can fix things now.

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> --- a/net/core/net-sysfs.c	2009-02-26 08:36:18.000000000 -0800
> +++ b/net/core/net-sysfs.c	2009-02-26 08:37:51.000000000 -0800
> @@ -77,7 +77,9 @@ static ssize_t netdev_store(struct devic
>  	if (endp == buf)
>  		goto err;
>  
> -	rtnl_lock();
> +	if (!rtnl_trylock())
> +		return -ERESTARTSYS;
> +
>  	if (dev_isalive(net)) {
>  		if ((ret = (*set)(net, new)) == 0)
>  			ret = len;
