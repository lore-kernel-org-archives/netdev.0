From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Link detection
Date: Mon, 14 Mar 2005 14:32:16 +0100
Message-ID: <20050314133216.GM31837@postel.suug.ch>
References: <200503141435.38227.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Hasso Tepper <hasso@estpak.ee>
Content-Disposition: inline
In-Reply-To: <200503141435.38227.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Hasso Tepper <200503141435.38227.hasso@estpak.ee> 2005-03-14 14:35
> 1) What's the proper way to detect carrier in Linux for user space 
> application like Quagga?
> 
> True, IFF_RUNNING is from BSD, but as long as the code in 
> net/core/dev.c:dev_get_flags() is there, it gives nice clean way to get 
> carrier status from user space (AFAIK it's used in same way in Solaris). 
> Especially for applications using rtnetlink - ie. without it there is no 
> all info in the netlink message any more. If these applications will 
> receive RTM_NEWLINK, they have to poll kernel "look, maybe carrier status 
> is changed" every time?

You should open a rtnetlink socket and register to the RTMGRP_LINK
multicast group and filter for RTM_NEWLINK with ifi_change & IFF_UP and
then look at ifi_flags & IFF_UP to see whether the interface is now
up or down. You'll receive such a rtnetlink message everytime the
carrier status changes.

> 2) There is no difference between "we know that carrier is really on" and 
> "interface doesn't support carrier detection" in Linux.
> 
> >From users' point of view it might make huge difference - can I rely on info 
> I get from OS, or have to run to the equipment to see whether links are 
> really up or not? It's not critical, but would be still nice to have.

Yes, this is a known weakness. You can use ethtool to work around this a bit.

> 3) Connected routes in carrier down situations. If address are added to the 
> interface, "connected" route is added to the interface as well. Problem is 
> that this route is still there if carrier is down, but there is no 
> difference for user if just carrier is down or interface is 
> administratively down - network behind this interface is still actually 
> unreachable.  

The routes must stay if the interface isn't shut down completely. A loss
of the carrier can be temporarly for just a very short period of time.
What we can do is, like in the neighbour tables, differ between a
adimistrative shutdown and a loss of the carrier with a new flag, would
that help you?

> It's not only the issue related with routing protocols, but the general one. 
> I'm using laptop with two interfaces - ethernet and wireless. If I plug off 
> ethernet cable and walk away from my desk, the network on this ethernet 
> segment should be still reachable for me via wireless (default route), but 
> no ... I have to shut down ethernet interface manually.

I think the reaction upon a loss of the carrier should remain in userspace
to some kind of daemon. The only way that would be half working would be
some kind of timeout representing a watermark which makes a temporary
carrier loss a permanent one (i.e. react on it as it would be a
permanent shutdown). This timer must be disabled by default but can be
activated by the user. My question is, what should happen once the
carrier is found again? Restore the routes from somd kind of backup
tables created while disabling the interface? Leave it to userspace?

> Before someone proposes that - yes, managing these routes can be done from 
> user space in theory (like zebra daemon), but there are several problems 
> regarding this.
> 
> * There are several applications which would be interested in this, but it 
> would be dangerous imho if several applications at once will manage 
> connected routes in kernel.

This is subject to be solved via the use of a netlink daemon taking care
of proper locking. Just needs some more time.

> And I don't see any actual reason not to manage removal/adding connected 
> routes in kernel level if link goes down/up. Or is there any? Why would 
> anyone need route to the interface if it's actually known to be unusable?

Problem #1: Differ between a temporary loss of carrier and a permanent
            failure. Relatively easy from userspace because userspace
	    knows about the strategy.

Problem #2: Strategy upon resume of carrier signal, userspace can simply
            reread its configuration and add the routes again. Kernel
	    must backup them and somehow ensure that they stay
	    consistent. Imagine you delete a route to a certain host but
	    one of your links is down at the moment, the route will be
	    restored once the interface comes back up which is probably
	    unexpected behaviour.

Both issues can be solved with quite some effort though.
