From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 09:18:42 -0700
Message-ID: <20100421161842.GB25928@x200.localdomain>
References: <C7F354F4.29CC8%scofeldm@cisco.com>
 <201004211326.00974.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, chrisw@redhat.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20656 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755396Ab0DUQSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 12:18:48 -0400
Content-Disposition: inline
In-Reply-To: <201004211326.00974.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Arnd Bergmann (arnd@arndb.de) wrote:
> On Tuesday 20 April 2010, Scott Feldman wrote:
> > On 4/20/10 6:48 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:
> > > Also, do you expect your interface to be supported by dcbd/lldpad,
> > > or is there a good reason to create a new tool for iovnl?
> > 
> > Lldpad supporting this interface would seem right, for those cases where
> > lldpad is responsible for configuring the netdev.
> 
> I believe we meant different things here, because I misunderstood the
> intention of the code. My question was whether lldpad would send the
> netlink messages to iovnl, but from what you and Chris write, the
> real idea was that both lldpad and kernel/iovnl can receive the
> same messages, right?

Correct.  An example set of steps for initiating host to switch
negotiation and subsequently launching a VM would be (expect user below
to be a mgmt tool like libvirt):

1) user sends netlink message w/ relevant host interface and port profile id
2) recipient picks this up (enic, lldpad, whatever)
3) recipient does negotiation w/ adjacent switch
4) user creates macvtap associated w/ relevant host interface
5) user launches guest

> > >> + * @IOV_ATTR_CLIENT_NAME: client name (NLA_NUL_STRING)
> > >> + * @IOV_ATTR_HOST_UUID: host UUID (NLA_NUL_STRING)
> > > 
> > > Can you elaborate more on what these do? Who is the 'client' and the 'host'
> > > in this case, and why do you need to identify them?
> > 
> > Those are optional and useful, for example, by the network mgmt tool for
> > presenting a view such as:
> > 
> >     - blade 1/2                     // know by host uuid
> >         - vm-rhel5-eth0             // client name
> >             - port-profile: xyz
> > 
> > Something like that.
> 
> Hmm, but how do they get from the device driver to the the network
> management tool then? Also, these are similar to the attributes
> that are passed in the 802.1Qbg VDP protocol, but not compatible.
> If the idea is use the same netlink protocol for both your internal
> representation and for the standard based protocol, I think we should
> make them compatible.

Indeed, that's my expectation.

> Instead of a string identifying the port profile, this needs to pass
> a four byte field for a VSI type (3 bytes) and VSI manager ID (1 byte).

I think we just need a u8 array, 4 bytes for VDP, some maxlen that is
at least as large as enic expects.

> There is also a UUID in VDP, but it identifies the guest, not the host,
> so this is really confusing.

Yes, I had same confusion.  I expected guest, enic wants to send host as
well.

> VDP also needs a list of MAC addresses and VLAN IDs (normally only
> one of each), but that would be separate from what you tell the adapter,
> see below: 
> 
> > >> + * @IOV_ATTR_MAC_ADDR: device station MAC address (NLA_U8[6])
> > > 
> > > Just one mac address? What happens if we want to assign multiple mac
> > > addresses to the VF later? Also, how is this defined specifically?
> > > Will a SIOCSIFHWADDR with a different MAC address on the VF fail
> > > later, or is this just the default value?
> > 
> > Depends on how the VF wants to handle this.  For our use-case with enic we
> > only need the port-profile op so I'm not sure what the best design is for
> > mac+vlan on a VF.  Looking for advise from folks like yourself.  If it's not
> > needed, let's scratch it.
> 
> In order to make VEPA work, it's absolutely required to impose a hard limit
> on what MAC+VLAN IDs are visible to the VF, because the switch identifies
> the guest by those and forwards any frames to/from that address according
> to the VSI type.
> 
> However, I feel that we should strictly separate the steps of configuring
> the adapter from talking to the switch. When we do the VDP association
> in user land, we still need to set up the VLAN and MAC configuration for
> the VF through a kernel interface. If we ignore the port profile stuff
> for a moment, your netlink interface looks like a good fit for that.
> 
> Since it seems what you really want to do is to do the exchange with the
> switch from here, maybe the hardware configuration part should be moved
> the DCB interface?

I suppose this would work  (although it's a bit odd being out of scope
of DCB spec).  I don't expect mgmt app to care about the implementation
specifics of an adapter, so it will always send this and iovnl message
too.  All as part of same setup.

thanks,
-chris
