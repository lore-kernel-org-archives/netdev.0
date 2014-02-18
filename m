From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [Xen-devel] [RFC v2 0/4] net: bridge / ip optimizations for
 virtual net backends
Date: Tue, 18 Feb 2014 11:43:59 -0800
Message-ID: <CAB=NE6VxNByeWGk6_Ow7WgxA3HCwGBjrjL9MNVRGsEfFyeKTdw@mail.gmail.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com> <5301E411.5060908@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel@lists.xenproject.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kvm@vger.kernel.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5301E411.5060908@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 17, 2014 at 2:27 AM, David Vrabel <david.vrabel@citrix.com> wrote:
> On 15/02/14 02:59, Luis R. Rodriguez wrote:
>> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>>
>> This v2 series changes the approach from my original virtualization
>> multicast patch series [0] by abandoning completely the multicast
>> issues and instead generalizing an approach for virtualization
>> backends. There are two things in common with virtualization
>> backends:
>>
>>   0) they should not become the root bridge
>>   1) they don't need ipv4 / ipv6 interfaces
>
> Why?  There's no real difference between a backend network device and a
> physical device (from the point of view of the backend domain).  I do
> not think these are intrinsic properties of backend devices.

Let me clarify the original motivation as that can likely help explain
how I ended up with this patch series.

SUSE has had reports of xen backend interfaces ending up with
duplicate address notification filling up logs on systems with a
series of guests, these reports go back to 2006. This was root caused
to DAD on IPv6 interfaces, and a work around implemented to disable
DAD [0] on multicast links. Even though this patch as a work around
should not be applicable anymore given that since the xen-netback
upstreaming since 2.6.39 ether_setup is used and that enables the
multicast flag, we should try ensure the issue doesn't creep up
anymore. As per the IPv6 RFCs and Linux IPv6 implementation -- DAD
should be triggered even in the case of manual IP configuration and
when the link goes up, as such SLAAC will always take place on IPv6
interfaces. Although not documented upon my review I determined the
original issue could also be attributed to the corner case documented
on Appendix A of RFC 4862 [1] and this could be more prevalent for
xen-netback given we stuck to the same MAC address for all xen-netback
interfaces. I first tried to generalize the work around and address
the multicast case requirement for IPv6 [2], and explicitly disabling
multicast on xen-netback. Although this approach could likely be
generalized further by taking into account for NBMA links by checking
dev->type I determined we didn't need IPv6 interfaces at all on the
xent-netback interfaces. This lead me to further review if we even
needed IPv4 interfaces as well, and it turns out we do not.

New motivation: removing IPv4 and IPv6 from the backend interfaces can
save up a lot of boiler plate run time code, triggers from ever taking
place, and simplifying the backend interaces. If there is no use for
IPv4 and IPv6 interfaces why do we have them? Note: I have yet to test
the NAT case.

> I can see these being useful knobs for administrators (or management
> toolstacks) to turn on, on a per-device basis.

Agreed but these knobs don't even exist for drivers yet, let alone for
system administrators. I certainly can shoot for another series to let
administrators configure this as a preference but -- if we know a
driver won't need IPv4 and IPv6 interfaces why not just allow drivers
to disable them all together? Consider the simplification of the
interfaces on the host.

[0] https://gitorious.org/opensuse/kernel-source/source/8e16582178a29b03e850468004a47e7be5ed3005:patches.xen/ipv6-no-autoconf
[1] http://tools.ietf.org/html/rfc4862
[2] http://marc.info/?l=linux-netdev&m=139207142110536&w=2

  Luis
