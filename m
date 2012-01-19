From: David Lamparter <equinox@diac24.net>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 20:53:49 +0100
Message-ID: <20120119195349.GN2262734@jupiter.n2.diac24.net>
References: <20120119190114.GL2262734@jupiter.n2.diac24.net>
 <20120119.140621.817165404586593441.davem@davemloft.net>
 <20120119192541.GM2262734@jupiter.n2.diac24.net>
 <20120119.143105.735366189369504929.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: equinox@diac24.net, hans.schillstrom@ericsson.com,
	netdev@vger.kernel.org, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:33417 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932670Ab2ASTx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 14:53:59 -0500
Content-Disposition: inline
In-Reply-To: <20120119.143105.735366189369504929.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2012 at 02:31:05PM -0500, David Miller wrote:
> >> >> Keeping the timewait sockets around is necessary to absorb any lingering
> >> >> packets in the network meant for those sockets.
[...]
> >> The assumption is that the address is moving, which might not be true.
> > 
> > I don't understand what you mean, what address may not be moving?
> > 
> > We're talking about dropping a netns. All of its addresses disappear,
> > all of its soft devices disappear. Its hard devices fall back into the
> > init namespace, is that what you're referring to?
> 
> And then you immediately start up a new netns with the same address
> and then resets go back to lingering TCP packets the time-waits would
> have consumed.
> 
> The reason this is different from a host reboot is that a host reboot
> takes some amount of time, which even if around 30 seconds is superior
> in behavior to what can happen with netns which can be created almost
> instantly.

Arjan van de Ven booted Linux in 5 seconds in 2008,
cf. http://lwn.net/Articles/299483/

On the TCP timewait scale of time, this is pretty much "immediate".

[..]
> Then if a new netns is created that tries to reuse the address used by
> the mini-netns which hasn't cleared yet, you give -EAGAIN until all
> the timewaits expire.

The effect of this is that you end up being unable to reboot lxc based
virtualised hosts without waiting 2 minutes for the TCP timers to
expire. That sounds completely unacceptable to me.

Another perspective of this is looking at the device references held by a
namespace. I can without any issue and at any time move a network device
into another namespace. This creates exactly the same situation where
the TCP stack that now has the device may reset old connections.

(Now you may argue that one should remove the network devices from a
netns before closing it. One could do that, yes, but that would require
having access to the netns before it actually goes down. That's
problematic if the system inside the netns shuts down uncleanly. Also,
the now-device-devoid network namespace will hold kernel resources for
no good reason.)

> That's much more acceptable to me than what it being proposed, which is
> complete gatbage.

I respectfully disagree.
