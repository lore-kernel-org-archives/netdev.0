From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Tue, 16 Dec 2014 21:51:05 -0800
Message-ID: <549119C9.3080504@cumulusnetworks.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:46430 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbaLQFvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 00:51:10 -0500
In-Reply-To: <54902E5E.2070405@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/14, 5:06 AM, Jamal Hadi Salim wrote:
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
> Do these NICs not have such a concept?
> An fdb entry has an egress port column; I have seen cases where the
> port is labeled as "Cpu port" which would mean it belongs to the host;
> but in this case it just seems there is no such concept and as Or
> brought up in another email - what does "VLANid" mean in such a case?
> If we go with a CPU port concept,
> We could then use the concept of a vlan filter on a port basis
> but then what happens when you dont have an fdb (majority of cases)?
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
> Maybe what we need is a concept of a "edge relay" extended netdev?
> These things would have an fdb as well down and uplink relay ports that
> can be attached to them.
>
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
> Is there no way to get the unicast/multicast mac addresses for such
> a driver?
> I think that would help bring clarity to my confusion.
>
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
>
>
>> It works OK for host nics (NICS that can't forward between ports) and
>> seems at best confusing for real switch asics.
>
> So if these NICs have fdb entries and i programmed it (meaning setting
> which port a given MAC should be sent to), would it not work?
>
>> On a related question do
>> you expect the switch asic to trap any packets with MAC addresses in
>> the multi/unicast address lists and send them to the correct netdev? Or
>> will the switch forward them using normal FDB tables?
>>
>
> I think there would be a separate table for that. Roopa, can you check
> with the ASICs you guys work on? 
Jamal, yes, AFAICS, we do have a separate table where we add some static 
entries
indicating send to  CPU (example IPV4 and IPV6 link local multicast) and 
such
packets are sent to the correct netdev

> The point i was trying to make above
> is today there is a uni/multicast list or table of sorts that all NICs
> expose.
> There's always the hack of a "cpu port". I have also seen the "cpu port"
> being conceptualized in L3 tables to imply "next hop is cpu" where you
> have an IP address owned by the host; so maybe we need a concept of a
> cpu port or again the revival of TheThing class device.
>
> cheers,
> jamal
>
