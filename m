From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Tue, 16 Dec 2014 08:35:51 -0800
Message-ID: <54905F67.2090509@gmail.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:57234 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbaLPQgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 11:36:04 -0500
Received: by mail-oi0-f53.google.com with SMTP id g201so989668oib.12
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 08:36:03 -0800 (PST)
In-Reply-To: <54902E5E.2070405@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2014 05:06 AM, Jamal Hadi Salim wrote:
> On 12/15/14 19:45, John Fastabend wrote:
>> On 12/15/2014 06:29 AM, Jamal Hadi Salim wrote:
>
>>
>> hmm good question. When I implemented this on the host nics with SR-IOV,
>> VMDQ, etc. The multi/unicast addresses were propagated into the FDB by
>> the driver.
>
> So if i understand correctly, this is a NIC with an FDB. And there is no
> concept of a bridge to which it is attached. To the point of
> classical uni/multicast addresses on a netdev abstraction; these
> are typically stored in *much simpler tables* (used to be IO
> registers back in the day)

 From a model perspective it looks like a edge relay. Only a single
downlink with multiple uplinks. No learning, no loops and so no
STP, et. al. required. It may or may not support MAC+VLAN forwarding
or just MAC forwarding.

It may be configured via register writes or more complicated firmware
requests or some other mechanism. This is device dependent even across
devices by the same vendor the mechanisms change. But the driver
abstracts this.

> Do these NICs not have such a concept?
> An fdb entry has an egress port column; I have seen cases where the
> port is labeled as "Cpu port" which would mean it belongs to the host;

But in the SR-IOV case you have multiple "Cpu ports" and you want
to send packets to each of them depending on the configuration.


    port0   port1     port2  port3
     |        |        |      |      uplinks
  +------------------------------+
  |                              |
  |       SRIOV edge relay       |
  |                              |
  +------------------------------+
                  |                   downlink


In a host nic with SRIOV each port will be a PCIE function. So really
they are all CPU ports. For multi-function devices they might all be
physical functions.

In the hardware there needs to be a table to forward incoming traffic
to the correct port#. For L2 we use MAC+VLAN and an egress port column
to select the port. The model shouldn't care if the port is backed by
a VF or PF or set of queues. It just needs to forward packets to the
correct uplink.

One issue we have today when writing software for these edge relays
is we don't have a netdev representing the downlink. Or a netdev
representing management functions of the device. So if I want to
say change the mode of the edge relay from VEB to VEPA I usually
just send the message to the PF. Or if I want to send packets out on
the wire but not through the edge relay usually we do this by sending
control packets over an elected PF and it will attach a tag or something
so the edge relay doesn't forward or flood them to other uplinks. Adding
a netdev for the downlink would probably clean some of this up. Now
we rely on some behaviour that is not well-defined.

> but in this case it just seems there is no such concept and as Or
> brought up in another email - what does "VLANid" mean in such a case?

I think most host nics with SR-IOV can forward using VLAN + MAC and
do filtering on VLANid. Many can also put a default VLAN on the packet.

> If we go with a CPU port concept,
> We could then use the concept of a vlan filter on a port basis
> but then what happens when you dont have an fdb (majority of cases)?

Not sure what the question is here.. I'm hoping the above helped
explain my thinking on this.

Don't have an FDB? This means you don't have any way to forward
between ports so you must have a 1:1 mapping between the physical
port and the netdev. I think its fair to think of this as a TPMR
(two port mac relay) although not a very useful abstraction.

>
>> My logic was if some netdev ethx has a set of MAC addresses
>> above it well then any virtual function or virtual device also behind
>> the hardware shouldn't be sending those addresses out the egress switch
>> facing port. Otherwise the switch will see packets it knows are behind
>> that port and drop them. Or flood them if it hasn't learned the address
>> yet. Either way they will never get to the right netdev.
>>
>> Admittedly I wasn't thinking about switches with many ports at the time.
>>
>
> I often struggle with trying to "box" SRIOV into some concept of a
> switch abstraction and sometimes i am puzzled.
> Would exposing the SRIOV underlay as a switch not have solved this
> problem? Then the virtual ports essentially are bridge ports.

Yes this would help and this is how I view it. Although the
edge relay vs "real standards based" bridge distinction is important
because we don't do learning, only have a single uplink, don't run
loop detecting protocols, etc. All that stuff is not needed on a host
where you "know" your MAC addresses (at least for many use cases) and
can not build loops.

> Maybe what we need is a concept of a "edge relay" extended netdev?

This is effectively what the fdb table does right? Sure its not as
explicit as it could be but this is how I treat the NIC when I learn
it has multiple downlinks and a single uplink. At the moment we use
a trick similar to Jiri's on rocker, when we get a switch op like
getlink, setlink we "know" what switch object it refers to because
the netdev maps to a single switch always.

> These things would have an fdb as well down and uplink relay ports that
> can be attached to them.
>

Right in the current code paths there is no "attach" operation we assume
the edge relay and ports are attached when the ports are created via
SR-IOV or hw-offload or whatever.

What are we missing? We have the FDB and a unique id to show ports on
the same edge relay. User space can build this abstraction from those
two things. A downlink netdev port would probably clean up the
abstraction a bit especially for sending control frames.

>
>>> Some of these drivers may be just doing the LinuxWay(aka cutnpaste what
>>> the other driver did).
>>
>> My original thinking here was... if it didn't implement fdb_add, fdb_del
>> and fdb_dump then if you wanted to think of it as having forwarding
>> database that was fine but it was really just a two port mac relay. In
>> which case just dump all the mac addresses it knows about. In this case
>> if it was something more fancy it could do its own dump like vxlan or
>> macvlan.
>>
>
> The challenge here is lack of separation between a NICs uni/multicast
> ports which it owns - which is a traditional operation regardless of
> what capabilities the NIC has; vs an fdb which has may have many
> other capabilities. Probably all NICs capable of many MACs implement
> fdbs?

Yes they must to support forwarding. Agreed its a bit clunky they
way we overload uni/multicast address lists. But what does it mean
to add a unicast address to a port and not have it in the FDB? If
the port wants to receive traffic on a MAC because its added to the
unicast list doesn't it mean insert it into the FDB so the packets
actually get sent to the netdev?

Otherwise its a two step process one add it to the multicast list
and then add it to the FDB. I'm not sure why this is valuable.

>
>> For a host nic ucast/multicast and fdb are the same, I think? The
>> code we had was just short-hand to allow the common case a host nic
>> to work. Notice vxlan and bridge drivers didn't dump there addr lists
>> from fdb_dump until your patch.
>>
>> Perhaps my implementation of macvlan fdb_{add|del|dump} is buggy. And
>> I shouldn't overload the addr lists.
>>
>
> Not just those - I am wondering about the general utility of what
> Hubert was trying to do if all the driver does is call the default
> dumper based on some flags presence and the default dumper
> does a dump of uni/multicast host entries. Those are not really fdb
> entries in the traditional sense.

But as a practical matter any uni/multicast entry is in the FDB
so when the host nic has multiple ports we receive those mac addresses
on the port. The drivers do this today and it seems reasonable to me.

> Is there no way to get the unicast/multicast mac addresses for such
> a driver?

You can almost infer it from ip link by looking at all the stacked
drivers and figuring out how the address are propagated down. Then
look at the routes and figure out multicast address. But other than
the fdb dump mechanism I don't think there is anything.

> I think that would help bring clarity to my confusion.
>

clear as mud now?

>
>>
>> I'm interested to see what Vlad says as well. But the current situation
>> is previously some drivers dumped their addr lists others didn't.
>> Specifically, the more switch like devices (bridge, vxlan) didn't. Now
>> every device will dump the addr lists. I'm not entirely convinced that
>> is correct.
>>
>
> I am glad this happened ;-> Otherwise we wouldnt be having this
> discussion. When Vlad was asking me I was in a rush to get the patch
> out and didnt question because i thought this was something some crazy
> virtualization people needed.
> If Vlad's use case goes away, then Hubert's little restoration is fine.

Yep. maybe we can talk about it at the netdev users conference

>
>
>> It works OK for host nics (NICS that can't forward between ports) and
>> seems at best confusing for real switch asics.
>
> So if these NICs have fdb entries and i programmed it (meaning setting
> which port a given MAC should be sent to), would it not work?

You mean via 'bridge fdb add' yes this will work. But then as a short
hand we also program the ucast/multicast addresses. (have I beaten this
to death yet?)

>
>> On a related question do
>> you expect the switch asic to trap any packets with MAC addresses in
>> the multi/unicast address lists and send them to the correct netdev? Or
>> will the switch forward them using normal FDB tables?
>>
>
> I think there would be a separate table for that. Roopa, can you check
> with the ASICs you guys work on? The point i was trying to make above
> is today there is a uni/multicast list or table of sorts that all NICs
> expose.
> There's always the hack of a "cpu port". I have also seen the "cpu port"
> being conceptualized in L3 tables to imply "next hop is cpu" where you
> have an IP address owned by the host; so maybe we need a concept of a
> cpu port or again the revival of TheThing class device.

OK the confusing part of "cpu port" to me is in a host nic trying to
map this abstraction onto it implies a host nic may have many "cpu
ports".

Thanks,
.John

>
> cheers,
> jamal
>


-- 
John Fastabend         Intel Corporation
