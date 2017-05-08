From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] net: Fix inconsistent teardown and release of
 private netdev state.
Date: Mon, 08 May 2017 15:21:35 -0400 (EDT)
Message-ID: <20170508.152135.1200615918260312115.davem@davemloft.net>
References: <20170508.125243.1637135196896174683.davem@davemloft.net>
        <20170508121359.45e367e5@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36148 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752364AbdEHTVh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 15:21:37 -0400
In-Reply-To: <20170508121359.45e367e5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 8 May 2017 12:13:59 -0700

> Thanks for addressing a confusing and messy semantic. If you merge
> this then it would be good to update the documentation in
> Doucmentation/networking to describe how drivers are supposed to
> behave.

Will do.

> An alternative and more difficult way of addressing the problem would
> be to rework the drivers that define destructors to work with the simpler
> model used by all the other drivers. What makes these drivers special,
> and can they be fixed instead. Probably this won't work and would be too
> much effort on lots of little used devices.

The biggest problem is that we have two models of teardown... well
actually the issue is more about resources allocated at probe time.

For many software devices, instances come from ->newlink() or other
config requests, so they go "register the device" and then forget
about it, leaving it to the registered callbacks to cleanup.

But things are different for most hardware devices.  They allocate
resources on probe, and therefore absolutely cannot let
register_netdevice(), or the callbacks, release those resources
nor perform the free_netdev().

So what a lot of drivers do is, in their driver ->remove() method,
unregister the device, release the probe time resources, then
do the free_netdev() by hand.

So as you say, these interfaces and their behavior evolved over time
in response to need.
