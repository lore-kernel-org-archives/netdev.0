From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/6] neigh: fix a possible leak issue of neigh
 entry
Date: Fri, 15 May 2015 11:39:50 -0400 (EDT)
Message-ID: <20150515.113950.1408734283430265055.davem@davemloft.net>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
	<1431672946-300-3-git-send-email-ying.xue@windriver.com>
	<1431691962.27831.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, netdev@vger.kernel.org,
	alexei@purestorage.com, joern@purestorage.com, ja@ssi.bg
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933865AbbEOPjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 11:39:55 -0400
In-Reply-To: <1431691962.27831.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 May 2015 05:12:42 -0700

> On Fri, 2015-05-15 at 14:55 +0800, Ying Xue wrote:
>> Once modifying a pending timer of a neighbour, it's insufficient to
>> post a warning message. Instead we should not take the neighbour's
>> reference count at the same time, otherwise, it causes an issue that
>> the neighbour cannot be freed forever.
>> 
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> ---
>>  net/core/neighbour.c |    9 +++++----
>>  1 file changed, 5 insertions(+), 4 deletions(-)
>> 
>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>> index 3de6542..5595db3 100644
>> --- a/net/core/neighbour.c
>> +++ b/net/core/neighbour.c
>> @@ -164,10 +164,11 @@ static int neigh_forced_gc(struct neigh_table *tbl)
>>  
>>  static void neigh_add_timer(struct neighbour *n, unsigned long when)
>>  {
>> -	neigh_hold(n);
>> -	if (unlikely(mod_timer(&n->timer, when))) {
>> -		printk("NEIGH: BUG, double timer add, state is %x\n",
>> -		       n->nud_state);
>> +	if (likely(!mod_timer(&n->timer, when))) {
>> +		neigh_hold(n);
>> +	} else {
>> +		pr_warn("NEIGH: BUG, double timer add, state is %x\n",
>> +			n->nud_state);
>>  		dump_stack();
>>  	}
>>  }
> 
> 
> NACK

Indeed, major NACK.  And you've been told this change is unacceptable
multiple times already, and you've been told exactly why as well.
