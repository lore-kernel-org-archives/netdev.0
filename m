From: David Held <drheld@google.com>
Subject: Re: [PATCH net-next 2/2] udp: Use hash2 for long hash1 chains in __udp*_lib_mcast_deliver.
Date: Tue, 15 Jul 2014 09:48:20 -0400
Message-ID: <CAGa1Tm5+ZiNuuYVmjWRh5i069m8hWL0aXRDjjP=3dd0p5hWFXQ@mail.gmail.com>
References: <1405377039-10082-1-git-send-email-drheld@google.com>
	<1405377039-10082-2-git-send-email-drheld@google.com>
	<1405413181.10255.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:48598 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaGONsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 09:48:20 -0400
Received: by mail-ig0-f177.google.com with SMTP id hn18so2868372igb.10
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 06:48:20 -0700 (PDT)
In-Reply-To: <1405413181.10255.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 4:33 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-07-14 at 18:30 -0400, David Held wrote:
>> Many multicast sources can have the same port which can result in a very
>> large list when hashing by port only. Hash by address and port instead
>> if this is the case. This makes multicast more similar to unicast.
>>
>> On a 24-core machine receiving from 500 multicast sockets on the same
>> port, before this patch 80% of system CPU was used up by spin locking
>> and only ~25% of packets were successfully delivered.
>>
>> With this patch, all packets are delivered and kernel overhead is ~8%
>> system CPU on spinlocks.
>>
>> Signed-off-by: David Held <drheld@google.com>
>> ---
>>  include/net/sock.h | 14 ++++++++++++++
>>  net/ipv4/udp.c     | 30 ++++++++++++++++++++----------
>>  net/ipv6/udp.c     | 29 +++++++++++++++++++----------
>>  3 files changed, 53 insertions(+), 20 deletions(-)
>>
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index cb84b2f..6734cab 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -660,6 +660,20 @@ static inline void sk_add_bind_node(struct sock *sk,
>>  #define sk_for_each_bound(__sk, list) \
>>       hlist_for_each_entry(__sk, list, sk_bind_node)
>>
>> +/**
>> + * sk_nulls_for_each_entry_offset - iterate over a list at a given struct offset
>> + * @tpos:    the type * to use as a loop cursor.
>> + * @pos:     the &struct hlist_node to use as a loop cursor.
>> + * @head:    the head for your list.
>> + * @offset:  offset of hlist_node within the struct.
>> + *
>> + */
>> +#define sk_nulls_for_each_entry_offset(tpos, pos, head, offset)                     \
>> +     for (pos = (head)->first;                                              \
>> +          (!is_a_nulls(pos)) &&                                             \
>> +             ({ tpos = (typeof(*tpos) *)((void *)pos - offset); 1;});       \
>> +          pos = pos->next)
>> +
>>  static inline struct user_namespace *sk_user_ns(struct sock *sk)
>>  {
>>       /* Careful only use this in a context where these parameters
>> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> index 8089ba2..b023a36 100644
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>> @@ -1616,6 +1616,8 @@ static void flush_stack(struct sock **stack, unsigned int count,
>>
>>               if (skb1 && udp_queue_rcv_skb(sk, skb1) <= 0)
>>                       skb1 = NULL;
>> +
>> +             sock_put(sk);
>>       }
>>       if (unlikely(skb1))
>>               kfree_skb(skb1);
>> @@ -1648,37 +1650,45 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>>       unsigned short hnum = ntohs(uh->dest);
>>       struct udp_hslot *hslot = udp_hashslot(udptable, net, hnum);
>>       int dif = skb->dev->ifindex;
>> -     unsigned int i, count = 0;
>> +     unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
>> +     unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
>> +
> Not sure why hash2 and hash2_any are set to 0 here ?

It shouldn't be needed, but there's a spurious compiler warning
otherwise as the compiler isn't smart enough to know that the second
use_hash2 implies that they will have been set.

>
>> +     if (use_hash2) {
>> +             hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum);
>> +             hash2 = udp4_portaddr_hash(net, daddr, hnum);
>
> you probably could AND the mask here
>         hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum) & udp_table.mask;
>         hash2 = udp4_portaddr_hash(net, daddr, hnum) & udp_table.mask;

Sounds good. That solves the issue you identified below.

>> +start_lookup:
>> +             hslot = &udp_table.hash2[hash2 & udp_table.mask];
>> +             offset = offsetof(typeof(*sk), __sk_common.skc_portaddr_node);
>> +     }
>>
>>       spin_lock(&hslot->lock);
>> -     sk_nulls_for_each(sk, node, &hslot->head) {
>> +     sk_nulls_for_each_entry_offset(sk, node, &hslot->head, offset) {
>>               if (__udp_is_mcast_sock(net, sk,
>>                                       uh->dest, daddr,
>>                                       uh->source, saddr,
>>                                       dif, hnum)) {
>>                       stack[count++] = sk;
>> +                     sock_hold(sk);
>>                       if (unlikely(count == ARRAY_SIZE(stack))) {
>>                               flush_stack(stack, count, skb, ~0);
>>                               count = 0;
>>                       }
>>               }
>>       }
>> -     /*
>> -      * before releasing chain lock, we must take a reference on sockets
>> -      */
>> -     for (i = 0; i < count; i++)
>> -             sock_hold(stack[i]);
>>
>>       spin_unlock(&hslot->lock);
>>
>> +     /* Also lookup *:port if we are using hash2 and haven't done so yet. */
>> +     if (use_hash2 && hash2 != hash2_any) {
>
> The thing that really matters here is not hash2 != hash2_any, but that
> the hash bucket (after masking hash2 with udp_table.mask) is the same or
> not.
>
> If the test is not properly done here, we are doing to deliver two
> copies of each packet to each socket.

You're right. Thanks for spotting that! Will update.

>> +             hash2 = hash2_any;
>> +             goto start_lookup;
>> +     }
>> +
>
>
>
