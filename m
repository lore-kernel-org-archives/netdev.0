From: jamal <hadi@cyberus.ca>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: 17 Jul 2004 07:52:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090065129.1066.1196.camel@jzny.localdomain>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda> <1089906936.6114.904.camel@uganda>
	 <1089908900.1027.77.camel@jzny.localdomain>
	 <1089910757.6114.965.camel@uganda>
	 <1089912658.1029.101.camel@jzny.localdomain>
	 <20040715232035.37e016ef@zanzibar.2ka.mipt.ru>
	 <1089981282.1060.1293.camel@jzny.localdomain>
	 <1089990384.6114.2842.camel@uganda>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1089990384.6114.2842.camel@uganda>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-07-16 at 11:06, Evgeniy Polyakov wrote:
> On Fri, 2004-07-16 at 16:34, jamal wrote:
> > 
> > Ok, so some controller is in charge - seems like thats something that
> > could be easily done in user space based on mastership transitions.
> 
> Yes, but here is tricky but true example:
> Some time ago e1000 driver from Intel had possibility to do hardware
> bonding(i absolutely don't remember how it was called, but idea was the
> same as in bonding).

I remeber that cruft. Actually (sadly) people like montavista ship that
thing in their distros (under the disguise of carrier grade linux;->).
I think the current folks out of intel working on Linux drivers and
bonding are a lot more knowledgeable - i do hope they have thrown that
"thing" out of the window.

> Consider following scenario: if node is a master than it enables this
> bonding mode using e1000 internal registers. Ethtools doesn't support
> those mode. yes it also can be enabled through patching userspace, but
> with kernel CARP it is not needed.

The way bonding works is the right way to do it.
Forget about that other crap.
There was a thread on netdev a while back to empower bonding to be 
controlled from user space; when that happens you are set.
But even without that the link carrier netlink event messages
should be a good start.

> Or consider TGE example(...wireless HA... strange sentence, but...):
> If I am a master, than enable higher priority in driver.
> Current tc design can't be mapped to driver's internal structures :>

Now you want to wakeup mr Vladimir ;-> Actually i think i just saw mails
from him.
Yes, these are some of the issues we wanna go work on. Still waiting for
the brief review of RSVP-like control being used in TGE. And when done
all that should be done in user space.

> But the main killer is following:
> consider firewall with thousands iptables rules, and if node becomes a
> master it needs to add or remove some rules from table.
> Copying such amounts to/from userspace/kernelspace memory will take
> _minutes_... Even using iptables chains.
> But kernel implementation may just add one rule.

Thats a deficiency in iptables. Iptables should be fixed.
I think there may be plans to fix it actually in place.

> Yet another variant: you need to access CPU internal registers based on
> HA state, kind of turning on or off additional hotplug CPU and or
> memory, enabling/disabling NUMA access. Can you enable/disable bus
> arbiter from userspace?

I think you should be able to write an interface to access such
functionality. Isnt there something along /sbin/hotplug used for such
things?

> For example I'm using on-chip SDRAM in PPC440 as L2 cache or as jitter
> buffer for OPB access, decision to use each mode is based on some
> hardware loads. Userspace do not have access to such mechanism.
> It is deep kernel internals, and I do not see any good reason to export
> it to userspace.
> Actually last example can't be used as argument in our discussion, but
> it illustrates that sometimes we need to touch kernel-_only_ parts, and
> this decision is dictated from the outside of the touchable part.
> 

I can tell you one thing: I am totaly against this thing being part
of the kernel; not just because it adds noise but because it makes it
harder to keep adding more and more functionality or integrating its
capability into other apps.
BTW, theres a very nice paper being presented at OLS by someone from .au
who is trying infact to move drivers to user space ;-> 
I dont mind adding some needed datapath mechanism in the kernel to
enable it to do interesting things; control of such mechanism and policy
decisions should be very clearly separated and sit in userspace.

> > BTW, I like that ARP balancing feature that CARP has. Pretty neat.
> > Note that it could be easily done via a tc action with user space
> > control.
> 
> Anything may be done in userspace.
> For example routing decision.
> Yes, it _may_ be done in userspace. But it is slow.

Big difference though with CARP. CARP shouldnt need to process 100Kpps;
but even if it did, CARP packet contain control information that is
valuable in policy settings. Control protocols tend to be "rich" and
evolve over much shorter periods of time.  
A better comparison what you are saying is to move OSPF to the kernel.

> SCSI over IP may be done as network block device.
> Or even copying packet to userspace through raw device and then send it
> using socket.

Again all that is datapath. CARP is control.

> QNX and Mach are even designed in this way.

We just have better architecture thats all ;-> 

[BTW, A lot of people with experience in things like vxworks (one big
flat memory space) always want to move things into the kernel. Typically
after some fight they move certain things to user space with
"you will hear from me" threats. I never hear back from them because
it works fine. This after they wanted to shoot me because linux "wasnt
realtime"]

> It is not talk about current possibilities, it is kind of design :)
> Yes, probably our _current_ needs may be satisfied using existing
> userspace tools.
> But I absolutely sure that we will need in-kernel support.
> I'm reading you second e-mail with pretty diagrams and already see where
> in-kernel CARP will live there :)

Ok;-> I am looking forward to see your view on it.

cheers,
jamal
