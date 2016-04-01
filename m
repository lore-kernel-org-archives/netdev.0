From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2 net-next] net: ipv4: Consider unreachable nexthops in
 multipath routes
Date: Fri, 1 Apr 2016 08:39:30 -0600
Message-ID: <56FE8822.3080900@cumulusnetworks.com>
References: <1459463081-20206-1-git-send-email-dsa@cumulusnetworks.com>
 <alpine.LFD.2.11.1604011005480.2190@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34931 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759273AbcDAOje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 10:39:34 -0400
Received: by mail-io0-f175.google.com with SMTP id g185so154807539ioa.2
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 07:39:33 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1604011005480.2190@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/1/16 2:09 AM, Julian Anastasov wrote:
>> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
>> index d97268e8ff10..6d423faff0ce 100644
>> --- a/net/ipv4/fib_semantics.c
>> +++ b/net/ipv4/fib_semantics.c
>> @@ -1559,17 +1559,45 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
>>   }
>>
>>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
>> +static bool fib_good_nh(const struct fib_nh *nh, struct net_device *dev)
>> +{
>> +	struct neighbour *n = NULL;
>> +	int state = NUD_NONE;
>
> 	Looks like we can do it even better.
> If we use NUD_REACHABLE here...
>
>> +
>> +	if (nh->nh_scope == RT_SCOPE_LINK) {
>> +		rcu_read_lock_bh();
>> +
>> +		n = __neigh_lookup_noref(&arp_tbl, &nh->nh_gw, dev);
>> +		if (n)
>> +			state = n->nud_state;
>> +
>> +		rcu_read_unlock_bh();
>> +	}
>> +
>> +	/* outside of rcu locking using n only as a boolean
>> +	 * on whether a neighbor entry existed
>> +	 */
>> +	if (!n || (state & NUD_VALID))
>
> 	then check for '!n' is not needed. For bool type
> 'return state & NUD_VALID;' should work.

good simplification.

>
>> +		return true;
>> +
>> +	return false;
>> +}
>>
>>   void fib_select_multipath(struct fib_result *res, int hash)
>>   {
>>   	struct fib_info *fi = res->fi;
>> +	struct net_device *dev = fi->fib_dev;
>> +	struct net *net = fi->fib_net;
>>
>>   	for_nexthops(fi) {
>>   		if (hash > atomic_read(&nh->nh_upper_bound))
>>   			continue;
>>
>> -		res->nh_sel = nhsel;
>> -		return;
>> +		if (!net->ipv4.sysctl_fib_multipath_use_neigh ||
>> +		    fib_good_nh(nh, dev)) {
>
> 	This dev is from first nexthop. Better fib_good_nh
> to use nh->nh_dev instead, it is present for all nexthops
> in multipath route. We should not copy the bugs from
> fib_detect_death.

ack. Will fix.

>
>> +			res->nh_sel = nhsel;
>> +			return;
>> +		}
>>   	} endfor_nexthops(fi);
>
> 	So, you dropped the idea to give full chance for
> fallback? Now if last nexthop fails we do not fallback at all.
> We promised to prefer reachable nexthops.

I'll save the first nhsel not selected and if all fails return it. That 
keeps the fallback inline with what happens today.
