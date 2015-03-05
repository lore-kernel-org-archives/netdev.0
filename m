From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 8/8] ipmpls: Basic device for injecting packets into an mpls tunnel
Date: Thu, 05 Mar 2015 13:52:00 -0600
Message-ID: <871tl39q8v.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<87lhjlvriq.fsf@x220.int.ebiederm.org>
	<CAMs_D1-KtgYEG4-4H7L6uWmUYw-vM2pnqVfDJJECPR+v6Y4QTw@mail.gmail.com>
	<87oao7cznh.fsf@x220.int.ebiederm.org>
	<CAMs_D18nbQwaFaWd9ojG3b_0G+PzCsSPGnX3_bNAU8MQJ-BhFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: Vivek Venkatraman <vivek@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:43060 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbbCETzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 14:55:37 -0500
In-Reply-To: <CAMs_D18nbQwaFaWd9ojG3b_0G+PzCsSPGnX3_bNAU8MQJ-BhFg@mail.gmail.com>
	(Vivek Venkatraman's message of "Thu, 5 Mar 2015 08:25:27 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vivek Venkatraman <vivek@cumulusnetworks.com> writes:

> On Thu, Mar 5, 2015 at 6:00 AM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>> Vivek Venkatraman <vivek@cumulusnetworks.com> writes:
>>
>>> It is great to see an MPLS data plane implementation make it into the
>>> kernel. I have a couple of questions on this patch.
>>>
>>> On Wed, Feb 25, 2015 at 9:18 AM, Eric W. Biederman
>>> <ebiederm@xmission.com> wrote:
>>>>
>>>>
>>>> Allow creating an mpls tunnel endpoint with
>>>>
>>>> ip link add type ipmpls.
>>>>
>>>> This tunnel has an mpls label for it's link layer address, and by
>>>> default sends all ingress packets over loopback to the local MPLS
>>>> forwarding logic which performs all of the work.
>>>>
>>>
>>> Is it correct that to achieve IPoMPLS, each LSP has to be installed as
>>> a link/netdevice?
>>
>> This is still a bit in flux.  The ingress logic is not yet merged.  When
>> I resent the patches I did not resend this one as I am less happy with
>> it than I am about the others and the problem is orthogonal.
>>
>>> If ingress packets loopback with the label associated with the link to
>>> hit the MPLS forwarding logic, how does it work if each packet has to
>>> be then forwarded with a different label stack? One use case is a
>>> common IP/MPLS application such as L3VPNs (RFC 4364) where multiple
>>> VPNs may reside over the same LSP, each having its own VPN (inner)
>>> label.
>>
>> If we continue using this approach (which I picked because it was simple
>> for bootstrapping and testing) the way it would work is that you have a
>> local label that when you forward packets with that label all of the
>> other needed labels are pushed.
>>
>
> Yes, I can see that this approach is simple for bootstrapping.
>
> However, I think the need for a local label is going to be bit of a
> challenge as well as not intuitive. I say the latter because at an
> ingress LSP (i.e., the kernel is performing an MPLS LER function), you
> are only pushing labels just based on normal IP routing (or L2, if
> implementing a pseudowire), so needing to assign a local label that
> then gets popped seems convoluted. The challenge is because the local
> label has to be unique for the label stack that needs to be imposed,
> it is not just a 1-to-1 mapping with the tunnel.

Agreed.

>> That said I think the approach I chose has a lot going for it.
>>
>> Fundamentally I think the ingress to an mpls tunnel fundamentally needs
>> the same knobs and parameters as struct mpls_route.  Aka which machine
>> do we forward the packets to, and which labels do we push.
>>
>> The extra decrement of the hop count on ingress is not my favorite
>> thing.
>>
>> The question in my mind is how do we select which mpls route to use.
>> Spending a local label for that purpose does not seem particularly
>> unreasonable.
>>
>> Using one network device per tunnel it a bit more questionable.  I keep
>> playing with ideas that would allow a single device to serve multiple
>> mpls tunnels.
>>
>
> For the scenario I mentioned (L3VPNs) which would be common at the
> edge, isn't it a network device per "VPN" (or more precisely, per VPN
> per LSP)? I don't think this scales well.

We need a data structure in the kernel for each
Forwarding Equivalent Class (aka per VPN per LSP) the only question is
how expensive that data structure should be.

In big-O notation the scaling is equal.  The practical question how large
are our constant factors and are they a problem.  If the L3VPN results
in enough entries on a machine then it is a scaling problem otherwise
not so much.

>> For going from normal ip routing to mpls routing somewhere we need the
>> the destination ip prefix to mpls tunnel mapping. There are a couple of
>> possible ways this could be solved.
>> - One ingress network device per mpls tunnel.
>> - One ingress network device and with with a a configurable routing
>>   prefix to mpls mapping.  Possibly loaded on the fly.  net/atm/clip.c
>>   does something like this for ATM virtual circuits.
>> - One ingress network device that looks at IP_ROUTE_CLASSID and
>>   use that to select the mpls labels to use.
>> - Teach the IP network stack how to insert packets in tunnels without
>>   needing a magic netdevice.
>>
>
> I feel it should be along the lines of "teach the IP network stack how
> to push labels".

That phrasing sets off alarms bells in my mind of mpls specific hacks in
the kernel, which most likely will cause performance regression and
maintenance complications.

> In general, MPLS LSPs can be setup as hop-by-hop
> routed LSPs (when using a signaling protocol like LDP or BGP) as well
> as tunnels that may take a different path than normal routing. I feel
> it is good if the dataplane can support both models. In the former,
> the IP network stack should push the labels which are just
> encapsulation and then just transmit on the underlying netdevice that
> corresponds to the neighbor interface. To achieve this, maybe it is
> the neighbor (nexthop) that has to reference the mpls_route. In the
> latter (LSPs are treated as tunnels and/or this is the only model
> supported), the IP network stack would still need to impose any inner
> labels (i.e., VPN or pseudowire, later on Entropy or Segment labels)
> and then transmit over the tunnel netdevice which would impose the
> tunnel label.

Potentially.  This part of the discussion has reached the point where I
need to see code to carry this part of the discussion any farther.

Eric
