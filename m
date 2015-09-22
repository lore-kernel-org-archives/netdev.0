From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RHEL6.6 PATCH] netpoll: Close race condition between
 poll_one_napi and napi_disable
Date: Tue, 22 Sep 2015 12:46:13 -0700
Message-ID: <5601B005.8050208@gmail.com>
References: <1442944823-23402-1-git-send-email-nhorman@redhat.com>
 <20150922190154.GC31679@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>,
	Neil Horman <nhorman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33653 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759697AbbIVTqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 15:46:15 -0400
Received: by pacex6 with SMTP id ex6so17811667pac.0
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 12:46:14 -0700 (PDT)
In-Reply-To: <20150922190154.GC31679@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2015 12:01 PM, Neil Horman wrote:
> On Tue, Sep 22, 2015 at 02:00:23PM -0400, Neil Horman wrote:
>> Drivers might call napi_disable while not holding the napi instance poll_lock.
>> In those instances, its possible for a race condition to exist between
>> poll_one_napi and napi_disable.  That is to say, poll_one_napi only tests the
>> NAPI_STATE_SCHED bit to see if there is work to do during a poll, and as such
>> the following may happen:
>>
>> CPU0				CPU1
>> ndo_tx_timeout			napi_poll_dev
>>   napi_disable			 poll_one_napi
>>    test_and_set_bit (ret 0)
>> 				  test_bit (ret 1)
>>     reset adapter		   napi_poll_routine
>>
>> If the adapter gets a tx timeout without a napi instance scheduled, its possible
>> for the adapter to think it has exclusive access to the hardware  (as the napi
>> instance is now scheduled via the napi_disable call), while the netpoll code
>> thinks there is simply work to do.  The result is parallel hardware access
>> leading to corrupt data structures in the driver, and a crash.
>>
>> Additionaly, there is another, more critical race between netpoll and
>> napi_disable.  The disabled napi state is actually identical to the scheduled
>> state for a given napi instance.  The implication being that, if a napi instance
>> is disabled, a netconsole instance would see the napi state of the device as
>> having been scheduled, and poll it, likely while the driver was dong something
>> requiring exclusive access.  In the case above, its fairly clear that not having
>> the rings in a state ready to be polled will cause any number of crashes.
>>
>> The fix should be pretty easy.  netpoll uses its own bit to indicate that that
>> the napi instance is in a state of being serviced by netpoll (NAPI_STATE_NPSVC).
>> We can just gate disabling on that bit as well as the sched bit.  That should
>> prevent netpoll from conducting a napi poll if we convert its set bit to a
>> test_and_set_bit operation to provide mutual exclusion
>>
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>> CC: "David S. Miller" <davem@davemloft.net>
>> CC: jmaxwell@redhat.com
>> Tested-by: jmaxwell@redhat.com
>> ---
>>   include/linux/netdevice.h |  2 ++
>>   net/core/dev.c            |  2 ++
>>   net/core/netpoll.c        | 12 ++++++++++--
>>   3 files changed, 14 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index b791405..48becac 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -507,6 +507,8 @@ static inline void napi_enable(struct napi_struct *n)
>>   	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
>>   	smp_mb__before_atomic();
>>   	clear_bit(NAPI_STATE_SCHED, &n->state);
>> +	clear_bit(NAPI_STATE_NPSVC, &n->state);
>> +
>>   }
>>   
>>   #ifdef CONFIG_SMP
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index ee0d628..b6b01bf 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -4723,6 +4723,8 @@ void napi_disable(struct napi_struct *n)
>>   
>>   	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
>>   		msleep(1);
>> +	while (test_and_set_bit(NAPI_STATE_NPSVC, &n->state))
>> +		msleep(1);
>>   
>>   	hrtimer_cancel(&n->timer);
>>   
>> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
>> index 6aa3db8..91cf217 100644
>> --- a/net/core/netpoll.c
>> +++ b/net/core/netpoll.c
>> @@ -142,7 +142,7 @@ static void queue_process(struct work_struct *work)
>>    */
>>   static int poll_one_napi(struct napi_struct *napi, int budget)
>>   {
>> -	int work;
>> +	int work = 0;
>>   
>>   	/* net_rx_action's ->poll() invocations and our's are
>>   	 * synchronized by this test which is only made while
>> @@ -151,7 +151,14 @@ static int poll_one_napi(struct napi_struct *napi, int budget)
>>   	if (!test_bit(NAPI_STATE_SCHED, &napi->state))
>>   		return budget;
>>   
>> -	set_bit(NAPI_STATE_NPSVC, &napi->state);
>> +	/*
>> + 	 * If we set this bit but see that it has already been set,
>> + 	 * that indicates that napi has been disabled and we need
>> + 	 * to abort this operation
>> + 	 */
>> +
>> +	if(test_and_set_bit(NAPI_STATE_NPSVC, &napi->state))
>> +		goto out;
>>   
>>   	work = napi->poll(napi, budget);
>>   	WARN_ONCE(work > budget, "%pF exceeded budget in poll\n", napi->poll);
>> @@ -159,6 +166,7 @@ static int poll_one_napi(struct napi_struct *napi, int budget)
>>   
>>   	clear_bit(NAPI_STATE_NPSVC, &napi->state);
>>   
>> +out:
>>   	return budget - work;
>>   }
>>   
>> -- 
>> 2.1.0
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> Shoot, I forgot to change my subject prefix, sorry about that. Dave this applies
> to net-next, shall I resubmit with a proper prefix, or are you good with it as
> is?

It looks like this patch introduces some white-space errors as well.  
The comment block has one trailing white space, and 4 spaces before 
tabs.  You might want to resubmit with that fixed.

- Alex
