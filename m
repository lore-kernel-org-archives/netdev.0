From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net] mpls: modify RTA_NEWDST netlink attribute to include
 family
Date: Tue, 19 May 2015 11:15:03 +0100
Message-ID: <555B0D27.2040008@brocade.com>
References: <1431664722-59539-1-git-send-email-roopa@cumulusnetworks.com> <877fsa2vs1.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vivek@cumulusnetworks.com" <vivek@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:46663 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753870AbbESKPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 06:15:15 -0400
In-Reply-To: <877fsa2vs1.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/05/15 07:35, Eric W. Biederman wrote:
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
>
> I don't think this makes any sense.
>
> How do you change the destination address on a packet to a value in
> another protocol?  None of IPv4, IPv6, and MPLS support that.
>
> Aka this attribute represents DNAT.
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
>
> I have to some extent, nothing I am completely pleased with yet but
> enough that I can narrow things down to some extent.
>
> I believe you are referring to the case where we have an ipv4 packet
> or an ipv6 packet and we are inserting it into an mpls tunnel for the
> next step of it's travel.  Egress from mpls appears to already be
> convered.
>
> The bounding set of challenges looks something like this:
> - We might be placing a full routing table into mpls with
>    a different mpls tunnel for each different route.
>    A full routing table today runs about 1 million routes
>    so we need to support inserting into the ballpark of 1 million
>    different mpls tunnels.
>    As it happens 1 million is also 2^20 or the number of mpls labels.

I'd like to add a couple of other requirements into the mix:
- Allow for prefix-independent convergence of BGP routes for IGP changes 
(BGP-PIC Core - see informational IETF draft-rtgwg-bgp-pic-02). What 
this means is that if the IGP route for the loopback address of a BGP 
peer router changes then all of the BGP routes recursive via that route 
should converge in a time independent of the number of such BGP routes. 
Whilst it might be desirable to have this happen in a pure IP case for 
the full Internet route table, the use of MPLS-VPNs makes this much more 
of a requirement because it scales the problem up by potentially 
multiplying the ~500k routes by the number of VPNs.
- Ensure the TTL is correctly set in both the IP and MPLS header (i.e. 
avoid a re-switch and TTL decrement)

>
> At 1 million tunnels that rules out using network devices.
>
> Network devices have two basic things that cause scalability problems.
> - struct netdevice and all of sysfs and sysctl overheads fixable
>    but they run at about 32K today.
> - The accounting of ingress and egress packets.
>    It takes a lot of percpu counters to make accounting fast
>    so I think fundamentally we want something without counters.
>
> Which lead me to look at the kernel xfrm subsystem.  xfrm is a close
> match in requirements.  But having to do a second inefficient lookup and
> lookup on more than what we normally used to route a packet seems
> wrong. Not hooking into the routing tables seems wrong.  The xfrm data
> structures themselves seem heavy weight for simple low cost
> encapsulation.
>
>
> So I think we need to build yet another infrastructure for dealing with
> light weight tunnels (not just mpls).
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

I really like this idea of having an RTA_ENCAP attribute that can 
specify the encapsulation to be used by any sort of encapsulation that 
might be useful to perform on a per-route basis.

While we're brainstorming, I'll throw out another option: have output 
interface be a virtual interface for the encap type and then having the 
RTA_ENCAP data interpreted by that interface based on skb->dst. Note 
that the interface could be shared by multiple routes with differing 
encap data, but all sharing common parameters. In the case where there 
are no parameters to configure, or they're common to all the routes, 
there would only need to be one instance of the virtual interface (for a 
given namespace).

The encap data for mpls could then store the outgoing labels, interface 
and nexthop. Alternatively, to support PIC as per the above requirement, 
it could store the VPN label and then either a local label allocated for 
the IGP prefix or the recursive nexthop, either of which could then be 
looked up at packet forwarding time to determine the outgoing label, 
interface and nexthop.

Any thoughts on this? The use of the encap-specific virtual interface 
has the advantage of having an object on which parameters like ttl, mtu 
and don't-fragment could be configured and stored, whilst at the same 
time minimising the new infra required.

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

Agreed.

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

As long as the layer of indirection is optional I'm ok with that, as it 
might not be worth if for certain types of encaps that don't need to 
store much more data than the size of a pointer on a 64-bit architecture.

>
> Anyway that is my brainstorm on how things should look, and I really
> don't think extending RTA_NEWDST makes much if any sense at all.
> RTA_NEWDST is just DNAT.
>
> Eric

Thanks,
Rob
