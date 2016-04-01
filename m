From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Fri, 1 Apr 2016 04:01:34 +0200
Message-ID: <56FDD67E.2040904@stressinduktion.org>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBA6E.5030508@stressinduktion.org>
 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBF0E.8020309@stressinduktion.org>
 <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
 <1459474618.3751123.565321858.30DF1858@webmail.messagingengine.com>
 <1459474756.6473.248.camel@edumazet-glaptop3.roam.corp.google.com>
 <1459475124.6473.250.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:50837 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752210AbcDACBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 22:01:39 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 2123F20CD4
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 22:01:38 -0400 (EDT)
In-Reply-To: <1459475124.6473.250.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.04.2016 03:45, Eric Dumazet wrote:
> On Thu, 2016-03-31 at 18:39 -0700, Eric Dumazet wrote:
>> On Fri, 2016-04-01 at 03:36 +0200, Hannes Frederic Sowa wrote:
>>> On Fri, Apr 1, 2016, at 03:19, Eric Dumazet wrote:
>>>> Thanks.
>>>>
>>>> As you can see, release_sock() messes badly lockdep (once your other
>>>> patches are in )
>>>>
>>>> Once we properly fix release_sock() and/or __release_sock(), all these
>>>> false positives disappear.
>>>
>>> This was a loopback connection. I need to study release_sock and
>>> __release_sock more as I cannot currently see an issue with the lockdep
>>> handling.
>>
>> Okay, please try :
>>
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index b67b9aedb230..570dcd91d64e 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -2429,10 +2429,6 @@ EXPORT_SYMBOL(lock_sock_nested);
>>
>>   void release_sock(struct sock *sk)
>>   {
>> -	/*
>> -	 * The sk_lock has mutex_unlock() semantics:
>> -	 */
>> -	mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
>>
>>   	spin_lock_bh(&sk->sk_lock.slock);
>>   	if (sk->sk_backlog.tail)
>> @@ -2445,6 +2441,10 @@ void release_sock(struct sock *sk)
>>   		sk->sk_prot->release_cb(sk);
>>
>>   	sock_release_ownership(sk);
>> +	/*
>> +	 * The sk_lock has mutex_unlock() semantics:
>> +	 */
>> +	mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
>>   	if (waitqueue_active(&sk->sk_lock.wq))
>>   		wake_up(&sk->sk_lock.wq);
>>   	spin_unlock_bh(&sk->sk_lock.slock);
>
> Also take a look at commit c3f9b01849ef3bc69024990092b9f42e20df7797
>
> We might need to include the mutex_release() in sock_release_ownership()

I thought so first, as well. But given the double check for the 
spin_lock and the "mutex" we end up with the same result for the 
lockdep_sock_is_held check.

Do you see other consequences?

Thanks,
Hannes
