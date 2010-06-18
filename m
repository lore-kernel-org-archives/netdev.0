From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Distributed Switch Architecture(DSA)
Date: Fri, 18 Jun 2010 14:12:23 +0200
Message-ID: <20100618121223.GH14513@mail.wantstofly.org>
References: <OF4DC5B7A3.2D318B4E-ONC1257746.00253DA6-C1257746.002714B0@transmode.se> <20100618073309.GB14513@mail.wantstofly.org> <OF68B8EEAD.B003EFE7-ONC1257746.003109DB-C1257746.0032D371@transmode.se> <20100618095923.GC14513@mail.wantstofly.org> <OF8E185B56.9B8AB610-ONC1257746.003A78DF-C1257746.003D4C6C@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:46089 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761086Ab0FRMM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 08:12:27 -0400
Content-Disposition: inline
In-Reply-To: <OF8E185B56.9B8AB610-ONC1257746.003A78DF-C1257746.003D4C6C@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 18, 2010 at 01:09:32PM +0200, Joakim Tjernlund wrote:

> > > > > I am trying to wrap my head around DSA and I need some help.
> > > > >
> > > > > Assume the example from Lennert:
> > > > >
> > > > >        +-----------+       +-----------+
> > > > >        |           | RGMII |           |
> > > > >        |           +-------+           +------ 1000baseT MDI ("WAN")
> > > > >        |           |       |  6-port   +------ 1000baseT MDI ("LAN1")
> > > > >        |    CPU    |       |  ethernet +------ 1000baseT MDI ("LAN2")
> > > > >        |           |MIImgmt|  switch   +------ 1000baseT MDI ("LAN3")
> > > > >        |           +-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
> > > > >        |           |       |           |
> > > > >        +-----------+       +-----------+
> > > > >
> > > > > If I understand this correctly I get at least 5 virtual I/Fs corresponding
> > > > > to WAN, LAN1-4, but how is the RGMII I/F modelled?
> > > >
> > > > The RGMII interface is just the interface that your "real" network
> > > > driver exports.  In the case of the Kirkwood 6281 A0 Reference Design
> > > > (which I developed this code on), that would be eth0.  After the DSA
> > > > driver is instantiated, you don't send or receive over eth0 directly
> > > > anymore -- eth0 becomes purely a transport for DSA-tagged packets.
> > >
> > > hmm, but how do I send normal pkgs form the CPU to the switch then?
> >
> > Define what you mean by 'normal pkgs'.
> 
> An ethernet broadcast pkg flooded onto all ports.

This statement assumes that all ports have been configured into a
bridge, which is not the default case.  (And why would it be?  Having each
port in the same VLAN/subnet is only one of the many possible ways of
configuring your switch ports -- and regular (non-DSA) Linux network
interfaces aren't bridged together by default either.)  I.e. after boot,
each of the switch ports behaves as if it's independent.


> A normal ethernet host DST address would be looked up by
> the switch HW and sent to the appropriate port.

In current upstream kernels, if you in fact bridge all switch ports
together using Linux bridging, this address lookup will be done by the
Linux bridging code.


> > > I envision I would get some interface in the CPU I can set an IP address
> > > on and use as a normal I/F which would be switched by the HW switch to
> > > the appropriate port.
> >
> > Yes, these are the DSA/slave interfaces created by net/dsa/slave.c.
> > You are free to attach IP addresses to the wan/lanX interfaces, and
> > things will work as you'd expect them to.
> 
> Not sure what to expect here actually.

That the DSA interfaces will behave just like non-DSA Linux network
interfaces.


> > > What about RX? What decides which pkg to route through the switch and
> > > which pgk to send up to the virtual I/F?
> >
> > By default, which is until you enable bridging on some subset of the
> > ports, all ports have their own address database, and all received
> > packets are passed directly up to the CPU, where the DSA code will
> > then make those packets be received on the DSA slave interfaces.
> 
> ah, so until I enable bridging, all ports are viewed as a separate
> network I/F?

Yes.  The original DSA commit message says as much:

    The switch driver presents each port on the switch as a separate
    network interface to Linux, [...]


> Once I create a linux bridge device and add the virtual I/Fs, one
> enables the bridge function.

Yes and no.  Right now there is no hardware switch offload code in the
upstream kernel, so all bridging will still be done in software.  You
will need something along the lines of the patch I pointed you to to
enable hardware bridging.


> One drawback with that is that you kill the bridge when you reboot
> linux.

With the hardware bridging patch, hardware bridging will continue if
you don't break down your br0 interface before rebooting.  (Of course,
your board might still have a hardware reset line that resets the
switch when the CPU resets.)


> > > > > Now I want to add STP/RSTP to the switch. How would one do that?
> > > >
> > > > First, you'll want the hardware bridging patches that I posted to
> > > > netdev@ a while back, e.g.:
> > > >
> > > >    http://patchwork.ozlabs.org/patch/16578/
> > >
> > > I see, will have to study this a bit closer. One question though,
> > > does this disable MAC learning in the linux bridge?
> >
> > No, why should it?
> 
> Doesn't the HW switch handle all MAC leaning? Why duplicate
> this in the SW bridge?
> I figured the HW switch would offload the SW bridge this task.

Imagine the case where you bridge lan1, lan2 (both on the switch chip)
into br0, together with wlan0 (which is not on the switch chip).

Now a packet is sent out of br0.  Should it be sent to wlan0 or to the
switch chip?  How will you make this decision without an address database
on the Linux side?


> > > Do you have any idea how to do DSA on a Broadcom switch?
> >
> > I have no idea.  When I originally submitted the DSA code for merging,
> > I contacted Broadcom people about adding support for Broadcom switch
> > chips to it, but I never heard back from them.
> 
> OK. With DSA, how does one configure VLANs, policing and parameters in the
> HW switch that don't map or exist in the linux bridge?

The idea is to use existing kernel interface for this as much as
possible.  So e.g. if you do:

	vconfig add lan1 123
	vconfig add lan2 123
	brctl addbr br123
	brctl addif br123 lan1.123
	brctl addif br123 lan2.123

Then the DSA code (or some userspace netlink listener helper, or some
combination of both) should ideally also detect that VLAN 123 on
interfaces lan1 and lan2 are to be bridged together, and program the
switch chip accordingly.  I think all VLAN configurations that at least
the Marvell hardware supports can be expressed this way.

To configure things like ingress/egress rate limiting and such in the
switch chip for which there is no Linux counterpart interface, I suppose
some sysfs interface or so might suffice.
