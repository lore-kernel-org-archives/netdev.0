From: Taehee Yoo <ap420073@gmail.com>
Subject: Re: [PATCH] rhashtable: Fix missing elements when inserting.
Date: Thu, 25 May 2017 01:13:05 +0900
Message-ID: <CAMArcTVrGoopQseeOLFQoHheve-qMV2iE-KCPDT8UG5o97sa7g@mail.gmail.com>
References: <20170524014950.3261-1-ap420073@gmail.com> <20170524043617.GA22594@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:35221 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758036AbdEXQNG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 12:13:06 -0400
Received: by mail-yw0-f196.google.com with SMTP id p144so13118175ywp.2
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 09:13:06 -0700 (PDT)
In-Reply-To: <20170524043617.GA22594@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-05-24 13:36 GMT+09:00 Herbert Xu <herbert@gondor.apana.org.au>:
> Taehee Yoo <ap420073@gmail.com> wrote:
>> rhltable_insert_key() inserts a node into list of element,
>> if node's key is duplicated, so that it becomes the chain of
>> element(as known as rhead). Also bucket table points that element directly.
>> If a inserted node's element chain is located at third,
>> rhltable misses first and second element chain.
>> This issue is causion of to failture the rhltable_remove().
>>
>> After this patch, rhltable_insert_key() inserts a node into second of
>> element's list, so that rhlist do not misses elements.
>>
>> Signed-off-by: Taehee Yoo <ap420073@gmail.com>
>
> I'm sorry but I don't understand your description of the problem.
> The new duplicate object is always inserted at the head of the
> list and therefore replaces the previous list head in the hash
> bucket chain.
>
> Do you have some code that reproduces the problem?
>
I tested this problem using netfilter, therefore a attached diff file
modifies netfilter source code.
That diff prints fail messages if return value of rhltable_remove() is -ENOENT.

I used below commands

sysctl -w net.netfilter.nf_conntrack_udp_timeout=100000
sysctl -w net.netfilter.nf_conntrack_max=1000000
iptables -t nat -A POSTROUTING -j MASQUERADE

hping3 < ip address > -2 -p 1 --flood
hping3 < ip address > -2 -p 2 --flood
conntrack -D > /dev/null
we can see "nf_nat_cleanup_conntrack, not found"

>> diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
>> index 7d56a7e..d3c24b9 100644
>> --- a/include/linux/rhashtable.h
>> +++ b/include/linux/rhashtable.h
>> @@ -762,11 +762,9 @@ static inline void *__rhashtable_insert_fast(
>>                list = container_of(obj, struct rhlist_head, rhead);
>>                plist = container_of(head, struct rhlist_head, rhead);
>>
>> -               RCU_INIT_POINTER(list->next, plist);
>> -               head = rht_dereference_bucket(head->next, tbl, hash);
>> -               RCU_INIT_POINTER(list->rhead.next, head);
>> -               rcu_assign_pointer(*pprev, obj);
>> -
>> +               RCU_INIT_POINTER(list->next, rht_dereference_bucket(plist->next,
>> +                                                                   tbl, hash));
>> +               RCU_INIT_POINTER(plist->next, list);
>
> Your second RCU_INIT_POINTER needs to be rcu_assign_pointer.
>
Thank you, I won't forget this.

> Your approach of retaining the first duplicate object as the head
> of the list should work too but I don't really see any point in
> changing this.
>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
