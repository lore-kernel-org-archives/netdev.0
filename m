From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: Distributed Switch Architecture(DSA)
Date: Fri, 18 Jun 2010 11:15:09 +0200
Message-ID: <OF68B8EEAD.B003EFE7-ONC1257746.003109DB-C1257746.0032D371@transmode.se>
References: <OF4DC5B7A3.2D318B4E-ONC1257746.00253DA6-C1257746.002714B0@transmode.se> <20100618073309.GB14513@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:36989 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758221Ab0FRJT0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jun 2010 05:19:26 -0400
In-Reply-To: <20100618073309.GB14513@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek <buytenh@wantstofly.org> wrote on 2010/06/18 09:33:09:
>
> On Fri, Jun 18, 2010 at 09:06:52AM +0200, Joakim Tjernlund wrote:
>
> > I am trying to wrap my head around DSA and I need some help.
> >
> > Assume the example from Lennert:
> >
> >        +-----------+       +-----------+
> >        |           | RGMII |           |
> >        |           +-------+           +------ 1000baseT MDI ("WAN")
> >        |           |       |  6-port   +------ 1000baseT MDI ("LAN1")
> >        |    CPU    |       |  ethernet +------ 1000baseT MDI ("LAN2")
> >        |           |MIImgmt|  switch   +------ 1000baseT MDI ("LAN3")
> >        |           +-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
> >        |           |       |           |
> >        +-----------+       +-----------+
> >
> > If I understand this correctly I get at least 5 virtual I/Fs corresponding
> > to WAN, LAN1-4, but how is the RGMII I/F modelled?
>
> The RGMII interface is just the interface that your "real" network
> driver exports.  In the case of the Kirkwood 6281 A0 Reference Design
> (which I developed this code on), that would be eth0.  After the DSA
> driver is instantiated, you don't send or receive over eth0 directly
> anymore -- eth0 becomes purely a transport for DSA-tagged packets.

hmm, but how do I send normal pkgs form the CPU to the switch then?
I envision I would get some interface in the CPU I can set an IP address
on and use as a normal I/F which would be switched by the HW switch to
the appropriate port.

>
>
> > I guess I will have one "real" ethX I/F which maps to RGMII but do I
> > get one virtual I/F too?
>
> You get a virtual interface for each of the ports on the switch (that
> are not CPU or inter-switch ports), i.e. all ports on the right of the
> diagram -- wan, lan1, lan2, lan3, lan4.  These interfaces are created
> by net/dsa/slave.c and are called DSA interfaces or slave interfaces.
>
>
> > What use are these virtual I/Fs? Just to read status from the
> > corresponding ports?
>
> That's one of the purposes, yes.  There's a polling routine that
> periodically checks the status of each of the ports on the switch (via
> the MII management interface) and feeds back that status to the virtual
> interfaces.  I.e. if you plug a cable into lan3, you'll see a syslog
> message about the link on the virtual interface lan3 having come up,
> with the link speed, etc.
>
>
> > Can one TX and RX network pkgs over these I/Fs too?
>
> Sure -- that's the whole point.

TX:ing pkgs on such virtual I/F would go directly to the port, bypassing
normal switching?
What about RX? What decides which pkg to route through the switch and
which pgk to send up to the virtual I/F?

>
>
> > Now I want to add STP/RSTP to the switch. How would one do that?
>
> First, you'll want the hardware bridging patches that I posted to
> netdev@ a while back, e.g.:
>
>    http://patchwork.ozlabs.org/patch/16578/

I see, will have to study this a bit closer. One question though,
does this disable MAC learning in the linux bridge?

Do you have any idea how to do DSA on a Broadcom switch?
The control plane is an attached with PCI and has a big
user space lib/apps to manage the switch.

>
> They aren't in upstream-mergeable form in their current form, but they
> do the job.  These will propagate brctl addif/delif calls into the switch
> chip, so that switching between those ports will be done in hardware.
>
> Now if all you want is regular STP, with that patch you'll be done --
> the ->bridge_set_stp_state() hook propagates the spanning tree state of
> each of the DSA virtual interfaces into the switch chip automatically.
>
> If you want to use a userspace STP implementation, you'll just have to
> make sure that STP state (listening/learning/blocking/forwarding/etc) is
> correctly propagated to the switch chip similarly to how it's done in the
> patch.
>
> (Ideally, these patches should be reworked to receive bridge configuration
> and port status changes via netlink.  Unfortunately, I was asked to return
> all my Marvell hardware when I left Marvell, so someone else will have to
> do this work.)
>

