From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: suspicious RCU usage (netlink/rhashtable)
Date: Tue, 22 Dec 2015 16:46:38 -0500
Message-ID: <CAEfhGizBuy79qvUdOFtbpUHg-2NPb3=Lsms8Mhg4txQH6-CWyA@mail.gmail.com>
References: <CAEfhGiwEhWqwtbAhbaVCEohePUyUC+f-Ap6b4oHk1Mdkg+ZKUA@mail.gmail.com>
	<20151222.162841.889225793486693960.davem@davemloft.net>
	<CAEfhGiz1FnghHRpcYUVKhWNV=4yjfU-pAsjynKTgwPctsNQ5Gw@mail.gmail.com>
	<20151222.164225.926367017579760543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dave Jones <davej@codemonkey.org.uk>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:35512 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933232AbbLVVql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:46:41 -0500
Received: by mail-lb0-f196.google.com with SMTP id tz10so3881964lbb.2
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 13:46:40 -0800 (PST)
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com. [209.85.215.45])
        by smtp.gmail.com with ESMTPSA id n62sm2068584lfn.5.2015.12.22.13.46.39
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 13:46:39 -0800 (PST)
Received: by mail-lf0-f45.google.com with SMTP id l133so136455098lfd.2
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 13:46:39 -0800 (PST)
In-Reply-To: <20151222.164225.926367017579760543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 4:42 PM, David Miller <davem@davemloft.net> wrote:
> From: Craig Gallek <kraigatgoog@gmail.com>
> Date: Tue, 22 Dec 2015 16:38:32 -0500
>
>> On Tue, Dec 22, 2015 at 4:28 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Craig Gallek <kraigatgoog@gmail.com>
>>> Date: Tue, 22 Dec 2015 15:51:19 -0500
>>>
>>>> I was actually just looking at this as well (though a slightly
>>>> different stack).  The issue is with: c6ff5268293e rhashtable: Fix
>>>> walker list corruption
>>>>
>>>> It changed the lock acquired in rhashtable_walk_init to use the new
>>>> spinlock, but the rht_dereference macro expects the mutex.  I was
>>>> still trying to track down which repository this change came in
>>>> through, though...
>>>
>>> Both cam via my networking tree.
>> Simple fix is below.  Though, I don't understand the history of the
>> multiple locks in this structure to be sure it's correct.  I'll send
>> it as a formal patch.  Please reject if it's not the right approach.
>>
>> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
>> index 1c149e9..cc80870 100644
>> --- a/lib/rhashtable.c
>> +++ b/lib/rhashtable.c
>> @@ -516,7 +516,8 @@ int rhashtable_walk_init(struct rhashtable *ht,
>> struct rhashtable_iter *iter)
>>                 return -ENOMEM;
>>
>>         spin_lock(&ht->lock);
>> -       iter->walker->tbl = rht_dereference(ht->tbl, ht);
>> +       iter->walker->tbl =
>> +               rcu_dereference_protected(ht->tbl, lockdep_is_held(&ht->lock));
>>         list_add(&iter->walker->list, &iter->walker->tbl->walkers);
>>         spin_unlock(&ht->lock);
>
> How can this be the "fix"?  That's exactly what's in the tree.
Ah, you're right, this fix was submitted to next in 179ccc0a7364 but
hasn't made it into net-next yet.
