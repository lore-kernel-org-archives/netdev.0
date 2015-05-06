From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 6/7] packet: rollover huge flows before small flows
Date: Wed, 6 May 2015 16:06:34 -0400
Message-ID: <CA+FuTSfQ5vXQeo8FqU-hi3zTqu4hx+JqJmNbmRp95M0O3um1kA@mail.gmail.com>
References: <1430936837-22655-1-git-send-email-willemb@google.com>
 <1430936837-22655-7-git-send-email-willemb@google.com> <1430940864.14545.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:35998 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbbEFUHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 16:07:06 -0400
Received: by oift201 with SMTP id t201so16916595oif.3
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 13:07:05 -0700 (PDT)
In-Reply-To: <1430940864.14545.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2015 at 3:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-05-06 at 14:27 -0400, Willem de Bruijn wrote:
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Migrate flows from a socket to another socket in the fanout group not
>> only when the socket is full. Start migrating huge flows early, to
>> divert possible 4-tuple attacks without affecting normal traffic.
>>
>> Introduce fanout_flow_is_huge(). This detects huge flows, which are
>> defined as taking up more than half the load. It does so cheaply, by
>> storing the rxhashes of the N most recent packets. If over half of
>> these are the same rxhash as the current packet, then drop it. This
>> only protects against 4-tuple attacks. N is chosen to fit all data in
>> a single cache line.
>>
>> Tested:
>>   Ran bench_rollover for 10 sec with 1.5 Mpps of single flow input.
>>
>>       lpbb5:/export/hda3/willemb# ./bench_rollover -l 1000 -r -s
>>       cpu        rx       rx.k     drop.k   rollover     r.huge   r.failed
>>        0    1202599    1202599          0          0          0          0
>>        1    1221096    1221096          0          0          0          0
>>        2    1202296    1202296          0          0          0          0
>>        3    1229998    1229998          0          0          0          0
>>        4    1229551    1229551          0          0          0          0
>>        5    1221097    1221097          0          0          0          0
>>        6    1223496    1223496          0          0          0          0
>>        7    1616768    1616768          0    8530027    8530027          0
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>> ---
>>  net/packet/af_packet.c | 30 +++++++++++++++++++++++++++---
>>  net/packet/internal.h  |  4 ++++
>>  2 files changed, 31 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index d0c4c95..4e54b6b 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -1326,6 +1326,24 @@ static int fanout_rr_next(struct packet_fanout *f, unsigned int num)
>>       return x;
>>  }
>>
>> +static bool fanout_flow_is_huge(struct packet_sock *po, struct sk_buff *skb)
>> +{
>> +     u32 rxhash;
>> +     int i, count = 0;
>> +
>> +     rxhash = skb_get_hash(skb);
>> +     spin_lock(&po->rollover->hist_lock);
>> +     for (i = 0; i < ROLLOVER_HLEN; i++)
>> +             if (po->rollover->history[i] == rxhash)
>> +                     count++;
>> +
>> +     i = po->rollover->hist_idx++ & (ROLLOVER_HLEN - 1);
>> +     po->rollover->history[i] = rxhash;
>> +     spin_unlock(&po->rollover->hist_lock);
>> +
>> +     return count > (ROLLOVER_HLEN >> 1);
>> +}
>> +
>
> I am not a huge fan of this strategy or memory placement, because of the
> spinlock that protects something which should be a hint, more than an
> ultra precise decision. At the time lock is released, the status might
> already be imprecise.
>
> You touch 3 cache lines here, one for rollover->hist_idx++, one for
> history[i] = hash, and one for the spinlock.

Do you suggest running lockless, similar to the rfs table?
I can reduce history length to make hist_idx fit in the same
cacheline.

>
> (And following patch has the atomic_long_inc() for stats)
>
>
>
