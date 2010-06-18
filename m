From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: Distributed Switch Architecture(DSA)
Date: Fri, 18 Jun 2010 17:13:03 +0200
Message-ID: <OF4FC7639D.8FBCAF3B-ONC1257746.004AF9D3-C1257746.005397F6@transmode.se>
References: <OF4DC5B7A3.2D318B4E-ONC1257746.00253DA6-C1257746.002714B0@transmode.se> <20100618073309.GB14513@mail.wantstofly.org> <OF68B8EEAD.B003EFE7-ONC1257746.003109DB-C1257746.0032D371@transmode.se> <20100618095923.GC14513@mail.wantstofly.org> <OF8E185B56.9B8AB610-ONC1257746.003A78DF-C1257746.003D4C6C@transmode.se> <20100618121223.GH14513@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:33685 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932475Ab0FRPO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jun 2010 11:14:58 -0400
In-Reply-To: <20100618121223.GH14513@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek <buytenh@wantstofly.org> wrote on 2010/06/18 14:12:23:
>
> On Fri, Jun 18, 2010 at 01:09:32PM +0200, Joakim Tjernlund wrote:
>
> > > > > > I am trying to wrap my head around DSA and I need some help.
> > > > > >
> > > > > > Assume the example from Lennert:
> > > > > >
> > > > > >        +-----------+       +-----------+
> > > > > >        |           | RGMII |           |
> > > > > >        |           +-------+           +------ 1000baseT MDI ("WAN")
> > > > > >        |           |       |  6-port   +------ 1000baseT MDI ("LAN1")
> > > > > >        |    CPU    |       |  ethernet +------ 1000baseT MDI ("LAN2")
> > > > > >        |           |MIImgmt|  switch   +------ 1000baseT MDI ("LAN3")
> > > > > >        |           +-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
> > > > > >        |           |       |           |
> > > > > >        +-----------+       +-----------+
> > > > > >
> > > > > > If I understand this correctly I get at least 5 virtual I/Fs corresponding
> > > > > > to WAN, LAN1-4, but how is the RGMII I/F modelled?
> > > > >
> > > > > The RGMII interface is just the interface that your "real" network
> > > > > driver exports.  In the case of the Kirkwood 6281 A0 Reference Design
> > > > > (which I developed this code on), that would be eth0.  After the DSA
> > > > > driver is instantiated, you don't send or receive over eth0 directly
> > > > > anymore -- eth0 becomes purely a transport for DSA-tagged packets.
> > > >
> > > > hmm, but how do I send normal pkgs form the CPU to the switch then?
> > >
> > > Define what you mean by 'normal pkgs'.
> >
> > An ethernet broadcast pkg flooded onto all ports.
>
> This statement assumes that all ports have been configured into a
> bridge, which is not the default case.  (And why would it be?  Having each
> port in the same VLAN/subnet is only one of the many possible ways of
> configuring your switch ports -- and regular (non-DSA) Linux network
> interfaces aren't bridged together by default either.)  I.e. after boot,
> each of the switch ports behaves as if it's independent.
>
>
> > A normal ethernet host DST address would be looked up by
> > the switch HW and sent to the appropriate port.
>
> In current upstream kernels, if you in fact bridge all switch ports
> together using Linux bridging, this address lookup will be done by the
> Linux bridging code.

Yes, I am getting there mentally. I just have a hard time letting go of
viewing the HW switch as an external entity :)

[SNIP]

>
> > Once I create a linux bridge device and add the virtual I/Fs, one
> > enables the bridge function.
>
> Yes and no.  Right now there is no hardware switch offload code in the
> upstream kernel, so all bridging will still be done in software.  You
> will need something along the lines of the patch I pointed you to to
> enable hardware bridging.
>
>
> > One drawback with that is that you kill the bridge when you reboot
> > linux.
>
> With the hardware bridging patch, hardware bridging will continue if
> you don't break down your br0 interface before rebooting.  (Of course,
> your board might still have a hardware reset line that resets the
> switch when the CPU resets.)

hmm, one will have to recreate the exact config in several steps(create br0, add each
I/F etc.). I guess if done carefully one can avoid disturbing the switch.

>
> > > > > > Now I want to add STP/RSTP to the switch. How would one do that?
> > > > >
> > > > > First, you'll want the hardware bridging patches that I posted to
> > > > > netdev@ a while back, e.g.:
> > > > >
> > > > >    http://patchwork.ozlabs.org/patch/16578/
> > > >
> > > > I see, will have to study this a bit closer. One question though,
> > > > does this disable MAC learning in the linux bridge?
> > >
> > > No, why should it?
> >
> > Doesn't the HW switch handle all MAC leaning? Why duplicate
> > this in the SW bridge?
> > I figured the HW switch would offload the SW bridge this task.
>
> Imagine the case where you bridge lan1, lan2 (both on the switch chip)
> into br0, together with wlan0 (which is not on the switch chip).
>
> Now a packet is sent out of br0.  Should it be sent to wlan0 or to the
> switch chip?  How will you make this decision without an address database
> on the Linux side?

True, in this case you need it, but for only HW switch I/Fs you don't
need it and there can be several hundreds of MAC addresses passing
trough the HW switch. It would be nice if one didn't need to pass
all those up to the SW bridge, especially if you have a small embedded
CPU.

>
>
> > > > Do you have any idea how to do DSA on a Broadcom switch?
> > >
> > > I have no idea.  When I originally submitted the DSA code for merging,
> > > I contacted Broadcom people about adding support for Broadcom switch
> > > chips to it, but I never heard back from them.
> >
> > OK. With DSA, how does one configure VLANs, policing and parameters in the
> > HW switch that don't map or exist in the linux bridge?
>
> The idea is to use existing kernel interface for this as much as
> possible.  So e.g. if you do:
>
>    vconfig add lan1 123
>    vconfig add lan2 123
>    brctl addbr br123
>    brctl addif br123 lan1.123
>    brctl addif br123 lan2.123
>
> Then the DSA code (or some userspace netlink listener helper, or some
> combination of both) should ideally also detect that VLAN 123 on
> interfaces lan1 and lan2 are to be bridged together, and program the
> switch chip accordingly.  I think all VLAN configurations that at least
> the Marvell hardware supports can be expressed this way.

Yes, but I image that this breaks down when you want to do something a bit more
advanced. For example I don't think linux VLANs supports "shared VLAN learning"(SVL)
and to configure a HW switch to do SVL one would first have to impl.
that in Linux VLAN and then add the DSA code to get the config to the switch.

Not sure how one would express whether VLAN tags should be stripped off or not when
egressing the HW switch's physical port.

Furthermore, suppose one have a big HW switch, 48 ports, and lots of VLANs in that
HW switch one would have to create a lot of virtual I/Fs and VLANs in linux
just to configure the HW switch. This wastes resources on the CPU.

>
> To configure things like ingress/egress rate limiting and such in the
> switch chip for which there is no Linux counterpart interface, I suppose
> some sysfs interface or so might suffice.

Yes, there are aspects of a HW switch that doesn't map into DSA currently.
Perhaps one should add some framework to support this?

     Jocke

