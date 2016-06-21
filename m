From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH v3 00/17] Future-proof tunnel offload handlers
Date: Tue, 21 Jun 2016 11:17:58 -0700
Message-ID: <CAKgT0UdsYo84J087KUTiiwuHGUaykPvpQTVxCdvE9k21tM5hsQ@mail.gmail.com>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
 <20160617.202641.1821023739498595024.davem@davemloft.net> <CALx6S34Y3Qq6nMHuMcC2LC5duLBO3KVN3+A+0qmPrNvFfY7gJg@mail.gmail.com>
 <20160621.042211.945844554759834352.davem@davemloft.net> <CAKgT0Ucze-+PYdvoHhDSLuaTLrn+Ene+CnfJaKO7AEHGHBsKzg@mail.gmail.com>
 <18b4d172-2cf5-8246-9cac-ce92adf65bc8@solarflare.com> <234d6a2f-6971-7029-0645-f98e51236c4f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jesse Gross <jesse@kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jiri Benc <jbenc@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <michael.chan@broadcom.com>,
	Dept-GELinuxNICDev@qlogic.com
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:35482 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327AbcFUSl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 14:41:28 -0400
Received: by mail-io0-f182.google.com with SMTP id f30so24246865ioj.2
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 11:41:16 -0700 (PDT)
In-Reply-To: <234d6a2f-6971-7029-0645-f98e51236c4f@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 10:40 AM, Hannes Frederic Sowa
<hannes@redhat.com> wrote:
> On 21.06.2016 10:27, Edward Cree wrote:
>> On 21/06/16 18:05, Alexander Duyck wrote:
>>> On Tue, Jun 21, 2016 at 1:22 AM, David Miller <davem@davemloft.net> wrote:
>>>> But anyways, the vastness of the key is why we want to keep "sockets"
>>>> out of network cards, because proper support of "sockets" requires
>>>> access to information the card simply does not and should not have.
>>> Right.  Really what I would like to see for most of these devices is a
>>> 2 tuple filter where you specify the UDP port number, and the PF/VF ID
>>> that the traffic is received on.
>> But that doesn't make sense - the traffic is received on a physical network
>> port, and it's the headers (i.e. flow) at that point that determine whether
>> the traffic is encap or not.  After all, those headers are all that can
>> determine which PF or VF it's sent to; and if it's multicast and goes to
>> more than one of them, it seems odd for one to treat it as encap and the
>> other to treat it as normal UDP - one of them must be misinterpreting it
>> (unless the UDP is going to a userspace tunnel endpoint, but I'm ignoring
>> that complication for now).
>
> Disabling offloading of packets is never going to cause data corruptions
> or misinterpretations. In some cases we can hint the network card to do
> even more (RSS+checksumming). We always have a safe choice, namely not
> doing hw offloading.

Agreed.  Also we need to keep in mind that in many cases things like
RSS and checksumming can be very easily made port specific since what
we are talking about is just what is reported in the Rx descriptor and
not any sort of change to the packet data.

> Multicast is often scoped, in some cases we have different multicast
> scopes but the same addresses. In case of scoped traffic, we must verify
> the device as well and can't install the same flow on every NIC.

Right.  Hopefully the NIC vendors are thinking ahead and testing to
validate such cases where multicast or broadcast traffic doesn't do
anything weird to their NICs in terms of offloads.

>> At a given physical point in the network, a given UDP flow either is or is
>> not carrying encapsulated traffic, and if it tries to be both then things
>> are certain to break, just as much as if two different applications try to
>> use the same UDP flow for two different application protocols.
>
> I think the example Tom was hinting at initially is like that:
>
> A net namespace acts as a router and has a vxlan endpoint active. The
> vxlan endpoint enables vxlan offloading on all net_devices in the same
> namespace. Because we only identify the tunnel endpoint by UDP port
> number, traffic which should actually just be forwarded and should never
> be processed locally suddenly can become processed by the offloading hw
> units. Because UDP ports only form a contract between the end points and
> not with the router in between it would be illegal to treat those not
> locally designated packets as vxlan by the router.

Yes.  The problem is I am sure there are some vendors out there
wanting to tout their product as being excellent at routing VXLAN
traffic so they are probably exploiting this to try and claim
performance gains.

There is also some argument to be had for theory versus application.
Arguably it is the customers that are leading to some of the dirty
hacks as I think vendors are building NICs based on customer use cases
versus following any specifications.  In most data centers the tunnel
underlays will be deployed throughout the network and UDP will likely
be blocked for anything that isn't being used explicitly for
tunneling.  As such we seem to be seeing a lot of NICs that are only
supporting one port for things like this instead of designing them to
handle whatever we can throw at them.

I really think it may be a few more years before we hit the point
where the vendors start to catch a clue about the fact that they need
to have a generic approach that works in all cases versus what we have
now were they are supporting whatever the buzzword of the day is and
not looking much further down the road than that.  The fact is in a
few years time we might even have to start dealing with
tunnel-in-tunnel type workloads to address the use of containers
inside of KVM guests.  I'm pretty sure we don't have support for
recursive tunnel offloads in hardware and likely never will.  To that
end all I would really need is support for CHECKSUM_COMPLETE or outer
Rx checksums enabled, RSS based on the outer source port assuming the
destination port is recognized as a tunnel, the ability to have DF bit
set for any of the inner tunnel headers, and GSO partial extended to
support tunnel-in-tunnel scenarios.

- Alex
