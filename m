From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] mpls: modify RTA_NEWDST netlink attribute to include
 family
Date: Fri, 15 May 2015 11:18:02 -0700
Message-ID: <5556385A.1070709@cumulusnetworks.com>
References: <1431664722-59539-1-git-send-email-roopa@cumulusnetworks.com> <877fsa2vs1.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32932 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754957AbbEOSSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 14:18:04 -0400
Received: by padbw4 with SMTP id bw4so21426304pad.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 11:18:03 -0700 (PDT)
In-Reply-To: <877fsa2vs1.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/14/15, 11:35 PM, Eric W. Biederman wrote:
> roopa@cumulusnetworks.com writes:
>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> RTA_NEWDST netlink attribute today is used to carry mpls
>> labels. This patch encodes family in RTA_NEWDST.
>>
>> RTA_NEWDST by its name and its use in iproute2 can be
>> used as a generic new dst. But it is currently used only for
>> mpls labels ie with family AF_MPLS. Encoding family in the
>> attribute will help its reuse in the future.
>>
>> One usecase where family with RTA_NEWDST becomes necessary
>> is when we implement mpls label edge router function.
> I don't think this makes any sense.
>
> How do you change the destination address on a packet to a value in
> another protocol?  None of IPv4, IPv6, and MPLS support that.
>
> Aka this attribute represents DNAT.

thanks for that clarification (some details on what i was trying to do 
is at the end of this email).
>
>
>> This is a uapi change but RTA_NEWDST has not made
>> into any release yet. so, trying to rush this change into
>> 4.1 if acceptable.
>>
>> (iproute2 patch will follow)
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>> eric, if you had already thought about other ways to represent
>> labels for LER function, pls let me know. I am looking for suggestions.
> I have to some extent, nothing I am completely pleased with yet but
> enough that I can narrow things down to some extent.
>
> I believe you are referring to the case where we have an ipv4 packet
> or an ipv6 packet and we are inserting it into an mpls tunnel for the
> next step of it's travel.  Egress from mpls appears to already be
> convered.
yes, correct.
>
> The bounding set of challenges looks something like this:
> - We might be placing a full routing table into mpls with
>    a different mpls tunnel for each different route.
>    A full routing table today runs about 1 million routes
>    so we need to support inserting into the ballpark of 1 million
>    different mpls tunnels.
>    As it happens 1 million is also 2^20 or the number of mpls labels.
>
> At 1 million tunnels that rules out using network devices.
>
> Network devices have two basic things that cause scalability problems.
> - struct netdevice and all of sysfs and sysctl overheads fixable
>    but they run at about 32K today.
> - The accounting of ingress and egress packets.
>    It takes a lot of percpu counters to make accounting fast
>    so I think fundamentally we want something without counters.

agreed. And we have the same conclusions. device is not an option.
> Which lead me to look at the kernel xfrm subsystem.  xfrm is a close
> match in requirements.  But having to do a second inefficient lookup and
> lookup on more than what we normally used to route a packet seems
> wrong. Not hooking into the routing tables seems wrong.  The xfrm data
> structures themselves seem heavy weight for simple low cost
> encapsulation.
I have not looked at the xfrm infrastructure in detail. will do so.
>
>
> So I think we need to build yet another infrastructure for dealing with
> light weight tunnels (not just mpls).

ok, I was looking for a word to describe tunnels like mpls..., 'light 
weight tunnels'
sounds good.
>
> What I would propose would be a new infrastructure for dealing with
> simple stateless tunnels.  (AKA tunneling over IP or UDP or MPLS is fine
> but tunneling over TCP or otherwise needing smarts to insert a packet
> into a tunnel is a no-go).
>
> To support entering these tunnels and egressing from these tunnels we
> need a number that would represent the tunnel type that is linux
> specific.  This tunnel type would be a superset of the ipv4/ipv6
> protocol number that is stored in /etc/protocol and
> http://www.iana.org/assignments/protocol-numbers As well as being a
> superset the pseudo wire types
> http://www.iana.org/assignments/pwe3-parameters
> There are mpls tunnels that are not pseudo wires and there are
> tunnels over ip that are encoded in udp are something else as well.
>
> I believe I would represent this in rtnetlink with a new attribute
> RTA_ENCAP.  The current idea in my mind is that RTA_ENCAP would include
> the encapsulation type, a set of fixed headers and possibly some nested
> attributes (like output device), probably RTA_ENCAP and possibly
> RTA_DST.
ok..

>
> At an implementation level I would hook these to the ipv4 and ipv6
> routing tables at the same place as the destination network device,
> possibly sharing storage with where we put the destination network
> device today.
>
> We should be able to use dst->output to do all of the work and thus be
> able to use many if not all of the same hooks as the fast path of xfrm.
>
> We definitely need an ecapsulation method because we need to deal with
> things like the ttl, mtu and fragmentation and so we need to propogate
> bits algorithmically between the different layers.
>
> There is also the complication that ip over mpls natively vs ip over an
> mpls pseudo wire while in practice have the same encoding of the mpls
> labels they appear propogate the ttl differently.  In one case the ttl
> from the inner packet propogates to the outer packet during
> encapsulation and propogates to the inner packet when deccapsulating,
> and in the other case the mpls tunnel is treated as a single hop
> by the ip layer.
>
>
> So I think the right solution is to do the leg work and come up with
> an RTA_ENCAP netlink option, and the associated
>
>
> The cheap hack version of this is to use RTA_FLOW and encode a 32bit
> number in the routing table and use a magic device to look up that 32bit
> number in the mpls routing table (or possibly an mpls flow table)
> and use that to generate the mpls labels.
>
> I don't think we want add the cheap hack.  I think we want a good
> version that can work for all simple well defined tunnel types like
> mpls, gre, ipip, vxlan?, etc.
>
>
> I think we also will want a small layer of indirection in the
> implementation of RTA_ENCAP such that we can define a simple
> encapsulation separately from defining the route.  For IPv4 with in some
> cases 8 different prefixes for a single destination address, in the
> general case, and internal to a companies network I suspect the
> aggregation level can be much higher.
>
> What such an encapsulation would be is that we would have a tunnel
> table with simple integer index, and RTA_ENCAP would just hold
> that index to that tunnel.  The routing table would hold a reference
> counted pointer to the tunnel (so no extra lookups required in the fast
> path), and some other bits of netwlink would create and destroy the
> light-weight encapsulations.

ok, thanks for all the thoughts on this. I was not thinking separate 
tunnel table.
>
> Anyway that is my brainstorm on how things should look, and I really
> don't think extending RTA_NEWDST makes much if any sense at all.
> RTA_NEWDST is just DNAT.
Let me tell you where I was going with RTA_NEWDST: I was completely on 
board with all your
hints on a separate generic encapsulation layer for such "light weigh 
tunnels" in
  your previous emails on this. The part that wasn't clear was a 
separate tunnel table.

 From what i saw, mpls today was the only such light weight tunnel. And, 
to me RTA_NEWDST
was to some extent RTA_ENCAP you were talking about. Clearly i seem to 
have ignored all the other
encapsulation parameters that may need to go into it :). But, i guess in 
my mind i was thinking
those will be additional attributes. But agree, a new nested attribute 
could be a better option.

 From IPv4 for example, to me this looked something like adding the below.

ip route add 10.1.1.0/30 as mpls 200 via inet 10.1.1.2 dev swp1

the 'mpls 200' goes into RTA_NEWDST.

And from ipv4 code you look at the encap family and pass it on to the 
respective output func (i was looking at a possible
abstraction layer here...maybe something like xfrm covering different 
tunnel types like you mention above).

In the hacked up version of my patch (which i was not going to post if 
it looked like a hack anyways),
  i essentially set the dst->output to mpls_output.

I will see if I can come up with something on the lines of RTA_ENCAP you 
share above.

Thanks for the details eric! appreciate it.
