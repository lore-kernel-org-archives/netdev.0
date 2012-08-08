From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Wed, 08 Aug 2012 02:17:33 -0700
Message-ID: <87pq714uaa.fsf@xmission.com>
References: <501C3527.6060809@mellanox.com>
	<20120803.143315.151094375569109262.davem@davemloft.net>
	<501C5328.4060301@mellanox.com>
	<20120803.163627.1867181085116225405.davem@davemloft.net>
	<50205DE0.7080706@mellanox.com> <87obmnfs4p.fsf@xmission.com>
	<CAJZOPZLApfvgd1wrM2HseNrWh-egaixjhGfB7xBJU1FxFhBdzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ali Ayoub <ali@mellanox.com>, David Miller <davem@davemloft.net>,
	ogerlitz@mellanox.com, roland@kernel.org, netdev@vger.kernel.org,
	sean.hefty@intel.com, erezsh@mellanox.co.il, dledford@redhat.com,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49625 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664Ab2HHJRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 05:17:44 -0400
In-Reply-To: <CAJZOPZLApfvgd1wrM2HseNrWh-egaixjhGfB7xBJU1FxFhBdzg@mail.gmail.com>
	(Or Gerlitz's message of "Wed, 8 Aug 2012 10:32:47 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <or.gerlitz@gmail.com> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>> Ali Ayoub <ali@mellanox.com> writes:
> [...]
>>> I don't see in other alternatives a solution for the problem we're
>>> trying to solve. If there are changes/suggestions to improve eIPoIB
>>> netdev driver to avoid "messing with the link layer" and make it
>>> acceptable, we can discuss and apply them.
>
>> Nothing needs to be applied the code is done.  Routing from
>> IPoE to IPoIB works. There is nothing in what anyone has posted as requirements
>>  that needs work to implement.
>
>> I totally fail to see how getting packets of of the VM as ethernet
>> frames, and then  IP layer routing those packets over IP is not an
>> option.  What requirement am I missing.
>
>
> As you've indicated routing w/w.o using proxy-arp is an option, however,
>
>> All VMs should suport that mode of operation, and certainly the kernel does.
>> Implementations involving bridges like macvlan and macvtap are
>> performance optimizations, and the optimizations don't even apply in
>> areas like 802.11, where only one mac address is supported per adapter.
>> Bridging can ocassionally also be an administrative simplification as
>> well, but you should be able to achieve the a similar simplification
>> with a dhcprelay and proxy arp.
>
> as you wrote here, when performance and ease-of-use is under the spot,
> VM deployments tend to not to use routing.
>
> This is b/c it involves more over-head on the packet forwarding, and
> more administration work, for example, for setting routing rules that
> involve the VM IP address, something which AFAIK the hypervisor have
> no clue on, also its unclear to me if/how live migration can work in
> such setting.

All you need to make proxy-arp essentially pain free is a smart dhcp
relay, that sets up the routes.

> From this exact reason, there's a bunch of use-cases by tools and
> cloud stacks (such as open stack, ovirt, more) which do use bridged
> mode and the rest of the Ethernet envelope, such as using virtual L2
> vlan domains, ebtables based rules, etc etc. Where they and are not
> application to ipoib, but are working file ith eipoib.

Yes I am certain all of their IPv6 traffic works fine.

Regardless those are open source projects and can be modified to add
support to cleanly support inifinibnad.

> You mentioned that bridging mode doesn't apply to environment such as
> 802.11, and hence routing mode is used, we are trying to make a pointn
> here that bridging mode applies to ipoib with the approach suggested
> by eipoib.

You are completely failing.  Every time I look I see something about
eIPoIB that is even more broken.  Given that eIPoIB is a NAT
implementation that isn't really a surprise but still.

eIPoIB imposes enough overhead that I expect that routing is cheaper,
so your performance advantges go right out the window.

eIPoIB is seriously incompatible with ethernet breaking almost
everything and barely allowing IPv4 to work.

> Also, if we extend the discussion a bit, there are two more aspects to throw in:
>
> The first is the performance thing we have already started to mention
> -- specifically, the approach for RX zero copy (into the VM buffer),
> use designs such as vhost + macvtap NIC in passthrough mode which is
> likey to be set over a per VM hypervisor NIC, e.g such as the ones
> provided by VMDQ patches John Fastabend started to post (see
> http://marc.info/?l=linux-netdev&m=134264998405581&w=2) -- the ib0.N
> clone child are IPoIB VMDQ NICs if you like, and setting an eipoib NIC
> on top of each they can be plugged to that design.

If you care about performance link-layer NAT is not the way to go.
Teach the pieces you care about how to talk infiniband.

> The 2nd aspect, is NON VM environments where a NIC with Ethernet look
> and feel is required for IP traffic, but this have to live within an
> echo-system that fully uses IPoIB.
> In other words, a use case where IPoIB has to be below the cover for
> set of some specific apps, or nodes but do IP interaction with other
> apps/nodes and gateways who use IPoIB, the eIPoIB driver provides that
> functionality.

ip link add type dummy.

There now you have an interface with ethernet look and feel, and
routing can happily avoid it.

> So, to sum up, routing / proxy-arp seems to be off where we are
> targeting.

My condolences.

The existence of router / proxy-arp means that solutions do exist
(unlike your previous claim) you just don't like the idea of deploying
them.

Infiniband is standard enough you could quite easily implement virtual
infiniband bridging as an alternative to ethernet bridging.


At this stage of the game eIPoIB is interesting the same way a zombie is
interesting.  It is fascinating to see it still moving as chunks of
flesh fall to the floor removing any doubt that it is dead.

Eric
