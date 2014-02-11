From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC 2/2] xen-netback: disable multicast and use a random hw MAC address
Date: Tue, 11 Feb 2014 13:53:26 -0800
Message-ID: <CAB=NE6Vu=khpj_3J7r-u8DFkhyC-RgLikNFtOU-WO7te_4HMCw@mail.gmail.com>
References: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
 <1392071391-13215-3-git-send-email-mcgrof@do-not-panic.com> <1392108205.22033.16.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel@lists.xenproject.org,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, kvm@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392108205.22033.16.camel@dagon.hellion.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc'ing kvm folks as they may have a shared interest on the shared
physical case with the bridge (non NAT).

On Tue, Feb 11, 2014 at 12:43 AM, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> On Mon, 2014-02-10 at 14:29 -0800, Luis R. Rodriguez wrote:
>> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>>
>> Although the xen-netback interfaces do not participate in the
>> link as a typical Ethernet device interfaces for them are
>> still required under the current archtitecture. IPv6 addresses
>> do not need to be created or assigned on the xen-netback interfaces
>> however, even if the frontend devices do need them, so clear the
>> multicast flag to ensure the net core does not initiate IPv6
>> Stateless Address Autoconfiguration.
>
> How does disabling SAA flow from the absence of multicast?

See patch 1 in this series [0], but I explain the issue I see with
this on the cover letter [1]. In summary the RFCs on IPv6 make it
clear you need multicast for Stateless address autoconfiguration
(SLAAC is the preferred acronym) and DAD, however the net core has not
made this a requirement, and hence the patch. The caveat which I
address on the cover letter needs to be seriously considered though.

[0] http://marc.info/?l=linux-netdev&m=139207142110535&w=2
[1] http://marc.info/?l=linux-netdev&m=139207142110536&w=2

> Surely these should be controlled logically independently even if there is some
> notional linkage.

When a node hops on a network it will query its network by sending a
router solicitation multicast request for its configuration
parameters, the router can respond with router advertisements to
disable SLAAC.

Apart from that we have no other means to disable SLAAC neatly, and as
I gather that would be counter to the IPv6 RFCs anyway, and that makes
sense.

> Can SAA not be disabled directly?

Nope. The ipv6 core assumes all device want ipv6 and this is done upon
netdev registration, and as I noted on my patch 1 description --
although ipv6 supports a module parameter to disable autoconfiguration
RFC4682 Section 5.4 makes it clear that DAD *MUST* be performed on all
unicast addresses prior to assigning them to an interface, regardless
of
whether they are obtained through SLAAC, DHCPv6, or manual configuration.

Upon NETDEV_REGISTER the ipv6 core has 2 struct ipv6_devconf sets of
configurations which could get slapped onto devices, neither of these
disable autoconfiguration, its not a knob with a design purpose to let
devices disable freely -- and technically the RFCs for IPv6 simply
imply that you should not use IPv6 if you do cannot support multicast.
Given that the noautoconf module parameter exists though I think my
patch can be considered upstream after addressing the caveat I noted
on not-NBMA links (and I now I think I know how to address that, we
can just make the MULTICAST flag more meaninful for the dev->type).

A nasty hack to disable IPv6 for testing purposes is to set the MTU to
something lower than IPV6_MIN_MTU (1280) and in fact IPv4 can also be
disabled by setting it to 67, that will disable both IPv6 and IPv4.
That's obviously just that, a nasty nasty hack, but useful for easy
testing of disabling either ipv6 completely or both.

>>  Clearing the multicast
>> flag is required given that the net_device is using the
>> ether_setup() helper.
>>
>> There's also no good reason why the special MAC address of
>> FE:FF:FF:FF:FF:FF is being used other than to avoid issues
>> with STP,
>
> With your change there is a random probability on reboot that the bridge
> will end up with a randomly generated MAC address instead of a static
> MAC address (usually that of the physical NIC on the bridge), since the
> bridge tends to inherit the lowest MAC of any port.

I had not considered the bridge taking the lowest MAC address of any
port added! So that was one of the tricks with the fixed MAC address
of FE:FF:FF:FF:FF:FF, to ensure the bridge would skip using its mac
address when it was later added as a port. Another collateral issue if
this is *not* considered is that if a xen-netback interface has a MAC
address lower than the general interface one and if you shutdown that
guest, and therefore removed it from the bridge, the bridge MAC
address will also change once again back to the general interface one.
This will cause a hiccup on accessing the device, while ARP settles
things. If doing a massive shutdown / reboot of guests that have a
series of MAC addresses lower than the general interface one is a
series of MAC address changes on the bridge.

FWIW kvm seems to completely randomize the MAC address of the backend
TAP interfaces (while the front end virtio driver fully randomizes
it), but note that in the NAT use case where only the TAP interfaces
get added the above is not an issue, although I suspect if the shared
connection is used this could be a problem, it will depend on what
tools create the TAP interface and how.

I suspect we may have a shared concern here and I wonder if kvm hit
the snags described above on the shared physical cases. Curious if kvm
folks have seen these issues?

> Since IP configuration is done on the bridge this will break DHCP,
> whether it is using static or dynamic mappings from MAC to IP address,
> and the host will randomly change IP address on reboot.

Its beyond that, as I noted as well there can be issues upon shutdown.

> So Nack for that reason.

Makes sense. Will think about this a bit more.

>>  since using this can create an issue if a user
>> decides to enable multicast on the backend interfaces
>
> Please explain what this issue is.

I explained this on the cover letter but should have elaborated more
here. The *known* and *reported* issue is that xen-backend interfaces
can end up  SLAAC and you'd obviously end up in some situations where
the MAC address and IP address clash, despite the architecture of IPv6
to randomize time requests for neighbor solicitations, and DAD.
Ultimately a series of services can end up filling your log messages
with tons of warnings.

Another not reported issue, but I suspect critical and it can bite
both xen and kvm in the ass is described on Appendex A on RFC 4862 [2]
which considers the issues of getting duplicates of packets on the
same link with the same link layer address. I think to address that we
can also consider dev->type into all the different cases.

What drove these patches is trying to find a proper upstream approach
to Olaf's old xen ipv6-no-autoconf patch [3]. Although not stated on
the patch I have seen some old year 2006 internal reports even with
the static FE:FF:FF:FF:FF:FF MAC address, whereby the xen-netback
interfaces kicked off IPv6 SLAAC and DAD. IPv6 SLAAC should trigger
once the link goes up.

My preference, rather than trying to simply disable ipv6 is actually
seeing how xen-netback interfaces (and kvm TAP topology) can be
simplified further). As I see it there is tons of code which could
trigger being used on these xen-netback interfaces (and TAP for kvm)
which is simply not needed for the use case of just doing sending data
back and forth between host and guest: ipv6 is not needed at all, and
I tried to test removing ipv4, but ran into issues.

[2] http://tools.ietf.org/html/rfc4862#appendix-A
[3[ https://gitorious.org/opensuse/kernel-source/source/8e16582178a29b03e850468004a47e7be5ed3005:patches.xen/ipv6-no-autoconf

> Also how can a user enable multicast on the b/e?

ip set multicast on dev <devname>
ip set multicast off dev <devname>

> AFAIK only Solaris ever
> implemented the m/c bits of the Xen PV network protocol (not that I
> wouldn't welcome attempts to add it to other platforms)

Do you mean kernel configuration multicast ? Or networking ?

 Luis
