From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Thu, 9 Aug 2012 07:34:23 +0300
Message-ID: <CAJZOPZ+JKZAxF-SaWxCd_8pLqhrLXrPyQHEo0n-gNzuvMOA02w@mail.gmail.com>
References: <501C3527.6060809@mellanox.com>
	<20120803.143315.151094375569109262.davem@davemloft.net>
	<501C5328.4060301@mellanox.com>
	<20120803.163627.1867181085116225405.davem@davemloft.net>
	<50205DE0.7080706@mellanox.com>
	<87obmnfs4p.fsf@xmission.com>
	<CAJZOPZLApfvgd1wrM2HseNrWh-egaixjhGfB7xBJU1FxFhBdzg@mail.gmail.com>
	<87pq714uaa.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ali Ayoub <ali@mellanox.com>, David Miller <davem@davemloft.net>,
	ogerlitz@mellanox.com, roland@kernel.org, netdev@vger.kernel.org,
	sean.hefty@intel.com, erezsh@mellanox.co.il, dledford@redhat.com,
	"Michael S. Tsirkin" <mst@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:40797 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab2HIEeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 00:34:24 -0400
Received: by ggdk6 with SMTP id k6so32682ggd.19
        for <netdev@vger.kernel.org>; Wed, 08 Aug 2012 21:34:23 -0700 (PDT)
In-Reply-To: <87pq714uaa.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:
> Or Gerlitz <or.gerlitz@gmail.com> writes:

>> as you wrote here, when performance and ease-of-use is under the spot,
>> VM deployments tend to not to use routing.
>> This is b/c it involves more over-head on the packet forwarding, and
>> more administration work, for example, for setting routing rules that
>> involve the VM IP address, something which AFAIK the hypervisor have
>> no clue on, also its unclear to me if/how live migration can work in such setting.

> All you need to make proxy-arp essentially pain free is a smart dhcp
> relay, that sets up the routes.

So dhcp relay would help to maybe avoid some of the pain, however,
can you elaborate if/how live migration is supported under this scheme?

>> From this exact reason, there's a bunch of use-cases by tools and
>> cloud stacks (such as open stack, ovirt, more) which do use bridged
>> mode and the rest of the Ethernet envelope, such as using virtual L2
>> vlan domains, ebtables based rules, etc etc. Where they and are not
>> application to ipoib, but are working file ith eipoib.

> Yes I am certain all of their IPv6 traffic works fine.

I'm not sure to follow this comment.

> Regardless those are open source projects and can be modified to add
> support to cleanly support inifiniband.

open source/code can be modified indeed, but since exposing IPoIB link
layer to tools/emulators and VMs doesn't really make sense (see below),
we brought that this approach as a way to go for allowing people to use
bridging mode when the fabric is IB.

>> You mentioned that bridging mode doesn't apply to environment such as
>> 802.11, and hence routing mode is used, we are trying to make a pointn
>> here that bridging mode applies to ipoib with the approach suggested by eipoib.

> You are completely failing.  Every time I look I see something about
> eIPoIB that is even more broken.  Given that eIPoIB is a NAT
> implementation that isn't really a surprise but still.

> eIPoIB imposes enough overhead that I expect that routing is cheaper,
> so your performance advantges go right out the window.
>
> eIPoIB is seriously incompatible with ethernet breaking almost
> everything and barely allowing IPv4 to work.

I don't agree on this incompatiblity statement, you had a claim
on DHCP and I addressed it, beyond that, you don't like the eIPoIB
basic idea/design but this can't base an incompatiblity argument.


>> Also, if we extend the discussion a bit, there are two more aspects to throw in:
>> The first is the performance thing we have already started to mention
>> -- specifically, the approach for RX zero copy (into the VM buffer),
>> use designs such as vhost + macvtap NIC in passthrough mode which is
>> likey to be set over a per VM hypervisor NIC, e.g such as the ones
>> provided by VMDQ patches John Fastabend started to post (see
>> http://marc.info/?l=linux-netdev&m=134264998405581&w=2) -- the ib0.N
>> clone child are IPoIB VMDQ NICs if you like, and setting an eipoib NIC
>> on top of each they can be plugged to that design.

> If you care about performance link-layer NAT is not the way to go.
> Teach the pieces you care about how to talk infiniband.
>
>> The 2nd aspect, is NON VM environments where a NIC with Ethernet look
>> and feel is required for IP traffic, but this have to live within an
>> echo-system that fully uses IPoIB.
>> In other words, a use case where IPoIB has to be below the cover for
>> set of some specific apps, or nodes but do IP interaction with other
>> apps/nodes and gateways who use IPoIB, the eIPoIB driver provides that
>> functionality.


> ip link add type dummy.

> There now you have an interface with ethernet look and feel, and
> routing can happily avoid it.

again, not sure to follow, you mean "routing can happily use it", correct? that
is do routing between the dummy interface to IPoIB interface?


>> So, to sum up, routing / proxy-arp seems to be off where we are targeting.

> My condolences.
> The existence of router / proxy-arp means that solutions do exist
> (unlike your previous claim) you just don't like the idea of deploying them.

Don't like them from set of arguments, which we are covering here, re
manageability it still needs to clarified if/how live migration work and what
does it mean to always mandate dhcp relay.

> Infiniband is standard enough you could quite easily implement virtual
> infiniband bridging as an alternative to ethernet bridging.

Not really, as Michael indicated in his response over this thread
http://marc.info/?l=linux-netdev&m=134419288218373&w=2
IPoIB link layer addresses use IB HW constructs for which soft
hardware address setting isn't supported, and this interferes
with live migration.

Or.
