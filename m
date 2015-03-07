From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 8/8] ipmpls: Basic device for injecting packets
 into an mpls tunnel
Date: Sat, 7 Mar 2015 10:36:17 +0000
Message-ID: <54FAD4A1.7070008@brocade.com>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>	<87lhjlvriq.fsf@x220.int.ebiederm.org>	<CAMs_D1-KtgYEG4-4H7L6uWmUYw-vM2pnqVfDJJECPR+v6Y4QTw@mail.gmail.com>	<87oao7cznh.fsf@x220.int.ebiederm.org>	<CAMs_D18nbQwaFaWd9ojG3b_0G+PzCsSPGnX3_bNAU8MQJ-BhFg@mail.gmail.com> <871tl39q8v.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	roopa <roopa@cumulusnetworks.com>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	"santiago@crfreenet.org" <santiago@crfreenet.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:52809 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754419AbbCGKgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 05:36:46 -0500
In-Reply-To: <871tl39q8v.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/15 19:52, Eric W. Biederman wrote:
> Vivek Venkatraman <vivek@cumulusnetworks.com> writes:
>
>> On Thu, Mar 5, 2015 at 6:00 AM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>>> For going from normal ip routing to mpls routing somewhere we need the
>>> the destination ip prefix to mpls tunnel mapping. There are a couple of
>>> possible ways this could be solved.
>>> - One ingress network device per mpls tunnel.
>>> - One ingress network device and with with a a configurable routing
>>>    prefix to mpls mapping.  Possibly loaded on the fly.  net/atm/clip.c
>>>    does something like this for ATM virtual circuits.
>>> - One ingress network device that looks at IP_ROUTE_CLASSID and
>>>    use that to select the mpls labels to use.
>>> - Teach the IP network stack how to insert packets in tunnels without
>>>    needing a magic netdevice.
>>>
>>
>> I feel it should be along the lines of "teach the IP network stack how
>> to push labels".
>
> That phrasing sets off alarms bells in my mind of mpls specific hacks in
> the kernel, which most likely will cause performance regression and
> maintenance complications.

Other than the TTL and label-use issues already pointed out, it will 
also be tricky to perform UCMP & ECMP with a mix of labeled and 
unlabeled paths, unless the forwarding information that the routing 
protocols install in the imposition case is substantially different from 
the incoming-label case (in which case it will overly complicate the 
routing protocols).

There are also cases where it's highly desirable to use different 
subsets of available paths for incoming IP traffic, compared to incoming 
labeled traffic (eiBGP multipath) and this could be tricky to do without 
the IP stack doing the selection of the path to use.

There's also the issue of memory usage with route scale to be concerned 
with, with some of the solutions being better in this respect than 
others. Naturally, the "teach the IP network stack now to push labels" 
will scale the best, especially if routing information were to be shared 
with the label table where possible.

>
>> In general, MPLS LSPs can be setup as hop-by-hop
>> routed LSPs (when using a signaling protocol like LDP or BGP) as well
>> as tunnels that may take a different path than normal routing. I feel
>> it is good if the dataplane can support both models. In the former,
>> the IP network stack should push the labels which are just
>> encapsulation and then just transmit on the underlying netdevice that
>> corresponds to the neighbor interface. To achieve this, maybe it is
>> the neighbor (nexthop) that has to reference the mpls_route. In the
>> latter (LSPs are treated as tunnels and/or this is the only model
>> supported), the IP network stack would still need to impose any inner
>> labels (i.e., VPN or pseudowire, later on Entropy or Segment labels)
>> and then transmit over the tunnel netdevice which would impose the
>> tunnel label.
>
> Potentially.  This part of the discussion has reached the point where I
> need to see code to carry this part of the discussion any farther.

Another discussion point is whether using collapsed of label stacks for 
VPN prefixes will work adequately under scale when faced with IGP 
reconvergence events. The alternative would be to allow the control 
plane to install "push-and-lookup" type forwarding entries, essentially 
behaving as a recursive MPLS route in a similar way to what was proposed 
in the ipmpls tunnel - this would separate the VPN routing entries from 
the IGP ones, meaning that the forwarding information for the latter can 
change independently from the former. This can be done without further 
changes to the netlink protocol, so isn't a big priority right now.

Thanks,
Rob

>
> Eric
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
