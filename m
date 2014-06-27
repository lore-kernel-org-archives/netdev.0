From: Lori Jakab <lojakab@cisco.com>
Subject: Re: [PATCH V6 net-next] LISP: Locator/Identifier Separation Protocol
Date: Fri, 27 Jun 2014 09:19:50 +0300
Message-ID: <53AD0D06.6070109@cisco.com>
References: <9D51E1BB-BAB2-4859-A3E1-2C4F56BAD641@logicalelegance.com> <20140623.150206.1941399398042390524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vermagan@cisco.com
To: David Miller <davem@davemloft.net>, chris@logicalelegance.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aer-iport-3.cisco.com ([173.38.203.53]:12074 "EHLO
	aer-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbaF0G3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 02:29:33 -0400
In-Reply-To: <20140623.150206.1941399398042390524.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Thanks for reviewing.

Replying inline below on the general points, since I was coordinating=20
with Chris on this work. I added LISP support to the Open vSwitch=20
out-of-tree kernel module, which we would like to upstream when=20
Jesse/Pravin think it's ready.

On 6/24/14, 1:02 AM, David Miller wrote:
> From: Christopher White <chris@logicalelegance.com>
> Date: Fri, 20 Jun 2014 08:26:12 -0700
>
>> This is a static tunnel implementation of LISP as described in RFC 6=
830:
>>    http://tools.ietf.org/html/rfc6830
>>
>> This driver provides point-to-point LISP dataplane
>> encapsulation/decapsulation for statically configured endpoints. It =
provides
>> support for IPv4 in IPv4 and IPv6 in IPv4. IPv6 outer headers are no=
t
>> supported yet. Instance ID is supported on a per device basis.
>>
>> This implementation has been tested against LISPMob.
>>
>> Changes from V2: Move some functions to common headers. Remove unece=
ssary skb
>> ownership change. Minor cleanup.
>> Changes from V3: Revert some generic function consolidation for late=
r patches.
>> Changes from V4: Indentation (Note V4 was erroneously marked V3)
>> Changes from V5: Remove extraneous export
>>
>> Signed-off-by: Chris White <chris@logicalelegance.com>
> I'm not so sure if this is how we should start supporting LISP at thi=
s
> time.
>
> The whole point is to be able to dynamically map EIDs to RLOCs on dem=
and,
> and this static tunnel neither provides that functionality, nor provi=
des
> generic enough infrastructure to add such a facility easily.

We started this work after LISP was accepted into the out-of-tree Open=20
vSwitch (OVS) kernel module, because all tunneling protocols were moved=
=20
out to standalone kernel implementations, and OVS was just hooking into=
=20
those. That=92s why we only implemented static tunneling (for now),=20
because we only need the encapsulation to be done in the kernel module.=
=20
The dynamic part is intended to be provided by OVS, by means of flow ru=
les.

>
> Furthermore, LISP fundamentally seems quite DOS'able.  What is to kee=
p one
> from having to service a full Map-Request --> Map-Reply cycle for eve=
ry
> packet received?  Just keep spamming packet after packet through the =
ITR,
> specifying a unique and different EID in the destination address each=
 time.

Map-Requests can and should be rate limited. Also, if there is no=20
mapping for a packet in the map-cache (while we're waiting for a reply)=
,=20
it is sent to a Proxy-ETR, a dedicated LISP infrastructure box part of=20
the LISP architecture, and gets delivered to the destination.

>
> That's exactly the same kind of problem we had internally with the
> ipv4 routing cache and that's why we totally removed it.

If I understand correctly, the route cache was a hash table with=20
multiple keys. We intend to have a trie based look-up table for LISP.=20
Additionally, IPv4 routing was and still is a required component for=20
every networked host, while LISP will be an optional feature.

Beucause of this, and the reasons in the previous paragraph the=20
potential impact of the DoS is quite low IMHO.
>
> Also I wonder if whatever a "properly functioning" (whatever that
> means, given the DOS'ability of it in dynamic configurations) LISP gi=
ves
> us is worth the MTU we lose with the encapsulation.

The MTU issue is not unique to LISP. If you want, I can get into detail=
s=20
of what a =93properly functioning=94 LISP can provide (granted, on the=20
control plane side) that other tunneling protocols don=92t in a follow-=
up=20
email.

>
> Sorry, I'm not too thrilled about LISP and this patch in particular,
> from several different angles.  And therefore I'm going to mark this
> patch deferred and not apply it at this time.

Let us know what we should improve, and we=92ll work on it.

-Lori
