From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 2/4] net: use skb_get_hash in tx queue selection
Date: Fri, 21 Mar 2014 12:24:38 -0700
Message-ID: <CA+mtBx9mV1rBxD3Uc=T1T80dsWZ5p25GNKuRNBmT_DwDYwL4sw@mail.gmail.com>
References: <alpine.DEB.2.02.1403201701500.7187@tomh.mtv.corp.google.com>
	<1395365518.9114.116.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:46143 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbaCUTYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 15:24:39 -0400
Received: by mail-ig0-f171.google.com with SMTP id hl1so2280650igb.4
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 12:24:38 -0700 (PDT)
In-Reply-To: <1395365518.9114.116.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2014 at 6:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-03-20 at 17:09 -0700, Tom Herbert wrote:
>> __skb_get_hash tries to get the skb->hash from a connected socket
>> associated with an skb. __skb_tx_hash and get_xps_queue just call
>> skb_get_hash().
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>>  include/linux/netdevice.h |  2 +-
>>  include/linux/skbuff.h    |  2 +-
>>  net/core/flow_dissector.c | 22 +++++++++-------------
>>  3 files changed, 11 insertions(+), 15 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 4b6d12c..a1fa2e4 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -2481,7 +2481,7 @@ static inline int netif_set_xps_queue(struct net_device *dev,
>>   * as a distribution range limit for the returned value.
>>   */
>>  static inline u16 skb_tx_hash(const struct net_device *dev,
>> -                           const struct sk_buff *skb)
>> +                           struct sk_buff *skb)
>>  {
>>       return __skb_tx_hash(dev, skb, dev->real_num_tx_queues);
>>  }
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index aa2c22c..f392b74 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -2863,7 +2863,7 @@ static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
>>       return skb->queue_mapping != 0;
>>  }
>>
>> -u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
>> +u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
>>                 unsigned int num_tx_queues);
>>
>>  static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> index 107ed12..432d35a 100644
>> --- a/net/core/flow_dissector.c
>> +++ b/net/core/flow_dissector.c
>> @@ -212,6 +212,12 @@ void __skb_get_hash(struct sk_buff *skb)
>>       struct flow_keys keys;
>>       u32 hash;
>>
>> +     if (skb->sk && skb->sk->sk_hash) {
>> +             skb->hash = skb->sk->sk_hash;
>> +             skb->l4_hash = 1;
>> +             return;
>> +     }
>
> Wouldn't it be faster to simply set skb->hash in providers (TCP, UDP),
> to that we do not add this test here ?
>
Excellent idea. We should be able to eliminate all occurrences of "if
(skb->sk && skb->sk->sk_hash)" in the stack!

> After packet has been a while in a qdisc, access to skb->sk_hash will
> likely trigger a cache line miss.
>
>
>
