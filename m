From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 0/4] net: mpls: Allow users to configure more
 labels per route
Date: Tue, 28 Mar 2017 10:52:10 +0100
Message-ID: <b0f95463-8927-e9b7-0a59-f1e0b3bc1072@brocade.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
 <87shm1np5h.fsf@xmission.com>
 <5fe416c3-3e56-4e31-f92b-33e3e7b2e3c0@brocade.com>
 <608c60ac-7669-86f0-b0ef-02add5287009@cumulusnetworks.com>
 <871stiayie.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <roopa@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:50458 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754217AbdC1Jwg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 05:52:36 -0400
In-Reply-To: <871stiayie.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/03/17 04:08, Eric W. Biederman wrote:
> David Ahern <dsa@cumulusnetworks.com> writes:
>
>> On 3/27/17 4:39 AM, Robert Shearman wrote:
>>> On 25/03/17 19:15, Eric W. Biederman wrote:
>>>> David Ahern <dsa@cumulusnetworks.com> writes:
>>>>
>>>>> Bump the maximum number of labels for MPLS routes from 2 to 12. To keep
>>>>> memory consumption in check the labels array is moved to the end of
>>>>> mpls_nh
>>>>> and mpls_iptunnel_encap structs as a 0-sized array. Allocations use the
>>>>> maximum number of labels across all nexthops in a route for LSR and the
>>>>> number of labels configured for LWT.
>>>>>
>>>>> The mpls_route layout is changed to:
>>>>>
>>>>>    +----------------------+
>>>>>    | mpls_route           |
>>>>>    +----------------------+
>>>>>    | mpls_nh 0            |
>>>>>    +----------------------+
>>>>>    | alignment padding    |   4 bytes for odd number of labels; 0 for
>>>>> even
>>>>>    +----------------------+
>>>>>    | via[rt_max_alen] 0   |
>>>>>    +----------------------+
>>>>>    | alignment padding    |   via's aligned on sizeof(unsigned long)
>>>>>    +----------------------+
>>>>>    | ...                  |
>>>>>
>>>>> Meaning the via follows its mpls_nh providing better locality as the
>>>>> number of labels increases. UDP_RR tests with namespaces shows no impact
>>>>> to a modest performance increase with this layout for 1 or 2 labels and
>>>>> 1 or 2 nexthops.
>>>>>
>>>>> The new limit is set to 12 to cover all currently known segment
>>>>> routing use cases.
>>>>
>>>> How does this compare with running the packet a couple of times through
>>>> the mpls table to get all of the desired labels applied?
>>>
>>> At the moment (i.e setting output interface for a route to the loopback
>>> interface) the TTL would currently be calculated incorrectly since it'll
>>> be decremented each time the packet is run through the input processing.
>>> If that was avoided, then the only issue would be the lower performance.
>>
>> We have the infrastructure to add all the labels on one pass. It does
>> not make sense to recirculate the packet to get the same effect.
>
> I was really asking what are the advantages and disadvantages of this
> change rather than suggesting it was a bad idea.  The information about
> ttl is useful.
>
> Adding that this will route packets with more labels more quickly than
> the recirculation method is also useful to know.

I should also add that not recirculating also avoids having to allocate 
extra local labels, which may be limited in supply in some deployments, 
and avoids the extra control plane/user complexity associated with 
managing the routes associated with the recirculation.

Thanks,
Rob
