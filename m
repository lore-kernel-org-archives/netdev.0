From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC 2/2] xen-netback: disable multicast and use a random hw MAC address
Date: Wed, 12 Feb 2014 14:05:47 -0800
Message-ID: <CAB=NE6WFDWW1faoCYJP9zh6rPPvET+dbHxjHnGkYXtRx6z2LOQ@mail.gmail.com>
References: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
 <1392071391-13215-3-git-send-email-mcgrof@do-not-panic.com>
 <1392108205.22033.16.camel@dagon.hellion.org.uk> <CAB=NE6Vu=khpj_3J7r-u8DFkhyC-RgLikNFtOU-WO7te_4HMCw@mail.gmail.com>
 <1392203708.13563.50.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel@lists.xenproject.org,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, kvm@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:39651 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbaBLWGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:06:12 -0500
In-Reply-To: <1392203708.13563.50.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 3:15 AM, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> On Tue, 2014-02-11 at 13:53 -0800, Luis R. Rodriguez wrote:
>> Cc'ing kvm folks as they may have a shared interest on the shared
>> physical case with the bridge (non NAT).
>>
>> On Tue, Feb 11, 2014 at 12:43 AM, Ian Campbell <Ian.Campbell@citrix.com> wrote:
>> > On Mon, 2014-02-10 at 14:29 -0800, Luis R. Rodriguez wrote:
>> >> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>> >>
>> >> Although the xen-netback interfaces do not participate in the
>> >> link as a typical Ethernet device interfaces for them are
>> >> still required under the current archtitecture. IPv6 addresses
>> >> do not need to be created or assigned on the xen-netback interfaces
>> >> however, even if the frontend devices do need them, so clear the
>> >> multicast flag to ensure the net core does not initiate IPv6
>> >> Stateless Address Autoconfiguration.
>> >
>> > How does disabling SAA flow from the absence of multicast?
>>
>> See patch 1 in this series [0], but I explain the issue I see with
>> this on the cover letter [1].
>
> Oop, I felt like I'd missed some context. Thanks for pointing out that
> it was right under my nose.
>
>> In summary the RFCs on IPv6 make it
>> clear you need multicast for Stateless address autoconfiguration
>> (SLAAC is the preferred acronym) and DAD,
>
> That seems reasonable, but I think is the opposite to what I was trying
> to get at.
>
> Why is it not possible to disable SLAAC and/or DAD even if multicast is
> present?

Even if you set your IP address manually you still need to send router
solicitations using multicast, you also need to do DAD.

> IOW -- enabling/disabling multicast seems to me to be an odd proxy for
> disabling SLAAC or DAD and AIUI your patch fixes the opposite case,
> which is to avoid SLAAC and DAD on interfaces which don't do multicast
> (which makes sense since those protocols involve multicast).

Agreed :)

>>  however the net core has not
>> made this a requirement, and hence the patch. The caveat which I
>> address on the cover letter needs to be seriously considered though.
>>
>> [0] http://marc.info/?l=linux-netdev&m=139207142110535&w=2
>> [1] http://marc.info/?l=linux-netdev&m=139207142110536&w=2
>>
>> > Surely these should be controlled logically independently even if there is some
>> > notional linkage.
>>
>> When a node hops on a network it will query its network by sending a
>> router solicitation multicast request for its configuration
>> parameters, the router can respond with router advertisements to
>> disable SLAAC.
>
> Surely it should be possible for an interface to be explicitly not ipv6
> enabled, in which case it doesn't want to do any solicitation at all.

There are run time configuration options, but not net_device flags.
More on this below.

>> Apart from that we have no other means to disable SLAAC neatly, and as
>> I gather that would be counter to the IPv6 RFCs anyway, and that makes
>> sense.
>
> In your[0] post you say:
>         it should be noted that RFC4682 Section 5.4
>         makes it clear that DAD *MUST* be performed on all unicast
>         addresses prior to assigning them to an interface
>
> is that what you mean by counter to the RFCs?

Yeap.

> In my reading this "must do DAD" requirement only comes into affect if
> you are trying to assign a unicast address to an interface. It should be
> possible to simply not do that for an interface.

That is correct, why enable ipv6 then on that interfaces then? We have
the loopback for local stuff.

>> > Can SAA not be disabled directly?
>>
>> Nope. The ipv6 core assumes all device want ipv6
>
> IMHO it is entirely reasonable for an admin to desire that an interface
> has nothing at all to do with IPv6. At which point all of the
> requirements for multicast which flow from enabling IPv6 disappear.

Agreed.

>> >>  since using this can create an issue if a user
>> >> decides to enable multicast on the backend interfaces
>> >
>> > Please explain what this issue is.
>>
>> I explained this on the cover letter but should have elaborated more
>> here. The *known* and *reported* issue is that xen-backend interfaces
>> can end up  SLAAC and you'd obviously end up in some situations where
>> the MAC address and IP address clash, despite the architecture of IPv6
>> to randomize time requests for neighbor solicitations, and DAD.
>> Ultimately a series of services can end up filling your log messages
>> with tons of warnings.
>
> Right, this makes sense, but it seems like the solution should be to
> stop SLAAC from happening directly and not by playing tricks with
> multicast that happen to have the side effect of disabling SLAAC.

Agreed, however as I see it since yesterday the requirement for
multicast for IPv6 should likely become a requirement for dev->type
ether, there however is a module parameter to disable autoconf
completely though so I believe there may be some ether dev->type
devices out there with IPv6 without multicast, and while that seems
counter to the requirements on the RFCs it is something to consider.

At this point I consider the above a separate discussion (but one I'll
follow up with an RFCv2 patch), given that it seems we are in
agreement we should *consider* the ability to disable ipv6 all
together from a net_device. More on this below.

>> Another not reported issue, but I suspect critical and it can bite
>> both xen and kvm in the ass is described on Appendex A on RFC 4862 [2]
>> which considers the issues of getting duplicates of packets on the
>> same link with the same link layer address. I think to address that we
>> can also consider dev->type into all the different cases.
>
> We should never actually be generating any traffic with this address
> FWIW, all the generated traffic will have the guest's actual MAC. (at
> least in the bridging case, perhaps with with routing or NAT things are
> different, but I think in that case the traffic would appear to come
> from the hosts outgoing interface, not the vif device)

Which leads me to believe that creating a regular interface for a
backend interface seems overkill. I'm evaluating the minimal
requirements on the xen-backend case for an interface and believe this
can likely be shared with as a type of interface with kvm. Furthermore
the bridging could then be extended to not use its MAC address for the
root port even if STP were enabled.

>> My preference, rather than trying to simply disable ipv6 is actually
>> seeing how xen-netback interfaces (and kvm TAP topology) can be
>> simplified further). As I see it there is tons of code which could
>> trigger being used on these xen-netback interfaces (and TAP for kvm)
>> which is simply not needed for the use case of just doing sending data
>> back and forth between host and guest: ipv6 is not needed at all, and
>> I tried to test removing ipv4, but ran into issues.
>
> Bridging is not the only way to provide VM network connectivity. It
> should also be possible to do routing and even NAT by configuring
> appropriate p2p links and routing tables in the host. For that to work I
> think the tap and vif devices do need some sort of IPv[46] capability,

We have to be careful for sure, I'll try to test all cases including
kvm, but architecturally as I see it so far these things are simply
exchanging over data through their respective backend channels, I know
ipv6 interfaces are unused and I'm going to dig further to see why at
least one ipv4 interfaces is needed. I cannot fathom why either of
these interfaces would be required. I'll do a bit more digging.

The TAP interface requirements may be different, I haven't yet dug into that.

> so you can't just nuke that stuff completely. (Maybe/likely it also
> requires them to have a sensible MAC address, I'm not sure).

I'll dig.

>> [2] http://tools.ietf.org/html/rfc4862#appendix-A
>> [3[ https://gitorious.org/opensuse/kernel-source/source/8e16582178a29b03e850468004a47e7be5ed3005:patches.xen/ipv6-no-autoconf
>>
>> > Also how can a user enable multicast on the b/e?
>>
>> ip set multicast on dev <devname>
>> ip set multicast off dev <devname>
>>
>> > AFAIK only Solaris ever
>> > implemented the m/c bits of the Xen PV network protocol (not that I
>> > wouldn't welcome attempts to add it to other platforms)
>>
>> Do you mean kernel configuration multicast ? Or networking ?
>
> I meant the PV protocol extension which allows guests (netfront) to
> register to receive multicast frames across the PV ring -- i.e. for
> multicast to work from the guests PoV.

Not quite sure I understand, ipv6 works on guests so multicast works,
so its unclear what you mean by multicast frames across the PV ring.
Is there any code or or documents I can look at ?

> (maybe that was just an optimisation though and the default is to flood
> everything, it was a long time ago)

>From a networking perspective everything is being flooded as I've seen
it so far.

  Luis
