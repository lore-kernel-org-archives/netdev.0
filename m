From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: ipv4: Multipath needs to handle unreachable
 nexthops
Date: Thu, 24 Mar 2016 11:43:40 -0600
Message-ID: <56F4274C.70707@cumulusnetworks.com>
References: <1458833154-39091-1-git-send-email-dsa@cumulusnetworks.com>
 <1458837934.12033.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34273 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbcCXRnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 13:43:45 -0400
Received: by mail-io0-f172.google.com with SMTP id m184so91970915iof.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 10:43:44 -0700 (PDT)
In-Reply-To: <1458837934.12033.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/24/16 10:45 AM, Eric Dumazet wrote:
> On Thu, 2016-03-24 at 08:25 -0700, David Ahern wrote:
>> Multipath route lookups should consider knowledge about next hops and not
>> select a hop that is known to be failed.
>
> Does not look a net candidate to me.

you don't consider this a bug? certainly not a feature.

>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> ---
>>   net/ipv4/fib_semantics.c | 34 ++++++++++++++++++++++++++++++++--
>>   1 file changed, 32 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
>> index d97268e8ff10..28fc6700c2b1 100644
>> --- a/net/ipv4/fib_semantics.c
>> +++ b/net/ipv4/fib_semantics.c
>> @@ -1563,13 +1563,43 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
>>   void fib_select_multipath(struct fib_result *res, int hash)
>>   {
>>   	struct fib_info *fi = res->fi;
>> +	struct neighbour *n;
>> +	int state;
>>
>>   	for_nexthops(fi) {
>>   		if (hash > atomic_read(&nh->nh_upper_bound))
>>   			continue;
>>
>> -		res->nh_sel = nhsel;
>> -		return;
>> +		state = NUD_NONE;
>> +		n = neigh_lookup(&arp_tbl, &nh->nh_gw, fi->fib_dev);
>> +		if (n) {
>> +			state = n->nud_state;
>> +			neigh_release(n);
>> +		}
>
> This looks like something that could use RCU to avoid expensive
> refcounting ?

Yes, good point.
