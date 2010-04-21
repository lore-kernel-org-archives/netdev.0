From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 19:52:26 +0200
Message-ID: <201004211952.29145.arnd@arndb.de>
References: <C7F354F4.29CC8%scofeldm@cisco.com> <201004211326.00974.arnd@arndb.de> <20100421161842.GB25928@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:56510 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756033Ab0DURyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 13:54:15 -0400
In-Reply-To: <20100421161842.GB25928@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 21 April 2010, Chris Wright wrote:
> * Arnd Bergmann (arnd@arndb.de) wrote:
> > On Tuesday 20 April 2010, Scott Feldman wrote:
> > I believe we meant different things here, because I misunderstood the
> > intention of the code. My question was whether lldpad would send the
> > netlink messages to iovnl, but from what you and Chris write, the
> > real idea was that both lldpad and kernel/iovnl can receive the
> > same messages, right?
> 
> Correct.  An example set of steps for initiating host to switch
> negotiation and subsequently launching a VM would be (expect user below
> to be a mgmt tool like libvirt):
> 
> 1) user sends netlink message w/ relevant host interface and port profile id
> 2) recipient picks this up (enic, lldpad, whatever)
> 3) recipient does negotiation w/ adjacent switch
> 4) user creates macvtap associated w/ relevant host interface
> 5) user launches guest

I'd move point 4 before 1, but otherwise it makes sense and it would still
work either way.

> > If the idea is use the same netlink protocol for both your internal
> > representation and for the standard based protocol, I think we should
> > make them compatible.
> 
> Indeed, that's my expectation.
>
> [...]
>
> > Instead of a string identifying the port profile, this needs to pass
> > a four byte field for a VSI type (3 bytes) and VSI manager ID (1 byte).
> 
> I think we just need a u8 array, 4 bytes for VDP, some maxlen that is
> at least as large as enic expects.
> 
> > There is also a UUID in VDP, but it identifies the guest, not the host,
> > so this is really confusing.
> 
> Yes, I had same confusion.  I expected guest, enic wants to send host as
> well.

So given all these differences, how compatible can we make them?

With the current definition, most of fields are at least slightly
different. The differences seem to stem mostly from the fact that
Cisco switches use a nonstandard protocol, rather than the difference
between the firmware and userland implementations of the protocol,
and of course we shouldn't confuse the two.

> > In order to make VEPA work, it's absolutely required to impose a hard limit
> > on what MAC+VLAN IDs are visible to the VF, because the switch identifies
> > the guest by those and forwards any frames to/from that address according
> > to the VSI type.
> > 
> > However, I feel that we should strictly separate the steps of configuring
> > the adapter from talking to the switch. When we do the VDP association
> > in user land, we still need to set up the VLAN and MAC configuration for
> > the VF through a kernel interface. If we ignore the port profile stuff
> > for a moment, your netlink interface looks like a good fit for that.
> > 
> > Since it seems what you really want to do is to do the exchange with the
> > switch from here, maybe the hardware configuration part should be moved
> > the DCB interface?
> 
> I suppose this would work  (although it's a bit odd being out of scope
> of DCB spec).

It could be anywhere, it doesn't have to be the DCB interface, but could
be anything ranging from ethtool to iplink I guess. And we should define
it in a way that works for any SR-IOV card, whether it's using Cisco's
protocol in firmware, 802.1Qbg VDP in firmware, lldpad to do VDP or
none of the above and just provides an internal switch like all the
existing NICs.

> I don't expect mgmt app to care about the implementation
> specifics of an adapter, so it will always send this and iovnl message
> too.  All as part of same setup.

Why? I really see these things as separate. Obviously a management
tool like libvirt would need to do both these things eventually, but
each of them has multiple options that can be combined in various
ways:

1. Setting up the slave device
 a) create an SR-IOV VF to assign to a guest
 b) create a macvtap device to pass to qemu or vhost
 c) attach a tap device to a bridge
 d) create a macvlan device and put it into a container
 e) create a virtual interface for a VMDq adapter

2) Registering the slave with the switch
 a) use Cisco protocol in enic firmware (see patch 2/2)
 b) use standard VDP in lldpad
 c) use reverse-engineered cisco protocol in some user tool for
    non-enic adapters.
 d) use standard VDP in firmware (hopefully this never happens)
 e) do nothing at all (as we do today)

Some of the cases can be treated identically, e.g. 1d) and 1e), or
2a) and 2c), but in general the management app needs to have some
idea of which combination it's going to set up.

	Arnd
