From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Distributed Switch Architecture(DSA)
Date: Fri, 18 Jun 2010 09:33:09 +0200
Message-ID: <20100618073309.GB14513@mail.wantstofly.org>
References: <OF4DC5B7A3.2D318B4E-ONC1257746.00253DA6-C1257746.002714B0@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:49440 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754121Ab0FRHdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 03:33:13 -0400
Content-Disposition: inline
In-Reply-To: <OF4DC5B7A3.2D318B4E-ONC1257746.00253DA6-C1257746.002714B0@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 18, 2010 at 09:06:52AM +0200, Joakim Tjernlund wrote:

> I am trying to wrap my head around DSA and I need some help.
> 
> Assume the example from Lennert:
> 
> 		 +-----------+       +-----------+
> 		 |           | RGMII |           |
> 		 |           +-------+           +------ 1000baseT MDI ("WAN")
> 		 |           |       |  6-port   +------ 1000baseT MDI ("LAN1")
> 		 |    CPU    |       |  ethernet +------ 1000baseT MDI ("LAN2")
> 		 |           |MIImgmt|  switch   +------ 1000baseT MDI ("LAN3")
> 		 |           +-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
> 		 |           |       |           |
> 		 +-----------+       +-----------+
> 
> If I understand this correctly I get at least 5 virtual I/Fs corresponding
> to WAN, LAN1-4, but how is the RGMII I/F modelled?

The RGMII interface is just the interface that your "real" network
driver exports.  In the case of the Kirkwood 6281 A0 Reference Design
(which I developed this code on), that would be eth0.  After the DSA
driver is instantiated, you don't send or receive over eth0 directly
anymore -- eth0 becomes purely a transport for DSA-tagged packets.


> I guess I will have one "real" ethX I/F which maps to RGMII but do I
> get one virtual I/F too?

You get a virtual interface for each of the ports on the switch (that
are not CPU or inter-switch ports), i.e. all ports on the right of the
diagram -- wan, lan1, lan2, lan3, lan4.  These interfaces are created
by net/dsa/slave.c and are called DSA interfaces or slave interfaces.


> What use are these virtual I/Fs? Just to read status from the
> corresponding ports?

That's one of the purposes, yes.  There's a polling routine that
periodically checks the status of each of the ports on the switch (via
the MII management interface) and feeds back that status to the virtual
interfaces.  I.e. if you plug a cable into lan3, you'll see a syslog
message about the link on the virtual interface lan3 having come up,
with the link speed, etc.


> Can one TX and RX network pkgs over these I/Fs too?

Sure -- that's the whole point.


> Now I want to add STP/RSTP to the switch. How would one do that?

First, you'll want the hardware bridging patches that I posted to
netdev@ a while back, e.g.:

	http://patchwork.ozlabs.org/patch/16578/

They aren't in upstream-mergeable form in their current form, but they
do the job.  These will propagate brctl addif/delif calls into the switch
chip, so that switching between those ports will be done in hardware.

Now if all you want is regular STP, with that patch you'll be done --
the ->bridge_set_stp_state() hook propagates the spanning tree state of
each of the DSA virtual interfaces into the switch chip automatically.

If you want to use a userspace STP implementation, you'll just have to
make sure that STP state (listening/learning/blocking/forwarding/etc) is
correctly propagated to the switch chip similarly to how it's done in the
patch.

(Ideally, these patches should be reworked to receive bridge configuration
and port status changes via netlink.  Unfortunately, I was asked to return
all my Marvell hardware when I left Marvell, so someone else will have to
do this work.)
