From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 0/4] net: mpls: Allow users to configure more
 labels per route
Date: Mon, 27 Mar 2017 11:39:10 +0100
Message-ID: <5fe416c3-3e56-4e31-f92b-33e3e7b2e3c0@brocade.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
 <87shm1np5h.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <roopa@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:33751 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750781AbdC0Kjg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 06:39:36 -0400
In-Reply-To: <87shm1np5h.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/17 19:15, Eric W. Biederman wrote:
> David Ahern <dsa@cumulusnetworks.com> writes:
>
>> Bump the maximum number of labels for MPLS routes from 2 to 12. To keep
>> memory consumption in check the labels array is moved to the end of mpls_nh
>> and mpls_iptunnel_encap structs as a 0-sized array. Allocations use the
>> maximum number of labels across all nexthops in a route for LSR and the
>> number of labels configured for LWT.
>>
>> The mpls_route layout is changed to:
>>
>>    +----------------------+
>>    | mpls_route           |
>>    +----------------------+
>>    | mpls_nh 0            |
>>    +----------------------+
>>    | alignment padding    |   4 bytes for odd number of labels; 0 for even
>>    +----------------------+
>>    | via[rt_max_alen] 0   |
>>    +----------------------+
>>    | alignment padding    |   via's aligned on sizeof(unsigned long)
>>    +----------------------+
>>    | ...                  |
>>
>> Meaning the via follows its mpls_nh providing better locality as the
>> number of labels increases. UDP_RR tests with namespaces shows no impact
>> to a modest performance increase with this layout for 1 or 2 labels and
>> 1 or 2 nexthops.
>>
>> The new limit is set to 12 to cover all currently known segment
>> routing use cases.
>
> How does this compare with running the packet a couple of times through
> the mpls table to get all of the desired labels applied?

At the moment (i.e setting output interface for a route to the loopback 
interface) the TTL would currently be calculated incorrectly since it'll 
be decremented each time the packet is run through the input processing. 
If that was avoided, then the only issue would be the lower performance.

>
> I can certainly see the case in an mpls tunnel ingress where this might
> could be desirable.    Which is something you implement in your last
> patch.  However is it at all common to push lots of labels at once
> during routing?
>
> I am probably a bit naive but it seems absurd to push more
> than a handful of labels onto a packet as you are routing it.

 From draft-ietf-spring-segment-routing-mpls-07:

    Note that the kind of deployment of Segment Routing may affect the
    depth of the MPLS label stack.  As every segment in the list is
    represented by an additional MPLS label, the length of the segment
    list directly correlates to the depth of the label stack.
    Implementing a long path with many explicit hops as a segment list
    may thus yield a deep label stack that would need to be pushed at the
    head of the SR tunnel.

    However, many use cases would need very few segments in the list.
    This is especially true when taking good advantage of the ECMP aware
    routing within each segment.  In fact most use cases need just one
    additional segment and thus lead to a similar label stack depth as
    e.g.  RSVP-based routing.

The summary is that when using short-path routing then the number of 
labels needed to be pushed on will be small (2 or 3). However, if using 
SR to implement traffic engineering through a list of explicit hops then 
the number of labels pushed could be much greater and up to the diameter 
of the IGP network. Traffic engineering like this is not unusual.

Thanks,
Rob
