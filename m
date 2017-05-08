From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC] net: Fix inconsistent teardown and release of
 private netdev state.
Date: Mon, 8 May 2017 12:13:59 -0700
Message-ID: <20170508121359.45e367e5@xeon-e3>
References: <20170508.125243.1637135196896174683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35844 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752798AbdEHTOC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 15:14:02 -0400
Received: by mail-pg0-f51.google.com with SMTP id 64so15807663pgb.3
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 12:14:02 -0700 (PDT)
In-Reply-To: <20170508.125243.1637135196896174683.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 08 May 2017 12:52:43 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> Network devices can allocate reasources and private memory using
> netdev_ops->ndo_init().  However, the release of these resources
> can occur in one of two different places.
> 
> Either netdev_ops->ndo_uninit() or netdev->destructor().
> 
> The decision of which operation frees the resources depends upon
> whether it is necessary for all netdev refs to be released before it
> is safe to perform the freeing.
> 
> netdev_ops->ndo_uninit() presumably can occur right after the
> NETDEV_UNREGISTER notifier completes and the unicast and multicast
> address lists are flushed.
> 
> netdev->destructor(), on the other hand, does not run until the
> netdev references all go away.
> 
> Further complicating the situation is that netdev->destructor()
> almost universally does also a free_netdev().
> 
> This creates a problem for the logic in register_netdevice().
> Because all callers of register_netdevice() manage the freeing
> of the netdev, and invoke free_netdev(dev) if register_netdevice()
> fails.
> 
> If netdev_ops->ndo_init() succeeds, but something else fails inside
> of register_netdevice(), it does call ndo_ops->ndo_uninit().  But
> it is not able to invoke netdev->destructor().
> 
> This is because netdev->destructor() will do a free_netdev() and
> then the caller of register_netdevice() will do the same.
> 
> However, this means that the resources that would normally be released
> by netdev->destructor() will not be.
> 
> Over the years drivers have added local hacks to deal with this, by
> invoking their destructor parts by hand when register_netdevice()
> fails.
> 
> Many drivers do not try to deal with this, and instead we have leaks.
> 
> Let's close this hole by formalizing the distinction between what
> private things need to be freed up by netdev->destructor() and whether
> the driver needs unregister_netdevice() to perform the free_netdev().
> 
> netdev->priv_destructor() performs all actions to free up the private
> resources that used to be freed by netdev->destructor(), except for
> free_netdev().
> 
> netdev->needs_free_netdev is a boolean that indicates whether
> free_netdev() should be done at the end of unregister_netdevice().
> 
> Now, register_netdevice() can sanely release all resources after
> ndo_ops->ndo_init() succeeds, by invoking both ndo_ops->ndo_uninit()
> and netdev->priv_destructor().
> 
> And at the end of unregister_netdevice(), we invoke
> netdev->priv_destructor() and optionally call free_netdev().
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 

Thanks for addressing a confusing and messy semantic. If you merge
this then it would be good to update the documentation in Doucmentation/networking
to describe how drivers are supposed to behave.

The original semantics here evolved from a desire not to have to re-engineer
lots of device drivers. And your change does the same; ie. assume that there
is a reason the device needs special treatment on unregister.

An alternative and more difficult way of addressing the problem would
be to rework the drivers that define destructors to work with the simpler
model used by all the other drivers. What makes these drivers special,
and can they be fixed instead. Probably this won't work and would be too
much effort on lots of little used devices.
