From: Taehee Yoo <ap420073@gmail.com>
Subject: Re: [PATCH] rhashtable: Fix missing elements when inserting.
Date: Thu, 25 May 2017 01:17:16 +0900
Message-ID: <CAMArcTVKPjWg7gWfFr7iYCh=odOd0yFdRywdc-5f6gDcX4ToUQ@mail.gmail.com>
References: <20170524014950.3261-1-ap420073@gmail.com> <20170524043617.GA22594@gondor.apana.org.au>
 <CAMArcTVrGoopQseeOLFQoHheve-qMV2iE-KCPDT8UG5o97sa7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="94eb2c0a8d2c1d31a20550477061"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f196.google.com ([209.85.213.196]:33312 "EHLO
        mail-yb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966912AbdEXQRS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 12:17:18 -0400
Received: by mail-yb0-f196.google.com with SMTP id d72so6749904ybh.0
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 09:17:18 -0700 (PDT)
In-Reply-To: <CAMArcTVrGoopQseeOLFQoHheve-qMV2iE-KCPDT8UG5o97sa7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--94eb2c0a8d2c1d31a20550477061
Content-Type: text/plain; charset="UTF-8"

2017-05-25 1:13 GMT+09:00 Taehee Yoo <ap420073@gmail.com>:
> 2017-05-24 13:36 GMT+09:00 Herbert Xu <herbert@gondor.apana.org.au>:
>> Taehee Yoo <ap420073@gmail.com> wrote:
>>> rhltable_insert_key() inserts a node into list of element,
>>> if node's key is duplicated, so that it becomes the chain of
>>> element(as known as rhead). Also bucket table points that element directly.
>>> If a inserted node's element chain is located at third,
>>> rhltable misses first and second element chain.
>>> This issue is causion of to failture the rhltable_remove().
>>>
>>> After this patch, rhltable_insert_key() inserts a node into second of
>>> element's list, so that rhlist do not misses elements.
>>>
>>> Signed-off-by: Taehee Yoo <ap420073@gmail.com>
>>
>> I'm sorry but I don't understand your description of the problem.
>> The new duplicate object is always inserted at the head of the
>> list and therefore replaces the previous list head in the hash
>> bucket chain.
>>
>> Do you have some code that reproduces the problem?
>>
> I tested this problem using netfilter, therefore a attached diff file
> modifies netfilter source code.
> That diff prints fail messages if return value of rhltable_remove() is -ENOENT.
>
> I used below commands
>
> sysctl -w net.netfilter.nf_conntrack_udp_timeout=100000
> sysctl -w net.netfilter.nf_conntrack_max=1000000
> iptables -t nat -A POSTROUTING -j MASQUERADE
>
> hping3 < ip address > -2 -p 1 --flood
> hping3 < ip address > -2 -p 2 --flood
> conntrack -D > /dev/null
> we can see "nf_nat_cleanup_conntrack, not found"
>
>>> diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
>>> index 7d56a7e..d3c24b9 100644
>>> --- a/include/linux/rhashtable.h
>>> +++ b/include/linux/rhashtable.h
>>> @@ -762,11 +762,9 @@ static inline void *__rhashtable_insert_fast(
>>>                list = container_of(obj, struct rhlist_head, rhead);
>>>                plist = container_of(head, struct rhlist_head, rhead);
>>>
>>> -               RCU_INIT_POINTER(list->next, plist);
>>> -               head = rht_dereference_bucket(head->next, tbl, hash);
>>> -               RCU_INIT_POINTER(list->rhead.next, head);
>>> -               rcu_assign_pointer(*pprev, obj);
>>> -
>>> +               RCU_INIT_POINTER(list->next, rht_dereference_bucket(plist->next,
>>> +                                                                   tbl, hash));
>>> +               RCU_INIT_POINTER(plist->next, list);
>>
>> Your second RCU_INIT_POINTER needs to be rcu_assign_pointer.
>>
> Thank you, I won't forget this.
>
>> Your approach of retaining the first duplicate object as the head
>> of the list should work too but I don't really see any point in
>> changing this.
>>
>> Cheers,
>> --
>> Email: Herbert Xu <herbert@gondor.apana.org.au>
>> Home Page: http://gondor.apana.org.au/~herbert/
>> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

I'm so sorry, I did not attach diff file.

--94eb2c0a8d2c1d31a20550477061
Content-Type: text/plain; charset="US-ASCII"; name="rhashtable_test.diff"
Content-Disposition: attachment; filename="rhashtable_test.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j336yltm0

ZGlmZiAtLWdpdCBhL25ldC9uZXRmaWx0ZXIvbmZfbmF0X2NvcmUuYyBiL25ldC9uZXRmaWx0ZXIv
bmZfbmF0X2NvcmUuYwppbmRleCBiNDhkNmI1Li5hMWQ5YTU5IDEwMDY0NAotLS0gYS9uZXQvbmV0
ZmlsdGVyL25mX25hdF9jb3JlLmMKKysrIGIvbmV0L25ldGZpbHRlci9uZl9uYXRfY29yZS5jCkBA
IC03MDEsOSArNzAxLDE0IEBAIEVYUE9SVF9TWU1CT0xfR1BMKG5mX25hdF9sM3Byb3RvX3VucmVn
aXN0ZXIpOwogLyogTm8gb25lIHVzaW5nIGNvbm50cmFjayBieSB0aGUgdGltZSB0aGlzIGNhbGxl
ZC4gKi8KIHN0YXRpYyB2b2lkIG5mX25hdF9jbGVhbnVwX2Nvbm50cmFjayhzdHJ1Y3QgbmZfY29u
biAqY3QpCiB7Ci0JaWYgKGN0LT5zdGF0dXMgJiBJUFNfU1JDX05BVF9ET05FKQotCQlyaGx0YWJs
ZV9yZW1vdmUoJm5mX25hdF9ieXNvdXJjZV90YWJsZSwgJmN0LT5uYXRfYnlzb3VyY2UsCisJaW50
IGVycjsKKworCWlmIChjdC0+c3RhdHVzICYgSVBTX1NSQ19OQVRfRE9ORSkgeworCQllcnIgPSBy
aGx0YWJsZV9yZW1vdmUoJm5mX25hdF9ieXNvdXJjZV90YWJsZSwgJmN0LT5uYXRfYnlzb3VyY2Us
CiAJCQkJbmZfbmF0X2J5c291cmNlX3BhcmFtcyk7CisJCWlmIChlcnIgPT0gLUVOT0VOVCkKKwkJ
CXByaW50aygiJXMsIG5vdCBmb3VuZFxuIiwgX19mdW5jX18pOworCX0KIH0KIAogc3RhdGljIHN0
cnVjdCBuZl9jdF9leHRfdHlwZSBuYXRfZXh0ZW5kIF9fcmVhZF9tb3N0bHkgPSB7Cg==
--94eb2c0a8d2c1d31a20550477061--
