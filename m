From: Chris Mason <clm@fb.com>
Subject: Re: [PATCH RFC] ipv6_fib limit spinlock hold times for /proc/net/ipv6_route
Date: Thu, 24 Apr 2014 10:41:11 -0400
Message-ID: <53592287.2050902@fb.com>
References: <535918BC.5030708@fb.com> <20140424142030.GD1960@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:14597 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757933AbaDXOk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 10:40:26 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s3OEcPlV009791
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 07:40:26 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1ketjj1k5y-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 07:40:25 -0700
In-Reply-To: <20140424142030.GD1960@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2014 10:20 AM, Hannes Frederic Sowa wrote:
> Hi!
>
> On Thu, Apr 24, 2014 at 09:59:24AM -0400, Chris Mason wrote:
>> The ipv6 code to dump routes in /proc/net/ipv6_route can hold
>> a read lock on the table for a very long time.  This ends up blocking
>> writers and triggering softlockups.
>>
>> This patch is a simple work around to limit the number of entries
>> we'll walk while processing /proc/net/ipv6_route.  It intentionally
>> slows down proc file reading to make sure we don't lock out the
>> real ipv6 traffic.
>
> I guess most time is spent in formatting and printing the rt6_info details
> to the procfs file. Have you tried excluding !(rt6_info->rt6i_flags &
> RTF_CACHE) routes?

We do have a separate patch from Paul Saab that excludes the cached 
routes and it has a big impact (~10x fewer entries).  But the 
softlockups still flow.

I was going to discuss the cache exclusion on a separate thread, but the 
short version is that I don't have any clue of how many people we'd 
upset by unconditionally leaving out the cached entries.

>
> Maybe this is a viable alternative. A patch could also check for
> RTF_DYNAMIC and RTF_MODIFIED so we would still show redirected and
> mtu-caching nodes.
>
>> This patch is also horrible, and doesn't actually fix the entire
>> problem.  We still have rcu_read_lock held the whole time we cat
>> /proc/net/ipv6_route.  On an unpatched machine, I've clocked the
>> time required to cat /proc/net/ipv6_route at 14 minutes.
>>
>> java cats this proc file on startup to search for local routes, and the
>> resulting contention on the table lock makes our boxes fall over.
>
> Urks, does plain openjdk do that or is this something in your application?
>

Seems to be built into the jdk, and not our app.

>>
>> So, I'm sending the partial fix to get discussion started.
>
> I am planing to submit patches which reduce the caching of DST_HOST
> entries in the ipv6 fib next month which will result in a much smaller
> fib to walk by then.

Great.

-chris
