From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun netns BUG()
Date: Fri, 3 Jul 2009 16:35:01 +0800
Message-ID: <20090703083501.GA25536@gondor.apana.org.au>
References: <m1ljo61cya.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dwmw2@infradead.org, netdev@vger.kernel.org,
	johannes@sipsolutions.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50958 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752974AbZGCIfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 04:35:09 -0400
Content-Disposition: inline
In-Reply-To: <m1ljo61cya.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> --- linux-2.6.28.x86_64-old/drivers/net/tun.c   2009-05-06 15:01:56.000000000 -0700
> +++ linux-2.6.28.x86_64/drivers/net/tun.c       2009-05-06 15:10:09.000000000 -0700
> @@ -1194,21 +1194,22 @@
> static int tun_chr_close(struct inode *inode, struct file *file)
> {
>        struct tun_file *tfile = file->private_data;
> -       struct tun_struct *tun = __tun_get(tfile);
> +       struct tun_struct *tun;
> 
> 
> +       rtnl_lock();
> +       tun = __tun_get(tfile);
>        if (tun) {
>                DBG(KERN_INFO "%s: tun_chr_close\n", tun->dev->name);
> 
> -               rtnl_lock();
>                __tun_detach(tun);
> 
>                /* If desireable, unregister the netdevice. */
>                if (!(tun->flags & TUN_PERSIST))
>                        unregister_netdevice(tun->dev);
> 
> -               rtnl_unlock();
>        }
> +       rtnl_unlock();

Sorry, catching up with emails (hmm, maybe I should stop doing
that and read some new emails :)

This just turns a wide-open race into a less likely one (that's
why it appears to fix the problem).  The crux of the issue is that 
__tun_get(tfile) != NULL has nothing to do with whether the device
has been unregistered.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
