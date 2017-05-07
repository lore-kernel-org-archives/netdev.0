From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4 00/12] Fix possbile memleaks when fail to
 register_netdevice
Date: Sun, 07 May 2017 18:25:50 -0400 (EDT)
Message-ID: <20170507.182550.695836233888168365.davem@davemloft.net>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41118 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750984AbdEGWZz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 18:25:55 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@foxmail.com
Date: Tue,  2 May 2017 13:58:42 +0800

> These following drivers allocate kinds of resources in its ndo_init
> func, free some of them or all in the destructor func. Then there is
> one memleak that some errors happen after register_netdevice invokes
> the ndo_init callback. Because only the ndo_uninit callback is invoked
> in the error handler of register_netdevice, but destructor not.
> 
> In my original approach, I tried to free the resources in the
> newlink func when fail to register_netdevice, like destructor did
> except not free the net_dev. This method is not good when destructor
> is changed, and the memleak could be not fixed when there is no
> newlink callback.
> 
> Now create one new func used to free the resources in the
> destructor, and the ndo_uninit func also could invokes it when fail
> to register the net_device by comparing the dev->reg_state with
> NETREG_UNINITIALIZED.  If there is no existing ndo_uninit, just add
> one.
> 
> This solution doesn't only make sure free all resources in any case,
> but also follows the original desgin that some resources could be
> kept until the destructor executes normally after register the
> device successfully.

Device private teardown is in two stages for the following reason.
The issue is that netdev_ops->ndo_init() allocates two types of
resources.

One type is OK to release during destruction before the netdev refs
goes to zero.  This is what netdev_ops->ndo_uninit() is for.

The second type is for releasing things which are not safe to drop
until the very last netdev reference disappears.  This is what
netdev->destructor() is for.

If you look around there are hacks in place all over to try and deal
with this issue.  Basically, look for code that checks the return
value of register_netdev() and if an error is indicated it does
some local driver state freeing.  Bonding is one example.  It is
trying to deal with the problem this patch set is targetting.

What really needs to happen is we must divorce the logic of
dev->destructor() from free_netdev().

That way we can do the free_netdev in the unregister netdevice path
after calling netdev->destructor().

Then the only issue callers of register_netdevice() need to be aware
of is that if an error is returned, that caller must call
free_netdev().  Which has been the case for decades.

So I would fix this as follows:

1) Rename netdev->destructor() into "netdev->priv_destructor()"  It
   performs all post ndo_ops->ndo_uninit() cleanups, _except_
   free_netdev().  Update all drivers with netdev->destructor().

2) Add a boolean state to netdev, which indicates if free_netdev()
   should be performed after netdev->priv_destructor() during
   unregister.

That provides all of the flexibility necessary to fix this bug in
the core.

In register_netdevice() if something after ndo_ops->ndo_init()
succeeeds, we invoke _both_ ndo_ops->ndo_uninit() and
netdev->priv_destructor().  We do not look at the netdev "needs
free_netdev()" boolean.

In netdev_run_todo(), where we have the one and only
netdev->destructor() call, change it to:

	if (dev->priv_destructor)
		dev->priv_destructor(dev);
	if (dev->needs_free_netdev)
		free_netdev(dev);

That fixes the bug in all cases.  And makes the purpose and logic
extremely clear.  Also, no internal state tests leak into the
drivers.

Finally, drivers that try to cover up this issue, such as bonding,
need to be changed to no try and free up device private state if
their invocation of register_netdevice() fails.

Thanks.
