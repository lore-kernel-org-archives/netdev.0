From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 3/3] net: reserve ports for applications using fixed port
 numbers
Date: Mon, 12 Apr 2010 14:52:59 +0800
Message-ID: <4BC2C34B.50109@redhat.com>
References: <20100409101442.5051.99812.sendpatchset@localhost.localdomain>	<20100409101513.5051.97926.sendpatchset@localhost.localdomain> <201004092221.GEE32059.FHMOFVLJOFSOtQ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, opurdila@ixiacom.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, davem@davemloft.net, ebiederm@xmission.com
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201004092221.GEE32059.FHMOFVLJOFSOtQ@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa wrote:
> Hello.
> 
> Amerigo Wang wrote:
>> Index: linux-2.6/drivers/infiniband/core/cma.c
>> ===================================================================
>> --- linux-2.6.orig/drivers/infiniband/core/cma.c
>> +++ linux-2.6/drivers/infiniband/core/cma.c
>> @@ -1980,6 +1980,8 @@ retry:
>>  	/* FIXME: add proper port randomization per like inet_csk_get_port */
>>  	do {
>>  		ret = idr_get_new_above(ps, bind_list, next_port, &port);
>> +		if (inet_is_reserved_local_port(port))
>> +			ret = -EAGAIN;
> 
> You should not overwrite ret with -EAGAIN when idr_get_new_above() returned
> -ENOSPC. I don't know about idr, thus I don't know whether
> 
> 		if (!ret && inet_is_reserved_local_port(port))
> 			ret = -EAGAIN;
> 
> is correct or not.

Hmm, good catch! I think it is correct.



> 
>>  	} while ((ret == -EAGAIN) && idr_pre_get(ps, GFP_KERNEL));
>>  
>>  	if (ret)
>> @@ -2996,10 +2998,13 @@ static int __init cma_init(void)
>>  {
>>  	int ret, low, high, remaining;
>>  
>> -	get_random_bytes(&next_port, sizeof next_port);
>>  	inet_get_local_port_range(&low, &high);
>> +again:
>> +	get_random_bytes(&next_port, sizeof next_port);
>>  	remaining = (high - low) + 1;
>>  	next_port = ((unsigned int) next_port % remaining) + low;
>> +	if (inet_is_reserved_local_port(next_port))
>> +		goto again;
>>  
> 
> You should not unconditionally "goto again;".
> If all ports were reserved, it will loop forever (CPU stalls).
> 

Yeah, how about:

	int tries = 10;
	...
again:
	...
	if (inet_is_reserved_local_port(next_port)) {
		if (tries--)
			goto again;
		else
			return -EBUSY;
	}

?


>>  	cma_wq = create_singlethread_workqueue("rdma_cm");
>>  	if (!cma_wq)
> 
> 
>> Index: linux-2.6/net/sctp/socket.c
>> ===================================================================
>> --- linux-2.6.orig/net/sctp/socket.c
>> +++ linux-2.6/net/sctp/socket.c
>> @@ -5436,6 +5436,8 @@ static long sctp_get_port_local(struct s
>>  			rover++;
>>  			if ((rover < low) || (rover > high))
>>  				rover = low;
>> +			if (inet_is_reserved_local_port(rover))
>> +				continue;
> 
> This one needs to be
> 
> 			if (inet_is_reserved_local_port(rover))
> 				goto next_nolock;
> 
>>  			index = sctp_phashfn(rover);
>>  			head = &sctp_port_hashtable[index];
>>  			sctp_spin_lock(&head->lock);
> 
>  next:
> 			sctp_spin_unlock(&head->lock);
> +next_nolock:
> 		} while (--remaining > 0);
> 
> otherwise, it will loop forever if all ports were reserved.

Sorry, doesn't 'continue' jump to exactly where 'next_nolock' is??
Or I am missing something?


Thanks for your review!
