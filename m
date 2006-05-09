From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] netdev sysfs failure handling
Date: Tue, 09 May 2006 15:43:22 -0700 (PDT)
Message-ID: <20060509.154322.09145595.davem@davemloft.net>
References: <20060509120107.0a999f38@localhost.localdomain>
	<20060509.140501.18000999.davem@davemloft.net>
	<20060509144049.0924d41c@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13994
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751323AbWEIWn1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 18:43:27 -0400
To: shemminger@osdl.org
In-Reply-To: <20060509144049.0924d41c@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 9 May 2006 14:40:49 -0700

> Agreed, especially since rtnl is now a real mutex.  The case, that
> I was worried about:
> 	rtnl_lock()
> 	spin_lock_irq(&mylock);
> 	x = register_netdevice();
> ...
> 
> Doesn't show up in any current code, even for the pseudo devices
> and funny virtualized interfaces.

Right, therefore I think we should put something like your patch in
there now.... perhaps.

The case where we really needed the todo list is unregister, so that
we can safely wait for all references to the net device to go away.

I still wonder about those mentioned hotplug races wrt. linkwatch
in the comment above netdev_run_todo().

Linkwatch is such a nuissance because it combines asynchronous link
state change processing with keventd and RTNL locking.  It sleeps
waiting for __LINK_STATE_SCHED to clear with the RTNL held (via
dev_deactivate()).  But then again dev_close() code paths do this
too, so the dev_deactivate() bit should be OK.

Linkwatch, after doing the dev_activate(), emits a NETDEV_CHANGE
notifier on netdev_chain and also sends out an RTM_NETLINK
message.  This is for the case where IFF_UP is set.

Until we release the RTNL semaphore, during netdev register, nobody
can go in an inspect the state of a net device.  So doing the sysfs
node creation in register_netdevice() should be OK as far as I can
tell.

Can anyone find a problem with this?
