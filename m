From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [RFC 2/2] xen-netback: disable multicast and use a random hw
 MAC address
Date: Wed, 12 Feb 2014 11:15:08 +0000
Message-ID: <1392203708.13563.50.camel@kazak.uk.xensource.com>
References: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
	 <1392071391-13215-3-git-send-email-mcgrof@do-not-panic.com>
	 <1392108205.22033.16.camel@dagon.hellion.org.uk>
	 <CAB=NE6Vu=khpj_3J7r-u8DFkhyC-RgLikNFtOU-WO7te_4HMCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>, <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6Vu=khpj_3J7r-u8DFkhyC-RgLikNFtOU-WO7te_4HMCw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-02-11 at 13:53 -0800, Luis R. Rodriguez wrote:
> Cc'ing kvm folks as they may have a shared interest on the shared
> physical case with the bridge (non NAT).
> 
> On Tue, Feb 11, 2014 at 12:43 AM, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> > On Mon, 2014-02-10 at 14:29 -0800, Luis R. Rodriguez wrote:
> >> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> >>
> >> Although the xen-netback interfaces do not participate in the
> >> link as a typical Ethernet device interfaces for them are
> >> still required under the current archtitecture. IPv6 addresses
> >> do not need to be created or assigned on the xen-netback interfaces
> >> however, even if the frontend devices do need them, so clear the
> >> multicast flag to ensure the net core does not initiate IPv6
> >> Stateless Address Autoconfiguration.
> >
> > How does disabling SAA flow from the absence of multicast?
> 
> See patch 1 in this series [0], but I explain the issue I see with
> this on the cover letter [1].

Oop, I felt like I'd missed some context. Thanks for pointing out that
it was right under my nose.

> In summary the RFCs on IPv6 make it
> clear you need multicast for Stateless address autoconfiguration
> (SLAAC is the preferred acronym) and DAD,

That seems reasonable, but I think is the opposite to what I was trying
to get at.

Why is it not possible to disable SLAAC and/or DAD even if multicast is
present?

IOW -- enabling/disabling multicast seems to me to be an odd proxy for
disabling SLAAC or DAD and AIUI your patch fixes the opposite case,
which is to avoid SLAAC and DAD on interfaces which don't do multicast
(which makes sense since those protocols involve multicast).

>  however the net core has not
> made this a requirement, and hence the patch. The caveat which I
> address on the cover letter needs to be seriously considered though.
> 
> [0] http://marc.info/?l=linux-netdev&m=139207142110535&w=2
> [1] http://marc.info/?l=linux-netdev&m=139207142110536&w=2
> 
> > Surely these should be controlled logically independently even if there is some
> > notional linkage.
> 
> When a node hops on a network it will query its network by sending a
> router solicitation multicast request for its configuration
> parameters, the router can respond with router advertisements to
> disable SLAAC.

Surely it should be possible for an interface to be explicitly not ipv6
enabled, in which case it doesn't want to do any solicitation at all.

> Apart from that we have no other means to disable SLAAC neatly, and as
> I gather that would be counter to the IPv6 RFCs anyway, and that makes
> sense.

In your[0] post you say:
        it should be noted that RFC4682 Section 5.4
        makes it clear that DAD *MUST* be performed on all unicast
        addresses prior to assigning them to an interface

is that what you mean by counter to the RFCs?

In my reading this "must do DAD" requirement only comes into affect if
you are trying to assign a unicast address to an interface. It should be
possible to simply not do that for an interface.

> > Can SAA not be disabled directly?
> 
> Nope. The ipv6 core assumes all device want ipv6

IMHO it is entirely reasonable for an admin to desire that an interface
has nothing at all to do with IPv6. At which point all of the
requirements for multicast which flow from enabling IPv6 disappear.

> >>  since using this can create an issue if a user
> >> decides to enable multicast on the backend interfaces
> >
> > Please explain what this issue is.
> 
> I explained this on the cover letter but should have elaborated more
> here. The *known* and *reported* issue is that xen-backend interfaces
> can end up  SLAAC and you'd obviously end up in some situations where
> the MAC address and IP address clash, despite the architecture of IPv6
> to randomize time requests for neighbor solicitations, and DAD.
> Ultimately a series of services can end up filling your log messages
> with tons of warnings.

Right, this makes sense, but it seems like the solution should be to
stop SLAAC from happening directly and not by playing tricks with
multicast that happen to have the side effect of disabling SLAAC.

> Another not reported issue, but I suspect critical and it can bite
> both xen and kvm in the ass is described on Appendex A on RFC 4862 [2]
> which considers the issues of getting duplicates of packets on the
> same link with the same link layer address. I think to address that we
> can also consider dev->type into all the different cases.

We should never actually be generating any traffic with this address
FWIW, all the generated traffic will have the guest's actual MAC. (at
least in the bridging case, perhaps with with routing or NAT things are
different, but I think in that case the traffic would appear to come
from the hosts outgoing interface, not the vif device)

> My preference, rather than trying to simply disable ipv6 is actually
> seeing how xen-netback interfaces (and kvm TAP topology) can be
> simplified further). As I see it there is tons of code which could
> trigger being used on these xen-netback interfaces (and TAP for kvm)
> which is simply not needed for the use case of just doing sending data
> back and forth between host and guest: ipv6 is not needed at all, and
> I tried to test removing ipv4, but ran into issues.

Bridging is not the only way to provide VM network connectivity. It
should also be possible to do routing and even NAT by configuring
appropriate p2p links and routing tables in the host. For that to work I
think the tap and vif devices do need some sort of IPv[46] capability,
so you can't just nuke that stuff completely. (Maybe/likely it also
requires them to have a sensible MAC address, I'm not sure).

> [2] http://tools.ietf.org/html/rfc4862#appendix-A
> [3[ https://gitorious.org/opensuse/kernel-source/source/8e16582178a29b03e850468004a47e7be5ed3005:patches.xen/ipv6-no-autoconf
> 
> > Also how can a user enable multicast on the b/e?
> 
> ip set multicast on dev <devname>
> ip set multicast off dev <devname>
> 
> > AFAIK only Solaris ever
> > implemented the m/c bits of the Xen PV network protocol (not that I
> > wouldn't welcome attempts to add it to other platforms)
> 
> Do you mean kernel configuration multicast ? Or networking ?

I meant the PV protocol extension which allows guests (netfront) to
register to receive multicast frames across the PV ring -- i.e. for
multicast to work from the guests PoV.

(maybe that was just an optimisation though and the default is to flood
everything, it was a long time ago)

Ian.
