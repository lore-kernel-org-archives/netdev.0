From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 1/5] net: Do not record sender_cpu as napi_id in
 socket receive paths
Date: Thu, 16 Mar 2017 15:33:05 -0700
Message-ID: <CAKgT0UcHgdb0Z_KvjPJuS1gtcFEi8rj2dKouUeXkuvwjopDiBQ@mail.gmail.com>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
 <20170316183238.15806.14293.stgit@localhost.localdomain> <1489701936.28631.249.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489701936.28631.249.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 16, 2017 at 3:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
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
>>  include/net/busy_poll.h |    5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
>> index c0452de83086..67991635953e 100644
>> --- a/include/net/busy_poll.h
>> +++ b/include/net/busy_poll.h
>> @@ -116,7 +116,8 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
>>  static inline void sk_mark_napi_id(struct sock *sk, const struct sk_buff *skb)
>>  {
>>  #ifdef CONFIG_NET_RX_BUSY_POLL
>> -     sk->sk_napi_id = skb->napi_id;
>> +     if (skb->napi_id > (u32)NR_CPUS)
>> +             sk->sk_napi_id = skb->napi_id;
>>  #endif
>>  }
>>
>> @@ -125,7 +126,7 @@ static inline void sk_mark_napi_id_once(struct sock *sk,
>>                                       const struct sk_buff *skb)
>>  {
>>  #ifdef CONFIG_NET_RX_BUSY_POLL
>> -     if (!sk->sk_napi_id)
>> +     if (!sk->sk_napi_id && (skb->napi_id > (u32)NR_CPUS))
>>               sk->sk_napi_id = skb->napi_id;
>>  #endif
>>  }
>>
>
> It is not clear why this patch is needed .
>
> What you describe here is the case we might receive packets for a socket
> coming from different interfaces ?
>
> If skb->napi_id is a sender_cpu, why should we prevent overwriting the
> sk_napi_id with it, knowing that busy polling will simply ignore the
> invalid value ?
>
> Do not get me wrong :
>
> I simply try to understand why the test about napi_id validity is now
> done twice :
>
> 1) At the time we are writing into sk->sk_napi_id

I would argue that this is the one piece we were missing.

> 2) At busy polling time when we read sk->sk_napi_id

Unless there was something recently added I don't think this was ever
checked.  Instead we start digging into the hash looking for the ID
that won't ever be there.  Maybe we should add something to napi_by_id
that just returns NULL in these cases.

On top of that I think there end up being several spots where once we
lock in a non-NAPI ID it is stuck such as the sk_mark_napi_id_once
call.  I figure we are better off locking in an actual NAPI ID rather
than getting a sender_cpu stuck in there.
