From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Distributed Switch Architecture(DSA)
Date: Sat, 19 Jun 2010 18:56:43 +0200
Message-ID: <20100619165642.GP14513@mail.wantstofly.org>
References: <OF4DC5B7A3.2D318B4E-ONC1257746.00253DA6-C1257746.002714B0@transmode.se> <20100618073309.GB14513@mail.wantstofly.org> <OF68B8EEAD.B003EFE7-ONC1257746.003109DB-C1257746.0032D371@transmode.se> <20100618095923.GC14513@mail.wantstofly.org> <OF8E185B56.9B8AB610-ONC1257746.003A78DF-C1257746.003D4C6C@transmode.se> <20100618121223.GH14513@mail.wantstofly.org> <OF4FC7639D.8FBCAF3B-ONC1257746.004AF9D3-C1257746.005397F6@transmode.se> <20100618201243.GK14513@mail.wantstofly.org> <OF27FDE4E4.06C565FF-ONC1257747.004A175A-C1257747.004EF252@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:53713 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab0FSQ4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jun 2010 12:56:47 -0400
Content-Disposition: inline
In-Reply-To: <OF27FDE4E4.06C565FF-ONC1257747.004A175A-C1257747.004EF252@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 19, 2010 at 04:22:18PM +0200, Joakim Tjernlund wrote:

> > > > > OK. With DSA, how does one configure VLANs, policing and
> > > > > parameters in the HW switch that don't map or exist in the
> > > > > linux bridge?
> > > >
> > > > The idea is to use existing kernel interface for this as much as
> > > > possible.  So e.g. if you do:
> > > >
> > > >    vconfig add lan1 123
> > > >    vconfig add lan2 123
> > > >    brctl addbr br123
> > > >    brctl addif br123 lan1.123
> > > >    brctl addif br123 lan2.123
> > > >
> > > > Then the DSA code (or some userspace netlink listener helper, or some
> > > > combination of both) should ideally also detect that VLAN 123 on
> > > > interfaces lan1 and lan2 are to be bridged together, and program the
> > > > switch chip accordingly.  I think all VLAN configurations that at least
> > > > the Marvell hardware supports can be expressed this way.
> > >
> > > Yes, but I image that this breaks down when you want to do something
> > > a bit more advanced. For example I don't think linux VLANs supports
> > > "shared VLAN learning"(SVL) and to configure a HW switch to do SVL
> > > one would first have to impl. that in Linux VLAN and then add the DSA
> > > code to get the config to the switch.
> >
> > Yes.  But that's really the best way to do it, in my humble opinion.
> 
> I will buy that for the moment. I can't see a better way either if
> you truly want to integrate a HW switch into linux. I just wish
> Linux VLANs had some support for SVL too

You know how to fix that. :)


> > If you don't go the host networking stack integration route, you end
> > up with something like the vendor drivers.  Which work fine for most
> > scenarios.. until you want to do something like talking TCP/IP using
> > the host TCP stack over some of the switch ports, at which point the
> > lack of host networking stack integration comes to bite you.
> 
> Just doing STP will bite you :)

Most people deal with this by running a userland STP daemon that uses
raw sockets to inject manually (i.e. in userspace) DSA-tagged packets
onto the eth0 (or whatever) interface.  This "works" (for some
definitions of 'works') for UDP apps such as a DHCP server as well --
this crappy approach unfortunately only really breaks down for TCP.


> > > Not sure how one would express whether VLAN tags should be stripped
> > > off or not when egressing the HW switch's physical port.
> >
> > If you transmit a packet onto 'lan', it will be sent to the switch chip
> > with an "untagged" DSA tag.  If you transmit a packet onto 'lan.123',
> > it will be sent to the switch chip with a "tagged" DSA tag.  See
> > net/dsa/tag_dsa.c for details.
> 
> Ah, now I get it, thanks.
> However, how does this work for LAN to LAN pkgs? LAN1 and LAN2 could be
> in the same VLAN but one is implicit(port) VLAN and the
> other is explicit.

If you tell the HW switch to forward these packets, they will never
appear at the CPU interface, so the DSA tagging/untagging doesn't enter
the picture.


> How do I config the HW switch to do that?

Tell the switch that the vlan is native on one of the ports but not on
the other.  It's been a while since I looked at the chip docs but there
are ways of doing this.


> > > Furthermore, suppose one have a big HW switch, 48 ports, and lots of
> > > VLANs in that HW switch one would have to create a lot of virtual I/Fs
> > > and VLANs in linux just to configure the HW switch. This wastes
> > > resources on the CPU.
> >
> > Where the 'resource waste' is on the order of a couple of tens or
> > hundreds of kilobytes of RAM.  If this is a problem for your host
> > CPU, I think you have bigger problems anyway.
> 
> That is not a very good argument, this is how bloat builds.

If you have a better way of getting all the features while spending
less resources, please step forward with your ideas.  The current design
is the best I could come up with, but I'm sure it's not optimal in its
current form.


> > > > To configure things like ingress/egress rate limiting and such in the
> > > > switch chip for which there is no Linux counterpart interface, I suppose
> > > > some sysfs interface or so might suffice.
> > >
> > > Yes, there are aspects of a HW switch that doesn't map into DSA currently.
> > > Perhaps one should add some framework to support this?
> >
> > Sounds good.
> 
> Any idea how such an framework should look like? What transport
> mechanism is suitable to talk to a user space daemon?

Have a look at netlink.
