From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: call rcu_read_lock before checking for
 duplicate transport nodes
Date: Tue, 28 Feb 2017 22:37:35 +0800
Message-ID: <CADvbK_fzwfPnictj1yqyW5VBMtOKf5X_fWLYxjeyh4DJo2NweQ@mail.gmail.com>
References: <d239fb1c1f86e3421de4a891f8a704d37b236cbf.1488256889.git.lucien.xin@gmail.com>
 <20170228142323.GA17171@hmswarspite.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35361 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751810AbdB1Ohh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 09:37:37 -0500
In-Reply-To: <20170228142323.GA17171@hmswarspite.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 10:23 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> On Tue, Feb 28, 2017 at 12:41:29PM +0800, Xin Long wrote:
>> Commit cd2b70875058 ("sctp: check duplicate node before inserting a
>> new transport") called rhltable_lookup() to check for the duplicate
>> transport node in transport rhashtable.
>>
>> But rhltable_lookup() doesn't call rcu_read_lock inside, it could cause
>> a use-after-free issue if it tries to dereference the node that another
>> cpu has freed it. Note that sock lock can not avoid this as it is per
>> sock.
>>
>> This patch is to fix it by calling rcu_read_lock before checking for
>> duplicate transport nodes.
>>
>> Fixes: cd2b70875058 ("sctp: check duplicate node before inserting a new transport")
>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>>  net/sctp/input.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/net/sctp/input.c b/net/sctp/input.c
>> index fc45896..2a28ab2 100644
>> --- a/net/sctp/input.c
>> +++ b/net/sctp/input.c
>> @@ -884,14 +884,17 @@ int sctp_hash_transport(struct sctp_transport *t)
>>       arg.paddr = &t->ipaddr;
>>       arg.lport = htons(t->asoc->base.bind_addr.port);
>>
>> +     rcu_read_lock();
>>       list = rhltable_lookup(&sctp_transport_hashtable, &arg,
>>                              sctp_hash_params);
>>
>>       rhl_for_each_entry_rcu(transport, tmp, list, node)
>>               if (transport->asoc->ep == t->asoc->ep) {
>> +                     rcu_read_unlock();
>>                       err = -EEXIST;
>>                       goto out;
>>               }
>> +     rcu_read_unlock();
>>
>>       err = rhltable_insert_key(&sctp_transport_hashtable, &arg,
>>                                 &t->node, sctp_hash_params);
>> --
>> 2.1.0
>>
>>
>
> Hmm, rhltable_insert_key I think returns a pointer to the existing object in the
> hash table if there is a collision (according to the _rhashtable_insert_fast
> description).  Wouldn't it be better to eliminate the rhl_for_each_entry_rcu
> entirely, and just check the returned pointer from rhltable_insert_key?
I wish it could do it, but rhlist(rhltable_insert_key) allows duplicate
node to be inserted, it will never return the existing node. :(

I guess the codes you saw are only for the old rhashtable api (they are
together with rhlist codes in __rhashtable_insert_fast).

Thanks

>
> Neil
>
