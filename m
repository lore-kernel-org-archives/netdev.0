From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] packet: hold bind lock when rebinding to fanout hook
Date: Fri, 15 Sep 2017 16:01:55 -0400
Message-ID: <CAF=yD-+X1Tke22BV0ZrWJOw0FXr2WpNLsaCtGt6+-p2hSAnCRA@mail.gmail.com>
References: <20170914211441.67326-1-willemb@google.com> <CAM_iQpXOS3cB8GtuVZaQq7AnFkHQXxcBqkg0azMU-JpMtv4NRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Willem de Bruijn <willemb@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        nixiaoming <nixiaoming@huawei.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:57226 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751544AbdIOUCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 16:02:36 -0400
Received: by mail-io0-f176.google.com with SMTP id m103so11002196iod.13
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 13:02:36 -0700 (PDT)
In-Reply-To: <CAM_iQpXOS3cB8GtuVZaQq7AnFkHQXxcBqkg0azMU-JpMtv4NRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index c26172995511..d288f52c53f7 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -1684,10 +1684,6 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
>>
>>         mutex_lock(&fanout_mutex);
>>
>> -       err = -EINVAL;
>> -       if (!po->running)
>> -               goto out;
>> -
>>         err = -EALREADY;
>>         if (po->fanout)
>>                 goto out;
>> @@ -1749,7 +1745,10 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
>>                 list_add(&match->list, &fanout_list);
>>         }
>>         err = -EINVAL;
>> -       if (match->type == type &&
>> +
>> +       spin_lock(&po->bind_lock);
>> +       if (po->running &&
>
>
> As you move the po->running check later after setting po->rollover, I wonder
> if po->rollover possibly depends on po>running on other path?

The rollover code does not explicitly check po->running, if that is
what you are concerned about.

A newly allocated po->rollover structure will also only be accessed
from the datapath once the socket is added to a fanout group. Both
before and after this patch, that happens well after the po->running
check.

If the socket already had a po->rollover, then it must already have
had a po->fanout, too, so fanout_add does not reach this code.

>> +           match->type == type &&
>>             match->prot_hook.type == po->prot_hook.type &&
>>             match->prot_hook.dev == po->prot_hook.dev) {
>>                 err = -ENOSPC;
>> @@ -1761,6 +1760,13 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
>>                         err = 0;
>>                 }
>>         }
>> +       spin_unlock(&po->bind_lock);
>> +
>> +       if (err && !refcount_read(&match->sk_ref)) {
>> +               list_del(&match->list);
>> +               kfree(match);
>> +       }
>
> This looks correct but still seems odd, it smells you don't use refcnt in an
> expected way.

It tests whether the object has no references, in which case it must have
been newly allocated and the fanout join operation must have failed.

I don't see an obviously simpler patch.

The entire code could perhaps be restructured eventually. There is,
for instance, no reason to test match->{type, prot_hook.type, prot_hook.dev}
when having just allocated the structure. Nor to test whether sk_ref exceeds
PACKET_FANOUT_MAX. Conversely, this sk_ref == 0 test only makes sense
when having taken the (!match) branch earlier.

But a refactor is out of scope for a bug fix.
