From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 2/2] net: Optimize snmp stat aggregation by walking
 all the percpu data at once
Date: Tue, 25 Aug 2015 21:36:10 +0530
Message-ID: <55DC9272.4050402@linux.vnet.ibm.com>
References: <y> <1440489266-31127-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <1440489266-31127-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <1440512908.8932.11.camel@edumazet-glaptop2.roam.corp.google.com> <55DC8E06.2040007@linux.vnet.ibm.com> <1440518424.8932.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, jiri@resnulli.us,
	edumazet@google.com, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	anton@au1.ibm.com, nacc@linux.vnet.ibm.com,
	srikar@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:50835 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755187AbbHYQJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 12:09:23 -0400
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Wed, 26 Aug 2015 02:09:20 +1000
In-Reply-To: <1440518424.8932.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2015 09:30 PM, Eric Dumazet wrote:
> On Tue, 2015-08-25 at 21:17 +0530, Raghavendra K T wrote:
>> On 08/25/2015 07:58 PM, Eric Dumazet wrote:
>
>>>
>>>
>>> This is a great idea, but kcalloc()/kmalloc() can fail and you'll crash
>>> the whole kernel at this point.
>>>
>>
>> Good catch, and my bad. Though system is in bad memory condition,
>> since fill_stat is not critical for the system do you think silently
>> returning from here is a good idea?
>> or do you think we should handle with -ENOMEM way up.?
>
> Hmm... presumably these 288 bytes could be allocated in
> inet6_fill_ifla6_attrs() stack frame.
>
> Also it is weird we fill all these stats for a device we just created
> and never enabled : initial stats are all 0 for them.
>

Yes it is.. Initially I was even thinking

1. if we could disable the stat filling just after creation ( only
allocate the space for statistics but do not fill).

2. should we have a PROC_FS_NET_SNMP config which we can disable if not
necessary.

3. should we defer this snmp_fold_walk to a workqueue. (unfortunately
there is not much to do after this stat filling which can run in
parallel before we wait for completion.. or may be there is a way).
