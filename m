From: Vivek Venkatraman <vivek@cumulusnetworks.com>
Subject: Re: [PATCH net-next 8/8] ipmpls: Basic device for injecting packets
 into an mpls tunnel
Date: Thu, 5 Mar 2015 08:25:27 -0800
Message-ID: <CAMs_D18nbQwaFaWd9ojG3b_0G+PzCsSPGnX3_bNAU8MQJ-BhFg@mail.gmail.com>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<87lhjlvriq.fsf@x220.int.ebiederm.org>
	<CAMs_D1-KtgYEG4-4H7L6uWmUYw-vM2pnqVfDJJECPR+v6Y4QTw@mail.gmail.com>
	<87oao7cznh.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:44019 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbbCEQZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 11:25:28 -0500
Received: by wibhm9 with SMTP id hm9so16518436wib.2
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 08:25:27 -0800 (PST)
In-Reply-To: <87oao7cznh.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 5, 2015 at 6:00 AM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> Vivek Venkatraman <vivek@cumulusnetworks.com> writes:
>
>> It is great to see an MPLS data plane implementation make it into the
>> kernel. I have a couple of questions on this patch.
>>
>> On Wed, Feb 25, 2015 at 9:18 AM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>>
>>>
>>> Allow creating an mpls tunnel endpoint with
>>>
>>> ip link add type ipmpls.
>>>
>>> This tunnel has an mpls label for it's link layer address, and by
>>> default sends all ingress packets over loopback to the local MPLS
>>> forwarding logic which performs all of the work.
>>>
>>
>> Is it correct that to achieve IPoMPLS, each LSP has to be installed as
>> a link/netdevice?
>
> This is still a bit in flux.  The ingress logic is not yet merged.  When
> I resent the patches I did not resend this one as I am less happy with
> it than I am about the others and the problem is orthogonal.
>
>> If ingress packets loopback with the label associated with the link to
>> hit the MPLS forwarding logic, how does it work if each packet has to
>> be then forwarded with a different label stack? One use case is a
>> common IP/MPLS application such as L3VPNs (RFC 4364) where multiple
>> VPNs may reside over the same LSP, each having its own VPN (inner)
>> label.
>
> If we continue using this approach (which I picked because it was simple
> for bootstrapping and testing) the way it would work is that you have a
> local label that when you forward packets with that label all of the
> other needed labels are pushed.
>

Yes, I can see that this approach is simple for bootstrapping.

However, I think the need for a local label is going to be bit of a
challenge as well as not intuitive. I say the latter because at an
ingress LSP (i.e., the kernel is performing an MPLS LER function), you
are only pushing labels just based on normal IP routing (or L2, if
implementing a pseudowire), so needing to assign a local label that
then gets popped seems convoluted. The challenge is because the local
label has to be unique for the label stack that needs to be imposed,
it is not just a 1-to-1 mapping with the tunnel.

> That said I think the approach I chose has a lot going for it.
>
> Fundamentally I think the ingress to an mpls tunnel fundamentally needs
> the same knobs and parameters as struct mpls_route.  Aka which machine
> do we forward the packets to, and which labels do we push.
>
> The extra decrement of the hop count on ingress is not my favorite
> thing.
>
> The question in my mind is how do we select which mpls route to use.
> Spending a local label for that purpose does not seem particularly
> unreasonable.
>
> Using one network device per tunnel it a bit more questionable.  I keep
> playing with ideas that would allow a single device to serve multiple
> mpls tunnels.
>

For the scenario I mentioned (L3VPNs) which would be common at the
edge, isn't it a network device per "VPN" (or more precisely, per VPN
per LSP)? I don't think this scales well.

> For going from normal ip routing to mpls routing somewhere we need the
> the destination ip prefix to mpls tunnel mapping. There are a couple of
> possible ways this could be solved.
> - One ingress network device per mpls tunnel.
> - One ingress network device and with with a a configurable routing
>   prefix to mpls mapping.  Possibly loaded on the fly.  net/atm/clip.c
>   does something like this for ATM virtual circuits.
> - One ingress network device that looks at IP_ROUTE_CLASSID and
>   use that to select the mpls labels to use.
> - Teach the IP network stack how to insert packets in tunnels without
>   needing a magic netdevice.
>

I feel it should be along the lines of "teach the IP network stack how
to push labels". In general, MPLS LSPs can be setup as hop-by-hop
routed LSPs (when using a signaling protocol like LDP or BGP) as well
as tunnels that may take a different path than normal routing. I feel
it is good if the dataplane can support both models. In the former,
the IP network stack should push the labels which are just
encapsulation and then just transmit on the underlying netdevice that
corresponds to the neighbor interface. To achieve this, maybe it is
the neighbor (nexthop) that has to reference the mpls_route. In the
latter (LSPs are treated as tunnels and/or this is the only model
supported), the IP network stack would still need to impose any inner
labels (i.e., VPN or pseudowire, later on Entropy or Segment labels)
and then transmit over the tunnel netdevice which would impose the
tunnel label.


> None of the ideas I have thought of so far feels just right.
>
> At the same time I don't think there is a lot of wiggle room in the
> fundmanetals.  Mapping ip routes to mpls tunnels in a way that software
> can process quickly and efficiently and the code is maintainable, does
> not leave a lot of wiggle room at the end of the day.
>
> Eric

Vivek
