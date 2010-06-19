From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: Distributed Switch Architecture(DSA)
Date: Sat, 19 Jun 2010 16:22:18 +0200
Message-ID: <OF27FDE4E4.06C565FF-ONC1257747.004A175A-C1257747.004EF252@transmode.se>
References: <OF4DC5B7A3.2D318B4E-ONC1257746.00253DA6-C1257746.002714B0@transmode.se> <20100618073309.GB14513@mail.wantstofly.org> <OF68B8EEAD.B003EFE7-ONC1257746.003109DB-C1257746.0032D371@transmode.se> <20100618095923.GC14513@mail.wantstofly.org> <OF8E185B56.9B8AB610-ONC1257746.003A78DF-C1257746.003D4C6C@transmode.se> <20100618121223.GH14513@mail.wantstofly.org> <OF4FC7639D.8FBCAF3B-ONC1257746.004AF9D3-C1257746.005397F6@transmode.se> <20100618201243.GK14513@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:47230 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755978Ab0FSO0e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jun 2010 10:26:34 -0400
In-Reply-To: <20100618201243.GK14513@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek <buytenh@wantstofly.org> wrote on 2010/06/18 22:12:43:
> From: Lennert Buytenhek <buytenh@wantstofly.org>
> To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> Cc: netdev@vger.kernel.org
> Date: 2010/06/18 22:12
> Subject: Re: Distributed Switch Architecture(DSA)
>
> On Fri, Jun 18, 2010 at 05:13:03PM +0200, Joakim Tjernlund wrote:
>
> > > > > > > > Now I want to add STP/RSTP to the switch. How would one do that?
> > > > > > >
> > > > > > > First, you'll want the hardware bridging patches that I posted to
> > > > > > > netdev@ a while back, e.g.:
> > > > > > >
> > > > > > >    http://patchwork.ozlabs.org/patch/16578/
> > > > > >
> > > > > > I see, will have to study this a bit closer. One question though,
> > > > > > does this disable MAC learning in the linux bridge?
> > > > >
> > > > > No, why should it?
> > > >
> > > > Doesn't the HW switch handle all MAC leaning? Why duplicate
> > > > this in the SW bridge?
> > > > I figured the HW switch would offload the SW bridge this task.
> > >
> > > Imagine the case where you bridge lan1, lan2 (both on the switch chip)
> > > into br0, together with wlan0 (which is not on the switch chip).
> > >
> > > Now a packet is sent out of br0.  Should it be sent to wlan0 or to the
> > > switch chip?  How will you make this decision without an address database
> > > on the Linux side?
> >
> > True, in this case you need it, but for only HW switch I/Fs you don't
> > need it and there can be several hundreds of MAC addresses passing
> > trough the HW switch. It would be nice if one didn't need to pass
> > all those up to the SW bridge, especially if you have a small embedded
> > CPU.
>
> I think you overestimate the effect that address learning will have on
> the host CPU.  It only needs to happen for the first packet for every
> new MAC address, and address flooding attacks is something you'll need
> to address in either case.

Possibly, I am just being careful.

>
> If you're really worried about this scenario, then just configure your
> boot loader to bridge all switch ports together, and don't load the DSA
> driver.  The switch will then appear as a single interface, 'eth0' (or
> whatever your SoC calls it), over which you can talk directly without
> any form of tagging.  You won't be able to use any advanced features,
> though.

Na, that is no fun :)

>
>
> > > > > > Do you have any idea how to do DSA on a Broadcom switch?
> > > > >
> > > > > I have no idea.  When I originally submitted the DSA code for merging,
> > > > > I contacted Broadcom people about adding support for Broadcom switch
> > > > > chips to it, but I never heard back from them.
> > > >
> > > > OK. With DSA, how does one configure VLANs, policing and parameters in the
> > > > HW switch that don't map or exist in the linux bridge?
> > >
> > > The idea is to use existing kernel interface for this as much as
> > > possible.  So e.g. if you do:
> > >
> > >    vconfig add lan1 123
> > >    vconfig add lan2 123
> > >    brctl addbr br123
> > >    brctl addif br123 lan1.123
> > >    brctl addif br123 lan2.123
> > >
> > > Then the DSA code (or some userspace netlink listener helper, or some
> > > combination of both) should ideally also detect that VLAN 123 on
> > > interfaces lan1 and lan2 are to be bridged together, and program the
> > > switch chip accordingly.  I think all VLAN configurations that at least
> > > the Marvell hardware supports can be expressed this way.
> >
> > Yes, but I image that this breaks down when you want to do something
> > a bit more advanced. For example I don't think linux VLANs supports
> > "shared VLAN learning"(SVL) and to configure a HW switch to do SVL
> > one would first have to impl. that in Linux VLAN and then add the DSA
> > code to get the config to the switch.
>
> Yes.  But that's really the best way to do it, in my humble opinion.

I will buy that for the moment. I can't see a better way either if
you truly want to integrate a HW switch into linux. I just wish
Linux VLANs had some support for SVL too

>
> If you don't go the host networking stack integration route, you end
> up with something like the vendor drivers.  Which work fine for most
> scenarios.. until you want to do something like talking TCP/IP using
> the host TCP stack over some of the switch ports, at which point the
> lack of host networking stack integration comes to bite you.

Just doing STP will bite you :)

>
>
> > Not sure how one would express whether VLAN tags should be stripped
> > off or not when egressing the HW switch's physical port.
>
> If you transmit a packet onto 'lan', it will be sent to the switch chip
> with an "untagged" DSA tag.  If you transmit a packet onto 'lan.123',
> it will be sent to the switch chip with a "tagged" DSA tag.  See
> net/dsa/tag_dsa.c for details.

Ah, now I get it, thanks.
However, how does this work for LAN to LAN pkgs? LAN1 and LAN2 could be
in the same VLAN but one is implicit(port) VLAN and the
other is explicit. How do I config the HW switch to do that?

>
>
> > Furthermore, suppose one have a big HW switch, 48 ports, and lots of
> > VLANs in that HW switch one would have to create a lot of virtual I/Fs
> > and VLANs in linux just to configure the HW switch. This wastes
> > resources on the CPU.
>
> Where the 'resource waste' is on the order of a couple of tens or
> hundreds of kilobytes of RAM.  If this is a problem for your host
> CPU, I think you have bigger problems anyway.

That is not a very good argument, this is how bloat builds.
However, lets ignore this for now.

>
>
> > > To configure things like ingress/egress rate limiting and such in the
> > > switch chip for which there is no Linux counterpart interface, I suppose
> > > some sysfs interface or so might suffice.
> >
> > Yes, there are aspects of a HW switch that doesn't map into DSA currently.
> > Perhaps one should add some framework to support this?
>
> Sounds good.

Any idea how such an framework should look like? What transport
mechanism is suitable to talk to a user space daemon?

