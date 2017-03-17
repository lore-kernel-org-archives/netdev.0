From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 1/5] net: Do not record sender_cpu as napi_id in
 socket receive paths
Date: Thu, 16 Mar 2017 19:40:56 -0700
Message-ID: <CAKgT0UeTRNxb9B5Y7mhZ4QmKrUNSYDHBbQu6=kM+6X6ETuRu8g@mail.gmail.com>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
 <20170316183238.15806.14293.stgit@localhost.localdomain> <1489701936.28631.249.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UcHgdb0Z_KvjPJuS1gtcFEi8rj2dKouUeXkuvwjopDiBQ@mail.gmail.com> <1489704618.28631.267.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489704618.28631.267.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 16, 2017 at 3:50 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-03-16 at 15:33 -0700, Alexander Duyck wrote:
>> On Thu, Mar 16, 2017 at 3:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> > It is not clear why this patch is needed .
>> >
>> > What you describe here is the case we might receive packets for a socket
>> > coming from different interfaces ?
>> >
>> > If skb->napi_id is a sender_cpu, why should we prevent overwriting the
>> > sk_napi_id with it, knowing that busy polling will simply ignore the
>> > invalid value ?
>> >
>> > Do not get me wrong :
>> >
>> > I simply try to understand why the test about napi_id validity is now
>> > done twice :
>> >
>> > 1) At the time we are writing into sk->sk_napi_id
>>
>> I would argue that this is the one piece we were missing.
>>
>> > 2) At busy polling time when we read sk->sk_napi_id
>>
>> Unless there was something recently added I don't think this was ever
>> checked.  Instead we start digging into the hash looking for the ID
>> that won't ever be there.  Maybe we should add something to napi_by_id
>> that just returns NULL in these cases.
>
> But this is exactly what should happen.
>
> For invalid ID, we return NULL from napi_by_id()
>
> No need to add code for that, since the function is meant to deal with
> valid cases.

I don't know.  My concern here is about the cost of going through all
that code just for something that we know shouldn't be valid.  If
nothing else I might update sk_can_busy_loop so that it doesn't try
busy looping on a sk_napi_id that is NR_CPU or less.

>> On top of that I think there end up being several spots where once we
>> lock in a non-NAPI ID it is stuck such as the sk_mark_napi_id_once
>> call.  I figure we are better off locking in an actual NAPI ID rather
>> than getting a sender_cpu stuck in there.
>
> Are you referring to sk_mark_napi_id_once() ?
>
> Since this is only used by UDP, I would be OK to avoid the 'locking' for
> 'sender_cpu'  ids.

What I probably can do is go through and replace all the spots where
we where checking for sk_napi_id being 0, and instead replace it with
a check against NR_CPUS.
