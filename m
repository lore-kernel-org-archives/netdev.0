From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 1/4] net: mpls: Convert number of nexthops to u8
Date: Tue, 28 Mar 2017 13:39:57 -0500
Message-ID: <87k2799req.fsf@xmission.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
        <1490461408-9551-2-git-send-email-dsa@cumulusnetworks.com>
        <871stjmn0o.fsf@xmission.com>
        <b370c097-d0ad-95c5-2687-264da22d37d6@cumulusnetworks.com>
        <87wpbagwk5.fsf@xmission.com>
        <78820aeb-6c41-5f71-90b6-ff41a91ca088@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        rshearma@brocade.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57543 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752617AbdC1SpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 14:45:13 -0400
In-Reply-To: <78820aeb-6c41-5f71-90b6-ff41a91ca088@cumulusnetworks.com> (David
        Ahern's message of "Tue, 28 Mar 2017 09:25:54 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> On 3/27/17 4:54 PM, Eric W. Biederman wrote:
>> It is absolutely a no-brainer to change rt_nhn to a u8.  And I very much
>> appreciate all work to keep mpls_route into a single cache line.  As in
>> practices that is one of the most important parts to performance.
>> 
>> Which leads to the functions mpls_ifup, mpls_ifdown, and
>> mpls_select_multipath.
>> 
>> To make this all work correctly we need a couple of things.
>> - A big fat comment on struct mpls_route and mpls_nh about how
>>   and why these structures are modified and not replaced during
>>   nexthop processing.  Including the fact that it all modifications
>>   may only happen with rntl_lock held.
>> 
>> - The use of READ_ONCE and WRITE_ONCE on all rt->rt_nhn_alive accesses,
>>   that happen after the route is installed (and is thus rcu reachable).
>> 
>> - The use of READ_ONCE and WRITE_ONCE on all nh->nh_flags accesses,
>>   that happen after the route is installed (and is thus rcu reachable).
>
> For both of these, mpls_select_multipath does need to use READ_ONCE to
> read the nh_flags and rt_nhn_alive. In this case it is reading a value
> that could change behind its back.
>
> The READ_ONCE is not necessary for mpls_ifdown or mpls_ifup as these are
> the functions that change the values. These 2 functions only need a
> WRITE_ONCE for both struct members.

True.  We don't need READ_ONCE under rtnl_lock which we use to protect writes.

Eric
