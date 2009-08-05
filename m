From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Tue, 04 Aug 2009 22:32:49 -0700
Message-ID: <m1ljlyvn9a.fsf@fess.ebiederm.org>
References: <20090803161242.12947.14620.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41257 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbZHEFc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 01:32:56 -0400
In-Reply-To: <20090803161242.12947.14620.stgit@flek.lan> (Paul Moore's message of "Mon\, 03 Aug 2009 12\:12\:43 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore <paul.moore@hp.com> writes:

> Convert some pointless gotos into returns and ensure tun_attach() errors are
> handled correctly.
>
> Signed-off-by: Paul Moore <paul.moore@hp.com>

This patch appears slightly wrong.  Comments inline.

> I'm sending this as an RFC patch because I'm not entirely certain that the
> changes to the tun_attach() error handling code are 100% correct, although I
> strongly suspect that the current behavor of simply returning an error code
> without any cleanup is broken.  Can anyone comment on this?
> ---
>
>  drivers/net/tun.c |   19 ++++++++++---------
>  1 files changed, 10 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 4a0db7a..b6d06fd 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -938,13 +938,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  		err = tun_attach(tun, file);
>  		if (err < 0)
>  			return err;
> -	}
> -	else {
> +	} else {
>  		char *name;
>  		unsigned long flags = 0;
>  
> -		err = -EINVAL;
> -
>  		if (!capable(CAP_NET_ADMIN))
>  			return -EPERM;
>  
> @@ -958,7 +955,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  			flags |= TUN_TAP_DEV;
>  			name = "tap%d";
>  		} else
> -			goto failed;
> +			return -EINVAL;

Trivially correct.

>  
>  		if (*ifr->ifr_name)
>  			name = ifr->ifr_name;
> @@ -976,10 +973,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  		tun->flags = flags;
>  		tun->txflt.count = 0;
>  
> -		err = -ENOMEM;
>  		sk = sk_alloc(net, AF_UNSPEC, GFP_KERNEL, &tun_proto);
> -		if (!sk)
> +		if (!sk) {
> +			err = -ENOMEM;
>  			goto err_free_dev;
> +		}

Trivially correct but I would argue uglier.

>  
>  		init_waitqueue_head(&tun->socket.wait);
>  		sock_init_data(&tun->socket, sk);
> @@ -1010,7 +1008,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  
>  		err = tun_attach(tun, file);
>  		if (err < 0)
> -			goto failed;
> +			goto err_unreg_dev;
>  	}

This is the interesting one.  And several problems with it.  When
Herbert reworked the reference counting here he introduced the goto
failed; Instead of err_free_dev.

I think there were more possible races when I introduced the check
of the return code of tun_attach, the only case I can see currently
is if the file was attached to another tun device before we grabbed the
rtnl_lock.


>  	DBG(KERN_INFO "%s: tun_set_iff\n", tun->dev->name);
> @@ -1039,11 +1037,14 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  	strcpy(ifr->ifr_name, tun->dev->name);
>  	return 0;
>  
> + err_unreg_dev:
> +	rtnl_lock();
> +	unregister_netdevice(tun->dev);
> +	rtnl_unlock();

This is a guaranteed deadlock.  We already hold the rtnl_lock here.
Furthermore all I should need to do in this case is to call
unregister_netdevice(...).    As all of the rest of the pieces should
happen in the cleanup routines called from unregister_netdevice.

The current behavior of returning an error code is a little bit off
as it creates a persistent tun device without setting tun->flags | TUN_PERSIST.
And it leaves a tun device for someone else to clean up.

At the same time it should be perfectly legitimate for someone else to
come along and attach to the tun device and delete it or to call
ip link del <tun>

Eric

>   err_free_sk:
>  	sock_put(sk);
>   err_free_dev:
>  	free_netdev(dev);
> - failed:
>  	return err;
>  }
>  
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
