From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: tun netns BUG()
Date: Fri, 03 Jul 2009 07:52:30 -0700
Message-ID: <m163e9hl8x.fsf@fess.ebiederm.org>
References: <m1ljo61cya.fsf@fess.ebiederm.org>
	<20090703083501.GA25536@gondor.apana.org.au>
	<20090703090355.GA25768@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, dwmw2@infradead.org,
	netdev@vger.kernel.org, johannes@sipsolutions.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49829 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbZGCOwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 10:52:34 -0400
In-Reply-To: <20090703090355.GA25768@gondor.apana.org.au> (Herbert Xu's message of "Fri\, 3 Jul 2009 17\:03\:55 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Fri, Jul 03, 2009 at 04:35:01PM +0800, Herbert Xu wrote:
>> 
>> This just turns a wide-open race into a less likely one (that's
>> why it appears to fix the problem).  The crux of the issue is that 
>> __tun_get(tfile) != NULL has nothing to do with whether the device
>> has been unregistered.

Not so.

unregister_netdevice
  rollback_registered
    tun_net_unit
      __tun_detach.


Further we need rtnl_lock around __tun_detach.

Eric



> tun: Fix device unregister race
>
> It is currently possible for an asynchronous device unregister
> to cause the same tun device to be unregistered twice.  This
> is because the unregister in tun_chr_close only checks whether
> __tun_get(tfile) != NULL.  This however has nothing to do with
> whether the device has already been unregistered.  All it tells
> you is whether __tun_detach has been called.
>
> This patch fixes this by using the most obvious thing to test
> whether the device has been unregistered.
>
> It also moves __tun_detach outside of rtnl_unlock since nothing
> that it does requires that lock.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 11a0ba4..b393536 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1324,20 +1324,22 @@ static int tun_chr_close(struct inode *inode, struct file *file)
>  	struct tun_file *tfile = file->private_data;
>  	struct tun_struct *tun;
>  
> -
> -	rtnl_lock();
>  	tun = __tun_get(tfile);
>  	if (tun) {
> -		DBG(KERN_INFO "%s: tun_chr_close\n", tun->dev->name);
> +		struct net_device *dev = tun->dev;
> +
> +		DBG(KERN_INFO "%s: tun_chr_close\n", dev->name);
>  
>  		__tun_detach(tun);
>  
>  		/* If desireable, unregister the netdevice. */
> -		if (!(tun->flags & TUN_PERSIST))
> -			unregister_netdevice(tun->dev);
> -
> +		if (!(tun->flags & TUN_PERSIST)) {
> +			rtnl_lock();
> +			if (dev->reg_state == NETREG_REGISTERED)
> +				unregister_netdevice(dev);
> +			rtnl_unlock();
> +		}
>  	}
> -	rtnl_unlock();
>  
>  	tun = tfile->tun;
>  	if (tun)
>
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
