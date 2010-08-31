From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [rfc] Merging the Open vSwitch datapath
Date: Tue, 31 Aug 2010 13:48:55 +0200
Message-ID: <201008311348.55883.arnd@arndb.de>
References: <20100830062755.GA22396@verge.net.au> <201008302304.38061.arnd@arndb.de> <43F901BD926A4E43B106BF17856F0755F63A0B62@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Pfaff <blp@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:57777 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932136Ab0HaLtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 07:49:11 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755F63A0B62@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 31 August 2010, Rose, Gregory V wrote:

> >On Monday 30 August 2010 20:45:19 Rose, Gregory V wrote:
> >> As of now there are no existing ways to get switch configuration to a
> >> NIC without resorting to a customized interface such as a private
> >IOCTL.
> >
> >Well, there are the IFLA_VF_INFO netlink attributes that I would
> >assume are to be used for switch configuration and extended where
> >required for that, e.g. to set VEPA mode per channel.
> >
> >> EVB is an emerging standard that I think would be desirable to support
> >> in the kernel.
> >
> >Do you mean 802.1Qbg?
> 
> Yes, and 802.1Qbh.

The situation for 802.1Qbh is a little trickier. We cannot do an
implementation of this in user space, because the spec is not public.
However, we have kernel interfaces that allow you to do this in
firmware/driver.
 
> > Why would you want kernel support? There is
> >already support for VEPA in the kernel, and 802.1ad provider bridges
> >should probably be added in order to support multi-channel setups.
> 
> I should probably read up a bit more on 802.1ad.

What we need here is an extension of the vlan module to allow
double tagging with the right ethertype on the outer frame.

> >The other parts are configuration protocols like LLDP and CDP, which
> >we normally do in user space (e.g. lldpad).
> >
> >What else is there that you think should go into the kernel.
> 
> It seems to me that the IFLA_VF_INFO netlink attributes are station
> oriented.  The kernel support I see there is insufficient for some 
> other things that need to be done for access control, forwarding 
> rules and actions taken on certain kind of packets.  I think there'll
> be a need to configure the switch itself, not just the stations
> attached to the switch.

Ok, I'm beginning to understand what you want to do.

1. VEPA using software: use a traditional NIC, and macvtap (or similar)
   in the hypervisor to separate traffic between the guests, do
   bridging in an external switch. Works now.
2. VEPA using hardware: give each guest a VF, configure VFs into VEPA
   mode. Requires a trivial addition to IFLA_VF_INFO to allow VEPA setting
3. Simple bridge using software: like 1, but forward traffic between
   some or all macvtap ports. Works now.
4. Simple bridge using hardware: Like 2, this is what we do today when
   using VFs.
5. Full-featured bridge using brctl/ebtables/iptables. This has access
   to all features of the Linux kernel. Works today, but requires management
   infrastructure (see: Vyatta) that is not present everywhere.
6. Full-featured bridge in hardware with the features of ebtables/iptables.
   Not going to happen IMHO, see below.
7. Full-featured distributed bridge using Open vSwitch. This is
   what the current discussion is about.
8. Full-featured distributed bridge using Open vSwitch and hardware support.

I was arguing against 6, which would not even work using the same Open
vSwitch netlink interface, while I guess what you want is 8.

Now I would not call that "configuring the switch", since the switch in
this case is basically a daemon running on the host and configuring the
data path, which has now moved into the hardware from the kernel.

> >> As you mention netlink is easier to extend and I think
> >> it would be a great way to add support for NIC EVB in the kernel.
> >> But even with a kernel interface there is still no user level tool.
> >
> >Using the same interface as Open vSwitch would be really nice to
> >configure a NIC bridge sounds interesting if we want to speed up
> >Open vSwitch, but I don't think it makes any sense for the EVB
> >protocols. Quite the contrary, you typically want the NIC to
> >get out of the way and do all the bridging in the external
> >switch in case of VEPA. Or you actually want to use features of
> >the software bridge implementation like iptables.
> 
> What if the NIC is the external switch? 

I don't think that is going to happen. All embedded switches
are of the edge (a.k.a. dumb) type right now, and I believe that
will stay this way.
By an external switch, I mean something that is running an
operating system and allows users to log in for configuring
the switch rules.

> I mean, what if the
> NIC has an edge virtual bridge embedded in it?  The IFLA_VF_INFO
> messages are sufficient for many features but there are some that
> it doesn't address.  And I don't know of any way to get iptables
> rules down to the VF using existing kernel interfaces. 

Exactly! The problem is that I don't think any edge virtual bridge
can ever implement the full set of features we have in software,
and for this reason I wouldn't spend too much time in adding a small
subset of the features.

We probably have a few hundreds features implemented in iptables,
ebtables and tc, e.g. connection tracking, quality of service
and filtering. Implementing all these on a NIC is both an enourmous
(or close to impossible) development task and a security risk,
unless you are thinking of actually running Linux on the NIC
to implement them.

Anyway, my point was that improvements to the bridging code
are not directly related to work on EVB, even if we had netfilter
rules for controlling the integrated bridge in your NIC.

Now, your suggestion to define the Open vSwitch netlink interface
in a way that works with both hardware bridges as well as the
kernel code we're discussing does sound great!
Obviously, there are some nice ways to combine this with the EVB
protocols, but I can both being useful without the other.

> >One idea that we have discussed in the past is to use the macvlan
> >netlink interface to create ports inside a NIC. This interface
> >already exists in the kernel, and it allows both bridged and VEPA
> >interfaces. The main advantage of this is that the kernel can
> >transparently create ports either using software macvlan or
> >hardware accelerated functions where available.
> 
> This actually sounds like a good idea.  I hadn't thought about that. 
> It would cover one of the primary issues I'm dealing with right now.

Ok, cool. Since this is something I've been meaning to work on for
some time but never got around to, I'll gladly give help and advice
if you want to work on the implementation. I have access to a number
of Intel NICs to test things.

	Arnd
