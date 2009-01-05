From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe select_queue broken in 2.6.28
Date: Sun, 4 Jan 2009 19:23:20 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0901041918010.1888@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090101225456.68f4fe9d@extreme> <20090102.001933.70654029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55049 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753413AbZAEDXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jan 2009 22:23:35 -0500
In-Reply-To: <20090102.001933.70654029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Jan 2009, David Miller wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 1 Jan 2009 22:54:56 -0800
> 
> > The ixgbe driver in 2.6.28 modifies select_queue. This is bad
> > in a couple of ways:
> >   1) select_queue is now in net_device_ops so the driver won't build
> >      unless CONFIG_COMPAT_NET_DEV_OPS is defined
> >   2) it is changing data that is shared and supposed to be immutable.
> > 
> > Looks like a some of the DCB stuff forgot to look at net_device_ops
> 
> Drivers shouldn't be overriding the ->select_queue() method unless
> there is a very specific reason to do so.  Ethernet drivers will not
> have such a reason.

Agreed.  I stumbled across this override in the DCB code in ixgbe right 
before the holidays.  I plan to find out why that was put in and submit a 
patch to correct it.

> This is a very bad trend and I think I'm going to need to simply
> remove the ->select_queue() method to stop the bleeding.

I understand why you want to remove this, but at the same time it is 
something that is useful if we don't abuse it.  I know for a fact this 
function pointer is very useful for routing performance setups, where 
binding a Tx queue to the CPU is very useful.  Jesse actually did the work 
on testing and getting good results with this.

> If people keep overriding this method in their drivers, then when we
> move to more sophisticated methods of computing the hash we will have
> to hit all of these override spots which makes the generic queue
> selection function pointless.

Understood.  If I clean up the use in ixgbe, and we can influence others 
to not abuse the function pointer, can we please keep it?  It really does 
provide flexibility with certain advanced features in future devices in 
specific configurations, which would be impossible to support without this 
ops pointer.

Cheers,
-PJ Waskiewicz
