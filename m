From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 4/4] xps_flows: XPS for packets that don't have a socket
Date: Thu, 1 Sep 2016 16:18:39 -0700
Message-ID: <CAKgT0Uepy6wyS4Dgjw1NKfUJV=P7jC047dtmZobW1JNTGUCRPQ@mail.gmail.com>
References: <1472688605-2613704-1-git-send-email-tom@herbertland.com>
 <1472688605-2613704-5-git-send-email-tom@herbertland.com> <CAKgT0UdYQn1GNV5G=rBG4i-fUMyN6GXGzZkPEg6ZPkRxVSKGdw@mail.gmail.com>
 <CALx6S377fEV8mt1H3QzydicjqA8qBKmGshsZOQ9NFrnw8mYNQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Rick Jones <rick.jones2@hpe.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33590 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbcIAXSl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 19:18:41 -0400
Received: by mail-it0-f67.google.com with SMTP id g185so427256ith.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 16:18:40 -0700 (PDT)
In-Reply-To: <CALx6S377fEV8mt1H3QzydicjqA8qBKmGshsZOQ9NFrnw8mYNQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 1, 2016 at 8:56 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Thu, Sep 1, 2016 at 8:36 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Wed, Aug 31, 2016 at 5:10 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> xps_flows maintains a per device flow table that is indexed by the
>>> skbuff hash. The table is only consulted when there is no queue saved in
>>> a transmit socket for an skbuff.
>>>
>>> Each entry in the flow table contains a queue index and a queue
>>> pointer. The queue pointer is set when a queue is chosen using a
>>> flow table entry. This pointer is set to the head pointer in the
>>> transmit queue (which is maintained by BQL).
>>>
>>> The new function get_xps_flows_index that looks up flows in the
>>> xps_flows table. The entry returned gives the last queue a matching flow
>>> used. The returned queue is compared against the normal XPS queue. If
>>> they are different, then we only switch if the tail pointer in the TX
>>> queue has advanced past the pointer saved in the entry. In this
>>> way OOO should be avoided when XPS wants to use a different queue.
>>>
>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>> ---
>>>  net/Kconfig    |  6 +++++
>>>  net/core/dev.c | 85 +++++++++++++++++++++++++++++++++++++++++++++++-----------
>>>  2 files changed, 76 insertions(+), 15 deletions(-)
>>>
>>
>> So it looks like you didn't address the two issues I called out with
>> this patch last time.  I have called them out again below.
>>
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index 34b5322..fc68d19 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>
>> <snip>
>>
>>> @@ -3240,26 +3239,82 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
>>>  #endif
>>>  }
>>>
>>> -static u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
>>> +/* Must be called with RCU read_lock */
>>> +static int get_xps_flows_index(struct net_device *dev, struct sk_buff *skb)
>>>  {
>>> -       struct sock *sk = skb->sk;
>>> -       int queue_index = sk_tx_queue_get(sk);
>>> +#ifdef CONFIG_XPS_FLOWS
>>> +       struct xps_dev_flow_table *flow_table;
>>> +       struct xps_dev_flow ent;
>>> +       int queue_index;
>>> +       struct netdev_queue *txq;
>>> +       u32 hash;
>>>
>>> -       if (queue_index < 0 || skb->ooo_okay ||
>>> -           queue_index >= dev->real_num_tx_queues) {
>>> -               int new_index = get_xps_queue(dev, skb);
>>> -               if (new_index < 0)
>>> -                       new_index = skb_tx_hash(dev, skb);
>>> +       flow_table = rcu_dereference(dev->xps_flow_table);
>>> +       if (!flow_table)
>>> +               return -1;
>>>
>>> -               if (queue_index != new_index && sk &&
>>> -                   sk_fullsock(sk) &&
>>> -                   rcu_access_pointer(sk->sk_dst_cache))
>>> -                       sk_tx_queue_set(sk, new_index);
>>> +       queue_index = get_xps_queue(dev, skb);
>>> +       if (queue_index < 0)
>>> +               return -1;
>>
>> I really think what would make more sense here is to just call
>> skb_tx_hash to acquire the queue_index instead of just exiting.  That
>> way we don't have the flows toggling back and forth between XPS and
>> non-XPS cpus.
>>
> __netdev_pick_tx checks the return value to be < 0 and will call
> skb_tx_hash if it is.

Right, but we might be bouncing between a CPU that is listed in the
XPS maps and one that is not.  We should be performing the same checks
in either case to avoid having the traffic bounce between queues.

>>> -               queue_index = new_index;
>>> +       hash = skb_get_hash(skb);
>>> +       if (!hash)
>>> +               return -1;
>>
>> So a hash of 0 is perfectly valid.  So this line doesn't make any
>> sense.  You could just drop these two lines and work with the hash you
>> generated.
>>
> A hash of zero indicates an invalid hash. See __flow_hash_from_keys
> for instance.
>

So this is going to force all non-hashable traffic not from a socket
onto queue 0 since you are rejecting it here and that will force it
into skb_tx_hash which should give you a result of 0.  Is that what
you intend to do?

Also I would recommend moving this check up to before you call
get_xps_queue.  There isn't much point in getting the XPS queue for
hash 0 if you are are just going to throw away the value anyway.

- Alex
