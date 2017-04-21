From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net] ipv4: Avoid caching dsts when lookup skipped nh oif
 check
Date: Fri, 21 Apr 2017 18:17:10 +0100
Message-ID: <c032e425-e814-d8f6-72ac-ad66444164da@brocade.com>
References: <1492693132-4708-1-git-send-email-rshearma@brocade.com>
 <7c395b52-d639-9001-c6fa-ccacec4ce0d9@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:35295 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1041482AbdDUSbh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:31:37 -0400
In-Reply-To: <7c395b52-d639-9001-c6fa-ccacec4ce0d9@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/04/17 23:18, David Ahern wrote:
> On 4/20/17 6:58 AM, Robert Shearman wrote:
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index acd69cfe2951..f667783ffd19 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -2125,6 +2125,14 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
>>  		fi = NULL;
>>  	}
>>
>> +	/* If the flag to skip the nh oif check is set then the output
>> +	 * device may not match the nh device, so cannot use or add to
>> +	 * cache in that case.
>> +	 */
>> +	if (unlikely(fl4->flowi4_flags & FLOWI_FLAG_SKIP_NH_OIF &&
>> +		     FIB_RES_NH(*res).nh_dev != dev_out))
>> +		do_cache = false;
>> +
>>  	fnhe = NULL;
>>  	do_cache &= fi != NULL;
>>  	if (do_cache) {
>>
>
> I believe this is a better fix:
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 5e1e60546fce..fb74a16958af 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2407,7 +2407,7 @@ struct rtable *__ip_route_output_key_hash(struct
> net *net, struct flowi4 *fl4,
>                 }
>
>                 /* L3 master device is the loopback for that domain */
> -               dev_out = l3mdev_master_dev_rcu(dev_out) ? :
> net->loopback_dev;
> +               dev_out = l3mdev_master_dev_rcu(FIB_RES_DEV(res)) ? :
> net->loopback_dev;
>                 fl4->flowi4_oif = dev_out->ifindex;
>                 flags |= RTCF_LOCAL;
>                 goto make_route;
>
> Fixes: 5f02ce24c2696 ("net: l3mdev: Allow the l3mdev to be a loopback")
>
> With your change above, references to vrf devices are still taken
> (dev_out is the vrf device based on the flow struct) even though the
> route's nexthop is in another domain. And the commit log should
> reference the use case which is policy routing overriding the VRF rule.

That is indeed a nicer fix - it survives all of my local testing. Thanks 
for correcting the fixes tag too.

I had included this text in the commit message to capture the condition 
of the rules ordering: "when the rule for the lookup in the local table
is ordered before the rule for lookups using l3mdevs". However, I'll try 
to make it more prominent and expand it to note the policy routing use 
case too.

Thanks,
Rob
