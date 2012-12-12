From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: netdevice wanrouter: Convert directly reference of netdev->priv
Date: Tue, 11 Dec 2012 19:58:15 -0500
Message-ID: <CAP=VYLrHQSGhX+_39tMmg+SE6LLDj+2kzSogB5aicFiPDJPLKg@mail.gmail.com>
References: <20121203090405.GA12089@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:47896 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753486Ab2LLB2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 20:28:45 -0500
Received: by mail-pb0-f45.google.com with SMTP id mc8so80205pbc.4
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 17:28:45 -0800 (PST)
In-Reply-To: <20121203090405.GA12089@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 3, 2012 at 4:04 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> Hello Wang Chen,
>
> The patch 7be6065b39c3: "netdevice wanrouter: Convert directly
> reference of netdev->priv" from Nov 20, 2008, leads to the following
> Smatch warning:
> net/wanrouter/wanmain.c:610 wanrouter_device_new_if()
>          error: potential NULL dereference 'dev'.
>
> This is an old patch from 2008.  It removed the allocation in
> wanrouter_device_new_if() so it looks like wanrouter has been completely
> broken for four years.

Hi Dan,

Crap -- wishing I'd seen this earlier.  There was an RFC patch for
sending wanrouter to the bitbucket from Joe Perches, but aside
from the obvious build failures in it that Dave found (and I fixed)
there wasn't any real feedback (either positive or negative) to it:

http://patchwork.ozlabs.org/patch/198830/

Knowing it has been non-functional for ~4 years is I think a key
bit of information in justifying a removal, so folks like yourself
and JuliaL don't waste cycles fixing/auditing dead code.  But it
will need to be 3.9 material now, it seems.

Paul.
--

>
> @@ -589,10 +591,6 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
>                 err = -EPROTONOSUPPORT;
>                 goto out;
>         } else {
> -               dev = kzalloc(sizeof(struct net_device), GFP_KERNEL);
> -               err = -ENOBUFS;
> -               if (dev == NULL)
> -                       goto out;
>                 err = wandev->new_if(wandev, dev, cnf);
>
> "dev" is still NULL after the call to ->new_if().
>
>         }
>
> Here is what the code looks like now:
>
> net/wanrouter/wanmain.c
>    590          if (cnf->config_id == WANCONFIG_MPPP) {
>    591                  printk(KERN_INFO "%s: Wanpipe Mulit-Port PPP support has not been compiled in!\n",
>    592                                  wandev->name);
>    593                  err = -EPROTONOSUPPORT;
>    594                  goto out;
>    595          } else {
>
> We were supposed to allocate "dev" here.
>
>    596                  err = wandev->new_if(wandev, dev, cnf);
>    597          }
>    598
>    599          if (!err) {
>    600                  /* Register network interface. This will invoke init()
>    601                   * function supplied by the driver.  If device registered
>    602                   * successfully, add it to the interface list.
>    603                   */
>    604
>    605  #ifdef WANDEBUG
>    606                  printk(KERN_INFO "%s: registering interface %s...\n",
>    607                         wanrouter_modname, dev->name);
>    608  #endif
>    609
>    610                  err = register_netdev(dev);
>                               ^^^^^^^^^^^^^^^^^^^^
>
> The kernel will always oops inside the call to register_netdev() because
> "dev" is still NULL.
>
> I suspect we should just revert the patch?
>
> regards,
> dan carpenter
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
