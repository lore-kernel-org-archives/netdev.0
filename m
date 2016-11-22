From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH] net: ipv6: avoid errors due to per-cpu atomic alloc
Date: Tue, 22 Nov 2016 13:17:44 +0000
Message-ID: <05518e10-0da0-ab83-8917-02853e34ac3e@brocade.com>
References: <1479810840-19122-1-git-send-email-mmanning@brocade.com>
 <718b6520-686e-cab3-1c8d-9e1de4cb0dbd@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:39020 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753253AbcKVNSi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 08:18:38 -0500
In-Reply-To: <718b6520-686e-cab3-1c8d-9e1de4cb0dbd@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2016 12:18 PM, Hannes Frederic Sowa wrote:
> On 22.11.2016 11:34, Mike Manning wrote:
>> Bursts of failures may occur when adding IPv6 routes via Netlink to the
>> kernel when testing under scale (e.g. 500 routes lost out of 1M). The
>> reason is that percpu.c:pcpu_balance_workfn() is not guaranteed to have
>> extended the area map in time for the atomic allocation using percpu.c:
>> pcpu_alloc() to succeed. This results in route additions failing with
>> an -ENOMEM error.
>>
>> While the sender of the Netlink msg to add this route could check for
>> an ACK and retransmit in the case of an -ENOMEM error, the latter
>> should not occur in the first place if there is plenty of memory. The
>> solution is to use non-atomic alloc for rt6_info instead. While the
>> client may now be blocked for longer depending on the state of the
>> chunk being added to, this work has to be incurred at some point.
>>
>> The alternative solution would be to provide configurable parameters
>> e.g. via sysctl in percpu.c for default map size, low/high empty pages
>> and map margins. For this solution, the map margin sizes need to be
>> stored per chunk, as large margins cannot be used if the dynamic early
>> slots map size is in use. This is not a preferred solution though, as
>> it requires tuning of these parameters to provide sufficient margins to
>> avoid -ENOMEM errors depending on system requirements.
>>
>> Signed-off-by: Mike Manning <mmanning@brocade.com>
>> ---
>>  net/ipv6/route.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 1b57e11..0e9bb76 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -347,7 +347,7 @@ struct rt6_info *ip6_dst_alloc(struct net *net,
>>  	struct rt6_info *rt = __ip6_dst_alloc(net, dev, flags);
>>  
>>  	if (rt) {
>> -		rt->rt6i_pcpu = alloc_percpu_gfp(struct rt6_info *, GFP_ATOMIC);
>> +		rt->rt6i_pcpu = alloc_percpu_gfp(struct rt6_info *, GFP_KERNEL);
>>  		if (rt->rt6i_pcpu) {
>>  			int cpu;
> 
> Nak, this doesn't work, as ip6_dst_alloc must be callable from
> non-blocking code paths unfortunately.
> 
> 

Thanks for the prompt reply.

Do you consider the alternative of providing configurable parameters for per-cpu
alloc as viable, or is there a better way of dealing with this?

While I have tested such param changes under scale as avoiding the -ENOMEM errors, it
would be good to get confirmation that this approach is acceptable prior to coding the
sysctl handling for these.
