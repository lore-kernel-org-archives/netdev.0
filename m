From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Tue, 6 Mar 2012 15:09:57 +0100
Message-ID: <20120306140957.GA27559@wantstofly.org>
References: <1329225526.2806.34.camel@mojatatu>
 <4F3AAE80.4040609@intel.com>
 <1329315057.4158.15.camel@mojatatu>
 <4F3C5B44.7000608@intel.com>
 <1329488932.2272.19.camel@mojatatu>
 <4F3E8A01.5000205@intel.com>
 <1329568900.3027.0.camel@mojatatu>
 <4F4DAC26.4050108@intel.com>
 <20120305165339.GS12271@wantstofly.org>
 <1331041346.2374.108.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, Chris Healy <chealy@imsco-us.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:62644 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759254Ab2CFOKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:10:01 -0500
Content-Disposition: inline
In-Reply-To: <1331041346.2374.108.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 06, 2012 at 08:42:26AM -0500, jamal wrote:

> > net/dsa currently configures any switch chips in the system to do
> > auto-learning.  
> 
> So we clearly need the (user configurable) knob to turn on/off learning.

Why so?  (I think the switch chips should just never do learning at
all..)


> I think it should also be upto the admin to decide whether the learning
> happens in the kernel or user space.

I can't see any point in doing it in userspace.  What would be the
advantage of that?  And based on what would the admin make the decision?


> > However, I would much prefer to disable that, and have
> > the switch chip just pass up packets for new source addresses, have
> > Linux do the learning, and then mirror the Linux software FDB into
> > the hardware instead -- that avoids having to manually flush the
> > hardware FDB on certain STP state transitions or having to configure
> > the hardware to use a shorter address learning timeout when we're in
> > the middle of an STP topology change, which are problems we are
> > running into in practice.
> 
> So in the scenario you are describing then it seems the h/ware has
> no stp state toggles, correct?  In other ASICs i have seen, there is
> influence from stp state on behavior.

It does, there is an STP state field per port in the switch chip,
which controls whether learning takes place on this port (in
Learning and Forwarding states) and whether packets are forwarded
(in the Forwarding state).

But e.g. it doesn't automatically flush this port's FDB entries if
you move a port from Forwarding to Listening -- the STP state field
only controls direct learning and forwarding for received packets.

And when you receive a BPDU with the topology change notification
bit set, the switch won't automatically shorten the FDB entry
timeout for you until the topology change is over, either.


> > Just curious -- while your patches allow propagating FDB entries
> > into the hardware, do you also have hooks to tell the hardware which
> > ports are to share address databases?
> 
> I think those are missing in this discussion and makes a lot of
> sense to be part of the interface.

Keep in mind that these chips also do VLAN tagging in hardware, and
so a scenario like:

	# brctl addbr br123
	# brctl addif br123 lan1.123
	# brctl addif br123 lan2.123

is also one that can be handled in hardware (which the current
patchwork patch doesn't handle yet).


> > net/dsa currently solves this by not having the hardware handle
> > broadcast packets at all, which circumvents the problem, but for
> > multicast traffic you would still like to be able to do at least the
> > forwarding that can be done in hardware in hardware.  (Unicast doesn't
> > have this problem as long as the kernel and the switch chip agree on
> > their view of the FDB.)
> 
> Of course this could represent an interesting opportunity for a DOS.
> Even at 4 port switch at 100Mbs, hitting 500Kpps to the CPU (I am
> thinking these tiny switches end up in some tiny MIPS/ARM cpu) could
> be devastating. How do you deal with that?

You can let the switch rate limit the number of packets passed up to
the CPU.  500 kp/s broadcast traffic seems somewhat excessive in any
case, and I'm not sure if this deserves handling apart from QoSing
those streams to manageable levels.


thanks,
Lennert
