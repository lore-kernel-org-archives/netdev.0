From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 0/4] net: mpls: Allow users to configure more labels per route
Date: Mon, 27 Mar 2017 22:08:57 -0500
Message-ID: <871stiayie.fsf@xmission.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
        <87shm1np5h.fsf@xmission.com>
        <5fe416c3-3e56-4e31-f92b-33e3e7b2e3c0@brocade.com>
        <608c60ac-7669-86f0-b0ef-02add5287009@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:44385 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753864AbdC1DOl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 23:14:41 -0400
In-Reply-To: <608c60ac-7669-86f0-b0ef-02add5287009@cumulusnetworks.com> (David
        Ahern's message of "Mon, 27 Mar 2017 08:21:24 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> On 3/27/17 4:39 AM, Robert Shearman wrote:
>> On 25/03/17 19:15, Eric W. Biederman wrote:
>>> David Ahern <dsa@cumulusnetworks.com> writes:
>>>
>>>> Bump the maximum number of labels for MPLS routes from 2 to 12. To keep
>>>> memory consumption in check the labels array is moved to the end of
>>>> mpls_nh
>>>> and mpls_iptunnel_encap structs as a 0-sized array. Allocations use the
>>>> maximum number of labels across all nexthops in a route for LSR and the
>>>> number of labels configured for LWT.
>>>>
>>>> The mpls_route layout is changed to:
>>>>
>>>>    +----------------------+
>>>>    | mpls_route           |
>>>>    +----------------------+
>>>>    | mpls_nh 0            |
>>>>    +----------------------+
>>>>    | alignment padding    |   4 bytes for odd number of labels; 0 for
>>>> even
>>>>    +----------------------+
>>>>    | via[rt_max_alen] 0   |
>>>>    +----------------------+
>>>>    | alignment padding    |   via's aligned on sizeof(unsigned long)
>>>>    +----------------------+
>>>>    | ...                  |
>>>>
>>>> Meaning the via follows its mpls_nh providing better locality as the
>>>> number of labels increases. UDP_RR tests with namespaces shows no impact
>>>> to a modest performance increase with this layout for 1 or 2 labels and
>>>> 1 or 2 nexthops.
>>>>
>>>> The new limit is set to 12 to cover all currently known segment
>>>> routing use cases.
>>>
>>> How does this compare with running the packet a couple of times through
>>> the mpls table to get all of the desired labels applied?
>> 
>> At the moment (i.e setting output interface for a route to the loopback
>> interface) the TTL would currently be calculated incorrectly since it'll
>> be decremented each time the packet is run through the input processing.
>> If that was avoided, then the only issue would be the lower performance.
>
> We have the infrastructure to add all the labels on one pass. It does
> not make sense to recirculate the packet to get the same effect.

I was really asking what are the advantages and disadvantages of this
change rather than suggesting it was a bad idea.  The information about
ttl is useful.

Adding that this will route packets with more labels more quickly than
the recirculation method is also useful to know.

>>> I can certainly see the case in an mpls tunnel ingress where this might
>>> could be desirable.    Which is something you implement in your last
>>> patch.  However is it at all common to push lots of labels at once
>>> during routing?
>>>
>>> I am probably a bit naive but it seems absurd to push more
>>> than a handful of labels onto a packet as you are routing it.
>> 
>> From draft-ietf-spring-segment-routing-mpls-07:
>> 
>>    Note that the kind of deployment of Segment Routing may affect the
>>    depth of the MPLS label stack.  As every segment in the list is
>>    represented by an additional MPLS label, the length of the segment
>>    list directly correlates to the depth of the label stack.
>>    Implementing a long path with many explicit hops as a segment list
>>    may thus yield a deep label stack that would need to be pushed at the
>>    head of the SR tunnel.
>> 
>>    However, many use cases would need very few segments in the list.
>>    This is especially true when taking good advantage of the ECMP aware
>>    routing within each segment.  In fact most use cases need just one
>>    additional segment and thus lead to a similar label stack depth as
>>    e.g.  RSVP-based routing.
>> 
>> The summary is that when using short-path routing then the number of
>> labels needed to be pushed on will be small (2 or 3). However, if using
>> SR to implement traffic engineering through a list of explicit hops then
>> the number of labels pushed could be much greater and up to the diameter
>> of the IGP network. Traffic engineering like this is not unusual.
>
> And the thread on the FRR mailing list has other ietf references. The
> summary is that are plenty of use cases for more labels on ingress
> (ip->mpls) and route paths (mpls->mpls). I did see one comment that 12
> may not be enough for all use cases. Why not 16 or 20?
>
> This patch set bumps the number of labels and the performance impact is
> only to users that use a high label count. Other than a temporary stack
> variable for installing the routes, no memory is allocated based on the
> limit as an array size, so we could just as easily go with 16 - a nice
> round number.

Overall I like what is being accomplished by this patchset.
I especially like the fact that the forwarding path is left
essentially unchanged, and that the struct mpls_route shirnks a little
for the common case.

I believe we should just kill MAX_NEW_LABELS.

I think the only significant change from your patch is the removal of an
array from mpls_route_config.

With the removal of MAX_NEW_LABELS I would replace it by a sanity check
in mpls_rt_alloc that verifies that the amount we are going to allocate
for struct mpls_route is < PAGE_SIZE.  Anything larger is just
asking for trouble.

That should put our practical limit just a little bit below 32 nexthops
adding 32 labels each.

Eric
