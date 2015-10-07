From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v2 1/2] mpls: multipath support
Date: Tue, 06 Oct 2015 22:38:32 -0500
Message-ID: <877fmz8i13.fsf@x220.int.ebiederm.org>
References: <1444157209-12518-2-git-send-email-roopa@cumulusnetworks.com>
	<87vbajbx4l.fsf@x220.int.ebiederm.org>
	<56142E6E.2070406@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org, rshearma@brocade.com
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:60841 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbbJGDqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 23:46:02 -0400
In-Reply-To: <56142E6E.2070406@cumulusnetworks.com>
	(roopa@cumulusnetworks.com's message of "Tue, 06 Oct 2015 13:26:22
	-0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

roopa <roopa@cumulusnetworks.com> writes:

> On 10/6/15, 12:44 PM, Eric W. Biederman wrote:
>> Roopa Prabhu <roopa@cumulusnetworks.com> writes:
>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This patch adds support for MPLS multipath routes.
>>>
>>> Includes following changes to support multipath:
>>> - splits struct mpls_route into 'struct mpls_route + struct mpls_nh'
>>>
>>> - 'struct mpls_nh' represents a mpls nexthop label forwarding entry
>>>
>>> - moves mpls route and nexthop structures into internal.h
>>>
>>> - A mpls_route can point to multiple mpls_nh structs
>>>
>>> - the nexthops are maintained as a list
>> So I am not certain I like nexthops being a list.  In the practical case
>> introducing this list guarantees that everyone will see at least an
>> extra cache line miss in the forwarding path.
>>
>> In the more abstract sense a list is the wrong data structure.  If the
>> list is so short we can afford to walk it an array is a better data
>> structure.  If we need enough entries to make the memory consumption
>> of an array a concern we want some kind of hash table or tree data
>> structure, because a list will be too long in that case.
>>
>> So can we please not use a list?
> sure, I used arrays the first time. http://marc.info/?l=linux-netdev&m=143932956719398&w=2
> And i am very much ok with an array.  I used list in v2 by following the ipv6 fib code following comments from v1.
>
>
> The only place the lookup is sensitive is in the nexthop selection in datapath. And depending
> on how the selection algorithm works, i am not sure if using a hash table will help there.
> I will look though.
>
> I did prefer an array and If you are ok with an array, I will respin.

Please.  And let's cut out any fields we are not using yet.  If nothing
else lean and mean keeps this code more understandable and reviewable as
at the end of the day there is less of it.

>> I expect we can simplify the data structures by noting that rt_via must
>> be an ethernet mac today so that 6 bytes are enough and 8 bytes gives us
>> a bit extra and aligns things nicely.
>>
>> Also I know it goes away in the next patch but a spinlock taken for
>> every transit through the forwarding path really bugs me.
> yes, agree. I picked that from ipv4 fib. since it goes away with Roberts patch I did not spend any time on it.
>
> thanks for the review.

Eric
