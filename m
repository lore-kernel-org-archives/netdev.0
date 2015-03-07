From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 8/8] ipmpls: Basic device for injecting packets into an mpls tunnel
Date: Sat, 07 Mar 2015 15:12:14 -0600
Message-ID: <87mw3o5x75.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<87lhjlvriq.fsf@x220.int.ebiederm.org>
	<CAMs_D1-KtgYEG4-4H7L6uWmUYw-vM2pnqVfDJJECPR+v6Y4QTw@mail.gmail.com>
	<87oao7cznh.fsf@x220.int.ebiederm.org>
	<CAMs_D18nbQwaFaWd9ojG3b_0G+PzCsSPGnX3_bNAU8MQJ-BhFg@mail.gmail.com>
	<871tl39q8v.fsf@x220.int.ebiederm.org> <54FAD4A1.7070008@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vivek Venkatraman <vivek@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	roopa <roopa@cumulusnetworks.com>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	"santiago\@crfreenet.org" <santiago@crfreenet.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:41153 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753308AbbCGVP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 16:15:56 -0500
In-Reply-To: <54FAD4A1.7070008@brocade.com> (Robert Shearman's message of
	"Sat, 7 Mar 2015 10:36:17 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> On 05/03/15 19:52, Eric W. Biederman wrote:
>> Vivek Venkatraman <vivek@cumulusnetworks.com> writes:
>>
>>> On Thu, Mar 5, 2015 at 6:00 AM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>>>> For going from normal ip routing to mpls routing somewhere we need the
>>>> the destination ip prefix to mpls tunnel mapping. There are a couple of
>>>> possible ways this could be solved.
>>>> - One ingress network device per mpls tunnel.
>>>> - One ingress network device and with with a a configurable routing
>>>>    prefix to mpls mapping.  Possibly loaded on the fly.  net/atm/clip.c
>>>>    does something like this for ATM virtual circuits.
>>>> - One ingress network device that looks at IP_ROUTE_CLASSID and
>>>>    use that to select the mpls labels to use.
>>>> - Teach the IP network stack how to insert packets in tunnels without
>>>>    needing a magic netdevice.
>>>>
>>>
>>> I feel it should be along the lines of "teach the IP network stack how
>>> to push labels".
>>
>> That phrasing sets off alarms bells in my mind of mpls specific hacks in
>> the kernel, which most likely will cause performance regression and
>> maintenance complications.
>
> Other than the TTL and label-use issues already pointed out, it will also be
> tricky to perform UCMP & ECMP with a mix of labeled and unlabeled paths, unless
> the forwarding information that the routing protocols install in the imposition
> case is substantially different from the incoming-label case (in which case it
> will overly complicate the routing protocols).

Six of one half a dozen of the other.  But I agree keeping track of
labels that are only used to forward IP traffic is likely an unnecessary
complication.

> There are also cases where it's highly desirable to use different subsets of
> available paths for incoming IP traffic, compared to incoming labeled traffic
> (eiBGP multipath) and this could be tricky to do without the IP stack doing the
> selection of the path to use.

We definitely want to use the standard routing table to do routing.

> There's also the issue of memory usage with route scale to be concerned with,
> with some of the solutions being better in this respect than others. Naturally,
> the "teach the IP network stack now to push labels" will scale the best,
> especially if routing information were to be shared with the label table where
> possible.
>
>>
>>> In general, MPLS LSPs can be setup as hop-by-hop
>>> routed LSPs (when using a signaling protocol like LDP or BGP) as well
>>> as tunnels that may take a different path than normal routing. I feel
>>> it is good if the dataplane can support both models. In the former,
>>> the IP network stack should push the labels which are just
>>> encapsulation and then just transmit on the underlying netdevice that
>>> corresponds to the neighbor interface. To achieve this, maybe it is
>>> the neighbor (nexthop) that has to reference the mpls_route. In the
>>> latter (LSPs are treated as tunnels and/or this is the only model
>>> supported), the IP network stack would still need to impose any inner
>>> labels (i.e., VPN or pseudowire, later on Entropy or Segment labels)
>>> and then transmit over the tunnel netdevice which would impose the
>>> tunnel label.
>>
>> Potentially.  This part of the discussion has reached the point where I
>> need to see code to carry this part of the discussion any farther.
>
> Another discussion point is whether using collapsed of label stacks for VPN
> prefixes will work adequately under scale when faced with IGP reconvergence
> events. The alternative would be to allow the control plane to install
> "push-and-lookup" type forwarding entries, essentially behaving as a recursive
> MPLS route in a similar way to what was proposed in the ipmpls tunnel - this
> would separate the VPN routing entries from the IGP ones, meaning that the
> forwarding information for the latter can change independently from the
> former. This can be done without further changes to the netlink protocol, so
> isn't a big priority right now.

You can currently make multiple trips through the MPLS forwarding
stack, you just need to set your output interface to "lo".   If that
case becomes heavily used we may want to optimize it, but the code
as implemented should 

Eric
