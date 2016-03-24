From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv4: Multipath needs to handle unreachable
 nexthops
Date: Thu, 24 Mar 2016 14:26:49 -0400 (EDT)
Message-ID: <20160324.142649.1341796465258541197.davem@davemloft.net>
References: <1458833154-39091-1-git-send-email-dsa@cumulusnetworks.com>
	<1458837934.12033.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbcCXS04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 14:26:56 -0400
In-Reply-To: <1458837934.12033.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Mar 2016 09:45:34 -0700

> On Thu, 2016-03-24 at 08:25 -0700, David Ahern wrote:
>> Multipath route lookups should consider knowledge about next hops and not
>> select a hop that is known to be failed.
> 
> Does not look a net candidate to me.
> 
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> ---
>>  net/ipv4/fib_semantics.c | 34 ++++++++++++++++++++++++++++++++--
>>  1 file changed, 32 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
>> index d97268e8ff10..28fc6700c2b1 100644
>> --- a/net/ipv4/fib_semantics.c
>> +++ b/net/ipv4/fib_semantics.c
>> @@ -1563,13 +1563,43 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
>>  void fib_select_multipath(struct fib_result *res, int hash)
>>  {
>>  	struct fib_info *fi = res->fi;
>> +	struct neighbour *n;
>> +	int state;
>>  
>>  	for_nexthops(fi) {
>>  		if (hash > atomic_read(&nh->nh_upper_bound))
>>  			continue;
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

Indeed, this is way too expensive as-is.
