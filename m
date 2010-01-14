From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Thu, 14 Jan 2010 16:37:52 +0100
Message-ID: <4B4F3A50.1050400@trash.net>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Ben Greear <greearb@candelatech.com>
To: hadi@cyberus.ca
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1263481549.23480.24.camel@bigi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Ive had an equivalent discussion with B Greear (CCed) at one point on
> something similar, curious if you solve things differently - couldnt
> tell from the patch if you address it.

Its basically the same, except that this patch uses ct_extend
and mark values.

> Comments inline:
> 
> On Thu, 2010-01-14 at 15:05 +0100, Patrick McHardy wrote:
>> The attached largish patch adds support for "conntrack zones",
>> which are virtual conntrack tables that can be used to seperate
>> connections from different zones, allowing to handle multiple
>> connections with equal identities in conntrack and NAT.
>>
>> A zone is simply a numerical identifier associated with a network
>> device that is incorporated into the various hashes and used to
>> distinguish entries in addition to the connection tuples. Additionally
>> it is used to seperate conntrack defragmentation queues. An iptables
>> target for the raw table could be used alternatively to the network
>> device for assigning conntrack entries to zones.
>>
>>
>> This is mainly useful when connecting multiple private networks using
>> the same addresses (which unfortunately happens occasionally) 
> 
> Agreed that this would be a main driver of such a feature.
> Which means that you need zones (or whatever noun other people use) to
> work on not just netfilter, but also routing, ipsec etc.

Routing already works fine. I believe IPsec should also work already,
but I haven't tried it.

> As a digression: this is trivial to solve with network namespaces. 
> 
>> to pass
>> the packets through a set of veth devices and SNAT each network to a
>> unique address, after which they can pass through the "main" zone and
>> be handled like regular non-clashing packets and/or have NAT applied a
>> second time based f.i. on the outgoing interface.
>>
> 
> The fundamental question i have is:
> how you deal with overlapping addresses?
> i.e zone1 uses 10.0.0.1 and zone2 uses 10.0.0.1 but they are for
> different NAT users/endpoints.

The zone is set based on some other criteria (in this case the
incoming device). The packets make one pass through the stack
to a veth device and are SNATed in POSTROUTING to non-clashing
addresses. When they come out of the other side of the veth
device, they make a second pass through the network stack and
can be handled like any other packet.

So the setup would be (with 10.0.0.0/24 on if0 and if1):

ip rule add from if0 lookup t0
ip route add default veth0 table t0
iptables -t nat -A POSTROUTING -o veth0 -j NETMAP --to 10.1.0.0/24
echo 1 >/sys/class/net/if0/nf_ct_zone
echo 1 >/sys/class/net/veth0/nf_ct_zone

ip rule add from if1 lookup t1
ip route add default veth2 table t0
iptables -t nat -A POSTROUTING -o veth2 -j NETMARK --to 10.1.1.0/24
etho 2 >/sys/class/net/if1/nf_ct_zone
echo 2 >/sys/class/net/veth2/nf_ct_zone

The mapped packets are received on veth1 and veth3 with non-clashing
addresses.

>> As probably everyone has noticed, this is quite similar to what you
>> can do using network namespaces. The main reason for not using
>> network namespaces is that its an all-or-nothing approach, you can't
>> virtualize just connection tracking. 
> 
> Unless there is a clever approach for overlapping IP addresses (my
> question above), i dont see a way around essentially virtualizing the
> whole stack which clone(CLONE_NEWNET) provides..

I don't understand the problem.

>> Beside the difficulties in
>> managing different namespaces from f.i. an IKE or PPP daemon running
>> in the initial namespace, 
> 
> This is a valid concern against the namespace approach. Existing tools
> of course could be taught to know about namespaces - and one could
> argue that if you can resolve the overlap IP address issue, then you
> _have to_ modify user space anyways.

I don't think thats true. In any case its completely impractical
to modify every userspace tool that does something with networking
and potentially make complex configuration changes to have all
those namespaces interact nicely. Currently they are simply not
very well suited for virtualizing selected parts of networking.

>> network namespaces have a quite large
>> overhead, especially when used with a large conntrack table.
> 
> Elaboration needed.
> You said the size in 64 bit increases to 152B per conntrack i think?

I said code size increases by 152b.

> Do you have a hand-wave figure we can use as a metric to elaborate this
> point? What would a typical user of this feature have in number of
> "zones" and how many contracks per zone? Actually we could also look
> at extremes (huge number vs low numbers)...

I'm not sure whether there is a typical user for overlapping
networks :) I know of setups with ~150 overlapping networks.

The number of conntracks per zone doesn't matter since the
table is shared between all zones. network namespaces would
allocate 150 tables, each of the same size, which might be
quite large.

> You may also wanna look as a metric at code complexity/maintainability
> of this scheme vs namespace (which adds zero changes to the kernel).

There's not a lot of complexity, its basically passing a numeric
identifier around in a few spots and comparing it. Something like
TOS handling in the routing code.

> I am pretty sure you will soon be "zoning" on other pieces of the net
> stack ;->

I've thought about that and I don't think that's necessary for this
use case. Its enough to resolve overlapping address ranges, everything
else can be done in the second path through the stack.

>> I'm not too fond of this partial feature duplication myself, but I
>> couldn't think of a better way to do this without the downsides of
>> using namespaces. Having partially shared network namespaces would
>> be great, but it doesn't seem to fit in the design very well.
>> I'm open for any better suggestion :)
> 
> My opinions above.
> 
> BTW, why not use skb->mark instead of creating a new semantic construct?

Because people are already using it for different purposes.
