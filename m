From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC,PATCHv2 0/6] support for DSA hardware ethernet switch chips
Date: Mon, 29 Sep 2008 12:09:16 +0200
Message-ID: <20080929100916.GD26097@xi.wantstofly.org>
References: <20080929023728.GF21560@xi.wantstofly.org> <1222679386.23279.45.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@cam.org>, netdev@vger.kernel.org
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:46362 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbYI2KJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 06:09:17 -0400
Content-Disposition: inline
In-Reply-To: <1222679386.23279.45.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 11:09:46AM +0200, Maxime Bizon wrote:

> Hi Lennert,

Hi Maxime,


> > This patch set adds support for hardware ethernet switches that use
> > the DSA (Distributed Switch Architecture) protocol.  These chips are
> > typically used in access points and DSL routers and such, where they
> > sit between the CPU's ethernet port and the external ethernet ports
> > on the box (typically 4 LAN ports and 1 WAN port).
> 
> Nice and clean work !

Thanks. :)


> I have once tried to make a driver for Marvell switches, but I could
> never find a satisfying userspace/kernel split.

It took me quite some time to figure it out as well, and the version
I posted is the third rewrite or so before I was happy with it.  I
think this version is the best solution in the end.

[ I'm interested in tester feedback -- if you can give this a quick
  try on your board(s), that would be much appreciated. :-) ]


> I thought a kernel solution would be painful, because it would require a
> bunch of private ioctl to handle the switch configuration (vtu/atu).
> 
> So I just did all the switch management from userland through MII ioctl
> with a dsdt like library. I then found myself screwed when I tried to
> implement spanning tree / port mirroring, for which DSA is a must, and
> obviously a kernel support is needed if you want to keep your CPU port
> usable.
> 
> I hacked it with SOCK_PACKET, and a bad hack in the kernel core to
> restore the packet header... I thought exposing the switch ports as
> kernel netdevice would be good, but was unsure how much support I should
> put in kernel.
> 
> 
> Then I saw your patch; which takes a completely different approach.
> 
> Switch driver is fully in kernel, which clearly have some benefits:
>  - CPU port is auto-configured, NFS root works out of the box
>  - link status of other ports can be fetched with "standard" ethtool

Yeah.  In my view, everything just needs to be as transparent as
possible, with no application changes needed.  I didn't want to
introduce a model where applications even need to be aware of what's
going on.


> But you end up with a "fixed" configuration in the kernel, and there are
> things you usually want to set/change at runtime like VLAN port mapping,
> ATU static entry. Also you may want to fetch the ATU dynamic table, etc.

I totally agree that there should be no fixed configuration in the
kernel as to which ports are in which VLANs or other such policy
decisions, and I think my model allows for this.

IMHO, there needs to be no difference between configuring a software
bridge and a hardware bridge.

That means that VLAN port mapping needs to be handled by snooping the
configuration of the linux software bridging stack.  I.e. when someone
does 'brctl addif br0 lan1; brctl addif br0 lan2', that needs to signal
the switch driver that ports 1 and 2 should from this point on share
address databases and be able to send packets to each other directly.
(And when someone then runs 'tcpdump -i lan1', it is debatable whether
that needs to enable Ingress/Egress Monitor Mode in the switch chip
so that you'll see packets going into/out of port 1 even if they are
bridged in hardware.)

Static entries in the address database should be handled the same, IMHO
-- use the mechanism that exists for software bridging (there currently
isn't any, as far as I know, but that can be fixed) and extend that to
transparently work with hardware bridging.  So when you implement for
for example IGMP snooping, it will automatically work for both software
bridging and hardware bridging, with no modifications needed.

There has been talk about a bridge netlink configuration interface.
Such a thing would be ideal for hooking into from the DSA driver (or
some userland stub, whatever turns out to be better).


> If your intent is to keep this part in userspace, it's unclear to me
> how much user access is still possible to the switch registers, MII
> ioctl is still there, but how can you be sure you don't conflict with
> the kernel driver (switch reset, PPU polling, etc).

We'll have to see what's best here.

In any case, there should be _no_ knowledge of switch register layouts
in userspace.  If we do need to handle this part from userspace, then
there needs to be a unified sysfs interface or something like that that
abstracts away the differences between each of the individual switch
chip families.

(Note that my goal is that other brands and models of switch chips should
be supportable in this framework, which rules out putting any knowledge
of Marvell-specific things in files other than net/dsa/mv88*.c.)

Thanks for your feedback!


cheers,
Lennert
