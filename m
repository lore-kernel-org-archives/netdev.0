From: jamal <hadi@cyberus.ca>
Subject: Re: Interconnect virtual device?
Date: 02 Mar 2005 16:55:54 -0500
Message-ID: <1109800554.1091.213.camel@jzny.localdomain>
References: <4222A8F2.6080004@candelatech.com>
	 <1109592365.2188.914.camel@jzny.localdomain>
	 <422353C9.6050001@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <422353C9.6050001@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Not sure if i ever responded to you.

On Mon, 2005-02-28 at 12:24, Ben Greear wrote:
> jamal wrote:
[..]
> > In other words, it redirects to another device - I take it based on some
> > rules. Sounds to me like the mirred action already does this (and in
> > addition can mirror).
> 
> Actually, I was thinking that either user-space or perhaps a kernel
> module could use the standard methods of receiving all pkts in promisc
> mode to do the bridging portion.  If I force the real ethernet
> interface to have no IP address, and put it into promisc mode, then
> I can effectively bridge in user-space.
> 
> When I re-insert the pkts into the stack by writing to the virtual
> device, the (potentially modified) packet can be
> routed and firewalled, etc just like a normal packet received from the
> network.  I may need to have two virtual inter-connects, one w/out
> an IP that does the bridging portion, and one with an IP that actually
> communicates with the rest of the kernel.  In this case, the two virtuals
> would be connected to each other.
> 
> I think this could provide a way to do very customized actions on
> raw packets without having to hack the kernel on an ongoing basis.
> 

There are two ways to do this:

a) You could redirect to a packet socket - a small extension needed to
the redirect action (mostly mechanical details involved like keeping
state of which sockets are open etc).

b) My preference is to push this gentleman's PF_RING
(http://www.ntop.org/ntop.html) netdevice into the kernel. He has
replicated unfortunately a lot of the stuff already done by MMAPED
packet socket - but i think we can forgive him since solution a) would
require hacking packet socket.

Reinjection of packets still needs working for that device - just as
much as a few cleanups here and there. The problem is the guy is not
very responsive - I have a lot of notes on his stuff if you are willing
to chase him around.
You can then get redirection to this device for free (for either
incoming or outgoing packets); something like:

tc filter add dev eth0 .... \
match ip src 10.0.0.1/32 \
action mirred egress redirect dev ring0

Assuming you have a program running on user space you should receive all
packets incoming and/or outgoing on eth0.

And no, you dont need the eth device to have a ip address attached.

cheers,
jamal
