From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Distributed Switch Architecture(DSA)
Date: Fri, 18 Jun 2010 11:59:23 +0200
Message-ID: <20100618095923.GC14513@mail.wantstofly.org>
References: <OF4DC5B7A3.2D318B4E-ONC1257746.00253DA6-C1257746.002714B0@transmode.se> <20100618073309.GB14513@mail.wantstofly.org> <OF68B8EEAD.B003EFE7-ONC1257746.003109DB-C1257746.0032D371@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:58267 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046Ab0FRJ71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 05:59:27 -0400
Content-Disposition: inline
In-Reply-To: <OF68B8EEAD.B003EFE7-ONC1257746.003109DB-C1257746.0032D371@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 18, 2010 at 11:15:09AM +0200, Joakim Tjernlund wrote:

> > > I am trying to wrap my head around DSA and I need some help.
> > >
> > > Assume the example from Lennert:
> > >
> > >        +-----------+       +-----------+
> > >        |           | RGMII |           |
> > >        |           +-------+           +------ 1000baseT MDI ("WAN")
> > >        |           |       |  6-port   +------ 1000baseT MDI ("LAN1")
> > >        |    CPU    |       |  ethernet +------ 1000baseT MDI ("LAN2")
> > >        |           |MIImgmt|  switch   +------ 1000baseT MDI ("LAN3")
> > >        |           +-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
> > >        |           |       |           |
> > >        +-----------+       +-----------+
> > >
> > > If I understand this correctly I get at least 5 virtual I/Fs corresponding
> > > to WAN, LAN1-4, but how is the RGMII I/F modelled?
> >
> > The RGMII interface is just the interface that your "real" network
> > driver exports.  In the case of the Kirkwood 6281 A0 Reference Design
> > (which I developed this code on), that would be eth0.  After the DSA
> > driver is instantiated, you don't send or receive over eth0 directly
> > anymore -- eth0 becomes purely a transport for DSA-tagged packets.
> 
> hmm, but how do I send normal pkgs form the CPU to the switch then?

Define what you mean by 'normal pkgs'.


> I envision I would get some interface in the CPU I can set an IP address
> on and use as a normal I/F which would be switched by the HW switch to
> the appropriate port.

Yes, these are the DSA/slave interfaces created by net/dsa/slave.c.
You are free to attach IP addresses to the wan/lanX interfaces, and
things will work as you'd expect them to.


> > > I guess I will have one "real" ethX I/F which maps to RGMII but do I
> > > get one virtual I/F too?
> >
> > You get a virtual interface for each of the ports on the switch (that
> > are not CPU or inter-switch ports), i.e. all ports on the right of the
> > diagram -- wan, lan1, lan2, lan3, lan4.  These interfaces are created
> > by net/dsa/slave.c and are called DSA interfaces or slave interfaces.
> >
> >
> > > What use are these virtual I/Fs? Just to read status from the
> > > corresponding ports?
> >
> > That's one of the purposes, yes.  There's a polling routine that
> > periodically checks the status of each of the ports on the switch (via
> > the MII management interface) and feeds back that status to the virtual
> > interfaces.  I.e. if you plug a cable into lan3, you'll see a syslog
> > message about the link on the virtual interface lan3 having come up,
> > with the link speed, etc.
> >
> >
> > > Can one TX and RX network pkgs over these I/Fs too?
> >
> > Sure -- that's the whole point.
> 
> TX:ing pkgs on such virtual I/F would go directly to the port, bypassing
> normal switching?

Define what you mean by 'normal switching'.


> What about RX? What decides which pkg to route through the switch and
> which pgk to send up to the virtual I/F?

By default, which is until you enable bridging on some subset of the
ports, all ports have their own address database, and all received
packets are passed directly up to the CPU, where the DSA code will
then make those packets be received on the DSA slave interfaces.


> > > Now I want to add STP/RSTP to the switch. How would one do that?
> >
> > First, you'll want the hardware bridging patches that I posted to
> > netdev@ a while back, e.g.:
> >
> >    http://patchwork.ozlabs.org/patch/16578/
> 
> I see, will have to study this a bit closer. One question though,
> does this disable MAC learning in the linux bridge?

No, why should it?


> Do you have any idea how to do DSA on a Broadcom switch?

I have no idea.  When I originally submitted the DSA code for merging,
I contacted Broadcom people about adding support for Broadcom switch
chips to it, but I never heard back from them.
