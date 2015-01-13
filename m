From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] rhashtable: unnecessary to use delayed work
Date: Tue, 13 Jan 2015 17:48:54 +0800
Message-ID: <54B4EA06.8010507@windriver.com>
References: <1421139645-1588-1-git-send-email-ying.xue@windriver.com> <20150113093550.GG20387@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35441 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbbAMJtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 04:49:21 -0500
In-Reply-To: <20150113093550.GG20387@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2015 05:35 PM, Thomas Graf wrote:
> On 01/13/15 at 05:00pm, Ying Xue wrote:
>> When we put our declared work task in the global workqueue with
>> schedule_delayed_work(), its delay parameter is always zero.
>> Therefore, we should define a normal work in rhashtable structure
>> instead of a delayed work.
>>
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> Cc: Thomas Graf <tgraf@suug.ch>
> 
>> @@ -914,7 +914,7 @@ void rhashtable_destroy(struct rhashtable *ht)
>>  
>>  	mutex_lock(&ht->mutex);
>>  
>> -	cancel_delayed_work(&ht->run_work);
>> +	cancel_work_sync(&ht->run_work);
>>  	bucket_table_free(rht_dereference(ht->tbl, ht));
>>  
>>  	mutex_unlock(&ht->mutex);
> 
> I like the patch!
> 
> I think it introduces a possible dead lock though (see below). OTOH, it
> could actually explain the reason for the 0day lock debug splash that
> was reported.
> 
> Dead lock: The worker could already have been kicked off but was
> interrupted before it acquired ht->mutex. rhashtable_destroy() is
> called and acquired ht->mutex. cancel_work_sync() waits for worker to
> finish while holding ht->mutex. Worker can't finish because it needs to
> acquire ht->mutex to do so.
> 
> For the very same reason the reported warning could have been triggered.
> Instead of the dead lock, it would have called bucket_table_free()
> with a deferred resizer still underway.
> 
> What about we do something like this?
> 
> void rhashtable_destroy(struct rhashtable *ht)
> {
>         ht->being_destroyed = true;
> 	cancel_work_sync(&ht->run_work);
> 
> 	mutex_lock(&ht->mutex);
> 	bucket_table_free(rht_dereference(ht->tbl, ht));
> 	mutex_unlock(&ht->mutex);
> }
> 

Damn! I knew your above described deadlock scenario. Thank you for the
nice catch!

> If you agree we can explain this shortly in the commit message and add:
> Fixes: 97defe1 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
> 

OK, I will deliver the next version.

By the way, I think we should check the following condition before call
cancel_work_sync(), otherwise, we may cancel an uninitialized work.

(ht->p.grow_decision || ht->p.shrink_decision)

What do you think?

Regards,
Ying

> 
