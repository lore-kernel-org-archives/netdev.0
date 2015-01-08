From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 1/2] gen_stats.c: Duplicate xstats buffer for later
 use
Date: Thu, 8 Jan 2015 11:05:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC353D@AcuExch.aculab.com>
References: <20150108103518.GA7214@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: 'Ignacy Gawedzki' <ignacy.gawedzki@green-communications.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.184]:52089 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754256AbbAHLGc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 06:06:32 -0500
In-Reply-To: <20150108103518.GA7214@zenon.in.qult.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ignacy Gawedzki
> The gnet_stats_copy_app() function gets called, more often than not, with its
> second argument a pointer to an automatic variable in the caller's stack.
> Therefore, to avoid copying garbage afterwards when calling
> gnet_stats_finish_copy(), this data is better copied to a dynamically allocated
> memory that gets freed after use.
> 
> Signed-off-by: Ignacy Gawedzki <ignacy.gawedzki@green-communications.fr>
> ---
>  net/core/gen_stats.c | 17 ++++++++++++++---
>  1 file changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
> index 0c08062..5770a0e 100644
> --- a/net/core/gen_stats.c
> +++ b/net/core/gen_stats.c
> @@ -305,7 +305,10 @@ int
>  gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
>  {
>  	if (d->compat_xstats) {
> -		d->xstats = st;
> +		d->xstats = kmalloc(len, GFP_KERNEL);
> +		if (!d->xstats)
> +			goto kmalloc_failure;
> +		memcpy(d->xstats, st, len);
>  		d->xstats_len = len;
>  	}
> 
> @@ -313,6 +316,9 @@ gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
>  		return gnet_stats_copy(d, TCA_STATS_APP, st, len);
> 
>  	return 0;
> +kmalloc_failure:
> +	spin_unlock_bh(d->lock);
> +	return -1;
>  }

This rather implies that you are calling kmalloc() with a spin lock help.
If this is valid at all then you should probably specify GPF_ATOMIC.
OTOH it is better to call kmalloc() before acquiring the lock.

The locking itself looks odd - since the corresponding spin_lock_bh()
isn't in the same function.

	David
