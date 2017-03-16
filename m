From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [net-next PATCH 1/5] net: Do not record sender_cpu as napi_id
 in socket receive paths
Date: Thu, 16 Mar 2017 15:41:03 -0700
Message-ID: <58CB147F.7080401@intel.com>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>     <20170316183238.15806.14293.stgit@localhost.localdomain> <1489701936.28631.249.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        edumazet@google.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489701936.28631.249.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 3/16/2017 3:05 PM, Eric Dumazet wrote:
> On Thu, 2017-03-16 at 11:32 -0700, Alexander Duyck wrote:
>> From: Sridhar Samudrala <sridhar.samudrala@intel.com>
>>
>> Fix sk_mark_napi_id() and sk_mark_napi_id_once() to set sk_napi_id only if
>> skb->napi_id is a valid value.
>>
>> This happens in loopback paths where skb->napi_id is not updated in
>> rx path and holds sender_cpu that is set in xmit path.
>>
>> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>   include/net/busy_poll.h |    5 +++--
>>   1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
>> index c0452de83086..67991635953e 100644
>> --- a/include/net/busy_poll.h
>> +++ b/include/net/busy_poll.h
>> @@ -116,7 +116,8 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
>>   static inline void sk_mark_napi_id(struct sock *sk, const struct sk_buff *skb)
>>   {
>>   #ifdef CONFIG_NET_RX_BUSY_POLL
>> -	sk->sk_napi_id = skb->napi_id;
>> +	if (skb->napi_id > (u32)NR_CPUS)
>> +		sk->sk_napi_id = skb->napi_id;
>>   #endif
>>   }
>>   
>> @@ -125,7 +126,7 @@ static inline void sk_mark_napi_id_once(struct sock *sk,
>>   					const struct sk_buff *skb)
>>   {
>>   #ifdef CONFIG_NET_RX_BUSY_POLL
>> -	if (!sk->sk_napi_id)
>> +	if (!sk->sk_napi_id && (skb->napi_id > (u32)NR_CPUS))
>>   		sk->sk_napi_id = skb->napi_id;
>>   #endif
>>   }
>>
> It is not clear why this patch is needed .
>
> What you describe here is the case we might receive packets for a socket
> coming from different interfaces ?

This is seen with AF_UNIX or AF_INET sockets over loopback.
>
> If skb->napi_id is a sender_cpu, why should we prevent overwriting the
> sk_napi_id with it, knowing that busy polling will simply ignore the
> invalid value ?

We are not checking for invalid VALUE(< NR_CPUs) in busy_poll,
Non-zero sk->napi_id is considered valid.

If we don't want to add this check while setting sk->sk_napi_Id, we 
could change the
check in ep_set_busy_poll_napi_id() to check for invalid value rather 
than non-zero value.

>
> Do not get me wrong :
>
> I simply try to understand why the test about napi_id validity is now
> done twice :
>
> 1) At the time we are writing into sk->sk_napi_id
>
> 2) At busy polling time when we read sk->sk_napi_id
>
>
>
