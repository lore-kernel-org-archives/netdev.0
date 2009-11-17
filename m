From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] dev->refcnt long term holder
Date: Tue, 17 Nov 2009 11:18:10 -0800 (PST)
Message-ID: <20091117.111810.181262927.davem@davemloft.net>
References: <4B01ADF5.8090904@gmail.com>
	<20091117.003019.196504832.davem@davemloft.net>
	<20091117095846.6ef8b4f6@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52437
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754690AbZKQTRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 14:17:54 -0500
In-Reply-To: <20091117095846.6ef8b4f6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 17 Nov 2009 09:58:46 -0800

> I thought it was to handle:
>  1) carrier on old devices would bounce, so it provides ratelimiting
>     of state changes. Modern hardware and CPU's probably makes this a non-issue.
>  2) wasn't there some code path with device changes, hotplug, uevent and
>     udev that meant that we couldn't do notifiers immediately.

I did a lot of code review in this area last night and it seems to be
#1 above and simply being able to do sleeping things to send the
events even though the carrier state changes happen in interrupt
context.

Even for what it's designed to do, it's overengineered.

So what I propose is that we simplify the design and also allow direct
invocation for cases where we're already in a sleepable context and/or
holding RTNL.  Similar to how Eric is doing in his latest linkwatch
patch for VLANs.

Note also that linkwatch's current implementation is the sole reason
we do the real work of netdevice destruction after dropping RTNL :-)
Linkwatch and unregister_netdevice() used to deadlock on RTNL.

>From history-2.6 GIT:

commit ff936f4e8148e75b20595eda5de6d3a4bb55b631
Author: David S. Miller <davem@nuts.ninka.net>
Date:   Mon May 19 04:30:48 2003 -0700

    [NET]: Fix netdevice unregister races.
    
    We had two major issues when unregistering networking devices.
    1) Even trying to run hotplug asynchronously could deadlock
       if keventd was currently trying to get the RTNL semaphore
       in order to process linkwatch events.
    2) Unregister needs to wait for the last reference to go away
       before the finalization of the unregister can execute.  This
       cannot occur under the RTNL semaphore as this is deadlock
       prone as well.
    
    The solution is to do all of this stuff after dropping the
    RTNL semaphore.  rtnl_lock, if it is about to protect a region
    of code that could unregister network devices, registers a list
    to which unregistered netdevs are attached.  At rtnl_unlock time
    this list is processed to wait for refcounts to drop to zero and
    then finalize the unregister.



